// Warm Amber Theme - Color System with Light/Dark Variants
// Inspired by Moloch's semantic color system with persistent customization

// =============================================================================
// THEME STATE FOR DYNAMIC COMPONENTS
// =============================================================================

// State to store current theme colors - set by theme, read by components
#let theme-colors-state = state("theme-colors-state", none)

// =============================================================================
// COLOR THEME PRESETS
// =============================================================================

// Warm Amber theme (default) - Light variant
#let warm-amber-light = (
  // Primary accent colors
  accent-primary: rgb("#C2762E"),
  accent-secondary: rgb("#D4915A"),
  accent-subtle: rgb("#FDF6EE"),
  accent-glow: rgb("#E8A756"),
  accent-deep: rgb("#9E5F23"),

  // Background hierarchy
  bg-base: rgb("#FDFCFA"),
  bg-elevated: rgb("#FFFFFF"),
  bg-muted: rgb("#F9F7F4"),
  bg-surface: rgb("#F5F2EE"),
  bg-wash: rgb("#FAF8F5"),

  // Text hierarchy
  text-primary: rgb("#2D2A26"),
  text-secondary: rgb("#5C564E"),
  text-muted: rgb("#8C857B"),
  text-light: rgb("#B5AFA6"),
  text-subtle: rgb("#A49E95"),

  // Borders
  border-subtle: rgb("#EAE6E1"),
  border-soft: rgb("#E0DBD4"),
  border-medium: rgb("#D4CEC5"),
  progress-track: rgb("#E8E4DE"),

  // Functional colors
  alert-bg: rgb("#FEF3F2"),
  alert-border: rgb("#F87171"),
  alert-text: rgb("#DC2626"),
  example-bg: rgb("#F0FDF4"),
  example-border: rgb("#4ADE80"),
  example-text: rgb("#16A34A"),

  // Focus slide (gradient amber)
  focus-bg: rgb("#C2762E"),
  focus-text: rgb("#FFFEFA"),

  // Standout slide - deep amber with warm cream (elegant, cohesive)
  standout-bg: rgb("#8B5A2B"),     // Deep sienna brown
  standout-text: rgb("#FFF8F0"),   // Warm cream text

  // Header bar (Moloch-style) - using warm amber tones
  header-bg: rgb("#9E5F23"),       // Deep amber for header
  header-text: rgb("#FFFEFA"),     // Warm white text
)

// Warm Amber theme - Dark variant
#let warm-amber-dark = (
  // Primary accent colors (slightly brighter for dark bg)
  accent-primary: rgb("#E8A756"),
  accent-secondary: rgb("#D4915A"),
  accent-subtle: rgb("#3D3530"),
  accent-glow: rgb("#F0B866"),
  accent-deep: rgb("#C2762E"),

  // Background hierarchy (inverted)
  bg-base: rgb("#1C1917"),
  bg-elevated: rgb("#292524"),
  bg-muted: rgb("#1F1C1A"),
  bg-surface: rgb("#262220"),
  bg-wash: rgb("#211E1C"),

  // Text hierarchy (inverted)
  text-primary: rgb("#FAFAF9"),
  text-secondary: rgb("#D6D3D1"),
  text-muted: rgb("#A8A29E"),
  text-light: rgb("#78716C"),
  text-subtle: rgb("#57534E"),

  // Borders (inverted)
  border-subtle: rgb("#3D3835"),
  border-soft: rgb("#44403C"),
  border-medium: rgb("#57534E"),
  progress-track: rgb("#44403C"),

  // Functional colors (adjusted for dark)
  alert-bg: rgb("#450A0A"),
  alert-border: rgb("#DC2626"),
  alert-text: rgb("#FCA5A5"),
  example-bg: rgb("#052E16"),
  example-border: rgb("#16A34A"),
  example-text: rgb("#86EFAC"),

  // Focus slide (gradient amber)
  focus-bg: rgb("#E8A756"),
  focus-text: rgb("#1C1917"),

  // Standout slide - warm cream with deep amber (inverted from light)
  standout-bg: rgb("#FFF8F0"),      // Warm cream background
  standout-text: rgb("#8B5A2B"),    // Deep sienna text

  // Header bar - amber accent on dark
  header-bg: rgb("#C2762E"),        // Warm amber header
  header-text: rgb("#FAFAF9"),      // Light text
)

// Tomorrow theme (programmer-friendly) - Light variant
#let tomorrow-light = (
  accent-primary: rgb("#4271AE"),
  accent-secondary: rgb("#718C00"),
  accent-subtle: rgb("#EFF1F5"),
  accent-glow: rgb("#3E999F"),
  accent-deep: rgb("#8959A8"),

  bg-base: rgb("#FFFFFF"),
  bg-elevated: rgb("#FFFFFF"),
  bg-muted: rgb("#F2F2F2"),
  bg-surface: rgb("#EFEFEF"),
  bg-wash: rgb("#F7F7F7"),

  text-primary: rgb("#1D1F21"),
  text-secondary: rgb("#4D4D4C"),
  text-muted: rgb("#8E908C"),
  text-light: rgb("#C5C8C6"),
  text-subtle: rgb("#A0A1A0"),

  border-subtle: rgb("#E0E0E0"),
  border-soft: rgb("#D6D6D6"),
  border-medium: rgb("#C8C8C8"),
  progress-track: rgb("#E0E0E0"),

  alert-bg: rgb("#FDF2F2"),
  alert-border: rgb("#C82829"),
  alert-text: rgb("#C82829"),
  example-bg: rgb("#F2FDF5"),
  example-border: rgb("#718C00"),
  example-text: rgb("#718C00"),

  focus-bg: rgb("#4271AE"),
  focus-text: rgb("#FFFFFF"),

  // Standout slide
  standout-bg: rgb("#1D1F21"),
  standout-text: rgb("#81A2BE"),

  // Header bar - using blue accent
  header-bg: rgb("#4271AE"),
  header-text: rgb("#FFFFFF"),
)

// Tomorrow theme - Dark variant
#let tomorrow-dark = (
  accent-primary: rgb("#81A2BE"),
  accent-secondary: rgb("#B5BD68"),
  accent-subtle: rgb("#373B41"),
  accent-glow: rgb("#8ABEB7"),
  accent-deep: rgb("#B294BB"),

  bg-base: rgb("#1D1F21"),
  bg-elevated: rgb("#282A2E"),
  bg-muted: rgb("#232527"),
  bg-surface: rgb("#2D2F33"),
  bg-wash: rgb("#252729"),

  text-primary: rgb("#C5C8C6"),
  text-secondary: rgb("#969896"),
  text-muted: rgb("#707070"),
  text-light: rgb("#4D4D4C"),
  text-subtle: rgb("#5C5E5C"),

  border-subtle: rgb("#373B41"),
  border-soft: rgb("#444850"),
  border-medium: rgb("#555960"),
  progress-track: rgb("#373B41"),

  alert-bg: rgb("#3A1F1F"),
  alert-border: rgb("#CC6666"),
  alert-text: rgb("#CC6666"),
  example-bg: rgb("#1F3A1F"),
  example-border: rgb("#B5BD68"),
  example-text: rgb("#B5BD68"),

  focus-bg: rgb("#81A2BE"),
  focus-text: rgb("#1D1F21"),

  // Standout slide
  standout-bg: rgb("#C5C8C6"),
  standout-text: rgb("#1D1F21"),

  // Header bar - lighter blue on dark
  header-bg: rgb("#81A2BE"),
  header-text: rgb("#1D1F21"),
)

// Paper theme (high contrast, academic) - Light variant
#let paper-light = (
  accent-primary: rgb("#1A1A1A"),
  accent-secondary: rgb("#2563EB"),
  accent-subtle: rgb("#F5F5F5"),
  accent-glow: rgb("#3B82F6"),
  accent-deep: rgb("#0F172A"),

  bg-base: rgb("#FFFFFF"),
  bg-elevated: rgb("#FFFFFF"),
  bg-muted: rgb("#F8F8F8"),
  bg-surface: rgb("#F3F3F3"),
  bg-wash: rgb("#FAFAFA"),

  text-primary: rgb("#000000"),
  text-secondary: rgb("#333333"),
  text-muted: rgb("#666666"),
  text-light: rgb("#999999"),
  text-subtle: rgb("#808080"),

  border-subtle: rgb("#E5E5E5"),
  border-soft: rgb("#D4D4D4"),
  border-medium: rgb("#A3A3A3"),
  progress-track: rgb("#E5E5E5"),

  alert-bg: rgb("#FEF2F2"),
  alert-border: rgb("#EF4444"),
  alert-text: rgb("#DC2626"),
  example-bg: rgb("#EFF6FF"),
  example-border: rgb("#2563EB"),
  example-text: rgb("#1D4ED8"),

  focus-bg: rgb("#2563EB"),
  focus-text: rgb("#FFFFFF"),

  // Standout slide
  standout-bg: rgb("#000000"),
  standout-text: rgb("#FFFFFF"),

  // Header bar - blue accent for paper theme
  header-bg: rgb("#2563EB"),
  header-text: rgb("#FFFFFF"),
)

// Paper theme - Dark variant
#let paper-dark = (
  accent-primary: rgb("#FFFFFF"),
  accent-secondary: rgb("#60A5FA"),
  accent-subtle: rgb("#262626"),
  accent-glow: rgb("#93C5FD"),
  accent-deep: rgb("#F8FAFC"),

  bg-base: rgb("#0A0A0A"),
  bg-elevated: rgb("#171717"),
  bg-muted: rgb("#0F0F0F"),
  bg-surface: rgb("#1A1A1A"),
  bg-wash: rgb("#141414"),

  text-primary: rgb("#FFFFFF"),
  text-secondary: rgb("#E5E5E5"),
  text-muted: rgb("#A3A3A3"),
  text-light: rgb("#737373"),
  text-subtle: rgb("#525252"),

  border-subtle: rgb("#262626"),
  border-soft: rgb("#404040"),
  border-medium: rgb("#525252"),
  progress-track: rgb("#262626"),

  alert-bg: rgb("#450A0A"),
  alert-border: rgb("#F87171"),
  alert-text: rgb("#FCA5A5"),
  example-bg: rgb("#172554"),
  example-border: rgb("#60A5FA"),
  example-text: rgb("#93C5FD"),

  focus-bg: rgb("#60A5FA"),
  focus-text: rgb("#0A0A0A"),

  // Standout slide
  standout-bg: rgb("#FFFFFF"),
  standout-text: rgb("#0A0A0A"),

  // Header bar - lighter blue on dark paper
  header-bg: rgb("#60A5FA"),
  header-text: rgb("#0A0A0A"),
)

// Dracula theme - Light variant
#let dracula-light = (
  accent-primary: rgb("#BD93F9"),
  accent-secondary: rgb("#FF79C6"),
  accent-subtle: rgb("#F8F8F2"),
  accent-glow: rgb("#8BE9FD"),
  accent-deep: rgb("#6272A4"),

  bg-base: rgb("#F8F8F2"),
  bg-elevated: rgb("#FFFFFF"),
  bg-muted: rgb("#F0F0EB"),
  bg-surface: rgb("#E8E8E3"),
  bg-wash: rgb("#F5F5F0"),

  text-primary: rgb("#282A36"),
  text-secondary: rgb("#44475A"),
  text-muted: rgb("#6272A4"),
  text-light: rgb("#9090A0"),
  text-subtle: rgb("#7575A0"),

  border-subtle: rgb("#E0E0D8"),
  border-soft: rgb("#D0D0C8"),
  border-medium: rgb("#B0B0A8"),
  progress-track: rgb("#E0E0D8"),

  alert-bg: rgb("#FFF0F0"),
  alert-border: rgb("#FF5555"),
  alert-text: rgb("#FF5555"),
  example-bg: rgb("#F0FFF4"),
  example-border: rgb("#50FA7B"),
  example-text: rgb("#50FA7B"),

  focus-bg: rgb("#BD93F9"),
  focus-text: rgb("#282A36"),

  standout-bg: rgb("#FF79C6"),
  standout-text: rgb("#282A36"),

  header-bg: rgb("#BD93F9"),
  header-text: rgb("#282A36"),
)

// Dracula theme - Dark variant
#let dracula-dark = (
  accent-primary: rgb("#BD93F9"),
  accent-secondary: rgb("#FF79C6"),
  accent-subtle: rgb("#44475A"),
  accent-glow: rgb("#8BE9FD"),
  accent-deep: rgb("#6272A4"),

  bg-base: rgb("#282A36"),
  bg-elevated: rgb("#343746"),
  bg-muted: rgb("#21222C"),
  bg-surface: rgb("#3A3C4E"),
  bg-wash: rgb("#2E303E"),

  text-primary: rgb("#F8F8F2"),
  text-secondary: rgb("#E0E0E0"),
  text-muted: rgb("#BFBFBF"),
  text-light: rgb("#6272A4"),
  text-subtle: rgb("#7580A0"),

  border-subtle: rgb("#44475A"),
  border-soft: rgb("#4A4D5E"),
  border-medium: rgb("#6272A4"),
  progress-track: rgb("#44475A"),

  alert-bg: rgb("#3A1F2A"),
  alert-border: rgb("#FF5555"),
  alert-text: rgb("#FF6E6E"),
  example-bg: rgb("#253D2A"),
  example-border: rgb("#50FA7B"),
  example-text: rgb("#69FF94"),

  focus-bg: rgb("#BD93F9"),
  focus-text: rgb("#282A36"),

  standout-bg: rgb("#FF79C6"),
  standout-text: rgb("#282A36"),

  header-bg: rgb("#BD93F9"),
  header-text: rgb("#282A36"),
)

// =============================================================================
// COLOR GETTER SYSTEM
// =============================================================================

// Get colors for a given theme and variant
#let get-theme-colors(theme: "warm-amber", variant: "light") = {
  let themes = (
    "warm-amber": (light: warm-amber-light, dark: warm-amber-dark),
    "tomorrow": (light: tomorrow-light, dark: tomorrow-dark),
    "paper": (light: paper-light, dark: paper-dark),
    "dracula": (light: dracula-light, dark: dracula-dark),
  )

  let selected-theme = themes.at(theme, default: themes.warm-amber)
  selected-theme.at(variant, default: selected-theme.light)
}

// =============================================================================
// DEFAULT COLORS (backwards compatibility - warm-amber light)
// =============================================================================

#let accent-primary = warm-amber-light.accent-primary
#let accent-secondary = warm-amber-light.accent-secondary
#let accent-subtle = warm-amber-light.accent-subtle
#let accent-glow = warm-amber-light.accent-glow
#let accent-deep = warm-amber-light.accent-deep

#let bg-base = warm-amber-light.bg-base
#let bg-elevated = warm-amber-light.bg-elevated
#let bg-muted = warm-amber-light.bg-muted
#let bg-surface = warm-amber-light.bg-surface
#let bg-wash = warm-amber-light.bg-wash

#let text-primary = warm-amber-light.text-primary
#let text-secondary = warm-amber-light.text-secondary
#let text-muted = warm-amber-light.text-muted
#let text-light = warm-amber-light.text-light
#let text-subtle = warm-amber-light.text-subtle

#let border-subtle = warm-amber-light.border-subtle
#let border-soft = warm-amber-light.border-soft
#let border-medium = warm-amber-light.border-medium
#let progress-track = warm-amber-light.progress-track

#let alert-bg = warm-amber-light.alert-bg
#let alert-border = warm-amber-light.alert-border
#let alert-text = warm-amber-light.alert-text
#let example-bg = warm-amber-light.example-bg
#let example-border = warm-amber-light.example-border
#let example-text = warm-amber-light.example-text

#let focus-bg = warm-amber-light.focus-bg
#let focus-text = warm-amber-light.focus-text

#let standout-bg = warm-amber-light.standout-bg
#let standout-text = warm-amber-light.standout-text

#let header-bg = warm-amber-light.header-bg
#let header-text = warm-amber-light.header-text

// =============================================================================
// GRADIENTS (generated based on colors)
// =============================================================================

#let make-gradients(colors) = {
  (
    bg-gradient: gradient.linear(
      angle: 180deg,
      (colors.bg-base, 0%),
      (colors.bg-muted, 100%)
    ),
    accent-gradient: gradient.linear(
      angle: 135deg,
      (colors.accent-secondary, 0%),
      (colors.accent-primary, 50%),
      (colors.accent-deep, 100%)
    ),
    title-gradient: gradient.linear(
      angle: 180deg,
      (colors.bg-base, 0%),
      (colors.accent-subtle, 100%)
    ),
    header-gradient: gradient.linear(
      angle: 0deg,
      (colors.accent-primary.transparentize(20%), 0%),
      (colors.accent-secondary.transparentize(60%), 30%),
      (colors.border-subtle, 100%)
    ),
    progress-gradient: gradient.linear(
      angle: 0deg,
      (colors.accent-secondary, 0%),
      (colors.accent-primary, 100%)
    ),
  )
}

// Default gradients
#let bg-gradient = gradient.linear(
  angle: 180deg,
  (rgb("#FDFCFA"), 0%),
  (rgb("#F9F7F4"), 100%)
)

#let accent-gradient = gradient.linear(
  angle: 135deg,
  (rgb("#D4915A"), 0%),
  (rgb("#C2762E"), 50%),
  (rgb("#A86B2D"), 100%)
)

#let title-gradient = gradient.linear(
  angle: 180deg,
  (rgb("#FDFCFA"), 0%),
  (rgb("#FDF6EE"), 100%)
)

// =============================================================================
// SHADOWS
// =============================================================================

#let shadow-soft = rgb("#2D2A26").transparentize(96%)
#let shadow-medium = rgb("#2D2A26").transparentize(92%)
#let shadow-strong = rgb("#2D2A26").transparentize(88%)

#let overlay-light = rgb("#FFFFFF").transparentize(40%)
#let overlay-dark = rgb("#2D2A26").transparentize(95%)
