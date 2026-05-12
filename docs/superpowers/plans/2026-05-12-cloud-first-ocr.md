# Cloud-First OCR Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove local OCR from the scan/import path and make backend Gemini multimodal extraction process image/PDF files directly.

**Architecture:** Flutter uploads the selected image/PDF bytes to a new authenticated Fastify endpoint. Fastify enforces existing quota/auth, sends file bytes plus extraction prompt to Gemini, returns the same normalized extraction response, and Flutter renders review/save from that response.

**Tech Stack:** Flutter/Riverpod, Fastify/TypeScript, Gemini REST `generateContent` with `inline_data`, existing Neon-backed quota/audit storage.

---

### Task 1: Backend File Extraction Contract

**Files:**
- Modify: `backend/src/types.ts`
- Modify: `backend/src/services/provider.ts`
- Modify: `backend/src/services/prompts.ts`
- Modify: `backend/src/app.ts`
- Test: `backend/test/extraction.test.ts`

- [x] Add a failing backend test for `POST /v1/import/extract-file` with `file.mime_type` and `file.data_base64`.
- [x] Extend backend schemas with `extractionFileRequestSchema`.
- [x] Extend `AiProvider.extract` input to accept either `normalizedText` or `document`.
- [x] Send Gemini `inline_data` for files, plus text prompt.
- [x] Reuse existing auth, quota, audit, response normalization.

### Task 2: Flutter Cloud File Service

**Files:**
- Modify: `lib/features/scan_import/domain/import_services.dart`
- Modify: `lib/core/services/backend_services.dart`
- Modify: `lib/shared/providers/app_providers.dart`
- Test: `test/import_services_test.dart`

- [x] Add a failing Flutter test proving `ImportCoordinator` calls AI extraction with the file and empty OCR text.
- [x] Remove `OcrService` from coordinator dependencies.
- [x] Read file bytes in `BackendAiExtractionService` and call `/v1/import/extract-file`.
- [x] Keep manual fallback when cloud is disabled/unavailable.

### Task 3: Processing UX

**Files:**
- Modify: `lib/features/scan_import/presentation/scan_screens.dart`
- Test: `test/ocr_processing_screen_test.dart`

- [x] Replace generic OCR wording with cloud extraction wording.
- [x] Show a concrete cloud processing message.
- [x] Show retry/manual fallback if backend fails.

### Task 4: Remove Local OCR Dependency

**Files:**
- Modify: `pubspec.yaml`
- Update lockfile with `flutter pub get`

- [x] Remove `google_mlkit_text_recognition`.
- [x] Remove imports/classes using ML Kit OCR.
- [x] Verify app still builds.
