# Monetization Manual QA Checklist

Date: 2026-05-11

## Billing

- Install a fresh build.
- Confirm the app opens as a free user.
- Open Premium and verify Google Play plans load.
- Trigger a purchase with Google Play test billing.
- Confirm purchase enters pending state when Play returns pending.
- Confirm successful purchase unlocks premium only after backend verification returns.
- Restart the app and confirm premium persists.
- Open Settings and verify premium status reflects the active plan.
- Tap Restore purchases on a clean install with the same account.
- Confirm restore returns the active entitlement.
- Test an account with no active purchase and confirm restore does not resurrect stale premium.

## Offline and Failure States

- Disable network before opening Premium and confirm cached entitlement still renders.
- Attempt restore while offline and confirm the UI shows a recoverable error.
- Simulate backend outage and confirm purchase verification does not silently unlock premium.
- Confirm no permanent loading state remains after failures.

## Premium Gates

- Free user: tap PDF import and confirm a premium upsell sheet appears.
- Free user: tap CSV export and confirm a premium upsell sheet appears.
- Free user: tap Save scenario and confirm a premium upsell sheet appears.
- Premium user: confirm those actions proceed without upsell.

## AdMob

- Free user with `ADMOB_ENABLED=true` and test IDs:
  - dashboard shows banner
  - debts list shows banner
  - reports shows banner
- Premium user:
  - dashboard shows no banner
  - debts list shows no banner
  - reports shows no banner
- Confirm no ads appear on:
  - onboarding
  - unlock
  - add/edit debt
  - add payment
  - scan processing/review
  - backup/restore
  - security/privacy
  - premium

## Environment and Release Readiness

- Verify `.env` uses the intended product IDs and AdMob IDs for the target environment.
- Verify backend env uses the intended Play package name and service account.
- Verify Android build environment provides the intended `ADMOB_ANDROID_APP_ID`.
- Verify the built APK flavor matches the intended package/application ID.

## Logging and Privacy

- Confirm no raw purchase token appears in app logs.
- Confirm no raw purchase token appears in backend logs.
- Confirm no financial record contents are referenced by ad configuration or ad requests.
