import { fileURLToPath } from 'node:url';

import { afterEach, describe, expect, test } from 'vitest';

import { loadConfig } from '../src/config.js';
import { readSchemaSql } from '../src/services/storage.js';

const originalEnv = { ...process.env };
const originalCwd = process.cwd();

afterEach(() => {
  process.env = { ...originalEnv };
  process.chdir(originalCwd);
});

describe('backend config validation', () => {
  function setRequiredProductionEnv() {
    process.env.POSTGRES_URL =
      'postgres://postgres:postgres@localhost:5432/debt_destroyer';
    process.env.REDIS_URL = 'redis://localhost:6379';
    process.env.GEMINI_API_KEY = 'gemini-key';
    process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON =
      '{"type":"service_account","project_id":"test"}';
    process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER = '123456789';
    delete process.env.ALLOW_DEBUG_ATTESTATION;
    delete process.env.DEBUG_ATTESTATION_SECRET;
  }

  test('rejects default JWT secrets in production', () => {
    process.env.NODE_ENV = 'production';
    setRequiredProductionEnv();
    delete process.env.JWT_ACCESS_SECRET;
    delete process.env.JWT_REFRESH_SECRET;
    delete process.env.JWT_SECRET;

    expect(() => loadConfig()).toThrow(/JWT_ACCESS_SECRET/);
  });

  test('rejects debug attestation outside local environments', () => {
    process.env.NODE_ENV = 'staging';
    process.env.JWT_ACCESS_SECRET = 'staging-access-secret';
    process.env.JWT_REFRESH_SECRET = 'staging-refresh-secret';
    process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER = '123456789';
    process.env.ALLOW_DEBUG_ATTESTATION = 'true';
    process.env.DEBUG_ATTESTATION_SECRET = 'debug-secret';

    expect(() => loadConfig()).toThrow(/ALLOW_DEBUG_ATTESTATION/);
  });

  test('requires debug secret when debug attestation is enabled', () => {
    process.env.NODE_ENV = 'development';
    process.env.ALLOW_DEBUG_ATTESTATION = 'true';
    delete process.env.DEBUG_ATTESTATION_SECRET;

    expect(() => loadConfig()).toThrow(/DEBUG_ATTESTATION_SECRET/);
  });

  test('requires play integrity project number outside local environments', () => {
    process.env.NODE_ENV = 'production';
    process.env.POSTGRES_URL =
      'postgres://postgres:postgres@localhost:5432/debt_destroyer';
    process.env.REDIS_URL = 'redis://localhost:6379';
    process.env.GEMINI_API_KEY = 'gemini-key';
    process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON =
      '{"type":"service_account","project_id":"test"}';
    process.env.JWT_ACCESS_SECRET = 'prod-access-secret';
    process.env.JWT_REFRESH_SECRET = 'prod-refresh-secret';
    delete process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER;

    expect(() => loadConfig()).toThrow(/PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER/);
  });

  test('requires postgres url outside local environments', () => {
    process.env.NODE_ENV = 'production';
    process.env.JWT_SECRET = 'prod-shared-secret';
    process.env.REDIS_URL = 'redis://localhost:6379';
    process.env.GEMINI_API_KEY = 'gemini-key';
    process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON =
      '{"type":"service_account","project_id":"test"}';
    process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER = '123456789';
    delete process.env.POSTGRES_URL;

    expect(() => loadConfig()).toThrow(/POSTGRES_URL/);
  });

  test('requires redis url outside local environments', () => {
    process.env.NODE_ENV = 'production';
    process.env.JWT_SECRET = 'prod-shared-secret';
    process.env.POSTGRES_URL =
      'postgres://postgres:postgres@localhost:5432/debt_destroyer';
    process.env.GEMINI_API_KEY = 'gemini-key';
    process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON =
      '{"type":"service_account","project_id":"test"}';
    process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER = '123456789';
    delete process.env.REDIS_URL;

    expect(() => loadConfig()).toThrow(/REDIS_URL/);
  });

  test('requires gemini api key outside local environments', () => {
    process.env.NODE_ENV = 'production';
    process.env.JWT_SECRET = 'prod-shared-secret';
    process.env.POSTGRES_URL =
      'postgres://postgres:postgres@localhost:5432/debt_destroyer';
    process.env.REDIS_URL = 'redis://localhost:6379';
    process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON =
      '{"type":"service_account","project_id":"test"}';
    process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER = '123456789';
    delete process.env.GEMINI_API_KEY;

    expect(() => loadConfig()).toThrow(/GEMINI_API_KEY/);
  });

  test('loads pg pool settings for Render-friendly defaults and overrides', () => {
    process.env.NODE_ENV = 'production';
    setRequiredProductionEnv();
    process.env.JWT_ACCESS_SECRET = 'prod-access-secret';
    process.env.JWT_REFRESH_SECRET = 'prod-refresh-secret';
    process.env.POSTGRES_POOL_MAX = '12';
    process.env.POSTGRES_POOL_MIN = '1';
    process.env.POSTGRES_IDLE_TIMEOUT_MS = '45000';
    process.env.POSTGRES_CONNECTION_TIMEOUT_MS = '8000';
    process.env.POSTGRES_MAX_LIFETIME_SECONDS = '600';

    const config = loadConfig();

    expect(config.postgresPool).toEqual({
      max: 12,
      min: 1,
      idleTimeoutMs: 45000,
      connectionTimeoutMs: 8000,
      maxLifetimeSeconds: 600,
    });
  });
});

describe('schema loading', () => {
  test('reads init sql relative to the backend module', async () => {
    process.chdir(fileURLToPath(new URL('..', import.meta.url)));

    const sql = await readSchemaSql();

    expect(sql).toContain('create table if not exists install_sessions');
    expect(sql).toContain('create table if not exists quota_reservations');
  });
});
