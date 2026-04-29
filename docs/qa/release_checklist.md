# QA and Regression Checklist

## Targeted Automated Suites
- `flutter test test/strategy_engine_test.dart`
- `flutter test test/reminder_services_test.dart`
- `flutter test test/data_portability_test.dart`
- `flutter test test/reports_screen_test.dart`
- `flutter test test/data_backups_screen_test.dart`
- `flutter test test/biometric_unlock_screen_test.dart`
- `flutter test test/ocr_processing_screen_test.dart`
- `flutter analyze`
- `flutter test`

## Release Sanity
- Fresh install reaches onboarding, dashboard, and settings without crashes.
- Upgrade install preserves debts, payments, protected preferences, and app lock settings.
- Add debt manually and confirm dashboard and reports update.
- Add payment manually and confirm debt balance and recent activity update.
- Premium-gated actions still route free users to the paywall.
- Hidden-balance mode masks dashboard and debt values while the app remains usable.
- Backup export creates an encrypted `.ddbackup` file and restore preview shows record counts before confirmation.
- Replace restore succeeds on a clean install and restores debts, payments, documents, preferences, and reminder history.

## Manual Device Matrix

### Camera, OCR, and PDF
- Capture from camera on a physical Android device.
- Import from gallery screenshot and verify review-before-save flow.
- Import a PDF statement and confirm payment-like line items appear when available.
- Test OCR failure / weak OCR path and confirm manual fallback remains usable.
- Test low-confidence or unknown-document classification and confirm the review screen stays editable.

### Notifications
- Grant notification permission and verify due lead, due today, overdue, weekly summary, and milestone notifications schedule correctly.
- Deny notification permission and confirm settings show the denied state without crashing.
- Edit a debt due date and confirm stale reminders disappear and replacement reminders schedule.
- Archive, restore, pay off, and delete debts and confirm stale reminders are cancelled.
- Restart the app and confirm reminders reconcile again.

### Security and Privacy
- Enable app lock and verify successful biometric or device-credential unlock.
- Test biometric cancel, temporary lockout, and unavailable-auth behavior.
- Background the app for less than the relock timeout and verify it resumes unlocked.
- Background the app past the relock timeout and verify it relocks before sensitive content is shown.
- Verify Android screenshot blocking on dashboard, reports, debt details, scan review, and security/privacy screens.
- Verify the privacy shield appears in the app switcher/background path.

### Billing Sandbox
- Load Google Play Billing products with license test accounts.
- Complete a successful purchase and verify backend entitlement unlock.
- Verify pending purchase state is shown without unlocking.
- Cancel out of purchase flow and confirm no entitlement change.
- Restore purchases and confirm entitlement is restored.
- Validate expired / grace / on-hold states if sandbox timing permits.

### Export, Backup, and Restore
- Export CSV while premium is active and confirm the shared file contents look correct.
- Attempt full backup with mismatched passphrase confirmation and confirm it blocks.
- Attempt restore with wrong passphrase and confirm it fails safely without wiping data.
- Restore on a device with existing data and confirm replace-only warning is shown.
- Confirm restored source documents can still be opened through the app after re-sealing.

### Layout and Theme
- Verify light and dark themes on small and large Android screens.
- Check dashboard, reports, premium, backup, and scan review screens in portrait.
- Check at least one large-screen or tablet-sized emulator for overflow regressions.

## Known Manual-Only Areas
- Camera and PDF import rely on device/plugin integrations not fully covered by widget tests.
- Play Billing and Play Integrity still require real Google sandbox/device validation.
- Notification delivery and recents-thumbnail masking vary by Android version and OEM skin.
- Reminder restoration after full device reboot still depends on app relaunch in this repo.
