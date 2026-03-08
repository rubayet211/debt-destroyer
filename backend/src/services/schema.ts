import { extractionSchema, type ExtractionPayload } from '../types.js';

function sanitizeNumber(value: unknown) {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  if (typeof value === 'number') {
    return value < 0 ? 0 : value;
  }
  if (typeof value === 'string') {
    const cleaned = value.replaceAll(/[^0-9.\-]/g, '');
    if (cleaned.length === 0) {
      return null;
    }
    const parsed = Number(cleaned);
    return Number.isFinite(parsed) ? Math.max(0, parsed) : null;
  }
  return null;
}

function sanitizeDate(value: unknown) {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  const text = String(value).trim();
  if (/^\d{4}-\d{2}-\d{2}/.test(text)) {
    return text.slice(0, 10);
  }
  const slashParts = text.split('/');
  if (slashParts.length === 3) {
    const [month, day, year] = slashParts.map((part) => Number(part));
    if ([month, day, year].every(Number.isFinite)) {
      return new Date(Date.UTC(year, month - 1, day))
        .toISOString()
        .slice(0, 10);
    }
  }
  const parsed = new Date(text);
  return Number.isNaN(parsed.getTime()) ? null : parsed.toISOString().slice(0, 10);
}

export function normalizeExtraction(raw: Record<string, unknown>) {
  const payload: ExtractionPayload = extractionSchema.parse({
    issuer_name: raw.issuer_name ? String(raw.issuer_name) : null,
    title: raw.title ? String(raw.title) : null,
    debt_type: raw.debt_type ? String(raw.debt_type) : null,
    current_balance: sanitizeNumber(raw.current_balance),
    original_balance: sanitizeNumber(raw.original_balance),
    apr_percentage: sanitizeNumber(raw.apr_percentage),
    minimum_payment: sanitizeNumber(raw.minimum_payment),
    due_date: sanitizeDate(raw.due_date),
    payment_date: sanitizeDate(raw.payment_date),
    payment_amount: sanitizeNumber(raw.payment_amount),
    currency: raw.currency ? String(raw.currency).toUpperCase() : null,
    notes: raw.notes ? String(raw.notes) : null,
    confidence:
      typeof raw.confidence === 'number'
        ? Math.max(0, Math.min(1, raw.confidence))
        : 0,
    last4: raw.last4 ? String(raw.last4) : null,
    raw_detected_labels: Array.isArray(raw.raw_detected_labels)
      ? raw.raw_detected_labels.map((item) => String(item))
      : [],
  });

  const warnings: string[] = [];
  if (payload.confidence < 0.5) {
    warnings.push('low_confidence');
  }
  if (!payload.current_balance && !payload.payment_amount) {
    warnings.push('no_amount_detected');
  }

  return { payload, warnings };
}
