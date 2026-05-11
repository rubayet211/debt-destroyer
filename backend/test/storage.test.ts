import { describe, expect, test } from 'vitest';

import { buildPostgresPoolConfig } from '../src/services/storage.js';

describe('postgres pool configuration', () => {
  test('builds a pooled Neon-friendly pg config from POSTGRES_URL', () => {
    const config = buildPostgresPoolConfig(
      'postgresql://user:pass@ep-example-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require',
      {
        max: 12,
        min: 0,
        idleTimeoutMs: 30000,
        connectionTimeoutMs: 10000,
        maxLifetimeSeconds: 300,
      },
    );

    expect(config.connectionString).toContain('ep-example-pooler');
    expect(config.max).toBe(12);
    expect(config.min).toBe(0);
    expect(config.idleTimeoutMillis).toBe(30000);
    expect(config.connectionTimeoutMillis).toBe(10000);
    expect(config.maxLifetimeSeconds).toBe(300);
    expect(config.keepAlive).toBe(true);
    expect(config.enableChannelBinding).toBe(true);
    expect(config.allowExitOnIdle).toBe(false);
    expect(config.application_name).toBe('debt-destroyer-backend');
  });

  test('does not force channel binding for plain local postgres urls', () => {
    const config = buildPostgresPoolConfig(
      'postgres://postgres:postgres@localhost:5432/debt_destroyer',
      {
        max: 10,
        min: 0,
        idleTimeoutMs: 30000,
        connectionTimeoutMs: 10000,
        maxLifetimeSeconds: 300,
      },
    );

    expect(config.enableChannelBinding).toBe(false);
  });
});
