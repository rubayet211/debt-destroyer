import type { DocumentClassification } from '../types.js';

export function buildExtractionPrompt(
  classification: DocumentClassification,
  normalizedText: string,
) {
  const classifierHint = {
    creditCardStatement: 'credit card statement',
    loanStatement: 'loan statement',
    bnplDashboard: 'buy now pay later dashboard',
    receipt: 'receipt',
    genericBill: 'bill',
    genericFinanceScreenshot: 'generic finance screenshot',
    unknown: 'unknown finance document',
  }[classification];

  return `
You extract debt and payment details from OCR text.
Return strict JSON only.
Classification: ${classifierHint}
JSON keys:
issuer_name, title, debt_type, current_balance, original_balance, apr_percentage, minimum_payment, due_date, payment_date, payment_amount, currency, notes, confidence, last4, raw_detected_labels.
Use null when uncertain.
Never return prose.
OCR TEXT:
${normalizedText}
`.trim();
}
