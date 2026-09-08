//
// revolution.typ — Gallery for volume-of-revolution feature in simple-plot
//
#import "@preview/simple-plot:0.9.1": volume-of-revolution

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

= simple-plot — Volume of revolution gallery

// ── 1. Canonical: sqrt(x) ────────────────────────────────────────────────────
#demo[1 · $f(x) = sqrt(x)$ on $[0, 4]$ — default look][
  #align(center)[
    #volume-of-revolution(
      x => calc.sqrt(x),
      domain: (0.0, 4.0),
      n-disks: 4,
      width: 8.0, height: 4.0,
      label-f: $f(x) = sqrt(x)$,
    )
  ]
]

// ── 2. Cylinder — constant function ──────────────────────────────────────────
#demo[2 · $f(x) = 2$ on $[0, 3]$ — cylinder][
  #align(center)[
    #volume-of-revolution(
      x => 2.0,
      domain: (0.0, 3.0),
      n-disks: 3,
      width: 7.0, height: 3.5,
      label-f: $f(x) = 2$,
      disk-color: blue.lighten(80%),
      disk-stroke: blue.darken(20%) + 0.6pt,
      profile-stroke: blue + 1.5pt,
    )
  ]
]

// ── 3. Cone — linear function ─────────────────────────────────────────────────
#demo[3 · $f(x) = x$ on $[0, 3]$ — cone][
  #align(center)[
    #volume-of-revolution(
      x => x,
      domain: (0.01, 3.0),
      n-disks: 4,
      width: 7.0, height: 4.0,
      label-a: $0$,
      label-f: $f(x) = x$,
      disk-color: red.lighten(80%),
      disk-stroke: red.darken(20%) + 0.6pt,
      profile-stroke: red + 1.5pt,
    )
  ]
]

// ── 4. Sphere — semi-circle profile ──────────────────────────────────────────
#demo[4 · $f(x) = sqrt(4 - x^2)$ on $[-2, 2]$ — sphere][
  #align(center)[
    #volume-of-revolution(
      x => calc.sqrt(calc.max(0.0, 4.0 - x * x)),
      domain: (-1.99, 1.99),
      n-disks: 5,
      width: 8.0, height: 4.0,
      label-a: $-2$, label-b: $2$,
      label-f: $f$,
      disk-color: green.lighten(80%),
      disk-stroke: green.darken(20%) + 0.6pt,
      profile-stroke: green.darken(20%) + 1.5pt,
    )
  ]
]

// ── 5. Exponential — flared solid ─────────────────────────────────────────────
#demo[5 · $f(x) = e^(x\/2)$ on $[0, 2]$ — flared solid][
  #align(center)[
    #volume-of-revolution(
      x => calc.exp(x / 2.0),
      domain: (0.0, 2.0),
      n-disks: 4,
      width: 7.0, height: 4.0,
      label-f: $e^(x\/2)$,
      disk-color: rgb("#fff0d0"),
      disk-stroke: rgb("#c06000") + 0.7pt,
      profile-stroke: rgb("#c06000") + 1.5pt,
    )
  ]
]

// ── 6. Radius marker feature ─────────────────────────────────────────────────
#demo[6 · `show-radius-marker: true` — radius dimension][
  #grid(columns: (1fr, 1fr), gutter: 1em,
    align(center)[
      _radius at $x = a$ (default)_
      #v(0.3em)
      #volume-of-revolution(
        x => calc.sqrt(x),
        domain: (1.0, 4.0),
        n-disks: 3,
        width: 7.0, height: 3.5,
        show-back: false,
        show-radius-marker: true,
        label-a: $1$,
        label-f: $sqrt(x)$,
        label-y: $y$,
      )
    ],
    align(center)[
      _radius at interior point $x = 2$_
      #v(0.3em)
      #volume-of-revolution(
        x => calc.sqrt(x),
        domain: (0.0, 4.0),
        n-disks: 3,
        width: 7.0, height: 3.5,
        show-back: false,
        show-radius-marker: true,
        yaxis-x: 2.0,
        label-f: $sqrt(x)$,
        label-y: $sqrt(2)$,
      )
    ],
  )
]

// ── 7. Effect of n-disks ──────────────────────────────────────────────────────
#demo[7 · Effect of `n-disks` — `show-back: false` for a clean comparison][
  #grid(columns: (1fr, 1fr, 1fr), gutter: 1em,
    ..for n in (2, 5, 10) {(
      align(center)[
        #text(8pt, raw("n-disks: " + str(n)))
        #v(0.2em)
        #volume-of-revolution(
          x => calc.sqrt(x + 1.0),
          domain: (0.0, 3.0),
          n-disks: n,
          width: 4.5, height: 2.2,
          show-back: false,
          show-labels: false,
        )
      ],
    )}
  )
]

// ── 8. Full 3D vs front-only (`show-back`) ───────────────────────────────────
#demo[8 · `show-back: true` (default) vs `show-back: false` — same solid][
  #grid(columns: (1fr, 1fr), gutter: 1.5em,
    align(center)[
      _`show-back: true` — full 3D perspective_
      #v(0.3em)
      #volume-of-revolution(
        x => 1.5 + 0.5 * calc.cos(calc.pi * x),
        domain: (0.0, 2.0),
        n-disks: 5,
        width: 7.0, height: 3.5,
        show-back: true,
        disk-color: purple.lighten(80%),
        disk-stroke: purple.darken(20%) + 0.6pt,
        profile-stroke: purple + 1.5pt,
      )
    ],
    align(center)[
      _`show-back: false` — front half only_
      #v(0.3em)
      #volume-of-revolution(
        x => 1.5 + 0.5 * calc.cos(calc.pi * x),
        domain: (0.0, 2.0),
        n-disks: 5,
        width: 7.0, height: 3.5,
        show-back: false,
        disk-color: purple.lighten(80%),
        disk-stroke: purple.darken(20%) + 0.6pt,
        profile-stroke: purple + 1.5pt,
      )
    ],
  )
]

// ── 9. axis-y — revolution around y = c ──────────────────────────────────────
#demo[9 · `axis-y: 1` — revolution around $y = 1$][
  #grid(columns: (1fr, 1fr), gutter: 1.5em,
    align(center)[
      _$f(x) = 1 + sqrt(x)$ around $y = 1$_
      #v(0.3em)
      #volume-of-revolution(
        x => 1.0 + calc.sqrt(x),
        domain: (0.0, 4.0),
        axis-y: 1.0,
        n-disks: 4,
        width: 7.0, height: 3.5,
        label-a: $0$, label-b: $4$,
        label-f: $1 + sqrt(x)$,
      )
    ],
    align(center)[
      _$f(x) = x + 1$ around $y = 1$ (cone)_
      #v(0.3em)
      #volume-of-revolution(
        x => x + 1.0,
        domain: (0.01, 3.0),
        axis-y: 1.0,
        n-disks: 4,
        width: 7.0, height: 3.5,
        label-a: $0$, label-b: $3$,
        label-f: $x + 1$,
        disk-color: rgb("#e8eaf6"),
        disk-stroke: rgb("#3949ab") + 0.6pt,
        profile-stroke: rgb("#3949ab") + 1.5pt,
      )
    ],
  )
]

// ── 10. axis-slope — revolution around oblique axis ───────────────────────────
#demo[10 · `axis-slope: 1` — revolution around $y = x$][
  #grid(columns: (1fr, 1fr), gutter: 1.5em,
    align(center)[
      _$f(x) = 2x$ around $y = x$ — cone_
      #v(0.3em)
      #volume-of-revolution(
        x => 2.0 * x,
        domain: (0.01, 2.0),
        axis-slope: 1.0,
        n-disks: 4,
        width: 7.0, height: 4.0,
        label-a: $0$, label-b: $2$,
        label-f: $2x$,
        disk-color: rgb("#fce4ec"),
        disk-stroke: rgb("#c62828") + 0.6pt,
        profile-stroke: rgb("#c62828") + 1.5pt,
      )
    ],
    align(center)[
      _$f(x) = x^2$ around $y = x$ — pinched at $x = 1$_
      #v(0.3em)
      #volume-of-revolution(
        x => x * x,
        domain: (0.01, 2.0),
        axis-slope: 1.0,
        n-disks: 4,
        width: 7.0, height: 4.0,
        label-a: $0$, label-b: $2$,
        label-f: $x^2$,
        disk-color: rgb("#e8f5e9"),
        disk-stroke: rgb("#2e7d32") + 0.6pt,
        profile-stroke: rgb("#2e7d32") + 1.5pt,
      )
    ],
  )
]
