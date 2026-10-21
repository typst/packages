// Outline / Agenda (English)
#import "@preview/modern-szu-slides:0.1.0": *

#let outline-section = [
  #slide[
    #pad(top: -1em)[
      #stack(
        dir: ttb,
        spacing: 0.8em,
        [
          #text(size: outline-heading-size, weight: "bold", fill: cover-accent)[Outline]
          #line(length: 100%, stroke: 1.4pt + outline-rule)
        ],
        [
          #stack(
            dir: ttb,
            spacing: 0.55em,
            [
              #outline-item(
                [01],
                [Part I],
                [*Background & Motivation*],
              )
            ],
            [
              #outline-item(
                [02],
                [Part II],
                [*Methodology & Architecture*],
              )
            ],
            [
              #outline-item(
                [03],
                [Part III],
                [*Experiments & Results*],
              )
            ],
            [
              #outline-item(
                [04],
                [Part IV],
                [*Conclusion & Future Work*],
              )
            ],
          )
        ],
      )
    ]
  ]
]
