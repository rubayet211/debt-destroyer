import { createApp } from './app.js';
import { loadConfig } from './config.js';

const config = loadConfig();
const app = await createApp({ config });

let isShuttingDown = false;

const shutdown = async (signal: string, exitCode = 0) => {
  if (isShuttingDown) {
    return;
  }

  isShuttingDown = true;
  app.log.info({ signal }, 'shutdown requested');

  try {
    await Promise.race([
      app.close(),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('graceful shutdown timed out')), 10_000),
      ),
    ]);
    app.log.info({ signal }, 'shutdown complete');
    process.exit(exitCode);
  } catch (error) {
    app.log.error({ err: error, signal }, 'shutdown failed');
    process.exit(1);
  }
};

process.on('SIGINT', () => {
  void shutdown('SIGINT');
});

process.on('SIGTERM', () => {
  void shutdown('SIGTERM');
});

process.on('unhandledRejection', (reason) => {
  app.log.error({ err: reason }, 'unhandled promise rejection');
  void shutdown('unhandledRejection', 1);
});

process.on('uncaughtException', (error) => {
  app.log.error({ err: error }, 'uncaught exception');
  void shutdown('uncaughtException', 1);
});

try {
  await app.listen({ port: config.port, host: config.host });
  app.log.info(
    {
      host: config.host,
      port: config.port,
      environment: config.environment,
    },
    'server listening',
  );
} catch (error) {
  app.log.error({ err: error }, 'server failed to start');
  await app.close().catch(() => undefined);
  process.exit(1);
}
