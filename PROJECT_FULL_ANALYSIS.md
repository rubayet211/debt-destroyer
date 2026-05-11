# PROJECT_FULL_ANALYSIS

**Last updated:** 2026-05-11  
**Repository:** `j:\codex`  
**Project shape:** Flutter Android app + Node.js/Fastify backend  
**Evidence basis:** Direct code reads, backend tests, build files, deployment files, and route/service inspection

## Confidence Legend

- **Confirmed** means the behavior was read directly from source or backed by tests.
- **Inferred** means the behavior was deduced from routing, provider wiring, naming, or surrounding code.
- **Unknown** means the repo was not fully inspected in that area, so the document avoids pretending certainty.

This file is the code-grounded, system-level map of the repository. It intentionally favors architecture, runtime behavior, data flow, deployment, and operational risk over marketing language.

## 1. Project Overview

**Debt Destroyer** is a privacy-first debt tracking and payoff planning product built as a full-stack mobile system. The primary client is a Flutter Android app, and the backend is a TypeScript/Fastify API that handles attestation, JWT bootstrap, billing verification, quota enforcement, and optional cloud extraction for scanned documents.

The repo is not “just a Flutter app with an API on the side.” It is a coupled system with a local-first mobile data model, a secure device session model, and a backend that exists specifically to support trust-sensitive features such as Play Integrity attestation, premium entitlement verification, and AI-assisted document extraction.

The strongest product themes visible in code are:

- Local encrypted storage for debt and document data
- Biometric / app-lock / privacy-shield controls
- OCR-assisted statement import
- Payoff strategy simulation and reporting
- Google Play billing-backed premium feature gating
- Explicit retention and purge controls for imported material

The key top-level areas are:

- [lib/main.dart](lib/main.dart)
- [lib/app/bootstrap.dart](lib/app/bootstrap.dart)
- [lib/app/app.dart](lib/app/app.dart)
- [lib/app/router/app_router.dart](lib/app/router/app_router.dart)
- [lib/shared/providers/app_providers.dart](lib/shared/providers/app_providers.dart)
- [lib/shared/data/local/app_database.dart](lib/shared/data/local/app_database.dart)
- [backend/src/app.ts](backend/src/app.ts)
- [backend/src/config.ts](backend/src/config.ts)
- [backend/src/services/storage.ts](backend/src/services/storage.ts)
- [backend/src/services/attestation.ts](backend/src/services/attestation.ts)
- [backend/src/services/billing.ts](backend/src/services/billing.ts)
- [backend/src/services/rate-limit.ts](backend/src/services/rate-limit.ts)

## 2. Executive Summary

The app solves a specific financial workflow problem: users want to track debts, understand payoff order, import statements with less manual entry, and keep sensitive financial data locked down on device. The mobile side gives them the UI, local encrypted persistence, reminders, strategy simulation, backup/restore, and privacy controls. The backend is the security and entitlement layer, not the source of truth for everyday debt data.

The implementation is notably opinionated:

- The app is Android-first and built around product flavors (`dev`, `staging`, `prod`).
- Core data lives locally in encrypted SQLite via Drift + SQLCipher.
- Imported documents are retained in an encrypted vault, with configurable purge behavior.
- Cloud processing is explicitly opt-in per import.
- Premium access is feature-based, not just binary “premium yes/no.”

There is also visible documentation drift in a few places. For example, [lib/features/settings/presentation/settings_screens.dart](lib/features/settings/presentation/settings_screens.dart) includes a help/about experience that still frames some backup and roadmap behavior in language that is looser than the actual implementation. The code is more complete than the static copy in some screens suggests.

## 3. Tech Stack Summary

### Frontend

| Area | Evidence | Notes |
|---|---|---|
| Framework | [pubspec.yaml](pubspec.yaml) | Flutter `^3.9.2` SDK constraint |
| State management | Riverpod | App-wide provider graph in [lib/shared/providers/app_providers.dart](lib/shared/providers/app_providers.dart) |
| Routing | `go_router` | Central route table in [lib/app/router/app_router.dart](lib/app/router/app_router.dart) |
| Local DB | Drift + SQLCipher | Encrypted SQLite schema in [lib/shared/data/local/app_database.dart](lib/shared/data/local/app_database.dart) |
| Auth | `local_auth`, `flutter_secure_storage` | Biometrics plus secure key/session storage |
| Import / capture | `camera`, `image_picker`, `file_picker`, `google_mlkit_text_recognition`, `syncfusion_flutter_pdf` | Camera, gallery, PDF, OCR | 
| Charts / reporting | `fl_chart` | Reports dashboard and projections |
| Notifications | `flutter_local_notifications`, `timezone` | Reminders and milestone alerts |
| Billing | `in_app_purchase`, `in_app_purchase_android` | Premium entitlement flow |
| Export / sharing | `share_plus`, `csv`, `archive` | CSV export, backup packaging, share sheets |
| Telemetry | Firebase core/analytics/crashlytics | Wrapped by app services and config flags |
| Utilities | `http`, `intl`, `uuid`, `google_fonts`, `flutter_dotenv`, `cryptography` | Network, formatting, IDs, theming, env, encryption |

### Backend

| Area | Evidence | Notes |
|---|---|---|
| Framework | `fastify` | API server in [backend/src/app.ts](backend/src/app.ts) |
| Validation | `zod` | Config and request schema discipline in [backend/src/config.ts](backend/src/config.ts) and [backend/src/types.ts](backend/src/types.ts) |
| Database | `pg` | PostgreSQL-backed persistence and pool tuning |
| Cache / rate limiting | `ioredis` | Redis is primary in prod; memory fallback exists for local dev |
| Auth | `jsonwebtoken` | Access and refresh token model |
| AI provider | `googleapis` | Gemini-based extraction integration |
| Build/runtime | TypeScript + `tsx` + `vitest` | Build, run, and test stack |
| Containerization | Docker | [backend/Dockerfile](backend/Dockerfile) |

### Android / Native

| Area | Evidence | Notes |
|---|---|---|
| Build system | Gradle Kotlin DSL | [android/app/build.gradle.kts](android/app/build.gradle.kts) |
| Flavors | `dev`, `staging`, `prod` | Product flavoring is explicit |
| Signing | `key.properties` or env vars | `ANDROID_KEYSTORE_*` fallback is supported |
| Integrity | Play Integrity dependency | `com.google.android.play:integrity` is included |

## 4. Dependency Analysis

### Core runtime dependencies on the Flutter side

The Flutter app depends heavily on a small set of core packages:

- `flutter_riverpod` for almost all state and DI orchestration
- `go_router` for route structure and guarded navigation
- `drift` + `sqlcipher_flutter_libs` for local persistence and encryption
- `flutter_secure_storage` for security/session state that should survive process death but stay device-bound
- `local_auth` for unlock and biometric security
- `camera` / `image_picker` / `file_picker` / `google_mlkit_text_recognition` / `syncfusion_flutter_pdf` for import
- `flutter_local_notifications` and `timezone` for reminders
- `in_app_purchase` for premium purchase flow
- `share_plus` and `archive` for export and packaging

### Core runtime dependencies on the backend side

The backend is built around a narrower surface:

- `fastify` for routing, validation hooks, and lifecycle handling
- `zod` for schema-safe config and payload validation
- `pg` for PostgreSQL storage
- `ioredis` for rate limiting and short-lived state
- `jsonwebtoken` for token issuance/verification
- `googleapis` for Play Integrity and Gemini-related API interactions
- `dotenv` for environment bootstrap

### Dependency observations

- **Confirmed:** The dependency list is aligned with the actual features in the app; the imports and tests support the package choices.
- **Confirmed:** The backend container is intentionally slim, based on Node 22 slim and running as a non-root user. See [backend/Dockerfile](backend/Dockerfile).
- **Inferred:** There is no evidence of a broad plugin zoo. The project is relatively disciplined in external surface area for the amount of functionality it offers.
- **Unknown:** A full dead-code / unused-dependency audit was not completed. No repository-wide package pruning analysis was performed.

## 5. Architecture Overview

### Design principles visible in code

1. **Local-first data ownership**
   - Debts, payments, scenarios, reminders, preferences, and imported documents live locally in encrypted storage.

2. **Backend-mediated trust operations**
   - The backend handles attestation, token bootstrap, entitlement verification, restore checks, and extraction.

3. **Explicit privacy controls**
   - App lock, screenshot protection, privacy shield, raw OCR retention, and data purge controls are first-class settings.

4. **Feature-first organization**
   - The Flutter app is grouped by feature rather than by abstract technical layer alone.

5. **Reactive state with clear persistence boundaries**
   - Riverpod providers bridge the UI to repositories, and Drift repositories bridge to storage.

### High-level flow

```text
User action
  -> Flutter screen
  -> Riverpod provider / controller
  -> Service or repository
  -> Drift / secure storage / vault / HTTP client
  -> Local DB or backend API
```

### Trust and control boundaries

- The app uses [lib/app/app.dart](lib/app/app.dart) to coordinate lifecycle-aware security behavior.
- The router in [lib/app/router/app_router.dart](lib/app/router/app_router.dart) includes protected paths such as unlock, privacy upgrade, and data protection recovery.
- The backend is stateless with respect to app content but stateful with respect to installs, challenges, entitlements, quotas, and rate limits.
- App security state is session-oriented and persisted through secure storage, not through the backend.

### Important architectural pattern

The app does not rely on a single monolithic “auth state.” Instead, several states coexist:

- device unlock state
- app lock / privacy shield state
- entitlement state
- backend bootstrap session state
- local database encryption / migration state

That separation is important because the product needs to answer different questions at different times: “Is this the same install?”, “Is the user allowed to open the app?”, “Can the user use this premium feature?”, and “Is this imported document still allowed to stay on disk?”

## 6. Folder and File Structure Breakdown

### Root level

```text
lib/                Flutter application
backend/            Fastify API + SQL + tests + Dockerfile
android/            Android project wrapper, flavors, signing, integrity dependency
docs/               Supplemental QA / release / planning material
test/               Flutter widget and service tests
analysis_options.yaml
pubspec.yaml
render.yaml
README.md
```

### Flutter app layout

```text
lib/
  main.dart
  app/
    bootstrap.dart
    app.dart
    router/
  core/
    services/
    widgets/
    utils/
    logging/
    errors/
  features/
    onboarding/
    auth_lock/
    dashboard/
    debts/
    scan_import/
    strategy/
    reports/
    settings/
  shared/
    data/
    enums/
    models/
    providers/
```

### Backend layout

```text
backend/
  src/
    app.ts
    config.ts
    server.ts
    types.ts
    utils.ts
    services/
  sql/
    001_init.sql
  test/
```

### What each top-level area means

- **lib/app** is startup, routing, lifecycle, and top-level security coordination.
- **lib/core** contains cross-cutting app services, logging, formatting, and generic widgets.
- **lib/features** contains the domain screens and their supporting logic.
- **lib/shared** contains reusable models, enums, repository abstractions, database wiring, and providers.
- **backend/src** contains the security-sensitive API behavior.
- **backend/test** is not trivial scaffolding; it documents the intended API behavior and hardening constraints.

## 7. Product Category and User Problem

### Category

This is a **personal finance / debt management / payoff planning** product with document import and secure local storage as differentiators.

### Problem the app solves

The app is for users who have multiple debts and want a practical way to:

- understand what they owe
- prioritize payments
- reduce manual data entry
- keep financial data private
- get reminders and visual progress feedback
- back up and restore their data without losing control of it

### Why this product exists

The code suggests the app is designed to remove the three biggest pain points in debt tracking:

1. Manual entry is tedious, so OCR and PDF import reduce friction.
2. Financial data is sensitive, so local encryption and app security matter.
3. Debt payoff feels abstract, so strategy simulation and charts make progress visible.

### Likely user segments

- Users with one or more credit cards, loans, or BNPL balances
- Privacy-conscious users who want local storage instead of SaaS-led aggregation
- Users who want reminders and payoff projections, not just a balance table
- Power users who care about premium reporting, export, and scenario analysis

## 8. Primary User Roles and Flows

### Role 1: First-time user

Typical flow:

1. Launch app
2. Complete onboarding
3. Set preferences such as currency, theme, and privacy/security defaults
4. Add debts manually or import a statement
5. See a dashboard snapshot and payoff projection

### Role 2: Returning daily or weekly user

Typical flow:

1. Unlock app if needed
2. Review dashboard and upcoming due items
3. Log a payment or edit a debt
4. Check reports or strategy changes
5. Let reminders continue in the background

### Role 3: Privacy-sensitive user

Typical flow:

1. Enable app lock / screenshot protection / privacy shield
2. Use local OCR only or approve cloud extraction explicitly per import
3. Configure retention and purge settings
4. Create encrypted backups or restore from an encrypted archive

### Role 4: Premium user

Typical flow:

1. Verify subscription through Google Play
2. Unlock premium-only features like PDF import, CSV export, scenario saving, advanced reports, advanced strategy comparison, unlimited scans, and premium themes
3. Restore entitlements on new devices or reinstalls

## 9. Full Feature Inventory

### Onboarding and app startup

- Splash/bootstrap initialization
- Environment loading and telemetry setup
- Camera discovery on startup
- Onboarding completion tracking
- Data protection upgrade explainer
- Secure storage recovery path

### Dashboard and overview

- Snapshot of total outstanding debt
- Total paid so far
- Monthly minimum total
- Projected debt-free date
- Interest expected and interest saved vs baseline
- Upcoming due debts
- Recent payments
- Mixed-currency indicator

### Debt management

- Add debt
- Edit debt
- View debt details
- Archive and restore debts
- Mark debts paid off
- Delete debts
- Add payments
- View payment history

### Scan / import workflow

- Camera capture
- Gallery import
- Receipt import
- PDF statement import
- Local OCR processing
- Cloud extraction opt-in
- Review and confirm extracted data
- Duplicate detection during finalization
- Save extracted items as debts or payments

### Strategy and payoff planning

- Snowball / avalanche / custom strategy analysis
- Projection schedule and payoff ordering
- Scenario simulation
- Baseline comparison
- Interest / time tradeoff review

### Reporting

- Date-range filters
- Bar, line, and pie charts
- Payment aggregation
- Debt breakdown by type
- Projection summary
- CSV export and sharing

### Notifications

- Due reminders
- Overdue reminders
- Weekly summary reminders
- Milestone notifications
- Notification permissions and scheduling controls

### Security and privacy

- App lock
- Biometric unlock
- Screenshot protection
- Privacy shield on app switcher
- Raw OCR retention controls
- Document retention mode and purge controls
- Secure storage migration / recovery

### Backup and portability

- Encrypted full backups
- Backup inspection / validation
- Restore from encrypted archive
- Document vault migration
- Best-effort purge of plaintext remnants

### Premium / monetization

Based on the `PremiumFeature` enum in [lib/shared/enums/app_enums.dart](lib/shared/enums/app_enums.dart), premium capabilities currently include:

- unlimitedScans
- pdfImport
- advancedReports
- csvExport
- scenarioSaving
- advancedStrategyComparison
- premiumThemes

### Backend / operational features

- Install bootstrap challenge and verification
- JWT access / refresh token issuance
- Capabilities endpoint for entitlement and quota state
- Billing verify / restore endpoints
- Extraction endpoint with quota reservation
- Redis-backed rate limiting with memory fallback for local development
- Postgres pool tuning and cleanup jobs

## 10. Screen and Route Map

The router in [lib/app/router/app_router.dart](lib/app/router/app_router.dart) is a central artifact because it shows the actual product surface better than the README does.

### Core routes

| Route | Screen / Purpose | Notes |
|---|---|---|
| `/` | Splash / bootstrap handoff | Entry point before onboarding or shell |
| `/onboarding` | Onboarding flow | Initial user setup and product introduction |
| `/unlock` | App unlock | Biometric / device-auth gate |
| `/privacy-upgrade` | [PrivacyUpgradeScreen](lib/features/settings/presentation/data_protection_screens.dart) | Explains encrypted local storage upgrade |
| `/data-protection-recovery` | [DataProtectionRecoveryScreen](lib/features/settings/presentation/data_protection_screens.dart) | Recovery path if encrypted local storage init fails |
| `/dashboard` | Main dashboard shell tab | Snapshot and quick actions |
| `/debts` | Debt list shell tab | Primary debt management surface |
| `/scan` | Import shell tab | OCR / PDF / review workflows |
| `/strategy` | Strategy shell tab | Payoff planning and simulation |
| `/settings` | Settings shell tab | Preferences, security, premium, help |

### Debt routes

| Route | Screen / Purpose | Notes |
|---|---|---|
| `/debts/add` | Add debt | Manual debt entry |
| `/debts/:id` | Debt detail | Core debt profile and related actions |
| `/debts/:id/edit` | Edit debt | Update debt terms and metadata |
| `/debts/:id/add-payment` | Add payment | Payment logging path |
| `/debts/:id/payments` | Payment history | Debt-specific payment history |

### Scan routes

| Route | Screen / Purpose | Notes |
|---|---|---|
| `/scan/camera` | Camera scan | Capture source documents |
| `/scan/processing` | OCR / extraction processing | Can route local-only or cloud-assisted processing |
| `/scan/review` | Review / confirm import | Final review and duplicate handling |

### Reporting and settings routes

| Route | Screen / Purpose | Notes |
|---|---|---|
| `/reports` | Reporting dashboard | Charts, summaries, CSV export |
| `/notifications` | Notification settings | Reminder configuration |
| `/backups` | Backup / restore | Encrypted export and restore flows |
| `/premium` | Premium upsell / feature matrix | Shows unlocked feature set |
| `/security` | Security & privacy | App lock, shields, OCR retention, purge behavior |
| `/help` | Help / about | App info and support style content |

### Routing observations

- The app uses a tabbed shell for the major feature areas.
- Guarded routes exist for security-sensitive or recovery states.
- The route map itself is a major product spec: it proves the app is broader than a simple tracker.

## 11. Backend API and Service Breakdown

The backend is the system’s security, entitlement, and cloud-extraction layer. It is not a mirror of the mobile local database.

### Main API file

- [backend/src/app.ts](backend/src/app.ts) is the primary Fastify application. It contains:
  - health endpoints
  - bootstrap challenge and verification
  - token refresh
  - capability lookup
  - billing verify / restore
  - extraction
  - quota reservation logic
  - error mapping and rate-limit handling

### Key service files

| File | Responsibility | Notes |
|---|---|---|
| [backend/src/config.ts](backend/src/config.ts) | Environment validation and config loading | Hardens production requirements with Zod |
| [backend/src/services/storage.ts](backend/src/services/storage.ts) | App store / memory store / Postgres store | Persists challenges, refresh tokens, quota, entitlement, history, audit, and rate limit state |
| [backend/src/services/attestation.ts](backend/src/services/attestation.ts) | Play Integrity token handling | Decodes integrity tokens and validates install bootstrap |
| [backend/src/services/billing.ts](backend/src/services/billing.ts) | Google Play purchase verification | Maps purchase states into entitlement state |
| [backend/src/services/rate-limit.ts](backend/src/services/rate-limit.ts) | Rate limiting | Redis preferred, in-memory fallback in local environments |
| [backend/src/server.ts](backend/src/server.ts) | Process startup and shutdown | Signal handling and graceful shutdown |
| [backend/src/utils.ts](backend/src/utils.ts) | Shared HTTP / error helpers | Small support layer |

### Behavior confirmed by backend tests

The test suite in [backend/test](backend/test) confirms the following behaviors:

- invalid payloads produce structured validation errors
- `/health/live` and `/health/ready` return expected status payloads
- missing Gemini configuration makes readiness fail
- bootstrap challenge endpoints are rate-limited
- Redis startup failure falls back to memory rate limiting in local development
- production Redis failure is treated as a startup failure
- billing verification persists active entitlements
- billing restore selects the active entitlement and ignores expired ones
- unexpected billing product IDs are rejected

### Operational contract

The backend is intentionally strict in production:

- Postgres is required outside dev/test.
- Redis is required outside dev/test.
- Gemini is required outside dev/test.
- Google Play service account JSON is required outside dev/test.
- Debug attestation is only allowed in local/test environments.

## 12. Data Model and Persistence

### Local app database

The local mobile database is in [lib/shared/data/local/app_database.dart](lib/shared/data/local/app_database.dart). It is encrypted, Drift-based, and versioned. The summary from inspection is:

- schema version 7
- encrypted SQLCipher-backed persistence
- debt, payment, imported document, parsing, reminder, scenario, preferences, and subscription-related tables
- migration logic that handles secure storage and document retention concerns

### Key local concepts

| Concept | Where it appears | Why it matters |
|---|---|---|
| Debts | `Debt` model and debt tables | Core financial state |
| Payments | `Payment` model and payment tables | Tracks user actions and reporting |
| Imported documents | import/document tables | Holds OCR / PDF source metadata and retention state |
| Parsed extractions | parsing tables and import services | Captures extraction results and review state |
| Reminder events / rules | reminder tables and models | Drives notifications and milestone logic |
| Scenarios | scenario tables and strategy models | Stores simulation outputs when enabled |
| Preferences | app preferences table and secure stores | Stores user privacy and app behavior choices |
| Subscription state | subscription model and backend sync | Local view of entitlements and unlocked features |

### Data protection and vault storage

The mobile app goes beyond just encrypting the SQLite database. It also has a secure vault concept:

- [lib/core/services/vault_services.dart](lib/core/services/vault_services.dart) encrypts imported documents before storing them on disk.
- The vault uses device-bound key material and AES-GCM.
- There are explicit purge paths for both encrypted stored documents and legacy plaintext files.
- [lib/core/services/portability_services.dart](lib/core/services/portability_services.dart) can package backups, inspect them, and restore them.

### Backup and restore model

The backup system is real, not aspirational:

- backups are encrypted with a passphrase
- backup inspection is possible before restore
- restore rehydrates debts, payments, documents, scenarios, reminders, and preferences
- restore attempts staged cleanup if vault re-encryption fails midway

### Important detail

The data model is not just a database schema. It is a privacy architecture: encrypted local database, encrypted document vault, and backup passphrase protection all work together.

## 13. Security and Privacy Model

This is one of the strongest parts of the codebase.

### App-level security

The app security stack includes:

- biometric unlock through `local_auth`
- secure storage for session and lock state
- screenshot protection
- privacy shield on app switcher / background state
- app relock timing controls

These behaviors are orchestrated through [lib/app/app.dart](lib/app/app.dart), [lib/core/services/app_services.dart](lib/core/services/app_services.dart), and related providers.

### Security settings visible in the app

The settings UI exposes toggles for:

- app lock
- screenshot protection
- privacy shield on app switcher
- hide balances
- AI consent
- raw OCR retention
- document retention mode
- purge failed imports

### Backend trust model

The backend security model includes:

- Play Integrity attestation
- bootstrap challenge / verify
- JWT access and refresh tokens
- quota reservations for extraction
- endpoint-specific rate limiting
- explicit production environment checks

### AI and privacy

The app does not silently send everything to the backend:

- local OCR runs on device
- cloud extraction is asked for per import
- AI processing appears tied to explicit consent and quota state
- the app stores preferences that track whether the user has consented to AI processing

### Logging discipline

[lib/core/logging/app_logger.dart](lib/core/logging/app_logger.dart) shows a deliberately defensive logging approach. Sensitive keys and sensitive values are redacted or blocked, and the logger summarizes data instead of dumping raw payloads.

### Privacy-related risk that is still worth noting

The app has strong controls, but it also processes highly sensitive data. That means the product depends on the correctness of:

- local storage encryption
- vault key management
- retention / purge behavior
- backend attestation and token checks
- billing state synchronization

Those areas are not “nice to have”; they are part of the trust model.

## 14. State Management and Data Flow

### Frontend state shape

The app uses Riverpod as its main state layer. The provider graph in [lib/shared/providers/app_providers.dart](lib/shared/providers/app_providers.dart) acts as the dependency injection spine for:

- secure storage
- app database
- backend config and API access
- preferences
- debts and payments repositories
- OCR/import services
- reminders and notification services
- billing / entitlement services
- dashboard snapshot generation
- app security coordination

### Data flow pattern

```text
Screen
  -> Provider
  -> Repository / service
  -> Local DB / secure storage / network
  -> Provider update
  -> Rebuild screen
```

### The interesting part

The app avoids a lot of ad hoc global state by making providers the shared vocabulary. That is especially valuable here because security state, entitlement state, and finance state all need to coexist without contaminating each other.

### Dashboard and summary state

[lib/shared/models/dashboard_snapshot.dart](lib/shared/models/dashboard_snapshot.dart) defines the main dashboard summary shape. It contains:

- outstanding debt
- total paid so far
- minimum monthly total
- projected debt-free date
- expected interest
- savings compared with baseline
- upcoming due debts
- recent payments
- mixed-currency flag

### Reminder orchestration

[lib/core/services/app_services.dart](lib/core/services/app_services.dart) includes the reminder planning and reconciliation logic. Reminder state is not static; it is recomputed from preferences, debts, payments, and prior events.

## 15. UI and Presentation Layer

The presentation layer is utility-heavy rather than ornamental. It is trying to make a financial workflow understandable and low-friction.

### Shared UI primitives

The app uses reusable widgets such as:

- `AppPage`
- `AppCard`
- `SectionHeader`
- `EmptyStateView`
- `LoadingPane`
- `AppErrorState`

These are used widely across dashboard, debts, scan, reports, and settings screens.

### Visual language

The interface emphasizes:

- list views for debt and import management
- card-based summaries for overview content
- charts for reporting and projection
- bottom sheets for privacy consent and import choices
- inline toggles for settings

### Important screen clusters

#### Debts

[lib/features/debts/presentation/debts_screens.dart](lib/features/debts/presentation/debts_screens.dart) covers:

- debt detail
- add/edit debt
- add payment
- payment history
- archive / restore / delete / mark paid off flows

#### Scan/import

[lib/features/scan_import/presentation/scan_screens.dart](lib/features/scan_import/presentation/scan_screens.dart) covers:

- source selection
- permission handling
- cloud consent choice
- local OCR / cloud processing handoff
- document list and purge actions

#### Reports

[lib/features/reports/presentation/reports_screen.dart](lib/features/reports/presentation/reports_screen.dart) covers:

- reporting range selection
- projection summary
- bar chart of payments
- line chart of payoff projection
- pie chart by debt type
- CSV export gatekeeping

#### Settings

[lib/features/settings/presentation/settings_screens.dart](lib/features/settings/presentation/settings_screens.dart) covers:

- notifications
- premium
- security/privacy
- data backups
- help/about

### Design assessment

The UI is functional and tightly connected to the product’s trust model. It is not a generic consumer dashboard; it is a workflow UI for a sensitive financial assistant.

## 16. External Integrations

### Mobile / OS-level integrations

- `local_auth` for biometrics
- `permission_handler` for gallery/camera access
- `camera` and `image_picker` for captures
- `file_picker` for PDF import
- `flutter_local_notifications` for reminders
- `share_plus` for export sharing
- `timezone` for time-aware scheduling

### Google / cloud integrations

- Play Integrity for install attestation
- Google Play Billing for premium purchase verification and restore
- Gemini API for structured extraction on the backend
- Firebase analytics/crash reporting, with runtime configuration control

### Data / document integrations

- OCR via `google_mlkit_text_recognition`
- PDF import via `syncfusion_flutter_pdf`
- CSV export via `csv`
- Encrypted archive packaging via `archive`

### Backend integration model

The app’s backend config model in [lib/shared/models/backend_models.dart](lib/shared/models/backend_models.dart) shows the integration contract clearly:

- base URL
- environment
- Play Integrity project/package configuration
- debug attestation secret for local/test use
- premium product and base plan identifiers

## 17. Configuration, Build, and Deployment

### Environment files

- [\.env.example](.env.example) defines the Flutter client runtime contract, including app flavor, backend base URL, Play Integrity, and Firebase flags.
- [backend/.env.example](backend/.env.example) defines the backend runtime contract, including Postgres, Redis, JWT, Gemini, billing, rate limits, and attestation variables.

### Android build configuration

`android/app/build.gradle.kts` confirms:

- `dev`, `staging`, and `prod` flavors
- Android namespace / application ID `com.debtdestroyer.app`
- release signing via `key.properties` or `ANDROID_KEYSTORE_*` env vars
- Play Integrity dependency on the native side

The sample signing file [android/key.properties.example](android/key.properties.example) exists for local setup.

### Flutter / app workflows

The GitHub Actions workflow [\.github/workflows/ci.yml](.github/workflows/ci.yml) runs:

- `dart format --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- backend `npm test`
- backend `npm run build`

The Android verification workflow [\.github/workflows/android-verify.yml](.github/workflows/android-verify.yml) builds:

- dev debug APK
- staging release APK
- prod release app bundle

### Backend container and deployment

- [backend/Dockerfile](backend/Dockerfile) builds a Node 22 runtime image, prunes dev dependencies, copies compiled output, and runs as non-root `node`.
- [backend/docker-compose.yml](backend/docker-compose.yml) provides local Postgres 16 and Redis 7 along with the backend service.
- [render.yaml](render.yaml) defines the Render deployment for `debt-destroyer-backend`, including health checks, production env vars, and secret injection points.

### Deployment posture

The deployment files show a clear distinction between:

- local development, where dependencies can fall back to in-memory behavior
- staging / production, where external services are expected to exist and production requirements are enforced

## 18. Important File-by-File Notes

This section is not exhaustive, but it highlights the files that most strongly define the product.

### Flutter app entry and bootstrap

- [lib/main.dart](lib/main.dart): tiny entry point that calls `bootstrap()`.
- [lib/app/bootstrap.dart](lib/app/bootstrap.dart): loads env, timezone, telemetry, camera availability, and app-wide error handling.
- [lib/app/app.dart](lib/app/app.dart): root app widget and lifecycle/security coordinator.

### Routing and shell structure

- [lib/app/router/app_router.dart](lib/app/router/app_router.dart): route inventory, guarded paths, and shell tabs.

### Shared providers and state

- [lib/shared/providers/app_providers.dart](lib/shared/providers/app_providers.dart): central Riverpod graph and service wiring.

### Persistence and models

- [lib/shared/data/local/app_database.dart](lib/shared/data/local/app_database.dart): encrypted Drift schema and migrations.
- [lib/shared/models/debt_financial_terms.dart](lib/shared/models/debt_financial_terms.dart): APR / fee / minimum-payment terms.
- [lib/shared/models/dashboard_snapshot.dart](lib/shared/models/dashboard_snapshot.dart): dashboard summary contract.
- [lib/shared/models/reminder_models.dart](lib/shared/models/reminder_models.dart): reminder plan and milestone records.
- [lib/shared/models/data_protection_models.dart](lib/shared/models/data_protection_models.dart): encrypted storage readiness state.
- [lib/shared/models/subscription_state.dart](lib/shared/models/subscription_state.dart): premium entitlement view.

### Import pipeline

- [lib/features/scan_import/domain/import_services.dart](lib/features/scan_import/domain/import_services.dart): classifier, parser, heuristic fallback, and import coordinator.
- [lib/features/scan_import/presentation/scan_screens.dart](lib/features/scan_import/presentation/scan_screens.dart): source selection, consent, processing, and recent import list.

### Strategy and reports

- [lib/features/strategy/domain/portfolio_projection_service.dart](lib/features/strategy/domain/portfolio_projection_service.dart): payoff math and schedule generation.
- [lib/features/strategy/presentation/strategy_simulator_screen.dart](lib/features/strategy/presentation/strategy_simulator_screen.dart): user-facing strategy exploration.
- [lib/features/reports/presentation/reports_screen.dart](lib/features/reports/presentation/reports_screen.dart): charts, filters, export.

### Settings and security UX

- [lib/features/settings/presentation/settings_screens.dart](lib/features/settings/presentation/settings_screens.dart): notification, premium, security, backup, and help screens.
- [lib/features/settings/presentation/data_protection_screens.dart](lib/features/settings/presentation/data_protection_screens.dart): privacy upgrade and recovery screens.

### Security / storage services

- [lib/core/services/app_services.dart](lib/core/services/app_services.dart): analytics, crash reporting, biometric auth, notifications, reminder planning, premium gating, CSV export.
- [lib/core/services/vault_services.dart](lib/core/services/vault_services.dart): secure document vault, retention handling, and secure key service.
- [lib/core/services/portability_services.dart](lib/core/services/portability_services.dart): encrypted backup and restore workflow.
- [lib/core/logging/app_logger.dart](lib/core/logging/app_logger.dart): sensitive-data-aware logging.

### Backend source of truth and hardening

- [backend/src/app.ts](backend/src/app.ts): main API behavior and endpoint wiring.
- [backend/src/config.ts](backend/src/config.ts): required env and runtime config rules.
- [backend/src/server.ts](backend/src/server.ts): startup and graceful shutdown.
- [backend/src/services/storage.ts](backend/src/services/storage.ts): persistence and cleanup.
- [backend/src/services/attestation.ts](backend/src/services/attestation.ts): Play Integrity decode flow.
- [backend/src/services/billing.ts](backend/src/services/billing.ts): Google Play entitlement verification.
- [backend/src/services/rate-limit.ts](backend/src/services/rate-limit.ts): rate-limiting strategies and fallback behavior.

### Tests that matter

- [backend/test/storage.test.ts](backend/test/storage.test.ts)
- [backend/test/rate-limit.test.ts](backend/test/rate-limit.test.ts)
- [backend/test/billing.test.ts](backend/test/billing.test.ts)
- [backend/test/ops-hardening.test.ts](backend/test/ops-hardening.test.ts)
- [backend/test/extraction.test.ts](backend/test/extraction.test.ts)
- [test/app_security_test.dart](test/app_security_test.dart)
- [test/data_backups_screen_test.dart](test/data_backups_screen_test.dart)
- [test/ocr_processing_screen_test.dart](test/ocr_processing_screen_test.dart)
- [test/strategy_engine_test.dart](test/strategy_engine_test.dart)

## 19. Strengths of the Current Codebase

- The product has a real end-to-end story: entry, unlock, debt tracking, OCR import, reporting, backup, and premium verification are all present.
- Security and privacy are not cosmetic; they are built into the app model, the backend model, and the persistence model.
- The backend is well-constrained and validated rather than loosely assembled.
- The feature set is coherent. Every major feature supports the same core user goal: understand and eliminate debt while keeping data safe.
- The test suite is not decorative. Backend tests in particular validate startup, attestation, billing, and rate limiting behavior.
- Deployment is operationally mature enough to have Docker, Compose, Render, and CI workflows already defined.

## 20. Weaknesses, Risks, and Tech Debt

- The app is security-sensitive, so any bug in encryption, vault handling, backup restore, or entitlement syncing could have high impact.
- The onboarding and settings surface is large for a finance app, which can make first-time setup feel heavy if not carefully guided.
- Some screen copy appears behind the implementation, especially where backup and roadmap language is concerned.
- The backend depends on external services in production: Redis, Postgres, Gemini, Play Integrity, and Google Play service account credentials.
- The codebase is clearly Android-first; iOS support may be possible in Flutter terms, but it is not the currently evidenced delivery target.
- The project has many moving parts, which raises maintenance cost for schema migrations and cross-layer compatibility.

## 21. Incomplete, Unclear, or Inferred Areas

### Still not fully inspected

- Some supporting files in `docs/qa`, `docs/release`, and `docs/superpowers` were not deeply inspected.
- Not every helper module in `lib/core` was read line-by-line.
- Not every feature screen was opened individually, although the route inventory and most major screens were covered.

### Known document drift

- Help/about copy appears to be less precise than the actual implementation in a few places.
- The app’s product story is more complete than some of the older descriptive docs suggest.

### Repository-wide marker scan

- A full TODO/FIXME scan was attempted but was not conclusive enough to treat as authoritative.
- Because of that, this document avoids claiming “there are no TODOs” and instead treats that area as not fully verified.

### What is inferred rather than directly proven

- Exact UX timing details for some overlay transitions
- The full long-tail behavior of every parser fallback path
- The exact user experience of every premium upsell state in every edge case

## 22. Glossary of Important Internal Terms

| Term | Meaning |
|---|---|
| App lock | Device-auth or biometric gate before content is shown |
| Privacy shield | Screen masking when the app is backgrounded or switched away |
| SQLCipher | Encrypted SQLite layer used by Drift |
| Vault | Encrypted on-disk storage for imported documents |
| Bootstrap | The install/session trust handshake with the backend |
| Attestation | Play Integrity verification of the install/device context |
| Entitlement | Premium feature access state returned by backend and mirrored locally |
| Scenario | Payoff simulation snapshot and strategy comparison artifact |
| Retention mode | How long imported documents or OCR text may remain stored |
| Restoration | Encrypted backup recovery process |

## 23. Concise “Explain This Project to Another LLM” Summary

Debt Destroyer is a Flutter Android app backed by a Fastify/TypeScript API. The mobile app is local-first and encrypted: debts, payments, reminders, preferences, scenarios, and imported documents are stored on device through Drift + SQLCipher, with a separate encrypted document vault and encrypted backup/restore flow. The backend exists to do the trust-heavy work: Play Integrity bootstrap, JWT session issuance, premium entitlement verification through Google Play billing, request rate limiting, quota control for extraction, and Gemini-assisted cloud document processing when the user explicitly allows it. The UI is feature-first and route-driven, with major surfaces for dashboard, debts, scan/import, strategy simulation, reports, settings, security/privacy, backups, and premium. The codebase is unusually focused on privacy controls such as app lock, screenshot protection, privacy shield, raw OCR retention, and purge behavior. In short, it is a debt-management system that treats security and offline ownership as core product features rather than add-ons.