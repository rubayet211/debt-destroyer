import type { AppConfig } from '../config.js';
import { hmacSha256 } from './crypto.js';

export type AttestationVerdict = {
  valid: boolean;
  status: 'verified' | 'debug' | 'failed';
  reason?: string;
};

export interface AttestationVerifier {
  verify(input: {
    attestationToken: string;
    installId: string;
    nonce: string;
  }): Promise<AttestationVerdict>;
}

export class ConfigurableAttestationVerifier implements AttestationVerifier {
  constructor(private readonly config: AppConfig) {}

  async verify(input: {
    attestationToken: string;
    installId: string;
    nonce: string;
  }): Promise<AttestationVerdict> {
    const debugToken = buildDebugAttestationToken({
      secret: this.config.debugAttestationSecret,
      installId: input.installId,
      nonce: input.nonce,
    });
    if (
      this.config.allowDebugAttestation &&
      isDebugAttestationEnvironment(this.config.environment) &&
      debugToken !== null &&
      input.attestationToken === debugToken
    ) {
      return { valid: true, status: 'debug' };
    }

    return {
      valid: false,
      status: 'failed',
      reason:
        'Real Play Integrity verification is not configured for this environment.',
    };
  }
}

export function isDebugAttestationEnvironment(environment: string) {
  return environment === 'development' || environment === 'test';
}

export function buildDebugAttestationToken(input: {
  secret?: string;
  installId: string;
  nonce: string;
}) {
  if (!input.secret) {
    return null;
  }
  const signature = hmacSha256(
    input.secret,
    `${input.installId}:${input.nonce}`,
  );
  return `debug-attestation:v1:${signature}`;
}
