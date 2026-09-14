/// Theme system for pepentation presentations.
///
/// This module provides theme presets that can be used with `setup-presentation`.
/// Themes are dictionaries that can be easily merged and customized.
///
/// # Usage
/// ```typ
/// #import "@local/pepentation:0.1.0": *
/// #import "@local/pepentation:0.1.0/themes": themes
///
/// #show: setup-presentation.with(
///   theme: themes.theme-azure-breeze
/// )
/// ```
///
/// # Customization
/// You can easily customize themes by merging:
/// ```typ
/// #show: setup-presentation.with(
///   theme: (..themes.theme-azure-breeze, primary: rgb("#FF0000"))
/// )
/// ```

/// Default theme structure with all available options.
#let default-theme = (
  primary: rgb("#003365"),
  secondary: rgb("#00649F"),
  background: rgb("#FFFFFF"),
  main-text: rgb("#000000"),
  sub-text: rgb("#FFFFFF"),
  sub-text-dimmed: rgb("#FFFFFF"),
  code-background: luma(240),
  code-text: none,
  dark: false,
  toc-background: rgb("#003365").transparentize(95%),
  toc-text: rgb("#003365"),
  toc-stroke: rgb("#003365").lighten(50%),
  blocks: (
    definition-color: gray,
    warning-color: red,
    remark-color: orange,
    hint-color: green,
    info-color: blue,
    example-color: purple,
    quote-color: luma(200),
    success-color: rgb("#22c55e"),
    failure-color: rgb("#ef4444"),
  ),
)

/// Azure Breeze - Light blue theme with a fresh, airy feel.
#let theme-azure-breeze = (
  primary: rgb("#0ea5e9"),
  secondary: rgb("#38bdf8"),
  background: rgb("#f0f9ff"),
  main-text: rgb("#0c4a6e"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#e0f2fe"),
  code-background: rgb("#e0f2fe"),
  code-text: rgb("#0369a1"),
  dark: false,
  toc-background: rgb("#0ea5e9").transparentize(95%),
  toc-text: rgb("#0ea5e9"),
  toc-stroke: rgb("#0ea5e9").lighten(50%),
  blocks: (
    definition-color: rgb("#cbd5e1"),
    warning-color: rgb("#fca5a5"),
    remark-color: rgb("#fdba74"),
    hint-color: rgb("#86efac"),
    info-color: rgb("#7dd3fc"),
    example-color: rgb("#c084fc"),
    quote-color: rgb("#e2e8f0"),
    success-color: rgb("#4ade80"),
    failure-color: rgb("#f87171"),
  ),
)

/// Azure Breeze Dark - Dark variant of the azure breeze theme.
#let theme-azure-breeze-dark = (
  primary: rgb("#0284c7"),
  secondary: rgb("#0ea5e9"),
  background: rgb("#0c4a6e"),
  main-text: rgb("#e0f2fe"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#7dd3fc"),
  code-background: rgb("#0a1a2a"),
  code-text: rgb("#7dd3fc"),
  dark: true,
  toc-background: rgb("#0284c7").lighten(50%).transparentize(95%),
  toc-text: rgb("#0284c7").lighten(60%),
  toc-stroke: rgb("#0284c7").lighten(20%),
  blocks: (
    definition-color: rgb("#334155"),
    warning-color: rgb("#991b1b"),
    remark-color: rgb("#9a3412"),
    hint-color: rgb("#166534"),
    info-color: rgb("#075985"),
    example-color: rgb("#581c87"),
    quote-color: rgb("#1e293b"),
    success-color: rgb("#15803d"),
    failure-color: rgb("#dc2626"),
  ),
)

/// Crimson Dawn - Red-based theme with warm, energetic tones.
#let theme-crimson-dawn = (
  primary: rgb("#dc2626"),
  secondary: rgb("#ef4444"),
  background: rgb("#fef2f2"),
  main-text: rgb("#7f1d1d"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#fee2e2"),
  code-background: rgb("#fee2e2"),
  code-text: rgb("#991b1b"),
  dark: false,
  toc-background: rgb("#dc2626").transparentize(95%),
  toc-text: rgb("#dc2626"),
  toc-stroke: rgb("#dc2626").lighten(50%),
  blocks: (
    definition-color: rgb("#e5e7eb"),
    warning-color: rgb("#fca5a5"),
    remark-color: rgb("#fdba74"),
    hint-color: rgb("#86efac"),
    info-color: rgb("#7dd3fc"),
    example-color: rgb("#c084fc"),
    quote-color: rgb("#f3f4f6"),
    success-color: rgb("#4ade80"),
    failure-color: rgb("#f87171"),
  ),
)

/// Crimson Dawn Dark - Dark variant of the crimson dawn theme.
#let theme-crimson-dawn-dark = (
  primary: rgb("#b91c1c"),
  secondary: rgb("#dc2626"),
  background: rgb("#7f1d1d"),
  main-text: rgb("#fee2e2"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#fca5a5"),
  code-background: rgb("#450a0a"),
  code-text: rgb("#fca5a5"),
  dark: true,
  toc-background: rgb("#b91c1c").lighten(50%).transparentize(95%),
  toc-text: rgb("#b91c1c").lighten(60%),
  toc-stroke: rgb("#b91c1c").lighten(20%),
  blocks: (
    definition-color: rgb("#374151"),
    warning-color: rgb("#991b1b"),
    remark-color: rgb("#9a3412"),
    hint-color: rgb("#166534"),
    info-color: rgb("#075985"),
    example-color: rgb("#581c87"),
    quote-color: rgb("#1f2937"),
    success-color: rgb("#15803d"),
    failure-color: rgb("#dc2626"),
  ),
)

/// Forest Canopy - Green-based theme with natural, calming tones.
#let theme-forest-canopy = (
  primary: rgb("#16a34a"),
  secondary: rgb("#22c55e"),
  background: rgb("#f0fdf4"),
  main-text: rgb("#14532d"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#dcfce7"),
  code-background: rgb("#dcfce7"),
  code-text: rgb("#166534"),
  dark: false,
  toc-background: rgb("#16a34a").transparentize(95%),
  toc-text: rgb("#16a34a"),
  toc-stroke: rgb("#16a34a").lighten(50%),
  blocks: (
    definition-color: rgb("#d1d5db"),
    warning-color: rgb("#fca5a5"),
    remark-color: rgb("#fdba74"),
    hint-color: rgb("#86efac"),
    info-color: rgb("#7dd3fc"),
    example-color: rgb("#c084fc"),
    quote-color: rgb("#e5e7eb"),
    success-color: rgb("#4ade80"),
    failure-color: rgb("#f87171"),
  ),
)

/// Forest Canopy Dark - Dark variant of the forest canopy theme.
#let theme-forest-canopy-dark = (
  primary: rgb("#15803d"),
  secondary: rgb("#16a34a"),
  background: rgb("#14532d"),
  main-text: rgb("#dcfce7"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#86efac"),
  code-background: rgb("#052e15"),
  code-text: rgb("#86efac"),
  dark: true,
  toc-background: rgb("#15803d").lighten(50%).transparentize(95%),
  toc-text: rgb("#15803d").lighten(60%),
  toc-stroke: rgb("#15803d").lighten(20%),
  blocks: (
    definition-color: rgb("#1f2937"),
    warning-color: rgb("#991b1b"),
    remark-color: rgb("#9a3412"),
    hint-color: rgb("#166534"),
    info-color: rgb("#075985"),
    example-color: rgb("#581c87"),
    quote-color: rgb("#111827"),
    success-color: rgb("#15803d"),
    failure-color: rgb("#dc2626"),
  ),
)

/// Deep Ocean - Blue-based theme (enhanced default).
#let theme-deep-ocean = (
  primary: rgb("#003365"),
  secondary: rgb("#00649F"),
  background: rgb("#FFFFFF"),
  main-text: rgb("#000000"),
  sub-text: rgb("#FFFFFF"),
  sub-text-dimmed: rgb("#E6F2F8"),
  code-background: luma(240),
  code-text: none,
  dark: false,
  toc-background: rgb("#003365").transparentize(95%),
  toc-text: rgb("#003365"),
  toc-stroke: rgb("#003365").lighten(50%),
  blocks: (
    definition-color: gray,
    warning-color: red,
    remark-color: orange,
    hint-color: green,
    info-color: blue,
    example-color: purple,
    quote-color: luma(200),
    success-color: rgb("#22c55e"),
    failure-color: rgb("#ef4444"),
  ),
)

/// Deep Ocean Dark - Dark variant of the deep ocean theme.
#let theme-deep-ocean-dark = (
  primary: rgb("#00649F"),
  secondary: rgb("#0ea5e9"),
  background: rgb("#001122"),
  main-text: rgb("#E6F2F8"),
  sub-text: rgb("#FFFFFF"),
  sub-text-dimmed: rgb("#7dd3fc"),
  code-background: rgb("#000a1a"),
  code-text: rgb("#7dd3fc"),
  dark: true,
  toc-background: rgb("#00649F").lighten(50%).transparentize(95%),
  toc-text: rgb("#00649F").lighten(60%),
  toc-stroke: rgb("#00649F").lighten(20%),
  blocks: (
    definition-color: rgb("#1e3a5f"),
    warning-color: rgb("#991b1b"),
    remark-color: rgb("#9a3412"),
    hint-color: rgb("#166534"),
    info-color: rgb("#075985"),
    example-color: rgb("#581c87"),
    quote-color: rgb("#0c4a6e"),
    success-color: rgb("#15803d"),
    failure-color: rgb("#dc2626"),
  ),
)

/// Twilight Violet - Purple-based theme with elegant, mysterious tones.
#let theme-twilight-violet = (
  primary: rgb("#7c3aed"),
  secondary: rgb("#8b5cf6"),
  background: rgb("#faf5ff"),
  main-text: rgb("#3b0764"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#e9d5ff"),
  code-background: rgb("#e9d5ff"),
  code-text: rgb("#6b21a8"),
  dark: false,
  toc-background: rgb("#7c3aed").transparentize(95%),
  toc-text: rgb("#7c3aed"),
  toc-stroke: rgb("#7c3aed").lighten(50%),
  blocks: (
    definition-color: rgb("#e5e7eb"),
    warning-color: rgb("#fca5a5"),
    remark-color: rgb("#fdba74"),
    hint-color: rgb("#86efac"),
    info-color: rgb("#7dd3fc"),
    example-color: rgb("#c084fc"),
    quote-color: rgb("#f3f4f6"),
    success-color: rgb("#4ade80"),
    failure-color: rgb("#f87171"),
  ),
)

/// Twilight Violet Dark - Dark variant of the twilight violet theme.
#let theme-twilight-violet-dark = (
  primary: rgb("#6b21a8"),
  secondary: rgb("#7c3aed"),
  background: rgb("#3b0764"),
  main-text: rgb("#e9d5ff"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#c084fc"),
  code-background: rgb("#1a0529"),
  code-text: rgb("#c084fc"),
  dark: true,
  toc-background: rgb("#6b21a8").lighten(50%).transparentize(95%),
  toc-text: rgb("#6b21a8").lighten(60%),
  toc-stroke: rgb("#6b21a8").lighten(20%),
  blocks: (
    definition-color: rgb("#1f2937"),
    warning-color: rgb("#991b1b"),
    remark-color: rgb("#9a3412"),
    hint-color: rgb("#166534"),
    info-color: rgb("#075985"),
    example-color: rgb("#581c87"),
    quote-color: rgb("#111827"),
    success-color: rgb("#15803d"),
    failure-color: rgb("#dc2626"),
  ),
)

/// Golden Hour - Warm, sunset-inspired theme with golden and amber tones.
#let theme-golden-hour = (
  primary: rgb("#d97706"),
  secondary: rgb("#f59e0b"),
  background: rgb("#fffbeb"),
  main-text: rgb("#78350f"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#fef3c7"),
  code-background: rgb("#fef3c7"),
  code-text: rgb("#92400e"),
  dark: false,
  toc-background: rgb("#d97706").transparentize(95%),
  toc-text: rgb("#d97706"),
  toc-stroke: rgb("#d97706").lighten(50%),
  blocks: (
    definition-color: rgb("#f3f4f6"),
    warning-color: rgb("#fca5a5"),
    remark-color: rgb("#fdba74"),
    hint-color: rgb("#86efac"),
    info-color: rgb("#7dd3fc"),
    example-color: rgb("#c084fc"),
    quote-color: rgb("#f9fafb"),
    success-color: rgb("#4ade80"),
    failure-color: rgb("#f87171"),
  ),
)

/// Golden Hour Dark - Dark variant of the golden hour theme.
#let theme-golden-hour-dark = (
  primary: rgb("#b45309"),
  secondary: rgb("#d97706"),
  background: rgb("#78350f"),
  main-text: rgb("#fef3c7"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#fcd34d"),
  code-background: rgb("#2d1b05"),
  code-text: rgb("#fcd34d"),
  dark: true,
  toc-background: rgb("#b45309").lighten(50%).transparentize(95%),
  toc-text: rgb("#b45309").lighten(60%),
  toc-stroke: rgb("#b45309").lighten(20%),
  blocks: (
    definition-color: rgb("#1f2937"),
    warning-color: rgb("#991b1b"),
    remark-color: rgb("#9a3412"),
    hint-color: rgb("#166534"),
    info-color: rgb("#075985"),
    example-color: rgb("#581c87"),
    quote-color: rgb("#111827"),
    success-color: rgb("#15803d"),
    failure-color: rgb("#dc2626"),
  ),
)

/// Emerald Glow - Vibrant green theme with emerald accents.
#let theme-emerald-glow = (
  primary: rgb("#059669"),
  secondary: rgb("#10b981"),
  background: rgb("#ecfdf5"),
  main-text: rgb("#064e3b"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#d1fae5"),
  code-background: rgb("#d1fae5"),
  code-text: rgb("#047857"),
  dark: false,
  toc-background: rgb("#059669").transparentize(95%),
  toc-text: rgb("#059669"),
  toc-stroke: rgb("#059669").lighten(50%),
  blocks: (
    definition-color: rgb("#e5e7eb"),
    warning-color: rgb("#fca5a5"),
    remark-color: rgb("#fdba74"),
    hint-color: rgb("#86efac"),
    info-color: rgb("#7dd3fc"),
    example-color: rgb("#c084fc"),
    quote-color: rgb("#f3f4f6"),
    success-color: rgb("#34d399"),
    failure-color: rgb("#f87171"),
  ),
)

/// Emerald Glow Dark - Dark variant of the emerald glow theme.
#let theme-emerald-glow-dark = (
  primary: rgb("#047857"),
  secondary: rgb("#059669"),
  background: rgb("#064e3b"),
  main-text: rgb("#d1fae5"),
  sub-text: rgb("#ffffff"),
  sub-text-dimmed: rgb("#6ee7b7"),
  code-background: rgb("#052e1f"),
  code-text: rgb("#6ee7b7"),
  dark: true,
  toc-background: rgb("#047857").lighten(50%).transparentize(95%),
  toc-text: rgb("#047857").lighten(60%),
  toc-stroke: rgb("#047857").lighten(20%),
  blocks: (
    definition-color: rgb("#1f2937"),
    warning-color: rgb("#991b1b"),
    remark-color: rgb("#9a3412"),
    hint-color: rgb("#065f46"),
    info-color: rgb("#075985"),
    example-color: rgb("#581c87"),
    quote-color: rgb("#111827"),
    success-color: rgb("#047857"),
    failure-color: rgb("#dc2626"),
  ),
)
