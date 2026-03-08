import { z } from 'zod';

export const appEnvironmentSchema = z.enum([
  'development',
  'staging',
  'production',
  'test',
]);

export const documentClassificationSchema = z.enum([
  'creditCardStatement',
  'loanStatement',
  'bnplDashboard',
  'receipt',
  'genericBill',
  'genericFinanceScreenshot',
  'unknown',
]);

export const sourceTypeSchema = z.enum([
  'camera',
  'gallery',
  'screenshot',
  'pdf',
  'receipt',
  'bill',
]);

export const extractionSchema = z.object({
  issuer_name: z.string().nullable(),
  title: z.string().nullable(),
  debt_type: z.string().nullable(),
  current_balance: z.number().nullable(),
  original_balance: z.number().nullable(),
  apr_percentage: z.number().nullable(),
  minimum_payment: z.number().nullable(),
  due_date: z.string().nullable(),
  payment_date: z.string().nullable(),
  payment_amount: z.number().nullable(),
  currency: z.string().nullable(),
  notes: z.string().nullable(),
  confidence: z.number().min(0).max(1).default(0),
  last4: z.string().nullable(),
  raw_detected_labels: z.array(z.string()).default([]),
});

export const quotaSnapshotSchema = z.object({
  allowed: z.boolean(),
  remaining_free_scans: z.number().int().min(0),
  premium_required: z.boolean(),
  reset_at: z.string(),
});

export const extractionResponseSchema = z.object({
  extraction: extractionSchema,
  warnings: z.array(z.string()),
  quota: quotaSnapshotSchema,
  meta: z.object({
    request_id: z.string(),
    provider: z.string(),
    model: z.string(),
    classification: documentClassificationSchema,
    duration_ms: z.number().int().nonnegative(),
  }),
});

export const bootstrapChallengeRequestSchema = z.object({
  app_version: z.string().min(1),
  platform: z.string().min(1),
  install_id: z.string().min(1),
});

export const bootstrapVerifyRequestSchema = z.object({
  challenge_id: z.string().min(1),
  install_id: z.string().min(1),
  attestation_token: z.string().min(1),
  device: z.object({
    platform: z.string().min(1),
    app_version: z.string().min(1),
    build_mode: z.string().min(1),
  }),
});

export const tokenRefreshRequestSchema = z.object({
  refresh_token: z.string().min(1),
});

export const extractionRequestSchema = z.object({
  request_id: z.string().min(1),
  install_id: z.string().min(1),
  document_classification: documentClassificationSchema,
  normalized_ocr_text: z.string().min(1),
  source_type: sourceTypeSchema,
  app_version: z.string().min(1),
  consented_at: z.string().min(1),
});

export type DocumentClassification = z.infer<
  typeof documentClassificationSchema
>;
export type ExtractionPayload = z.infer<typeof extractionSchema>;
export type ExtractionResponse = z.infer<typeof extractionResponseSchema>;
export type BootstrapChallengeRequest = z.infer<
  typeof bootstrapChallengeRequestSchema
>;
export type BootstrapVerifyRequest = z.infer<
  typeof bootstrapVerifyRequestSchema
>;
export type TokenRefreshRequest = z.infer<typeof tokenRefreshRequestSchema>;
export type ExtractionRequest = z.infer<typeof extractionRequestSchema>;
