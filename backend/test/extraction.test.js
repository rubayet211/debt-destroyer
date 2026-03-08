import { afterAll, beforeAll, describe, expect, test } from 'vitest';
import { createApp } from '../src/app.js';
import { MemoryRateLimiter } from '../src/services/rate-limit.js';
import { MemoryAppStore } from '../src/services/storage.js';
class FakeProvider {
    providerName = 'fake';
    modelName = 'fake-model';
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
        },
        store,
        rateLimiter: new MemoryRateLimiter(),
        provider: new FakeProvider(),
    });
    let app;
    beforeAll(async () => {
        app = await appPromise;
    });
    afterAll(async () => {
        await app.close();
    });
    async function bootstrap() {
        const challenge = await app.inject({
            method: 'POST',
            url: '/v1/mobile/bootstrap/challenge',
            payload: {
                app_version: '1.0.0+1',
                platform: 'android',
                install_id: 'install-2',
            },
        });
        const body = challenge.json();
        const verify = await app.inject({
            method: 'POST',
            url: '/v1/mobile/bootstrap/verify',
            payload: {
                challenge_id: body.challenge_id,
                install_id: 'install-2',
                attestation_token: `debug-attestation:install-2:${body.nonce}`,
                device: {
                    platform: 'android',
                    app_version: '1.0.0+1',
                    build_mode: 'debug',
                },
            },
        });
        return verify.json().access_token;
    }
    test('returns normalized extraction payload', async () => {
        const accessToken = await bootstrap();
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
                normalized_ocr_text: 'Acme Bank\nCurrent balance: $1,240.55\nMinimum payment: $75',
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
        const accessToken = await bootstrap();
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
});
