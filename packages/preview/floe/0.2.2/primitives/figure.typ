// ============================================================================
// FLOE DESIGN SYSTEM — FIGURE & MEDIA PRIMITIVES (primitives/figure.typ)
// Layer 1: Framed Visual Containers for Images, Plots, Diagrams & Grids
// ============================================================================
#import "../core/lib.typ": *
#import "badge.typ": badge
#import "grid.typ": equal-grid

/// Framed Visual Container (Image / Plot / Diagram Card)
/// Modes:
///   - Pure framed box: `#figure-card[ ... ]` (when title & footer are omitted)
///   - Titled & captioned media card: `#figure-card(title: "...", footer: "...")[ ... ]`
#let figure-card(
  title: none,
  subtitle: none,
  tag: none,
  tag-variant: "dark",
  badge-label: none,
  badge-variant: "neutral",
  inline-header: false,
  caption: none,
  footer: none,
  fill: white,
  canvas-fill: rgb("#F8FAFC"),
  border-color: slate-300,
  radius: radii.md,
  inset: (x: 12pt, y: 10pt),
  img-width: 90%,
  above: 8pt,
  below: 8pt,
  body,
) = {
  let resolved-footer = if footer != none { footer } else { caption }
  let has-beans = (tag != none) or (badge-label != none)
  let has-header = title != none or subtitle != none or has-beans

  block(
    width: 100%,
    fill: canvas-fill,
    stroke: strokes.border + border-color,
    radius: radius,
    clip: true,
    above: above,
    below: below,
    breakable: false,
  )[
    #if has-header [
      #block(
        width: 100%,
        fill: fill,
        stroke: (bottom: strokes.hairline + slate-200),
        inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
        above: 0pt,
        below: 0pt,
      )[
        #set align(left + top)
        #set par(justify: false, leading: 0.45em)
        #if not inline-header [
          // Row 1: Corner-anchored Left Bean & Right Bean
          #if has-beans [
            #block(width: 100%, above: 0pt, below: 0pt)[
              #grid(
                columns: (1fr, auto),
                gutter: 8pt,
                align: (top + left, top + right),
                if tag != none [
                  #badge(tag, variant: tag-variant)
                ] else [],
                if badge-label != none [
                  #badge(badge-label, variant: badge-variant)
                ] else [],
              )
            ]
          ]
          // Row 2: Full-width Title below beans
          #if title != none [
            #block(width: 100%, above: if has-beans { 5.5pt } else { 0pt }, below: 0pt)[
              #text(
                font: fonts.sans,
                size: 9.5pt,
                weight: "bold",
                fill: floe-navy,
                top-edge: "cap-height",
                bottom-edge: "bounds",
              )[#title]
            ]
          ]
          // Row 3: Full-width Subtitle / Description below title
          #if subtitle != none [
            #block(width: 100%, above: if title != none or has-beans { 3.5pt } else { 0pt }, below: 0pt)[
              #text(
                font: fonts.sans,
                size: 7.8pt,
                fill: slate-500,
                top-edge: "cap-height",
                bottom-edge: "bounds",
              )[#subtitle]
            ]
          ]
        ] else [
          // Explicit Inline Header Override
          #grid(
            columns: (auto, 1fr, auto),
            gutter: 8pt,
            align: (horizon, horizon, horizon),
            if tag != none [
              #badge(tag, variant: tag-variant)
            ],
            [
              #if title != none [
                #text(font: fonts.sans, size: 9.2pt, weight: "bold", fill: floe-navy)[#title]
              ]
              #if subtitle != none [
                #block(above: 3pt, below: 0pt, text(font: fonts.sans, size: 7.8pt, fill: slate-500)[#subtitle])
              ]
            ],
            if badge-label != none [
              #badge(badge-label, variant: badge-variant)
            ]
          )
        ]
      ]
    ]
    #metadata("floe-stretch-center")
    #block(
      width: 100%,
      inset: inset,
      above: 0pt,
      below: 0pt,
      align(center + horizon)[
        #if type(body) == str {
          image(body, width: img-width)
        } else {
          body
        }
      ]
    )
    #metadata("floe-stretch-center")
    #if resolved-footer != none [
      #block(
        width: 100%,
        fill: slate-100,
        stroke: (top: strokes.hairline + slate-200),
        inset: (x: 12pt, y: 6.5pt),
        above: 0pt,
        below: 0pt,
      )[
        #set align(left + top)
        #set text(font: fonts.sans, size: 8pt, fill: slate-700)
        #set par(justify: false)
        #resolved-footer
      ]
    ]
  ]
}

/// Equal-Height Multi-Panel Figure / Media Grid
/// Arranges arbitrary visual cards, plots, diagrams, or images in rows of equal height,
/// with optional shared master title and footer caption.
#let figure-grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  title: none,
  badge-label: none,
  footer: none,
  caption: none,
  above: 8pt,
  below: 8pt,
  ..items,
) = {
  let resolved-footer = if footer != none { footer } else { caption }
  if title == none and resolved-footer == none {
    equal-grid(
      columns: columns,
      gutter: gutter,
      above: above,
      below: below,
      ..items.pos(),
    )
  } else {
    figure-card(
      title: title,
      badge-label: badge-label,
      footer: resolved-footer,
      canvas-fill: white,
      inset: 10pt,
      above: above,
      below: below,
    )[
      #equal-grid(
        columns: columns,
        gutter: gutter,
        above: 0pt,
        below: 0pt,
        ..items.pos(),
      )
    ]
  }
}
