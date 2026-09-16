#import "@preview/ugm-presentation-unofficial:0.1.0": conf, quote, section, slide, title

#show: doc => conf(
  num: 5,
  doc,
)

#title[
  = Hiya Hiya Hiya
  #lorem(10)
]

#section[
  == Mangtap
  #lorem(10)
]

#slide[
  === Jadi gini
  #grid[
    - ini kiri

      #lorem(40)

      #lorem(40)
  ][
    - ini kanan

      #lorem(20)

      $
        H = mat(
          (partial^2 f) / (partial x_1 partial x_1), (partial^2 f) / (partial x_1 partial x_2), ..., (partial^2 f) / (partial x_1 partial x_n);
          (partial^2 f) / (partial x_2 partial x_1), (partial^2 f) / (partial x_2 partial x_2), ..., (partial^2 f) / (partial x_2 partial x_n);
          ..., ..., ..., ...;
          (partial^2 f) / (partial x_n partial x_1), (partial^2 f) / (partial x_n partial x_2), ..., (partial^2 f) / (partial x_n partial x_n)
        ) = mat(
          a_11, a_12, ..., a_1n;
          a_21, a_22, ..., a_2n;
          ..., ..., ..., ...;
          a_(n 1), a_(n 2), ..., a_(n n)
        )
      $

      #lorem(20)
  ]
]

#quote[
  #text(size: 20pt, [
    #v(2em)
    "Jadi, anunya diiniin, ininya diituin, itunya dianuin"

    -Si anu-
  ])

]
