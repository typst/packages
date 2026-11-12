// ============================================================================
// FLOE DESIGN SYSTEM — PEDAGOGICAL EXPLAINERS (components/pedagogical.typ)
// Canva-Style Explainer Cards, Stepper Notebooks & Visual Dissection Canvases
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": card, badge
#import "academic.typ": _parse-args

/// Physical / Scientific Anchor: Grounding abstract math in physical, chemical, or engineering intuition
#let physical-anchor(..args) = {
  let (title, body) = _parse-args(args)
  let system = if "system" in args.named() { args.named().system } else { none }
  let domain = if "domain" in args.named() { args.named().domain } else { "PHYSICAL ANCHOR" }
  let inline-header = if "inline-header" in args.named() { args.named().inline-header } else { false }

  block(
    width: 100%,
    breakable: true,
    stroke: strokes.border + rgb("#A7F3D0"),
    radius: radii.md,
    fill: rgb("#F8FAF9"),
    clip: true,
    above: 8pt,
    below: 8pt,
  )[
    // Header
    #block(
      width: 100%,
      sticky: true,
      fill: rgb("#ECFDF5"),
      stroke: (bottom: strokes.hairline + rgb("#D1FAE5")),
      inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
      above: 0pt,
      below: 0pt,
    )[
      #set par(justify: false, leading: 0.45em)
      #if not inline-header [
        #block(width: 100%, above: 0pt, below: 0pt)[
          #grid(
            columns: (1fr, auto),
            gutter: 8pt,
            align: (top + left, top + right),
            badge(upper(domain), fill: floe-green, text-color: white),
            if system != none [
              #badge(system, variant: "outline")
            ] else [],
          )
        ]
        #if title != none [
          #block(width: 100%, above: 5.5pt, below: 0pt)[
            #text(
              font: fonts.sans,
              size: 9.6pt,
              weight: "bold",
              fill: floe-navy,
              top-edge: "cap-height",
              bottom-edge: "bounds",
            )[#title]
          ]
        ]
      ] else [
        #grid(
          columns: (auto, 1fr, auto),
          gutter: 8pt,
          align: (horizon, horizon, horizon),
          badge(upper(domain), fill: floe-green, text-color: white),
          if title != none [
            #text(font: fonts.sans, size: 9.5pt, weight: "bold", fill: floe-navy)[#title]
          ],
          if system != none [
            #badge(system, variant: "outline")
          ],
        )
      ]
    ]
    #block(
      width: 100%,
      inset: (x: 12pt, y: 10pt),
      above: 0pt,
      below: 0pt,
    )[
      #set text(fill: slate-800)
      #set par(justify: true)
      #body
    ]
  ]
}

/// Hand-Worked Step-by-Step Numerical Example
#let worked-example(..args) = {
  let (title, body) = _parse-args(args)
  let problem = if "problem" in args.named() { args.named().problem } else { none }
  let solution = if "solution" in args.named() { args.named().solution } else { none }
  let badge-label = if "badge-label" in args.named() { args.named().badge-label } else { none }
  let inline-header = if "inline-header" in args.named() { args.named().inline-header } else { false }
  let breakable = if "breakable" in args.named() { args.named().breakable } else { false }

  block(
    width: 100%,
    breakable: breakable,
    stroke: strokes.border + rgb("#FDE68A"),
    radius: radii.md,
    fill: white,
    clip: true,
    above: 8pt,
    below: 8pt,
  )[
    // Header
    #block(
      width: 100%,
      sticky: true,
      fill: rgb("#FFFBEB"),
      stroke: (bottom: strokes.hairline + rgb("#FEF3C7")),
      inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
      above: 0pt,
      below: 0pt,
    )[
      #set par(justify: false, leading: 0.45em)
      #if not inline-header [
        #block(width: 100%, above: 0pt, below: 0pt)[
          #grid(
            columns: (1fr, auto),
            gutter: 8pt,
            align: (top + left, top + right),
            badge("WORKED NUMERICAL EXAMPLE", fill: floe-amber, text-color: white),
            if badge-label != none [
              #badge(badge-label, variant: "warning")
            ] else [],
          )
        ]
        #if title != none [
          #block(width: 100%, above: 5.5pt, below: 0pt)[
            #text(
              font: fonts.sans,
              size: 9.6pt,
              weight: "bold",
              fill: floe-navy,
              top-edge: "cap-height",
              bottom-edge: "bounds",
            )[#title]
          ]
        ]
      ] else [
        #grid(
          columns: (auto, 1fr, auto),
          gutter: 8pt,
          align: (horizon, horizon, horizon),
          badge("WORKED NUMERICAL EXAMPLE", fill: floe-amber, text-color: white),
          if title != none [
            #text(font: fonts.sans, size: 9.6pt, weight: "bold", fill: floe-navy)[#title]
          ],
          if badge-label != none [
            #badge(badge-label, variant: "warning")
          ],
        )
      ]
    ]

    // Body
    #block(
      width: 100%,
      inset: (x: 12pt, y: 10pt),
      above: 0pt,
      below: 0pt,
    )[
      #set text(fill: slate-800)
      #if problem != none [
        #block(fill: slate-100, inset: 8pt, radius: radii.sm, stroke: strokes.hairline + slate-300)[
          #text(font: fonts.sans, size: 8pt, weight: "bold", fill: slate-700)[PROBLEM STATEMENT:]
          #v(2pt)
          #problem
        ]
        #v(6pt)
      ]
      #body
      #if solution != none [
        #v(6pt)
        #block(fill: rgb("#F0FDF4"), inset: 8pt, radius: radii.sm, stroke: strokes.hairline + rgb("#BBF7D0"))[
          #text(font: fonts.sans, size: 8pt, weight: "bold", fill: rgb("#15803D"))[FINAL RESULT:]
          #h(6pt)
          #solution
        ]
      ]
    ]
  ]
}

#let _parse-symbol-tuple(idx, s, palette: term-palette) = {
  let is-colored = (type(s.at(0)) == color)
  let s-color = if is-colored { s.at(0) } else { palette.at(calc.rem(idx, palette.len())) }
  let s-label = if is-colored { s.at(1) } else { s.at(0) }
  let s-name  = if is-colored { s.at(2) } else { s.at(1) }
  let s-desc  = if is-colored {
    if s.len() >= 4 { s.at(3) } else { none }
  } else {
    if s.len() >= 3 { s.at(2) } else { none }
  }
  (s-color, s-label, s-name, s-desc)
}

#let _render-symbol-card(s-color, s-label, s-name, s-desc, h: auto) = block(
  width: 100%,
  height: h,
  fill: slate-50,
  stroke: strokes.hairline + slate-200,
  radius: radii.sm,
  inset: 7pt,
)[
  #set par(justify: false, leading: 0.45em)
  // Row 1: Corner-anchored Symbol Bean
  #block(width: 100%, above: 0pt, below: 0pt)[
    #badge(
      s-label,
      fill: s-color.lighten(88%),
      text-color: s-color,
      stroke: strokes.hairline + s-color.lighten(35%),
    )
  ]
  // Row 2: Full-width Term Name
  #block(width: 100%, above: 4.5pt, below: 0pt)[
    #text(
      font: fonts.sans,
      size: 8.8pt,
      weight: "bold",
      fill: floe-navy,
      top-edge: "cap-height",
      bottom-edge: "bounds",
    )[#s-name]
  ]
  // Row 3: Full-width Description
  #if s-desc != none [
    #block(width: 100%, above: 3.5pt, below: 0pt)[
      #set text(size: 8.2pt, fill: slate-700)
      #s-desc
    ]
  ]
]

/// Visual Formula Breakdown Canvas
/// Displays equation prominently on a pedestal (supporting `#t1`..`#t6` or `#math-hl` color coding),
/// followed by symbol breakdown cards & numerical sanity check.
/// `symbols` accepts either 3-tuples `($sym$, "Name", [Desc])` (auto-colored with `palette`)
/// or 4-tuples `(color, $sym$, "Name", [Desc])`.
#let formula-breakdown(
  title: "Symbol-by-Symbol Mechanics",
  badge-label: none,
  inline-header: false,
  formula: none,
  symbols: (),
  palette: term-palette,
  ascii: "",
  arithmetic: none,
  card-columns: (1fr, 1fr),
  breakable: false,
  ..sink,
) = {
  let body = if sink.pos().len() > 0 { sink.pos().at(0) } else { none }

  block(
    width: 100%,
    stroke: strokes.border + slate-300,
    radius: radii.md,
    fill: white,
    clip: true,
    above: 8pt,
    below: 8pt,
    breakable: breakable,
  )[
    // Header
    #block(
      width: 100%,
      sticky: true,
      fill: slate-200,
      stroke: (bottom: strokes.hairline + slate-300),
      inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
      above: 0pt,
      below: 0pt,
    )[
      #set par(justify: false, leading: 0.45em)
      #if not inline-header [
        #block(width: 100%, above: 0pt, below: 0pt)[
          #grid(
            columns: (1fr, auto),
            gutter: 8pt,
            align: (top + left, top + right),
            badge("FORMULA BREAKDOWN", variant: "dark"),
            if badge-label != none [
              #badge(badge-label, variant: "info")
            ] else [],
          )
        ]
        #if title != none [
          #block(width: 100%, above: 5.5pt, below: 0pt)[
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
      ] else [
        #grid(
          columns: (auto, 1fr, auto),
          gutter: 8pt,
          align: (horizon, horizon, horizon),
          badge("FORMULA BREAKDOWN", variant: "dark"),
          text(font: fonts.sans, size: 9pt, weight: "bold", fill: floe-navy)[#title],
          if badge-label != none [
            #badge(badge-label, variant: "info")
          ],
        )
      ]
    ]
    #if formula != none [
      #block(
        width: 100%,
        fill: rgb("#F8FAFC"),
        stroke: (bottom: strokes.hairline + slate-200),
        inset: (x: 10pt, y: 11pt),
        above: 0pt,
        below: 0pt,
        align(center)[
          #text(size: 11.5pt, fill: slate-900)[
            #if type(formula) == content and formula.func() == math.equation [
              #math.equation(formula.body, block: true, numbering: none)
            ] else if type(formula) == str [
              $ #formula $
            ] else [
              #formula
            ]
          ]
        ]
      )
    ]
    #if body != none [
      #block(
        width: 100%,
        inset: (x: 12pt, y: 8pt),
        above: 0pt,
        below: 0pt,
      )[
        #set text(fill: slate-800)
        #set par(justify: true)
        #body
      ]
    ]
    #if symbols.len() > 0 [
      #block(
        width: 100%,
        inset: 8pt,
        above: 0pt,
        below: 0pt,
      )[
        #layout(size => {
          let ncols = card-columns.len()
          let gutter = 8pt
          let col-w = (size.width - gutter * (ncols - 1)) / ncols
          let parsed-symbols = symbols.enumerate().map(((idx, s)) => _parse-symbol-tuple(idx, s, palette: palette))
          let chunks = ()
          let curr = ()
          for ps in parsed-symbols {
            curr.push(ps)
            if curr.len() == ncols {
              chunks.push(curr)
              curr = ()
            }
          }
          if curr.len() > 0 {
            chunks.push(curr)
          }

          context {
            let all-symbol-cards = ()
            for chunk in chunks {
              let measured = chunk.map(ps => {
                measure(block(width: col-w, _render-symbol-card(ps.at(0), ps.at(1), ps.at(2), ps.at(3))))
              })
              let max-h = calc.max(..measured.map(m => m.height))
              for ps in chunk {
                all-symbol-cards.push(_render-symbol-card(ps.at(0), ps.at(1), ps.at(2), ps.at(3), h: max-h))
              }
            }
            grid(
              columns: card-columns,
              column-gutter: gutter,
              row-gutter: gutter,
              ..all-symbol-cards,
            )
          }
        })
      ]
    ]
    #if ascii != "" and symbols.len() == 0 [
      #block(
        width: 100%,
        inset: 8pt,
        above: 0pt,
        below: 0pt,
        align(center)[
          #if type(ascii) == str {
            raw(ascii, lang: "text")
          } else {
            ascii
          }
        ]
      )
    ]
    #if arithmetic != none [
      #block(
        width: 100%,
        fill: rgb("#F0FDF4"),
        stroke: (top: strokes.hairline + slate-200),
        inset: (x: 12pt, y: 7.5pt),
        above: 0pt,
        below: 0pt,
      )[
        #set text(fill: slate-800)
        #grid(
          columns: (auto, 1fr),
          gutter: 6pt,
          align: (top, top),
          text(font: fonts.sans, size: 8pt, fill: rgb("#16A34A"))[✓],
          [
            #text(font: fonts.sans, size: 8pt, weight: "bold", fill: rgb("#15803D"))[Concrete Numerical Verification:]
            #h(4pt)
            #set text(size: 8.5pt)
            #arithmetic
          ]
        )
      ]
    ]
  ]
}

/// Mathematical Derivation Stepper: Step-by-step mathematical reasoning pipeline
#let derivation-stepper(
  steps: (),
  title: "Step-by-Step Mathematical Mechanics",
  badge-label: none,
  inline-header: false,
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
)[
  #block(
    width: 100%,
    sticky: true,
    fill: slate-200,
    inset: (x: 9pt, top: 9pt, bottom: 8.5pt),
    stroke: (bottom: strokes.hairline + slate-300),
  )[
    #set par(justify: false, leading: 0.45em)
    #if not inline-header [
      #block(width: 100%, above: 0pt, below: 0pt)[
        #grid(
          columns: (1fr, auto),
          gutter: 8pt,
          align: (top + left, top + right),
          badge("DERIVATION STEPPER", fill: floe-navy, text-color: white),
          if badge-label != none [
            #badge(badge-label, variant: "info")
          ] else [],
        )
      ]
      #if title != none [
        #block(width: 100%, above: 5.5pt, below: 0pt)[
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
    ] else [
      #grid(
        columns: (auto, 1fr, auto),
        gutter: 8pt,
        align: (horizon, horizon, horizon),
        badge("DERIVATION STEPPER", fill: floe-navy, text-color: white),
        text(font: fonts.sans, size: 9pt, weight: "bold", fill: floe-navy)[#title],
        if badge-label != none [
          #badge(badge-label, variant: "info")
        ],
      )
    ]
  ]
  #for (i, st) in steps.enumerate() [
    #block(
      width: 100%,
      fill: if calc.even(i) { white } else { slate-100 },
      inset: (x: 12pt, y: 9pt),
      stroke: if i > 0 { (top: strokes.hairline + slate-200) } else { none },
    )[
      #grid(
        columns: (20pt, 1fr),
        gutter: 10pt,
        align: (top, top),
        box(
          width: 18pt,
          height: 18pt,
          fill: floe-cyan.lighten(82%),
          stroke: strokes.hairline + floe-cyan.lighten(45%),
          radius: radii.full,
          align(center + horizon)[#text(font: fonts.sans, size: 8pt, weight: "bold", fill: floe-navy)[#(i+1)]]
        ),
        [
          #text(font: fonts.sans, size: 8.8pt, weight: "bold", fill: floe-navy)[#st.at(0)]
          #v(3pt)
          #align(center)[#block(fill: white, inset: (x: 10pt, y: 5.5pt), stroke: strokes.hairline + slate-300, radius: radii.sm)[$#st.at(1)$]]
          #if st.len() >= 3 [
            #v(3pt)
            #text(size: 8.2pt, fill: slate-700)[*Physical Intuition:* #h(4pt) #st.at(2)]
          ]
        ]
      )
    ]
  ]
]
