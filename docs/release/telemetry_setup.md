# Telemetry Setup

## Current architecture
- Flutter telemetry uses the existing `AnalyticsService` and `CrashReporter` abstractions.
- The repo now includes Firebase-backed implementations with noop fallback.
- If Firebase config is absent, the app still builds and runs with no telemetry.

## Required runtime values
- `ENABLE_ANALYTICS`
- `ENABLE_CRASH_REPORTING`
- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET` (optional)

These can be supplied through `.env` for local work or `--dart-define` for CI/release.

## External setup still required
- Create the Firebase project.
- Register the production Android app with package `com.debtdestroyer.app`.
- If telemetry is enabled for `dev` or `staging`, register `com.debtdestroyer.app.dev` and `com.debtdestroyer.app.staging` as separate Android apps and supply matching Firebase app IDs for those flavors.
- Decide whether to add `google-services.json` and native Crashlytics symbol upload as a production follow-up.
- Define the production analytics event allowlist and retention policy.

## Logging policy
- Info logs are suppressed in release builds.
- Error logs remain structured and redacted.
- Do not log raw OCR text, balances, document paths, or tokens to analytics/crash metadata.
