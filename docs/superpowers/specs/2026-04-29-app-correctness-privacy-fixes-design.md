# App Correctness And Privacy Fixes Design

## Summary

This spec covers the first launch-hardening sub-project for the Flutter app:

1. Fix payment balance updates so logged payments decrement the current stored balance instead of recomputing from original balance.
2. Fix the scan/import flow so nothing is persisted before the user presses the final confirm action.
3. Fix reports so they use a user-selectable date range, defaulting to full history.

The goal is to correct production-impacting behavior without widening scope into adjacent UX or architecture work.

## Scope

### In scope

- Payment save and delete behavior in the repository layer
- Import processing and final confirm persistence boundaries
- Reports data sourcing and date-range filtering UI/state
- Regression tests for the three corrected behaviors

### Out of scope

- Custom priority ordering UX
- Backend hardening
- Google Play store assets, policy forms, and release packaging
- Broad refactors of repository, provider, or routing architecture

## Requirements

### 1. Payment balance behavior

- Logging a payment must decrement the debt's current stored balance by the payment amount.
- Deleting a payment must restore the previously deducted amount to the debt's current stored balance.
- Balance updates must clamp at zero and must not produce negative balances.
- The system must not recompute current balance from `originalBalance - totalPaid`.
- The existing debt form and debt screens should not require UX changes for this fix.

### 2. Import persistence contract

- Scan/import processing may perform OCR, classification, parsing, and review preparation in memory.
- No imported document record, parsed extraction record, or related persisted artifact may be written before the user presses the final confirm action.
- Cancelled review flows must leave storage unchanged.
- Failed final confirm attempts must leave storage unchanged.
- Persistence must happen only inside the explicit final save path after validation passes.

### 3. Reports behavior

- Reports must use a user-selectable date range.
- The default date range must be full history.
- The "Payments tracked" total must respect the selected date range.
- The monthly payments chart must respect the selected date range.
- Reports must source from full stored payment history, not a truncated recent-payments feed.

## Design

### Payment fix

The payment correction stays in the repository layer so the behavior is fixed at the data boundary and existing UI flows remain intact.

`DriftPaymentsRepository` currently recalculates a debt balance from the original balance and the sum of all payments. That logic will be replaced with current-balance delta handling:

- On payment create, subtract the payment amount from the stored `currentBalance`.
- On payment delete, add the payment amount back to the stored `currentBalance`.
- On payment update through upsert, compute the delta between the prior stored payment amount and the new amount, then apply only that delta to the current stored balance.

This preserves the existing meaning of `currentBalance` as the user-recorded truth while still allowing logged payments to keep that value current.

### Import fix

The import correction stays in the controller/review-save boundary.

`ScanImportController.process()` should return an `ImportReviewBundle` only. It must not persist the document during OCR or parse. The review screen remains responsible for showing the prepared result, but final persistence moves entirely into the explicit confirm/save path after:

- target debt selection validation
- payment amount validation
- any required import-specific validation

If validation fails, the save path exits without writing document or extraction state. If the user backs out of review, nothing remains in storage because nothing was written.

### Reports fix

The reports correction stays in provider and presentation wiring.

Reports should consume all payments from storage and apply an in-app date-range filter before deriving totals and chart data. A reports-specific date-range state source will be introduced for the selected range, with full-history as the default. The screen then derives:

- filtered payments total
- filtered monthly aggregation for charting

No database schema change is required for this work.

## File Impact

Expected primary file changes:

- `lib/shared/data/repositories.dart`
- `lib/shared/providers/app_providers.dart`
- `lib/features/scan_import/presentation/scan_screens.dart`
- `lib/features/reports/presentation/reports_screen.dart`
- related tests in `test/`

This spec intentionally keeps changes localized to current ownership boundaries.

## Error Handling

### Payments

- Missing debt rows should remain a safe no-op for recalculation helpers.
- Balance updates must clamp to zero.
- Update paths must use the prior persisted payment amount when calculating deltas.

### Import

- Processing failures before review must not write anything.
- Validation failures during confirm must not write anything.
- Only a successful confirm path may persist the document and associated derived state.

### Reports

- Default full-history behavior must work without requiring user input.
- Empty ranges must render valid zero-state summaries and charts without crashing.

## Testing Strategy

### Payment tests

- Saving a payment against a debt with an independently set `currentBalance` decrements that stored balance.
- Deleting the payment restores the deducted balance.
- Updating an existing payment applies only the amount delta.
- The regression test must prove the system no longer derives balance from `originalBalance`.

### Import tests

- Processing to review does not persist documents.
- Final confirm persists only after validation passes.
- Failed confirm paths leave storage unchanged.

### Reports tests

- Default range uses full history.
- A selected range filters "Payments tracked" totals.
- A selected range filters monthly chart input data.
- Reports no longer depend on the recent-payments capped provider for their data source.

## Non-Goals And Tradeoffs

- This design does not attempt to redesign debt reconciliation semantics beyond the approved rule that payment logging updates the stored current balance.
- This design does not introduce draft import persistence because the approved product contract explicitly forbids persistence before final confirm.
- This design does not add broader reporting analytics beyond the date-range requirement.

## Acceptance Criteria

- Payment logging no longer corrupts balances by deriving from original balance.
- Import review no longer writes any storage artifacts before final confirmation.
- Reports default to full history and honor a user-selected date range.
- Regression tests cover all three corrected behaviors.
