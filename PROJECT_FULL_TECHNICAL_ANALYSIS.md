# DEBT DESTROYER — Complete Technical Analysis

**Last Updated:** April 2026  
**Project Type:** Full-Stack Mobile Application (Flutter + Node.js Backend)  
**Repository:** rubayet211/debt-destroyer (dev branch, main as default)

---

## 1. Project Overview

**Debt Destroyer** is a privacy-first debt tracking, payoff planning, and document-assisted import application for Android. The core value proposition is enabling users to:

- Track debt manually or import statements using OCR and AI extraction
- Simulate payoff strategies (Snowball, Avalanche, Custom)
- Manage payments with local-first encrypted persistence
- View debt-free forecasts and financial metrics
- Access premium features via Google Play billing
- Maintain full control over when and how personal financial data is processed

The application is built with **Flutter** for the frontend (Android-first, extensible to iOS) and **Node.js/Fastify** for the backend, with a focus on privacy, security, and offline-first operation.

---

## 2. Executive Summary

### Scope

- **Language(s):** Dart (Flutter frontend), TypeScript (Node.js backend), Kotlin (Android native)
- **Package Managers:** Pub (Dart), npm (Node.js), Gradle (Android)
- **Database (Frontend):** SQLite with encryption (Drift ORM, SQLCipher)
- **Database (Backend):** PostgreSQL (with in-memory and Redis support for testing)
- **Architecture:** Feature-first layered architecture (presentation, domain, data)
- **State Management:** Riverpod with reactive providers
- **Routing:** go_router with StatefulShellRoute (tabbed bottom navigation)

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Project Type** | Full-stack mobile application (Flutter + backend) |
| **Primary OS** | Android (flavors: dev, staging, prod) |
| **Architecture** | Feature-first + layered domain/data separation |
| **State Pattern** | Reactive (Riverpod providers, streams) |
| **Data Persistence** | Encrypted local DB (SQLite + SQLCipher) + backend for auth/extraction |
| **Auth Model** | Play Integrity attestation + JWT (access/refresh tokens) |
| **Billing** | Google Play subscriptions with backend verification |
| **OCR** | On-device (Google ML Kit) + optional backend AI extraction |
| **Privacy Model** | Local-first, explicit opt-in for cloud processing |

---

## 3. Tech Stack Summary

### Frontend Stack (Flutter/Dart)

| Category | Packages |
|----------|----------|
| **State Management** | `flutter_riverpod` (v2.6.1) — Provider-based reactive state |
| **Routing** | `go_router` (v16.2.1) — Declarative routing with deep linking |
| **Database** | `drift` (v2.28.1) — Async SQLite ORM, code-gen schema; `sqlcipher_flutter_libs` (v0.6.6) — On-device encryption |
| **Auth** | `local_auth` (v2.3.0) — Biometric + PIN; `flutter_secure_storage` (v9.2.4) — Secure string storage |
| **Camera/File** | `camera` (v0.11.3), `image_picker` (v1.2.0), `file_picker` (v10.3.2) |
| **OCR** | `google_mlkit_text_recognition` (v0.15.0) — On-device text recognition |
| **PDF** | `syncfusion_flutter_pdf` (v30.2.7) — PDF reading |
| **Charts** | `fl_chart` (v1.1.1) — Data visualization |
| **Notifications** | `flutter_local_notifications` (v19.4.1) — Local reminders |
| **Crypto** | `cryptography` (v2.7.0) — Encryption utilities |
| **Export/Share** | `csv` (v6.0.0), `share_plus` (v12.0.1), `archive` (v4.0.7) |
| **Firebase** | `firebase_core` (v3.15.2), `firebase_analytics` (v11.6.0), `firebase_crashlytics` (v4.3.10) |
| **Billing** | `in_app_purchase` (v3.2.3), `in_app_purchase_android` (v0.4.0+8) |
| **HTTP** | `http` (v1.5.0) — Simple HTTP client for backend |
| **Utility** | `intl` (v0.20.2) — i18n; `uuid` (v4.5.1); `google_fonts` (v6.3.2); `timezone` (v0.10.1); `flutter_dotenv` (v6.0.0) |

### Backend Stack (Node.js/Fastify)

| Category | Packages |
|----------|----------|
| **Framework** | `fastify` (v5.6.1) — High-performance HTTP server |
| **Validation** | `zod` (v4.1.11) — Schema validation and type coercion |
| **Database** | `pg` (v8.16.3) — PostgreSQL client |
| **Cache/Rate-Limit** | `ioredis` (v5.8.1) — Redis client for quota tracking and rate limiting |
| **Auth** | `jsonwebtoken` (v9.0.2) — JWT token generation/verification |
| **AI** | `googleapis` (v171.4.0) — Gemini API integration for structured extraction |
| **Config** | `dotenv` (v17.2.3) — Environment variable loading |
| **Testing** | `vitest` (v3.2.4) — Vitest test runner |
| **Build** | `typescript` (v5.9.3), `tsx` (v4.20.6) — TypeScript compilation and execution |

### Development Dependencies

- **Flutter:** `flutter_test`, `flutter_lints`, `drift_dev`, `build_runner`, `mocktail`
- **Backend:** `@types/node`, `@types/pg`, `@types/jsonwebtoken`

---

## 4. Dependency Analysis

### Core Runtime Dependencies

#### Frontend (Dart)

**Critical Dependencies:**
- `flutter_riverpod` — Entire state management model depends on this
- `go_router` — Core navigation layer
- `drift` + `sqlcipher_flutter_libs` — Data persistence and encryption
- `google_mlkit_text_recognition` — OCR engine (local)
- `firebase_analytics` + `firebase_crashlytics` — Telemetry pipeline

**Feature Dependencies:**
- `camera`, `image_picker`, `file_picker` — Document capture sources
- `local_auth` — Biometric unlock
- `in_app_purchase` — Premium subscription billing
- `flutter_local_notifications` — Reminder scheduling
- `http` — Backend communication

**Supporting:**
- `cryptography` — Encryption for vault services
- `csv`, `archive`, `share_plus` — Export and sharing
- `timezone`, `intl`, `uuid` — Utilities

#### Backend (Node.js)

**Critical Dependencies:**
- `fastify` — HTTP server framework
- `zod` — Request/response validation and schema normalization
- `pg` — PostgreSQL connectivity
- `jsonwebtoken` — Session token handling
- `ioredis` — Rate limiting and quota reservation

**Feature Dependencies:**
- `googleapis` — Gemini API provider for AI extraction
- `dotenv` — Environment configuration

**Testing:**
- `vitest` — Test runner

### Potentially Unused or Concerning Packages

| Package | Observation |
|---------|------------|
| `collection` (v1.19.1) | Standard Dart utilities, likely used transitively |
| `meta` (v1.16.0) | Dart metadata, standard |
| `path` (v1.9.1), `path_provider` (v2.1.5) | File path utilities, expected |
| `permission_handler` (v12.0.1) | Android permissions (camera, storage, notifications) — required |
| `sqlite3` (v2.9.3) | Direct SQLite bindings (lower level than Drift) — likely used by Drift internally |

### Dependency Gaps / Inferred Missing Pieces

- **No explicit form validation library** — Validation appears to be custom or via `zod` on backend
- **No state persistence layer** — Riverpod state is ephemeral; Drift handles data persistence
- **No HTTP request logging/interceptor library** — Backend HTTP calls may not have detailed logging
- **No animation library beyond Material** — No Lottie or similar for complex animations

---

## 5. Architecture Overview

### Design Principles

1. **Feature-First Organization** — Code organized by feature, not by layer
2. **Layered Architecture within Features** — Separation of presentation, domain, data
3. **Reactive State Management** — Riverpod providers for reactive streams
4. **Local-First, Backend-Mediated** — Core data lives on device; backend handles auth and optional AI
5. **Explicit Privacy Consent** — Cloud extraction only with user opt-in
6. **Offline-First Operation** — App remains functional without backend
7. **Type Safety** — Strong typing in Dart and TypeScript

### High-Level Data Flow

```
User Input (Screen)
    ↓
Riverpod Provider (state mutation)
    ↓
Service Layer (business logic)
    ↓
Repository Layer (data access)
    ↓
Drift (local SQLite) or HTTP (backend)
    ↓
Device Storage / Backend Server
```

### Feature Structure

```
lib/
  app/                    # App bootstrap, routing, theme
    bootstrap.dart        # Initialization, telemetry setup
    app.dart              # Root widget, security overlays
    router/               # Route definitions
    theme/                # Material theme configuration
  
  core/                   # Cross-cutting concerns
    services/             # Auth, telemetry, security, backup, billing
    widgets/              # Reusable UI components
    constants/            # App constants
    utils/                # Parsers, formatters, helpers
    logging/              # App logger and telemetry integration
    errors/               # Custom exceptions
  
  features/               # Feature modules
    onboarding/           # Splash, intro slides, currency/security setup
    auth_lock/            # Biometric unlock screen
    dashboard/            # Home screen, debt metrics, snapshot view
    debts/                # CRUD for debts, payment history, details
    scan_import/          # Camera, OCR, AI extraction, review
    strategy/             # Strategy simulator (snowball/avalanche)
    reports/              # Charts, analytics, projections
    settings/             # User preferences, premium, security
  
  shared/                 # Shared domain models and data layer
    models/               # Domain entities (Debt, Payment, etc.)
    data/                 # Repositories and database
    enums/                # Shared enumerations
    providers/            # Riverpod providers (dependency injection)

backend/
  src/
    server.ts             # Server entry point
    app.ts                # Fastify app, route handlers
    config.ts             # Configuration loading (Zod-based)
    types.ts              # Zod schemas for validation
    utils.ts              # Error handling, helpers
    services/             # Auth, storage, rate-limit, schema, provider, billing, crypto, attestation
  sql/
    001_init.sql          # PostgreSQL schema bootstrap
  test/                   # Integration tests with mocked services
```

---

## 6. Folder and File Structure Breakdown

### Frontend (`lib/`)

#### `app/` — Application Bootstrap and Navigation

- **`bootstrap.dart`** — Initialization pipeline:
  - Loads environment variables (`flutter_dotenv`)
  - Initializes timezone data
  - Sets up crash reporting (Firebase + custom handler)
  - Discovers available cameras
  - Initializes telemetry system
  - Runs the app in guarded zone with error handling

- **`app.dart`** — Root `DebtDestroyerApp` widget:
  - Watches `userPreferencesProvider` (theme, locale)
  - Watches `appSecurityCoordinatorProvider` (lock state, privacy shield)
  - Renders `MaterialApp.router` with `go_router`
  - Overlays privacy shield and unlock screen when needed
  - Observes app lifecycle (foreground/background)
  - Reconciles reminders when debts/payments change

- **`router/app_router.dart`** — Go Router configuration:
  - Routes: splash → onboarding → tabbed shell (Dashboard, Debts, Scan, Strategy, Settings)
  - Nested routes for debt details, add/edit, payment history
  - Scan routes: camera → OCR processing → review confirmation
  - Protected routes: unlock, privacy-upgrade, data-protection-recovery
  - Non-feature routes: premium, reports, notifications, backups, security, help

- **`theme/app_theme.dart`** — Material Design theme:
  - Light and dark themes
  - Color scheme, typography
  - Component defaults

#### `core/` — Cross-Cutting Concerns

**Services (`core/services/`):**
- **`app_services.dart`** — BiometricAuthService, AnalyticsService, CsvExportService, PremiumService, NoopAnalyticsService
- **`security_services.dart`** — AppSecurityState, SensitiveRouteRegistry, SensitiveScreenProtectionService, AppSecurityCoordinatorNotifier
- **`backend_services.dart`** — AttestationService (Play Integrity), BackendSessionManager, BackendAuthService, BackendCapabilitiesService, BackendAiExtractionService
- **`billing_services.dart`** — BillingService (abstract), GooglePlayBillingService, EntitlementSyncService
- **`telemetry_services.dart`** — TelemetryConfig, TelemetryRuntime, FirebaseAnalyticsService, CrashReporter with Firebase or noop fallback
- **`vault_services.dart`** — LocalVaultKeyService, ProtectedPreferencesStore, AppSecuritySessionStore, SecureDocumentVaultService, DataRetentionService
- **`data_protection_service.dart`** — DataProtectionBootstrapService, DataProtectionState
- **`portability_services.dart`** — DataPortabilityService (backup/restore)

**Utilities:**
- **`core/constants/app_constants.dart`** — Package name, product IDs, base URLs
- **`core/utils/formatters.dart`** — Currency, date, debt balance formatting with privacy masking
- **`core/utils/parsers.dart`** — JSON parsing, type conversions
- **`core/logging/app_logger.dart`** — Structured logging with context
- **`core/errors/app_exception.dart`** — Custom exception types
- **`core/widgets/app_widgets.dart`** — Reusable UI components (AppCard, AppPage, EmptyStateView, etc.)

#### `features/` — Feature Modules

Each feature follows: `domain/` → `presentation/` (some have no domain layer if simple)

**`onboarding/`**
- **`presentation/`**
  - `splash_screen.dart` — App icon, loading state
  - `onboarding_screen.dart` — Paged intro slides, currency/locale selection, security setup (app lock enable)

**`auth_lock/`**
- **`presentation/`**
  - `biometric_unlock_screen.dart` — Unlock pane with biometric auth, PIN fallback

**`dashboard/`**
- **`domain/`**
  - `debt_metrics_service.dart` — Calculate totals, paid so far, minimums, debt-free forecast
- **`presentation/`**
  - `home_dashboard_screen.dart` — Metrics cards, debt distribution chart, recent activity

**`debts/`**
- **`presentation/`**
  - `debts_screens.dart` — List screen, add/edit forms, details, payment history

**`scan_import/`**
- **`domain/`**
  - `import_services.dart` — OcrService (ML Kit), DocumentClassifier, ParseValidationService, AiExtractionService (abstract)
- **`presentation/`**
  - `scan_screens.dart` — Hub screen, camera capture, OCR processing, parsed review/confirmation

**`strategy/`**
- **`domain/`**
  - `strategy_engine.dart` — Delegates to PortfolioProjectionService
  - `portfolio_projection_service.dart` — Snowball, Avalanche, Custom strategy simulation
  - `money_math.dart` — Interest compounding, payment schedules
- **`presentation/`**
  - `strategy_simulator_screen.dart` — Strategy selection, scenario cards, comparison

**`reports/`**
- **`presentation/`**
  - `reports_screen.dart` — Charts (payoff timeline, category breakdown), export options

**`settings/`**
- **`presentation/`**
  - `settings_screens.dart` — Theme, currency, strategy, notifications, security, backup, premium, help pages

#### `shared/` — Shared Domain and Data

**`models/`**
- `debt.dart` — Debt entity (id, title, creditor, type, balance, APR, minimum, due date, etc.)
- `payment.dart` — Payment entity (id, debtId, amount, date, method, notes, tags)
- `user_preferences.dart` — UserPreferences (currency, theme, locale, notification settings, security settings)
- `strategy_models.dart` — StrategyRequest, StrategyResult, Scenario
- `import_models.dart` — ImportedDocument, ParsedExtraction, ExtractionCandidate, ImportReviewBundle
- `dashboard_snapshot.dart` — DashboardSnapshot (totals, forecast)
- `subscription_state.dart` — SubscriptionState (free vs premium, plan, expiry)
- `billing_models.dart` — BillingPlan, BillingCatalog, PurchaseDetails
- `backend_models.dart` — InstallSession, BackendConfig, BackendQuotaSnapshot
- `data_protection_models.dart` — DataProtectionState, migration info
- `backup_models.dart` — BackupValidationResult, BackupMetadata
- `debt_financial_terms.dart` — DebtFinancialTerms (promos, recurring fees, etc.)
- `reminder_models.dart` — ReminderRule, ReminderEvent, etc.

**`enums/`**
- `app_enums.dart` — DebtType, DebtStatus, PaymentFrequency, DocumentSourceType, StrategyType, PremiumFeature, ReminderKind, etc.

**`data/`**
- `repositories.dart` — Abstract repositories + Drift implementations:
  - `DebtsRepository`, `PaymentsRepository`, `PreferencesRepository`, `DocumentsRepository`, `ScenariosRepository`, `SubscriptionRepository`, `ReminderEventsRepository`
  - Each maps Drift table rows to domain models
- `local/app_database.dart` — Drift database definition:
  - Tables: DebtsTable, PaymentsTable, ImportedDocumentsTable, ParsedExtractionsTable, ReminderRulesTable, ReminderEventsTable, ScenariosTable, AppPreferencesTable, SubscriptionStateTable
  - SQLCipher encryption setup
  - Migrations (schema version 7)
  - Helper methods for JSON encoding/decoding

**`providers/`**
- `app_providers.dart` — Riverpod provider definitions:
  - Infrastructure providers (httpClient, database, secureStorage, localNotifications)
  - Configuration providers (backendConfig, telemetry)
  - Repository providers
  - Service providers
  - State providers (userPreferences, allDebts, allPayments, userPreferences, subscription, entitlement)
  - Feature providers (reminderOrchestrator, billingService, dataPortabilityService)
  - Async/stream providers for loading data

---

### Backend (`backend/`)

#### `backend/src/`

**`server.ts`** — Entry point
- Loads config
- Creates and starts Fastify app
- Binds to `0.0.0.0:PORT`

**`app.ts`** — Core Fastify application
- **Dependency injection:** Store, provider, rateLimiter, billingVerifier, attestationVerifier
- **Error handler:** Catches `AppError` and returns structured error responses
- **Cleanup hook:** Closes store and rate limiter on shutdown
- **Health checks:** `/health/live`, `/health/ready`
- **Auth endpoints:**
  - `POST /v1/mobile/bootstrap/challenge` — Create attestation challenge
  - `POST /v1/mobile/bootstrap/verify` — Verify Play Integrity, issue JWT
  - `POST /v1/mobile/token/refresh` — Rotate refresh token, issue new access token
- **Capabilities:** `GET /v1/mobile/me/capabilities` — Return premium status, features, quota
- **Billing:**
  - `POST /v1/billing/google-play/verify` — Verify subscription receipt, update entitlement
  - `POST /v1/billing/google-play/restore` — Multi-purchase verification for restore flow
- **Extraction:**
  - `POST /v1/mobile/extractions` — AI extraction with rate limiting, quota enforcement, audit logging
  - Calls provider (Gemini), normalizes response, stores audit

**`config.ts`** — Configuration loader (Zod schema)
- **Environment variables:**
  - `NODE_ENV`, `PORT`, `POSTGRES_URL`, `REDIS_URL`
  - `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` (required in prod)
  - `GEMINI_API_KEY`, `GEMINI_MODEL`
  - `FREE_SCAN_LIMIT`, `ACCESS_TOKEN_TTL_SECONDS`, `REFRESH_TOKEN_TTL_DAYS`
  - `ALLOW_DEBUG_ATTESTATION`, `DEBUG_ATTESTATION_SECRET`
  - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`, `PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER`, `PLAY_INTEGRITY_PACKAGE_NAME`
  - `PREMIUM_PRODUCT_ID`, `PREMIUM_MONTHLY_BASE_PLAN_ID`, `PREMIUM_YEARLY_BASE_PLAN_ID`
- **Validation:** Ensures production secrets are set, debug attestation disabled in prod

**`types.ts`** — Zod schemas
- **Request schemas:**
  - `bootstrapChallengeRequestSchema` — app_version, platform, install_id
  - `bootstrapVerifyRequestSchema` — challenge_id, attestation_token, device info
  - `billingVerifyRequestSchema` — product_id, purchase_token, etc.
  - `extractionRequestSchema` — document_classification, ocr_text, request_id
  - `tokenRefreshRequestSchema` — refresh_token
- **Response schemas:**
  - `extractionResponseSchema` — extraction fields (issuer, balance, APR, due date, etc.), line items, summary, warnings, meta
  - `entitlementSnapshotSchema` — premium status, features, billing info
  - `quotaSnapshotSchema` — remaining free scans, reset time

**`utils.ts`** — Helpers
- `AppError` class — Structured error responses (statusCode, code, message, details)
- `requireInstallId()` — Verify JWT and extract installId
- `signAccessToken()`, signature verification, token utilities

**`services/`** — Service implementations

- **`attestation.ts`** — `ConfigurableAttestationVerifier`
  - Verifies Play Integrity tokens via Google API
  - Returns verdict (valid, status, reason)
  - Dev/test mode supports debug attestation

- **`billing.ts`** — `BillingVerifier` (Google Play)
  - Verifies subscription purchase tokens
  - Normalizes billing provider responses
  - Returns EntitlementRecord (isPremium, status, validUntil, features, etc.)

- **`crypto.ts`** — Utilities
  - `makeId()`, `makeNonce()`, `makeOpaqueToken()` — UUID/random generation
  - `hashToken()` — SHA256 hashing of refresh tokens
  - `sha256()` — General hashing
  - `redactTextPreview()` — Redact PII from logs

- **`provider.ts`** — AI providers
  - Abstract `AiProvider` interface
  - `GeminiProvider` — Calls Gemini API for structured debt extraction
  - Handles classification-specific prompts

- **`prompts.ts`** — Prompt templates for Gemini by document classification

- **`rate-limit.ts`** — `RateLimiter` (Redis)
  - Per-install, per-IP rate limiting
  - 20 requests/min per install, 60 requests/min per IP
  - Returns remaining count and reset time

- **`storage.ts`** — `AppStore` (interface + implementations)
  - **MemoryAppStore** — In-memory (for tests)
  - **PostgreSQL implementation** — Production store
  - Tables:
    - `attestation_challenges` — Challenge state
    - `install_sessions` — Device registration
    - `refresh_tokens` — JWT refresh tokens
    - `usage_counters` — Monthly extraction count
    - `quota_reservations` — Pending quota slots
    - `premium_entitlements` — Subscription status
    - `billing_purchase_history` — Purchase records
    - `extraction_audits` — AI extraction logs
    - `audit_events` — General events (bootstrap, billing, extraction)
    - `rate_limit_events` — Rate limit violations

- **`schema.ts`** — `normalizeExtraction()`
  - Validates raw provider response against `extractionSchema`
  - Coerces types, handles nulls
  - Returns normalized, safe-to-store extraction

#### `backend/sql/`

**`001_init.sql`** — Schema bootstrap
- Creates tables with foreign keys, indexes
- Enables JSONB features for PostgreSQL
- Default values, constraints

#### `backend/test/`

Integration tests using Vitest + mocked services

---

## 7. Product Purpose and Problem Solved

### The Problem

Users with multiple debts (credit cards, loans, BNPL, etc.) face:
1. **Fragmented data** — Statements scattered across provider apps, emails, or paper
2. **Manual data entry** — Tedious, error-prone re-entry of debt details
3. **Strategy confusion** — Unclear which payoff strategy (snowball vs. avalanche) is optimal
4. **Privacy concerns** — Reluctance to share financial details with third-party apps
5. **Lack of offline functionality** — Dependency on cloud services for basic tracking

### Debt Destroyer's Solution

**Privacy-First Debt Tracking with Intelligent Import:**

1. **Local-first operation** — All debt data stored encrypted locally; no mandatory cloud upload
2. **Intelligent document import** — Camera/gallery capture → on-device OCR → optional backend AI extraction (explicit per-import)
3. **Strategy simulation** — Compare Snowball, Avalanche, and Custom strategies with realistic month-by-month projections
4. **Secure offline payoff planning** — Build and execute a payoff strategy without external dependencies
5. **Premium features** — Unlimited scans, advanced reports, scenario saving (via Google Play)
6. **Privacy controls** — Granular settings: app lock, balance hiding, cloud extraction consent, data retention policies

### User Value Proposition

- **For Debt Consolidators:** Understand total debt, visualize payoff timeline, compare strategies
- **For Privacy-Conscious Users:** All personal financial data encrypted and retained locally
- **For Busy Professionals:** One-tap document import and AI-assisted extraction saves hours
- **For Financially Disciplined Users:** Detailed reporting, milestone tracking, reminder scheduling

---

## 8. User Roles and Primary Workflows

### User Roles

1. **Free User** — Limited to 5 cloud extractions/month, basic features, local tracking
2. **Premium User** — Unlimited cloud extractions, advanced reports, scenario saving, CSV export
3. **Guest/Onboarding** — First-time user; completes setup wizard (currency, security, locale)
4. **Admin (Implicit)** — Backend maintains audit logs, quotas, billing state per install

### Primary Workflows

#### Workflow 1: Manual Debt Tracking
```
1. User: Open app, view Dashboard (empty)
2. User: Tap "Add debt" button
3. UI: Navigate to AddEditDebtScreen
4. User: Enter title, creditor, type, balance, APR, due date, payment frequency
5. User: Submit form → Riverpod writes to Drift database
6. UI: Navigate back to Dashboard
7. System: Watch triggers refreshes debts list, metrics recalculate
```

#### Workflow 2: Import Statement via Scan
```
1. User: Navigate to Scan tab
2. UI: Show ScanImportHubScreen (import sources, recent imports)
3. User: Tap "Camera" source → CameraCaptureScreen
4. User: Capture credit card statement photo
5. System: Save to app storage, navigate to OCRProcessingScreen
6. System: Run on-device OCR (ML Kit), classify document (credit card, loan, etc.)
7. UI: Show OCR confidence, allow cloud extraction toggle
8. User: Choose "Allow cloud extraction" (Premium or within free quota)
9. System: If enabled, bootstrap backend session + send normalized OCR to /extraction
10. Backend: Verify attestation, check quota, call Gemini, normalize response
11. System: Render ParsedReviewConfirmScreen with extracted fields
12. User: Review suggested values (issuer, balance, APR, due date, etc.), mark payment line items
13. User: Tap "Confirm and save"
14. System: Save ImportedDocument + ParsedExtraction + create Debt record
15. System: Update dashboard metrics
```

#### Workflow 3: Strategy Simulation
```
1. User: Navigate to Strategy tab
2. System: Load all debts from Drift
3. UI: StrategySimulatorScreen shows available strategies
4. User: Select Avalanche strategy, input extra payment ($100/mo)
5. System: Invoke StrategyEngine.simulate() → PortfolioProjectionService
6. System: Project month-by-month payoff, calculate interest saved, return scenarios
7. UI: Render timeline, interest comparison, warnings (overdues, late fees)
8. User: Tap "Save scenario" (Premium feature)
9. System: Save to ScenariosTable, tagged with creation date
10. User: Switch to another strategy, compare side-by-side
```

#### Workflow 4: Premium Upgrade
```
1. User: Tap "Premium" in Settings
2. UI: PremiumScreen shows plans (Monthly, Yearly)
3. User: Tap "Subscribe"
4. System: Invoke GooglePlayBillingService.buyPlan()
5. System: Google Play shows purchase dialog
6. User: Confirms purchase
7. System: Google Play calls app's purchaseStream listener
8. App: Extracts purchase token, sends to /billing/google-play/verify
9. Backend: Verifies token with Google, updates EntitlementRecord, saves audit
10. System: Update SubscriptionStateTable, toggle premium features
11. UI: Reflect premium status in Settings, unlock unlimited extractions
```

#### Workflow 5: App Lock and Privacy
```
1. User: Enable biometric unlock in Security settings
2. System: Save preference → protectedPreferencesStore
3. User: Backgrounding app (lifecycle change detected in app.dart)
4. System: Trigger AppSecurityCoordinatorNotifier.handleLifecycleChange()
5. System: Set lock flag, schedule relocking after timeout
6. User: Foreground app
7. System: Check lock state, if locked, render BiometricUnlockScreen
8. User: Authenticate with fingerprint/face
9. System: Set isUnlocked=true, clear overlays, resume navigation
10. User: Toggle "Hide balances" in Settings
11. System: Update preference, re-render dashboard with masked values
```

#### Workflow 6: Data Backup and Restore
```
1. User: Tap "Data & Backups" in Settings
2. UI: DataBackupsScreen shows export/backup options
3. User: Tap "Create encrypted backup"
4. System: Invoke DataPortabilityService.createFullBackup(passphrase)
5. System: Serialize all debts, payments, preferences, imported documents (vault-protected)
6. System: Encrypt with user-provided passphrase
7. System: Create .ddbackup file in Downloads
8. User: Share file via email/cloud
9. [Later, new device]
10. User: Tap "Restore from backup"
11. User: Select .ddbackup file via FilePicker
12. System: Invoke DataPortabilityService.inspectBackup(file, passphrase)
13. System: Decrypt and validate structure
14. User: Confirm restore
15. System: Clear local database, restore from backup
16. System: Reboot data providers, refresh UI
```

---

## 9. Full Feature Inventory

### Core Features

| Feature | Status | Location | Details |
|---------|--------|----------|---------|
| **Manual Debt Tracking** | ✓ Complete | `debts/presentation` | Add, edit, delete debts with full details |
| **Payment Logging** | ✓ Complete | `debts/presentation` | Log payments, view payment history |
| **Dashboard Metrics** | ✓ Complete | `dashboard/` | Total outstanding, paid, minimums, debt-free forecast |
| **Snowball Strategy** | ✓ Complete | `strategy/domain` | Smallest balance first payoff simulation |
| **Avalanche Strategy** | ✓ Complete | `strategy/domain` | Highest APR first payoff simulation |
| **Custom Priority Strategy** | ✓ Complete | `strategy/domain` | User-defined payoff order |
| **On-Device OCR** | ✓ Complete | `scan_import/domain` | Google ML Kit text recognition (camera, gallery, PDF) |
| **Document Classification** | ✓ Complete | `scan_import/domain` | Auto-detect credit card, loan, BNPL statements |
| **Cloud AI Extraction** | ✓ Complete | `backend/src/services/provider.ts` | Gemini API integration for structured extraction |
| **Backend Attestation** | ✓ Complete | `backend/src/services/attestation.ts` | Play Integrity verification for secure extraction |
| **Quota System** | ✓ Complete | `backend/src/services/storage.ts` | 5 free cloud extractions/month (free tier) |
| **Google Play Billing** | ✓ Complete | `billing_services.dart` + `backend/src/services/billing.ts` | Premium subscription (monthly/yearly) |
| **Local Notifications** | ✓ Complete | `core/services/app_services.dart` | Reminder scheduling (due date alerts, overdue notices) |
| **App Lock (Biometric)** | ✓ Complete | `auth_lock/presentation` | Fingerprint/face unlock with timeout |
| **Data Export (CSV)** | ✓ Complete | `core/services/app_services.dart` | Export debts and payments to CSV |
| **Encrypted Backup** | ✓ Complete | `core/services/portability_services.dart` | Full backup with passphrase encryption |
| **Backup Restore** | ✓ Complete | `core/services/portability_services.dart` | Restore from encrypted .ddbackup file |
| **Telemetry** | ✓ Complete | `core/services/telemetry_services.dart` | Firebase Analytics + Crashlytics |
| **Theme Support** | ✓ Complete | `app/theme` | Light, dark, system modes |
| **Multi-Currency** | ✓ Complete | `shared/models/user_preferences.dart` | User selects currency for all views |
| **Privacy Shield** | ✓ Complete | `security_services.dart` | Blur screen on app background (if enabled) |
| **Balance Masking** | ✓ Complete | `security_services.dart` | Hide balance values in UI |

### Premium Features

| Feature | Status | Details |
|---------|--------|---------|
| **Unlimited Cloud Extractions** | ✓ Complete | No monthly quota |
| **PDF Import** | ✓ Complete | Direct PDF statement upload (via Syncfusion) |
| **Advanced Reports** | ✓ Complete | Charts, timeline, category breakdown |
| **Scenario Saving** | ✓ Complete | Save multiple strategy simulations |
| **CSV Export** | ✓ Complete | Download debt and payment data |
| **Advanced Theme Customization** | ⚠️ Inferred | Presumed premium, not fully verified in code |

### Secondary Features

| Feature | Status | Location | Details |
|---------|--------|----------|---------|
| **Recurring Fee Tracking** | ⚠️ Partial | `debt_financial_terms.dart` | Fields present, integration unclear |
| **Promo Rate Handling** | ⚠️ Partial | `money_math.dart` | Finance terms model exists |
| **Late Fee Calculation** | ⚠️ Partial | `money_math.dart` | Warnings system in place |
| **Multi-Language** | ✗ Not Found | — | intl package present but no translations |
| **Milestone Tracking** | ⚠️ Partial | `reminder_models.dart` | Model defined, integration unclear |
| **Family Loan Support** | ✓ Complete | `debt.dart` — DebtType enum | Can create family loan debts |
| **Line Item Import** | ✓ Complete | `import_models.dart` | Backend returns line items with confidence |
| **Ambiguity Flagging** | ✓ Complete | `import_models.dart`, `backend/types.ts` | ParsedExtraction stores ambiguity notes |
| **Rate Limiting** | ✓ Complete | `backend/src/services/rate-limit.ts` | Per-install + per-IP limiting |
| **Audit Logging** | ✓ Complete | `backend/src/services/storage.ts` | All operations logged (bootstrap, billing, extraction) |

### Administrative Features

| Feature | Status | Details |
|---------|--------|---------|
| **Audit Event Log** | ✓ Complete | Backend logs all significant events (bootstrap, billing, extraction) |
| **Usage Tracking** | ✓ Complete | Per-install monthly extraction counts |
| **Entitlement Management** | ✓ Complete | Backend tracks premium status, billing provider, expiry |
| **Purchase History** | ✓ Complete | Backend stores all purchase attempts and outcomes |
| **Rate Limit Monitoring** | ✓ Complete | Backend logs rate limit violations |
| **Installation Registry** | ✓ Complete | Backend tracks install ID, attestation status, last seen |

---

## 10. Pages / Routes / Screens Breakdown

### Route Hierarchy

```
GoRouter (initialLocation: '/')
├── / — SplashScreen (loading check)
├── /onboarding — OnboardingScreen (intro + setup)
├── /unlock — BiometricUnlockScreen (lock recovery)
├── /privacy-upgrade — PrivacyUpgradeScreen (data protection migration)
├── /data-protection-recovery — DataProtectionRecoveryScreen (recovery UI)
│
└── StatefulShellRoute (tabbed bottom navigation)
    ├── Branch 0: /dashboard — HomeDashboardScreen
    ├── Branch 1: /debts — DebtsListScreen
    │   ├── /debts/add — AddEditDebtScreen
    │   ├── /debts/:id — DebtDetailsScreen
    │   ├── /debts/:id/edit — EditDebtLoaderScreen
    │   ├── /debts/:id/add-payment — AddPaymentScreen
    │   └── /debts/:id/payments — PaymentHistoryScreen
    ├── Branch 2: /scan — ScanImportHubScreen
    │   ├── /scan/camera — CameraCaptureScreen
    │   ├── /scan/processing — OCRProcessingScreen
    │   └── /scan/review — ParsedReviewConfirmScreen
    ├── Branch 3: /strategy — StrategySimulatorScreen
    └── Branch 4: /settings — SettingsScreen
│
├── /reports — ReportsScreen (analytics, export)
├── /notifications — NotificationSettingsScreen
├── /backups — DataBackupsScreen
├── /premium — PremiumScreen (subscription options)
├── /security — SecurityPrivacyScreen
└── /help — HelpAboutScreen
```

### Screen Details

#### Public / Pre-Auth Routes

| Screen | File | Purpose | Permissions |
|--------|------|---------|-------------|
| **SplashScreen** | `onboarding/presentation/splash_screen.dart` | Initial app load, check onboarding status | None required |
| **OnboardingScreen** | `onboarding/presentation/onboarding_screen.dart` | 3-slide intro + currency/locale/security setup | First launch only |
| **BiometricUnlockScreen** | `auth_lock/presentation/biometric_unlock_screen.dart` | Unlock app with biometric or PIN | Requires local_auth permission |

#### Main Tab Routes (Protected)

| Tab | Screen | File | Purpose | Features |
|-----|--------|------|---------|----------|
| **Dashboard** | HomeDashboardScreen | `dashboard/presentation/home_dashboard_screen.dart` | Overview of all debts, totals, debt-free forecast | Charts, quick actions, empty state |
| **Debts** | DebtsListScreen | `debts/presentation/debts_screens.dart` | List all debts with status badges | Filter, sort, search, multi-select |
| **Debts** (sub) | AddEditDebtScreen | `debts/presentation/debts_screens.dart` | Create or modify debt entry | Form validation, date picker, type select |
| **Debts** (sub) | DebtDetailsScreen | `debts/presentation/debts_screens.dart` | Full debt view with payment history | Charts, add payment, edit, delete |
| **Debts** (sub) | EditDebtLoaderScreen | `debts/presentation/debts_screens.dart` | Load debt, pre-fill edit form | Async loading |
| **Debts** (sub) | AddPaymentScreen | `debts/presentation/debts_screens.dart` | Log a payment against a debt | Payment method select, date/amount entry |
| **Debts** (sub) | PaymentHistoryScreen | `debts/presentation/debts_screens.dart` | Historical payments for a debt | Table, export, total calculations |
| **Scan** | ScanImportHubScreen | `scan_import/presentation/scan_screens.dart` | Import document hub (sources, recent imports) | Source buttons, recent list |
| **Scan** (sub) | CameraCaptureScreen | `scan_import/presentation/scan_screens.dart` | Camera preview with capture controls | Flash, zoom, orientation |
| **Scan** (sub) | OCRProcessingScreen | `scan_import/presentation/scan_screens.dart` | OCR and optional cloud extraction | Progress indicator, cloud toggle |
| **Scan** (sub) | ParsedReviewConfirmScreen | `scan_import/presentation/scan_screens.dart` | Review extracted data before saving | Editable fields, line item selection |
| **Strategy** | StrategySimulatorScreen | `strategy/presentation/strategy_simulator_screen.dart` | Strategy comparison and simulation | Tabs: Snowball, Avalanche, Custom |
| **Settings** | SettingsScreen | `settings/presentation/settings_screens.dart` | Theme, currency, strategy, notifications, etc. | List items, links to sub-screens |

#### Secondary / Non-Tab Routes (Protected)

| Screen | File | Purpose |
|--------|------|---------|
| **ReportsScreen** | `reports/presentation/reports_screen.dart` | Charts, timeline, category breakdown, export |
| **NotificationSettingsScreen** | `settings/presentation/settings_screens.dart` | Enable/disable reminders, set quiet hours |
| **DataBackupsScreen** | `settings/presentation/data_protection_screens.dart` | Create, inspect, restore backups |
| **PremiumScreen** | `settings/presentation/settings_screens.dart` | Show subscription plans, purchase flow |
| **SecurityPrivacyScreen** | `settings/presentation/data_protection_screens.dart` | App lock, balance hiding, cloud consent |
| **HelpAboutScreen** | `settings/presentation/settings_screens.dart` | Privacy policy, FAQ, version info |
| **PrivacyUpgradeScreen** | `settings/presentation/data_protection_screens.dart` | Migration flow for local encryption upgrade |
| **DataProtectionRecoveryScreen** | `settings/presentation/data_protection_screens.dart` | Recovery if encryption bootstrap fails |

---

## 11. API / Backend Breakdown

### Backend Architecture

**Technology:** Node.js + Fastify + Zod + PostgreSQL + Redis

**Port:** Configurable (default 8787)

**Environment:** dev, staging, production (configured via NODE_ENV)

### API Endpoints

#### Health Checks

```
GET /health/live
GET /health/ready
Response: { ok: true, status: "live"|"ready" }
```

#### Authentication & Session

##### 1. Bootstrap Challenge
```
POST /v1/mobile/bootstrap/challenge
Request: {
  app_version: string,
  platform: string,
  install_id: string
}
Response: {
  challenge_id: string,
  nonce: string,
  attestation_provider: "play_integrity",
  instructions: string
}
Logic:
- Create challenge record in DB (expires in 5 min)
- Generate cryptographic nonce
- Save audit event
```

##### 2. Bootstrap Verify
```
POST /v1/mobile/bootstrap/verify
Request: {
  challenge_id: string,
  install_id: string,
  attestation_token: string,  // from Play Integrity API
  device: {
    app_version: string,
    platform: string
  }
}
Response: {
  access_token: string,  // JWT
  refresh_token: string,  // Opaque token (hash stored)
  expires_in_seconds: number,
  session: {
    install_id: string,
    attestation_status: string
  }
}
Logic:
- Verify challenge exists and not consumed
- Verify attestation token signature via Play Integrity
- Create install session record
- Issue access + refresh tokens
- Save audit event
Error Codes:
- invalid_challenge: Challenge not found
- challenge_consumed: Already used
- challenge_expired: Expired
- attestation_failed: Invalid signature/nonce
```

##### 3. Token Refresh
```
POST /v1/mobile/token/refresh
Request: {
  refresh_token: string
}
Response: {
  access_token: string,  // New JWT
  refresh_token: string,  // New opaque token
  expires_in_seconds: number
}
Logic:
- Hash incoming refresh token
- Look up token record (must not be revoked, not expired)
- Revoke old token
- Issue new pair
Error Codes:
- invalid_refresh_token: Token not found, revoked, or expired
```

#### Capabilities & Quota

##### 4. Get Capabilities
```
GET /v1/mobile/me/capabilities
Headers: Authorization: Bearer <access_token>
Response: {
  premium: boolean,
  features: [string],
  free_scan_remaining: number,
  rate_limit_state: "ok"|"limited",
  entitlement: {
    is_premium: boolean,
    product_id: string | null,
    plan_id: string | null,
    status: string,
    valid_until: string (ISO) | null,
    features: [string]
  }
}
Logic:
- Verify JWT, extract installId
- Get quota snapshot for current month
- Get entitlement record
- Return merged state
```

#### Billing

##### 5. Verify Subscription
```
POST /v1/billing/google-play/verify
Headers: Authorization: Bearer <access_token>
Request: {
  install_id: string,
  package_name: string,
  product_id: string,
  base_plan_id: string | null,
  purchase_token: string
}
Response: {
  entitlement: { /* as above */ }
}
Logic:
- Verify install_id matches JWT
- Verify package_name matches config
- Call Google Play Billing Library to verify token
- Normalize provider response
- Update entitlement record
- Save purchase history
- Save audit event
Error Codes:
- install_mismatch: JWT mismatch
- package_mismatch: Unexpected package
- billing_verification_failed: Google Play says invalid
```

##### 6. Restore Purchases
```
POST /v1/billing/google-play/restore
Headers: Authorization: Bearer <access_token>
Request: {
  install_id: string,
  package_name: string,
  purchases: [
    {
      product_id: string,
      base_plan_id: string | null,
      purchase_token: string
    }
  ]
}
Response: {
  entitlement: { /* most recent active entitlement */ }
}
Logic:
- Verify all purchase tokens with Google Play
- For each, normalize and save purchase history
- Determine "best" entitlement (most valid, longest expiry)
- Update entitlement record
- Save audit events
```

#### AI Extraction

##### 7. Cloud Extraction
```
POST /v1/mobile/extractions
Headers: Authorization: Bearer <access_token>
Request: {
  install_id: string,
  request_id: string,
  document_classification: "creditCardStatement" | "loanStatement" | ... | "unknown",
  normalized_ocr_text: string  // from on-device ML Kit
}
Response: {
  extraction: {
    issuer_name: string | null,
    title: string | null,
    debt_type: string | null,
    current_balance: number | null,
    apr_percentage: number | null,
    due_date: string (ISO) | null,
    minimum_payment: number | null,
    currency: string | null,
    confidence: number (0-1)
    // ... and 10+ other fields
  },
  summary: { /* same structure as extraction */ },
  line_items: [
    {
      date: string (ISO) | null,
      description: string | null,
      amount: number | null,
      type: string | null,
      confidence: number (0-1),
      warnings: [string]
    }
  ],
  warnings: [string],
  quota: {
    allowed: boolean,
    remaining_free_scans: number,
    premium_required: boolean,
    reset_at: string (ISO)
  },
  meta: {
    request_id: string,
    provider: "gemini",
    model: string,
    classification: string,
    duration_ms: number
  }
}
Logic:
- Verify JWT, extract installId
- Check install rate limit (20 req/min), IP rate limit (60 req/min)
- If free user, reserve quota slot (5/month)
- If quota exceeded, return 429
- Call Gemini API with classification-specific prompt
- Normalize response via Zod schema
- Calculate OCR hash (for deduplication)
- Store extraction audit
- Commit quota slot if previously reserved
- Return normalized response + remaining quota
Error Codes:
- rate_limited: Too many requests (return retry_at)
- quota_exhausted: Free quota full
- extraction_failed: Provider error
```

### Request/Response Schemas (Zod)

**Extraction Schema (normalized):**
```typescript
{
  issuer_name: string | null,
  title: string | null,
  debt_type: string | null,
  current_balance: number | null,
  original_balance: number | null,
  apr_percentage: number | null,
  minimum_payment: number | null,
  due_date: string (ISO) | null,
  payment_date: string (ISO) | null,
  payment_amount: number | null,
  currency: string | null,
  notes: string | null,
  confidence: number (0-1),
  last4: string | null,
  raw_detected_labels: [string],
  statement_start_date: string (ISO) | null,
  statement_end_date: string (ISO) | null
}
```

**Statement Line Item Schema:**
```typescript
{
  id: string | null,
  date: string (ISO) | null,
  description: string | null,
  amount: number | null,
  type: string | null,
  confidence: number (0-1),
  currency: string | null,
  warnings: [string]
}
```

### Database Schema (PostgreSQL)

**Core Tables:**

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `attestation_challenges` | Challenge lifecycle | challenge_id, install_id, nonce, expires_at, consumed_at |
| `install_sessions` | Device registration | install_id, attestation_status, blocked_until, last_seen_at |
| `refresh_tokens` | JWT rotation | token_id, install_id, token_hash, expires_at, revoked_at |
| `usage_counters` | Quota tracking | install_id, month_key, cloud_extractions, reserved_extractions |
| `quota_reservations` | Pending quota slots | reservation_id, install_id, month_key, status, expires_at |
| `premium_entitlements` | Subscription state | install_id, is_premium, product_id, plan_id, status, valid_until, features (JSONB) |
| `billing_purchase_history` | Purchase records | record_id, install_id, product_id, plan_id, status, payload (JSONB) |
| `extraction_audits` | AI extraction logs | request_id, install_id, classification, provider, status, latency_ms, ocr_hash |
| `audit_events` | General audit log | install_id, event_type, payload (JSONB) |
| `rate_limit_events` | Rate limit log | install_id, ip_address, key, limit_value, remaining, reset_at |

### Error Handling

**Standard Error Response:**
```json
{
  "error": "error_code",
  "message": "Human-readable message",
  "details": { /* optional context */ }
}
```

**HTTP Status Codes:**
- 400: Invalid input (bad request, invalid challenge, etc.)
- 401: Authentication failed (invalid JWT, attestation failed, invalid refresh token)
- 403: Forbidden (install mismatch, package mismatch)
- 429: Rate limited or quota exhausted
- 500: Internal server error

### Security Patterns

1. **Attestation Verification** — All requests require valid Play Integrity attestation on bootstrap
2. **JWT with Short TTL** — Access tokens expire quickly (900s default), refresh tokens rotated on use
3. **Token Hashing** — Refresh tokens hashed before storage (not plaintext)
4. **Rate Limiting** — Per-install + per-IP to prevent abuse
5. **Quota Reservations** — Atomic reserve-then-commit pattern to prevent double-extraction
6. **Audit Logging** — All significant operations logged with timestamp, installId, and payload
7. **PII Redaction** — OCR text previews redacted in logs

### Integration Points

1. **Google Play Integrity API** — Verify device authenticity
2. **Google Play Billing Library** — Verify subscription purchases
3. **Gemini API** — AI extraction of financial data from OCR text

---

## 12. Database and Data Model Breakdown

### Frontend Database (SQLite + Drift)

**Database:** `app_database.dart` + `app_database.g.dart` (generated)

**Type:** SQLite with SQLCipher encryption

**Schema Version:** 7

**Encryption:** On-device via `sqlcipher_flutter_libs`

#### Tables

##### 1. DebtsTable
```dart
class DebtsTable extends Table {
  TextColumn get id;  // UUID
  TextColumn get title;
  TextColumn get creditorName;
  TextColumn get type;  // DebtType enum (creditCard, loan, etc.)
  TextColumn get currency;
  RealColumn get originalBalance;
  RealColumn get currentBalance;
  RealColumn get apr;  // Annual Percentage Rate
  RealColumn get minimumPayment;
  DateTimeColumn get dueDate;  // nullable
  TextColumn get paymentFrequency;  // PaymentFrequency enum
  DateTimeColumn get createdAt;
  DateTimeColumn get updatedAt;
  TextColumn get notes;  // default: ''
  TextColumn get tagsJson;  // JSON array: ['tag1', 'tag2']
  TextColumn get financialTermsJson;  // Promo rates, recurring fees, etc.
  TextColumn get status;  // DebtStatus: active, paidOff, archived
  BoolColumn get remindersEnabled;
  IntColumn get customPriority;  // User-defined order (1, 2, 3...)
}
PrimaryKey: {id}
```

**Key Points:**
- Supports credit cards, personal loans, student loans, car loans, mortgages, BNPL, family loans, utility arrears
- APR is used by strategy engine for interest calculations
- Tags allow arbitrary categorization
- `financialTermsJson` encodes promo rates, recurring fees, late fee rules
- `status` allows soft-archiving without deletion

##### 2. PaymentsTable
```dart
class PaymentsTable extends Table {
  TextColumn get id;
  TextColumn get debtId;  // Foreign key to DebtsTable
  RealColumn get amount;
  DateTimeColumn get date;
  TextColumn get method;  // enum or free text
  TextColumn get sourceType;  // PaymentSourceType: payment, refund, credit, etc.
  TextColumn get notes;
  TextColumn get tagsJson;
  DateTimeColumn get createdAt;
}
PrimaryKey: {id}
ForeignKey: debtId references DebtsTable.id
```

**Key Points:**
- Each payment tied to a specific debt
- Supports multiple payment methods
- Payment history used for charts and debt details

##### 3. ImportedDocumentsTable
```dart
class ImportedDocumentsTable extends Table {
  TextColumn get id;
  TextColumn get localPath;  // File path in app storage
  TextColumn get storageRef;  // Secure vault reference (nullable, encrypted)
  TextColumn get sourceType;  // DocumentSourceType enum
  TextColumn get mimeType;
  DateTimeColumn get createdAt;
  DocumentLifecycleState get lifecycleState;  // imported, processed, linked, pendingDeletion, purged
  TextColumn get linkedDebtId;  // nullable, links to debt
  TextColumn get rawOcrText;  // Full OCR output (nullable, encrypted)
  TextColumn get parseStatus;  // pending, success, failed, discarded
  TextColumn get parseVersion;  // Version of parser used
  BoolColumn get deleted;
  DateTimeColumn get retentionExpiresAt;  // When to purge
  DateTimeColumn get rawOcrExpiresAt;  // When to delete OCR text
  DateTimeColumn get processedAt;  // nullable
  DateTimeColumn get linkedAt;  // When linked to debt
  DateTimeColumn get pendingDeletionAt;  // Soft-delete timestamp
  DateTimeColumn get purgedAt;  // Hard-delete timestamp
  DateTimeColumn get encryptedAt;  // When moved to vault
  BoolColumn get hasRawOcrText;
}
PrimaryKey: {id}
```

**Key Points:**
- Tracks document lifecycle from import to purge
- `storageRef` points to encrypted vault storage (SecureDocumentVaultService)
- `rawOcrText` retained separately with expiry policy (configurable: 7, 30 days or manual)
- Supports PII retention policies (GDPR-friendly)

##### 4. ParsedExtractionsTable
```dart
class ParsedExtractionsTable extends Table {
  TextColumn get id;
  TextColumn get documentId;  // Foreign key to ImportedDocumentsTable
  TextColumn get classification;  // DocumentClassification enum
  RealColumn get confidence;  // 0-1 confidence score from ML/AI
  TextColumn get payloadJson;  // Full normalized extraction (ExtractionCandidate)
  TextColumn get ambiguityNotes;  // Flagged issues
  DateTimeColumn get createdAt;
}
PrimaryKey: {id}
ForeignKey: documentId references ImportedDocumentsTable.id
```

**Key Points:**
- Stores backend AI response (or local heuristic fallback)
- `payloadJson` includes all extracted fields: issuer, balance, APR, due date, line items, etc.
- Enables reviewing historical extractions

##### 5. ReminderRulesTable
```dart
class ReminderRulesTable extends Table {
  TextColumn get id;
  TextColumn get debtId;  // nullable, or global
  TextColumn get kind;  // ReminderKind enum: dueLead, dueToday, overdue, milestone
  TextColumn get schedule;  // Cron-like or relative (e.g., "1 day before due")
  BoolColumn get enabled;
  TextColumn get notificationChannelId;
}
PrimaryKey: {id}
```

**Key Points:**
- Defines reminder schedule (rules) for reminders
- Executed by ReminderOrchestrator service

##### 6. ReminderEventsTable
```dart
class ReminderEventsTable extends Table {
  TextColumn get id;
  TextColumn get debtId;  // nullable
  TextColumn get kind;  // ReminderKind
  DateTimeColumn get scheduledFor;
  DateTimeColumn get firedAt;  // nullable, when reminder was shown
  TextColumn get status;  // scheduled, fired, dismissed, snoozed
  DateTimeColumn get createdAt;
}
PrimaryKey: {id}
```

**Key Points:**
- Records individual reminder events (instances)
- Allows snooze/dismiss tracking

##### 7. ScenariosTable
```dart
class ScenariosTable extends Table {
  TextColumn get id;
  TextColumn get strategyType;  // StrategyType enum: snowball, avalanche, customPriority
  RealColumn get extraPayment;  // Additional monthly payment
  RealColumn get budget;  // Total available monthly
  DateTimeColumn get createdAt;
  TextColumn get label;  // User-supplied name
  RealColumn get baselineInterest;  // Total interest without extra payment
  RealColumn get optimizedInterest;  // Total interest with extra payment
  IntColumn get monthsToPayoff;
}
PrimaryKey: {id}
```

**Key Points:**
- Stores user-created strategy scenarios
- Enables comparison across saved simulations (Premium feature)

##### 8. AppPreferencesTable
```dart
class AppPreferencesTable extends Table {
  IntColumn get key;  // default: 1 (singleton)
  TextColumn get currencyCode;  // 'USD', 'EUR', etc.
  TextColumn get locale;
  TextColumn get themeMode;  // system, light, dark
  BoolColumn get notificationsEnabled;
  TextColumn get appRelockTimeout;  // immediate, seconds30, minutes5
  TextColumn get documentRetentionMode;  // days7, days30, manual
  BoolColumn get hideBalances;
  BoolColumn get enableCloudExtraction;  // User opt-in for AI extraction
  DateTimeColumn get cloudExtractionConsent;  // When user enabled it
  BoolColumn get enableBiometricLock;
  BoolColumn get privacyShield;  // Blur on background
  Int get purgeFailedImportsAfterHours;
  BoolColumn get dataProtectionExplainerSeen;
}
PrimaryKey: {key}
```

**Key Points:**
- Singleton row (key=1)
- Stores user preferences for UI, security, privacy
- `enableCloudExtraction` is explicit consent flag for backend AI

##### 9. SubscriptionStateTable
```dart
class SubscriptionStateTable extends Table {
  IntColumn get key;  // default: 1 (singleton)
  BoolColumn get isPremium;
  TextColumn get productId;  // 'premium'
  TextColumn get planId;  // 'monthly', 'yearly'
  TextColumn get billingProvider;  // 'google_play'
  TextColumn get status;  // 'active', 'expired', 'pending'
  DateTimeColumn get validUntil;  // nullable
  BoolColumn get autoRenewing;
  DateTimeColumn get lastVerifiedAt;  // When we last verified with Play Billing
  TextColumn get unlockedFeaturesJson;  // JSON array of feature IDs
}
PrimaryKey: {key}
```

**Key Points:**
- Synced from backend entitlement record
- Tracks premium status, expiry, auto-renewal
- Unlocked features list controls UI visibility (Premium features)

### Data Model (Domain Layer)

**Models in `shared/models/`:**

1. **Debt** — Core domain entity
2. **Payment** — Individual payment
3. **UserPreferences** — User settings (preferences)
4. **ImportedDocument** — Imported financial document
5. **ParsedExtraction** — Extracted data from document
6. **ExtractionCandidate** — Extraction in review (before save)
7. **StrategyRequest** — User request for strategy simulation
8. **StrategyResult** — Strategy simulation output with projections
9. **Scenario** — Saved strategy scenario
10. **DashboardSnapshot** — Computed view of debt state (totals, forecast)
11. **SubscriptionState** — Premium subscription status
12. **BillingPlan**, **BillingCatalog** — Subscription offerings
13. **DebtFinancialTerms** — Extended debt attributes (promo rates, fees)
14. **ReminderRule**, **ReminderEvent** — Reminder scheduling

### Database Relationships

```
DebtsTable
  ├─→ PaymentsTable (1:many)
  ├─→ ImportedDocumentsTable (1:many, via linkedDebtId)
  └─→ ReminderRulesTable (1:many, via debtId)

ImportedDocumentsTable
  └─→ ParsedExtractionsTable (1:many, via documentId)

ReminderRulesTable
  └─→ ReminderEventsTable (1:many, via id)

ScenariosTable (standalone)
AppPreferencesTable (singleton)
SubscriptionStateTable (singleton)
```

### Data Flow Patterns

#### Pattern 1: Create Debt from Import
```
User confirms ParsedReviewConfirmScreen
    ↓
ImportReviewBundle extracts fields
    ↓
CreateDebtCommand issued to Drift
    ↓
Debt inserted → DebtsTable
    ↓
ImportedDocument marked as linked (linkedDebtId = debtId)
    ↓
Watch providers trigger refresh
    ↓
UI updates (dashboard, debts list)
```

#### Pattern 2: Compute Dashboard
```
Watch allDebtsProvider
    ↓
Watch allPaymentsProvider
    ↓
DashboardService.compute() aggregates:
  - sum(currentBalance) → totalOutstanding
  - sum(payments.amount) → totalPaid
  - sum(minimumPayment) → monthlyMinimums
    ↓
PortfolioProjectionService projects debt-free date
    ↓
DashboardSnapshot emitted
    ↓
Dashboard re-renders with new totals
```

#### Pattern 3: Strategy Simulation
```
User selects strategy + enters extra payment
    ↓
StrategyEngine.simulate(debts, request)
    ↓
PortfolioProjectionService.projectPortfolio()
    ↓
MoneyMath calculates month-by-month state
    ↓
Returns timeline + interest comparison
    ↓
UI renders strategy cards
    ↓
User taps "Save" → ScenariosTable insert
```

### Migrations

**Schema Version 7 (current):**
- `app_database.dart` migration handler checks `from < version`
- For historical versions, migrations may drop/add columns (strategy handling, financial terms)
- `onUpgrade` callback ensures backward compatibility

---

## 13. Authentication and Authorization

### Authentication Architecture

**Model:** Device-based + Play Integrity attestation

### Session Flow

#### Step 1: Bootstrap Challenge
```
1. App startup
2. Check if valid JWT exists in ProtectedPreferencesStore
3. If expired or missing:
   - Generate or retrieve installId (UUID, stored securely)
   - POST /v1/mobile/bootstrap/challenge with app_version, platform
   - Backend returns challenge_id, nonce
4. App stores challenge temporarily
```

#### Step 2: Attestation & Token Issue
```
1. App calls PlayIntegrityAttestationService.requestAttestationToken()
   - Invokes native Android method channel (debt_destroyer/play_integrity)
   - Native code calls Play Integrity API with nonce
   - Returns attestation token (signed JWT-like object from Google)
2. App POSTs to /v1/mobile/bootstrap/verify with attestation_token
3. Backend validates:
   - Challenge exists and not consumed
   - Attestation token signature valid (verified with Play Integrity servers)
   - Nonce matches challenge
4. Backend issues:
   - access_token (JWT, 15-min TTL, signed with JWT_ACCESS_SECRET)
   - refresh_token (opaque, 30-day TTL, hash stored in DB)
5. App stores tokens securely (flutter_secure_storage)
```

#### Step 3: Access & Refresh
```
1. Subsequent requests include Authorization: Bearer <access_token>
2. Backend verifies JWT signature with JWT_ACCESS_SECRET
3. On expiry (900s), app POSTs to /v1/mobile/token/refresh
4. Backend validates refresh_token, revokes it, issues new pair
5. App updates tokens
```

### Authorization Patterns

#### Route Protection
**Frontend:**
- Guarded by AppSecurityCoordinator
- Sensitive routes (dashboard, debts, strategy) require:
  - Valid JWT (checked via BackendSessionManager)
  - App not locked (biometric/PIN required if enabled)
- Public routes: splash, onboarding

**Backend:**
- All routes except /health/* require valid JWT
- Extract installId from JWT (claim verified by signature)
- Check quota/entitlement based on installId

#### Feature Access
**Based on SubscriptionStateTable.isPremium:**
- Unlimited cloud extractions (free: 5/month)
- CSV export (free: manual data entry only)
- PDF import (free: camera/gallery only)
- Advanced reports (free: basic dashboard)
- Scenario saving (free: single scenario only)

#### Premium Entitlement Check
```dart
// In backend
const entitlement = await store.getEntitlement(installId);
if (!entitlement.isPremium && resource === 'unlimited_extractions') {
  throw error 429 quota_exhausted
}

// In frontend (Riverpod)
final subscription = ref.watch(subscriptionStateProvider).valueOrNull;
final isPremium = subscription?.isPremium ?? false;
if (!isPremium && featureId === 'unlimitedScans') {
  showPremiumRequired();
}
```

### Play Integrity Attestation Details

**Purpose:** Verify device authenticity and prevent bot/replay attacks

**Fields:**
- `appVersion` — App version code
- `deviceIntegrity` — Device integrity verdict
- `requestDetails` — Timestamp, nonce verification

**In Development/Test:**
- Optional debug attestation (ALLOW_DEBUG_ATTESTATION=true)
- Debug secret signs HMAC instead of real Play Integrity

**In Production:**
- PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER required
- Real Play Integrity API responses validated

### Biometric/PIN Lock

**Local Control:**
- `BiometricAuthService` wraps `local_auth` package
- User can enable in Security settings
- On re-lock, user prompted with fingerprint/face/PIN
- Timeout configurable: immediate, 30s, 5min

**Does NOT:**
- Replace backend auth (JWT still required)
- Encrypt database (SQLCipher always enabled)
- Act as single factor of auth (device + Play Integrity are primary)

---

## 14. State Management and Data Flow

### Riverpod Provider Architecture

**Philosophy:** Provider-based dependency injection + reactive streams

#### Provider Categories

##### 1. Infrastructure Providers (Singletons)
```dart
// Value providers returning singleton instances
final httpClientProvider = Provider<http.Client>(...)  // HTTP client
final appDatabaseProvider = Provider<AppDatabase>(...)  // SQLite DB
final secureStorageProvider = Provider(...)  // Secure storage
final localNotificationsProvider = Provider(...)  // Notifications
```

##### 2. Configuration Providers
```dart
final backendConfigProvider = Provider<BackendConfig>(...)  // API config
final availableCamerasProvider = Provider<List<CameraDescription>>(...)  // Camera list
```

##### 3. Repository Providers
```dart
final debtsRepositoryProvider = Provider<DebtsRepository>(...)
final paymentsRepositoryProvider = Provider<PaymentsRepository>(...)
final preferencesRepositoryProvider = Provider<PreferencesRepository>(...)
final documentsRepositoryProvider = Provider<DocumentsRepository>(...)
final scenariosRepositoryProvider = Provider<ScenariosRepository>(...)
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(...)
```

##### 4. Service Providers
```dart
final backendAuthServiceProvider = Provider<BackendSessionManager>(...)
final billingServiceProvider = Provider<BillingService>(...)
final reminderOrchestratorProvider = Provider<ReminderOrchestrator>(...)
final dataPortabilityServiceProvider = Provider<DataPortabilityService>(...)
final telemetryProvider = Provider<TelemetryRuntime>(...)
```

##### 5. State Providers (Mutable)
```dart
final appSecurityCoordinatorProvider = StateNotifierProvider<AppSecurityCoordinatorNotifier, AppSecurityState>(...)
```

##### 6. Async Providers (Stream + Future)

**Stream Providers (Reactive data):**
```dart
final userPreferencesProvider = StreamProvider<UserPreferences>(...)  // Watch preferences
final allDebtsProvider = StreamProvider<List<Debt>>(...)  // Watch all debts
final allPaymentsProvider = StreamProvider<List<Payment>>(...)  // Watch all payments
final subscriptionStateProvider = StreamProvider<SubscriptionState>(...)  // Watch subscription
final scenariosProvider = StreamProvider<List<Scenario>>(...)  // Watch scenarios
final documentsProvider = StreamProvider<List<ImportedDocument>>(...)  // Watch imports
final reminderEventsProvider = StreamProvider<List<ReminderEvent>>(...)  // Watch reminders
```

**Future Providers (One-shot async):**
```dart
final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>(...)  // Compute metrics
final debtDetailsProvider = FutureProvider.family<Debt, String>(...)  // Fetch by ID
final paymentHistoryProvider = FutureProvider.family<List<Payment>, String>(...)
final notificationPermissionProvider = FutureProvider<bool>(...)  // Check OS permission
final entitlementRefreshProvider = FutureProvider<SubscriptionState>(...)  // Verify with backend
```

##### 7. Computed Providers (Derived state)
```dart
final debtsGroupedByStatusProvider = Provider<Map<DebtStatus, List<Debt>>>(ref) {
  final debts = ref.watch(allDebtsProvider).valueOrNull ?? [];
  return groupBy(debts, (d) => d.status);
}
```

### Data Flow Pattern

#### Example: Dashboard View Render Cycle
```
1. Build Dashboard Widget
   └─ ref.watch(dashboardSnapshotProvider)

2. Provider resolves:
   └─ Depends on: allDebtsProvider, allPaymentsProvider, userPreferencesProvider
   └─ Each dependency updates from Drift stream

3. DashboardService.compute():
   ├─ Aggregate debt totals
   ├─ Sum payments
   ├─ Calculate debt-free forecast
   └─ Return DashboardSnapshot

4. UI re-renders with:
   ├─ Total outstanding balance
   ├─ Charts (debt distribution, payoff timeline)
   ├─ Metric tiles (paid, minimums)
   └─ Forecast date

5. On user action (add payment):
   └─ PaymentRepository.addPayment()
   └─ Drift notifies stream listeners
   └─ allPaymentsProvider refreshes
   └─ dashboardSnapshotProvider re-computes
   └─ UI re-renders
```

#### Example: Debt Import & Save
```
1. User confirms ParsedReviewConfirmScreen

2. Riverpod action:
   └─ ref.read(debtsRepositoryProvider).addDebt(debt)

3. Repository writes to Drift:
   └─ DebtsTable.insert(debtData)

4. Drift stream notifies:
   └─ allDebtsProvider listeners receive new list

5. Dependent providers update:
   └─ dashboardSnapshotProvider (depends on allDebtsProvider)
   └─ debtsGroupedByStatusProvider

6. UI cascades:
   └─ DebtsListScreen re-renders (new item)
   └─ Dashboard re-renders (updated totals)

7. Reminders may trigger:
   └─ ReminderOrchestrator.reconcile() called
   └─ Scheduling logic runs
   └─ ReminderEventsTable updated
```

### State Notifier Pattern

**AppSecurityCoordinatorNotifier:**
```dart
class AppSecurityCoordinatorNotifier extends StateNotifier<AppSecurityState> {
  syncPreferences(UserPreferences prefs) {
    state = state.copyWith(
      enableBiometricLock: prefs.enableBiometricLock,
      appRelockTimeout: prefs.appRelockTimeout,
    );
  }
  
  handleLifecycleChange(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) {
      // App backgrounded, schedule relock
      state = state.copyWith(lastBackgroundedAt: DateTime.now());
    }
  }
  
  updateRoute(String newRoute) {
    final isSensitive = sensitiveRouteRegistry.isSensitiveLocation(newRoute);
    state = state.copyWith(
      currentRoute: newRoute,
      isSensitiveRoute: isSensitive,
      isLockRequired: isSensitive && _shouldRequireLock(),
    );
  }
}
```

### Watching & Listening

**In UI (watch):**
```dart
final snapshot = ref.watch(allDebtsProvider);
// Re-render on every update
snapshot.when(
  data: (debts) => DebtsList(debts: debts),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => ErrorWidget(),
);
```

**In Widgets (listen):**
```dart
ref.listen(userPreferencesProvider, (previous, next) {
  next.whenData((prefs) {
    // Side effect: update security coordinator
    ref.read(appSecurityCoordinatorProvider.notifier)
        .syncPreferences(prefs);
  });
});
```

**Manual reads:**
```dart
final debts = ref.read(allDebtsProvider).valueOrNull ?? [];
// One-shot read, no watching
```

### Async Loading States

**Stream data shape:**
```dart
AsyncValue<T> = 
  | AsyncData(T)  // data loaded
  | AsyncLoading  // loading
  | AsyncError(Exception, StackTrace)  // error
```

**Handling:**
```dart
snapshot.whenData((data) => ...)  // Only data
snapshot.whenLoading(() => ...)  // Only loading
snapshot.whenError((err, st) => ...)  // Only error
snapshot.when(
  data: (data) => ...,
  loading: () => ...,
  error: (err, st) => ...,
)
```

---

## 15. UI / Component System

### Design System

**Foundation:**
- **Framework:** Flutter Material Design 3
- **Theme:** Light + Dark modes, system preference
- **Typography:** Google Fonts (configurable)
- **Color Scheme:** Material Design palette (primary, secondary, tertiary, error)

### Component Library (`core/widgets/app_widgets.dart`)

**Common Wrappers:**
- `AppPage` — Scaffold wrapper with title, actions, FAB
- `AppCard` — Material Card with padding, elevation
- `AppButton` — FilledButton wrapper with consistent styling
- `EmptyStateView` — Icon + title + message for empty states
- `ErrorView` — Error display with retry button

**Data Display:**
- `SensitiveValueText` — Currency/balance text with optional masking (privacy)
- `DebtCard` — Debt item card (title, balance, APR, status badge)
- `PaymentTile` — Payment history row
- `StrategyComparison` — Side-by-side scenario comparison

**Forms:**
- Text input fields (currency, date, amount)
- Dropdown selectors (debt type, strategy, payment frequency)
- Checkbox/toggle for preferences
- Date picker via Material showDatePicker

**Charts:**
- `fl_chart` library integration:
  - Pie chart (debt distribution by type)
  - Line chart (payoff timeline)
  - Bar chart (interest comparison)

### Layout Patterns

#### Dashboard Layout
```
┌─ AppBar with title "Dashboard" + reports icon ─┐
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌─ Card: Total Outstanding ────┐               │
│  │  $15,234.56                   │               │
│  │  ┌─────┬─────────┐           │               │
│  │  │Total│ Monthly │           │               │
│  │  │Paid │Minimums │           │               │
│  │  └─────┴─────────┘           │               │
│  └────────────────────────────────┘               │
│                                                  │
│  ┌─ Card: Debt-Free Forecast ──┐               │
│  │  In 5 years, 3 months        │               │
│  └────────────────────────────────┘               │
│                                                  │
│  ┌─ Card: Debt Distribution ───┐               │
│  │  [Pie Chart]                 │               │
│  └────────────────────────────────┘               │
│                                                  │
└─ FloatingActionButton: Scan ──────────────────────┘
```

#### Debts List Layout
```
┌─ AppBar "Debts" ────────────────────────┐
├─────────────────────────────────────────┤
│ [Filter] [Sort]                         │
├─────────────────────────────────────────┤
│ ┌─ DebtCard 1 ────────────────────────┐ │
│ │ Credit Card                     │ ACTIVE
│ │ Current Bank      $3,500 / $5,000   │
│ │ 22.5% APR                          │
│ └────────────────────────────────────┘ │
│ ┌─ DebtCard 2 ────────────────────────┐ │
│ │ Car Loan                        │ ACTIVE
│ │ AutoFinance      $8,200 / $12,000   │
│ │ 5.2% APR                          │
│ └────────────────────────────────────┘ │
│ ┌─ Add Button ───────────────────────┐ │
│ │ + Add New Debt                      │ │
│ └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### Scan & OCR Flow Layout
```
ScanImportHubScreen
  ├─ "Import sources:"
  ├─   [Camera] [Gallery] [Receipt] [PDF]
  ├─ "Recent imports:"
  └─   [Import list]

CameraCaptureScreen
  ├─ [Camera preview]
  └─ [Capture button] [Flip camera] [Flash]

OCRProcessingScreen
  ├─ [Progress indicator]
  ├─ "Extracting text..."
  └─ [Cloud extraction toggle: ON/OFF]

ParsedReviewConfirmScreen
  ├─ Classification: "Credit Card Statement" (confidence: 92%)
  ├─ Fields (editable):
  │  ├─ Issuer: [Capital One            ]
  │  ├─ Balance: [$3,456.78             ]
  │  ├─ APR: [22.5                      ]
  │  └─ Due Date: [2024-03-15           ]
  ├─ Line Items (selectable):
  │  ├─ ☐ 2024-02-15 | Payment | -$100
  │  ├─ ☐ 2024-02-18 | Purchase | +$45.99
  │  └─ ☐ 2024-02-20 | Interest | +$67.23
  └─ [Discard] [Save]
```

### Responsive Design

**Breakpoints:**
- Phone (default) — Full-width single column
- Tablet (≥600dp) — Side-by-side layouts, expanded cards
- Large (≥900dp) — Multi-pane layouts (not yet implemented)

**Adaptations:**
- Cards use `Flexible`/`Expanded` for width
- Forms single-column on phone, 2-column on tablet
- Charts responsive via `fl_chart`'s size callbacks

### Accessibility

**Implemented:**
- Semantic labels on buttons/icons
- High contrast for dark mode
- Readable font sizes (minimum 14pt for body)
- Color not the only indicator (status badges use icons + color)

**Gaps (Inferred):**
- No explicit screen reader testing mentioned
- Form validation error messages may lack screen reader context

---

## 16. External Integrations

### Google Play Services

#### 1. Play Integrity API
**Purpose:** Device attestation for secure backend access

**Configuration:**
- `PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER` — Google Cloud project number
- `PLAY_INTEGRITY_PACKAGE_NAME` — App package name

**Flow:**
1. Frontend calls native Android method channel
2. Android calls Play Integrity API (via Google Play Services on device)
3. Backend receives JWT-like token, validates with Google servers
4. Backend issues JWT for further API access

**Risk Mitigation:**
- Dev mode allows debug attestation (HMAC-signed)
- Production enforces real Play Integrity

#### 2. Google Play Billing Library
**Purpose:** Subscription verification and entitlement management

**Configuration:**
- `PREMIUM_PRODUCT_ID` — Product ID in Play Console (e.g., "premium")
- `PREMIUM_MONTHLY_BASE_PLAN_ID` — Subscription plan ID (e.g., "monthly")
- `PREMIUM_YEARLY_BASE_PLAN_ID` — Subscription plan ID (e.g., "yearly")

**Flow:**
1. Frontend uses InAppPurchase package to open Play Billing dialog
2. User selects plan and completes purchase
3. Play Billing returns purchase token
4. Frontend sends token to backend /v1/billing/google-play/verify
5. Backend verifies with Google Play Licensing API
6. Backend updates entitlement record
7. Frontend checks subscription state, unlocks premium features

**Entitlements Managed:**
- `isPremium` — Boolean flag
- `planId` — Subscription type (monthly/yearly)
- `status` — active, expired, pending, canceled
- `validUntil` — Expiry date
- `autoRenewing` — Renewal status
- `features` — JSON array of unlocked feature IDs

### Firebase

#### 1. Firebase Analytics
**Purpose:** Event tracking and user behavior analysis

**Configuration:**
- Loaded via `google-services.json` (Firebase Console)
- Environment: `APP_ENV`, `APP_FLAVOR` define which project

**Events Tracked:**
- App opens
- Screen views (via telemetry router observer)
- User actions (debt added, payment logged, extraction completed)
- Feature usage (strategy simulation, export, backup)
- Errors (caught exceptions)

**Fallback:**
- If Firebase config missing, uses NoopAnalyticsService (silent no-op)

#### 2. Firebase Crashlytics
**Purpose:** Crash reporting and error monitoring

**Configuration:**
- Auto-enabled in Release builds
- Disabled in Debug (set forceCrashlytics to false)

**Behavior:**
- Uncaught exceptions forwarded to Crashlytics
- `FlutterError.onError` handler logs framework errors
- `WidgetsBinding.platformDispatcher.onError` logs platform errors
- `runZonedGuarded` catches zone errors

**Data Sent:**
- Crash stack trace
- Device info (OS, app version)
- Custom breadcrumbs/logs

### Google ML Kit

**Purpose:** On-device text recognition (OCR)

**Configuration:**
- `google_mlkit_text_recognition` package
- Latin script recognition enabled

**Flow:**
1. User captures/selects image (camera, gallery, PDF)
2. MlKitOcrService processes image via ML Kit
3. Returns recognized text + line-by-line breakdown
4. App classifies document (credit card, loan, etc.)
5. Optional backend extraction if user opts in

**Privacy:**
- All processing local, no data sent to Google

### Google Gemini API (Backend)

**Purpose:** Structured extraction of financial data from OCR text

**Configuration:**
- `GEMINI_API_KEY` — API key (backend-held, not in app)
- `GEMINI_MODEL` — Model name (default: gemini-2.0-flash)

**Request Flow:**
1. App sends normalized OCR text to `/v1/mobile/extractions`
2. Backend calls Gemini API with classification-specific prompt
3. Gemini returns structured JSON (issuer, balance, APR, due date, line items)
4. Backend normalizes + validates response against schema
5. Backend returns to app

**Supported Document Types:**
- Credit card statements
- Loan statements
- BNPL dashboards
- Receipts
- Generic bills
- Generic finance screenshots

**Error Handling:**
- If Gemini unavailable, app falls back to local heuristics
- Backend logs extraction errors for debugging

**Privacy:**
- Backend holds API key (app never sees it)
- OCR text sent only with user consent
- Backend stores audit log (not raw text, hash + preview)

---

## 17. Config / Environment / Build / Deployment

### Frontend Configuration

#### Environment Variables (`.env` file)

```bash
# Backend API
BACKEND_BASE_URL=https://api.debtdestroyer.com
BACKEND_ENV=production

# Firebase
FIREBASE_ANDROID_API_KEY=...
FIREBASE_ANDROID_APP_ID=...
FIREBASE_MESSAGING_SENDER_ID=...
FIREBASE_PROJECT_ID=...
FIREBASE_STORAGE_BUCKET=...

# Play Integrity
PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=...
PLAY_INTEGRITY_PACKAGE_NAME=com.debtdestroyer.app

# App config
APP_ENV=production
APP_FLAVOR=prod
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true

# Optional: Debug attestation (dev only)
DEBUG_ATTESTATION_SECRET=...
```

#### Build Configuration

**Android Flavors** (defined in `android/app/build.gradle.kts` or similar):
- **dev** — Debug, localhost backend, debug attestation enabled
- **staging** — Release build, staging backend, real attestation
- **prod** — Release build, production backend, real attestation

**Signing:**
- **Dev:** Debug keystore (auto-generated)
- **Staging/Prod:** Signed with release keystore (in CI/CD)

**Build Commands:**
```bash
# Dev
flutter build apk --flavor dev

# Staging
flutter build apk --flavor staging --release

# Production
flutter build apk --flavor prod --release

# Run dev
flutter run --flavor dev
```

#### Drift Database Migration

**Schema Version:** 7

**Migration steps in `app_database.dart`:**
```dart
onUpgrade: (migrator, from, to) async {
  if (from < 2) { /* add financialTermsJson */ }
  if (from < 3) { /* add customPriority */ }
  if (from < 4) { /* add document tables */ }
  if (from < 5) { /* add scenarios */ }
  if (from < 6) { /* add reminder tables */ }
  if (from < 7) { /* add subscription table */ }
}
```

### Backend Configuration

#### Environment Variables

```bash
# Server
NODE_ENV=production
PORT=8787

# Database
POSTGRES_URL=postgresql://user:pass@host:5432/debt_destroyer

# Cache
REDIS_URL=redis://host:6379

# JWT Secrets (required in prod)
JWT_ACCESS_SECRET=... (min 8 chars)
JWT_REFRESH_SECRET=... (min 8 chars)

# Gemini API
GEMINI_API_KEY=...
GEMINI_MODEL=gemini-2.0-flash

# Quotas
FREE_SCAN_LIMIT=5
ACCESS_TOKEN_TTL_SECONDS=900
REFRESH_TOKEN_TTL_DAYS=30

# Play Integrity
PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=...
PLAY_INTEGRITY_PACKAGE_NAME=com.debtdestroyer.app

# Billing
PREMIUM_PRODUCT_ID=premium
PREMIUM_MONTHLY_BASE_PLAN_ID=monthly
PREMIUM_YEARLY_BASE_PLAN_ID=yearly

# Optional: Debug attestation (dev only)
ALLOW_DEBUG_ATTESTATION=false
DEBUG_ATTESTATION_SECRET=...

# Google Play Service Account (for verifying billing)
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=/path/to/service-account.json
```

#### Build & Deployment

**TypeScript Compilation:**
```bash
npm run build  # Outputs to dist/
```

**Start:**
```bash
npm start  # Runs node dist/server.js
```

**Development:**
```bash
npm run dev  # Runs with tsx watch (auto-restart)
```

**Testing:**
```bash
npm test  # Runs vitest
```

**Database:**
- Migrations: Manual SQL in `sql/001_init.sql`
- Applied on startup (backend creates tables if missing)

### CI/CD (Inferred)

**GitHub Actions workflow (presumed):**
- Triggers on push to dev/main branches
- Steps:
  1. Run Flutter analyze
  2. Run Flutter tests
  3. Run backend tests (vitest)
  4. Build Android APK (dev/staging/prod flavor)
  5. [Optional] Upload to Play Store internal track
  6. [Optional] Deploy backend to Cloud Run / server

---

## 18. Important File-by-File Notes

### Critical Frontend Files

| File | Lines | Purpose | Risk |
|------|-------|---------|------|
| `lib/app/bootstrap.dart` | ~80 | App initialization, telemetry setup | Single point of failure for startup |
| `lib/app/app.dart` | ~130 | Root widget, security overlays | Complex lifecycle management |
| `lib/app/router/app_router.dart` | ~100 | Route definitions | Route misconfigs affect UX flow |
| `lib/shared/data/local/app_database.dart` | ~200 | Database schema | Schema migrations critical |
| `lib/shared/data/repositories.dart` | ~800 | Data access layer | Complex Drift query logic |
| `lib/shared/providers/app_providers.dart` | ~400 | Dependency injection | Provider misconfiguration breaks whole app |
| `lib/core/services/security_services.dart` | ~300 | Security coordinator | Lock/unlock logic must be reliable |
| `lib/core/services/backend_services.dart` | ~500 | Backend communication | Authentication failures block all API calls |
| `lib/features/scan_import/domain/import_services.dart` | ~600 | OCR + AI extraction | Parsing logic must handle edge cases |
| `lib/features/strategy/domain/portfolio_projection_service.dart` | ~400 | Strategy simulation | Math errors affect payoff forecasts |

### Critical Backend Files

| File | Lines | Purpose | Risk |
|------|-------|---------|------|
| `backend/src/app.ts` | ~800 | Route handlers, business logic | Core API, errors affect clients |
| `backend/src/services/storage.ts` | ~600 | Database abstractions | Data integrity, concurrency issues |
| `backend/src/services/attestation.ts` | ~300 | Play Integrity verification | Security bypass if weakened |
| `backend/src/services/provider.ts` | ~200 | Gemini API integration | AI extraction failures affect UX |
| `backend/src/services/rate-limit.ts` | ~150 | Rate limiting | DOS vulnerability if bypassed |
| `backend/src/config.ts` | ~100 | Configuration loading | Secrets leak if mishandled |
| `backend/sql/001_init.sql` | ~200 | Schema bootstrap | Schema bugs persist to production |

---

## 19. Strengths of the Current Codebase

### Architecture

1. **Clear Separation of Concerns**
   - Features self-contained with presentation/domain/data layers
   - Services cleanly isolated (billing, security, telemetry, etc.)
   - Repositories abstract data access

2. **Reactive Data Flow**
   - Riverpod providers enable efficient re-rendering (only affected widgets rebuild)
   - Stream-based state minimizes imperative updates
   - Async/Future providers handle loading states cleanly

3. **Type Safety**
   - Strong typing in Dart and TypeScript prevents runtime type errors
   - Zod schemas on backend provide request validation + type coercion
   - Enums prevent invalid state values

4. **Security Practices**
   - Play Integrity attestation prevents bot/emulator abuse
   - JWT with short TTL + refresh token rotation
   - On-device encryption (SQLCipher) for local data
   - Explicit user consent for cloud AI extraction

5. **Privacy-First Design**
   - Local-first operation (works offline)
   - Optional cloud extraction (not mandatory)
   - Data retention policies (automatic purge of OCR)
   - Privacy shield (blur on background)

6. **Offline Resilience**
   - Drift handles local persistence
   - Strategy simulation runs locally (no backend needed)
   - Graceful fallback to local heuristics if AI unavailable

7. **Testing Infrastructure**
   - Unit tests for core services (strategy, metrics, import parsing)
   - Integration tests for backend endpoints
   - Mock implementations for testing (MemoryAppStore)

8. **Code Organization**
   - Consistent file naming and folder structure
   - Feature-based organization scales well
   - Shared domain models reduce duplication

### Operational Excellence

1. **Monitoring & Observability**
   - Firebase Crashlytics captures exceptions
   - Analytics tracks feature usage
   - Backend audit logs capture security events
   - Structured logging with context

2. **Database Design**
   - Foreign keys enforce referential integrity
   - Indexes on frequently queried columns
   - Sensible defaults (not required fields default to empty, false, 0)
   - JSON columns for extensibility (financial terms, features list)

3. **Error Handling**
   - Structured AppError responses from backend
   - Try-catch patterns in Dart services
   - Graceful degradation (noop telemetry if Firebase unavailable)

---

## 20. Weaknesses / Risks / Tech Debt

### Known Issues & Risks

#### Frontend

| Issue | Severity | Details | Mitigation |
|-------|----------|---------|-----------|
| **Large app.dart file** | Medium | AppState management in one place; would benefit from splitting | Consider StateNotifierProvider per concern |
| **Complex OCRProcessingScreen** | Medium | Multiple branches (local OCR, cloud extraction, fallback); hard to test | Extract logic to service layer |
| **No explicit form validation UI** | Medium | Forms show errors but no clear validation rules visible | Add form builder with validation display |
| **Riverpod caching strategy unclear** | Low | Some providers may cache stale data | Review provider invalidation logic |
| **No error boundary for screens** | Low | Widget error in one screen crashes entire app | Wrap screens in ErrorWidget |
| **Testing coverage gaps** | Medium | Many features lack unit/widget tests | Prioritize critical paths (security, billing) |
| **Hard-coded constants scattered** | Low | Magic strings in multiple files | Centralize in app_constants.dart |

#### Backend

| Issue | Severity | Details | Mitigation |
|-------|----------|---------|-----------|
| **No database connection pooling** | Medium | Single pool may bottleneck under load | Configure pg pool settings |
| **Limited error context** | Medium | Some errors logged with minimal detail | Enhance logging with request ID, timing |
| **No rate limit carryover** | Low | Per-minute rates don't account for burst | Consider token bucket algorithm |
| **Gemini prompt injection risk** | Medium | User-controlled OCR text passed to Gemini; prompt injection possible | Sanitize/escape user inputs before LLM calls |
| **No request timeout enforcement** | Low | Long-running provider calls could hang | Add explicit timeout handlers |
| **Single point of failure for storage** | Medium | PostgreSQL failure brings down all services | Add connection retry + fallback cache |

#### Architecture

| Issue | Severity | Details |
|-------|----------|---------|
| **Tight coupling to Google Play** | Medium | App relies on Play Integrity API; no fallback attestation method |
| **Gemini API vendor lock-in** | Medium | AI extraction hardcoded to Gemini; switching providers requires refactor |
| **Firebase dependency** | Low | Analytics/Crashlytics hard-dependency; noop fallback not tested |
| **No distributed tracing** | Low | Hard to track request flows across frontend + backend |
| **No feature flags** | Low | Feature rollout requires code change + redeployment |

#### Operational

| Issue | Severity | Details |
|-------|----------|---------|
| **No backup strategy documented** | Medium | User backups work, but backend data (audit logs, purchase history) not backed up |
| **No disaster recovery plan** | Medium | No tested recovery procedure if database corrupted |
| **Limited monitoring alerts** | Low | No mention of alerting on API errors, quota exhaustion |
| **No API versioning strategy** | Medium | /v1/ routes exist, but no clear upgrade path for v2 |

### Potential Unfinished Features

| Feature | Status | Evidence | Notes |
|---------|--------|----------|-------|
| **Multi-Language Support** | Partial | `intl` package present, no translations found | No i18n strings detected; `locale` preference stored but not used |
| **Advanced Theme Customization** | Inferred Incomplete | Premium feature mentioned but not fully implemented | App supports light/dark/system; custom colors not evident |
| **Milestone Tracking** | Partial | Model exists (`ReminderKind.milestone`) but integration unclear | Reminder system set up but milestone-specific logic not found |
| **Promo Rate Handling** | Partial | `DebtFinancialTerms` has fields but integration unclear | Strategy engine may not account for promo APR expiry |
| **Late Fee Penalties** | Partial | Finance terms model exists but logic not found | Projection warnings mention late fees but calculation not visible |
| **Batch Import** | Not Found | Single document import flow present, no bulk operation | Each document imported individually |
| **Bank Account Linking** | Not Found | No OAuth integration to banks | Manual import only |
| **Multi-Currency Ledger** | Partial | Currency field in Debt model but no conversion logic | Single currency per debt, no cross-currency operations |

### Missing Features

| Feature | Impact | Rationale |
|---------|--------|-----------|
| **End-to-End Tests** | Medium | No test harness covering full user flows (import → strategy → export) |
| **Performance Profiling** | Low | No benchmarks for large debt portfolios (100+ debts) |
| **Accessibility Audit** | Medium | No mention of WCAG compliance testing |
| **Security Audit** | High | No mention of third-party security review (penetration test, code audit) |
| **Changelog / Release Notes** | Low | No versioning history in repo |
| **API Documentation (OpenAPI/Swagger)** | Low | Backend API documented in code, not machine-readable spec |
| **Load Testing** | Low | No tests for backend under concurrent load |

---

## 21. Incomplete / Unclear / Inferred Areas

### Ambiguities Requiring Code Inspection or Runtime Testing

| Area | Question | Evidence | Status |
|------|----------|----------|--------|
| **Reminder Reconciliation** | How does ReminderOrchestrator schedule reminders? | `reminder_services_test.dart` exists but not fully reviewed | ⚠️ Inferred |
| **Duplicate Detection** | How does import review detect potential duplicates? | UI mentions "Duplicate flagged" but logic unclear | ⚠️ Inferred |
| **Payment Method Tracking** | Is payment method stored and analyzed? | Model includes `method` field but no usage evident | ⚠️ Inferred |
| **CSV Export Format** | What columns, ordering, grouping in export? | Service exists but format not fully documented | ⚠️ Inferred |
| **Backup Restore Partial** | Can user restore individual debts vs. full snapshot? | Only full restore found; partial restore not evident | ⚠️ Inferred |
| **Multi-Device Sync** | Does app support multiple devices per user? | No cloud sync mechanism found; implies single device | ⚠️ Single Device |
| **Offline Editing Conflict** | If user edits on two devices offline, what happens? | No conflict resolution visible | ⚠️ Not Supported |
| **Plan Optimization** | Does strategy engine optimize for minimal interest paid? | Avalanche strategy sorts by APR; other heuristics unclear | ⚠️ Inferred |
| **Rate Limiting Bypass** | Could bad actor spoof IP to reset rate limit? | Backend enforces per-install + per-IP; logic seems sound but no mention of IPv6/proxy handling | ⚠️ Needs Review |
| **Attestation Spoofing** | Could debug attestation leak into production? | Code checks NODE_ENV, but config validation could be stronger | ⚠️ Depends on Ops |

### Unclear Integration Points

1. **Notification Permissions** — How does app request notification permission on Android 13+?
   - `permission_handler` package present
   - Code not fully reviewed

2. **Camera Permission** — Runtime permission flow for camera capture?
   - Android requires runtime permissions
   - Not explicitly visible in CameraCaptureScreen

3. **File Storage Permission** — How does backup/restore handle storage access on Android 11+?
   - Scoped storage or Media permissions?
   - Not explicitly visible

4. **Biometric Fallback** — If device lacks biometric hardware, what's the fallback?
   - Model has PIN fallback but implementation unclear

5. **Network Change Handling** — Does app recover from network disconnection during cloud extraction?
   - Riverpod async doesn't explicitly handle network transitions

---

## 22. Glossary of Important Internal Terms

| Term | Definition | Context |
|------|-----------|---------|
| **Install ID** | Unique identifier per app installation (UUID, stored securely) | Used to track entitlements, quota, audit logs |
| **Challenge** | Temporary attestation challenge issued by backend (has nonce, expires 5min) | Play Integrity flow: challenge → verification |
| **Nonce** | Cryptographic random value tied to challenge, included in attestation token | Prevents replay attacks |
| **Attestation Token** | JWT-like object returned by Play Integrity API | Signed by Google, backend verifies signature |
| **Access Token** | Short-lived JWT (15 min) issued by backend after attestation | Included in Authorization header for API calls |
| **Refresh Token** | Long-lived opaque token (30 days) stored (hashed) in backend DB | Used to mint new access token when expired |
| **Entitlement** | Subscription status for an install (premium, plan type, expiry, features) | Synced from Play Billing, cached in app |
| **Quota** | Monthly limit on free cloud extractions (5 by default, unlimited if premium) | Tracked per-install per-month |
| **Reservation** | Temporary hold on quota slot during extraction (released if extraction fails) | Prevents double-counting quota |
| **Extraction** | Process of parsing OCR text into structured debt fields (issuer, balance, APR, etc.) | Local (heuristic) or cloud (AI via Gemini) |
| **OCR** | Optical Character Recognition; converting image to text | Local via ML Kit, runs on device |
| **Document Classification** | Auto-detecting document type (credit card, loan, bill, etc.) | Enables classification-specific extraction logic |
| **Lifecycle State** | ImportedDocument state: imported → processed → linked → pendingDeletion → purged | Tracks document lifecycle |
| **Vault** | Encrypted secure storage for sensitive files (documents, backups) | Uses `SecureDocumentVaultService` + encryption key |
| **Data Protection** | Feature flag + UI for user control over data encryption, retention, cloud consent | Includes privacy shield, balance masking, document purge |
| **Scenario** | Saved strategy simulation with specific strategy, extra payment, and result | Enables comparison across scenarios |
| **Strategy Type** | Payoff strategy: Snowball (lowest balance first), Avalanche (highest APR first), Custom (user-ordered) | Used by StrategyEngine.simulate() |
| **Projection** | Month-by-month simulation of debt payoff with interest, payments, payoff date | Output of StrategyEngine |
| **Premium Feature** | Feature restricted to premium subscribers (unlimited scans, CSV export, PDF import, etc.) | Gated by SubscriptionState.isPremium |
| **Flavor** | Build variant: dev, staging, prod | Determines API endpoints, signing keys, telemetry configuration |
| **Provider** | Riverpod provider instance; manages state, side effects, dependency injection | Examples: debtsProvider, allPaymentsProvider, billingServiceProvider |
| **Drift** | Dart ORM for SQLite; generates type-safe queries, migrations | Abstracts database layer |
| **StatefulShellRoute** | Go Router construct for tabbed navigation (maintains branch state) | Enables bottom nav bar with persistent tab state |
| **AppShell** | Custom widget managing tabbed layout (body + bottom nav) | Renders current branch + navigation bar |
| **Sensitive Route** | Routes that display user financial data (dashboard, debts, strategy, reports) | Subject to app lock + privacy shield |
| **App Lock** | Biometric or PIN lock triggered on app relock after timeout | Protects sensitive routes |
| **Privacy Shield** | Blurred screen overlay shown when app backgrounded (if enabled) | Prevents shoulder surfing on home screen |
| **Balance Masking** | Displaying asterisks instead of actual debt/payment amounts in UI | User preference for sensitive environments |

---

## 23. Concise "Explain This Project to Another LLM" Summary

### What It Is

**Debt Destroyer** is a privacy-first mobile debt management application for Android that enables users to:
- Manually track debts or import financial documents (statements, receipts) via OCR
- Simulate debt payoff strategies (Snowball, Avalanche, Custom) with month-by-month projections
- Schedule reminders, export data, and back up encrypted snapshots

**Unique value:** All personal financial data stored encrypted locally on the device; cloud AI extraction explicitly opt-in, never automatic.

### Tech Stack

**Frontend:** Flutter (Dart) with Riverpod (state), go_router (navigation), Drift + SQLCipher (encrypted local DB)
**Backend:** Node.js + Fastify with TypeScript, Zod (validation), PostgreSQL + Redis
**Auth:** Play Integrity attestation + JWT (access + refresh tokens)
**AI:** On-device ML Kit (OCR) + backend Gemini API (optional structured extraction)
**Billing:** Google Play subscriptions with server-side verification
**Telemetry:** Firebase Analytics + Crashlytics

### Architecture

- **Feature-first:** 8 features (onboarding, auth_lock, dashboard, debts, scan_import, strategy, reports, settings) each with presentation/domain/data layers
- **Reactive streams:** Riverpod providers watch Drift database changes, re-render only affected widgets
- **Offline-first:** Full functionality without backend; cloud extraction gracefully degrades
- **Layered backend:** Route handlers → services → storage abstraction; supports in-memory, PostgreSQL, or custom implementations

### Database Schema

**Frontend (SQLite):**
- `DebtsTable` — Core debts with APR, balance, due date, tags, financial terms
- `PaymentsTable` — Payment history per debt
- `ImportedDocumentsTable` — Imported documents with lifecycle (imported → linked → purged)
- `ParsedExtractionsTable` — Extracted data from documents (issuer, balance, APR, confidence, line items)
- `ReminderRulesTable`, `ReminderEventsTable` — Reminder scheduling
- `ScenariosTable` — Saved strategy simulations
- `AppPreferencesTable` — User settings (currency, theme, security, cloud consent)
- `SubscriptionStateTable` — Premium subscription status

**Backend (PostgreSQL):**
- `install_sessions` — Device registration with attestation status
- `attestation_challenges` — Challenge lifecycle for Play Integrity
- `refresh_tokens` — JWT refresh token storage (hashed)
- `usage_counters` — Monthly extraction quota tracking
- `quota_reservations` — Pending quota slots during extraction
- `premium_entitlements` — Subscription state per install
- `extraction_audits` — AI extraction logs with latency + confidence
- `audit_events` — General event log (bootstrap, billing, extractions)

### Key Workflows

1. **Manual Tracking:** User adds debt → Riverpod writes to Drift → provider refreshes → UI updates
2. **Document Import:** User captures photo → local OCR → optional backend extraction (user opt-in) → parsed review screen → save to Drift
3. **Strategy Simulation:** User selects strategy + extra payment → StrategyEngine projects month-by-month → render timeline + interest comparison
4. **Premium Upgrade:** User purchases via Play Billing → backend verifies → updates entitlement → app unlocks premium features
5. **Secure Backup:** User enters passphrase → app encrypts full database snapshot → export as .ddbackup file

### Security Patterns

1. **Device Attestation:** Play Integrity verifies device authenticity; prevents bot/emulator abuse
2. **Session Tokens:** Access tokens (15 min) + refresh tokens (30 day); refresh tokens hashed + rotated on use
3. **On-Device Encryption:** SQLCipher encrypts all local data; separate vault for sensitive documents
4. **Explicit Cloud Consent:** AI extraction requires user per-import opt-in; default is local-only
5. **Audit Logging:** All backend operations logged (bootstrap, billing, extraction) with install ID + timestamp
6. **Rate Limiting:** Per-install + per-IP to prevent abuse

### Known Challenges

1. **Single-Device Model:** No multi-device sync; cloud sync not supported
2. **Vendor Lock-in:** Tight coupling to Google Play Integrity + Gemini API
3. **Incomplete Features:** Multi-language (intl package present, no strings); advanced themes (premium feature not fully implemented); promo rate handling (model exists, integration unclear)
4. **Testing Gaps:** Limited E2E tests; no load/security audit mentioned
5. **Scale Questions:** Unknown performance with 100+ debts; no benchmarks provided

### Deployment Model

- **Frontend:** Android APK (flavors: dev/staging/prod) signed + uploaded to Play Store
- **Backend:** Node.js process in container (Cloud Run, server, or Kubernetes); needs PostgreSQL + Redis
- **Config:** Environment variables for API keys, quotas, JWT secrets
- **CI/CD:** GitHub Actions (presumed) runs tests, builds APK, deploys backend

### Maintenance & Observability

- **Error Tracking:** Firebase Crashlytics captures exceptions + stack traces
- **Analytics:** Firebase Analytics tracks feature usage + user behavior
- **Audit Logs:** Backend logs all security-relevant events (attestation, billing, quota)
- **Database Monitoring:** Manual SQL monitoring (no ORM-level observability visible)

---

## End of Analysis

**Document Version:** 1.0  
**Analysis Date:** April 2026  
**Project Status:** Functional MVP with premium features (Android-first)  
**Code Quality:** Good (clear architecture, type-safe, reactive patterns)  
**Production Readiness:** Ready with caveats (see risks section 20)

**Next Steps for Team:**
1. Add comprehensive E2E test suite (Playwright or similar)
2. Conduct security audit + penetration testing
3. Load test backend under concurrent requests
4. Document API (OpenAPI/Swagger)
5. Plan for multi-device sync (if needed)
6. Complete incomplete features (multi-language, advanced themes)
7. Implement feature flags for rollout control
8. Establish SLOs/SLIs for monitoring

---

**END OF DOCUMENT**
