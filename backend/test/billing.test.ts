import { afterAll, beforeAll, describe, expect, test } from 'vitest';

import { createApp } from '../src/app.js';
import { buildDebugAttestationToken } from '../src/services/attestation.js';
import type { BillingVerifier } from '../src/services/billing.js';
import { MemoryRateLimiter } from '../src/services/rate-limit.js';
import { MemoryAppStore } from '../src/services/storage.js';

class FakeBillingVerifier implements BillingVerifier {
  async verifySubscription(input: {
    productId: string;
    basePlanId: string | null;
    purchaseToken: string;
    packageName: string;
  }) {
    const now = new Date('2026-03-09T00:00:00.000Z');
    const status =
      input.purchaseToken === 'expired-token' ? 'expired' : 'active';
    return {
      isPremium: status === 'active',
      productId: input.productId,
      planId: input.basePlanId ?? 'yearly',
      billingProvider: 'google_play' as const,
      status,
      validUntil:
        status === 'active' ? new Date('2026-04-09T00:00:00.000Z') : now,
      autoRenewing: status === 'active',
      lastVerifiedAt: now,
      originalExternalId: `order-${input.purchaseToken}`,
      purchaseTokenHash: '',
      features:
        status === 'active'
          ? [
              'unlimitedScans',
              'pdfImport',
              'advancedReports',
              'csvExport',
              'scenarioSaving',
              'advancedStrategyComparison',
              'premiumThemes',
            ]
          : [],
      rawProviderPayload: {
        packageName: input.packageName,
      },
    };
  }
}

describe('billing verification endpoints', () => {
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
      freeScanLimit: 5,
      accessTokenTtlSeconds: 900,
      refreshTokenTtlDays: 30,
      requestTimeoutMs: 15000,
      allowDebugAttestation: true,
      debugAttestationSecret: 'debug-secret',
      googlePlayPackageName: 'com.debtdestroyer.app',
      googlePlayServiceAccountJson: undefined,
    },
    store,
    rateLimiter: new MemoryRateLimiter(),
    billingVerifier: new FakeBillingVerifier(),
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

  test('verifies purchase and persists entitlement in capabilities', async () => {
    const accessToken = await bootstrap('install-billing');
    const verify = await app.inject({
      method: 'POST',
      url: '/v1/billing/google-play/verify',
      headers: { authorization: `Bearer ${accessToken}` },
      payload: {
        install_id: 'install-billing',
        product_id: 'premium',
        base_plan_id: 'yearly',
        purchase_token: 'token-1',
        package_name: 'com.debtdestroyer.app',
        purchase_state: 'purchased',
        purchase_time: '2026-03-09T00:00:00.000Z',
        app_version: '1.0.0+1',
      },
    });

    expect(verify.statusCode).toBe(200);
    expect(verify.json().entitlement.is_premium).toBe(true);
    expect(verify.json().entitlement.plan_id).toBe('yearly');

    const capabilities = await app.inject({
      method: 'GET',
      url: '/v1/mobile/me/capabilities',
      headers: { authorization: `Bearer ${accessToken}` },
    });
    expect(capabilities.statusCode).toBe(200);
    expect(capabilities.json().premium).toBe(true);
    expect(capabilities.json().entitlement.status).toBe('active');
  });

  test('restore persists the same active entitlement it returns', async () => {
    const accessToken = await bootstrap('install-restore');
    const restore = await app.inject({
      method: 'POST',
      url: '/v1/billing/google-play/restore',
      headers: { authorization: `Bearer ${accessToken}` },
      payload: {
        install_id: 'install-restore',
        package_name: 'com.debtdestroyer.app',
        app_version: '1.0.0+1',
        purchases: [
          {
            product_id: 'premium',
            base_plan_id: 'yearly',
            purchase_token: 'token-2',
            purchase_state: 'restored',
            purchase_time: '2026-03-09T00:00:00.000Z',
          },
          {
            product_id: 'premium',
            base_plan_id: 'monthly',
            purchase_token: 'expired-token',
            purchase_state: 'restored',
            purchase_time: '2026-03-01T00:00:00.000Z',
          },
        ],
      },
    });

    expect(restore.statusCode).toBe(200);
    expect(restore.json().entitlement.is_premium).toBe(true);
    expect(restore.json().entitlement.plan_id).toBe('yearly');

    const capabilities = await app.inject({
      method: 'GET',
      url: '/v1/mobile/me/capabilities',
      headers: { authorization: `Bearer ${accessToken}` },
    });
    expect(capabilities.statusCode).toBe(200);
    expect(capabilities.json().premium).toBe(true);
    expect(capabilities.json().entitlement.plan_id).toBe('yearly');
    expect(capabilities.json().entitlement.status).toBe('active');
  });
});
