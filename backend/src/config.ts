import dotenv from 'dotenv';
import { z } from 'zod';

import { appEnvironmentSchema } from './types.js';

dotenv.config();

const defaultAccessSecret = 'local-access-secret';
const defaultRefreshSecret = 'local-refresh-secret';
const defaultIssuer = 'debt-destroyer-backend';
const defaultAudience = 'debt-destroyer-mobile';
const defaultGeminiModel = 'gemini-2.0-flash';
const defaultPostgresPoolMax = 10;
const defaultPostgresPoolMin = 0;
const defaultPostgresIdleTimeoutMs = 30_000;
const defaultPostgresConnectionTimeoutMs = 10_000;
const defaultPostgresMaxLifetimeSeconds = 300;

const configSchema = z
  .object({
    NODE_ENV: appEnvironmentSchema.default('development'),
    HOST: z.string().default('0.0.0.0'),
    PORT: z.coerce.number().default(8787),
    LOG_LEVEL: z
      .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
      .optional(),
    TRUST_PROXY: z.coerce.boolean().default(false),
    POSTGRES_URL: z.string().optional(),
    POSTGRES_POOL_MAX: z.coerce
      .number()
      .int()
      .positive()
      .default(defaultPostgresPoolMax),
    POSTGRES_POOL_MIN: z.coerce
      .number()
      .int()
      .nonnegative()
      .default(defaultPostgresPoolMin),
    POSTGRES_IDLE_TIMEOUT_MS: z.coerce
      .number()
      .int()
      .positive()
      .default(defaultPostgresIdleTimeoutMs),
    POSTGRES_CONNECTION_TIMEOUT_MS: z.coerce
      .number()
      .int()
      .positive()
      .default(defaultPostgresConnectionTimeoutMs),
    POSTGRES_MAX_LIFETIME_SECONDS: z.coerce
      .number()
      .int()
      .positive()
      .default(defaultPostgresMaxLifetimeSeconds),
    REDIS_URL: z.string().optional(),
    JWT_SECRET: z.string().min(8).optional(),
    JWT_ACCESS_SECRET: z.string().min(8).optional(),
    JWT_REFRESH_SECRET: z.string().min(8).optional(),
    JWT_ISSUER: z.string().min(1).optional(),
    JWT_AUDIENCE: z.string().min(1).optional(),
    GEMINI_API_KEY: z.string().optional(),
    GEMINI_MODEL: z.string().default(defaultGeminiModel),
    GEMINI_API_VERSION: z.enum(['v1', 'v1beta']).default('v1beta'),
    GEMINI_TIMEOUT_MS: z.coerce.number().int().positive().optional(),
    FREE_SCAN_LIMIT: z.coerce.number().default(5),
    ACCESS_TOKEN_TTL: z.coerce.number().int().positive().optional(),
    ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().int().positive().optional(),
    REFRESH_TOKEN_TTL: z.coerce.number().int().positive().optional(),
    REFRESH_TOKEN_TTL_DAYS: z.coerce.number().int().positive().optional(),
    REQUEST_TIMEOUT_MS: z.coerce.number().int().positive().optional(),
    RATE_LIMIT_BOOTSTRAP_CHALLENGE_PER_MINUTE: z.coerce
      .number()
      .int()
      .positive()
      .default(20),
    RATE_LIMIT_BOOTSTRAP_VERIFY_PER_MINUTE: z.coerce
      .number()
      .int()
      .positive()
      .default(20),
    RATE_LIMIT_TOKEN_REFRESH_PER_MINUTE: z.coerce
      .number()
      .int()
      .positive()
      .default(20),
    RATE_LIMIT_BILLING_VERIFY_PER_MINUTE: z.coerce
      .number()
      .int()
      .positive()
      .default(20),
    RATE_LIMIT_BILLING_RESTORE_PER_MINUTE: z.coerce
      .number()
      .int()
      .positive()
      .default(10),
    RATE_LIMIT_EXTRACTION_INSTALL_PER_MINUTE: z.coerce
      .number()
      .int()
      .positive()
      .default(20),
    RATE_LIMIT_EXTRACTION_IP_PER_MINUTE: z.coerce
      .number()
      .int()
      .positive()
      .default(60),
    ALLOW_DEBUG_ATTESTATION: z.coerce.boolean().default(false),
    DEBUG_ATTESTATION_SECRET: z.string().optional(),
    GOOGLE_PLAY_PACKAGE_NAME: z.string().default('com.debtdestroyer.app'),
    GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: z.string().optional(),
    PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER: z.string().optional(),
    PLAY_INTEGRITY_PACKAGE_NAME: z
      .string()
      .default('com.debtdestroyer.app'),
    PREMIUM_PRODUCT_ID: z.string().default('premium'),
    PREMIUM_MONTHLY_BASE_PLAN_ID: z.string().default('monthly'),
    PREMIUM_YEARLY_BASE_PLAN_ID: z.string().default('yearly'),
    ENABLE_CLEANUP_JOBS: z.coerce.boolean().default(false),
    CLEANUP_INTERVAL_MINUTES: z.coerce.number().int().positive().default(60),
  })
  .superRefine((env, ctx) => {
    const isLocalEnvironment =
      env.NODE_ENV === 'development' || env.NODE_ENV === 'test';
    const jwtSecret = env.JWT_SECRET;
    const accessSecret = env.JWT_ACCESS_SECRET ?? jwtSecret ?? defaultAccessSecret;
    const refreshSecret =
      env.JWT_REFRESH_SECRET ?? jwtSecret ?? defaultRefreshSecret;
    if (!isLocalEnvironment) {
      if (!env.POSTGRES_URL) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['POSTGRES_URL'],
          message:
            'POSTGRES_URL must be configured outside development and test.',
        });
      }
      if (!env.REDIS_URL) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['REDIS_URL'],
          message: 'REDIS_URL must be configured outside development and test.',
        });
      }
      if (!env.GEMINI_API_KEY) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['GEMINI_API_KEY'],
          message:
            'GEMINI_API_KEY must be configured outside development and test.',
        });
      }
      if (!env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'],
          message:
            'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON must be configured outside development and test.',
        });
      }
      if (accessSecret == defaultAccessSecret) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['JWT_ACCESS_SECRET'],
          message:
            'JWT_ACCESS_SECRET must be explicitly configured outside development and test.',
        });
      }
      if (refreshSecret == defaultRefreshSecret) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['JWT_REFRESH_SECRET'],
          message:
            'JWT_REFRESH_SECRET must be explicitly configured outside development and test.',
        });
      }
    }
    if (env.ALLOW_DEBUG_ATTESTATION && !isLocalEnvironment) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['ALLOW_DEBUG_ATTESTATION'],
        message:
          'Debug attestation can only be enabled in development or test environments.',
      });
    }
    if (env.ALLOW_DEBUG_ATTESTATION && !env.DEBUG_ATTESTATION_SECRET) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['DEBUG_ATTESTATION_SECRET'],
        message:
          'DEBUG_ATTESTATION_SECRET is required when debug attestation is enabled.',
      });
    }
    if (!isLocalEnvironment) {
      if (!env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER'],
          message:
            'PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER must be configured outside development and test.',
        });
      }
    }
    if (env.CLEANUP_INTERVAL_MINUTES < 5) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['CLEANUP_INTERVAL_MINUTES'],
        message: 'CLEANUP_INTERVAL_MINUTES must be at least 5 minutes.',
      });
    }
    if (env.POSTGRES_POOL_MIN > env.POSTGRES_POOL_MAX) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['POSTGRES_POOL_MIN'],
        message: 'POSTGRES_POOL_MIN cannot be greater than POSTGRES_POOL_MAX.',
      });
    }
  });

export type AppConfig = ReturnType<typeof loadConfig>;

export function loadConfig() {
  const env = configSchema.parse(process.env);
  const accessTokenTtlSeconds =
    env.ACCESS_TOKEN_TTL_SECONDS ?? env.ACCESS_TOKEN_TTL ?? 900;
  const refreshTokenTtlDays = env.REFRESH_TOKEN_TTL_DAYS ?? env.REFRESH_TOKEN_TTL ?? 30;
  return {
    environment: env.NODE_ENV,
    host: env.HOST,
    port: env.PORT,
    logLevel: env.LOG_LEVEL ?? (env.NODE_ENV === 'production' ? 'info' : 'debug'),
    trustProxy: env.TRUST_PROXY,
    postgresUrl: env.POSTGRES_URL,
    postgresPool: {
      max: env.POSTGRES_POOL_MAX,
      min: env.POSTGRES_POOL_MIN,
      idleTimeoutMs: env.POSTGRES_IDLE_TIMEOUT_MS,
      connectionTimeoutMs: env.POSTGRES_CONNECTION_TIMEOUT_MS,
      maxLifetimeSeconds: env.POSTGRES_MAX_LIFETIME_SECONDS,
    },
    redisUrl: env.REDIS_URL,
    jwtAccessSecret: env.JWT_ACCESS_SECRET ?? env.JWT_SECRET ?? defaultAccessSecret,
    jwtRefreshSecret:
      env.JWT_REFRESH_SECRET ?? env.JWT_SECRET ?? defaultRefreshSecret,
    jwtIssuer: env.JWT_ISSUER ?? defaultIssuer,
    jwtAudience: env.JWT_AUDIENCE ?? defaultAudience,
    geminiApiKey: env.GEMINI_API_KEY,
    geminiModel: env.GEMINI_MODEL,
    geminiApiVersion: env.GEMINI_API_VERSION,
    freeScanLimit: env.FREE_SCAN_LIMIT,
    accessTokenTtlSeconds,
    refreshTokenTtlDays,
    requestTimeoutMs: env.GEMINI_TIMEOUT_MS ?? env.REQUEST_TIMEOUT_MS ?? 15000,
    allowDebugAttestation: env.ALLOW_DEBUG_ATTESTATION,
    debugAttestationSecret: env.DEBUG_ATTESTATION_SECRET,
    googlePlayPackageName: env.GOOGLE_PLAY_PACKAGE_NAME,
    googlePlayServiceAccountJson: env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON,
    playIntegrityCloudProjectNumber: env.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER,
    playIntegrityPackageName: env.PLAY_INTEGRITY_PACKAGE_NAME,
    premiumProductId: env.PREMIUM_PRODUCT_ID,
    premiumMonthlyBasePlanId: env.PREMIUM_MONTHLY_BASE_PLAN_ID,
    premiumYearlyBasePlanId: env.PREMIUM_YEARLY_BASE_PLAN_ID,
    rateLimits: {
      bootstrapChallengePerMinute: env.RATE_LIMIT_BOOTSTRAP_CHALLENGE_PER_MINUTE,
      bootstrapVerifyPerMinute: env.RATE_LIMIT_BOOTSTRAP_VERIFY_PER_MINUTE,
      tokenRefreshPerMinute: env.RATE_LIMIT_TOKEN_REFRESH_PER_MINUTE,
      billingVerifyPerMinute: env.RATE_LIMIT_BILLING_VERIFY_PER_MINUTE,
      billingRestorePerMinute: env.RATE_LIMIT_BILLING_RESTORE_PER_MINUTE,
      extractionInstallPerMinute: env.RATE_LIMIT_EXTRACTION_INSTALL_PER_MINUTE,
      extractionIpPerMinute: env.RATE_LIMIT_EXTRACTION_IP_PER_MINUTE,
    },
    enableCleanupJobs: env.ENABLE_CLEANUP_JOBS,
    cleanupIntervalMinutes: env.CLEANUP_INTERVAL_MINUTES,
  };
}
