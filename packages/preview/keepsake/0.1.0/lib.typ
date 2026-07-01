/// Template for primary content
#let primary-content(
  greeting: "Dear Someone,",
  date: [],
  salutation: "From,",
  sender: [],
  body: [],
  inset: 3em,
) = {
  box(inset: inset)[
    #set align(left)
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      text(greeting), text(date, fill: rgb("#888888")),
    )

    #body

    #set align(right)
    #salutation \
    #sender
  ]
}

/// A standard card folded once.
/// Requires 2 pages (Front/Back and Inside Left/Right).
/// Single hamburger fold of the paper
#let bifold(
  paper: "us-letter",
  front: [],
  primary: [],
  secondary: [],
  back: [],
  body,
) = {
  set page(paper: paper, flipped: true, margin: 0pt)

  // Page 1: Outside (Back | Front)
  grid(
    columns: (1fr, 1fr),
    rows: 100%,
    gutter: 0pt,
    align(center + horizon, back), align(center + horizon, front),
  )

  pagebreak()

  // Page 2: Inside (Left | Right)
  grid(
    columns: (1fr, 1fr),
    rows: 100%,
    gutter: 0pt,
    align(center + horizon, secondary), align(center + horizon, primary),
  )
}

/// A card folded hamburger twice
/// Matches the reference layout:
/// Top-Left: Front (Rotated), Top-Right: secondary
/// Bottom-Left: Back, Bottom-Right: primary
#let quarter-fold-vertical(
  front: [],
  primary: [],
  secondary: [],
  back: [],
  paper: "us-letter",
  body,
) = {
  set page(paper: paper, flipped: true, margin: 0pt)

  grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    gutter: 0pt,
    align(center + horizon, rotate(180deg, front)),
    align(center + horizon, secondary),

    align(center + horizon, back), align(center + horizon, primary),
  )
}

/// A card folded hotdog then hamburger
/// Top Row: FRONT (180°), BACK (180°)
/// Bottom Row: secondary (0°), primary (0°)
#let quarter-fold-horizontal(
  paper: "us-letter",
  front: [],
  primary: [],
  secondary: [],
  back: [],
  body,
) = {
  set page(paper: paper, flipped: true, margin: 0pt)

  grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    gutter: 0pt,
    align(center + horizon, rotate(180deg, front)),
    align(center + horizon, rotate(180deg, back)),

    align(center + horizon, secondary), align(center + horizon, primary),
  )
}
