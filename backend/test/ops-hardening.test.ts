import { afterAll, beforeAll, describe, expect, test } from 'vitest';

import { createApp } from '../src/app.js';
import { MemoryRateLimiter } from '../src/services/rate-limit.js';
import { MemoryAppStore } from '../src/services/storage.js';

const baseConfig = {
  environment: 'test' as const,
  host: '0.0.0.0',
  port: 0,
  logLevel: 'debug' as const,
  trustProxy: false,
  postgresUrl: undefined,
  redisUrl: undefined,
  jwtAccessSecret: 'test-access-secret',
  jwtRefreshSecret: 'test-refresh-secret',
  jwtIssuer: 'debt-destroyer-backend',
  jwtAudience: 'debt-destroyer-mobile',
  geminiApiKey: 'gemini-key',
  geminiModel: 'gemini-2.0-flash',
  geminiApiVersion: 'v1beta' as const,
  freeScanLimit: 5,
  accessTokenTtlSeconds: 900,
  refreshTokenTtlDays: 30,
  requestTimeoutMs: 15000,
  allowDebugAttestation: true,
  debugAttestationSecret: 'debug-secret',
  googlePlayPackageName: 'com.debtdestroyer.app',
  googlePlayServiceAccountJson: '{"type":"service_account","project_id":"test"}',
  playIntegrityCloudProjectNumber: '123456789',
  playIntegrityPackageName: 'com.debtdestroyer.app',
  premiumProductId: 'premium',
  premiumMonthlyBasePlanId: 'monthly',
  premiumYearlyBasePlanId: 'yearly',
  rateLimits: {
    bootstrapChallengePerMinute: 20,
    bootstrapVerifyPerMinute: 20,
    tokenRefreshPerMinute: 20,
    billingVerifyPerMinute: 20,
    billingRestorePerMinute: 10,
    extractionInstallPerMinute: 20,
    extractionIpPerMinute: 60,
  },
  enableCleanupJobs: false,
  cleanupIntervalMinutes: 60,
};

describe('production hardening behavior', () => {
  const appPromise = createApp({
    config: baseConfig,
    store: new MemoryAppStore(),
    rateLimiter: new MemoryRateLimiter(),
  });
  let app: Awaited<typeof appPromise>;

  beforeAll(async () => {
    app = await appPromise;
  });

  afterAll(async () => {
    await app.close();
  });

  test('returns structured validation error on invalid payload', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/challenge',
      payload: {
        app_version: '1.0.0+1',
        platform: 'android',
      },
    });

    expect(response.statusCode).toBe(400);
    expect(response.json().error).toBe('validation_error');
    expect(Array.isArray(response.json().issues)).toBe(true);
  });

  test('reports ready state when dependencies are healthy', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health/ready',
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({ status: 'ok' });
  });

  test('reports live state with the Render-friendly payload', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health/live',
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({ status: 'ok' });
  });

  test('returns not_ready when gemini is not configured', async () => {
    const noGeminiApp = await createApp({
      config: {
        ...baseConfig,
        geminiApiKey: undefined,
      },
      store: new MemoryAppStore(),
      rateLimiter: new MemoryRateLimiter(),
    });
    try {
      const response = await noGeminiApp.inject({
        method: 'GET',
        url: '/health/ready',
      });

      expect(response.statusCode).toBe(503);
      expect(response.json()).toEqual({
        status: 'error',
        checks: {
          postgres: 'ok',
          redis: 'ok',
          gemini: 'failed',
        },
      });
    } finally {
      await noGeminiApp.close();
    }
  });

  test('enforces endpoint-specific rate limits for bootstrap challenge', async () => {
    const throttledApp = await createApp({
      config: {
        ...baseConfig,
        rateLimits: {
          ...baseConfig.rateLimits,
          bootstrapChallengePerMinute: 1,
        },
      },
      store: new MemoryAppStore(),
      rateLimiter: new MemoryRateLimiter(),
    });
    try {
      const payload = {
        app_version: '1.0.0+1',
        platform: 'android',
        install_id: 'install-rate-limit',
      };
      const first = await throttledApp.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/challenge',
        payload,
      });
      const second = await throttledApp.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/challenge',
        payload,
      });

      expect(first.statusCode).toBe(200);
      expect(second.statusCode).toBe(429);
      expect(second.json().error).toBe('rate_limited');
    } finally {
      await throttledApp.close();
    }
  });
});
