import { afterEach, beforeEach, describe, expect, test, vi } from 'vitest';

const redisMock = vi.hoisted(() => ({
  connectError: new Error('getaddrinfo ENOTFOUND red-bad'),
  instances: [] as Array<{
    on: ReturnType<typeof vi.fn>;
    connect: ReturnType<typeof vi.fn>;
    ping: ReturnType<typeof vi.fn>;
    disconnect: ReturnType<typeof vi.fn>;
  }>,
}));

const consoleSpies: Array<ReturnType<typeof vi.spyOn>> = [];

vi.mock('ioredis', () => ({
  Redis: vi.fn().mockImplementation(() => {
    const instance = {
      on: vi.fn(),
      connect: vi.fn().mockRejectedValue(redisMock.connectError),
      ping: vi.fn().mockResolvedValue('PONG'),
      disconnect: vi.fn(),
    };
    redisMock.instances.push(instance);
    return instance;
  }),
}));

describe('rate limiter Redis startup', () => {
  beforeEach(() => {
    redisMock.connectError = new Error('getaddrinfo ENOTFOUND red-bad');
    redisMock.instances.length = 0;
    consoleSpies.push(
      vi.spyOn(console, 'warn').mockImplementation(() => undefined),
      vi.spyOn(console, 'error').mockImplementation(() => undefined),
    );
  });

  afterEach(() => {
    for (const spy of consoleSpies) {
      spy.mockRestore();
    }
    consoleSpies.length = 0;
  });

  test('falls back to memory rate limiting when Redis is unavailable locally', async () => {
    const { MemoryRateLimiter, createRateLimiter } = await import(
      '../src/services/rate-limit.js'
    );

    const limiter = await createRateLimiter(
      'redis://red-bad:6379',
      'development',
    );

    expect(limiter).toBeInstanceOf(MemoryRateLimiter);
    expect(redisMock.instances[0].disconnect).toHaveBeenCalledOnce();
  });

  test('still fails startup when Redis is unavailable in production', async () => {
    const { createRateLimiter } = await import('../src/services/rate-limit.js');

    await expect(
      createRateLimiter('redis://red-bad:6379', 'production'),
    ).rejects.toThrow(/Redis unavailable/);
    expect(redisMock.instances[0].disconnect).toHaveBeenCalledOnce();
  });
});
