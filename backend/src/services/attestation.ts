import type { AppConfig } from '../config.js';

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
    const debugToken = `debug-attestation:${input.installId}:${input.nonce}`;
    if (
      this.config.allowDebugAttestation &&
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
