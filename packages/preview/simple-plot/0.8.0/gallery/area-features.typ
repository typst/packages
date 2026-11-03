//
// area-features.typ — Test / gallery for all new area-fill features in simple-plot 0.4.0
//
#import "@preview/simple-plot:0.8.0": plot, fill-area, area-between, note, vline, hline, riemann-sum

#set page(margin: 1.5cm, width: 21cm)
#set text(font: "New Computer Modern", size: 10pt)

#let demo(title, body) = {
  v(0.8em)
  block[
    *#title*
    #v(0.3em)
    #body
  ]
}

= simple-plot 0.4.0 — Area-fill feature gallery

// ── 1. fill: below a curve ───────────────────────────────────────────────────
#demo("1 · `fill:` — solid fill below a curve to baseline")[
  #grid(columns: (1fr, 1fr), gutter: 1em)[
    _Fill sin(x) above x-axis (blue):_
    #align(center)[
      #plot(
        xmin: -0.3, xmax: 7, ymin: -1.4, ymax: 1.4,
        width: 7, height: 4,
        axis-x-pos: "center", axis-y-pos: 0,
        xtick: (1, 2, 3, 4, 5, 6), ytick: (-1, 1),
        fill-area(x => calc.sin(x), domain: (0.0, calc.pi),
                  color: blue.lighten(75%)),
        (fn: x => calc.sin(x), domain: (-0.2, 6.8), stroke: blue + 1.2pt,
         label: $sin(x)$, label-pos: 0.15, label-anchor: "south"),
      )
    ]
  ][
    _Fill between curve and baseline y=0.5 (orange):_
    #align(center)[
      #plot(
        xmin: -0.3, xmax: 4, ymin: -0.3, ymax: 2.5,
        width: 7, height: 4,
        axis-x-pos: "center", axis-y-pos: 0,
        xtick: (1, 2, 3), ytick: (1, 2),
        fill-area(x => calc.sqrt(x), baseline: 0.5, domain: (0.25, 3.5),
                  color: orange.lighten(70%)),
        (hline: 0.5, stroke: stroke(paint: luma(100), thickness: 0.6pt, dash: "dashed")),
        (fn: x => calc.sqrt(x), domain: (0.01, 3.8), stroke: rgb("#e05") + 1.2pt,
         label: $sqrt(x)$, label-pos: 0.9, label-anchor: "south-west"),
      )
    ]
  ]
]

// ── 2. fill-between: solid color ─────────────────────────────────────────────
#demo("2 · `fill-between:` — solid color between two curves")[
  #align(center)[
    #plot(
      xmin: -1, xmax: 3, ymin: -3, ymax: 9,
      width: 10, height: 5.5,
      axis-x-pos: "center", axis-y-pos: "center",
      xtick: (-0, 1, 2), ytick: (-2, -1, 1, 2, 3, 4, 5, 6, 7, 8),
      area-between(x => 1.5 * calc.exp(x), x => calc.exp(x) - 2.0,
                   domain: (0.0, 1.0), color: green.lighten(70%)),
      (fn: x => 1.5 * calc.exp(x), domain: (-0.8, 1.8), stroke: blue + 1.2pt,
       label: $f(x) = 3/2 e^x$, label-pos: 0.75, label-anchor: "south-west"),
      (fn: x => calc.exp(x) - 2.0, domain: (-0.8, 1.8), stroke: red + 1.2pt,
       label: $g(x) = e^x - 2$, label-pos: 0.7, label-anchor: "north-east"),
      (vline: 0.0, stroke: stroke(paint: luma(120), thickness: 0.6pt, dash: "dotted")),
      (vline: 1.0, stroke: stroke(paint: luma(120), thickness: 0.6pt, dash: "dotted")),
    )
  ]
]

// ── 3. Hatch pattern gallery ─────────────────────────────────────────────────
#demo("3 · Hatch pattern styles — `\"ne\"`, `\"nw\"`, `\"h\"`, `\"v\"`, `\"cross\"`, `\"grid\"`")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.5em,
    ..for (style, col) in (
      ("ne",    blue),
      ("nw",    red),
      ("h",     green.darken(20%)),
      ("v",     purple),
      ("cross", rgb("#e06000")),
      ("grid",  teal),
    ) {
      (
        align(center)[
          #text(8pt)[`"#style"`]
          #v(0.2em)
          #plot(
            xmin: -1, xmax: 3, ymin: -0.5, ymax: 5,
            width: 5, height: 3,
            axis-x-pos: "center", axis-y-pos: 0,
            xtick: (1, 2), ytick: (1, 2, 3, 4),
            fill-area(x => x * x, domain: (0.0, 2.0),
                      hatch: style, hatch-spacing: 5pt,
                      hatch-stroke: col + 0.6pt),
            (fn: x => x * x, domain: (-0.5, 2.3), stroke: col + 1.2pt),
          )
        ],
      )
    }
  )
]

// ── 4. Overlapping fills (intersection) ──────────────────────────────────────
#demo("4 · Overlapping fills — two areas in different colors reveal intersection")[
  #align(center)[
    #plot(
      xmin: -0.5, xmax: 7, ymin: -1.5, ymax: 1.5,
      width: 12, height: 5,
      axis-x-pos: "center", axis-y-pos: 0,
      xtick: (1, 2, 3, 4, 5, 6), ytick: (-1, 1),
      fill-area(x => calc.sin(x), domain: (0.0, calc.pi),
                color: blue.transparentize(60%)),
      fill-area(x => calc.sin(x - 1.0), domain: (1.0, calc.pi + 1.0),
                color: red.transparentize(60%)),
      (fn: x => calc.sin(x), domain: (-0.2, 6.8), stroke: blue + 1.2pt,
       label: $sin(x)$, label-pos: 0.15, label-anchor: "south"),
      (fn: x => calc.sin(x - 1.0), domain: (-0.2, 6.8), stroke: red + 1.2pt,
       label: $sin(x-1)$, label-pos: 0.4, label-anchor: "south"),
    )
  ]
]

// ── 5. annotation + vline + hline ────────────────────────────────────────────
#demo("5 · `annotation:`, `vline:`, `hline:` — asymptote labelling")[
  #align(center)[
    #plot(
      xmin: -4, xmax: 6, ymin: -0.3, ymax: 5,
      width: 11, height: 5,
      axis-x-pos: "bottom", axis-y-pos: "left",
      xtick: (-3, -2, -1, 2, 3, 4, 5), ytick: (1, 2, 3, 4),
      // asymptote lines
      (vline: 1.0, stroke: stroke(paint: luma(100), thickness: 0.7pt, dash: "dashed")),
      (hline: 1.0, stroke: stroke(paint: luma(100), thickness: 0.7pt, dash: "dashed")),
      // curve (two branches)
      (fn: x => calc.exp(1.0 / (x - 1.0)), domain: (-4, 0.85),
       stroke: blue + 1.2pt, samples: 100),
      (fn: x => calc.exp(1.0 / (x - 1.0)), domain: (1.15, 5.8),
       stroke: blue + 1.2pt, samples: 100,
       label: $f(x) = e^(1/(x-1))$, label-pos: 0.55, label-anchor: "south-west"),
      // annotations
      note([AV : $x = 1$], (1.15, 4.5), anchor: "west", size: 9pt),
      note([AH : $y = 1$], (3.5, 1.2), anchor: "west", size: 9pt),
    )
  ]
]

// ── 6. Proof ln(2) > 1/2  using riemann-sum ──────────────────────────────────
#demo("6 · Proof $ln(2) > 1/2$ — `riemann-sum` (n=1, right) + `fill-area`")[
  #align(center)[
    #plot(
      xmin: 0, xmax: 9, ymin: 0, ymax: 1.3,
      width: 10, height: 4.5,
      axis-x-pos: "bottom", axis-y-pos: "left",
      xlabel: $x$,
      xtick: (1, 2, 4, 8), ytick: (0.5, 1.0),
      show-origin: false,
      // right Riemann sum n=1: rectangle [1,2] height f(2)=1/2
      riemann-sum(x => 1.0 / x, domain: (1.0, 2.0), n: 1, method: "right",
                  color: luma(210), stroke: luma(70) + 0.6pt),
      // blue area = ln(2)
      fill-area(x => 1.0 / x, baseline: 0.0, domain: (1.0, 2.0),
                color: blue.lighten(75%)),
      // curve
      (fn: x => 1.0 / x, domain: (0.35, 8.8), stroke: blue + 1.4pt, samples: 120,
       label: $y = 1/x$, label-pos: 0.08, label-anchor: "north-east"),
      // dotted verticals at 4 and 8
      vline(4.0, stroke: stroke(paint: luma(150), thickness: 0.5pt, dash: "dotted")),
      vline(8.0, stroke: stroke(paint: luma(150), thickness: 0.5pt, dash: "dotted")),
      note($ln 2$, (1.5, 0.2), anchor: "center", size: 9pt),
      note($1/2$,  (1.88, 0.5), anchor: "south", size: 8pt),
    )
  ]
]

// ── 7. Hatched + solid layers (tkz-fct style) ────────────────────────────────
#demo("7 · Hatched region + solid outline (tkz-fct style integral illustration)")[
  #align(center)[
    #plot(
      xmin: -0.5, xmax: 5, ymin: -0.5, ymax: 3,
      width: 11, height: 5,
      axis-x-pos: "center", axis-y-pos: 0,
      xtick: (1, 2, 3, 4), ytick: (1, 2),
      // hatched area between x and x² on [0,1]
      area-between(x => x, x => x * x, domain: (0.0, 1.0),
                   hatch: "ne", hatch-spacing: 4pt,
                   hatch-stroke: green.darken(20%) + 0.5pt),
      // hatched area between x² and 0 on [1,2]
      fill-area(x => x * x, domain: (1.0, 2.0),
                hatch: "nw", hatch-spacing: 4pt,
                hatch-stroke: red.darken(10%) + 0.5pt),
      (fn: x => x, domain: (0.0, 4.5), stroke: green.darken(20%) + 1.2pt,
       label: $y = x$, label-pos: 0.9, label-anchor: "south-west"),
      (fn: x => x * x, domain: (-0.3, 2.2), stroke: red.darken(10%) + 1.2pt,
       label: $y = x^2$, label-pos: 0.6, label-anchor: "south-east"),
      (vline: 1.0, stroke: stroke(paint: luma(130), thickness: 0.5pt, dash: "dotted")),
      (vline: 2.0, stroke: stroke(paint: luma(130), thickness: 0.5pt, dash: "dotted")),
    )
  ]
]

// ── 8. Riemann sums gallery ──────────────────────────────────────────────────
#demo("8 · `riemann-sum` — left, right, midpoint methods")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.5em,
    ..for (meth, label-txt) in (
      ("left",  "Left (lower for $f$ incr.)"),
      ("right", "Right (upper for $f$ incr.)"),
      ("mid",   "Midpoint"),
    ) {(
      align(center)[
        #text(8pt)[*#label-txt*]
        #v(0.2em)
        #plot(
          xmin: 0, xmax: 5, ymin: 0, ymax: 4,
          width: 5.5, height: 3.5,
          axis-x-pos: "bottom", axis-y-pos: "left",
          xtick: (1, 2, 3, 4), ytick: (1, 2, 3),
          show-origin: false,
          riemann-sum(x => calc.sqrt(x) + 0.3, domain: (0.5, 4.5), n: 4, method: meth,
                      color: blue.lighten(75%), stroke: blue.darken(20%) + 0.6pt),
          fill-area(x => calc.sqrt(x) + 0.3, baseline: 0.0, domain: (0.5, 4.5),
                    color: blue.transparentize(85%)),
          (fn: x => calc.sqrt(x) + 0.3, domain: (0.2, 4.8), stroke: blue + 1.2pt, samples: 80),
        )
      ],
    )}
  )
]

// ── 9. Riemann sum for decreasing function (upper/lower bounds) ───────────────
#demo("9 · Upper and lower Riemann sums for $1/x$ on $[1, 4]$")[
  #grid(columns: (1fr, 1fr), gutter: 1em,
    align(center)[
      #text(8pt)[*Left sum (upper bound, $f$ decreasing)*]
      #v(0.2em)
      #plot(
        xmin: 0, xmax: 4.5, ymin: 0, ymax: 1.4,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xlabel: $x$, show-origin: false,
        xtick: (1, 2, 3, 4), ytick: (0.5, 1.0),
        riemann-sum(x => 1.0 / x, domain: (1.0, 4.0), n: 6, method: "left",
                    color: luma(220), stroke: luma(80) + 0.5pt),
        fill-area(x => 1.0 / x, baseline: 0.0, domain: (1.0, 4.0),
                  color: blue.lighten(75%)),
        (fn: x => 1.0 / x, domain: (0.4, 4.4), stroke: blue + 1.3pt, samples: 100,
         label: $1/x$, label-pos: 0.1, label-anchor: "north-east"),
      )
    ],
    align(center)[
      #text(8pt)[*Right sum (lower bound, $f$ decreasing)*]
      #v(0.2em)
      #plot(
        xmin: 0, xmax: 4.5, ymin: 0, ymax: 1.4,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xlabel: $x$, show-origin: false,
        xtick: (1, 2, 3, 4), ytick: (0.5, 1.0),
        riemann-sum(x => 1.0 / x, domain: (1.0, 4.0), n: 6, method: "right",
                    color: luma(220), stroke: luma(80) + 0.5pt),
        fill-area(x => 1.0 / x, baseline: 0.0, domain: (1.0, 4.0),
                  color: blue.lighten(75%)),
        (fn: x => 1.0 / x, domain: (0.4, 4.4), stroke: blue + 1.3pt, samples: 100,
         label: $1/x$, label-pos: 0.1, label-anchor: "north-east"),
      )
    ],
  )
]

// ── 10. Hatched Riemann sums ──────────────────────────────────────────────────
#demo("10 · Hatched Riemann sum + fill-area overlay")[
  #align(center)[
    #plot(
      xmin: -0.3, xmax: 7, ymin: -1.5, ymax: 1.5,
      width: 12, height: 5,
      axis-x-pos: "center", axis-y-pos: 0,
      xtick: (1, 2, 3, 4, 5, 6), ytick: (-1, 1),
      riemann-sum(x => calc.sin(x), domain: (0.0, calc.pi), n: 6, method: "mid",
                  color: none, hatch: "ne", hatch-spacing: 4pt,
                  hatch-stroke: blue + 0.5pt, stroke: blue.darken(20%) + 0.5pt),
      fill-area(x => calc.sin(x), domain: (0.0, calc.pi), color: blue.transparentize(80%)),
      (fn: x => calc.sin(x), domain: (-0.2, 6.8), stroke: blue + 1.3pt,
       label: $sin(x)$, label-pos: 0.15, label-anchor: "south"),
    )
  ]
]
