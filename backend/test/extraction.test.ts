import { afterAll, beforeAll, describe, expect, test } from 'vitest';

import { createApp } from '../src/app.js';
import { buildDebugAttestationToken } from '../src/services/attestation.js';
import type { AiProvider } from '../src/services/provider.js';
import { MemoryRateLimiter } from '../src/services/rate-limit.js';
import { MemoryAppStore } from '../src/services/storage.js';

class FakeProvider implements AiProvider {
  readonly providerName = 'fake';
  readonly modelName = 'fake-model';

  async extract() {
    return {
      issuer_name: 'Acme Bank',
      title: 'Acme Statement',
      debt_type: 'credit card',
      current_balance: 1240.55,
      original_balance: 1600,
      apr_percentage: 19.9,
      minimum_payment: 75,
      due_date: '2026-03-15',
      payment_date: null,
      payment_amount: null,
      currency: 'usd',
      notes: 'Validated by test',
      confidence: 0.92,
      last4: '1234',
      raw_detected_labels: ['statement'],
    };
  }
}

class SlowProvider implements AiProvider {
  readonly providerName = 'slow';
  readonly modelName = 'slow-model';

  async extract() {
    await new Promise((resolve) => setTimeout(resolve, 40));
    return {
      issuer_name: 'Slow Bank',
      title: 'Slow Statement',
      debt_type: 'credit card',
      current_balance: 88,
      original_balance: 100,
      apr_percentage: 10,
      minimum_payment: 10,
      due_date: null,
      payment_date: null,
      payment_amount: null,
      currency: 'usd',
      notes: null,
      confidence: 0.8,
      last4: null,
      raw_detected_labels: [],
    };
  }
}

class FailingProvider implements AiProvider {
  readonly providerName = 'failing';
  readonly modelName = 'failing-model';

  async extract() {
    throw new Error('provider failed');
  }
}

describe('extraction endpoint', () => {
  const store = new MemoryAppStore();
  const appPromise = createApp({
    config: {
      environment: 'test',
      port: 0,
      postgresUrl: undefined,
      redisUrl: undefined,
      jwtAccessSecret: 'test-access-secret',
      jwtRefreshSecret: 'test-refresh-secret',
      geminiApiKey: undefined,
      geminiModel: 'gemini-2.0-flash',
      freeScanLimit: 1,
      accessTokenTtlSeconds: 900,
      refreshTokenTtlDays: 30,
      requestTimeoutMs: 15000,
      allowDebugAttestation: true,
      debugAttestationSecret: 'debug-secret',
    },
    store,
    rateLimiter: new MemoryRateLimiter(),
    provider: new FakeProvider(),
  });

  let app: Awaited<typeof appPromise>;

  beforeAll(async () => {
    app = await appPromise;
  });

  afterAll(async () => {
    await app.close();
  });

  async function bootstrap(installId: string) {
    const challenge = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/challenge',
      payload: {
        app_version: '1.0.0+1',
        platform: 'android',
        install_id: installId,
      },
    });
    const body = challenge.json();
    const verify = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/verify',
      payload: {
        challenge_id: body.challenge_id,
        install_id: installId,
        attestation_token: buildDebugAttestationToken({
          secret: 'debug-secret',
          installId,
          nonce: body.nonce,
        }),
        device: {
          platform: 'android',
          app_version: '1.0.0+1',
          build_mode: 'debug',
        },
      },
    });
    return verify.json().access_token as string;
  }

  test('returns normalized extraction payload', async () => {
    const accessToken = await bootstrap('install-2');
    const response = await app.inject({
      method: 'POST',
      url: '/v1/ai/extractions',
      headers: {
        authorization: `Bearer ${accessToken}`,
      },
      payload: {
        request_id: 'req-1',
        install_id: 'install-2',
        document_classification: 'creditCardStatement',
        normalized_ocr_text:
          'Acme Bank\nCurrent balance: $1,240.55\nMinimum payment: $75',
        source_type: 'gallery',
        app_version: '1.0.0+1',
        consented_at: new Date().toISOString(),
      },
    });

    expect(response.statusCode).toBe(200);
    expect(response.json().extraction.currency).toBe('USD');
    expect(response.json().quota.remaining_free_scans).toBe(0);
  });

  test('returns quota denial before provider call when exhausted', async () => {
    const accessToken = await bootstrap('install-2');
    const response = await app.inject({
      method: 'POST',
      url: '/v1/ai/extractions',
      headers: {
        authorization: `Bearer ${accessToken}`,
      },
      payload: {
        request_id: 'req-2',
        install_id: 'install-2',
        document_classification: 'creditCardStatement',
        normalized_ocr_text: 'Another OCR body',
        source_type: 'gallery',
        app_version: '1.0.0+1',
        consented_at: new Date().toISOString(),
      },
    });

    expect(response.statusCode).toBe(429);
    expect(response.json().error).toBe('quota_exhausted');
  });

  test('enforces quota atomically for concurrent requests', async () => {
    const concurrentApp = await createApp({
      config: {
        environment: 'test',
        port: 0,
        postgresUrl: undefined,
        redisUrl: undefined,
        jwtAccessSecret: 'test-access-secret',
        jwtRefreshSecret: 'test-refresh-secret',
        geminiApiKey: undefined,
        geminiModel: 'gemini-2.0-flash',
        freeScanLimit: 1,
        accessTokenTtlSeconds: 900,
        refreshTokenTtlDays: 30,
        requestTimeoutMs: 15000,
        allowDebugAttestation: true,
        debugAttestationSecret: 'debug-secret',
      },
      store: new MemoryAppStore(),
      rateLimiter: new MemoryRateLimiter(),
      provider: new SlowProvider(),
    });
    try {
      const challenge = await concurrentApp.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/challenge',
        payload: {
          app_version: '1.0.0+1',
          platform: 'android',
          install_id: 'install-race',
        },
      });
      const challengeBody = challenge.json();
      const verify = await concurrentApp.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/verify',
        payload: {
          challenge_id: challengeBody.challenge_id,
          install_id: 'install-race',
          attestation_token: buildDebugAttestationToken({
            secret: 'debug-secret',
            installId: 'install-race',
            nonce: challengeBody.nonce,
          }),
          device: {
            platform: 'android',
            app_version: '1.0.0+1',
            build_mode: 'debug',
          },
        },
      });
      const accessToken = verify.json().access_token as string;
      const payload = {
        document_classification: 'creditCardStatement',
        normalized_ocr_text: 'Concurrent OCR body',
        source_type: 'gallery',
        app_version: '1.0.0+1',
        consented_at: new Date().toISOString(),
      };

      const [first, second] = await Promise.all([
        concurrentApp.inject({
          method: 'POST',
          url: '/v1/ai/extractions',
          headers: { authorization: `Bearer ${accessToken}` },
          payload: {
            request_id: 'req-race-1',
            install_id: 'install-race',
            ...payload,
          },
        }),
        concurrentApp.inject({
          method: 'POST',
          url: '/v1/ai/extractions',
          headers: { authorization: `Bearer ${accessToken}` },
          payload: {
            request_id: 'req-race-2',
            install_id: 'install-race',
            ...payload,
          },
        }),
      ]);

      const statuses = [first.statusCode, second.statusCode].sort();
      expect(statuses).toEqual([200, 429]);
    } finally {
      await concurrentApp.close();
    }
  });

  test('releases reserved quota after provider failure', async () => {
    const failingApp = await createApp({
      config: {
        environment: 'test',
        port: 0,
        postgresUrl: undefined,
        redisUrl: undefined,
        jwtAccessSecret: 'test-access-secret',
        jwtRefreshSecret: 'test-refresh-secret',
        geminiApiKey: undefined,
        geminiModel: 'gemini-2.0-flash',
        freeScanLimit: 1,
        accessTokenTtlSeconds: 900,
        refreshTokenTtlDays: 30,
        requestTimeoutMs: 15000,
        allowDebugAttestation: true,
        debugAttestationSecret: 'debug-secret',
      },
      store: new MemoryAppStore(),
      rateLimiter: new MemoryRateLimiter(),
      provider: new FailingProvider(),
    });
    try {
      const challenge = await failingApp.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/challenge',
        payload: {
          app_version: '1.0.0+1',
          platform: 'android',
          install_id: 'install-fail',
        },
      });
      const challengeBody = challenge.json();
      const verify = await failingApp.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/verify',
        payload: {
          challenge_id: challengeBody.challenge_id,
          install_id: 'install-fail',
          attestation_token: buildDebugAttestationToken({
            secret: 'debug-secret',
            installId: 'install-fail',
            nonce: challengeBody.nonce,
          }),
          device: {
            platform: 'android',
            app_version: '1.0.0+1',
            build_mode: 'debug',
          },
        },
      });
      const accessToken = verify.json().access_token as string;
      const first = await failingApp.inject({
        method: 'POST',
        url: '/v1/ai/extractions',
        headers: { authorization: `Bearer ${accessToken}` },
        payload: {
          request_id: 'req-fail-1',
          install_id: 'install-fail',
          document_classification: 'creditCardStatement',
          normalized_ocr_text: 'Failure OCR body',
          source_type: 'gallery',
          app_version: '1.0.0+1',
          consented_at: new Date().toISOString(),
        },
      });
      expect(first.statusCode).toBe(500);

      const capabilities = await failingApp.inject({
        method: 'GET',
        url: '/v1/mobile/me/capabilities',
        headers: { authorization: `Bearer ${accessToken}` },
      });
      expect(capabilities.statusCode).toBe(200);
      expect(capabilities.json().free_scan_remaining).toBe(1);
    } finally {
      await failingApp.close();
    }
  });
});
