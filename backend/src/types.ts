import { z } from "zod";

export const appEnvironmentSchema = z.enum([
  "development",
  "staging",
  "production",
  "test",
]);

export const documentClassificationSchema = z.enum([
  "creditCardStatement",
  "loanStatement",
  "bnplDashboard",
  "receipt",
  "genericBill",
  "genericFinanceScreenshot",
  "unknown",
]);

export const sourceTypeSchema = z.enum([
  "camera",
  "gallery",
  "screenshot",
  "pdf",
  "receipt",
  "bill",
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
  statement_start_date: z.string().nullable().optional(),
  statement_end_date: z.string().nullable().optional(),
});

export const statementLineItemSchema = z.object({
  id: z.string().nullable().optional(),
  date: z.string().nullable(),
  description: z.string().nullable(),
  amount: z.number().nullable(),
  type: z.string().nullable(),
  confidence: z.number().min(0).max(1).default(0),
  currency: z.string().nullable().optional(),
  warnings: z.array(z.string()).default([]),
});

export const quotaSnapshotSchema = z.object({
  allowed: z.boolean(),
  remaining_free_scans: z.number().int().min(0),
  premium_required: z.boolean(),
  reset_at: z.string(),
});

export const entitlementSnapshotSchema = z.object({
  is_premium: z.boolean(),
  product_id: z.string().nullable(),
  plan_id: z.string().nullable(),
  billing_provider: z.string().nullable(),
  status: z.string(),
  valid_until: z.string().nullable(),
  auto_renewing: z.boolean(),
  last_verified_at: z.string().nullable(),
  original_external_id: z.string().nullable(),
  features: z.array(z.string()),
});

export const extractionResponseSchema = z.object({
  extraction: extractionSchema,
  summary: extractionSchema,
  line_items: z.array(statementLineItemSchema).default([]),
  document_signals: z.array(z.string()).default([]),
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

export const billingVerifyRequestSchema = z.object({
  install_id: z.string().min(1),
  product_id: z.string().min(1),
  base_plan_id: z.string().nullable().optional(),
  purchase_token: z.string().min(1),
  package_name: z.string().min(1),
  purchase_state: z.string().min(1),
  purchase_time: z.string().nullable().optional(),
  app_version: z.string().min(1),
});

export const billingRestoreRequestSchema = z.object({
  install_id: z.string().min(1),
  package_name: z.string().min(1),
  app_version: z.string().min(1),
  purchases: z.array(
    z.object({
      product_id: z.string().min(1),
      base_plan_id: z.string().nullable().optional(),
      purchase_token: z.string().min(1),
      purchase_state: z.string().min(1),
      purchase_time: z.string().nullable().optional(),
    }),
  ),
});

export const entitlementResponseSchema = z.object({
  entitlement: entitlementSnapshotSchema,
});

export type DocumentClassification = z.infer<
  typeof documentClassificationSchema
>;
export type ExtractionPayload = z.infer<typeof extractionSchema>;
export type StatementLineItemPayload = z.infer<typeof statementLineItemSchema>;
export type ExtractionResponse = z.infer<typeof extractionResponseSchema>;
export type BootstrapChallengeRequest = z.infer<
  typeof bootstrapChallengeRequestSchema
>;
export type BootstrapVerifyRequest = z.infer<
  typeof bootstrapVerifyRequestSchema
>;
export type TokenRefreshRequest = z.infer<typeof tokenRefreshRequestSchema>;
export type ExtractionRequest = z.infer<typeof extractionRequestSchema>;
export type BillingVerifyRequest = z.infer<typeof billingVerifyRequestSchema>;
export type BillingRestoreRequest = z.infer<typeof billingRestoreRequestSchema>;
export type EntitlementSnapshot = z.infer<typeof entitlementSnapshotSchema>;
