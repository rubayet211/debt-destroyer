# Financial Projection Notes

DEBT DESTROYER uses a deterministic projection engine for payoff planning. It is designed to be understandable and consistent across the dashboard, strategy simulator, and reports.

## What is modeled
- Opening balance comes from the user-recorded `currentBalance`
- Nominal APR with configurable compounding:
  - `monthlyCompound`
  - `dailySimple`
  - `none`
- Fixed minimum payments, minimum percent rules, and interest-plus-percent rules
- Promotional APR windows
- Monthly recurring fees
- Late fees when projected minimums are missed and the grace window fits within the cycle
- Penalty APR on overdue cycles
- Extra monthly payments, lump sums, and Snowball / Avalanche / Custom priority allocation
- Weekly, biweekly, monthly, and quarterly payment frequencies aggregated into monthly schedule buckets

## Rounding policy
- All engine math converts money to integer cents internally
- Values are rounded half-up to cents at each accrual, fee, and payment step
- APR is treated as a nominal annual percentage rate
- Daily accrual uses `days / 365`
- Monthly compound uses weighted nominal APR divided by `12`

## Important assumptions
- Stored debt balances remain user-recorded truth; the engine does not rebuild balances from payment history
- Existing debts without advanced terms default to:
  - monthly compounding
  - fixed minimum payment
  - no promo APR
  - no recurring fees
  - no late fee or penalty APR
- Underfunded budgets are modeled explicitly unless the caller opts to force minimum coverage

## Out of scope
- Variable-rate index products
- Exact lender daily balance conventions beyond the supported compounding modes
- Statement-exact amortization disclosures
- Full ledger reconciliation against real creditor statements
