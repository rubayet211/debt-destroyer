import { createHash, randomBytes, randomUUID } from 'node:crypto';

export function makeId() {
  return randomUUID();
}

export function makeNonce() {
  return randomBytes(24).toString('base64url');
}

export function makeOpaqueToken() {
  return randomBytes(48).toString('base64url');
}

export function sha256(input: string) {
  return createHash('sha256').update(input).digest('hex');
}

export function redactTextPreview(input: string) {
  const trimmed = input.trim().replaceAll(/\s+/g, ' ');
  return trimmed.slice(0, 96);
}
