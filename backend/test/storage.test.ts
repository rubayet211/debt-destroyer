import { describe, expect, test, vi } from 'vitest';

import {
  PostgresAppStore,
  buildPostgresPoolConfig,
} from '../src/services/storage.js';

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

  test('casts cleanup reference time before interval subtraction', async () => {
    const queries: string[] = [];
    const client = {
      query: vi.fn(async (sql: string) => {
        queries.push(sql);
        return { rowCount: 0 };
      }),
      release: vi.fn(),
    };
    const pool = {
      connect: vi.fn(async () => client),
    } as unknown as ConstructorParameters<typeof PostgresAppStore>[0];

    const store = new PostgresAppStore(pool);
    await store.cleanupExpiredData(new Date('2026-05-12T00:00:00.000Z'));

    const staleReservationQuery = queries.find((sql) =>
      sql.includes('delete from quota_reservations'),
    );
    expect(staleReservationQuery).toBeTruthy();
    expect(staleReservationQuery).toContain(
      "coalesce(released_at, committed_at, expires_at) <= $1::timestamptz - interval '30 days'",
    );
  });
});
