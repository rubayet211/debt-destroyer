import Fastify, { type FastifyInstance } from 'fastify';
import jwt from 'jsonwebtoken';

import { loadConfig, type AppConfig } from './config.js';
import {
  bootstrapChallengeRequestSchema,
  bootstrapVerifyRequestSchema,
  extractionRequestSchema,
  extractionResponseSchema,
  tokenRefreshRequestSchema,
  type ExtractionPayload,
} from './types.js';
import { AppError } from './utils.js';
import { ConfigurableAttestationVerifier } from './services/attestation.js';
import { makeId, makeNonce, makeOpaqueToken, redactTextPreview, sha256 } from './services/crypto.js';
import { GeminiProvider, type AiProvider } from './services/provider.js';
import { createRateLimiter, type RateLimiter } from './services/rate-limit.js';
import {
  createStore,
  hashToken,
  monthKeyFor,
  type AppStore,
  type UsageSnapshot,
} from './services/storage.js';
import { normalizeExtraction } from './services/schema.js';

type CreateAppOptions = {
  config?: AppConfig;
  store?: AppStore;
  provider?: AiProvider;
  rateLimiter?: RateLimiter;
};

type AccessTokenPayload = {
  installId: string;
  type: 'access';
};

export async function createApp(options: CreateAppOptions = {}) {
  const config = options.config ?? loadConfig();
  const store: AppStore =
    options.store ?? (await createStore(config.postgresUrl));
  const provider = options.provider ?? new GeminiProvider(config);
  const rateLimiter: RateLimiter =
    options.rateLimiter ?? (await createRateLimiter(config.redisUrl));
  const attestationVerifier = new ConfigurableAttestationVerifier(config);

  const app = Fastify({
    logger: {
      level: config.environment === 'production' ? 'info' : 'debug',
    },
  });

  app.setErrorHandler(async (error, request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: error.code,
        message: error.message,
        details: error.details,
      });
    }
    request.log.error(error);
    return reply.status(500).send({
      error: 'internal_error',
      message: 'Unexpected server failure',
    });
  });

  app.addHook('onClose', async () => {
    await store.close?.();
    await rateLimiter.close?.();
  });

  app.get('/health/live', async () => ({ ok: true, status: 'live' }));
  app.get('/health/ready', async () => ({ ok: true, status: 'ready' }));

  app.post('/v1/mobile/bootstrap/challenge', async (request, reply) => {
    const body = bootstrapChallengeRequestSchema.parse(request.body);
    const challengeId = makeId();
    const nonce = makeNonce();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await store.createChallenge({
      challengeId,
      installId: body.install_id,
      nonce,
      expiresAt,
      consumedAt: null,
    });

    await store.saveAuditEvent({
      installId: body.install_id,
      eventType: 'bootstrap.challenge.created',
      payload: {
        appVersion: body.app_version,
        platform: body.platform,
      },
    });

    return reply.send({
      challenge_id: challengeId,
      nonce,
      attestation_provider: 'play_integrity',
      instructions:
        'Submit the nonce to Play Integrity and send the resulting token to /verify.',
    });
  });

  app.post('/v1/mobile/bootstrap/verify', async (request, reply) => {
    const body = bootstrapVerifyRequestSchema.parse(request.body);
    const challenge = await store.getChallenge(body.challenge_id);
    if (!challenge || challenge.installId !== body.install_id) {
      throw new AppError(400, 'invalid_challenge', 'Challenge not found');
    }
    if (challenge.consumedAt) {
      throw new AppError(400, 'challenge_consumed', 'Challenge already used');
    }
    if (challenge.expiresAt.getTime() < Date.now()) {
      throw new AppError(400, 'challenge_expired', 'Challenge expired');
    }

    const verdict = await attestationVerifier.verify({
      attestationToken: body.attestation_token,
      installId: body.install_id,
      nonce: challenge.nonce,
    });
    if (!verdict.valid) {
      throw new AppError(401, 'attestation_failed', verdict.reason ?? 'Invalid attestation');
    }

    const challengeConsumed = await store.consumeChallengeIfUnused(
      body.challenge_id,
    );
    if (!challengeConsumed) {
      throw new AppError(
        400,
        'challenge_consumed',
        'Challenge already used',
      );
    }
    await store.upsertInstall({
      installId: body.install_id,
      attestationStatus: verdict.status,
      blockedUntil: null,
      lastSeenAt: new Date(),
    });

    const accessToken = signAccessToken(config, body.install_id);
    const refreshToken = makeOpaqueToken();
    const refreshHash = hashToken(refreshToken);
    await store.saveRefreshToken({
      tokenId: makeId(),
      installId: body.install_id,
      tokenHash: refreshHash,
      expiresAt: new Date(
        Date.now() + config.refreshTokenTtlDays * 24 * 60 * 60 * 1000,
      ),
      revokedAt: null,
    });

    await store.saveAuditEvent({
      installId: body.install_id,
      eventType: 'bootstrap.verify.succeeded',
      payload: {
        appVersion: body.device.app_version,
        platform: body.device.platform,
        attestationStatus: verdict.status,
      },
    });

    return reply.send({
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in_seconds: config.accessTokenTtlSeconds,
      session: {
        install_id: body.install_id,
        attestation_status: verdict.status,
      },
    });
  });

  app.post('/v1/mobile/token/refresh', async (request, reply) => {
    const body = tokenRefreshRequestSchema.parse(request.body);
    const stored = await store.getRefreshTokenByHash(hashToken(body.refresh_token));
    if (!stored || stored.revokedAt || stored.expiresAt.getTime() < Date.now()) {
      throw new AppError(401, 'invalid_refresh_token', 'Refresh token invalid');
    }

    await store.revokeRefreshToken(stored.tokenHash);
    const accessToken = signAccessToken(config, stored.installId);
    const nextRefreshToken = makeOpaqueToken();
    await store.saveRefreshToken({
      tokenId: makeId(),
      installId: stored.installId,
      tokenHash: hashToken(nextRefreshToken),
      expiresAt: new Date(
        Date.now() + config.refreshTokenTtlDays * 24 * 60 * 60 * 1000,
      ),
      revokedAt: null,
    });

    return reply.send({
      access_token: accessToken,
      refresh_token: nextRefreshToken,
      expires_in_seconds: config.accessTokenTtlSeconds,
    });
  });

  app.get('/v1/mobile/me/capabilities', async (request, reply) => {
    const installId = await requireInstallId(request, config);
    const quota = await getQuotaSnapshot(store, config, installId);
    const entitlement = await store.getEntitlement(installId);
    return reply.send({
      premium: entitlement.isPremium,
      features: entitlement.features,
      free_scan_remaining: quota.remaining_free_scans,
      rate_limit_state: 'ok',
    });
  });

  app.post('/v1/ai/extractions', async (request, reply) => {
    const installId = await requireInstallId(request, config);
    const body = extractionRequestSchema.parse(request.body);
    if (body.install_id !== installId) {
      throw new AppError(403, 'install_mismatch', 'Install id mismatch');
    }

    const installRate = await rateLimiter.consume(`install:${installId}`, 20, 60);
    const ipRate = await rateLimiter.consume(
      `ip:${request.ip}`,
      60,
      60,
    );
    await store.saveRateLimitEvent({
      installId,
      ipAddress: request.ip,
      key: 'install',
      limitValue: 20,
      remaining: installRate.remaining,
      resetAt: installRate.resetAt,
    });
    if (!installRate.allowed || !ipRate.allowed) {
      throw new AppError(429, 'rate_limited', 'Too many extraction requests', {
        retry_at: (installRate.allowed ? ipRate.resetAt : installRate.resetAt).toISOString(),
      });
    }

    const entitlement = await store.getEntitlement(installId);
    const monthKey = monthKeyFor(new Date());
    const reservedQuota = entitlement.isPremium
      ? null
      : await store.reserveQuotaSlot(
          installId,
          monthKey,
          config.freeScanLimit,
          quotaReservationTtlSeconds(config),
        );
    if (reservedQuota !== null && !reservedQuota.allowed) {
      throw new AppError(
        429,
        'quota_exhausted',
        'No cloud extraction quota remaining',
        {
          quota: makeQuotaSnapshot(config, reservedQuota.usage, true),
        },
      );
    }

    const startedAt = Date.now();
    const reservationId = reservedQuota?.reservationId ?? null;
    let rawResult: Record<string, unknown>;
    try {
      rawResult = await provider.extract({
        classification: body.document_classification,
        normalizedText: body.normalized_ocr_text,
      });
    } catch (error) {
      await store.saveAuditEvent({
        installId,
        requestId: body.request_id,
        eventType: 'extraction.provider.failed',
        payload: {
          message: error instanceof Error ? error.message : 'unknown',
        },
      });
      if (reservationId !== null) {
        await store.releaseQuotaSlot(reservationId);
      }
      throw error;
    }

    try {
      const normalized = normalizeExtraction(rawResult);
      const durationMs = Date.now() - startedAt;

      await store.saveExtractionAudit({
        requestId: body.request_id,
        installId,
        classification: body.document_classification,
        provider: provider.providerName,
        model: provider.modelName,
        status: 'success',
        latencyMs: durationMs,
        ocrHash: sha256(body.normalized_ocr_text),
        ocrPreview: redactTextPreview(body.normalized_ocr_text),
        warnings: normalized.warnings,
      });

      await store.saveAuditEvent({
        installId,
        requestId: body.request_id,
        eventType: 'extraction.completed',
        payload: {
          classification: body.document_classification,
          durationMs,
          warnings: normalized.warnings,
        },
      });

      if (reservationId !== null) {
        await store.commitQuotaSlot(reservationId);
      }
      const usageSnapshot = entitlement.isPremium
        ? null
        : await store.getUsageSnapshot(installId, monthKey);
      const nextQuota = entitlement.isPremium
        ? {
            allowed: true,
            remaining_free_scans: config.freeScanLimit,
            premium_required: false,
            reset_at: nextMonthReset().toISOString(),
          }
        : makeQuotaSnapshot(config, usageSnapshot!, false);

      const response = extractionResponseSchema.parse({
        extraction: normalized.payload,
        warnings: normalized.warnings,
        quota: nextQuota,
        meta: {
          request_id: body.request_id,
          provider: provider.providerName,
          model: provider.modelName,
          classification: body.document_classification,
          duration_ms: durationMs,
        },
      });

      return reply.send(response);
    } catch (error) {
      if (reservationId !== null) {
        await store.releaseQuotaSlot(reservationId);
      }
      throw error;
    }
  });

  return app;
}

async function requireInstallId(
  request: Parameters<FastifyInstance['route']>[0]['handler'] extends (
    ...args: infer T
  ) => unknown
    ? T[0]
    : never,
  config: AppConfig,
) {
  const authHeader = request.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    throw new AppError(401, 'missing_auth', 'Bearer token required');
  }
  const token = authHeader.slice('Bearer '.length);
  try {
    const payload = jwt.verify(token, config.jwtAccessSecret) as AccessTokenPayload;
    if (payload.type !== 'access') {
      throw new AppError(401, 'invalid_auth', 'Invalid token type');
    }
    return payload.installId;
  } catch (_) {
    throw new AppError(401, 'invalid_auth', 'Access token invalid or expired');
  }
}

function signAccessToken(config: AppConfig, installId: string) {
  return jwt.sign(
    {
      installId,
      type: 'access',
    } satisfies AccessTokenPayload,
    config.jwtAccessSecret,
    {
      expiresIn: config.accessTokenTtlSeconds,
    },
  );
}

async function getQuotaSnapshot(
  store: AppStore,
  config: AppConfig,
  installId: string,
) {
  const entitlement = await store.getEntitlement(installId);
  if (entitlement.isPremium) {
    return {
      allowed: true,
      remaining_free_scans: config.freeScanLimit,
      premium_required: false,
      reset_at: nextMonthReset().toISOString(),
    };
  }
  const usage = await store.getUsageSnapshot(installId, monthKeyFor(new Date()));
  return makeQuotaSnapshot(config, usage, true);
}

function makeQuotaSnapshot(
  config: AppConfig,
  usage: UsageSnapshot,
  premiumRequiredOnExhaustion: boolean,
) {
  const effectiveCount = usage.cloudExtractions + usage.reservedExtractions;
  const remaining = Math.max(0, config.freeScanLimit - effectiveCount);
  return {
    allowed: remaining > 0,
    remaining_free_scans: remaining,
    premium_required: premiumRequiredOnExhaustion && remaining <= 0,
    reset_at: nextMonthReset().toISOString(),
  };
}

function quotaReservationTtlSeconds(config: AppConfig) {
  return Math.max(30, Math.ceil(config.requestTimeoutMs / 1000) * 2);
}

function nextMonthReset() {
  const now = new Date();
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1));
}
