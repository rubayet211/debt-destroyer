import { afterAll, beforeAll, describe, expect, test } from 'vitest';
import { createApp } from '../src/app.js';
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
        },
        store,
        rateLimiter: new MemoryRateLimiter(),
    });
    let app;
    beforeAll(async () => {
        app = await appPromise;
    });
    afterAll(async () => {
        await app.close();
    });
    test('issues access and refresh tokens after debug attestation', async () => {
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
                attestation_token: `debug-attestation:install-1:${challengeBody.nonce}`,
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
});
