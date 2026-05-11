# Google Pay Decision

Date: 2026-05-11

## Decision

Google Pay should not be implemented for Debt Destroyer premium access in the current product.

## Why

Debt Destroyer sells digital in-app value:

- premium subscription access
- premium feature unlocks
- scan/import-related premium capability
- reporting/export/simulation unlocks

For Android apps, those are Google Play digital goods and must use Google Play Billing rather than Google Pay.

## Current Product Scope

The audited codebase sells or unlocks:

- unlimited scans
- PDF import
- advanced reports
- CSV export
- scenario saving
- advanced strategy comparison
- premium themes

These are all digital entitlements delivered inside the app.

## Policy-Safe Payment Method

Use Google Play Billing for:

- subscriptions
- premium unlocks
- digital feature access

Do not use Google Pay to bypass Google Play Billing for those features.

## When Google Pay Could Become Valid

Google Pay may become appropriate only if Debt Destroyer later adds a separate, policy-compliant payment flow for something outside Google Play digital goods, such as:

- paying a real-world financial advisor
- paying for a physical mailed product
- paying an external service that is not in-app digital access

If that happens:

- keep Google Pay separate from premium entitlement logic
- do not route Google Pay purchases into Play Billing subscription unlocks
- document the compliant use case before implementation

## Implementation Consequence

This monetization pass keeps premium access on Google Play Billing only and documents Google Pay as intentionally not implemented.
