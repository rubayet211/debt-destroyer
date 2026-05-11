import Fastify, {
  type FastifyInstance,
  type FastifyReply,
  type FastifyRequest,
} from "fastify";
import jwt from "jsonwebtoken";
import { ZodError } from "zod";

import { loadConfig, type AppConfig } from "./config.js";
import {
  bootstrapChallengeRequestSchema,
  bootstrapVerifyRequestSchema,
  billingRestoreRequestSchema,
  billingVerifyRequestSchema,
  entitlementResponseSchema,
  extractionRequestSchema,
  extractionResponseSchema,
  tokenRefreshRequestSchema,
  type ExtractionPayload,
} from "./types.js";
import { AppError } from "./utils.js";
import {
  ConfigurableAttestationVerifier,
  type AttestationVerifier,
} from "./services/attestation.js";
import {
  makeId,
  makeNonce,
  makeOpaqueToken,
  redactTextPreview,
  sha256,
} from "./services/crypto.js";
import {
  createBillingVerifier,
  type BillingVerifier,
} from "./services/billing.js";
import { GeminiProvider, type AiProvider } from "./services/provider.js";
import { createRateLimiter, type RateLimiter } from "./services/rate-limit.js";
import {
  createStore,
  type EntitlementRecord,
  freeEntitlementRecord,
  hashToken,
  monthKeyFor,
  normalizeEntitlementRecord,
  type AppStore,
  type UsageSnapshot,
} from "./services/storage.js";
import { normalizeExtraction } from "./services/schema.js";

type CreateAppOptions = {
  config?: AppConfig;
  store?: AppStore;
  provider?: AiProvider;
  rateLimiter?: RateLimiter;
  billingVerifier?: BillingVerifier;
  attestationVerifier?: AttestationVerifier;
};

type AccessTokenPayload = {
  installId: string;
  type: "access";
};

export async function createApp(options: CreateAppOptions = {}) {
  const config = withRuntimeDefaults(options.config ?? loadConfig());
  if (
    (config.environment === "production" || config.environment === "staging") &&
    !config.postgresUrl
  ) {
    throw new Error(
      "POSTGRES_URL is required in staging/production. Refusing to start with memory storage.",
    );
  }
  if (
    (config.environment === "production" || config.environment === "staging") &&
    !config.redisUrl
  ) {
    throw new Error(
      "REDIS_URL is required in staging/production. Refusing to start with memory rate limiting.",
    );
  }
  const store: AppStore =
    options.store ??
    (await createStore(
      config.postgresUrl,
      config.environment,
      config.postgresPool,
    ));
  const provider = options.provider ?? new GeminiProvider(config);
  const billingVerifier =
    options.billingVerifier ?? createBillingVerifier(config);
  const rateLimiter: RateLimiter =
    options.rateLimiter ??
    (await createRateLimiter(config.redisUrl, config.environment));
  const attestationVerifier =
    options.attestationVerifier ?? new ConfigurableAttestationVerifier(config);

  const app = Fastify({
    trustProxy: config.trustProxy,
    logger: {
      level: config.logLevel,
      base: {
        service: 'debt-destroyer-backend',
        environment: config.environment,
      },
    },
  });
  const extractionAliasDeprecatedAt = new Date().toUTCString();
  const extractionAliasSunsetAt = new Date(
    Date.now() + 30 * 24 * 60 * 60 * 1000,
  ).toUTCString();

  app.setErrorHandler(async (error, request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: error.code,
        message: error.message,
        details: config.environment === "production" ? undefined : error.details,
      });
    }
    if (error instanceof ZodError) {
      const issues = error.issues.map((issue) => ({
        path: issue.path.join("."),
        code: issue.code,
        ...(config.environment === "production"
          ? {}
          : { message: issue.message }),
      }));
      return reply.status(400).send({
        error: "validation_error",
        message: "Invalid request payload",
        issues,
      });
    }
    request.log.error(error);
    return reply.status(500).send({
      error: "internal_error",
      message: "Unexpected server failure",
    });
  });

  let cleanupInterval: NodeJS.Timeout | null = null;
  if (config.enableCleanupJobs) {
    const intervalMs = config.cleanupIntervalMinutes * 60 * 1000;
    cleanupInterval = setInterval(() => {
      void store
        .cleanupExpiredData(new Date())
        .then((summary) => {
          app.log.debug({ summary }, "cleanup job completed");
        })
        .catch((error: unknown) => {
          app.log.error(error, "cleanup job failed");
        });
    }, intervalMs);
    cleanupInterval.unref();
  }

  app.addHook("onClose", async () => {
    if (cleanupInterval) {
      clearInterval(cleanupInterval);
    }
    await store.close?.();
    await rateLimiter.close?.();
  });

  app.get("/health/live", async () => ({ status: "ok" }));
  app.get("/health/ready", async (_request, reply) => {
    const checks = await buildReadinessChecks(config, store, rateLimiter);
    const isReady = Object.values(checks).every((value) => value === "ok");
    if (!isReady) {
      return reply.status(503).send({
        status: "error",
        checks,
      });
    }
    return reply.send({ status: "ok" });
  });

  app.post("/v1/mobile/bootstrap/challenge", async (request, reply) => {
    const body = bootstrapChallengeRequestSchema.parse(request.body);
    await enforceRateLimit({
      rateLimiter,
      store,
      key: `bootstrap:challenge:ip:${request.ip}`,
      limit: config.rateLimits.bootstrapChallengePerMinute,
      windowSeconds: 60,
      eventKey: "bootstrap_challenge",
      installId: body.install_id,
      ipAddress: request.ip,
    });
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
      eventType: "bootstrap.challenge.created",
      payload: {
        appVersion: body.app_version,
        platform: body.platform,
      },
    });

    return reply.send({
      challenge_id: challengeId,
      nonce,
      attestation_provider: "play_integrity",
      instructions:
        "Submit the nonce to Play Integrity and send the resulting token to /verify.",
    });
  });

  app.post("/v1/mobile/bootstrap/verify", async (request, reply) => {
    const body = bootstrapVerifyRequestSchema.parse(request.body);
    await enforceRateLimit({
      rateLimiter,
      store,
      key: `bootstrap:verify:ip:${request.ip}`,
      limit: config.rateLimits.bootstrapVerifyPerMinute,
      windowSeconds: 60,
      eventKey: "bootstrap_verify",
      installId: body.install_id,
      ipAddress: request.ip,
    });
    const challenge = await store.getChallenge(body.challenge_id);
    if (!challenge || challenge.installId !== body.install_id) {
      throw new AppError(400, "invalid_challenge", "Challenge not found");
    }
    if (challenge.consumedAt) {
      throw new AppError(400, "challenge_consumed", "Challenge already used");
    }
    if (challenge.expiresAt.getTime() < Date.now()) {
      throw new AppError(400, "challenge_expired", "Challenge expired");
    }

    const verdict = await attestationVerifier.verify({
      attestationToken: body.attestation_token,
      installId: body.install_id,
      nonce: challenge.nonce,
    });
    if (!verdict.valid) {
      throw new AppError(
        401,
        "attestation_failed",
        verdict.reason ?? "Invalid attestation",
      );
    }

    const challengeConsumed = await store.consumeChallengeIfUnused(
      body.challenge_id,
    );
    if (!challengeConsumed) {
      throw new AppError(400, "challenge_consumed", "Challenge already used");
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
      eventType: "bootstrap.verify.succeeded",
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

  app.post("/v1/mobile/token/refresh", async (request, reply) => {
    const body = tokenRefreshRequestSchema.parse(request.body);
    await enforceRateLimit({
      rateLimiter,
      store,
      key: `token:refresh:ip:${request.ip}`,
      limit: config.rateLimits.tokenRefreshPerMinute,
      windowSeconds: 60,
      eventKey: "token_refresh",
      ipAddress: request.ip,
    });
    const stored = await store.getRefreshTokenByHash(
      hashToken(body.refresh_token),
    );
    if (
      !stored ||
      stored.revokedAt ||
      stored.expiresAt.getTime() < Date.now()
    ) {
      throw new AppError(401, "invalid_refresh_token", "Refresh token invalid");
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

  app.get("/v1/mobile/me/capabilities", async (request, reply) => {
    const installId = await requireInstallId(request, config);
    const quota = await getQuotaSnapshot(store, config, installId);
    const entitlement = await store.getEntitlement(installId);
    return reply.send({
      premium: entitlement.isPremium,
      features: entitlement.features,
      free_scan_remaining: quota.remaining_free_scans,
      rate_limit_state: "ok",
      entitlement: serializeEntitlement(entitlement),
    });
  });

  app.post("/v1/billing/google-play/verify", async (request, reply) => {
    const installId = await requireInstallId(request, config);
    await enforceRateLimit({
      rateLimiter,
      store,
      key: `billing:verify:install:${installId}`,
      limit: config.rateLimits.billingVerifyPerMinute,
      windowSeconds: 60,
      eventKey: "billing_verify",
      installId,
      ipAddress: request.ip,
    });
    const body = billingVerifyRequestSchema.parse(request.body);
    if (body.install_id !== installId) {
      throw new AppError(403, "install_mismatch", "Install id mismatch");
    }
    if (body.package_name !== config.googlePlayPackageName) {
      throw new AppError(400, "package_mismatch", "Unexpected package name");
    }
    validateBillingIds(config, body.product_id, body.base_plan_id ?? null);

    const verified = await billingVerifier.verifySubscription({
      productId: body.product_id,
      basePlanId: body.base_plan_id ?? null,
      purchaseToken: body.purchase_token,
      packageName: body.package_name,
    });
    const normalized = {
      ...verified,
      purchaseTokenHash: sha256(body.purchase_token),
    };

    await store.upsertEntitlement({
      installId,
      isPremium: normalized.isPremium,
      productId: normalized.productId,
      planId: normalized.planId,
      billingProvider: normalized.billingProvider,
      status: normalized.status,
      validUntil: normalized.validUntil,
      autoRenewing: normalized.autoRenewing,
      lastVerifiedAt: normalized.lastVerifiedAt,
      purchaseTokenHash: normalized.purchaseTokenHash,
      originalExternalId: normalized.originalExternalId,
      features: normalized.features,
    });
    await store.savePurchaseHistory({
      recordId: makeId(),
      installId,
      productId: normalized.productId ?? body.product_id,
      planId: normalized.planId,
      billingProvider: normalized.billingProvider,
      status: normalized.status,
      purchaseTokenHash: normalized.purchaseTokenHash,
      originalExternalId: normalized.originalExternalId,
      validUntil: normalized.validUntil,
      autoRenewing: normalized.autoRenewing,
      payload: normalized.rawProviderPayload,
    });
    await store.saveAuditEvent({
      installId,
      eventType: "billing.verify.completed",
      payload: {
        productId: normalized.productId,
        planId: normalized.planId,
        status: normalized.status,
      },
    });

    return reply.send(
      entitlementResponseSchema.parse({
        entitlement: serializeEntitlement({
          installId,
          isPremium: normalized.isPremium,
          productId: normalized.productId,
          planId: normalized.planId,
          billingProvider: normalized.billingProvider,
          status: normalized.status,
          validUntil: normalized.validUntil,
          autoRenewing: normalized.autoRenewing,
          lastVerifiedAt: normalized.lastVerifiedAt,
          purchaseTokenHash: normalized.purchaseTokenHash,
          originalExternalId: normalized.originalExternalId,
          features: normalized.features,
        }),
      }),
    );
  });

  app.post("/v1/billing/google-play/restore", async (request, reply) => {
    const installId = await requireInstallId(request, config);
    await enforceRateLimit({
      rateLimiter,
      store,
      key: `billing:restore:install:${installId}`,
      limit: config.rateLimits.billingRestorePerMinute,
      windowSeconds: 60,
      eventKey: "billing_restore",
      installId,
      ipAddress: request.ip,
    });
    const body = billingRestoreRequestSchema.parse(request.body);
    if (body.install_id !== installId) {
      throw new AppError(403, "install_mismatch", "Install id mismatch");
    }
    if (body.package_name !== config.googlePlayPackageName) {
      throw new AppError(400, "package_mismatch", "Unexpected package name");
    }
    for (const purchase of body.purchases) {
      validateBillingIds(
        config,
        purchase.product_id,
        purchase.base_plan_id ?? null,
      );
    }

    let bestEntitlement = freeEntitlementRecord(installId);
    for (const purchase of body.purchases) {
      const verified = await billingVerifier.verifySubscription({
        productId: purchase.product_id,
        basePlanId: purchase.base_plan_id ?? null,
        purchaseToken: purchase.purchase_token,
        packageName: body.package_name,
      });
      const normalized = {
        ...verified,
        purchaseTokenHash: sha256(purchase.purchase_token),
      };
      const nextEntitlement = {
        installId,
        isPremium: normalized.isPremium,
        productId: normalized.productId,
        planId: normalized.planId,
        billingProvider: normalized.billingProvider,
        status: normalized.status,
        validUntil: normalized.validUntil,
        autoRenewing: normalized.autoRenewing,
        lastVerifiedAt: normalized.lastVerifiedAt,
        purchaseTokenHash: normalized.purchaseTokenHash,
        originalExternalId: normalized.originalExternalId,
        features: normalized.features,
      };
      await store.savePurchaseHistory({
        recordId: makeId(),
        installId,
        productId: normalized.productId ?? purchase.product_id,
        planId: normalized.planId,
        billingProvider: normalized.billingProvider,
        status: normalized.status,
        purchaseTokenHash: normalized.purchaseTokenHash,
        originalExternalId: normalized.originalExternalId,
        validUntil: normalized.validUntil,
        autoRenewing: normalized.autoRenewing,
        payload: normalized.rawProviderPayload,
      });
      if (shouldReplaceEntitlement(bestEntitlement, nextEntitlement)) {
        bestEntitlement = nextEntitlement;
      }
    }

    const normalizedBestEntitlement = normalizeEntitlementRecord(bestEntitlement);
    await store.upsertEntitlement(normalizedBestEntitlement);

    return reply.send(
      entitlementResponseSchema.parse({
        entitlement: serializeEntitlement(normalizedBestEntitlement),
      }),
    );
  });

  const handleExtraction = async (
    request: FastifyRequest,
    reply: FastifyReply,
  ) => {
    const installId = await requireInstallId(request, config);
    const body = extractionRequestSchema.parse(request.body);
    if (body.install_id !== installId) {
      throw new AppError(403, "install_mismatch", "Install id mismatch");
    }

    await enforceRateLimit({
      rateLimiter,
      store,
      key: `extract:install:${installId}`,
      limit: config.rateLimits.extractionInstallPerMinute,
      windowSeconds: 60,
      eventKey: "extract_install",
      installId,
      ipAddress: request.ip,
    });
    await enforceRateLimit({
      rateLimiter,
      store,
      key: `extract:ip:${request.ip}`,
      limit: config.rateLimits.extractionIpPerMinute,
      windowSeconds: 60,
      eventKey: "extract_ip",
      installId,
      ipAddress: request.ip,
    });

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
        "quota_exhausted",
        "No cloud extraction quota remaining",
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
        eventType: "extraction.provider.failed",
        payload: {
          message: error instanceof Error ? error.message : "unknown",
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
        status: "success",
        latencyMs: durationMs,
        ocrHash: sha256(body.normalized_ocr_text),
        ocrPreview: redactTextPreview(body.normalized_ocr_text),
        warnings: normalized.warnings,
      });

      await store.saveAuditEvent({
        installId,
        requestId: body.request_id,
        eventType: "extraction.completed",
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
        summary: normalized.summary,
        line_items: normalized.lineItems,
        document_signals: normalized.documentSignals,
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
  };

  app.post("/v1/import/extract", handleExtraction);
  app.post("/v1/ai/extractions", async (request, reply) => {
    reply.header("Deprecation", extractionAliasDeprecatedAt);
    reply.header("Sunset", extractionAliasSunsetAt);
    return handleExtraction(request, reply);
  });

  return app;
}

function validateBillingIds(
  config: AppConfig,
  productId: string,
  basePlanId: string | null,
) {
  if (productId !== config.premiumProductId) {
    throw new AppError(
      400,
      "billing_product_mismatch",
      "Unexpected Google Play product id.",
    );
  }
  if (
    basePlanId != null &&
    basePlanId !== config.premiumMonthlyBasePlanId &&
    basePlanId !== config.premiumYearlyBasePlanId
  ) {
    throw new AppError(
      400,
      "billing_plan_mismatch",
      "Unexpected Google Play base plan id.",
    );
  }
}

async function requireInstallId(
  request: Parameters<FastifyInstance["route"]>[0]["handler"] extends (
    ...args: infer T
  ) => unknown
    ? T[0]
    : never,
  config: AppConfig,
) {
  const authHeader = request.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    throw new AppError(401, "missing_auth", "Bearer token required");
  }
  const token = authHeader.slice("Bearer ".length);
  try {
    const payload = jwt.verify(
      token,
      config.jwtAccessSecret,
      {
        issuer: config.jwtIssuer,
        audience: config.jwtAudience,
      },
    ) as AccessTokenPayload;
    const subject = (payload as { sub?: unknown }).sub;
    if (
      payload.type !== "access" ||
      typeof payload.installId !== "string" ||
      payload.installId.length === 0 ||
      typeof subject !== "string" ||
      subject.length === 0 ||
      subject !== payload.installId
    ) {
      throw new AppError(401, "invalid_auth", "Invalid token type");
    }
    return payload.installId;
  } catch (_) {
    throw new AppError(401, "invalid_auth", "Access token invalid or expired");
  }
}

function signAccessToken(config: AppConfig, installId: string) {
  return jwt.sign(
    {
      installId,
      type: "access",
    } satisfies AccessTokenPayload,
    config.jwtAccessSecret,
    {
      expiresIn: config.accessTokenTtlSeconds,
      issuer: config.jwtIssuer,
      audience: config.jwtAudience,
      subject: installId,
    },
  );
}

async function enforceRateLimit(input: {
  rateLimiter: RateLimiter;
  store: AppStore;
  key: string;
  limit: number;
  windowSeconds: number;
  eventKey: string;
  installId?: string;
  ipAddress?: string;
}) {
  const result = await input.rateLimiter.consume(
    input.key,
    input.limit,
    input.windowSeconds,
  );
  await input.store.saveRateLimitEvent({
    installId: input.installId,
    ipAddress: input.ipAddress,
    key: input.eventKey,
    limitValue: input.limit,
    remaining: result.remaining,
    resetAt: result.resetAt,
  });
  if (!result.allowed) {
    throw new AppError(
      429,
      "rate_limited",
      "Too many requests. Please try again later.",
      { retry_at: result.resetAt.toISOString() },
    );
  }
  return result;
}

async function buildReadinessChecks(
  config: AppConfig,
  store: AppStore,
  rateLimiter: RateLimiter,
) {
  const [postgresOk, redisOk] = await Promise.all([
    store.checkHealth(1200),
    rateLimiter.checkHealth?.(1200) ?? Promise.resolve(true),
  ]);
  const checks: Record<string, "ok" | "failed"> = {
    postgres: postgresOk ? "ok" : "failed",
    redis: redisOk ? "ok" : "failed",
    gemini: config.geminiApiKey && config.geminiModel ? "ok" : "failed",
  };
  if (config.environment === "production" || config.environment === "staging") {
    checks.google_play_credentials = config.googlePlayServiceAccountJson
      ? "ok"
      : "failed";
  }
  return checks;
}

function withRuntimeDefaults(config: AppConfig): AppConfig {
  return {
    ...config,
    host: config.host ?? "0.0.0.0",
    logLevel:
      config.logLevel ?? (config.environment === "production" ? "info" : "debug"),
    trustProxy: config.trustProxy ?? false,
    postgresPool: config.postgresPool ?? {
      max: 10,
      min: 0,
      idleTimeoutMs: 30_000,
      connectionTimeoutMs: 10_000,
      maxLifetimeSeconds: 300,
    },
    jwtIssuer: config.jwtIssuer ?? "debt-destroyer-backend",
    jwtAudience: config.jwtAudience ?? "debt-destroyer-mobile",
    geminiApiVersion: config.geminiApiVersion ?? "v1beta",
    rateLimits: config.rateLimits ?? {
      bootstrapChallengePerMinute: 20,
      bootstrapVerifyPerMinute: 20,
      tokenRefreshPerMinute: 20,
      billingVerifyPerMinute: 20,
      billingRestorePerMinute: 10,
      extractionInstallPerMinute: 20,
      extractionIpPerMinute: 60,
    },
    enableCleanupJobs: config.enableCleanupJobs ?? false,
    cleanupIntervalMinutes: config.cleanupIntervalMinutes ?? 60,
  };
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
  const usage = await store.getUsageSnapshot(
    installId,
    monthKeyFor(new Date()),
  );
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

function serializeEntitlement(entitlement: EntitlementRecord) {
  return {
    is_premium: entitlement.isPremium,
    product_id: entitlement.productId,
    plan_id: entitlement.planId,
    billing_provider: entitlement.billingProvider,
    status: entitlement.status,
    valid_until: entitlement.validUntil?.toISOString() ?? null,
    auto_renewing: entitlement.autoRenewing,
    last_verified_at: entitlement.lastVerifiedAt?.toISOString() ?? null,
    original_external_id: entitlement.originalExternalId,
    features: entitlement.features,
  };
}

function shouldReplaceEntitlement(
  current: EntitlementRecord,
  candidate: EntitlementRecord,
) {
  if (candidate.isPremium && !current.isPremium) {
    return true;
  }
  if (!candidate.isPremium && current.isPremium) {
    return false;
  }
  if (current.status === 'free' && candidate.status !== 'free') {
    return true;
  }
  return (candidate.validUntil?.getTime() ?? 0) > (current.validUntil?.getTime() ?? 0);
}
