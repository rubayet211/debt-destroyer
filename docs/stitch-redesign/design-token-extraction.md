# Stitch Redesign - Design Token Extraction

Source project: Debt Destroyer: Premium Fintech Redesign (`9002874483131754632`)

## Screens fetched
- Splash Screen: `cf0fa5e3315d447fbd460758e303f66c`
- Refined Home Dashboard: `e35ba6fba8894f4e81d8578f0b8426d3`
- Refined Debts List: `51743bceeeb44f63b1b3fd5680b00274`
- Refined Debt Details: `27c827012c6f4ae59c4b82a1b1da7690`
- Refined Add/Edit Debt: `203372a7edf849d8a8bf58a6a58a5b2e`
- Design System Handoff: `621e7aa69d5f4524aabbb2e68ee59943`
- Refined Strategy Simulator: `37b688cd839d41729607471f8bf21725`

Design-system asset instance is not exposed through `get_screen`, but the project metadata includes the exact Design MD and token map. Downloaded references are in `docs/stitch-redesign/screenshots/` and `docs/stitch-redesign/code/`.

## Colors
- Background / surface: `#f7f9ff`
- Surface lowest: `#ffffff`
- Surface low: `#edf4ff`
- Surface container: `#e3efff`
- Surface high: `#d8eaff`
- Surface highest / variant: `#cee5ff`
- Surface dim: `#c1ddfb`
- Primary: `#00152a`
- Primary container / midnight blue: `#102a43`
- Primary fixed: `#d1e4ff`
- Primary fixed dim: `#b0c9e8`
- Secondary / success: `#006d40`
- Secondary container / fresh green: `#7afbb1`
- Secondary fixed dim: `#5cde97`
- Tertiary / teal: `#001716`
- Tertiary container: `#002e2c`
- Tertiary fixed: `#84f5ee`
- Text primary: `#001d32`
- Text secondary: `#43474d`
- Outline: `#74777e`
- Outline variant: `#c3c6ce`
- Error: `#ba1a1a`
- Error container: `#ffdad6`
- Warning accent inferred from existing app and Stitch overdue treatment: `#f08c00`

## Typography
- Family: Manrope
- Display large: 48 / 56, weight 800, slight negative tracking for hero numbers
- Display mobile: 36 / 44, weight 800
- Headline large: 32 / 40, weight 700-800
- Headline medium: 24 / 32, weight 700-800
- Headline small: 20 / 28, weight 600-700
- Body large: 18 / 28, weight 400-500
- Body medium: 16 / 24, weight 400-500
- Label large: 14 / 20, weight 600-700
- Label medium: 12 / 16, weight 500-600

## Shape and spacing
- Base spacing unit: 4
- Standard mobile margin: 20
- Gutter: 16
- Section gaps: 24, 32, 48
- Input radius: 12
- Card radius: 24-28
- Chip and nav indicator radius: full pill
- Internal card padding: 16-24 depending density

## Component styles
- Cards: white `#ffffff`, subtle outline `#c3c6ce` at reduced opacity, ambient 0 4 20 black at 4%.
- Hero finance cards: midnight blue container, white text, green progress and positive badges.
- Buttons: 52-56 height, 12 radius, primary filled navy, secondary outlined/tonal.
- Inputs: filled white, 12 radius, outline rest state, 2px primary focus border.
- Chips: compact pill chips, selected navy/green; inactive white or blue-gray surface.
- Navigation: Material 3 bottom `NavigationBar`, rounded top container, green selected indicator.
- Privacy: eye/visibility action and masked financial values; implementation preserves existing `hideBalances`.
- Charts: green/navy financial palette, calm curved lines, subtle tracks, no heavy shadow.
- Empty/loading/error: centered card treatment with one clear action where possible.
