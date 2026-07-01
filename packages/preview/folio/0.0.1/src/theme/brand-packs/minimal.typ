// ─── Folio Brand Pack: Minimal (Typst defaults, no flourish) ───────────────
// This preset uses Typst's built-in defaults wherever possible.
// No custom fonts, no strong colors, no decorative radii.
// Ideal for users who want the cleanest possible output or as a
// neutral base for heavy customization.

#let brand = (
  typography: (
    font: (
      body: ("Liberation Serif", "New Computer Modern"),
      heading: ("Liberation Serif", "New Computer Modern"),
    ),
    size: (
      body: 11pt,
      sm: 0.85em,
      md: 1em,
      lg: 1.2em,
      xl: 1.4em,
    ),
  ),
  palette: (
    primary: rgb("#333333"),
    text: rgb("#212121"),
    intent: (
      success: rgb("#2e7d32"),
      danger: rgb("#c62828"),
      warning: rgb("#f57f17"),
      neutral: rgb("#757575"),
    ),
    surface: (
      background: rgb("#ffffff"),
      card: rgb("#fafafa"),
      border: rgb("#cccccc"),
      alt: rgb("#f5f5f5"),
    ),
  ),
  geometry: (
    radius: (
      sm: 0pt,
      md: 0pt,
      lg: 0pt,
      "none": 0pt,
      card: 0pt,
      table: 0pt,
      badge: 2pt,
      progress: 0pt,
    ),
    stroke-width: (
      thin: 0.5pt,
      normal: 0.75pt,
      thick: 1.5pt,
    ),
    gantt: (
      bar-height: 14pt,
      subtask-bar-height: 10pt,
      sidebar-padding: 12pt,
      sidebar-spacing: 1em,
    ),
    table: (
      cell-padding: 0.6em,
    ),
    page-margin: 2.5cm,
    paper: "a4",
  ),
  spacing: (
    base: 1em,
    density-multiplier: (
      compact: 0.6,
      comfortable: 1.0,
      spacious: 1.3,
    ),
  ),
)
