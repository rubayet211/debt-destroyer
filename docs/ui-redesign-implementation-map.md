# UI Redesign Implementation Map

## App entry and routing
- Entry point: `lib/main.dart` -> `lib/app/bootstrap.dart` -> `lib/app/app.dart`
- Router: `lib/app/router/app_router.dart`
- Navigation: `StatefulShellRoute.indexedStack` with Dashboard, Debts, Scan, Strategy, Settings tabs.

## State, data, and business logic
- State management: Riverpod providers in `lib/shared/providers/app_providers.dart`
- Persistence: Drift repositories in `lib/shared/data/repositories.dart`
- Models: `lib/shared/models/`
- Debt metrics: `lib/features/dashboard/domain/debt_metrics_service.dart`
- Strategy calculations: `lib/features/strategy/domain/strategy_engine.dart` and `portfolio_projection_service.dart`
- Scan/OCR flow: `lib/features/scan_import/domain/import_services.dart` and `lib/features/scan_import/presentation/scan_screens.dart`
- Privacy/masking: `UserPreferences.hideBalances`, `AppSecurityCoordinator`, privacy shield, screenshot protection, and `SensitiveValueText`

## Design-system files
- Existing theme updated: `lib/app/theme/app_theme.dart`
- New centralized tokens:
  - `lib/app/theme/app_colors.dart`
  - `lib/app/theme/app_spacing.dart`
  - `lib/app/theme/app_radius.dart`
  - `lib/app/theme/app_shadows.dart`
- Shared widgets updated: `lib/core/widgets/app_widgets.dart`

## Stitch mapping
- Design System / Handoff -> theme token files and shared widgets
- Splash Screen -> `lib/features/onboarding/presentation/splash_screen.dart`
- Refined Home Dashboard -> `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- Refined Debts List -> `lib/features/debts/presentation/debts_screens.dart` (`DebtsListScreen`)
- Refined Debt Details -> `lib/features/debts/presentation/debts_screens.dart` (`DebtDetailsScreen`)
- Refined Add/Edit Debt -> `lib/features/debts/presentation/debts_screens.dart` (`AddEditDebtScreen`)
- Refined Strategy Simulator -> `lib/features/strategy/presentation/strategy_simulator_screen.dart`

## Components reused or replaced
- `AppPage`: retained, restyled for centered fintech header and safe-area content.
- `AppCard`: replaced Card dependency with tokenized rounded surface, border, ambient shadow.
- `SectionHeader`: expanded with subtitle/trailing support.
- `SensitiveValueText`: preserved masking behavior with subtle animated reveal/hide.
- New shared components: `HeroFinanceCard`, `AppStatCard`, `AppStatusBadge`.
- NavigationBar: preserved routes, updated visual container, selected icons, and Stitch-like indicator.

## Risk areas
- Existing dirty worktree contains unrelated backend/provider/test changes; redesign avoids reverting them.
- Add/Edit debt remains a single route and form, so form validation and save behavior are preserved.
- Financial calculations are untouched; all dashboard and strategy values still come from providers/services.
- Small-screen risk is highest in dense stat rows and segmented strategy selector; analyzer/format pass and widget tests should catch obvious issues.
