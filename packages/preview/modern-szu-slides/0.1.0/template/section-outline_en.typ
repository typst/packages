// Outline / Table of Contents (English)

#import "@preview/touying:0.7.4": slide

#import "slide-functions.typ": outline-item, no-break
#import "slide-text.typ": cover-accent, outline-heading-size, outline-rule

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
                [Section One],
                [*Background and Motivation*],
              )
            ],
            [
              #outline-item(
                [02],
                [Section Two],
                [*Core Methodology and Design*],
              )
            ],
            [
              #outline-item(
                [03],
                [Section Three],
                [*Experiments and Analysis*],
              )
            ],
            [
              #outline-item(
                [04],
                [Summary],
                [*Conclusion and Future Work*],
              )
            ],
          )
        ],
      )
    ]
  ]
]
