// ============================================================================
// FLOE DESIGN SYSTEM — HEROES & SECTION HEADERS (components/hero.typ)
// Complete Suite of 12 Cover Heroes, Chapter Openers, Split/Stat Heroes & Headers
// All headers follow Floe's corner-anchored bean + stacked title geometry.
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": badge, equal-grid

/// 1. Cover Hero Banner (Full-Width Carded Book / Report / Monograph Masthead)
#let cover-hero(
  title: "",
  subtitle: none,
  eyebrow: "FLOE ACADEMIC SERIES",
  badge-label: none,
  meta: (),
  fill: floe-navy,
  accent: floe-cyan,
  above: 8pt,
  below: 12pt,
) = block(
  width: 100%,
  fill: fill,
  radius: radii.lg,
  inset: 18pt,
  above: above,
  below: below,
  breakable: false,
)[
  #set par(justify: false, leading: 0.45em)
  // Row 1: Corner-anchored Eyebrow & Right Badge
  #if eyebrow != none or badge-label != none [
    #block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 8pt,
        align: (top + left, top + right),
        if eyebrow != none [
          #badge(
            upper(eyebrow),
            fill: accent.transparentize(82%),
            text-color: accent,
            stroke: strokes.hairline + accent.transparentize(40%),
          )
        ] else [],
        if badge-label != none [
          #badge(badge-label, fill: white.transparentize(88%), text-color: white)
        ] else [],
      )
    ]
  ]
  // Row 2: Display Title
  #block(width: 100%, above: if eyebrow != none or badge-label != none { 10pt } else { 0pt }, below: 0pt)[
    #text(
      font: fonts.sans,
      size: 20pt,
      weight: "bold",
      fill: white,
      top-edge: "cap-height",
      bottom-edge: "bounds",
    )[#title]
  ]
  // Row 3: Accent Rule & Subtitle
  #block(width: 100%, above: 8pt, below: 0pt)[
    #line(length: 42%, stroke: 2.2pt + accent)
  ]
  #if subtitle != none [
    #block(width: 100%, above: 7pt, below: 0pt)[
      #text(font: fonts.sans, size: 10.5pt, fill: slate-200)[#subtitle]
    ]
  ]
  // Row 4: Metadata Strip
  #if meta.len() > 0 [
    #block(width: 100%, above: 12pt, below: 0pt)[
      #line(length: 100%, stroke: strokes.hairline + white.transparentize(80%))
      #v(7pt)
      #grid(
        columns: (1fr,) * calc.min(meta.len(), 4),
        gutter: 10pt,
        ..meta.map(m => [
          #text(font: fonts.sans, size: 7pt, weight: "bold", fill: accent, tracking: 0.06em)[#upper(m.at(0))]
          #block(above: 3pt, below: 0pt, text(font: fonts.sans, size: 8.5pt, fill: slate-100)[#m.at(1)])
        ])
      )
    ]
  ]
]

/// 2. Classic Academic Chapter Header Opener
#let chapter-header(
  num: 1,
  title: "",
  subtitle: none,
  eyebrow: "CHAPTER",
  badge-label: none,
  badge-variant: "info",
  meta: (),
  slides-ref: "",
  reader-ref: "",
  book-ref: "",
  exam-focus: "",
  exam-ref: "",
  teardown-ref: "",
  pagebreak-before: true,
  ..sink,
) = {
  if pagebreak-before {
    pagebreak(weak: true)
  }
  if type(num) == int {
    counter(heading).update((num, 0))
  }
  let has-legacy-refs = (
    slides-ref != "" or reader-ref != "" or book-ref != "" or
    exam-focus != "" or exam-ref != "" or teardown-ref != ""
  )
  block(width: 100%, below: 1.3em)[
    #set par(justify: false, leading: 0.45em)
    #block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 8pt,
        align: (top + left, top + right),
        badge(
          if eyebrow != "" [#upper(eyebrow) #num] else [CHAPTER #num],
          fill: floe-cyan.lighten(86%),
          text-color: floe-navy,
          stroke: strokes.hairline + floe-cyan.lighten(40%),
        ),
        if badge-label != none [
          #badge(badge-label, variant: badge-variant)
        ] else [],
      )
    ]
    #block(width: 100%, above: 6.5pt, below: 0pt)[
      #heading(level: 1, numbering: none)[#num. #title]
    ]
    #if subtitle != none [
      #block(width: 100%, above: 4pt, below: 0pt)[
        #text(font: fonts.sans, size: 10pt, fill: slate-600)[#subtitle]
      ]
    ]
    #block(width: 100%, above: 6pt, below: 0pt)[
      #line(length: 100%, stroke: 1.5pt + floe-cyan)
    ]
    #if meta.len() > 0 or has-legacy-refs [
      #block(
        width: 100%,
        fill: slate-100,
        stroke: strokes.border + slate-300,
        radius: radii.sm,
        inset: (x: 10pt, y: 6.5pt),
        above: 6pt,
        below: 0pt,
      )[
        #set text(font: fonts.sans, size: 8pt, fill: slate-800)
        #if meta.len() > 0 [
          #meta.map(p => [*#p.at(0):* #h(3pt) #p.at(1)]).join([ #h(8pt) • #h(8pt) ])
        ] else [
          #if slides-ref != "" [*Module:* #h(3pt) #slides-ref]
          #if book-ref != "" [ #h(8pt) | #h(8pt) #book-ref ]
          #if reader-ref != "" [ #h(8pt) | #h(8pt) #reader-ref ]
          #if exam-focus != "" [ #h(8pt) | #h(8pt) *Focus:* #exam-focus ]
          #if exam-ref != "" [ #h(8pt) | #h(8pt) *Ref:* #exam-ref ]
          #if teardown-ref != "" [ #h(8pt) | #h(8pt) *Scope:* #teardown-ref ]
        ]
      ]
    ]
  ]
}

/// 3. Editorial Magazine / Module Header with Learning Outcomes Strip
#let editorial-header(
  num: none,
  eyebrow: "MODULE OVERVIEW",
  title: "",
  subtitle: none,
  read-time: none,
  goals: (),
  above: 8pt,
  below: 12pt,
) = block(
  width: 100%,
  fill: white,
  stroke: strokes.border + slate-300,
  radius: radii.md,
  clip: true,
  above: above,
  below: below,
)[
  #set par(justify: false, leading: 0.45em)
  #block(
    width: 100%,
    inset: (x: 11pt, top: 10pt, bottom: 9pt),
    above: 0pt,
    below: 0pt,
  )[
    #block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 8pt,
        align: (top + left, top + right),
        badge(
          [#if num != none [MODULE #num • ]#upper(eyebrow)],
          fill: floe-cyan.lighten(85%),
          text-color: floe-navy,
          stroke: strokes.hairline + floe-cyan.lighten(40%),
        ),
        if read-time != none [
          #badge(read-time, variant: "neutral")
        ] else [],
      )
    ]
    #block(width: 100%, above: 6.5pt, below: 0pt)[
      #text(
        font: fonts.sans,
        size: 14pt,
        weight: "bold",
        fill: floe-navy,
        top-edge: "cap-height",
        bottom-edge: "bounds",
      )[#title]
    ]
    #if subtitle != none [
      #block(width: 100%, above: 4pt, below: 0pt)[
        #text(font: fonts.sans, size: 9.2pt, fill: slate-600)[#subtitle]
      ]
    ]
  ]
  #if goals.len() > 0 [
    #block(
      width: 100%,
      fill: slate-100,
      stroke: (top: strokes.hairline + slate-300),
      inset: (x: 11pt, y: 7.5pt),
      above: 0pt,
      below: 0pt,
    )[
      #grid(
        columns: (auto, 1fr),
        gutter: 8pt,
        align: (top, top),
        text(font: fonts.sans, size: 7.5pt, weight: "bold", fill: floe-navy)[LEARNING GOALS:],
        [
          #set text(font: fonts.sans, size: 8pt, fill: slate-700)
          #goals.join([ #h(6pt) • #h(6pt) ])
        ]
      )
    ]
  ]
]

/// 4. Dark Navy Banner Header (In-Page Major Part / Topic Transition Card)
#let banner-header(
  title: "",
  subtitle: none,
  tag: "PART OPENER",
  badge-label: none,
  accent: floe-navy,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  fill: accent,
  radius: radii.md,
  inset: (x: 11pt, top: 10pt, bottom: 10pt),
  above: above,
  below: below,
  breakable: false,
)[
  #set par(justify: false, leading: 0.45em)
  #if tag != none or badge-label != none [
    #block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 8pt,
        align: (top + left, top + right),
        if tag != none [
          #badge(
            upper(tag),
            fill: floe-cyan.transparentize(80%),
            text-color: floe-cyan,
            stroke: strokes.hairline + floe-cyan.transparentize(40%),
          )
        ] else [],
        if badge-label != none [
          #badge(badge-label, fill: white.transparentize(86%), text-color: white)
        ] else [],
      )
    ]
  ]
  #block(width: 100%, above: if tag != none or badge-label != none { 6pt } else { 0pt }, below: 0pt)[
    #text(
      font: fonts.sans,
      size: 13pt,
      weight: "bold",
      fill: white,
      top-edge: "cap-height",
      bottom-edge: "bounds",
    )[#title]
  ]
  #if subtitle != none [
    #block(width: 100%, above: 4pt, below: 0pt)[
      #text(font: fonts.sans, size: 8.8pt, fill: slate-300)[#subtitle]
    ]
  ]
]

/// 5. Split Hero Card (2-Column Keynote-Style Narrative + Visual Showcase Hero)
#let split-hero(
  title: "",
  subtitle: none,
  tag: "CORE ARCHITECTURE",
  badge-label: none,
  highlights: (),
  visual: none,
  fractions: (1.25fr, 1fr),
  above: 8pt,
  below: 8pt,
) = equal-grid(
  columns: fractions,
  gutter: 8pt,
  above: above,
  below: below,
  block(
    width: 100%,
    fill: floe-navy,
    radius: radii.md,
    inset: 11pt,
  )[
    #set par(justify: false, leading: 0.45em)
    #if tag != none or badge-label != none [
      #block(width: 100%, above: 0pt, below: 0pt)[
        #grid(
          columns: (1fr, auto),
          gutter: 6pt,
          align: (top + left, top + right),
          if tag != none [
            #badge(
              upper(tag),
              fill: floe-cyan.transparentize(80%),
              text-color: floe-cyan,
              stroke: strokes.hairline + floe-cyan.transparentize(40%),
            )
          ] else [],
          if badge-label != none [
            #badge(badge-label, fill: white.transparentize(86%), text-color: white)
          ] else [],
        )
      ]
    ]
    #block(width: 100%, above: 6pt, below: 0pt)[
      #text(
        font: fonts.sans,
        size: 12.5pt,
        weight: "bold",
        fill: white,
        top-edge: "cap-height",
        bottom-edge: "bounds",
      )[#title]
    ]
    #if subtitle != none [
      #block(width: 100%, above: 4pt, below: 0pt)[
        #text(font: fonts.sans, size: 8.4pt, fill: slate-300)[#subtitle]
      ]
    ]
    #if highlights.len() > 0 [
      #block(width: 100%, above: 7pt, below: 0pt)[
        #set text(font: fonts.sans, size: 8pt, fill: slate-100)
        #list(
          marker: text(fill: floe-cyan, weight: "bold")[▸],
          ..highlights
        )
      ]
    ]
  ],
  block(
    width: 100%,
    fill: slate-100,
    stroke: strokes.border + slate-300,
    radius: radii.md,
    inset: 10pt,
  )[
    #set text(fill: slate-800)
    #metadata("floe-stretch-center")
    #align(center + horizon)[#visual]
    #metadata("floe-stretch-center")
  ],
)

/// 6. Stat / Specification Hero (Header Banner + Equal-Height Parameter Strip)
#let stat-hero(
  title: "",
  subtitle: none,
  tag: "SYSTEM SPECIFICATION",
  badge-label: none,
  stats: (),
  palette: brand-term-palette,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  fill: white,
  stroke: strokes.border + slate-300,
  radius: radii.md,
  clip: true,
  above: above,
  below: below,
  breakable: false,
)[
  #set par(justify: false, leading: 0.45em)
  // Top Dark Header
  #block(
    width: 100%,
    fill: floe-navy,
    inset: (x: 10pt, top: 9pt, bottom: 9pt),
    above: 0pt,
    below: 0pt,
  )[
    #if tag != none or badge-label != none [
      #block(width: 100%, above: 0pt, below: 0pt)[
        #grid(
          columns: (1fr, auto),
          gutter: 8pt,
          align: (top + left, top + right),
          if tag != none [
            #badge(
              tag,
              fill: floe-cyan.transparentize(80%),
              text-color: floe-cyan,
              stroke: strokes.hairline + floe-cyan.transparentize(40%),
              baseline: 0pt,
            )
          ] else [],
          if badge-label != none [
            #badge(badge-label, fill: white.transparentize(86%), text-color: white, baseline: 0pt)
          ] else [],
        )
      ]
    ]
    #block(width: 100%, above: 5.5pt, below: 0pt)[
      #text(
        font: fonts.sans,
        size: 11.5pt,
        weight: "bold",
        fill: white,
        top-edge: "cap-height",
        bottom-edge: "bounds",
      )[#title]
    ]
    #if subtitle != none [
      #block(width: 100%, above: 3.5pt, below: 0pt)[
        #text(font: fonts.sans, size: 8.2pt, fill: slate-300)[#subtitle]
      ]
    ]
  ]
  // Bottom Specification Strip
  #if stats.len() > 0 [
    #block(width: 100%, fill: slate-100, inset: 8pt, above: 0pt, below: 0pt)[
      #equal-grid(
        columns: (1fr,) * stats.len(),
        gutter: 8pt,
        above: 0pt,
        below: 0pt,
        ..stats.enumerate().map(((idx, st)) => {
          let col = palette.at(calc.rem(idx, palette.len()))
          block(
            width: 100%,
            fill: white,
            stroke: strokes.hairline + slate-300,
            radius: radii.sm,
            inset: 8pt,
          )[
            #set par(justify: false, leading: 0.45em)
            #block(width: 100%, above: 0pt, below: 0pt)[
              #badge(
                st.at(0),
                fill: col.lighten(88%),
                text-color: col,
                stroke: strokes.hairline + col.lighten(35%),
                baseline: 0pt,
              )
            ]
            #block(width: 100%, above: 5pt, below: 0pt)[
              #text(font: fonts.sans, size: 11pt, weight: "bold", fill: floe-navy, top-edge: "cap-height", bottom-edge: "bounds")[#st.at(1)]
            ]
            #if st.len() >= 3 [
              #block(width: 100%, above: 3.5pt, below: 0pt)[
                #text(font: fonts.sans, size: 7.8pt, fill: slate-600)[#st.at(2)]
              ]
            ]
          ]
        })
      )
    ]
  ]
]

/// 7. Clean In-Page Section Header (Corner-Anchored Beans + Title + Accent Rule)
#let section-header(
  title: "",
  subtitle: none,
  tag: none,
  badge-label: none,
  badge-variant: "info",
  accent: floe-cyan,
  above: 10pt,
  below: 8pt,
  ..sink,
) = {
  let resolved-tag = if tag != none { tag } else if "badge-label" in sink.named() { none } else { "SECTION" }
  block(
    width: 100%,
    above: above,
    below: below,
    breakable: false,
  )[
    #set par(justify: false, leading: 0.45em)
    #if resolved-tag != none or badge-label != none [
      #block(width: 100%, above: 0pt, below: 0pt)[
        #grid(
          columns: (1fr, auto),
          gutter: 8pt,
          align: (top + left, top + right),
          if resolved-tag != none [
            #badge(resolved-tag, variant: "dark", baseline: 0pt)
          ] else [],
          if badge-label != none [
            #badge(badge-label, variant: badge-variant, baseline: 0pt)
          ] else [],
        )
      ]
    ]
    #block(width: 100%, above: 5.5pt, below: 0pt)[
      #text(
        font: fonts.sans,
        size: 12pt,
        weight: "bold",
        fill: floe-navy,
        top-edge: "cap-height",
        bottom-edge: "bounds",
      )[#title]
    ]
    #if subtitle != none [
      #block(width: 100%, above: 3.5pt, below: 0pt)[
        #text(font: fonts.sans, size: 8.6pt, fill: slate-600)[#subtitle]
      ]
    ]
    #block(width: 100%, above: 5pt, below: 0pt)[
      #line(length: 100%, stroke: 1.2pt + accent)
    ]
  ]
}

/// 8. Subchapter Lead-In Card (Left-Accented Scope & Topic Card)
#let subchapter-card(
  title: "",
  tag: none,
  badge-label: none,
  badge-variant: "neutral",
  accent: floe-navy,
  above: 8pt,
  below: 8pt,
  body,
) = {
  let has-beans = (tag != none) or (badge-label != none)
  block(
    width: 100%,
    fill: slate-100,
    stroke: (
      left: strokes.accent + accent,
      top: strokes.hairline + slate-300,
      right: strokes.hairline + slate-300,
      bottom: strokes.hairline + slate-300,
    ),
    radius: (right: radii.md, left: radii.sm),
    inset: (x: 10pt, top: 9pt, bottom: 9pt),
    above: above,
    below: below,
  )[
    #set par(justify: false, leading: 0.45em)
    #if has-beans [
      #block(width: 100%, above: 0pt, below: 0pt)[
        #grid(
          columns: (1fr, auto),
          gutter: 8pt,
          align: (top + left, top + right),
          if tag != none [
            #badge(tag, fill: accent, text-color: white, stroke: none, baseline: 0pt)
          ] else [],
          if badge-label != none [
            #badge(badge-label, variant: badge-variant, baseline: 0pt)
          ] else [],
        )
      ]
    ]
    #if title != "" [
      #block(width: 100%, above: if has-beans { 5.5pt } else { 0pt }, below: 0pt)[
        #text(
          font: fonts.sans,
          size: 9.8pt,
          weight: "bold",
          fill: floe-navy,
          top-edge: "cap-height",
          bottom-edge: "bounds",
        )[#title]
      ]
    ]
    #block(width: 100%, above: 4.5pt, below: 0pt)[
      #set text(font: fonts.sans, size: text-scale.sm, fill: slate-700)
      #body
    ]
  ]
}

/// 9. Minimalist Breadcrumb Header (Clean Editorial Monograph)
#let minimal-header(
  title: "",
  subtitle: none,
  breadcrumbs: (),
  date: none,
  above: 8pt,
  below: 10pt,
) = block(width: 100%, above: above, below: below)[
  #set par(justify: false, leading: 0.45em)
  #if breadcrumbs.len() > 0 or date != none [
    #block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 8pt,
        align: (top + left, top + right),
        if breadcrumbs.len() > 0 [
          #text(
            font: fonts.sans,
            size: 7.5pt,
            weight: "bold",
            fill: slate-500,
            tracking: 0.06em,
            top-edge: "cap-height",
            bottom-edge: "bounds",
          )[#breadcrumbs.map(b => upper(b)).join("  /  ")]
        ] else [],
        if date != none [
          #badge(date, variant: "neutral", baseline: 0pt)
        ] else [],
      )
    ]
  ]
  #block(width: 100%, above: if breadcrumbs.len() > 0 or date != none { 5.5pt } else { 0pt }, below: 0pt)[
    #text(
      font: fonts.sans,
      size: 13pt,
      weight: "bold",
      fill: floe-navy,
      top-edge: "cap-height",
      bottom-edge: "bounds",
    )[#title]
  ]
  #if subtitle != none [
    #block(width: 100%, above: 3.5pt, below: 0pt)[
      #text(font: fonts.sans, size: 8.8pt, fill: slate-600)[#subtitle]
    ]
  ]
  #block(width: 100%, above: 5pt, below: 0pt)[
    #line(length: 100%, stroke: strokes.border + slate-300)
  ]
]

/// 10. Executive Document Header Banner (Masthead for Reports & Memos)
#let document-header(
  title: "",
  subtitle: "",
  tag: none,
  badge-label: none,
  badge-variant: "info",
  metadata: (),
  accent: floe-cyan,
  above: 8pt,
  below: 12pt,
) = block(
  width: 100%,
  fill: white,
  stroke: strokes.border + slate-300,
  radius: radii.md,
  clip: true,
  above: above,
  below: below,
)[
  #set par(justify: false, leading: 0.45em)
  #block(width: 100%, height: 3pt, fill: accent, above: 0pt, below: 0pt)
  #block(width: 100%, inset: (x: 11pt, top: 9pt, bottom: 9pt), above: 0pt, below: 0pt)[
    #if tag != none or badge-label != none [
      #block(width: 100%, above: 0pt, below: 0pt)[
        #grid(
          columns: (1fr, auto),
          gutter: 8pt,
          align: (top + left, top + right),
          if tag != none [
            #badge(tag, variant: "dark", baseline: 0pt)
          ] else [],
          if badge-label != none [
            #badge(badge-label, variant: badge-variant, baseline: 0pt)
          ] else [],
        )
      ]
    ]
    #block(width: 100%, above: if tag != none or badge-label != none { 5.5pt } else { 0pt }, below: 0pt)[
      #text(
        font: fonts.sans,
        size: 15pt,
        weight: "bold",
        fill: floe-navy,
        top-edge: "cap-height",
        bottom-edge: "bounds",
      )[#title]
    ]
    #if subtitle != "" and subtitle != none [
      #block(width: 100%, above: 4pt, below: 0pt)[
        #text(font: fonts.sans, size: 9.2pt, fill: floe-muted)[#subtitle]
      ]
    ]
  ]
  #if metadata.len() > 0 [
    #block(
      width: 100%,
      fill: slate-100,
      stroke: (top: strokes.hairline + slate-300),
      inset: (x: 11pt, y: 7.5pt),
      above: 0pt,
      below: 0pt,
    )[
      #grid(
        columns: (1fr,) * calc.min(metadata.len(), 4),
        gutter: 10pt,
        ..metadata.map(item => [
          #text(font: fonts.sans, size: 7pt, weight: "bold", fill: floe-muted, tracking: 0.05em)[#upper(item.at(0))]
          #block(above: 2.5pt, below: 0pt, text(font: fonts.sans, size: 8.4pt, weight: "bold", fill: slate-800)[#item.at(1)])
        ])
      )
    ]
  ]
]

/// 11. Appendix Header Banner with Alphanumeric Numbering
#let appendix-header(
  letter: "A",
  title: "",
  subtitle: none,
  badge-label: none,
  slides-ref: "",
  reader-ref: "",
  teardown-ref: "",
  pagebreak-before: true,
  ..sink,
) = {
  if pagebreak-before {
    pagebreak(weak: true)
  }
  block(width: 100%, below: 1.3em)[
    #set par(justify: false, leading: 0.45em)
    #block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 8pt,
        align: (top + left, top + right),
        badge("APPENDIX " + upper(letter), variant: "purple", baseline: 0pt),
        if badge-label != none [
          #badge(badge-label, variant: "purple", baseline: 0pt)
        ] else [],
      )
    ]
    #block(width: 100%, above: 6.5pt, below: 0pt)[
      #if pagebreak-before [
        #heading(level: 1, numbering: none)[Appendix #letter. #title]
      ] else [
        #text(font: fonts.sans, size: 15pt, weight: "bold", fill: floe-navy, top-edge: "cap-height", bottom-edge: "bounds")[Appendix #letter. #title]
      ]
    ]
    #if subtitle != none [
      #block(width: 100%, above: 4pt, below: 0pt)[
        #text(font: fonts.sans, size: 10pt, fill: slate-600)[#subtitle]
      ]
    ]
    #block(width: 100%, above: 6pt, below: 0pt)[
      #line(length: 100%, stroke: 1.5pt + floe-purple)
    ]
    #if slides-ref != "" or reader-ref != "" or teardown-ref != "" [
      #block(
        width: 100%,
        fill: slate-100,
        stroke: strokes.border + slate-300,
        radius: radii.sm,
        inset: (x: 10pt, y: 6.5pt),
        above: 6pt,
        below: 0pt,
      )[
        #set text(font: fonts.sans, size: 8pt, fill: slate-800)
        #if slides-ref != "" [*Reference:* #h(4pt) #slides-ref]
        #if reader-ref != "" [ #h(8pt) | #h(8pt) #reader-ref ]
        #if teardown-ref != "" [ #h(8pt) | #h(8pt) *Scope:* #teardown-ref ]
      ]
    ]
  ]
}

/// 12. Presentation 16:9 Keynote Header Card
#let keynote-header(
  title: "",
  subtitle: "",
  tag: none,
  badge-label: none,
  above: 8pt,
  below: 8pt,
) = block(
  width: 100%,
  fill: floe-navy,
  radius: radii.md,
  inset: (x: 14pt, top: 12pt, bottom: 12pt),
  above: above,
  below: below,
  breakable: false,
)[
  #set par(justify: false, leading: 0.45em)
  #if tag != none or badge-label != none [
    #block(width: 100%, above: 0pt, below: 0pt)[
      #grid(
        columns: (1fr, auto),
        gutter: 8pt,
        align: (top + left, top + right),
        if tag != none [
          #badge(
            tag,
            fill: floe-cyan.transparentize(80%),
            text-color: floe-cyan,
            stroke: strokes.hairline + floe-cyan.transparentize(40%),
            baseline: 0pt,
          )
        ] else [],
        if badge-label != none [
          #badge(badge-label, fill: white.transparentize(86%), text-color: white, baseline: 0pt)
        ] else [],
      )
    ]
  ]
  #block(width: 100%, above: if tag != none or badge-label != none { 7pt } else { 0pt }, below: 0pt)[
    #text(
      font: fonts.sans,
      size: 16pt,
      weight: "bold",
      fill: white,
      top-edge: "cap-height",
      bottom-edge: "bounds",
    )[#title]
  ]
  #if subtitle != "" and subtitle != none [
    #block(width: 100%, above: 4.5pt, below: 0pt)[
      #text(font: fonts.sans, size: 9.8pt, fill: slate-300)[#subtitle]
    ]
  ]
]
