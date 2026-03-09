import type { DocumentClassification } from "../types.js";

export function buildExtractionPrompt(
  classification: DocumentClassification,
  normalizedText: string,
) {
  const classifierHint = {
    creditCardStatement: "credit card statement",
    loanStatement: "loan statement",
    bnplDashboard: "buy now pay later dashboard",
    receipt: "receipt",
    genericBill: "bill",
    genericFinanceScreenshot: "generic finance screenshot",
    unknown: "unknown finance document",
  }[classification];

  return `
You extract debt and payment details from OCR text.
Return strict JSON only.
Classification: ${classifierHint}
Return a JSON object with keys:
- issuer_name
- title
- debt_type
- current_balance
- original_balance
- apr_percentage
- minimum_payment
- due_date
- payment_date
- payment_amount
- currency
- notes
- confidence
- last4
- raw_detected_labels
- statement_start_date
- statement_end_date
- line_items: array of objects with keys date, description, amount, type, confidence, currency, warnings
- document_signals: array of short machine-readable hints
For line_items:
- include only rows that look like statement transactions or payment events
- use type from: payment, charge, fee, interest, other
- return null for uncertain dates instead of guessing
If no line items are present, return an empty array.
Use null when uncertain.
Never return prose.
OCR TEXT:
${normalizedText}
`.trim();
}
