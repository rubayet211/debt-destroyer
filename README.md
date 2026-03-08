# DEBT DESTROYER

Privacy-first debt tracking, payoff planning, and document-assisted import built with Flutter for Android.

## What It Includes
- Local-first debt and payment tracking with Drift persistence
- Manual debt CRUD and payment logging
- Dashboard totals, debt-free forecast, and debt distribution
- Strategy simulator for Snowball, Avalanche, and Custom priority ordering
- Scan hub for camera, gallery, receipt, screenshot, and PDF import
- On-device OCR with Google ML Kit
- Optional Gemini-assisted structured extraction behind explicit per-import consent
- Review-and-confirm import flow before any data is saved
- Premium entitlement abstraction with a local demo unlock
- Local reminder scheduling, app-lock flow, privacy settings, and CSV export
- Seeded demo data action for local development

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
```

Key architectural choices:
- `flutter_riverpod` for state management and dependency injection
- `go_router` with `StatefulShellRoute` for tabbed navigation
- Drift for offline-first structured data and queryable reporting
- Repository interfaces with Drift-backed implementations
- Strategy, OCR/import, notification, export, analytics, and premium behavior isolated behind services

## Main Packages
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

## OCR And AI Extraction
Import pipeline:
1. Acquire file from camera, gallery, receipt image, screenshot, or PDF.
2. Copy it into app-controlled local storage.
3. Run local OCR first.
4. Classify the document type.
5. If the user explicitly allows cloud parsing for that import, send normalized OCR text to Gemini.
6. If Gemini is unavailable, fall back to heuristic local parsing.
7. Validate and sanitize extracted values.
8. Show a review screen before saving anything.

Important behavior:
- OCR is local-first.
- Cloud AI is never silent.
- Imports are never auto-saved.
- Manual correction remains available even when OCR or AI parsing is weak.

## Privacy Model
- Local-first storage for debts, payments, preferences, scenarios, and imported documents
- No forced account creation
- No backend sync in this MVP
- No silent screenshot or statement upload
- Optional app lock via local device auth
- Optional hidden balance mode
- Imported documents can be discarded or deleted

## Setup
### Prerequisites
- Flutter `3.35.x`
- Android SDK configured
- Java 17 or newer

### Configure Gemini
Copy `.env.example` to `.env` and set:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

If the key is missing, the app still runs with local OCR and manual review fallback.

## Run
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Test
```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Development Notes
- Use the `Seed demo data` action in Settings to populate local sample debts and payments.
- Premium behavior is intentionally mocked through a local entitlement store.
- CSV export, PDF import, and scenario saving are premium-gated in the UI.
- Android Gradle desugaring is enabled for local notifications support.

## Known Limitations
- No real Google Play Billing integration yet
- No backend sync, household sharing, or encrypted backup transport yet
- Aggregate dashboard totals assume a single display currency when multiple debt currencies exist
- Import parsing is conservative and still depends on manual review for accuracy
- Camera and biometric flows are implemented for Android but are not covered by full device E2E tests in this repo

## Roadmap
- Real Play Billing integration
- Multiple saved strategy comparisons with deeper scenario analysis
- Richer statement line-item extraction
- Encrypted local backups and restore
- Household/shared debt mode
- Vendor-backed analytics and crash reporting adapters
