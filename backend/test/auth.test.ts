import { afterAll, beforeAll, describe, expect, test } from 'vitest';

import { createApp } from '../src/app.js';
import { buildDebugAttestationToken } from '../src/services/attestation.js';
import { MemoryRateLimiter } from '../src/services/rate-limit.js';
import { MemoryAppStore } from '../src/services/storage.js';

describe('mobile bootstrap auth flow', () => {
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
    },
    store,
    rateLimiter: new MemoryRateLimiter(),
  });

  let app: Awaited<typeof appPromise>;

  beforeAll(async () => {
    app = await appPromise;
  });

  afterAll(async () => {
    await app.close();
  });

  test('issues access and refresh tokens after explicit debug attestation', async () => {
    const challenge = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/challenge',
      payload: {
        app_version: '1.0.0+1',
        platform: 'android',
        install_id: 'install-1',
      },
    });

    expect(challenge.statusCode).toBe(200);
    const challengeBody = challenge.json();

    const verify = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/verify',
      payload: {
        challenge_id: challengeBody.challenge_id,
        install_id: 'install-1',
        attestation_token: buildDebugAttestationToken({
          secret: 'debug-secret',
          installId: 'install-1',
          nonce: challengeBody.nonce,
        }),
        device: {
          platform: 'android',
          app_version: '1.0.0+1',
          build_mode: 'debug',
        },
      },
    });

    expect(verify.statusCode).toBe(200);
    expect(verify.json().access_token).toBeTruthy();
    expect(verify.json().refresh_token).toBeTruthy();
  });

  test('rejects deterministic legacy debug attestation tokens', async () => {
    const challenge = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/challenge',
      payload: {
        app_version: '1.0.0+1',
        platform: 'android',
        install_id: 'install-legacy',
      },
    });
    const challengeBody = challenge.json();

    const verify = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/verify',
      payload: {
        challenge_id: challengeBody.challenge_id,
        install_id: 'install-legacy',
        attestation_token: `debug-attestation:install-legacy:${challengeBody.nonce}`,
        device: {
          platform: 'android',
          app_version: '1.0.0+1',
          build_mode: 'debug',
        },
      },
    });

    expect(verify.statusCode).toBe(401);
    expect(verify.json().error).toBe('attestation_failed');
  });

  test('consumes each challenge only once under concurrent verify requests', async () => {
    const challenge = await app.inject({
      method: 'POST',
      url: '/v1/mobile/bootstrap/challenge',
      payload: {
        app_version: '1.0.0+1',
        platform: 'android',
        install_id: 'install-race',
      },
    });
    const challengeBody = challenge.json();
    const payload = {
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
    };

    const [first, second] = await Promise.all([
      app.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/verify',
        payload,
      }),
      app.inject({
        method: 'POST',
        url: '/v1/mobile/bootstrap/verify',
        payload,
      }),
    ]);

    const statuses = [first.statusCode, second.statusCode].sort();
    expect(statuses).toEqual([200, 400]);
    const failed = [first, second].find((response) => response.statusCode === 400);
    expect(failed?.json().error).toBe('challenge_consumed');
  });
});
