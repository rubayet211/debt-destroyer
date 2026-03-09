import { google } from 'googleapis';

import type { AppConfig } from '../config.js';
import { AppError } from '../utils.js';

export type BillingVerificationInput = {
  productId: string;
  basePlanId: string | null;
  purchaseToken: string;
  packageName: string;
};

export type VerifiedEntitlement = {
  isPremium: boolean;
  productId: string | null;
  planId: string | null;
  billingProvider: 'google_play';
  status: 'active' | 'grace' | 'on_hold' | 'expired' | 'revoked' | 'pending';
  validUntil: Date | null;
  autoRenewing: boolean;
  lastVerifiedAt: Date;
  originalExternalId: string | null;
  purchaseTokenHash: string;
  features: string[];
  rawProviderPayload: Record<string, unknown>;
};

export interface BillingVerifier {
  verifySubscription(
    input: BillingVerificationInput,
  ): Promise<VerifiedEntitlement>;
}

const premiumFeatures = [
  'unlimitedScans',
  'pdfImport',
  'advancedReports',
  'csvExport',
  'scenarioSaving',
  'advancedStrategyComparison',
  'premiumThemes',
];

export function createBillingVerifier(config: AppConfig): BillingVerifier {
  if (!config.googlePlayServiceAccountJson) {
    return new UnconfiguredBillingVerifier();
  }
  return new GooglePlayBillingVerifier(config);
}

class UnconfiguredBillingVerifier implements BillingVerifier {
  async verifySubscription(): Promise<VerifiedEntitlement> {
    throw new AppError(
      503,
      'billing_unavailable',
      'Google Play verification is not configured on the backend.',
    );
  }
}

export class GooglePlayBillingVerifier implements BillingVerifier {
  constructor(private readonly config: AppConfig) {}

  async verifySubscription(
    input: BillingVerificationInput,
  ): Promise<VerifiedEntitlement> {
    const auth = new google.auth.GoogleAuth({
      credentials: JSON.parse(this.config.googlePlayServiceAccountJson!),
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    const publisher = google.androidpublisher({
      version: 'v3',
      auth,
    });
    const response = await publisher.purchases.subscriptionsv2.get({
      packageName: input.packageName,
      token: input.purchaseToken,
    });
    const payload = (response.data ?? {}) as Record<string, unknown>;
    const lineItem = pickLineItem(payload, input.productId);
    const status = mapSubscriptionStatus(payload['subscriptionState']);
    const validUntil = parseDate((lineItem?.expiryTime as string | undefined) ?? null);
    const autoRenewing = Boolean(
      (lineItem?.autoRenewingPlan as Record<string, unknown> | undefined)?.[
        'autoRenewEnabled'
      ],
    );

    return {
      isPremium: status === 'active' || status === 'grace',
      productId:
        (lineItem?.productId as string | undefined) ?? input.productId ?? null,
      planId:
        ((lineItem?.offerDetails as Record<string, unknown> | undefined)?.[
          'basePlanId'
        ] as
          string | undefined) ??
        input.basePlanId,
      billingProvider: 'google_play',
      status,
      validUntil,
      autoRenewing,
      lastVerifiedAt: new Date(),
      originalExternalId:
        (payload['latestOrderId'] as string | undefined) ?? null,
      purchaseTokenHash: '',
      features:
        status === 'active' || status === 'grace' ? premiumFeatures : [],
      rawProviderPayload: payload,
    };
  }
}

function pickLineItem(
  payload: Record<string, unknown>,
  productId: string,
): Record<string, unknown> | null {
  const lineItems = Array.isArray(payload['lineItems'])
    ? (payload['lineItems'] as Record<string, unknown>[])
    : [];
  for (const lineItem of lineItems) {
    if ((lineItem['productId'] as string | undefined) === productId) {
      return lineItem;
    }
  }
  return lineItems.length === 0 ? null : lineItems[0];
}

function parseDate(value: string | null) {
  if (value == null) {
    return null;
  }
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function mapSubscriptionStatus(
  raw: unknown,
): 'active' | 'grace' | 'on_hold' | 'expired' | 'revoked' | 'pending' {
  switch (raw) {
    case 'SUBSCRIPTION_STATE_ACTIVE':
      return 'active';
    case 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD':
      return 'grace';
    case 'SUBSCRIPTION_STATE_ON_HOLD':
      return 'on_hold';
    case 'SUBSCRIPTION_STATE_PENDING':
      return 'pending';
    case 'SUBSCRIPTION_STATE_EXPIRED':
      return 'expired';
    case 'SUBSCRIPTION_STATE_CANCELED':
    case 'SUBSCRIPTION_STATE_PAUSED':
      return 'revoked';
    default:
      return 'expired';
  }
}
