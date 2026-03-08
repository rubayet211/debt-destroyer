import dotenv from 'dotenv';
import { z } from 'zod';

import { appEnvironmentSchema } from './types.js';

dotenv.config();

const defaultAccessSecret = 'local-access-secret';
const defaultRefreshSecret = 'local-refresh-secret';

const configSchema = z
  .object({
    NODE_ENV: appEnvironmentSchema.default('development'),
    PORT: z.coerce.number().default(8787),
    POSTGRES_URL: z.string().optional(),
    REDIS_URL: z.string().optional(),
    JWT_ACCESS_SECRET: z.string().min(8).optional(),
    JWT_REFRESH_SECRET: z.string().min(8).optional(),
    GEMINI_API_KEY: z.string().optional(),
    GEMINI_MODEL: z.string().default('gemini-2.0-flash'),
    FREE_SCAN_LIMIT: z.coerce.number().default(5),
    ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().default(900),
    REFRESH_TOKEN_TTL_DAYS: z.coerce.number().default(30),
    REQUEST_TIMEOUT_MS: z.coerce.number().default(15000),
    ALLOW_DEBUG_ATTESTATION: z.coerce.boolean().default(false),
    DEBUG_ATTESTATION_SECRET: z.string().optional(),
  })
  .superRefine((env, ctx) => {
    const isLocalEnvironment =
      env.NODE_ENV === 'development' || env.NODE_ENV === 'test';
    const accessSecret = env.JWT_ACCESS_SECRET ?? defaultAccessSecret;
    const refreshSecret = env.JWT_REFRESH_SECRET ?? defaultRefreshSecret;
    if (!isLocalEnvironment) {
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
  });

export type AppConfig = ReturnType<typeof loadConfig>;

export function loadConfig() {
  const env = configSchema.parse(process.env);
  return {
    environment: env.NODE_ENV,
    port: env.PORT,
    postgresUrl: env.POSTGRES_URL,
    redisUrl: env.REDIS_URL,
    jwtAccessSecret: env.JWT_ACCESS_SECRET ?? defaultAccessSecret,
    jwtRefreshSecret: env.JWT_REFRESH_SECRET ?? defaultRefreshSecret,
    geminiApiKey: env.GEMINI_API_KEY,
    geminiModel: env.GEMINI_MODEL,
    freeScanLimit: env.FREE_SCAN_LIMIT,
    accessTokenTtlSeconds: env.ACCESS_TOKEN_TTL_SECONDS,
    refreshTokenTtlDays: env.REFRESH_TOKEN_TTL_DAYS,
    requestTimeoutMs: env.REQUEST_TIMEOUT_MS,
    allowDebugAttestation: env.ALLOW_DEBUG_ATTESTATION,
    debugAttestationSecret: env.DEBUG_ATTESTATION_SECRET,
  };
}
