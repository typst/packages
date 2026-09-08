// ─── Folio Brand Pack: Academic (Enhanced to match "Old 01" style) ─────────

#let brand = (
  typography: (
    font: (
      body: ("New Computer Modern", "Libertinus Serif", "Liberation Serif"),
      heading: ("New Computer Modern", "Libertinus Serif"),
    ),
    size: (
      body: 10pt, // old: size-body = 10pt
      sm: 0.8em, // old: size-small = 8pt (relative to 10pt)
      md: 1em,
      lg: 1.4em, // old: size-header = 14pt (relative to 10pt)
      xl: 2.4em, // old: size-title = 24pt (relative to 10pt)
    ),
  ),
  palette: (
    primary: rgb("#0d47a1"), // old: azul-oscuro
    text: rgb("#1a1a1a"), // classic print black
    intent: (
      success: rgb("#43a047"), // old: verde-exito
      danger: rgb("#e53935"), // old: rojo-error
      warning: rgb("#fb8c00"), // old: naranja-main
      neutral: rgb("#616161"), // old: gris-texto
    ),
    surface: (
      background: rgb("#ffffff"),
      card: rgb("#ffffff"),
      border: rgb("#e0e0e0"), // old: gris-borde
      alt: rgb("#f5f5f5"), // old: gris-claro (restores alternating rows!)
    ),
  ),
  geometry: (
    radius: (
      sm: 3pt, // old: priority badge radius
      md: 4pt,
      lg: 6pt, // old: budget-summary and team-card radius
      "none": 0pt,
      card: 6pt, // old: team-card = 6pt
      table: 4pt,
      badge: 10pt, // old: status-chip = 10pt (heavily rounded)
      progress: 3pt,
    ),
    stroke-width: (
      thin: 0.5pt, // old: lines were typically 0.5pt
      normal: 1pt,
      thick: 1.5pt,
    ),
    gantt: (
      bar-height: 14pt, // old: bar-height = 14pt
      subtask-bar-height: 10pt, // old: uncompleted width = 10pt
      sidebar-padding: 15pt, // old: sidebar padding = 15pt
      sidebar-spacing: 1.2em, // old: sidebar spacing = 12pt (~1.2em)
    ),
    table: (
      cell-padding: 0.75em, // old: inset (x: 8pt, y: 6pt)
    ),
    page-margin: 2cm, // old: margin (x: 2cm, y: 2cm)
    paper: "a4",
  ),
  spacing: (
    base: 1.2em, // Slightly wider base spacing to match older look
    density-multiplier: (
      compact: 0.7,
      comfortable: 1.0,
      spacious: 1.4,
    ),
  ),
)
