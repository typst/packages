#import "../utils/style.typ": *

#let glossary-page() = {
  set page(
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm)
  )

  align(center)[
    #text(size: 18pt, weight: "bold", fill: colors.primary)[
      Glossary
    ]
  ]

  v(1cm)

  let glossary-entries = (
    (
      key: "Machine Learning",
      short: "ML",
      long: "A method of data analysis that automates analytical model building."
    ),
    (
      key: "Deep Learning",
      short: "DL",
      long: "A subset of machine learning using neural networks with multiple layers."
    ),
    (
      key: "Neural Network",
      short: "NN",
      long: "A computing system inspired by biological neural networks."
    ),
    (
      key: "Algorithm",
      short: "Algo",
      long: "A procedure or formula for solving a problem."
    )
  )

  for entry in glossary-entries {
    block[
      *#entry.key* (#entry.short): #entry.long
    ]
    v(0.5em)
  }
}
