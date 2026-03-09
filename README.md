# DEBT DESTROYER

Privacy-first debt tracking, payoff planning, and document-assisted import built with Flutter for Android, with secure backend-mediated AI extraction.

## What It Includes
- Local-first debt and payment tracking with Drift persistence
- Manual debt CRUD and payment logging
- Dashboard totals, debt-free forecast, and debt distribution
- Strategy simulator for Snowball, Avalanche, and Custom priority ordering
- Scan hub for camera, gallery, receipt, screenshot, and PDF import
- On-device OCR with Google ML Kit
- Secure backend-mediated structured extraction behind explicit per-import consent
- Review-and-confirm import flow before any data is saved
- Google Play subscription billing with backend-verified premium entitlement
- Local reminder scheduling, app-lock flow, privacy settings, and CSV export
- Versioned encrypted full backup and replace-restore with source documents
- Seeded demo data action for local development
- Node/Fastify backend for attestation bootstrap, token rotation, quotas, audit logs, and provider isolation

## Architecture
The app uses a feature-first structure with clear presentation, domain, data, and shared layers:

```text
lib/
  app/              app bootstrap, router, theme
  core/             cross-cutting services, widgets, utils
  features/
    onboarding/
    auth_lock/
    dashboard/
    debts/
    scan_import/
    strategy/
    reports/
    settings/
  shared/           entities, enums, providers, database, repositories
backend/
  src/              Fastify app, auth, extraction, quotas, audit, storage
  sql/              schema bootstrap SQL
  test/             backend integration tests
```

Key architectural choices:
- `flutter_riverpod` for state management and dependency injection
- `go_router` with `StatefulShellRoute` for tabbed navigation
- Drift for offline-first structured data and queryable reporting
- Repository interfaces with Drift-backed implementations
- Strategy, OCR/import, notification, export, analytics, and premium behavior isolated behind services

## Main Packages
App:
- `flutter_riverpod`
- `go_router`
- `drift`
- `flutter_secure_storage`
- `local_auth`
- `camera`
- `image_picker`
- `file_picker`
- `google_mlkit_text_recognition`
- `syncfusion_flutter_pdf`
- `flutter_local_notifications`
- `fl_chart`
- `csv`
- `share_plus`
- `http`
- `flutter_dotenv`

Backend:
- `fastify`
- `zod`
- `pg`
- `ioredis`
- `jsonwebtoken`
- `vitest`

## OCR And Secure Extraction
Import pipeline:
1. Acquire file from camera, gallery, receipt image, screenshot, or PDF.
2. Copy it into app-controlled local storage.
3. Run local OCR first.
4. Classify the document type.
5. If the user explicitly allows cloud extraction for that import, the app bootstraps an install session with the backend.
6. The backend verifies Play Integrity attestation, enforces quota and rate limits, then calls the AI provider using server-held secrets.
7. The backend validates and normalizes the provider response against a strict schema, including optional statement summary fields and line items.
8. The app also runs local statement-summary and line-item heuristics so partial or offline OCR can still reach review safely.
9. The app falls back to heuristic local parsing if the backend is unavailable or denies extraction.
10. The app shows a review screen before saving anything.

Important behavior:
- OCR is local-first.
- Cloud extraction is never silent.
- The Flutter app no longer holds an AI provider key.
- Imports are never auto-saved.
- Manual correction remains available even when OCR or AI parsing is weak.
- Supported document types:
  - credit card statements
  - loan statements
  - BNPL screenshots
  - bill screenshots
  - receipts
  - generic finance screenshots
- Statement imports can now surface:
  - statement summary metadata
  - payment-like line items for selective multi-payment import
  - review-only charge, fee, or interest rows for human verification

## Privacy Model
- Local-first storage for debts, payments, preferences, scenarios, and imported documents
- Full backups are exported as encrypted passphrase-protected archives
- No forced account creation
- Backend is used only for attested cloud extraction and quota/auth decisions
- No silent screenshot or statement upload
- Optional app lock via local device auth
- Configurable relock timeout after backgrounding
- Sensitive-screen screenshot blocking on Android
- Privacy shield overlay for app switcher/background transitions
- Optional hidden balance mode
- Imported documents can be discarded or deleted
- Imported documents use explicit lifecycle states: imported, processed, linked, pending deletion, purged
- Raw OCR text is not persisted in ordinary backend logs; request audit stores hashes/redacted previews
- `hideBalances`, `aiConsentEnabled`, and `appLockEnabled` are mirrored into secure storage and treated as protected preferences

## Backup And Restore
- Full backups are exported as encrypted `.ddbackup` files.
- The backup container is versioned independently from the Drift schema.
- Backups include:
  - debts
  - payments
  - scenarios
  - imported document metadata
  - parsed extractions
  - reminder milestone history
  - portable user preferences, including protected preference values
  - imported source document bytes
- Backups do not include:
  - backend sessions or attestation state
  - local vault root keys
  - notification schedules
  - premium entitlement cache
- Restore flow:
  - pick a `.ddbackup` file
  - enter the passphrase
  - inspect counts and backup version
  - confirm destructive replace restore
- Restore is replace-only in this version. It does not merge into existing local data.

## Financial Projection Model
- Stored `currentBalance` remains the user-recorded truth for each debt
- Payoff projections now use a shared projection engine across dashboard, strategy, and reports
- Supported assumptions include:
  - monthly compound, daily simple, or no-interest accrual
  - fixed minimums, minimum percent rules, and interest-plus-percent rules
  - promotional APR windows
  - monthly recurring fees
  - late fees and penalty APR for projected overdue cycles
  - weekly, biweekly, monthly, and quarterly payment frequencies aggregated into monthly schedule output
- The engine uses integer cents internally and rounds half-up to cents at each accrual, fee, and payment step
- This remains a planning engine, not a lender-statement or legal amortization engine

## Setup
### Prerequisites
- Flutter `3.35.x`
- Android SDK configured
- Java 17 or newer
- Node.js `22+`
- Postgres and Redis for full backend mode

### Configure The Flutter App
Copy `.env.example` to `.env` and set:

```env
BACKEND_BASE_URL=http://10.0.2.2:8787
BACKEND_ENV=development
PLAY_INTEGRITY_PROJECT_NUMBER=
PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=
PLAY_INTEGRITY_PACKAGE_NAME=com.debtdestroyer.app
DEBUG_ATTESTATION_SECRET=
PREMIUM_PRODUCT_ID=premium
PREMIUM_MONTHLY_BASE_PLAN_ID=monthly
PREMIUM_YEARLY_BASE_PLAN_ID=yearly
```

If the backend URL is missing, the app still runs with local OCR and manual review fallback.

### Configure The Backend
Copy [backend/.env.example](/J:/codex/backend/.env.example) into `backend/.env` and set at minimum:

```env
POSTGRES_URL=postgres://postgres:postgres@localhost:5432/debt_destroyer
REDIS_URL=redis://localhost:6379
JWT_ACCESS_SECRET=replace_me_access
JWT_REFRESH_SECRET=replace_me_refresh
GEMINI_API_KEY=replace_me_gemini
ALLOW_DEBUG_ATTESTATION=false
GOOGLE_PLAY_PACKAGE_NAME=com.debtdestroyer.app
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"replace_me"}
PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=123456789
PLAY_INTEGRITY_PACKAGE_NAME=com.debtdestroyer.app
PREMIUM_PRODUCT_ID=premium
PREMIUM_MONTHLY_BASE_PLAN_ID=monthly
PREMIUM_YEARLY_BASE_PLAN_ID=yearly
```

For local development, debug attestation can be enabled explicitly. Production should use a real Play Integrity verdict plus matching package and cloud project configuration.

## Run
Backend:
```bash
cd backend
npm install
npm run dev
```

Flutter app:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Test
Backend:
```bash
cd backend
npm test
npm run build
```

Flutter:
```bash
flutter analyze
flutter test
flutter build apk --debug
```

Targeted regression suites:
```bash
flutter test test/strategy_engine_test.dart
flutter test test/reminder_services_test.dart
flutter test test/data_portability_test.dart
flutter test test/reports_screen_test.dart
flutter test test/data_backups_screen_test.dart
flutter test test/biometric_unlock_screen_test.dart
flutter test test/ocr_processing_screen_test.dart
```

Manual device QA and release sanity steps are documented in [docs/qa/release_checklist.md](/J:/codex/docs/qa/release_checklist.md).

## Development Notes
- Use the `Seed demo data` action in Settings to populate local sample debts and payments.
- Premium entitlement is verified through the backend after Google Play purchase or restore.
- CSV export, PDF import, and scenario saving are premium-gated in both the UI and the verified entitlement snapshot.
- Android Gradle desugaring is enabled for local notifications support.
- Android can request real Play Integrity tokens when `PLAY_INTEGRITY_PROJECT_NUMBER` is configured; debug attestation remains development-only.
- App lock currently uses biometrics or device credentials only; no separate in-app PIN is implemented.
- Reminder orchestration now reconciles from live debts, recent payments, and preferences on app startup plus data changes instead of scheduling only from debt edit flows.
- Settings now expose a dedicated `Data & backups` screen for CSV export, encrypted full backup export, and replace restore.
- Implemented reminder types:
  - due lead reminders (1, 2, or 3 days before)
  - due-today reminders
  - overdue reminders on days 1, 3, and 7
  - weekly Monday morning progress summary
  - one-time progress and paid-off milestones

## Known Limitations
- Production still requires live Google credentials and Play Console setup for Play Integrity and Google Play Billing verification
- Aggregate dashboard totals assume a single display currency when multiple debt currencies exist
- Import parsing is conservative and still depends on manual review for accuracy
- Multi-line statement import focuses on payment-like rows; purchase and fee rows are shown for review context but are not bulk-posted as debts or charges
- OCR-wrapped rows, missing years, and heavily degraded screenshots can still require manual correction on the review screen
- Debt balances are still user-recorded values; the app does not fully reconstruct live balances from historical statements or lender-specific ledgers
- Camera and biometric flows are implemented for Android but are not covered by full device E2E tests in this repo
- Screenshot blocking and recents-thumbnail masking are Android-first; exact system-recents behavior may vary by OEM/device version
- Weekly summary content is privacy-conscious and regenerated on app reconciliation, but it can become stale if the app is not reopened before the next scheduled delivery
- Automatic rehydration after device reboot is not implemented with a boot receiver in this repo; reminders are restored on next app launch
- Restore is replace-only in this version; it does not merge duplicate local records
- Backup passphrases are not recoverable by the app
- Postgres and Redis adapters are implemented for backend deployment, but local tests use in-memory stores

## Roadmap
- Multiple saved strategy comparisons with deeper scenario analysis
- Richer statement line-item extraction
- Household/shared debt mode
- Vendor-backed analytics and crash reporting adapters
