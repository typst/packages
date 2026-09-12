// pi-games.typ — Umbrella module bundling all pi-game libraries.
// Piotr Kuszewski · SGH Warsaw School of Economics
//
// Import once to get the shared palette, normal-form tables, and
// extensive-form game trees in a single namespace:
//   #import "@preview/pi-games:0.1.0": *
//
// Bundles (in src/):
//   · pi-game-palette.typ   — shared colour palette (single source of truth)
//   · pi-game-normal.typ    — normal-form / strategic-form game tables
//   · pi-game-trees.typ     — extensive-form game trees (CeTZ)
//
// Only the documented public API is re-exported. Each name is imported
// from a single canonical source to avoid duplicate bindings. Internal
// helpers are deliberately NOT re-exported (see the exclusion note below),
// and `cetz` is not re-exported — import it directly where a `cetz.canvas`
// block is needed:  #import "@preview/cetz:0.5.2" as cetz

// ── Shared colour palette (canonical source of all colours) ───────────
#import "src/pi-game-palette.typ": (
  game-player-colors,
  game-nature-color,
  game-fg,
  game-nash-color,
  game-highlight-color,
  game-infoset-color,
  game-subgame-stroke,
  game-subgame-fill,
  game-subgame-label,
)

// ── Normal-form games: functions + normal-form style/geometry config ──
#import "src/pi-game-normal.typ": (
  game-normal-form,
  game-three-player-normal-form,
  game-pal,
  game-cell-width,
  game-cell-height,
  game-games-per-row,
)

// ── Extensive-form trees: functions + tree-only geometry/style config ─
#import "src/pi-game-trees.typ": (
  // drawing functions
  game-node,
  game-nature,
  game-terminal,
  game-branch,
  game-prob,
  game-infoset,
  game-subgame,
  game-highlight,
  // inline text helpers
  game-payoffs,
  game-player,
  game-player-default,
  // geometry constants
  game-node-radius,
  game-terminal-radius,
  game-gap,
  game-act,
  game-apos,
  game-tick,
  // stroke widths
  game-sw-b,
  game-sw-n,
  game-sw-ni,
  game-sw-i,
  game-sw-h,
  // font sizes
  game-fsl,
  game-fsa,
  game-fsp,
)

// Deliberately excluded internal helpers (private to pi-game-trees.typ,
// not part of the public API): _gc, _gD, _gA, _vs, _va, _vm, _vn,
// _vpl, _vpr, _gvanch, _gname. They are not listed above, so a wildcard
// `#import "@preview/pi-games:0.1.0": *` will not expose them.
