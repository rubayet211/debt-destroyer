# ⚡ DEBT DESTROYER

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Fastify-%23000000.svg?style=for-the-badge&logo=fastify&logoColor=white" alt="Fastify" />
  <img src="https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
</p>

<p align="center">
  <strong>Privacy-first debt tracking, payoff planning, and AI-assisted document import.</strong><br />
  Built with Flutter for high-performance mobile tracking and a secure Node.js backend for smart extractions.
</p>

---



## 🚀 Core Capabilities

Debt Destroyer is a comprehensive financial tool designed to help users visualize and eliminate debt using data-driven strategies and secure automation.

*   **🛡️ Privacy-First Architecture**: Local-first storage using Drift, encrypted backups, and biometric app-locking.
*   **📸 Smart Import Hub**: Advanced OCR (Google ML Kit) and AI-mediated extraction for credit card statements, receipts, and loan documents.
*   **📊 Strategy Simulator**: Compare payoff methods like **Debt Snowball**, **Debt Avalanche**, and custom priority ordering.
*   **🤖 AI Extraction**: Secure backend-mediated structured data extraction with explicit per-import consent.
*   **📈 Financial Projections**: Precise interest accrual modeling, promotional APR windows, and debt-free date forecasts.
*   **💾 Data Portability**: Encrypted `.ddbackup` system and CSV exports for full user ownership of financial data.

---



## 🛠️ Technical Stack



### Frontend (Mobile App)
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Database:** Drift (SQLite)
- **Navigation:** GoRouter
- **Charts:** FL Chart



### Backend (Security & Extraction)
- **Runtime:** Node.js (Fastify)
- **Language:** TypeScript
- **Validation:** Zod
- **Database:** PostgreSQL & Redis
- **Testing:** Vitest

---



## 📁 Project Structure

```text
├── android/               # Native Android configuration & flavors
├── backend/               # Fastify server, AI extraction, and SQL schema
├── docs/                  # Extensive monetization, QA, & release documentation
├── lib/                   # Flutter source code
│   ├── app/               # Bootstrap, Routing, and Theme
│   ├── core/              # Low-level services (Security, Vault, Ad Services)
│   ├── features/          # Domain-driven feature modules (Strategy, Scan, Dashboard)
│   └── shared/            # Repositories, Database, and Data Models
└── test/                  # Comprehensive Flutter widget and unit tests
```

---



## 🚥 Quick Start



### 1. Prerequisites
- **Flutter SDK:** ^3.35.x
- **Node.js:** v22+
- **PostgreSQL & Redis:** (Required for backend features)



### 2. Backend Setup
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```



### 3. Flutter Setup
```bash


# Install dependencies
flutter pub get



# Generate database and model code
flutter pub run build_runner build --delete-conflicting-outputs



# Run the app
flutter run
```

---



## 🔒 Privacy & Security Model

Debt Destroyer implements a multi-layered security approach:
- **Local-First:** Your financial data stays on your device by default.
- **Attestation:** Uses Play Integrity to ensure the app environment hasn't been tampered with.
- **Consent-Based AI:** Documents are only sent for cloud extraction if you explicitly approve each instance.
- **Biometric Lock:** Integrated `local_auth` for securing access to sensitive records.

---



## 🧪 Testing
The project maintains a rigorous testing suite covering both frontend and backend.

**Run Flutter Tests:**
```bash
flutter test
```
*Targeted suites include `strategy_engine_test.dart`, `app_security_test.dart`, and `data_protection_test.dart`.*

**Run Backend Tests:**
```bash
cd backend
npm test
```

---

<p align="center">
  <sub>Built with ❤️ for financial freedom.</sub>
</p>