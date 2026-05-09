import { Redis } from 'ioredis';

import { makeId } from './crypto.js';

export type RateLimitResult = {
  allowed: boolean;
  remaining: number;
  resetAt: Date;
};

export interface RateLimiter {
  consume(
    key: string,
    limit: number,
    windowSeconds: number,
  ): Promise<RateLimitResult>;
  checkHealth?(timeoutMs?: number): Promise<boolean>;
  close?(): Promise<void>;
}

export class MemoryRateLimiter implements RateLimiter {
  private readonly buckets = new Map<
    string,
    { count: number; resetAt: number }
  >();

  async consume(
    key: string,
    limit: number,
    windowSeconds: number,
  ): Promise<RateLimitResult> {
    const now = Date.now();
    const existing = this.buckets.get(key);
    if (!existing || existing.resetAt <= now) {
      const resetAt = now + windowSeconds * 1000;
      this.buckets.set(key, { count: 1, resetAt });
      return {
        allowed: true,
        remaining: Math.max(0, limit - 1),
        resetAt: new Date(resetAt),
      };
    }

    existing.count += 1;
    return {
      allowed: existing.count <= limit,
      remaining: Math.max(0, limit - existing.count),
      resetAt: new Date(existing.resetAt),
    };
  }

  async checkHealth() {
    return true;
  }
}

export class RedisRateLimiter implements RateLimiter {
  constructor(private readonly redis: Redis) {}

  async consume(
    key: string,
    limit: number,
    windowSeconds: number,
  ): Promise<RateLimitResult> {
    const namespaced = `rate-limit:${key}`;
    const count = await this.redis.incr(namespaced);
    if (count === 1) {
      await this.redis.expire(namespaced, windowSeconds);
    }
    const ttl = await this.redis.ttl(namespaced);
    return {
      allowed: count <= limit,
      remaining: Math.max(0, limit - count),
      resetAt: new Date(Date.now() + Math.max(ttl, 0) * 1000),
    };
  }

  async close() {
    await this.redis.quit();
  }

  async checkHealth(timeoutMs = 1200) {
    return withTimeout(
      this.redis
        .ping()
        .then((value) => value === 'PONG')
        .catch(() => false),
      timeoutMs,
      false,
    );
  }
}

export async function createRateLimiter(
  redisUrl?: string,
  environment: string = 'development',
) {
  const isLocalEnvironment =
    environment === 'development' || environment === 'test';
  if (!redisUrl) {
    if (!isLocalEnvironment) {
      throw new Error(
        'REDIS_URL is required in staging/production. Refusing to use memory rate limiting.',
      );
    }
    return new MemoryRateLimiter();
  }
  const redis = new Redis(redisUrl);
  await redis.ping();
  return new RedisRateLimiter(redis);
}

export function makeRateLimitEventKey(prefix: string, suffix: string) {
  return `${prefix}:${suffix}:${makeId()}`;
}

function withTimeout<T>(promise: Promise<T>, timeoutMs: number, fallback: T) {
  return new Promise<T>((resolve) => {
    const timer = setTimeout(() => resolve(fallback), timeoutMs);
    promise
      .then((value) => resolve(value))
      .catch(() => resolve(fallback))
      .finally(() => clearTimeout(timer));
  });
}
