// ============================================================================
// FLOE DESIGN SYSTEM — DIVIDERS (primitives/divider.typ)
// Subtle Themed Separators, Pill Chips, Dotted, Dashed, Faded & Icon Breakers
// ============================================================================
#import "../core/lib.typ": *
#import "badge.typ": badge

/// 1. Subtle horizontal hairline rule
#let divider(
  color: slate-300,
  thickness: strokes.hairline,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
  line(length: 100%, stroke: thickness + color),
)

/// 2. Horizontal separator with centered pure text label (zero box / clean text)
#let text-divider(
  label,
  color: slate-300,
  thickness: strokes.hairline,
  text-color: floe-slate,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
)[
  #grid(
    columns: (1fr, auto, 1fr),
    gutter: 10pt,
    align: (horizon, horizon, horizon),
    line(length: 100%, stroke: thickness + color),
    text(font: fonts.sans, size: text-scale.xs, weight: "bold", fill: text-color, tracking: 0.08em, top-edge: "cap-height", bottom-edge: "baseline")[#label],
    line(length: 100%, stroke: thickness + color),
  )
]

/// 3. Horizontal separator with centered pill chip badge (rounded pill with tinted fill & border)
#let chip-divider(
  label,
  color: slate-300,
  thickness: strokes.hairline,
  text-color: floe-navy,
  badge-fill: slate-100,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
)[
  #grid(
    columns: (1fr, auto, 1fr),
    gutter: 10pt,
    align: (horizon, horizon, horizon),
    line(length: 100%, stroke: thickness + color),
    badge(label, fill: badge-fill, text-color: text-color, stroke: strokes.border + color, radius: radii.full, inset: (x: 8pt, y: 3.2pt)),
    line(length: 100%, stroke: thickness + color),
  )
]

/// 4. Dotted divider line
#let dotted-divider(
  color: slate-300,
  thickness: 1.0pt,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
  line(length: 100%, stroke: (paint: color, thickness: thickness, dash: "dotted")),
)

/// 5. Dashed divider line
#let dashed-divider(
  color: slate-300,
  thickness: 0.8pt,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
  line(length: 100%, stroke: (paint: color, thickness: thickness, dash: "dashed")),
)

/// 6. Gradient fade divider (fades in from left edge, solid in center, fades out on right)
#let fade-divider(
  color: slate-400,
  thickness: strokes.border,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
  line(
    length: 100%,
    stroke: thickness + gradient.linear(
      color.transparentize(100%),
      color,
      color.transparentize(100%),
    ),
  ),
)

/// 7. Icon / glyph divider with centered emblem
#let icon-divider(
  icon: "✦",
  color: slate-300,
  icon-color: floe-cyan,
  size: 8.5pt,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
)[
  #grid(
    columns: (1fr, auto, 1fr),
    gutter: 10pt,
    align: (horizon, horizon, horizon),
    line(length: 100%, stroke: strokes.hairline + color),
    text(font: fonts.sans, size: size, fill: icon-color)[#icon],
    line(length: 100%, stroke: strokes.hairline + color),
  )
]

/// 8. Brand gradient accent rule
#let gradient-divider(
  from-color: floe-cyan,
  to-color: floe-navy,
  thickness: 1.5pt,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  above: above,
  below: below,
  line(length: 100%, stroke: thickness + gradient.linear(from-color, to-color)),
)
