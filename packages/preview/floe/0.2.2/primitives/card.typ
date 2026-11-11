// ============================================================================
// FLOE DESIGN SYSTEM — SHADCN-INSPIRED CARD & ALERT PRIMITIVES (primitives/card.typ)
// Modern UI Component System: Header/Content/Footer, Subtle Borders, Zero Left-Bar Monoculture
// ============================================================================
#import "../core/lib.typ": *
#import "badge.typ": badge

/// Modern Shadcn-Style Card Container
/// Features: Header with title & description, optional top-right badge/icon,
/// comfortable content padding, hairline dividers, and optional footer.
#let card(
  title: none,
  description: none,
  tag: none,
  tag-variant: "dark",
  badge-label: none,
  badge-variant: "neutral",
  icon: none,
  inline-header: false,
  footer: none,
  fill: white,
  border-color: slate-200,
  radius: radii.md,
  inset: 12pt,
  above: 8pt,
  below: 8pt,
  breakable: true,
  body,
) = {
  let has-beans = (tag != none) or (badge-label != none) or (icon != none)
  block(
    width: 100%,
    fill: fill,
    stroke: strokes.border + border-color,
    radius: radius,
    clip: true,
    above: above,
    below: below,
    breakable: breakable,
  )[
    // Card Header
    #if title != none or description != none or has-beans [
      #block(
        width: 100%,
        stroke: (bottom: strokes.hairline + slate-200),
        inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
        above: 0pt,
        below: 0pt,
      )[
        #set par(justify: false, leading: 0.45em)
        #if not inline-header [
          // Row 1: Corner-anchored Left Bean / Icon & Right Bean
          #if has-beans [
            #block(width: 100%, above: 0pt, below: 0pt)[
              #grid(
                columns: (1fr, auto),
                gutter: 8pt,
                align: (top + left, top + right),
                if tag != none [
                  #badge(tag, variant: tag-variant)
                ] else if icon != none [
                  #box(
                    fill: slate-100,
                    radius: radii.sm,
                    inset: (x: 5pt, y: 3pt),
                    baseline: 0pt,
                    text(size: 8.5pt, top-edge: "cap-height", bottom-edge: "bounds")[#icon]
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
            #block(width: 100%, above: if has-beans { 5.5pt } else { 0pt }, below: 0pt)[
              #text(
                font: fonts.sans,
                size: 10pt,
                weight: "bold",
                fill: slate-900,
                top-edge: "cap-height",
                bottom-edge: "bounds",
              )[#title]
            ]
          ]
          // Row 3: Full-width Description
          #if description != none [
            #block(width: 100%, above: if title != none or has-beans { 3.5pt } else { 0pt }, below: 0pt)[
              #text(
                font: fonts.sans,
                size: 8pt,
                fill: slate-500,
                top-edge: "cap-height",
                bottom-edge: "bounds",
              )[#description]
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
            ] else if icon != none [
              #box(
                fill: slate-100,
                radius: radii.sm,
                inset: 4pt,
                align(center + horizon)[#icon]
              )
            ],
            [
              #if title != none [
                #block(text(font: fonts.sans, size: 10pt, weight: "bold", fill: slate-900)[#title])
              ]
              #if description != none [
                #block(above: 3pt, below: 0pt, text(font: fonts.sans, size: text-scale.xs, fill: slate-500)[#description])
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
      inset: (x: inset, top: if title != none or has-beans { 9pt } else { inset }, bottom: if footer != none { 9pt } else { inset }),
      above: 0pt,
      below: 0pt,
    )[
      #set text(fill: slate-800)
      #body
    ]
    #metadata("floe-footer")
    #if footer != none [
      #block(
        width: 100%,
        fill: slate-100,
        stroke: (top: strokes.hairline + slate-200),
        inset: (x: inset, y: 7pt),
        above: 0pt,
        below: 0pt,
      )[
        #set text(font: fonts.sans, size: text-scale.xs, fill: slate-600)
        #footer
      ]
    ]
  ]
}

/// Modern Shadcn-Style Alert Callout
/// Features: Full subtle tinted border, white card background with icon chip,
/// bold title on top, and full-width body underneath with NO thick colored left bar.
#let alert(
  variant: "info",
  title: none,
  icon: auto,
  style: "filled",
  radius: radii.md,
  breakable: false,
  above: 8pt,
  below: 8pt,
  body,
) = {
  let v-conf = (
    "info": (
      bg: rgb("#F0F9FF"),
      border: rgb("#BAE6FD"),
      fg: rgb("#0284C7"),
      title-fg: rgb("#0C4A6E"),
      icon-char: "ℹ",
    ),
    "success": (
      bg: rgb("#F0FDF4"),
      border: rgb("#BBF7D0"),
      fg: rgb("#16A34A"),
      title-fg: rgb("#14532D"),
      icon-char: "✓",
    ),
    "warning": (
      bg: rgb("#FFFBEB"),
      border: rgb("#FDE68A"),
      fg: rgb("#D97706"),
      title-fg: rgb("#78350F"),
      icon-char: "⚠",
    ),
    "danger": (
      bg: rgb("#FEF2F2"),
      border: rgb("#FECDD3"),
      fg: rgb("#DC2626"),
      title-fg: rgb("#881337"),
      icon-char: "✕",
    ),
    "tip": (
      bg: rgb("#F5F3FF"),
      border: rgb("#DDD6FE"),
      fg: rgb("#7C3AED"),
      title-fg: rgb("#4C1D95"),
      icon-char: "✦",
    ),
    "neutral": (
      bg: slate-50,
      border: slate-200,
      fg: slate-600,
      title-fg: slate-800,
      icon-char: "•",
    ),
  )

  let conf = v-conf.at(variant, default: v-conf.info)
  let resolved-fill = if style == "filled" { conf.bg } else { white }

  let resolved-icon = if icon != auto {
    icon
  } else {
    box(
      width: 15pt,
      height: 15pt,
      fill: conf.fg.lighten(85%),
      stroke: strokes.hairline + conf.border,
      radius: radii.full,
      align(center + horizon)[
        #text(font: fonts.sans, size: 7.5pt, weight: "bold", fill: conf.fg)[#conf.icon-char]
      ]
    )
  }

  block(
    width: 100%,
    fill: resolved-fill,
    stroke: strokes.border + conf.border,
    radius: radius,
    inset: (x: 11pt, y: 8.5pt),
    above: above,
    below: below,
    breakable: breakable,
  )[
    #if title != none [
      #block(below: 4pt)[
        #set par(justify: false)
        #grid(
          columns: (auto, 1fr),
          gutter: 7pt,
          align: (horizon, horizon),
          resolved-icon,
          text(font: fonts.sans, size: 9pt, weight: "bold", fill: conf.title-fg)[#title],
        )
      ]
    ] else [
      #resolved-icon
      #h(6pt)
    ]
    #block(width: 100%)[
      #set par(justify: false)
      #set text(fill: slate-800, size: text-scale.base)
      #body
    ]
  ]
}
