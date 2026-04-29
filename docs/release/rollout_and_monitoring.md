# Rollout and Monitoring Checklist

## Internal test track
- Verify fresh install and upgrade install.
- Verify backend connectivity for the target environment.
- Validate billing sandbox, attestation, reminders, backup/restore, and app lock on physical devices.

## Closed beta gate
- No blocker crashes in internal testing.
- No broken import/restore/premium paths.
- Notification and privacy features validated on at least two Android versions.
- Release candidate AAB verified from the `prod` flavor.

## Staged rollout suggestion
- 5% rollout for first production release
- Expand to 20% after 24 hours if:
  - no severe crash spike
  - no billing/restore blocker
  - no import/backup corruption reports
- Expand to 100% after 72 hours if monitoring remains clean

## Rollback triggers
- crash-free sessions materially below target
- billing entitlement failures
- import review/save corruption
- backup restore data loss reports
- app-lock/privacy regression exposing sensitive content

## Post-release monitoring
- monitor crash-free sessions and fatal issues
- monitor import/extraction failure rate
- monitor backup/restore support incidents
- monitor reminder delivery complaints and stale reminder reports
- monitor entitlement mismatch / restore purchase reports
