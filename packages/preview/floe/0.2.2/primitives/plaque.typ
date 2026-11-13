// ============================================================================
// FLOE DESIGN SYSTEM — MASTER PLAQUE PRIMITIVE (primitives/plaque.typ)
// Unified Container for Theorems, Definitions, Lemmas, Algorithms & Axioms
// Features: Flexible Header, title-below for long titles, takeaway footer
// ============================================================================
#import "../core/lib.typ": *
#import "badge.typ": badge

/// Master Generalized Plaque Primitive
/// Unifies theorems, definitions, lemmas, corollaries, and algorithms into a single atomic primitive.
#let plaque(
  tag: none,
  num: none,
  title: none,
  subtitle: none,
  badge-label: none,
  badge-variant: "outline",
  accent: floe-navy,
  header-fill: auto,
  title-below: true,
  inline-header: false,
  footer: none,
  border-color: auto,
  radius: radii.md,
  above: 8pt,
  below: 8pt,
  breakable: true,
  body,
) = {
  let use-inline = inline-header or (title-below == false)
  let has-beans = (tag != none) or (badge-label != none)
  let resolved-border = if border-color != auto {
    border-color
  } else if header-fill == floe-navy or header-fill == slate-800 {
    slate-300
  } else {
    accent.lighten(65%)
  }

  let resolved-header-fill = if header-fill != auto {
    header-fill
  } else {
    slate-100
  }

  let is-dark-header = (
    header-fill == floe-navy or
    header-fill == slate-800 or
    header-fill == slate-900 or
    header-fill == rgb("#0B1E36")
  )

  let tag-text-color = if is-dark-header { white } else { accent }
  let title-text-color = if is-dark-header { white } else { floe-navy }

  block(
    width: 100%,
    breakable: breakable,
    stroke: strokes.border + resolved-border,
    radius: radius,
    fill: white,
    clip: true,
    above: above,
    below: below,
  )[
    // Header Bar (if tag, title, subtitle, or badge present)
    #if tag != none or title != none or subtitle != none or badge-label != none [
      #block(
        width: 100%,
        fill: resolved-header-fill,
        stroke: (bottom: strokes.hairline + resolved-border),
        inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
        above: 0pt,
        below: 0pt,
      )[
        #set par(justify: false, leading: 0.45em)
        #if not use-inline [
          // Row 1: Corner-anchored Left Bean & Right Bean
          #if has-beans [
            #block(width: 100%, above: 0pt, below: 0pt)[
              #grid(
                columns: (1fr, auto),
                gutter: 8pt,
                align: (top + left, top + right),
                if tag != none [
                  #badge([#upper(tag)#if num != none [ #num]], fill: accent, text-color: white)
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
                size: 9.6pt,
                weight: "bold",
                fill: title-text-color,
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
                size: 8pt,
                fill: if is-dark-header { slate-300 } else { slate-500 },
                top-edge: "cap-height",
                bottom-edge: "bounds",
              )[#subtitle]
            ]
          ]
        ] else [
          // Explicit Inline Header Override: Tag, Title, and Badge on the same line
          #grid(
            columns: (auto, 1fr, auto),
            gutter: 8pt,
            align: (horizon, horizon, horizon),
            if tag != none [
              #badge([#upper(tag)#if num != none [ #num]], fill: accent, text-color: white)
            ],
            [
              #if title != none [
                #text(font: fonts.sans, size: 9.2pt, weight: "bold", fill: title-text-color)[#title]
              ]
              #if subtitle != none [
                #h(6pt)
                #text(
                  font: fonts.sans,
                  size: 8pt,
                  fill: if is-dark-header { slate-300 } else { slate-500 },
                )[#subtitle]
              ]
            ],
            if badge-label != none [
              #badge(badge-label, variant: badge-variant)
            ]
          )
        ]
      ]
    ]
    #block(
      width: 100%,
      inset: (x: 12pt, top: 10pt, bottom: 10.5pt),
      above: 0pt,
      below: 0pt,
    )[
      #set text(fill: slate-800)
      #show math.equation.where(block: true): it => block(above: 0.55em, below: 0.45em, it)
      #set par(justify: true)
      #body
    ]
    #metadata("floe-footer")
    #if footer != none [
      #block(
        width: 100%,
        fill: rgb("#FFFBEB"),
        stroke: (top: strokes.hairline + if is-dark-header { rgb("#FDE68A") } else { resolved-border }),
        inset: (x: 12pt, y: 7.5pt),
        above: 0pt,
        below: 0pt,
      )[
        #set text(font: fonts.sans, size: text-scale.xs, fill: rgb("#92400E"))
        #footer
      ]
    ]
  ]
}
