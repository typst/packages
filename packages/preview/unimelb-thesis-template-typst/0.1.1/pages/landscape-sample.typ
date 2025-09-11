#import "../utils/style.typ": *

#let landscape-sample-page() = {
  set page(
    height: auto,
    width: auto,
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
    flipped: true
  )

  align(center)[
    #text(size: 18pt, weight: "bold", fill: colors.primary)[
      Sample Landscape Page
    ]
  ]

  v(1cm)

  [= Mathematical Equations]

  align(center)[
    $ integral_(-oo)^(+oo) e^(-x^2) dif x = sqrt(pi) $
    v(0.5cm)
    $ lim_(n->oo) (1 + 1/n)^n = e $
    v(0.5cm)
    $ sum_(k=1)^oo 1/k^2 = pi^2/6 $
  ]

  [= Matrix Example]

  align(center)[
    $ A = mat(
      a_11, a_12, a_13;
      a_21, a_22, a_23;
      a_31, a_32, a_33
    ) $
  ]

  [= System of Equations]

  align(center)[
    $ cases(
      2x + y = 5,
      x - y = 1
    ) $
  ]

  set page(
    height: auto,
    width: auto,
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    flipped: false
  )
}
