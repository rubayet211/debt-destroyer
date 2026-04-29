import { google } from 'googleapis';

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

type DecodeIntegrityResponse = {
  tokenPayloadExternal?: {
    requestDetails?: {
      requestPackageName?: string;
      nonce?: string;
      timestampMillis?: string;
    };
    appIntegrity?: {
      appRecognitionVerdict?: string;
      packageName?: string;
    };
    deviceIntegrity?: {
      deviceRecognitionVerdict?: string[];
    };
  };
};

type IntegrityTokenDecoder = (
  token: string,
  config: AppConfig,
) => Promise<DecodeIntegrityResponse>;

export class ConfigurableAttestationVerifier implements AttestationVerifier {
  constructor(
    private readonly config: AppConfig,
    private readonly decoder: IntegrityTokenDecoder = decodeIntegrityToken,
  ) {}

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

    if (!this.config.googlePlayServiceAccountJson) {
      return {
        valid: false,
        status: 'failed',
        reason: 'Play Integrity verification is not configured.',
      };
    }

    try {
      const decoded = await this.decoder(input.attestationToken, this.config);
      const payload = decoded.tokenPayloadExternal;
      if (!payload) {
        return invalid('Integrity payload missing.');
      }
      const requestDetails = payload.requestDetails ?? {};
      const appIntegrity = payload.appIntegrity ?? {};
      const deviceIntegrity = payload.deviceIntegrity ?? {};
      const requestPackageName =
        requestDetails.requestPackageName ?? appIntegrity.packageName;
      if (requestDetails.nonce !== input.nonce) {
        return invalid('Integrity nonce mismatch.');
      }
      if (requestPackageName !== this.config.playIntegrityPackageName) {
        return invalid('Integrity package mismatch.');
      }
      if (
        appIntegrity.appRecognitionVerdict !==
        'PLAY_RECOGNIZED'
      ) {
        return invalid('App integrity verdict rejected.');
      }
      const deviceVerdicts = deviceIntegrity.deviceRecognitionVerdict ?? [];
      if (
        !deviceVerdicts.includes('MEETS_DEVICE_INTEGRITY') &&
        !deviceVerdicts.includes('MEETS_STRONG_INTEGRITY')
      ) {
        return invalid('Device integrity verdict rejected.');
      }
      return { valid: true, status: 'verified' };
    } catch (error) {
      return invalid(
        error instanceof Error
          ? error.message
          : 'Integrity verification failed.',
      );
    }
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

function invalid(reason: string): AttestationVerdict {
  return { valid: false, status: 'failed', reason };
}

async function decodeIntegrityToken(
  token: string,
  config: AppConfig,
): Promise<DecodeIntegrityResponse> {
  const auth = new google.auth.GoogleAuth({
    credentials: JSON.parse(config.googlePlayServiceAccountJson!),
    scopes: ['https://www.googleapis.com/auth/playintegrity'],
  });
  const client = await auth.getClient();
  const accessTokenResponse = await client.getAccessToken();
  const accessToken =
    typeof accessTokenResponse === 'string'
      ? accessTokenResponse
      : accessTokenResponse.token;
  if (!accessToken) {
    throw new Error('Unable to obtain Play Integrity access token.');
  }
  const response = await fetch(
    `https://playintegrity.googleapis.com/v1/${config.playIntegrityPackageName}:decodeIntegrityToken`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ integrityToken: token }),
    },
  );
  if (!response.ok) {
    throw new Error(
      `Play Integrity decode failed with status ${response.status}.`,
    );
  }
  return (await response.json()) as DecodeIntegrityResponse;
}
