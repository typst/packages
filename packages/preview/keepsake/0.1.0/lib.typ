// Internal helper to handle the common page setup and panel styling
#let _panel-box(content, inset) = {
  box(width: 100%, height: 100%, inset: inset, align(center + horizon, content))
}

// Internal helper for drawing fold lines
#let _guides(orientation) = {
  if orientation == "vertical" {
    place(center, line(start: (0pt, 0pt), end: (0pt, 100%), stroke: (
      dash: "dashed",
      paint: gray,
      thickness: 0.5pt,
    )))
  } else if orientation == "cross" {
    place(center + horizon, line(start: (0pt, -50%), end: (0pt, 50%), stroke: (
      dash: "dashed",
      paint: gray,
      thickness: 0.5pt,
    )))
    place(center + horizon, line(start: (-50%, 0pt), end: (50%, 0pt), stroke: (
      dash: "dashed",
      paint: gray,
      thickness: 0.5pt,
    )))
  }
}

/// A standard card folded once.
/// Requires 2 pages (Front/Back and Inside Left/Right).
/// Single hamburger fold of the paper
#let bifold(
  paper: "us-letter",
  front: [],
  back: [],
  inside-left: [],
  inside-right: [],
  draw-folds: false,
  inset: 1in,
  body, // Captured but not rendered by default to avoid accidental text overflow
) = {
  set page(paper: paper, flipped: true, margin: 0pt)

  // Page 1: Outside (Back | Front)
  if draw-folds { _guides("vertical") }
  grid(
    columns: (1fr, 1fr),
    rows: 100%,
    _panel-box(back, inset), _panel-box(front, inset),
  )

  pagebreak()

  // Page 2: Inside (Left | Right)
  if draw-folds { _guides("vertical") }
  grid(
    columns: (1fr, 1fr),
    rows: 100%,
    _panel-box(inside-left, inset), _panel-box(inside-right, inset),
  )
}

/// A card folded twice (vertically then horizontally).
/// Matches the reference layout:
/// Top-Left: Front (Rotated), Top-Right: Inside Top
/// Bottom-Left: Back, Bottom-Right: Inside Bottom
#let quarter-fold-vertical(
  paper: "us-letter",
  front: [],
  back: [],
  inside-top: [],
  inside-bottom: [],
  draw-folds: false,
  inset: 0.5in,
  body,
) = {
  set page(paper: paper, flipped: true, margin: 0pt)
  if draw-folds { _guides("cross") }

  grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),

    // Panel 1: Top Left (Front of the card) - Rotated 180
    _panel-box(rotate(180deg, front), inset),

    // Panel 2: Top Right (Inner upper panel)
    _panel-box(inside-top, inset),

    // Panel 3: Bottom Left (Back of the card)
    // Aligned to bottom center to match reference
    box(width: 100%, height: 100%, inset: inset, align(bottom + center, back)),

    // Panel 4: Bottom Right (Inner lower panel)
    _panel-box(inside-bottom, inset),
  )
}

/// A card folded horizontally then vertically.
/// Top Row: FRONT (180°), BACK (180°)
/// Bottom Row: INSIDE-LEFT (0°), INSIDE-RIGHT (0°)
#let quarter-fold-horizontal(
  paper: "us-letter",
  front: [],
  back: [],
  inside-left: [],
  inside-right: [],
  draw-folds: false,
  inset: 0.5in,
  body,
) = {
  set page(paper: paper, flipped: true, margin: 0pt)
  if draw-folds { _guides("cross") }

  grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),

    _panel-box(rotate(180deg, front), inset),

    // Force the back panel content to align to the "top" of its box
    // so the user's "bottom" looks correct after rotation.
    box(width: 100%, height: 100%, inset: inset, align(top + center, rotate(
      180deg,
      back,
    ))),

    _panel-box(inside-left, inset), _panel-box(inside-right, inset),
  )
}
