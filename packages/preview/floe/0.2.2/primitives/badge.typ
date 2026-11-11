// ============================================================================
// FLOE DESIGN SYSTEM — BADGES & KEYBOARD CHIPS (primitives/badge.typ)
// Single Canonical Pill/Bean/Badge Primitive Across All Layers
// ============================================================================
#import "../core/lib.typ": *

/// Canonical pill/badge chip with locked cap-height-to-baseline vertical metrics.
/// Guarantees identical badge height regardless of ascenders/descenders ("info" vs "warning")
/// and whether invoked bare inline or corner-anchored inside a card/plaque/hero header.
#let badge(
  label,
  variant: "neutral",
  fill: none,
  text-color: none,
  stroke: auto,
  weight: "bold",
  size: 7.5pt,
  tracking: 0.04em,
  radius: radii.sm,
  inset: (x: 5.5pt, y: 3.2pt),
  baseline: 18%,
) = {
  let v-map = (
    "info":    (bg: rgb("#E0F2FE"), fg: rgb("#0369A1"), border: strokes.hairline + rgb("#7DD3FC")),
    "success": (bg: rgb("#DCFCE7"), fg: rgb("#15803D"), border: strokes.hairline + rgb("#86EFAC")),
    "warning": (bg: rgb("#FEF3C7"), fg: rgb("#B45309"), border: strokes.hairline + rgb("#FCD34D")),
    "danger":  (bg: rgb("#FEE2E2"), fg: rgb("#B91C1C"), border: strokes.hairline + rgb("#FCA5A5")),
    "purple":  (bg: rgb("#EDE9FE"), fg: rgb("#6D28D9"), border: strokes.hairline + rgb("#C4B5FD")),
    "dark":    (bg: slate-800,      fg: white,          border: none),
    "neutral": (bg: slate-200,      fg: slate-800,      border: strokes.hairline + slate-300),
    "outline": (bg: white,          fg: slate-700,      border: strokes.hairline + slate-300),
  )

  let theme-conf = v-map.at(variant, default: v-map.neutral)
  let final-fill = if fill != none { fill } else { theme-conf.bg }
  let final-color = if text-color != none { text-color } else { theme-conf.fg }
  let final-stroke = if stroke != auto {
    stroke
  } else if fill != none {
    none
  } else {
    theme-conf.border
  }

  box(
    fill: final-fill,
    stroke: final-stroke,
    radius: radius,
    inset: inset,
    baseline: baseline,
  )[#text(
    font: fonts.sans,
    size: size,
    weight: weight,
    fill: final-color,
    tracking: tracking,
    top-edge: "cap-height",
    bottom-edge: "baseline",
  )[#label]]
}

/// Keyboard keycap visualization (e.g. #kbd("Ctrl") + #kbd("C"))
#let kbd(key) = box(
  fill: slate-100,
  stroke: (
    top: strokes.border + slate-200,
    left: strokes.border + slate-200,
    right: strokes.border + slate-300,
    bottom: 1.2pt + slate-300,
  ),
  radius: radii.sm,
  inset: (x: 4.5pt, y: 2.5pt),
  baseline: 18%,
)[#text(
  font: fonts.mono,
  size: 7.5pt,
  weight: "bold",
  fill: slate-800,
  top-edge: "cap-height",
  bottom-edge: "baseline",
)[#key]]

/// Status dot indicator (e.g. #status-dot(color: floe-green) Stable)
#let status-dot(color: floe-green, size: 5pt) = box(
  width: size,
  height: size,
  radius: radii.full,
  fill: color,
  baseline: 10%,
)
