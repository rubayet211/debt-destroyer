# DEBT DESTROYER Privacy Policy

Effective date: [insert date]

This Privacy Policy explains how DEBT DESTROYER collects, uses, stores, shares, and protects information when you use the DEBT DESTROYER Android app, its related backend services, and any features connected to subscriptions, backup, import, or optional cloud-assisted extraction.

If you do not agree with this Privacy Policy, do not use the app.

## 1. Summary

DEBT DESTROYER is designed to be local-first. Most of your debt records, payment history, reminders, preferences, scenarios, and imported documents stay on your device by default.

The app only sends data to our backend or third-party services when a feature requires it or when you choose to use an optional feature such as cloud-assisted extraction, subscription verification, telemetry, or backup-related services.

We do not require you to create an account to use the core app.

## 2. Information We Collect

The information we collect depends on how you use the app.

### 2.1 Information you provide directly

You may provide the following information:

- debt names, balances, interest rates, minimum payments, due dates, and payoff details
- payment entries and manual adjustments
- budget or strategy inputs
- reminder settings and notification preferences
- app preferences such as hidden-balance mode, app lock settings, and consent choices
- imported document images, PDFs, screenshots, receipts, and similar files
- backup passphrases that you enter locally on your device for encrypting or restoring a backup
- support messages or feedback that you send to us

### 2.2 Information created or stored by the app

The app may create or store the following data locally on your device:

- offline debt and payment database content
- imported document metadata and document-processing status
- OCR output and review data generated during document import
- reminder schedules and notification state
- encrypted backup archives that you export
- secure preferences stored in the device keychain or secure storage
- premium entitlement state and billing-related caches

### 2.3 Information collected automatically

Depending on your settings and device permissions, the app may automatically collect or process:

- device and app information such as app version, build number, Android version, and device model
- crash reports and diagnostic information if crash reporting is enabled
- analytics events if analytics is enabled
- integrity signals used for Play Integrity verification
- notification permission status and reminder scheduling status

### 2.4 Information from Google Play and billing systems

If you purchase a subscription, Google Play may provide us with subscription and transaction-related information needed to confirm premium access. This may include purchase state, entitlement status, product identifiers, and related billing metadata.

### 2.5 Information from optional cloud-assisted extraction

If you explicitly choose to use cloud-assisted extraction for an import, the app may send the selected document and related processing context to our backend so the backend can perform attested, server-side extraction and return structured results for review.

The app does not silently upload imported statements, screenshots, or receipts for cloud processing.

## 3. How We Use Information

We use information to:

- provide and operate the app
- store and display debts, payments, reminders, and reports
- calculate payoff projections and budgeting views
- import and review financial documents
- run optional cloud-assisted extraction
- verify device integrity and protect backend services from abuse
- process subscriptions and restore premium entitlement
- send reminders and operational notifications
- provide backup and restore functionality
- improve reliability, security, and app performance
- diagnose bugs, crashes, and service issues
- respond to support requests

We do not use your data for advertising.

## 4. Local-First Processing

The app is designed so that the most sensitive data stays on your device whenever possible.

In particular:

- debts, payments, preferences, reminders, and scenarios are stored locally by default
- imported documents stay on device unless you choose cloud-assisted extraction
- imported documents are reviewed before anything is saved from the import flow
- cloud-assisted extraction only happens when you explicitly allow it for a specific import
- imported documents are never auto-saved after upload without a review step

## 5. Optional Cloud-Assisted Extraction

The app can help extract structured data from statements, receipts, screenshots, and PDFs.

If you choose cloud-assisted extraction:

- the app sends the selected import to our backend
- the backend may verify Play Integrity signals and usage limits
- the backend may call one or more third-party AI or document-processing providers using server-held credentials
- the backend validates and normalizes the response before returning it to the app
- the app shows the results to you for review before any data is stored

We use this process to read the selected document on the backend and return structured fields for review.

## 6. Subscriptions and Payments

DEBT DESTROYER uses Google Play subscriptions for premium features.

When you subscribe or restore a subscription, Google Play may share transaction and entitlement information with us so we can:

- confirm whether you have an active premium entitlement
- unlock premium features
- restore access on a new device or after reinstall
- prevent unauthorized access to paid features

We do not receive your full payment card details from Google Play.

## 7. Notifications

If you allow notifications, the app may send reminders such as:

- due-date reminders
- overdue reminders
- weekly summary reminders
- milestone reminders

Notification content is based on your debt and reminder settings. You can disable notifications in the app or in Android system settings.

## 8. Biometrics and Device Authentication

The app may use your device's biometric or device-credential authentication to unlock the app locally.

We do not receive or store your biometric template. Authentication happens through the Android system and device security features.

## 9. Backups and Restore

You can export encrypted backups of your data.

When you create a backup:

- the backup is generated on your device
- the backup is encrypted with a passphrase that you choose
- the backup may include debts, payments, imported document data, preferences, and related records

When you restore a backup:

- you must provide the correct passphrase
- restore is replace-only in the current version
- the app may ask you to confirm that existing local data will be replaced

You are responsible for keeping your backup passphrase and backup files secure.

## 10. Permissions

The app requests permissions only for specific functions:

- Camera: to capture documents, receipts, screenshots, and statements
- Notifications: to deliver reminders and summary alerts
- Internet: to communicate with backend services, billing systems, and integrity checks

If you deny a permission, some features may not work as intended.

## 11. Sharing and Disclosure of Information

We may share information only in the following circumstances:

### 11.1 With service providers

We may share information with service providers that help us operate the app, such as:

- Google Play for subscriptions and billing
- backend hosting and infrastructure providers
- optional telemetry or crash-reporting services if enabled
- cloud processing providers used for optional extraction

These providers may process information on our behalf under contractual or technical restrictions.

### 11.2 For legal, security, or abuse-prevention reasons

We may disclose information if we believe it is necessary to:

- comply with law, regulation, or lawful requests
- enforce our terms or protect our rights
- investigate fraud, abuse, or security incidents
- protect users, systems, or property

### 11.3 In connection with a business transaction

If DEBT DESTROYER is involved in a merger, acquisition, financing, reorganization, or asset sale, information may be transferred as part of that transaction, subject to applicable law.

## 12. Telemetry, Analytics, and Crash Reporting

The app may support analytics and crash reporting through optional Firebase-backed integrations.

If these features are enabled:

- we may collect app usage events and crash diagnostics
- we may collect limited device and app metadata
- we do not intend to log extracted document text, balances, document paths, tokens, or other sensitive financial content in telemetry data

If these features are disabled or not configured, the app can still run with no telemetry.

## 13. Data Retention

We retain data for as long as needed to provide the app and its features, unless a longer retention period is required by law, security, accounting, or abuse-prevention needs.

Because the app is local-first, much of your data remains under your control on your device. If you delete the app or clear app data, local information stored on the device may be removed.

Backup files, exported files, and imported documents may remain on your device, in your file storage, or in locations you choose until you delete them.

Backend logs and audit records may be retained for a limited period to support security, reliability, and abuse prevention.

## 14. Security

We use technical and organizational safeguards designed to protect your information, including:

- encrypted local storage for sensitive data
- secure storage for protected preferences and secrets
- encrypted full-backup archives
- backend access controls and quota protections
- request validation and schema checks for extracted data
- redacted logging practices for sensitive content

No method of storage or transmission is completely secure, so we cannot guarantee absolute security.

## 15. Your Choices and Controls

You can control many data practices inside the app and through Android settings. For example, you can:

- choose whether to enable cloud-assisted extraction for a specific import
- manage app lock and hidden-balance settings
- control notification permissions
- export or delete backups and imported documents
- disable analytics or crash reporting if those options are available in your build
- uninstall the app to remove local data from the device

## 16. Your Rights

Depending on where you live, you may have rights to:

- access your personal information
- correct inaccurate information
- delete certain information
- object to or restrict certain processing
- withdraw consent where processing is based on consent
- request a copy of your data

Some rights may be limited by the local-first design of the app, the absence of user accounts, legal obligations, or technical constraints. If you need help with a request, contact us using the details below.

## 17. International Transfers

If you use cloud features, your information may be processed in countries other than the one where you live, including by service providers, cloud infrastructure vendors, or backend processors. We take reasonable steps to protect information transferred across borders.

## 18. Children's Privacy

DEBT DESTROYER is not intended for children under the age required by local law to consent to data processing. We do not knowingly collect personal information from children. If you believe a child has provided us with personal information, contact us and we will take appropriate action.

## 19. Third-Party Services

Depending on the features you use and the configuration of your build, the app may interact with third-party services such as:

- Google Play Billing
- Google Play Integrity
- Firebase Analytics
- Firebase Crashlytics
- backend hosting and database providers
- optional AI or document-extraction providers

These third parties have their own privacy policies and terms.

## 20. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. If we make material changes, we will update the effective date and, where appropriate, provide notice in the app, on the store listing, or on our website.

## 21. Contact Us

If you have questions, requests, or complaints about this Privacy Policy or how your information is handled, contact:

- Support email: [insert support email]
- Publisher / business name: [insert legal entity or publisher name]
- Privacy contact page: [insert website or support URL]

## 22. Notes for Publication

Before publishing this policy, replace all bracketed placeholders and confirm that the text matches the final production configuration for analytics, crash reporting, backend extraction, billing, and support.
