#let brand = (
  typography: (
    font: (
      body: ("Liberation Sans", "DejaVu Sans"),
      heading: ("Liberation Sans", "DejaVu Sans"),
    ),
    size: (
      body: 10pt,
      sm: 0.85em,
      md: 1em,
      lg: 1.25em,
      xl: 1.5em,
    ),
  ),
  palette: (
    primary: rgb("#2563eb"),
    text: rgb("#0f172a"),
    intent: (
      success: rgb("#16a34a"),
      danger: rgb("#dc2626"),
      warning: rgb("#eab308"),
      neutral: rgb("#64748b"),
    ),
    surface: (
      background: rgb("#ffffff"),
      card: rgb("#f8fafc"),
      border: rgb("#e2e8f0"),
      alt: rgb("#f1f5f9"),
    ),
  ),
  geometry: (
    radius: (
      sm: 2pt,
      md: 4pt,
      lg: 8pt,
      "none": 0pt,
      card: 8pt,
      table: 4pt,
      badge: 4pt,
      progress: 4pt,
    ),
    stroke-width: (
      thin: 0.5pt,
      normal: 1pt,
      thick: 2pt,
    ),
    gantt: (
      bar-height: 16pt,
      subtask-bar-height: 10pt,
      sidebar-padding: 15pt,
      sidebar-spacing: 1em,
    ),
    table: (
      cell-padding: 0.75em,
    ),
    page-margin: 2.5cm,
    paper: "a4",
  ),
  spacing: (
    base: 1em,
    density-multiplier: (
      compact: 0.5,
      comfortable: 1.0,
      spacious: 1.5,
    ),
  ),
)
