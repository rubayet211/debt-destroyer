import { readFile } from 'node:fs/promises';

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

export type UsageSnapshot = {
  cloudExtractions: number;
  reservedExtractions: number;
};

export type QuotaReservationResult = {
  allowed: boolean;
  reservationId: string | null;
  usage: UsageSnapshot;
};

export type EntitlementRecord = {
  installId: string;
  isPremium: boolean;
  productId: string | null;
  planId: string | null;
  billingProvider: string | null;
  status: string;
  validUntil: Date | null;
  autoRenewing: boolean;
  lastVerifiedAt: Date | null;
  purchaseTokenHash: string | null;
  originalExternalId: string | null;
  features: string[];
};

export type PurchaseHistoryRecord = {
  recordId: string;
  installId: string;
  productId: string;
  planId: string | null;
  billingProvider: string;
  status: string;
  purchaseTokenHash: string;
  originalExternalId: string | null;
  validUntil: Date | null;
  autoRenewing: boolean;
  payload: Record<string, unknown>;
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
  consumeChallengeIfUnused(challengeId: string): Promise<boolean>;
  upsertInstall(record: InstallRecord): Promise<void>;
  getInstall(installId: string): Promise<InstallRecord | null>;
  saveRefreshToken(record: RefreshTokenRecord): Promise<void>;
  getRefreshTokenByHash(tokenHash: string): Promise<RefreshTokenRecord | null>;
  revokeRefreshToken(tokenHash: string): Promise<void>;
  getUsageSnapshot(installId: string, monthKey: string): Promise<UsageSnapshot>;
  reserveQuotaSlot(
    installId: string,
    monthKey: string,
    freeScanLimit: number,
    reservationTtlSeconds: number,
  ): Promise<QuotaReservationResult>;
  commitQuotaSlot(reservationId: string): Promise<void>;
  releaseQuotaSlot(reservationId: string): Promise<void>;
  getEntitlement(installId: string): Promise<EntitlementRecord>;
  upsertEntitlement(record: EntitlementRecord): Promise<void>;
  savePurchaseHistory(record: PurchaseHistoryRecord): Promise<void>;
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
  private readonly reservations = new Map<
    string,
    {
      reservationId: string;
      installId: string;
      monthKey: string;
      status: 'reserved' | 'committed' | 'released';
      expiresAt: Date;
    }
  >();

  async createChallenge(record: ChallengeRecord) {
    this.challenges.set(record.challengeId, record);
  }

  async getChallenge(challengeId: string) {
    return this.challenges.get(challengeId) ?? null;
  }

  async consumeChallengeIfUnused(challengeId: string) {
    const challenge = this.challenges.get(challengeId);
    if (!challenge || challenge.consumedAt) {
      return false;
    }
    this.challenges.set(challengeId, {
      ...challenge,
      consumedAt: new Date(),
    });
    return true;
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

  async getUsageSnapshot(installId: string, monthKey: string) {
    this.reclaimExpiredReservations();
    return {
      cloudExtractions: this.usage.get(`${installId}:${monthKey}`) ?? 0,
      reservedExtractions: this.countActiveReservations(installId, monthKey),
    };
  }

  async reserveQuotaSlot(
    installId: string,
    monthKey: string,
    freeScanLimit: number,
    reservationTtlSeconds: number,
  ) {
    this.reclaimExpiredReservations();
    const usage = await this.getUsageSnapshot(installId, monthKey);
    if (usage.cloudExtractions + usage.reservedExtractions >= freeScanLimit) {
      return {
        allowed: false,
        reservationId: null,
        usage,
      };
    }
    const reservationId = makeId();
    this.reservations.set(reservationId, {
      reservationId,
      installId,
      monthKey,
      status: 'reserved',
      expiresAt: new Date(Date.now() + reservationTtlSeconds * 1000),
    });
    return {
      allowed: true,
      reservationId,
      usage: {
        cloudExtractions: usage.cloudExtractions,
        reservedExtractions: usage.reservedExtractions + 1,
      },
    };
  }

  async commitQuotaSlot(reservationId: string) {
    this.reclaimExpiredReservations();
    const reservation = this.reservations.get(reservationId);
    if (!reservation || reservation.status !== 'reserved') {
      return;
    }
    reservation.status = 'committed';
    const key = `${reservation.installId}:${reservation.monthKey}`;
    const next = (this.usage.get(key) ?? 0) + 1;
    this.usage.set(key, next);
  }

  async releaseQuotaSlot(reservationId: string) {
    const reservation = this.reservations.get(reservationId);
    if (!reservation || reservation.status !== 'reserved') {
      return;
    }
    reservation.status = 'released';
  }

  async getEntitlement(installId: string) {
    return (
      this.entitlements.get(installId) ?? {
        installId,
        isPremium: false,
        productId: null,
        planId: null,
        billingProvider: null,
        status: 'free',
        validUntil: null,
        autoRenewing: false,
        lastVerifiedAt: null,
        purchaseTokenHash: null,
        originalExternalId: null,
        features: [],
      }
    );
  }

  async upsertEntitlement(record: EntitlementRecord) {
    this.entitlements.set(record.installId, record);
  }

  async savePurchaseHistory(_record: PurchaseHistoryRecord) {}

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

  private reclaimExpiredReservations() {
    const now = Date.now();
    for (const reservation of this.reservations.values()) {
      if (
        reservation.status === 'reserved' &&
        reservation.expiresAt.getTime() <= now
      ) {
        reservation.status = 'released';
      }
    }
  }

  private countActiveReservations(installId: string, monthKey: string) {
    let count = 0;
    for (const reservation of this.reservations.values()) {
      if (
        reservation.installId === installId &&
        reservation.monthKey === monthKey &&
        reservation.status === 'reserved'
      ) {
        count += 1;
      }
    }
    return count;
  }
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
    const sql = await readSchemaSql();
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

  async consumeChallengeIfUnused(challengeId: string) {
    const result = await this.pool.query(
      `
        update attestation_challenges
        set consumed_at = now()
        where challenge_id = $1 and consumed_at is null
      `,
      [challengeId],
    );
    return result.rowCount === 1;
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

  async getUsageSnapshot(installId: string, monthKey: string) {
    await this.pool.query(
      `
        update quota_reservations
        set status = 'released', released_at = coalesce(released_at, now())
        where install_id = $1
          and month_key = $2
          and status = 'reserved'
          and expires_at <= now()
      `,
      [installId, monthKey],
    );
    const result = await this.pool.query(
      `
        select
          coalesce(counters.cloud_extractions, 0) as cloud_extractions,
          coalesce(active.active_reserved, 0) as reserved_extractions
        from (
          select $1::text as install_id, $2::text as month_key
        ) lookup
        left join usage_counters counters
          on counters.install_id = lookup.install_id
          and counters.month_key = lookup.month_key
        left join (
          select install_id, month_key, count(*)::integer as active_reserved
          from quota_reservations
          where status = 'reserved' and expires_at > now()
          group by install_id, month_key
        ) active
          on active.install_id = lookup.install_id
          and active.month_key = lookup.month_key
      `,
      [installId, monthKey],
    );
    return {
      cloudExtractions: result.rows[0]?.cloud_extractions ?? 0,
      reservedExtractions: result.rows[0]?.reserved_extractions ?? 0,
    };
  }

  async reserveQuotaSlot(
    installId: string,
    monthKey: string,
    freeScanLimit: number,
    reservationTtlSeconds: number,
  ) {
    const client = await this.pool.connect();
    try {
      await client.query('begin');
      await client.query(
        `
          update quota_reservations
          set status = 'released', released_at = now()
          where install_id = $1
            and month_key = $2
            and status = 'reserved'
            and expires_at <= now()
        `,
        [installId, monthKey],
      );
      await client.query(
        `
          insert into usage_counters
            (install_id, month_key, cloud_extractions, reserved_extractions)
          values ($1, $2, 0, 0)
          on conflict (install_id, month_key) do nothing
        `,
        [installId, monthKey],
      );
      const activeReservationsResult = await client.query(
        `
          select count(*)::integer as active_reserved
          from quota_reservations
          where install_id = $1
            and month_key = $2
            and status = 'reserved'
            and expires_at > now()
        `,
        [installId, monthKey],
      );
      const activeReserved = activeReservationsResult.rows[0]?.active_reserved ?? 0;
      await client.query(
        `
          update usage_counters
          set reserved_extractions = $3,
            updated_at = now()
          where install_id = $1 and month_key = $2
        `,
        [installId, monthKey, activeReserved],
      );
      const usageResult = await client.query(
        `
          select cloud_extractions, reserved_extractions
          from usage_counters
          where install_id = $1 and month_key = $2
          for update
        `,
        [installId, monthKey],
      );
      const usage = {
        cloudExtractions: usageResult.rows[0]?.cloud_extractions ?? 0,
        reservedExtractions: usageResult.rows[0]?.reserved_extractions ?? 0,
      };
      if (usage.cloudExtractions + usage.reservedExtractions >= freeScanLimit) {
        await client.query('commit');
        return {
          allowed: false,
          reservationId: null,
          usage,
        };
      }
      const reservationId = makeId();
      await client.query(
        `
          update usage_counters
          set reserved_extractions = reserved_extractions + 1,
            updated_at = now()
          where install_id = $1 and month_key = $2
        `,
        [installId, monthKey],
      );
      await client.query(
        `
          insert into quota_reservations
            (reservation_id, install_id, month_key, status, expires_at)
          values ($1, $2, $3, 'reserved', $4)
        `,
        [
          reservationId,
          installId,
          monthKey,
          new Date(Date.now() + reservationTtlSeconds * 1000),
        ],
      );
      await client.query('commit');
      return {
        allowed: true,
        reservationId,
        usage: {
          cloudExtractions: usage.cloudExtractions,
          reservedExtractions: usage.reservedExtractions + 1,
        },
      };
    } catch (error) {
      await client.query('rollback');
      throw error;
    } finally {
      client.release();
    }
  }

  async commitQuotaSlot(reservationId: string) {
    const client = await this.pool.connect();
    try {
      await client.query('begin');
      const reservationResult = await client.query(
        `
          select reservation_id, install_id, month_key, status, expires_at
          from quota_reservations
          where reservation_id = $1
          for update
        `,
        [reservationId],
      );
      const reservation = reservationResult.rows[0];
      if (!reservation || reservation.status !== 'reserved') {
        await client.query('rollback');
        return;
      }
      if (new Date(reservation.expires_at).getTime() <= Date.now()) {
        await client.query(
          `
            update quota_reservations
            set status = 'released', released_at = now()
            where reservation_id = $1 and status = 'reserved'
          `,
          [reservationId],
        );
        await client.query(
          `
            update usage_counters
            set reserved_extractions = greatest(0, reserved_extractions - 1),
              updated_at = now()
            where install_id = $1 and month_key = $2
          `,
          [reservation.install_id, reservation.month_key],
        );
        await client.query('commit');
        return;
      }
      await client.query(
        `
          update quota_reservations
          set status = 'committed', committed_at = now()
          where reservation_id = $1
        `,
        [reservationId],
      );
      await client.query(
        `
          update usage_counters
          set reserved_extractions = greatest(0, reserved_extractions - 1),
            cloud_extractions = cloud_extractions + 1,
            updated_at = now()
          where install_id = $1 and month_key = $2
        `,
        [reservation.install_id, reservation.month_key],
      );
      await client.query('commit');
    } catch (error) {
      await client.query('rollback');
      throw error;
    } finally {
      client.release();
    }
  }

  async releaseQuotaSlot(reservationId: string) {
    const client = await this.pool.connect();
    try {
      await client.query('begin');
      const reservationResult = await client.query(
        `
          select reservation_id, install_id, month_key, status
          from quota_reservations
          where reservation_id = $1
          for update
        `,
        [reservationId],
      );
      const reservation = reservationResult.rows[0];
      if (!reservation || reservation.status !== 'reserved') {
        await client.query('rollback');
        return;
      }
      await client.query(
        `
          update quota_reservations
          set status = 'released', released_at = now()
          where reservation_id = $1
        `,
        [reservationId],
      );
      await client.query(
        `
          update usage_counters
          set reserved_extractions = greatest(0, reserved_extractions - 1),
            updated_at = now()
          where install_id = $1 and month_key = $2
        `,
        [reservation.install_id, reservation.month_key],
      );
      await client.query('commit');
    } catch (error) {
      await client.query('rollback');
      throw error;
    } finally {
      client.release();
    }
  }

  async getEntitlement(installId: string) {
    const result = await this.pool.query(
      `
        select
          install_id,
          is_premium,
          product_id,
          plan_id,
          billing_provider,
          status,
          valid_until,
          auto_renewing,
          last_verified_at,
          purchase_token_hash,
          original_external_id,
          features
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
          productId: row.product_id,
          planId: row.plan_id,
          billingProvider: row.billing_provider,
          status: row.status,
          validUntil: row.valid_until,
          autoRenewing: row.auto_renewing,
          lastVerifiedAt: row.last_verified_at,
          purchaseTokenHash: row.purchase_token_hash,
          originalExternalId: row.original_external_id,
          features: row.features,
        }
      : {
          installId,
          isPremium: false,
          productId: null,
          planId: null,
          billingProvider: null,
          status: 'free',
          validUntil: null,
          autoRenewing: false,
          lastVerifiedAt: null,
          purchaseTokenHash: null,
          originalExternalId: null,
          features: [],
        };
  }

  async upsertEntitlement(record: EntitlementRecord) {
    await this.pool.query(
      `
        insert into premium_entitlements
          (
            install_id,
            is_premium,
            product_id,
            plan_id,
            billing_provider,
            status,
            valid_until,
            auto_renewing,
            last_verified_at,
            purchase_token_hash,
            original_external_id,
            features,
            updated_at
          )
        values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12::jsonb, now())
        on conflict (install_id)
        do update set
          is_premium = excluded.is_premium,
          product_id = excluded.product_id,
          plan_id = excluded.plan_id,
          billing_provider = excluded.billing_provider,
          status = excluded.status,
          valid_until = excluded.valid_until,
          auto_renewing = excluded.auto_renewing,
          last_verified_at = excluded.last_verified_at,
          purchase_token_hash = excluded.purchase_token_hash,
          original_external_id = excluded.original_external_id,
          features = excluded.features,
          updated_at = now()
      `,
      [
        record.installId,
        record.isPremium,
        record.productId,
        record.planId,
        record.billingProvider,
        record.status,
        record.validUntil,
        record.autoRenewing,
        record.lastVerifiedAt,
        record.purchaseTokenHash,
        record.originalExternalId,
        JSON.stringify(record.features),
      ],
    );
  }

  async savePurchaseHistory(record: PurchaseHistoryRecord) {
    await this.pool.query(
      `
        insert into billing_purchase_history
          (
            record_id,
            install_id,
            product_id,
            plan_id,
            billing_provider,
            status,
            purchase_token_hash,
            original_external_id,
            valid_until,
            auto_renewing,
            payload
          )
        values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb)
      `,
      [
        record.recordId,
        record.installId,
        record.productId,
        record.planId,
        record.billingProvider,
        record.status,
        record.purchaseTokenHash,
        record.originalExternalId,
        record.validUntil,
        record.autoRenewing,
        JSON.stringify(record.payload),
      ],
    );
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

export async function readSchemaSql() {
  return readFile(new URL('../../sql/001_init.sql', import.meta.url), 'utf8');
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
