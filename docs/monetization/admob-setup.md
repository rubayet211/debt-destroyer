# AdMob Setup

Date: 2026-05-11

## What Was Added

Debt Destroyer now includes:

- `google_mobile_ads` dependency
- Android AdMob application metadata
- runtime ad config parsing from `.env`
- premium-aware banner slots
- placement policy that only enables ads in low-risk free-user surfaces

## Environment Variables

Add these to the Flutter `.env` file:

```env
ADMOB_ENABLED=false
ADMOB_TEST_MODE=true
ADMOB_ANDROID_APP_ID=ca-app-pub-3940256099942544~3347511713
ADMOB_ANDROID_BANNER_AD_UNIT_ID=ca-app-pub-3940256099942544/6300978111
ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID=ca-app-pub-3940256099942544/1033173712
```

Notes:

- The defaults above are Google test IDs.
- Do not commit production AdMob IDs.
- `ADMOB_ENABLED` should remain `false` until production IDs, consent handling, and policy review are complete.

## Android Manifest Wiring

The Android manifest now reads the AdMob app ID through the Gradle placeholder `ADMOB_APP_ID`.

Current behavior:

- Gradle reads `ADMOB_ANDROID_APP_ID` from the shell environment at build time.
- If it is missing, the build falls back to the official Google test App ID.

## Dev, Staging, and Prod Expectations

### Dev / Staging

- Keep `ADMOB_ENABLED=false` unless you are explicitly testing ads.
- If you enable ads, keep `ADMOB_TEST_MODE=true`.
- Use Google test ad IDs only.

### Prod

- Set a real AdMob App ID in the build environment for `ADMOB_ANDROID_APP_ID`.
- Set real unit IDs in runtime `.env`.
- Switch `ADMOB_ENABLED=true`.
- Switch `ADMOB_TEST_MODE=false`.

## Where Ads Appear

Current banner placements:

- dashboard
- debts list
- reports

Ads are shown only when:

- the user is not premium
- AdMob is enabled
- a banner unit ID exists
- the placement is explicitly allowed
- the subscription state has resolved

## Where Ads Do Not Appear

Ads are intentionally blocked from:

- onboarding
- unlock / privacy shield
- add/edit debt
- add payment
- scan capture / OCR processing / review
- backup / restore
- security & privacy
- premium purchase screen
- any premium user session

## Testing Ads

1. Put the Google test IDs in `.env`.
2. Set `ADMOB_ENABLED=true`.
3. Build and run a free-user app session.
4. Confirm banners appear only on dashboard, debts list, and reports.
5. Upgrade to premium or override premium entitlement in test.
6. Confirm banners disappear.

## Consent and Privacy

This implementation deliberately stops short of a full consent SDK flow.

Required manual work before a production ad rollout:

1. Add region-aware consent collection.
2. Update privacy policy and store disclosures.
3. Decide whether non-personalized ads are required for your launch regions.
4. Confirm no financial record payloads are ever sent to ad services.
5. Validate AdMob account settings for family / age-directed treatment if relevant.
