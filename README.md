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
6. The backend verifies attestation, enforces quota and rate limits, then calls the AI provider using server-held secrets.
7. The backend validates and normalizes the provider response against a strict schema.
8. The app falls back to heuristic local parsing if the backend is unavailable or denies extraction.
9. The app shows a review screen before saving anything.

Important behavior:
- OCR is local-first.
- Cloud extraction is never silent.
- The Flutter app no longer holds an AI provider key.
- Imports are never auto-saved.
- Manual correction remains available even when OCR or AI parsing is weak.

## Privacy Model
- Local-first storage for debts, payments, preferences, scenarios, and imported documents
- No forced account creation
- Backend is used only for attested cloud extraction and quota/auth decisions
- No silent screenshot or statement upload
- Optional app lock via local device auth
- Optional hidden balance mode
- Imported documents can be discarded or deleted
- Raw OCR text is not persisted in ordinary backend logs; request audit stores hashes/redacted previews

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
DEBUG_ATTESTATION_SECRET=
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
ALLOW_DEBUG_ATTESTATION=true
GOOGLE_PLAY_PACKAGE_NAME=com.debtdestroyer.app
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"replace_me"}
```

For local development, debug attestation is enabled so the app can bootstrap without a real Play Integrity verdict.

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

## Development Notes
- Use the `Seed demo data` action in Settings to populate local sample debts and payments.
- Premium entitlement is verified through the backend after Google Play purchase or restore.
- CSV export, PDF import, and scenario saving are premium-gated in both the UI and the verified entitlement snapshot.
- Android Gradle desugaring is enabled for local notifications support.
- Android debug builds currently use a method-channel debug attestation token for backend bootstrap.

## Known Limitations
- Real Play Integrity verification is still debug-bypassed in local builds; production attestation backend verification needs live Google configuration
- Aggregate dashboard totals assume a single display currency when multiple debt currencies exist
- Import parsing is conservative and still depends on manual review for accuracy
- Camera and biometric flows are implemented for Android but are not covered by full device E2E tests in this repo
- Postgres and Redis adapters are implemented for backend deployment, but local tests use in-memory stores

## Roadmap
- Full production Play Integrity verification
- Multiple saved strategy comparisons with deeper scenario analysis
- Richer statement line-item extraction
- Encrypted local backups and restore
- Household/shared debt mode
- Vendor-backed analytics and crash reporting adapters
