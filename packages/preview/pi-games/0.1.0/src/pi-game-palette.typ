// pi-game-palette.typ — Shared colour palette for pi-game libraries
// Piotr Kuszewski · SGH Warsaw School of Economics
//
// Import in any pi-game library or document:
//   #import "pi-game-palette.typ": *

// ── Player colours ────────────────────────────────────────────────
/// Per-player colour palette. Index 0 = Player 1, index 4 = Player 5.
/// Used by `pi-game-trees` and `pi-games` as the single source of truth
/// for player colours across all representation formats.
/// Override in a document by redefining after import:
/// `#let game-player-colors = (rgb("…"), rgb("…"), …)`
#let game-player-colors = (
  rgb("#c41b34"),   // Player 1 — dark crimson red
  rgb("#4b73a0"),   // Player 2 — grey-blue
  rgb("#328b61"),   // Player 3 — forest green
  rgb("#c86c21"),   // Player 4 — burnt orange
  rgb("#0b7a86"),   // Player 5 — dark turquoise
)

/// Colour for Nature / chance nodes and probability labels.
#let game-nature-color = rgb("#666666")

/// General foreground colour for branch lines, terminal dots, and punctuation.
#let game-fg = rgb("#111111")

// ── Highlight colours ─────────────────────────────────────────────

/// Colour for Nash equilibrium cell outlines in normal-form game tables.
#let game-nash-color = rgb("#22c4c7")

/// Default colour for equilibrium-path overlays in game trees (`game-highlight`).
#let game-highlight-color = rgb("#e53e3e")

// ── Auxiliary colours ─────────────────────────────────────────────

/// Stroke colour for information sets when no player index is given.
#let game-infoset-color = luma(90)

/// Stroke colour for proper-subgame triangle outlines.
#let game-subgame-stroke = luma(130)

/// Fill colour for proper-subgame triangle interiors.
#let game-subgame-fill = luma(247)

/// Label colour inside proper-subgame triangles.
#let game-subgame-label = luma(145)
