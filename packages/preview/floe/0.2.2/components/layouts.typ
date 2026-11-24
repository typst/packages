// ============================================================================
// FLOE DESIGN SYSTEM — LAYOUT COMPOSITES (components/layouts.typ)
// Layer 3: Bento Grids, Split Views, Tradeoff Canvases, Feature & Key-Value Grids
// All multi-column layouts use #equal-grid so row heights equalize natively!
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": card, badge, equal-grid

// ----------------------------------------------------------------------------
// 1. Split-View & Pro-Con Tradeoff Grids
// ----------------------------------------------------------------------------

#let _render-split-col(title, badge-label, badge-variant, body, inline-header: false) = block(
  fill: white,
  stroke: strokes.border + slate-200,
  radius: radii.md,
  inset: 9pt,
  width: 100%,
)[
  #set text(fill: slate-800)
  #if title != none or badge-label != none [
    #set par(justify: false, leading: 0.45em)
    #if not inline-header [
      #if badge-label != none [
        #block(width: 100%, above: 0pt, below: 0pt)[
          #badge(badge-label, variant: badge-variant)
        ]
      ]
      #if title != none [
        #block(width: 100%, above: if badge-label != none { 5.5pt } else { 0pt }, below: 0pt)[
          #text(
            font: fonts.sans,
            size: 9.2pt,
            weight: "bold",
            fill: floe-navy,
            top-edge: "cap-height",
            bottom-edge: "bounds",
          )[#title]
        ]
      ]
    ] else [
      #grid(
        columns: (1fr, auto),
        align: (horizon, horizon),
        if title != none [
          #text(font: fonts.sans, size: 9pt, weight: "bold", fill: floe-navy)[#title]
        ],
        if badge-label != none [
          #badge(badge-label, variant: badge-variant)
        ]
      )
    ]
    #v(5pt)
    #line(length: 100%, stroke: strokes.hairline + slate-200)
    #v(5pt)
  ]
  #body
]

/// Split Two-Column Layout (Theory vs Implementation, Primal vs Dual)
/// Guarantees equal height across both columns natively via #equal-grid.
#let split-view(
  left,
  right,
  fractions: (1fr, 1fr),
  gutter: 8pt,
  titles: (none, none),
  badges: (none, none),
  above: 8pt,
  below: 8pt,
) = equal-grid(
  columns: fractions,
  gutter: gutter,
  above: above,
  below: below,
  _render-split-col(titles.at(0), badges.at(0), "info", left),
  _render-split-col(titles.at(1), badges.at(1), "warning", right),
)

#let _render-pro-con-box(fill-c, stroke-c, badge-txt, badge-var, marker-char, marker-c, items) = block(
  fill: fill-c,
  stroke: strokes.border + stroke-c,
  radius: radii.sm,
  inset: 9pt,
  width: 100%,
)[
  #set text(fill: slate-800)
  #block(below: 6pt)[
    #badge(badge-txt, variant: badge-var)
  ]
  #list(
    marker: text(fill: marker-c, weight: "bold")[#marker-char],
    ..items
  )
]

/// Pros vs. Cons (Advantages vs Limitations) Tradeoff Canvas
/// Enforces equal height between the pros and cons panels natively via #equal-grid.
#let pro-con(
  pros: (),
  cons: (),
  title: "Architectural Tradeoffs",
  pro-label: "ADVANTAGES",
  con-label: "LIMITATIONS",
) = block(
  width: 100%,
  stroke: strokes.border + slate-300,
  radius: radii.md,
  fill: white,
  clip: true,
  above: 8pt,
  below: 8pt,
  breakable: false,
)[
  #if title != none [
    #block(
      width: 100%,
      fill: slate-200,
      stroke: (bottom: strokes.hairline + slate-300),
      inset: (x: 12pt, y: 7pt),
      above: 0pt,
      below: 0pt,
    )[
      #set par(justify: false)
      #text(font: fonts.sans, size: 9.5pt, weight: "bold", fill: floe-navy)[#title]
    ]
  ]
  #block(
    width: 100%,
    inset: 10pt,
    above: 0pt,
    below: 0pt,
  )[
    #equal-grid(
      columns: (1fr, 1fr),
      gutter: 8pt,
      above: 0pt,
      below: 0pt,
      _render-pro-con-box(rgb("#F0FDF4"), rgb("#BBF7D0"), pro-label, "success", "✓", rgb("#16A34A"), pros),
      _render-pro-con-box(rgb("#FEF2F2"), rgb("#FECDD3"), con-label, "danger", "✕", rgb("#DC2626"), cons),
    )
  ]
]

// ----------------------------------------------------------------------------
// 2. Bento Grid (Powered by #equal-grid for Native Row Height Equalization)
// ----------------------------------------------------------------------------

/// Individual Bento Box Cell (No height argument needed — parent grid stretches it!)
#let bento-cell(
  title: none,
  subtitle: none,
  tag: none,
  tag-variant: "dark",
  badge-label: none,
  badge-variant: "neutral",
  icon: none,
  inline-header: false,
  footer: none,
  fill: white,
  stroke: slate-200,
  radius: radii.md,
  inset: 9pt,
  body,
) = {
  let has-beans = (tag != none) or (badge-label != none) or (icon != none)
  block(
    width: 100%,
    fill: fill,
    stroke: strokes.border + stroke,
    radius: radius,
    inset: inset,
  )[
    #set text(fill: slate-800)
    #if title != none or subtitle != none or has-beans [
      #set par(justify: false, leading: 0.45em)
      #if not inline-header [
        #if has-beans [
          #block(width: 100%, above: 0pt, below: 0pt)[
            #grid(
              columns: (1fr, auto),
              gutter: 6pt,
              align: (top + left, top + right),
              if tag != none [
                #badge(tag, variant: tag-variant)
              ] else if icon != none [
                #box(
                  fill: slate-100,
                  inset: (x: 5pt, y: 3pt),
                  radius: radii.sm,
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
        #grid(
          columns: (auto, 1fr, auto),
          gutter: 6pt,
          align: (horizon, horizon, horizon),
          if icon != none [
            #box(fill: slate-100, inset: 4pt, radius: radii.sm)[#icon]
          ],
          [
            #if title != none [
              #text(font: fonts.sans, size: 9.5pt, weight: "bold", fill: floe-navy)[#title]
            ]
            #if subtitle != none [
              #v(1pt)
              #text(font: fonts.sans, size: 7.8pt, fill: slate-500)[#subtitle]
            ]
          ],
          if badge-label != none [
            #badge(badge-label, variant: badge-variant)
          ]
        )
      ]
      #v(5pt)
      #line(length: 100%, stroke: strokes.hairline + slate-200)
      #v(5pt)
    ]
    #body
    #metadata("floe-footer")
    #if footer != none [
      #v(5pt)
      #line(length: 100%, stroke: strokes.hairline + slate-200)
      #v(4pt)
      #text(font: fonts.sans, size: 7.8pt, fill: slate-500)[#footer]
    ]
  ]
}

/// Bento Grid (2-column, 3-column, or custom fractional layout)
/// All cells in the same row automatically stretch to equal height!
#let bento-grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  above: 8pt,
  below: 8pt,
  ..cells,
) = equal-grid(
  columns: columns,
  gutter: gutter,
  above: above,
  below: below,
  ..cells.pos(),
)

// ----------------------------------------------------------------------------
// 3. Feature, Key-Value & Duality Grids
// ----------------------------------------------------------------------------

/// Key-Value Parameter Definition Grid
#let key-value-grid(
  items: (),
  columns: (auto, 1fr),
  gutter: 8pt,
  zebra: true,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  stroke: strokes.border + slate-300,
  radius: radii.md,
  fill: white,
  clip: true,
  above: above,
  below: below,
  breakable: true,
)[
  #set par(justify: false)
  #table(
    columns: columns,
    stroke: (x, y) => (
      top: if y > 0 { strokes.hairline + slate-200 } else { none },
      left: if x > 0 { strokes.hairline + slate-200 } else { none },
    ),
    fill: (_, y) => if zebra and calc.even(y) { slate-100 } else { white },
    inset: (x: 10pt, y: 6.5pt),
    align: (left + horizon, left + horizon),
    ..items.map(it => (
      text(font: fonts.sans, size: 8.6pt, weight: "bold", fill: floe-navy)[#it.at(0)],
      text(font: fonts.mono, size: 8.3pt, fill: slate-800)[#it.at(1)],
    )).flatten()
  )
]

/// Feature Cards Grid (Equal-height rows guaranteed via #equal-grid)
#let feature-grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 8pt,
  above: 8pt,
  below: 8pt,
  ..items,
) = equal-grid(
  columns: columns,
  gutter: gutter,
  above: above,
  below: below,
  ..items.pos().map(it => block(
    fill: white,
    stroke: strokes.border + slate-300,
    radius: radii.md,
    inset: 9pt,
    width: 100%,
  )[
    #set par(justify: false, leading: 0.45em)
    #if "icon" in it [
      #block(width: 100%, above: 0pt, below: 0pt)[
        #box(fill: slate-100, stroke: strokes.hairline + slate-300, inset: (x: 5pt, y: 3pt), radius: radii.sm, baseline: 0pt)[#it.icon]
      ]
    ]
    #if "title" in it [
      #block(width: 100%, above: if "icon" in it { 5.5pt } else { 0pt }, below: 0pt)[
        #text(font: fonts.sans, size: 9.2pt, weight: "bold", fill: floe-navy, top-edge: "cap-height", bottom-edge: "bounds")[#it.title]
      ]
    ]
    #if "desc" in it [
      #block(width: 100%, above: 4pt, below: 0pt)[
        #set text(font: fonts.sans, size: 8pt, fill: slate-600)
        #it.desc
      ]
    ]
  ])
)

/// Duality & Mathematical Analogy Grid
/// Mirrored comparative layout mapping dual concepts side-by-side with color badges.
#let duality-grid(
  left-title: "Primal Space",
  right-title: "Dual Space",
  left-badge: "PRIMAL",
  right-badge: "DUAL",
  inline-header: false,
  rows: (),
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  stroke: strokes.border + slate-300,
  radius: radii.md,
  fill: white,
  clip: true,
  above: above,
  below: below,
  breakable: false,
)[
  #set par(justify: false, leading: 0.45em)
  #block(
    width: 100%,
    fill: slate-200,
    inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
    stroke: (bottom: strokes.hairline + slate-300),
    above: 0pt,
    below: 0pt,
  )[
    #grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      if not inline-header [
        #block(width: 100%, above: 0pt, below: 0pt)[#badge(left-badge, variant: "info")]
        #block(width: 100%, above: 5.5pt, below: 0pt)[
          #text(font: fonts.sans, size: 9pt, weight: "bold", fill: floe-navy, top-edge: "cap-height", bottom-edge: "bounds")[#left-title]
        ]
      ] else [
        #badge(left-badge, variant: "info") #h(6pt)
        #text(font: fonts.sans, size: 8.8pt, weight: "bold", fill: floe-navy)[#left-title]
      ],
      if not inline-header [
        #block(width: 100%, above: 0pt, below: 0pt)[#badge(right-badge, variant: "purple")]
        #block(width: 100%, above: 5.5pt, below: 0pt)[
          #text(font: fonts.sans, size: 9pt, weight: "bold", fill: floe-navy, top-edge: "cap-height", bottom-edge: "bounds")[#right-title]
        ]
      ] else [
        #badge(right-badge, variant: "purple") #h(6pt)
        #text(font: fonts.sans, size: 8.8pt, weight: "bold", fill: floe-navy)[#right-title]
      ],
    )
  ]
  #for (idx, r) in rows.enumerate() [
    #block(
      width: 100%,
      fill: if calc.even(idx) { white } else { slate-100 },
      inset: (x: 10pt, y: 6.5pt),
      stroke: if idx > 0 { (top: strokes.hairline + slate-200) } else { none },
    )[
      #grid(
        columns: (1fr, 1fr),
        gutter: 12pt,
        align: horizon,
        [
          #if r.len() >= 2 [
            #text(font: fonts.sans, size: 8.2pt, weight: "bold", fill: slate-700)[#r.at(0):] #h(4pt)
            #r.at(1)
          ]
        ],
        [
          #if r.len() >= 4 [
            #text(font: fonts.sans, size: 8.2pt, weight: "bold", fill: slate-700)[#r.at(2):] #h(4pt)
            #r.at(3)
          ]
        ],
      )
    ]
  ]
]
