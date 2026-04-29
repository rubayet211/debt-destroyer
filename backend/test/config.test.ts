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
  test('rejects default JWT secrets in production', () => {
    process.env.NODE_ENV = 'production';
    process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER = '123456789';
    delete process.env.JWT_ACCESS_SECRET;
    delete process.env.JWT_REFRESH_SECRET;

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
    process.env.JWT_ACCESS_SECRET = 'prod-access-secret';
    process.env.JWT_REFRESH_SECRET = 'prod-refresh-secret';
    delete process.env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER;

    expect(() => loadConfig()).toThrow(/PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER/);
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
