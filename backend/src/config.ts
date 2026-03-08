import dotenv from 'dotenv';
import { z } from 'zod';

import { appEnvironmentSchema } from './types.js';

dotenv.config();

const configSchema = z.object({
  NODE_ENV: appEnvironmentSchema.default('development'),
  PORT: z.coerce.number().default(8787),
  POSTGRES_URL: z.string().optional(),
  REDIS_URL: z.string().optional(),
  JWT_ACCESS_SECRET: z.string().min(8).default('local-access-secret'),
  JWT_REFRESH_SECRET: z.string().min(8).default('local-refresh-secret'),
  GEMINI_API_KEY: z.string().optional(),
  GEMINI_MODEL: z.string().default('gemini-2.0-flash'),
  FREE_SCAN_LIMIT: z.coerce.number().default(5),
  ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().default(900),
  REFRESH_TOKEN_TTL_DAYS: z.coerce.number().default(30),
  REQUEST_TIMEOUT_MS: z.coerce.number().default(15000),
  ALLOW_DEBUG_ATTESTATION: z.coerce.boolean().default(true),
});

export type AppConfig = ReturnType<typeof loadConfig>;

export function loadConfig() {
  const env = configSchema.parse(process.env);
  return {
    environment: env.NODE_ENV,
    port: env.PORT,
    postgresUrl: env.POSTGRES_URL,
    redisUrl: env.REDIS_URL,
    jwtAccessSecret: env.JWT_ACCESS_SECRET,
    jwtRefreshSecret: env.JWT_REFRESH_SECRET,
    geminiApiKey: env.GEMINI_API_KEY,
    geminiModel: env.GEMINI_MODEL,
    freeScanLimit: env.FREE_SCAN_LIMIT,
    accessTokenTtlSeconds: env.ACCESS_TOKEN_TTL_SECONDS,
    refreshTokenTtlDays: env.REFRESH_TOKEN_TTL_DAYS,
    requestTimeoutMs: env.REQUEST_TIMEOUT_MS,
    allowDebugAttestation: env.ALLOW_DEBUG_ATTESTATION,
  };
}
