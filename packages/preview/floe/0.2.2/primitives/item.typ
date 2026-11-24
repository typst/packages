// ============================================================================
// FLOE DESIGN SYSTEM — ITEM CARD & GRID PRIMITIVES (primitives/item.typ)
// Atomic Building Blocks: Prominent Top Bean & Title with Full-Width Unpadded Body
// ============================================================================
#import "../core/lib.typ": *
#import "badge.typ": badge
#import "grid.typ": equal-grid

/// Individual Item Card (Corner-anchored Top Bean, Stacked Title, Full-Width Body, Optional Footer)
#let item-card(
  label: none,
  badge-label: none,
  badge-variant: "neutral",
  title: none,
  inline-header: false,
  footer: none,
  color: floe-navy,
  fill: slate-100,
  stroke: slate-300,
  radius: radii.sm,
  inset: 8pt,
  body,
) = {
  let has-beans = (label != none) or (badge-label != none)
  block(
    width: 100%,
    fill: fill,
    stroke: strokes.hairline + stroke,
    radius: radius,
    inset: inset,
  )[
    #set par(justify: false, leading: 0.45em)
    #if not inline-header [
      // Row 1: Corner-anchored Bean Row
      #if has-beans [
        #block(width: 100%, above: 0pt, below: 0pt)[
          #grid(
            columns: (1fr, auto),
            gutter: 6pt,
            align: (top + left, top + right),
            if label != none [
              #badge(
                label,
                fill: color.lighten(86%),
                text-color: color,
                stroke: strokes.hairline + color.lighten(40%),
              )
            ] else [],
            if badge-label != none [
              #badge(badge-label, variant: badge-variant)
            ] else [],
          )
        ]
      ]
      // Row 2: Full-width Title
      #if title != none [
        #block(width: 100%, above: if has-beans { 5pt } else { 0pt }, below: 0pt)[
          #text(
            font: fonts.sans,
            size: 8.8pt,
            weight: "bold",
            fill: floe-navy,
            top-edge: "cap-height",
            bottom-edge: "bounds",
          )[#title]
        ]
      ]
    ] else [
      #if has-beans or title != none [
        #block(width: 100%, above: 0pt, below: 0pt)[
          #grid(
            columns: (auto, 1fr, auto),
            gutter: 6pt,
            align: (horizon, horizon, horizon),
            if label != none [
              #badge(
                label,
                fill: color.lighten(86%),
                text-color: color,
                stroke: strokes.hairline + color.lighten(40%),
              )
            ],
            if title != none [
              #text(font: fonts.sans, size: 8.8pt, weight: "bold", fill: floe-navy)[#title]
            ],
            if badge-label != none [
              #badge(badge-label, variant: badge-variant)
            ],
          )
        ]
      ]
    ]
    // Full-width Body
    #block(width: 100%, above: if has-beans or title != none { 4.5pt } else { 0pt }, below: 0pt)[
      #set text(size: text-scale.base, fill: slate-700)
      #body
    ]
    #metadata("floe-footer")
    #if footer != none [
      #v(4pt)
      #line(length: 100%, stroke: strokes.hairline + slate-300)
      #v(3pt)
      #text(font: fonts.sans, size: 7.5pt, fill: slate-600)[#footer]
    ]
  ]
}

/// Equal-Height Grid Container for Any Items (item-card, card, figure-card, blocks)
/// Automatically equalizes heights across every row natively.
#let item-grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  above: 8pt,
  below: 8pt,
  ..items,
) = equal-grid(
  columns: columns,
  gutter: gutter,
  above: above,
  below: below,
  ..items.pos(),
)
