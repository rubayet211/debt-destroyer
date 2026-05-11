# Debt Destroyer Monetization Audit

Date: 2026-05-11

## Executive Summary

Debt Destroyer already has a meaningful Google Play Billing foundation:

- Flutter uses `in_app_purchase` and `in_app_purchase_android`.
- The backend exposes authenticated Google Play verify and restore endpoints.
- Entitlements are persisted locally in Drift and remotely in backend storage.
- Several premium features are gated from a unified `SubscriptionState`.

The monetization stack is not production-complete yet.

Main gaps found during audit:

- Google AdMob is not implemented.
- Google Pay is not implemented, and it should not be implemented for the current product scope.
- Billing UX is functional but thin: limited loading/error states, direct upsell redirects, and weak recovery messaging.
- Billing configuration contains hardcoded assumptions around default monthly/yearly base plan names.
- Backend restore logic can preserve stale premium state instead of clearing it when restore returns no active purchase.
- Backend capabilities/quota reads trust stored premium state without normalizing expired entitlements.
- Android is missing AdMob manifest metadata and ad configuration plumbing.

## Current State

### Google Play Billing

Implemented:

- Dependencies present in [pubspec.yaml](/J:/codex/pubspec.yaml)
- Billing service in [lib/core/services/billing_services.dart](/J:/codex/lib/core/services/billing_services.dart)
- Billing models in [lib/shared/models/billing_models.dart](/J:/codex/lib/shared/models/billing_models.dart)
- Billing providers in [lib/shared/providers/app_providers.dart](/J:/codex/lib/shared/providers/app_providers.dart)
- Premium screen in [lib/features/settings/presentation/settings_screens.dart](/J:/codex/lib/features/settings/presentation/settings_screens.dart)
- Backend verify/restore routes in [backend/src/app.ts](/J:/codex/backend/src/app.ts)
- Google Play verification service in [backend/src/services/billing.ts](/J:/codex/backend/src/services/billing.ts)
- Entitlement persistence in [backend/src/services/storage.ts](/J:/codex/backend/src/services/storage.ts)
- Backend tests in [backend/test/billing.test.ts](/J:/codex/backend/test/billing.test.ts)

Observed flow:

1. Flutter loads a Play Billing catalog for `PREMIUM_PRODUCT_ID`.
2. User starts purchase from the premium screen.
3. Flutter listens to `purchaseStream`.
4. Successful purchase sends `purchase_token` to backend verify endpoint.
5. Backend calls Google Play Developer API and persists normalized entitlement.
6. Flutter stores the returned entitlement in the local subscription repository.

Working pieces:

- Authenticated backend verification
- Purchase completion after verification
- Restore endpoint exists
- Local cached entitlement exists
- Feature gating exists for PDF import, CSV export, and scenario saving

Weak or missing pieces:

- Catalog helpers assume `monthly` and `yearly` plan IDs in UI getters
- Purchase update verification does not de-duplicate repeated purchase events
- Error mapping is raw and user-facing
- Upgrade prompts are mostly hard redirects to `/premium`
- Restore logic needs stronger stale-state handling
- Expired entitlement normalization is incomplete on backend reads
- No ad suppression layer exists because no ads exist yet

### Google Pay

Current state:

- No Google Pay SDK/package found in Flutter dependencies
- No Google Pay server-side checkout flow found
- No product use case was found that justifies Google Pay under Play policy

Decision:

- Do not implement Google Pay for premium digital features
- Use Google Play Billing for subscriptions and in-app premium access

See [google-pay-decision.md](/J:/codex/docs/monetization/google-pay-decision.md).

### Google AdMob

Current state:

- `google_mobile_ads` is not present in [pubspec.yaml](/J:/codex/pubspec.yaml)
- No ad service, ad widgets, or ad unit configuration found
- No AdMob application metadata in [AndroidManifest.xml](/J:/codex/android/app/src/main/AndroidManifest.xml)

Result:

- AdMob is currently unimplemented

## Premium Feature Gating Audit

Confirmed gates:

- PDF import gate in [scan_screens.dart](/J:/codex/lib/features/scan_import/presentation/scan_screens.dart)
- CSV export gate in [reports_screen.dart](/J:/codex/lib/features/reports/presentation/reports_screen.dart)
- CSV export gate in [settings_screens.dart](/J:/codex/lib/features/settings/presentation/settings_screens.dart)
- Scenario saving gate in [strategy_simulator_screen.dart](/J:/codex/lib/features/strategy/presentation/strategy_simulator_screen.dart)

Defined premium features:

- `unlimitedScans`
- `pdfImport`
- `advancedReports`
- `csvExport`
- `scenarioSaving`
- `advancedStrategyComparison`
- `premiumThemes`

Gaps:

- Upsell UX is inconsistent
- Some premium features are defined but do not have explicit UI surfaces yet
- There is no ads-vs-premium integration because ads do not exist yet

## Android Configuration Audit

Files inspected:

- [android/app/build.gradle.kts](/J:/codex/android/app/build.gradle.kts)
- [android/app/src/main/AndroidManifest.xml](/J:/codex/android/app/src/main/AndroidManifest.xml)

Findings:

- Internet permission exists
- Product flavors exist: `dev`, `staging`, `prod`
- Play Integrity dependency exists
- Release build exists
- No AdMob application metadata
- No AdMob manifest placeholders
- No monetization-specific release hardening beyond current billing/integrity setup

## Environment Audit

Frontend env:

- [\.env.example](/J:/codex/.env.example) contains backend URL, Play Integrity config, and premium product/base plan IDs
- It does not contain AdMob configuration

Backend env:

- [backend/.env.example](/J:/codex/backend/.env.example) contains Play package name, service account JSON, and premium product/base plan IDs
- Backend billing credentials are already modeled

## Risks Before Production

1. Restore can preserve stale premium state.
2. Expired entitlements may continue to look premium until another verification path runs.
3. Premium screen does not give strong recovery states when products are unavailable.
4. No AdMob layer means no free-tier ad monetization exists yet.
5. No documented Google Pay decision means future work could drift into a policy-unsafe path.

## Planned Changes

1. Normalize backend entitlement reads and fix restore selection logic.
2. Make billing plan handling and UX more resilient.
3. Add AdMob config, bootstrap, widgets, and premium-aware placement policy.
4. Replace direct premium dead-ends with better upgrade prompts.
5. Add docs, QA checklist, and tests.

## Files Inspected

- [pubspec.yaml](/J:/codex/pubspec.yaml)
- [pubspec.lock](/J:/codex/pubspec.lock)
- [\.env.example](/J:/codex/.env.example)
- [backend/.env.example](/J:/codex/backend/.env.example)
- [android/app/build.gradle.kts](/J:/codex/android/app/build.gradle.kts)
- [android/app/src/main/AndroidManifest.xml](/J:/codex/android/app/src/main/AndroidManifest.xml)
- [lib/app/bootstrap.dart](/J:/codex/lib/app/bootstrap.dart)
- [lib/app/router/app_router.dart](/J:/codex/lib/app/router/app_router.dart)
- [lib/core/constants/app_constants.dart](/J:/codex/lib/core/constants/app_constants.dart)
- [lib/core/services/app_services.dart](/J:/codex/lib/core/services/app_services.dart)
- [lib/core/services/backend_services.dart](/J:/codex/lib/core/services/backend_services.dart)
- [lib/core/services/billing_services.dart](/J:/codex/lib/core/services/billing_services.dart)
- [lib/core/widgets/app_widgets.dart](/J:/codex/lib/core/widgets/app_widgets.dart)
- [lib/features/dashboard/presentation/home_dashboard_screen.dart](/J:/codex/lib/features/dashboard/presentation/home_dashboard_screen.dart)
- [lib/features/debts/presentation/debts_screens.dart](/J:/codex/lib/features/debts/presentation/debts_screens.dart)
- [lib/features/reports/presentation/reports_screen.dart](/J:/codex/lib/features/reports/presentation/reports_screen.dart)
- [lib/features/scan_import/presentation/scan_screens.dart](/J:/codex/lib/features/scan_import/presentation/scan_screens.dart)
- [lib/features/settings/presentation/settings_screens.dart](/J:/codex/lib/features/settings/presentation/settings_screens.dart)
- [lib/features/strategy/presentation/strategy_simulator_screen.dart](/J:/codex/lib/features/strategy/presentation/strategy_simulator_screen.dart)
- [lib/shared/data/repositories.dart](/J:/codex/lib/shared/data/repositories.dart)
- [lib/shared/enums/app_enums.dart](/J:/codex/lib/shared/enums/app_enums.dart)
- [lib/shared/models/backend_models.dart](/J:/codex/lib/shared/models/backend_models.dart)
- [lib/shared/models/billing_models.dart](/J:/codex/lib/shared/models/billing_models.dart)
- [lib/shared/models/subscription_state.dart](/J:/codex/lib/shared/models/subscription_state.dart)
- [lib/shared/providers/app_providers.dart](/J:/codex/lib/shared/providers/app_providers.dart)
- [backend/src/app.ts](/J:/codex/backend/src/app.ts)
- [backend/src/config.ts](/J:/codex/backend/src/config.ts)
- [backend/src/services/billing.ts](/J:/codex/backend/src/services/billing.ts)
- [backend/src/services/storage.ts](/J:/codex/backend/src/services/storage.ts)
- [backend/src/types.ts](/J:/codex/backend/src/types.ts)
- [backend/test/billing.test.ts](/J:/codex/backend/test/billing.test.ts)
- [test/billing_test.dart](/J:/codex/test/billing_test.dart)

## Files Changed

- [docs/monetization/monetization-audit.md](/J:/codex/docs/monetization/monetization-audit.md)
- [docs/monetization/google-pay-decision.md](/J:/codex/docs/monetization/google-pay-decision.md)
- [docs/monetization/admob-setup.md](/J:/codex/docs/monetization/admob-setup.md)
- [docs/monetization/manual-qa-checklist.md](/J:/codex/docs/monetization/manual-qa-checklist.md)
- [docs/monetization/final-implementation-report.md](/J:/codex/docs/monetization/final-implementation-report.md)
- [\.env.example](/J:/codex/.env.example)
- [android/app/build.gradle.kts](/J:/codex/android/app/build.gradle.kts)
- [android/app/src/main/AndroidManifest.xml](/J:/codex/android/app/src/main/AndroidManifest.xml)
- [backend/src/app.ts](/J:/codex/backend/src/app.ts)
- [backend/src/services/storage.ts](/J:/codex/backend/src/services/storage.ts)
- [backend/test/billing.test.ts](/J:/codex/backend/test/billing.test.ts)
- [lib/app/bootstrap.dart](/J:/codex/lib/app/bootstrap.dart)
- [lib/core/services/ad_services.dart](/J:/codex/lib/core/services/ad_services.dart)
- [lib/core/services/billing_services.dart](/J:/codex/lib/core/services/billing_services.dart)
- [lib/core/widgets/monetization_widgets.dart](/J:/codex/lib/core/widgets/monetization_widgets.dart)
- [lib/features/dashboard/presentation/home_dashboard_screen.dart](/J:/codex/lib/features/dashboard/presentation/home_dashboard_screen.dart)
- [lib/features/debts/presentation/debts_screens.dart](/J:/codex/lib/features/debts/presentation/debts_screens.dart)
- [lib/features/reports/presentation/reports_screen.dart](/J:/codex/lib/features/reports/presentation/reports_screen.dart)
- [lib/features/scan_import/presentation/scan_screens.dart](/J:/codex/lib/features/scan_import/presentation/scan_screens.dart)
- [lib/features/settings/presentation/settings_screens.dart](/J:/codex/lib/features/settings/presentation/settings_screens.dart)
- [lib/features/strategy/presentation/strategy_simulator_screen.dart](/J:/codex/lib/features/strategy/presentation/strategy_simulator_screen.dart)
- [lib/shared/models/ad_models.dart](/J:/codex/lib/shared/models/ad_models.dart)
- [lib/shared/models/billing_models.dart](/J:/codex/lib/shared/models/billing_models.dart)
- [lib/shared/providers/app_providers.dart](/J:/codex/lib/shared/providers/app_providers.dart)
- [pubspec.lock](/J:/codex/pubspec.lock)
- [pubspec.yaml](/J:/codex/pubspec.yaml)
- [test/admob_test.dart](/J:/codex/test/admob_test.dart)
- [test/billing_test.dart](/J:/codex/test/billing_test.dart)
- [test/reports_screen_test.dart](/J:/codex/test/reports_screen_test.dart)
