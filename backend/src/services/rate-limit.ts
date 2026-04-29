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
}

export async function createRateLimiter(redisUrl?: string) {
  if (!redisUrl) {
    return new MemoryRateLimiter();
  }
  return new RedisRateLimiter(new Redis(redisUrl));
}

export function makeRateLimitEventKey(prefix: string, suffix: string) {
  return `${prefix}:${suffix}:${makeId()}`;
}
