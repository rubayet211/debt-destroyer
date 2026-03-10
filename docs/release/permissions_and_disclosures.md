# Permissions and Disclosures Checklist

## Android permissions in scope
- `CAMERA`
  - reason: capture statements, bills, receipts, and screenshots directly in-app
- `POST_NOTIFICATIONS`
  - reason: due reminders, overdue reminders, weekly summary, and milestone notifications
- `INTERNET`
  - reason: backend-mediated cloud extraction, billing verification, attestation, and entitlement refresh

## Feature disclosures
- Biometric / device credential auth:
  - used only for local app unlock
  - no custom PIN in this repo
- Screenshot blocking:
  - Android-only sensitive-screen protection through `FLAG_SECURE`
- Billing:
  - Google Play subscriptions with backend entitlement verification
- Backup:
  - full backup includes source documents and is encrypted with a user-entered passphrase

## Store listing disclosures to confirm before launch
- AI-assisted extraction is optional and consent-driven
- Financial projections are planning tools, not lender-statement replacements
- Restore is replace-only, not merge-based
- Notification delivery timing may vary by device/OEM settings
