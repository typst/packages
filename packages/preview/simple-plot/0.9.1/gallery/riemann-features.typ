//
// riemann-features.typ — Gallery showcasing all riemann-sum annotation features
//
#import "@preview/simple-plot:0.9.1": plot, riemann-sum

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

= simple-plot — Riemann Sum Feature Gallery

// ── 1. Five methods side by side ─────────────────────────────────────────────
#demo[1 · All five methods — `"left"`, `"right"`, `"mid"`, `"lower"`, `"upper"`][
  #grid(columns: (1fr,) * 5, gutter: 0.4em,
    ..for (meth, col) in (
      ("left",  blue),
      ("right", red),
      ("mid",   green.darken(20%)),
      ("lower", purple),
      ("upper", rgb("#e06000")),
    ) {(
      align(center)[
        #text(8pt, weight: "bold", raw("\"" + meth + "\""))
        #v(0.2em)
        #plot(
          xmin: 0, xmax: 3.3, ymin: 0, ymax: 2.3,
          width: 2.8, height: 2.7,
          xlabel: none, ylabel: none,
          axis-x-pos: "bottom", axis-y-pos: "left",
          xtick: (1, 2, 3), ytick: (1, 2),
          show-origin: false,
          riemann-sum(x => calc.sqrt(x) + 0.1, domain: (0.2, 3.0), n: 5,
                      method: meth,
                      color: col.lighten(75%), stroke: col.darken(10%) + 0.6pt),
          (fn: x => calc.sqrt(x) + 0.1, domain: (0.0, 3.2),
           stroke: col + 1.2pt, samples: 80),
        )
      ],
    )}
  )
]

// ── 2. show-points + show-dx + show-xi all at once ───────────────────────────
#demo[2 · Full annotation: `show-points`, `show-dx`, `show-xi` together][
  #align(center)[
    #plot(
      xmin: -0.2, xmax: 3.5, ymin: 0, ymax: 9.8,
      width: 11, height: 6.5,
      axis-x-pos: "bottom", axis-y-pos: "left",
      xlabel: $x$, ylabel: $y$,
      xtick: (1, 2, 3), ytick: (2, 4, 6, 8),
      show-origin: false,
      riemann-sum(
        x => x * x,
        domain: (0.0, 3.0),
        n: 6,
        method: "right",
        color: blue.lighten(80%),
        stroke: blue.darken(10%) + 0.6pt,
        show-points: true,
        point-color: rgb("#c94a00"),
        point-size: 0.07,
        point-label: none,
        show-dx: true,
        dx-rect: 2,
        dx-label: $Delta x$,
        show-xi: true,
      ),
      (fn: x => x * x, domain: (0.0, 3.1), stroke: blue + 1.5pt,
       label: $f(x) = x^2$, label-pos: 1.0, label-side: "left"),
    )
  ]
]

// ── 3. show-xi with xi-show-values ───────────────────────────────────────────
#demo[3 · `show-xi: true` + `xi-show-values: true` — numeric subdivision labels][
  #grid(columns: (1fr, 1fr), gutter: 1.5em,
    align(center)[
      _`xi-show-values: false` (default) — symbolic $x_0, x_1, dots$_
      #v(0.3em)
      #plot(
        xmin: -0.2, xmax: 4.4, ymin: 0, ymax: 2.5,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xtick: (1, 2, 3, 4), ytick: (1, 2),
        show-origin: false,
        riemann-sum(x => calc.sqrt(x), domain: (0.0, 4.0), n: 4, method: "left",
                    color: luma(225), stroke: luma(80) + 0.6pt,
                    show-xi: true, xi-show-values: false),
        (fn: x => calc.sqrt(x), domain: (0.0, 4.3), stroke: blue + 1.3pt, samples: 80),
      )
    ],
    align(center)[
      _`xi-show-values: true` — actual $x$ values shown_
      #v(0.3em)
      #plot(
        xmin: -0.2, xmax: 4.4, ymin: 0, ymax: 2.5,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xtick: (1, 2, 3, 4), ytick: (1, 2),
        show-origin: false,
        riemann-sum(x => calc.sqrt(x), domain: (0.0, 4.0), n: 4, method: "left",
                    color: luma(225), stroke: luma(80) + 0.6pt,
                    show-xi: true, xi-show-values: true),
        (fn: x => calc.sqrt(x), domain: (0.0, 4.3), stroke: blue + 1.3pt, samples: 80),
      )
    ],
  )
]

// ── 4. show-dx bracket detail ────────────────────────────────────────────────
#demo[4 · `show-dx` — $Delta x$ dimension bracket, `dx-rect` selects the rectangle][
  #grid(columns: (1fr, 1fr), gutter: 1.5em,
    align(center)[
      _`dx-rect: auto` (middle rectangle)_
      #v(0.3em)
      #plot(
        xmin: -0.2, xmax: 3.5, ymin: 0, ymax: 2.5,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xtick: (1, 2, 3), ytick: (1, 2),
        show-origin: false,
        riemann-sum(x => calc.sqrt(x + 0.5), domain: (0.0, 3.0), n: 6, method: "mid",
                    color: green.lighten(80%), stroke: green.darken(20%) + 0.6pt,
                    show-dx: true),
        (fn: x => calc.sqrt(x + 0.5), domain: (0.0, 3.2), stroke: green.darken(20%) + 1.3pt),
      )
    ],
    align(center)[
      _`dx-rect: 0` (first rectangle), custom `dx-label`_
      #v(0.3em)
      #plot(
        xmin: -0.2, xmax: 3.5, ymin: 0, ymax: 2.5,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xtick: (1, 2, 3), ytick: (1, 2),
        show-origin: false,
        riemann-sum(x => calc.sqrt(x + 0.5), domain: (0.0, 3.0), n: 6, method: "mid",
                    color: green.lighten(80%), stroke: green.darken(20%) + 0.6pt,
                    show-dx: true, dx-rect: 0, dx-label: $h$),
        (fn: x => calc.sqrt(x + 0.5), domain: (0.0, 3.2), stroke: green.darken(20%) + 1.3pt),
      )
    ],
  )
]

// ── 5. show-points with custom label ────────────────────────────────────────
#demo[5 · `show-points` — evaluation dots; `point-label` and `point-label-pos`][
  #grid(columns: (1fr, 1fr), gutter: 1.5em,
    align(center)[
      _`point-label: auto` — auto arrow label_
      #v(0.3em)
      #plot(
        xmin: -0.2, xmax: 3.7, ymin: 0, ymax: 2.4,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xtick: (1, 2, 3), ytick: (1, 2),
        show-origin: false,
        riemann-sum(x => calc.sqrt(x + 0.2), domain: (0.2, 3.2), n: 4, method: "mid",
                    color: luma(225), stroke: luma(80) + 0.5pt,
                    show-points: true),
        (fn: x => calc.sqrt(x + 0.2), domain: (0.0, 3.5), stroke: blue + 1.3pt),
      )
    ],
    align(center)[
      _`point-label: none` — dots only, no label_
      #v(0.3em)
      #plot(
        xmin: -0.2, xmax: 3.7, ymin: 0, ymax: 2.4,
        width: 7, height: 4,
        axis-x-pos: "bottom", axis-y-pos: "left",
        xtick: (1, 2, 3), ytick: (1, 2),
        show-origin: false,
        riemann-sum(x => calc.sqrt(x + 0.2), domain: (0.2, 3.2), n: 4, method: "mid",
                    color: luma(225), stroke: luma(80) + 0.5pt,
                    show-points: true, point-label: none,
                    point-color: red, point-size: 0.10),
        (fn: x => calc.sqrt(x + 0.2), domain: (0.0, 3.5), stroke: red + 1.3pt),
      )
    ],
  )
]

// ── 6. Hatch controls ────────────────────────────────────────────────────────
#demo[6 · Hatch controls: `hatch-spacing` and `hatch-stroke` on Riemann rectangles][
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.5em,
    ..for (spacing, label-txt) in ((3pt, "3pt"), (5pt, "5pt (default)"), (9pt, "9pt")) {(
      align(center)[
        #text(8pt, raw("hatch-spacing: " + label-txt))
        #v(0.2em)
        #plot(
          xmin: -0.2, xmax: 3.5, ymin: 0, ymax: 2.2,
          width: 4.8, height: 3.3,
          xlabel: none, ylabel: none,
          axis-x-pos: "bottom", axis-y-pos: "left",
          xtick: (1, 2, 3), ytick: (1, 2),
          show-origin: false,
          riemann-sum(x => calc.sqrt(x), domain: (0.0, 3.0), n: 6, method: "right",
                      color: none, hatch: "ne",
                      hatch-spacing: spacing,
                      hatch-stroke: blue + 0.6pt,
                      stroke: blue.darken(20%) + 0.7pt),
          (fn: x => calc.sqrt(x), domain: (0.0, 3.2), stroke: blue + 1.3pt),
        )
      ],
    )}
  )
]

// ── 7. "lower" / "upper" for U-shaped function ───────────────────────────────
#demo[7 · `"lower"` and `"upper"` — true inf/sup on each subinterval; works for U-curves][
  #grid(columns: (1fr, 1fr), gutter: 1.5em,
    align(center)[
      _`"lower"` — true minimum on each subinterval_
      #v(0.3em)
      #plot(
        xmin: -2.4, xmax: 2.4, ymin: -0.3, ymax: 4.6,
        width: 7, height: 4.5,
        axis-x-pos: "center", axis-y-pos: "center",
        xtick: (-2, -1, 1, 2), ytick: (1, 2, 3, 4),
        riemann-sum(x => x * x, domain: (-2.0, 2.0), n: 8, method: "lower",
                    color: blue.lighten(80%), stroke: blue.darken(10%) + 0.6pt, samples: 30),
        (fn: x => x * x, domain: (-2.1, 2.1), stroke: blue + 1.3pt,
         label: $x^2$, label-pos: 0.1, label-side: "right"),
      )
    ],
    align(center)[
      _`"upper"` — true maximum on each subinterval_
      #v(0.3em)
      #plot(
        xmin: -2.4, xmax: 2.4, ymin: -0.3, ymax: 4.6,
        width: 7, height: 4.5,
        axis-x-pos: "center", axis-y-pos: "center",
        xtick: (-2, -1, 1, 2), ytick: (1, 2, 3, 4),
        riemann-sum(x => x * x, domain: (-2.0, 2.0), n: 8, method: "upper",
                    color: red.lighten(80%), stroke: red.darken(10%) + 0.6pt, samples: 30),
        (fn: x => x * x, domain: (-2.1, 2.1), stroke: red + 1.3pt,
         label: $x^2$, label-pos: 0.1, label-side: "right"),
      )
    ],
  )
]

// ── 8. Pedagogical: proof illustration ───────────────────────────────────────
#demo[8 · Pedagogical: right-sum approximation of $integral_0^pi sin(x) dif x$][
  #align(center)[
    #plot(
      xmin: -0.2, xmax: calc.pi + 0.4, ymin: 0, ymax: 1.3,
      width: 14, height: 6,
      axis-x-pos: "bottom", axis-y-pos: "left",
      xlabel: $x$,
      show-origin: false,
      xtick: (calc.pi / 2, calc.pi),
      xtick-labels: ($pi/2$, $pi$),
      ytick: (0.5, 1.0),
      riemann-sum(
        x => calc.sin(x),
        domain: (0.0, calc.pi),
        n: 5,
        method: "right",
        color: blue.lighten(80%),
        stroke: blue.darken(10%) + 0.6pt,
        show-points: true, point-label: none,
        show-dx: true, dx-rect: 1, dx-label: $Delta x = pi/5$,
        show-xi: true,
      ),
      (fn: x => calc.sin(x), domain: (-0.1, calc.pi + 0.25),
       stroke: blue + 1.5pt, samples: 100,
       label: $sin(x)$, label-pos: 0.5, label-side: "above"),
    )
  ]
]
