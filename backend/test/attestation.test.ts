import { describe, expect, test } from 'vitest';

import { ConfigurableAttestationVerifier } from '../src/services/attestation.js';

const baseConfig = {
  environment: 'production' as const,
  port: 0,
  postgresUrl: undefined,
  redisUrl: undefined,
  jwtAccessSecret: 'prod-access-secret',
  jwtRefreshSecret: 'prod-refresh-secret',
  geminiApiKey: undefined,
  geminiModel: 'gemini-2.0-flash',
  freeScanLimit: 5,
  accessTokenTtlSeconds: 900,
  refreshTokenTtlDays: 30,
  requestTimeoutMs: 15000,
  allowDebugAttestation: false,
  debugAttestationSecret: undefined,
  googlePlayPackageName: 'com.debtdestroyer.app',
  googlePlayServiceAccountJson: '{"type":"service_account"}',
  playIntegrityCloudProjectNumber: '123456789',
  playIntegrityPackageName: 'com.debtdestroyer.app',
  premiumProductId: 'premium',
  premiumMonthlyBasePlanId: 'monthly',
  premiumYearlyBasePlanId: 'yearly',
};

describe('ConfigurableAttestationVerifier', () => {
  test('accepts valid production verdict', async () => {
    const verifier = new ConfigurableAttestationVerifier(baseConfig, async () => ({
      tokenPayloadExternal: {
        requestDetails: {
          nonce: 'nonce-1',
          requestPackageName: 'com.debtdestroyer.app',
        },
        appIntegrity: {
          appRecognitionVerdict: 'PLAY_RECOGNIZED',
          packageName: 'com.debtdestroyer.app',
        },
        deviceIntegrity: {
          deviceRecognitionVerdict: ['MEETS_DEVICE_INTEGRITY'],
        },
      },
    }));

    const result = await verifier.verify({
      attestationToken: 'token',
      installId: 'install-1',
      nonce: 'nonce-1',
    });

    expect(result).toEqual({ valid: true, status: 'verified' });
  });

  test('rejects invalid nonce', async () => {
    const verifier = new ConfigurableAttestationVerifier(baseConfig, async () => ({
      tokenPayloadExternal: {
        requestDetails: {
          nonce: 'wrong',
          requestPackageName: 'com.debtdestroyer.app',
        },
        appIntegrity: {
          appRecognitionVerdict: 'PLAY_RECOGNIZED',
        },
        deviceIntegrity: {
          deviceRecognitionVerdict: ['MEETS_DEVICE_INTEGRITY'],
        },
      },
    }));

    const result = await verifier.verify({
      attestationToken: 'token',
      installId: 'install-1',
      nonce: 'nonce-1',
    });

    expect(result.valid).toBe(false);
    expect(result.reason).toContain('nonce');
  });

  test('rejects package mismatch', async () => {
    const verifier = new ConfigurableAttestationVerifier(baseConfig, async () => ({
      tokenPayloadExternal: {
        requestDetails: {
          nonce: 'nonce-1',
          requestPackageName: 'com.other.app',
        },
        appIntegrity: {
          appRecognitionVerdict: 'PLAY_RECOGNIZED',
        },
        deviceIntegrity: {
          deviceRecognitionVerdict: ['MEETS_DEVICE_INTEGRITY'],
        },
      },
    }));

    const result = await verifier.verify({
      attestationToken: 'token',
      installId: 'install-1',
      nonce: 'nonce-1',
    });

    expect(result.valid).toBe(false);
    expect(result.reason).toContain('package');
  });

  test('rejects weak device verdict', async () => {
    const verifier = new ConfigurableAttestationVerifier(baseConfig, async () => ({
      tokenPayloadExternal: {
        requestDetails: {
          nonce: 'nonce-1',
          requestPackageName: 'com.debtdestroyer.app',
        },
        appIntegrity: {
          appRecognitionVerdict: 'PLAY_RECOGNIZED',
        },
        deviceIntegrity: {
          deviceRecognitionVerdict: ['MEETS_BASIC_INTEGRITY'],
        },
      },
    }));

    const result = await verifier.verify({
      attestationToken: 'token',
      installId: 'install-1',
      nonce: 'nonce-1',
    });

    expect(result.valid).toBe(false);
    expect(result.reason).toContain('Device integrity');
  });
});
