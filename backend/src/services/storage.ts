import { readFile } from 'node:fs/promises';
import { join } from 'node:path';

import { Pool } from 'pg';

import { makeId, sha256 } from './crypto.js';

export type ChallengeRecord = {
  challengeId: string;
  installId: string;
  nonce: string;
  expiresAt: Date;
  consumedAt: Date | null;
};

export type InstallRecord = {
  installId: string;
  attestationStatus: string;
  blockedUntil: Date | null;
  lastSeenAt: Date;
};

export type RefreshTokenRecord = {
  tokenId: string;
  installId: string;
  tokenHash: string;
  expiresAt: Date;
  revokedAt: Date | null;
};

export type EntitlementRecord = {
  installId: string;
  isPremium: boolean;
  features: string[];
};

export type ExtractionAuditRecord = {
  requestId: string;
  installId: string;
  classification: string;
  provider: string;
  model: string;
  status: string;
  latencyMs: number;
  ocrHash: string;
  ocrPreview: string | null;
  warnings: string[];
};

export interface AppStore {
  createChallenge(record: ChallengeRecord): Promise<void>;
  getChallenge(challengeId: string): Promise<ChallengeRecord | null>;
  consumeChallenge(challengeId: string): Promise<void>;
  upsertInstall(record: InstallRecord): Promise<void>;
  getInstall(installId: string): Promise<InstallRecord | null>;
  saveRefreshToken(record: RefreshTokenRecord): Promise<void>;
  getRefreshTokenByHash(tokenHash: string): Promise<RefreshTokenRecord | null>;
  revokeRefreshToken(tokenHash: string): Promise<void>;
  getUsageCount(installId: string, monthKey: string): Promise<number>;
  incrementUsageCount(installId: string, monthKey: string): Promise<number>;
  getEntitlement(installId: string): Promise<EntitlementRecord>;
  saveExtractionAudit(record: ExtractionAuditRecord): Promise<void>;
  saveAuditEvent(input: {
    installId?: string;
    requestId?: string;
    eventType: string;
    payload: Record<string, unknown>;
  }): Promise<void>;
  saveRateLimitEvent(input: {
    installId?: string;
    ipAddress?: string;
    key: string;
    limitValue: number;
    remaining: number;
    resetAt: Date;
  }): Promise<void>;
  close?(): Promise<void>;
}

export class MemoryAppStore implements AppStore {
  private readonly challenges = new Map<string, ChallengeRecord>();
  private readonly installs = new Map<string, InstallRecord>();
  private readonly refreshTokens = new Map<string, RefreshTokenRecord>();
  private readonly usage = new Map<string, number>();
  private readonly entitlements = new Map<string, EntitlementRecord>();

  async createChallenge(record: ChallengeRecord) {
    this.challenges.set(record.challengeId, record);
  }

  async getChallenge(challengeId: string) {
    return this.challenges.get(challengeId) ?? null;
  }

  async consumeChallenge(challengeId: string) {
    const challenge = this.challenges.get(challengeId);
    if (challenge) {
      this.challenges.set(challengeId, {
        ...challenge,
        consumedAt: new Date(),
      });
    }
  }

  async upsertInstall(record: InstallRecord) {
    this.installs.set(record.installId, record);
  }

  async getInstall(installId: string) {
    return this.installs.get(installId) ?? null;
  }

  async saveRefreshToken(record: RefreshTokenRecord) {
    this.refreshTokens.set(record.tokenHash, record);
  }

  async getRefreshTokenByHash(tokenHash: string) {
    return this.refreshTokens.get(tokenHash) ?? null;
  }

  async revokeRefreshToken(tokenHash: string) {
    const token = this.refreshTokens.get(tokenHash);
    if (token) {
      this.refreshTokens.set(tokenHash, { ...token, revokedAt: new Date() });
    }
  }

  async getUsageCount(installId: string, monthKey: string) {
    return this.usage.get(`${installId}:${monthKey}`) ?? 0;
  }

  async incrementUsageCount(installId: string, monthKey: string) {
    const key = `${installId}:${monthKey}`;
    const next = (this.usage.get(key) ?? 0) + 1;
    this.usage.set(key, next);
    return next;
  }

  async getEntitlement(installId: string) {
    return (
      this.entitlements.get(installId) ?? {
        installId,
        isPremium: false,
        features: [],
      }
    );
  }

  async saveExtractionAudit(_record: ExtractionAuditRecord) {}

  async saveAuditEvent(_input: {
    installId?: string;
    requestId?: string;
    eventType: string;
    payload: Record<string, unknown>;
  }) {}

  async saveRateLimitEvent(_input: {
    installId?: string;
    ipAddress?: string;
    key: string;
    limitValue: number;
    remaining: number;
    resetAt: Date;
  }) {}
}

export class PostgresAppStore implements AppStore {
  constructor(private readonly pool: Pool) {}

  static async create(connectionString: string) {
    const pool = new Pool({ connectionString });
    const store = new PostgresAppStore(pool);
    await store.ensureSchema();
    return store;
  }

  async ensureSchema() {
    const sql = await readFile(
      join(process.cwd(), 'backend', 'sql', '001_init.sql'),
      'utf8',
    );
    await this.pool.query(sql);
  }

  async createChallenge(record: ChallengeRecord) {
    await this.pool.query(
      `
        insert into attestation_challenges
          (challenge_id, install_id, nonce, expires_at, consumed_at)
        values ($1, $2, $3, $4, $5)
      `,
      [
        record.challengeId,
        record.installId,
        record.nonce,
        record.expiresAt,
        record.consumedAt,
      ],
    );
  }

  async getChallenge(challengeId: string) {
    const result = await this.pool.query(
      `
        select challenge_id, install_id, nonce, expires_at, consumed_at
        from attestation_challenges
        where challenge_id = $1
      `,
      [challengeId],
    );
    const row = result.rows[0];
    return row
      ? {
          challengeId: row.challenge_id,
          installId: row.install_id,
          nonce: row.nonce,
          expiresAt: row.expires_at,
          consumedAt: row.consumed_at,
        }
      : null;
  }

  async consumeChallenge(challengeId: string) {
    await this.pool.query(
      `update attestation_challenges set consumed_at = now() where challenge_id = $1`,
      [challengeId],
    );
  }

  async upsertInstall(record: InstallRecord) {
    await this.pool.query(
      `
        insert into install_sessions
          (install_id, attestation_status, blocked_until, last_seen_at)
        values ($1, $2, $3, $4)
        on conflict (install_id)
        do update set
          attestation_status = excluded.attestation_status,
          blocked_until = excluded.blocked_until,
          last_seen_at = excluded.last_seen_at,
          updated_at = now()
      `,
      [
        record.installId,
        record.attestationStatus,
        record.blockedUntil,
        record.lastSeenAt,
      ],
    );
  }

  async getInstall(installId: string) {
    const result = await this.pool.query(
      `
        select install_id, attestation_status, blocked_until, last_seen_at
        from install_sessions
        where install_id = $1
      `,
      [installId],
    );
    const row = result.rows[0];
    return row
      ? {
          installId: row.install_id,
          attestationStatus: row.attestation_status,
          blockedUntil: row.blocked_until,
          lastSeenAt: row.last_seen_at,
        }
      : null;
  }

  async saveRefreshToken(record: RefreshTokenRecord) {
    await this.pool.query(
      `
        insert into refresh_tokens
          (token_id, install_id, token_hash, expires_at, revoked_at)
        values ($1, $2, $3, $4, $5)
      `,
      [
        record.tokenId,
        record.installId,
        record.tokenHash,
        record.expiresAt,
        record.revokedAt,
      ],
    );
  }

  async getRefreshTokenByHash(tokenHash: string) {
    const result = await this.pool.query(
      `
        select token_id, install_id, token_hash, expires_at, revoked_at
        from refresh_tokens
        where token_hash = $1
      `,
      [tokenHash],
    );
    const row = result.rows[0];
    return row
      ? {
          tokenId: row.token_id,
          installId: row.install_id,
          tokenHash: row.token_hash,
          expiresAt: row.expires_at,
          revokedAt: row.revoked_at,
        }
      : null;
  }

  async revokeRefreshToken(tokenHash: string) {
    await this.pool.query(
      `update refresh_tokens set revoked_at = now() where token_hash = $1`,
      [tokenHash],
    );
  }

  async getUsageCount(installId: string, monthKey: string) {
    const result = await this.pool.query(
      `
        select cloud_extractions
        from usage_counters
        where install_id = $1 and month_key = $2
      `,
      [installId, monthKey],
    );
    return result.rows[0]?.cloud_extractions ?? 0;
  }

  async incrementUsageCount(installId: string, monthKey: string) {
    const result = await this.pool.query(
      `
        insert into usage_counters (install_id, month_key, cloud_extractions)
        values ($1, $2, 1)
        on conflict (install_id, month_key)
        do update set
          cloud_extractions = usage_counters.cloud_extractions + 1,
          updated_at = now()
        returning cloud_extractions
      `,
      [installId, monthKey],
    );
    return result.rows[0].cloud_extractions as number;
  }

  async getEntitlement(installId: string) {
    const result = await this.pool.query(
      `
        select install_id, is_premium, features
        from premium_entitlements
        where install_id = $1
      `,
      [installId],
    );
    const row = result.rows[0];
    return row
      ? {
          installId: row.install_id,
          isPremium: row.is_premium,
          features: row.features,
        }
      : { installId, isPremium: false, features: [] };
  }

  async saveExtractionAudit(record: ExtractionAuditRecord) {
    await this.pool.query(
      `
        insert into extraction_requests
          (request_id, install_id, classification, provider, model, status, latency_ms, ocr_hash, ocr_preview, warnings)
        values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10::jsonb)
      `,
      [
        record.requestId,
        record.installId,
        record.classification,
        record.provider,
        record.model,
        record.status,
        record.latencyMs,
        record.ocrHash,
        record.ocrPreview,
        JSON.stringify(record.warnings),
      ],
    );
  }

  async saveAuditEvent(input: {
    installId?: string;
    requestId?: string;
    eventType: string;
    payload: Record<string, unknown>;
  }) {
    await this.pool.query(
      `
        insert into audit_events
          (event_id, install_id, request_id, event_type, payload)
        values ($1, $2, $3, $4, $5::jsonb)
      `,
      [makeId(), input.installId, input.requestId, input.eventType, input.payload],
    );
  }

  async saveRateLimitEvent(input: {
    installId?: string;
    ipAddress?: string;
    key: string;
    limitValue: number;
    remaining: number;
    resetAt: Date;
  }) {
    await this.pool.query(
      `
        insert into rate_limit_events
          (event_id, install_id, ip_address, key, limit_value, remaining, reset_at)
        values ($1, $2, $3, $4, $5, $6, $7)
      `,
      [
        makeId(),
        input.installId,
        input.ipAddress,
        input.key,
        input.limitValue,
        input.remaining,
        input.resetAt,
      ],
    );
  }

  async close() {
    await this.pool.end();
  }
}

export async function createStore(postgresUrl?: string) {
  if (!postgresUrl) {
    return new MemoryAppStore();
  }
  return PostgresAppStore.create(postgresUrl);
}

export function monthKeyFor(date: Date) {
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(
    2,
    '0',
  )}`;
}

export function hashToken(token: string) {
  return sha256(token);
}
