# Release Build and Signing Guide

## Flavor matrix
- `dev`: local development and internal debugging, package suffix `.dev`
- `staging`: pre-release validation and closed testing, package suffix `.staging`
- `prod`: store-ready build, no package suffix

## Local commands
- Dev debug APK:
  - `flutter build apk --flavor dev --debug --dart-define=APP_ENV=development --dart-define=APP_FLAVOR=dev`
- Staging release APK:
  - `flutter build apk --flavor staging --release --dart-define=APP_ENV=staging --dart-define=APP_FLAVOR=staging`
- Prod release AAB:
  - `flutter build appbundle --flavor prod --release --dart-define=APP_ENV=prod --dart-define=APP_FLAVOR=prod`

## Signing
- Release signing is intentionally external to the repo.
- Copy [android/key.properties.example](/J:/codex/android/key.properties.example) to `android/key.properties`.
- Set:
  - `storeFile`
  - `storePassword`
  - `keyAlias`
  - `keyPassword`
- CI can provide the same values through environment variables:
  - `ANDROID_KEYSTORE_PATH`
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `ANDROID_KEY_PASSWORD`

## Unsigned vs signed output
- If no signing material is configured, release builds still verify as unsigned artifacts.
- Store upload requires:
  - a real keystore
  - matching `prod` env values
  - final Play Console package/product setup

## Required release-time inputs
- `.env` or `--dart-define` values for:
  - `APP_ENV`
  - `APP_FLAVOR`
  - backend base URL
  - Play Integrity package/project values
  - premium product/base-plan ids
- Optional Firebase telemetry values if release telemetry is enabled.
