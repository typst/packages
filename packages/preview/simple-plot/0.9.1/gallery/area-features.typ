//
// area-features.typ — Gallery for area fills, hatching and Riemann overlays
//
#import "@preview/simple-plot:0.9.1": plot, fill-area, area-between, note, vline, hline, riemann-sum

#set page(margin: 1.5cm, width: 21cm)
#set text(font: "New Computer Modern", size: 10pt)

#let demo(title, body) = {
  v(0.8em)
  block[
    #strong(title)
    #v(0.3em)
    #body
  ]
}

= simple-plot — Area-fill feature gallery

// ── 1. fill: below a curve ───────────────────────────────────────────────────
#demo[1 · `fill-area` — solid fill below a curve to a baseline][
  #grid(columns: (1fr, 1fr), gutter: 1em,
    align(center)[
      _Fill $sin(x)$ above the $x$-axis:_
      #v(0.3em)
      #plot(
        xmin: -0.3, xmax: 7, ymin: -1.4, ymax: 1.4,
        width: 7, height: 4,
        axis-x-pos: "center", axis-y-pos: 0,
        xtick: (1, 2, 3, 4, 5, 6), ytick: (-1, 1),
        fill-area(x => calc.sin(x), domain: (0.0, calc.pi),
                  color: blue.lighten(75%)),
        (fn: x => calc.sin(x), domain: (-0.2, 6.8), stroke: blue + 1.2pt,
         label: $sin(x)$, label-pos: 0.15, label-side: "above"),
      )
    ],
    align(center)[
      _Fill between curve and baseline $y = 0.5$:_
      #v(0.3em)
      #plot(
        xmin: -0.3, xmax: 4, ymin: -0.3, ymax: 2.5,
        width: 7, height: 4,
        axis-x-pos: "center", axis-y-pos: 0,
        xtick: (1, 2, 3), ytick: (1, 2),
        fill-area(x => calc.sqrt(x), baseline: 0.5, domain: (0.25, 3.5),
                  color: orange.lighten(70%)),
        (hline: 0.5, stroke: stroke(paint: luma(100), thickness: 0.6pt, dash: "dashed")),
        (fn: x => calc.sqrt(x), domain: (0.01, 3.8), stroke: rgb("#e05") + 1.2pt,
         label: $sqrt(x)$, label-pos: 0.9, label-side: "above-left"),
      )
    ],
  )
]

// ── 2. fill-between: solid color ─────────────────────────────────────────────
#demo[2 · `area-between` — solid color between two curves][
  #align(center)[
    #plot(
      xmin: -1, xmax: 3, ymin: -3, ymax: 9,
      width: 10, height: 5.5,
      axis-x-pos: "center", axis-y-pos: "center",
      xtick: (1, 2), ytick: (-2, 2, 4, 6, 8),
      area-between(x => 1.5 * calc.exp(x), x => calc.exp(x) - 2.0,
                   domain: (0.0, 1.0), color: green.lighten(70%)),
      (fn: x => 1.5 * calc.exp(x), domain: (-0.8, 1.75), stroke: blue + 1.2pt,
       label: $f(x) = 3/2 e^x$, label-pos: 0.97, label-side: "left"),
      (fn: x => calc.exp(x) - 2.0, domain: (-0.8, 2.35), stroke: red + 1.2pt,
       label: $g(x) = e^x - 2$, label-pos: 0.97, label-side: "right"),
      (vline: 0.0, stroke: stroke(paint: luma(120), thickness: 0.6pt, dash: "dotted")),
      (vline: 1.0, stroke: stroke(paint: luma(120), thickness: 0.6pt, dash: "dotted")),
    )
  ]
]

// ── 3. Hatch pattern gallery ─────────────────────────────────────────────────
#demo[3 · Hatch pattern styles — `"ne"`, `"nw"`, `"h"`, `"v"`, `"cross"`, `"grid"`][
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
          #text(8pt, raw("\"" + style + "\""))
          #v(0.2em)
          #plot(
            xmin: -1, xmax: 3, ymin: -0.5, ymax: 5,
            width: 4.6, height: 3,
            xlabel: none, ylabel: none,
            axis-x-pos: "center", axis-y-pos: 0,
            xtick: (1, 2), ytick: (1, 2, 3, 4),
            fill-area(x => x * x, domain: (0.0, 2.0),
                      hatch: style, hatch-spacing: 5pt,
                      hatch-stroke: col + 0.6pt),
            (fn: x => x * x, domain: (-0.5, 2.2), stroke: col + 1.2pt),
          )
        ],
      )
    }
  )
]

// ── 4. Overlapping fills (intersection) ──────────────────────────────────────
#demo[4 · Overlapping fills — two transparent areas reveal their intersection][
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
       label: $sin(x)$, label-pos: 0.13, label-side: "above-left"),
      (fn: x => calc.sin(x - 1.0), domain: (-0.2, 6.8), stroke: red + 1.2pt,
       label: $sin(x - 1)$, label-pos: 0.42, label-side: "above-right"),
    )
  ]
]

// ── 5. annotation + vline + hline ────────────────────────────────────────────
#demo[5 · `note`, `vline`, `hline` — asymptote labelling][
  #align(center)[
    #plot(
      xmin: -4, xmax: 6, ymin: -0.3, ymax: 5,
      width: 11, height: 5,
      axis-x-pos: "bottom", axis-y-pos: "left",
      xtick: (-3, -2, -1, 2, 3, 4, 5), ytick: (2, 3, 4),
      vline(1.0, stroke: stroke(paint: luma(100), thickness: 0.7pt, dash: "dashed")),
      hline(1.0, stroke: stroke(paint: luma(100), thickness: 0.7pt, dash: "dashed")),
      (fn: x => calc.exp(1.0 / (x - 1.0)), domain: (-4, 0.85),
       stroke: blue + 1.2pt, samples: 100),
      (fn: x => calc.exp(1.0 / (x - 1.0)), domain: (1.15, 5.8),
       stroke: blue + 1.2pt, samples: 100,
       label: $f(x) = e^(1/(x-1))$, label-pos: 0.75, label-side: "above-right"),
      note([AV : $x = 1$], (1.15, 4.5), anchor: "west", size: 9pt),
      note([AH : $y = 1$], (2.3, 1.25), anchor: "south", size: 9pt),
    )
  ]
]

// ── 6. Proof ln(2) > 1/2  using riemann-sum ──────────────────────────────────
#demo[6 · Proof $ln(2) > 1/2$ — `riemann-sum` ($n = 1$, right) + `fill-area`][
  #align(center)[
    #plot(
      xmin: 0, xmax: 9, ymin: 0, ymax: 1.3,
      width: 10, height: 4.5,
      axis-x-pos: "bottom", axis-y-pos: "left",
      xlabel: $x$,
      xtick: (1, 2, 4, 8), ytick: (0.5, 1.0),
      show-origin: false,
      // blue area = ln(2)
      fill-area(x => 1.0 / x, baseline: 0.0, domain: (1.0, 2.0),
                color: blue.lighten(75%)),
      // right Riemann sum n=1: rectangle [1,2] of height f(2)=1/2 (outline)
      riemann-sum(x => 1.0 / x, domain: (1.0, 2.0), n: 1, method: "right",
                  color: none, stroke: luma(70) + 0.8pt),
      (fn: x => 1.0 / x, domain: (0.35, 8.8), stroke: blue + 1.4pt, samples: 120,
       label: $y = 1/x$, label-pos: 0.08, label-side: "above-right"),
      vline(4.0, stroke: stroke(paint: luma(150), thickness: 0.5pt, dash: "dotted")),
      vline(8.0, stroke: stroke(paint: luma(150), thickness: 0.5pt, dash: "dotted")),
      note($ln 2$, (1.5, 0.2), anchor: "center", size: 9pt),
      note($1/2$,  (2.12, 0.48), anchor: "west", size: 8pt),
    )
  ]
]

// ── 7. Hatched + solid layers (tkz-fct style) ────────────────────────────────
#demo[7 · Hatched regions + curves (tkz-fct style integral illustration)][
  #align(center)[
    #plot(
      xmin: -0.5, xmax: 5, ymin: -0.5, ymax: 4.5,
      width: 11, height: 5.5,
      axis-x-pos: "center", axis-y-pos: 0,
      xtick: (1, 2, 3, 4), ytick: (1, 2, 3, 4),
      // hatched area between x and x² on [0,1]
      area-between(x => x, x => x * x, domain: (0.0, 1.0),
                   hatch: "ne", hatch-spacing: 4pt,
                   hatch-stroke: green.darken(20%) + 0.5pt),
      // hatched area between x² and 0 on [1,2]
      fill-area(x => x * x, domain: (1.0, 2.0),
                hatch: "nw", hatch-spacing: 4pt,
                hatch-stroke: red.darken(10%) + 0.5pt),
      (fn: x => x, domain: (0.0, 4.5), stroke: green.darken(20%) + 1.2pt,
       label: $y = x$, label-pos: 0.9, label-side: "below-right"),
      (fn: x => x * x, domain: (-0.3, 2.1), stroke: red.darken(10%) + 1.2pt,
       label: $y = x^2$, label-pos: 0.95, label-side: "left"),
      (vline: 1.0, stroke: stroke(paint: luma(130), thickness: 0.5pt, dash: "dotted")),
      (vline: 2.0, stroke: stroke(paint: luma(130), thickness: 0.5pt, dash: "dotted")),
    )
  ]
]

// ── 8. Riemann sums gallery ──────────────────────────────────────────────────
#demo[8 · `riemann-sum` — left, right, midpoint methods][
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.5em,
    ..for (meth, label-txt) in (
      ("left",  [Left (lower for $f$ incr.)]),
      ("right", [Right (upper for $f$ incr.)]),
      ("mid",   [Midpoint]),
    ) {(
      align(center)[
        #text(8pt, strong(label-txt))
        #v(0.2em)
        #plot(
          xmin: 0, xmax: 5, ymin: 0, ymax: 4,
          width: 4.8, height: 3.2,
          xlabel: none, ylabel: none,
          axis-x-pos: "bottom", axis-y-pos: "left",
          xtick: (1, 2, 3, 4), ytick: (1, 2, 3),
          show-origin: false,
          riemann-sum(x => calc.sqrt(x) + 0.3, domain: (0.5, 4.5), n: 4, method: meth,
                      color: blue.lighten(75%), stroke: blue.darken(20%) + 0.6pt),
          (fn: x => calc.sqrt(x) + 0.3, domain: (0.2, 4.8), stroke: blue + 1.2pt, samples: 80),
        )
      ],
    )}
  )
]

// ── 9. Riemann sum for decreasing function (upper/lower bounds) ───────────────
#demo[9 · Upper and lower Riemann sums for $1/x$ on $[1, 4]$][
  #grid(columns: (1fr, 1fr), gutter: 1em,
    align(center)[
      #text(8pt, strong[Left sum (upper bound, $f$ decreasing)])
      #v(0.2em)
      #plot(
        xmin: 0, xmax: 4.5, ymin: 0, ymax: 1.4,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xlabel: $x$, show-origin: false,
        xtick: (1, 2, 3, 4), ytick: (0.5, 1.0),
        fill-area(x => 1.0 / x, baseline: 0.0, domain: (1.0, 4.0),
                  color: blue.lighten(75%)),
        riemann-sum(x => 1.0 / x, domain: (1.0, 4.0), n: 6, method: "left",
                    color: none, stroke: luma(70) + 0.6pt),
        (fn: x => 1.0 / x, domain: (0.4, 4.4), stroke: blue + 1.3pt, samples: 100,
         label: $1/x$, label-pos: 0.1, label-side: "above-right"),
      )
    ],
    align(center)[
      #text(8pt, strong[Right sum (lower bound, $f$ decreasing)])
      #v(0.2em)
      #plot(
        xmin: 0, xmax: 4.5, ymin: 0, ymax: 1.4,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xlabel: $x$, show-origin: false,
        xtick: (1, 2, 3, 4), ytick: (0.5, 1.0),
        fill-area(x => 1.0 / x, baseline: 0.0, domain: (1.0, 4.0),
                  color: blue.lighten(75%)),
        riemann-sum(x => 1.0 / x, domain: (1.0, 4.0), n: 6, method: "right",
                    color: none, stroke: luma(70) + 0.6pt),
        (fn: x => 1.0 / x, domain: (0.4, 4.4), stroke: blue + 1.3pt, samples: 100,
         label: $1/x$, label-pos: 0.1, label-side: "above-right"),
      )
    ],
  )
]

// ── 10. Hatched Riemann sums ──────────────────────────────────────────────────
#demo[10 · Hatched Riemann sum over a solid `fill-area`][
  #align(center)[
    #plot(
      xmin: -0.3, xmax: 7, ymin: -1.5, ymax: 1.5,
      width: 12, height: 5,
      axis-x-pos: "center", axis-y-pos: 0,
      xtick: (1, 2, 3, 4, 5, 6), ytick: (-1, 1),
      fill-area(x => calc.sin(x), domain: (0.0, calc.pi), color: blue.lighten(85%)),
      riemann-sum(x => calc.sin(x), domain: (0.0, calc.pi), n: 6, method: "mid",
                  color: none, hatch: "ne", hatch-spacing: 4pt,
                  hatch-stroke: blue + 0.5pt, stroke: blue.darken(20%) + 0.5pt),
      (fn: x => calc.sin(x), domain: (-0.2, 6.8), stroke: blue + 1.3pt,
       label: $sin(x)$, label-pos: 0.13, label-side: "above-left"),
    )
  ]
]
