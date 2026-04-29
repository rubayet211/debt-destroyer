import {
  extractionSchema,
  statementLineItemSchema,
  type ExtractionPayload,
  type StatementLineItemPayload,
} from "../types.js";

function sanitizePositiveNumber(value: unknown) {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  if (typeof value === "number") {
    return value < 0 ? 0 : value;
  }
  if (typeof value === "string") {
    const cleaned = value.replaceAll(/[^0-9.\-]/g, "");
    if (cleaned.length === 0) {
      return null;
    }
    const parsed = Number(cleaned);
    return Number.isFinite(parsed) ? Math.max(0, parsed) : null;
  }
  return null;
}

function sanitizeSignedNumber(value: unknown) {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  if (typeof value === "string") {
    const cleaned = value
      .replaceAll(/[,$]/g, "")
      .replaceAll("(", "-")
      .replaceAll(")", "")
      .replaceAll(/[^0-9.\-]/g, "");
    if (cleaned.length === 0) {
      return null;
    }
    const parsed = Number(cleaned);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function sanitizeDate(value: unknown) {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  const text = String(value).trim();
  if (/^\d{4}-\d{2}-\d{2}/.test(text)) {
    return text.slice(0, 10);
  }
  const slashParts = text.split("/");
  if (slashParts.length === 3) {
    const [month, day, year] = slashParts.map((part) => Number(part));
    if ([month, day, year].every(Number.isFinite)) {
      const fullYear = year < 100 ? 2000 + year : year;
      return new Date(Date.UTC(fullYear, month - 1, day))
        .toISOString()
        .slice(0, 10);
    }
  }
  const parsed = new Date(text);
  return Number.isNaN(parsed.getTime())
    ? null
    : parsed.toISOString().slice(0, 10);
}

function sanitizeString(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  const text = String(value).replaceAll(/\s+/g, " ").trim();
  return text.length === 0 ? null : text;
}

function sanitizeLineItemType(value: unknown) {
  const normalized = String(value ?? "other")
    .trim()
    .toLowerCase();
  if (
    normalized === "payment" ||
    normalized === "charge" ||
    normalized === "fee" ||
    normalized === "interest"
  ) {
    return normalized;
  }
  return "other";
}

function sanitizeConfidence(value: unknown) {
  if (typeof value === "number") {
    return Math.max(0, Math.min(1, value));
  }
  return 0;
}

function normalizeLineItem(raw: Record<string, unknown>) {
  const description = sanitizeString(raw.description);
  const amount = sanitizeSignedNumber(raw.amount);
  if (!description || amount === null) {
    return null;
  }
  const payload: StatementLineItemPayload = statementLineItemSchema.parse({
    id: sanitizeString(raw.id),
    date: sanitizeDate(raw.date),
    description,
    amount,
    type: sanitizeLineItemType(raw.type),
    confidence: sanitizeConfidence(raw.confidence),
    currency: sanitizeString(raw.currency)?.toUpperCase() ?? null,
    warnings: Array.isArray(raw.warnings)
      ? raw.warnings.map((warning) => String(warning))
      : [],
  });
  return payload;
}

export function normalizeExtraction(raw: Record<string, unknown>) {
  const summary: ExtractionPayload = extractionSchema.parse({
    issuer_name: sanitizeString(raw.issuer_name),
    title: sanitizeString(raw.title),
    debt_type: sanitizeString(raw.debt_type),
    current_balance: sanitizePositiveNumber(raw.current_balance),
    original_balance: sanitizePositiveNumber(raw.original_balance),
    apr_percentage: sanitizePositiveNumber(raw.apr_percentage),
    minimum_payment: sanitizePositiveNumber(raw.minimum_payment),
    due_date: sanitizeDate(raw.due_date),
    payment_date: sanitizeDate(raw.payment_date),
    payment_amount: sanitizePositiveNumber(raw.payment_amount),
    currency: sanitizeString(raw.currency)?.toUpperCase() ?? null,
    notes: sanitizeString(raw.notes),
    confidence: sanitizeConfidence(raw.confidence),
    last4: sanitizeString(raw.last4),
    raw_detected_labels: Array.isArray(raw.raw_detected_labels)
      ? raw.raw_detected_labels.map((item) => String(item))
      : [],
    statement_start_date: sanitizeDate(raw.statement_start_date),
    statement_end_date: sanitizeDate(raw.statement_end_date),
  });

  const warnings: string[] = [];
  if (summary.confidence < 0.5) {
    warnings.push("low_confidence");
  }
  if (!summary.current_balance && !summary.payment_amount) {
    warnings.push("no_amount_detected");
  }

  const lineItems: StatementLineItemPayload[] = [];
  let droppedLineItems = 0;
  for (const item of Array.isArray(raw.line_items) ? raw.line_items : []) {
    if (item && typeof item === "object") {
      const normalized = normalizeLineItem(item as Record<string, unknown>);
      if (normalized) {
        lineItems.push(normalized);
      } else {
        droppedLineItems += 1;
      }
    } else {
      droppedLineItems += 1;
    }
  }
  if (
    lineItems.length > 0 &&
    !lineItems.some((item) => item.type === "payment")
  ) {
    warnings.push("statement_items_need_review");
  }
  if (droppedLineItems > 0) {
    warnings.push("dropped_malformed_line_items");
  }

  const documentSignals = Array.isArray(raw.document_signals)
    ? raw.document_signals.map((item) => String(item))
    : [];

  return {
    payload: summary,
    summary,
    lineItems,
    documentSignals,
    warnings,
  };
}
