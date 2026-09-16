// Thanks / Q&A Slide (English)
#import "@preview/modern-szu-slides:0.1.0": *

#let thanks-section = [
  #slide(
    config: config-page(
      header: none,
      footer: none,
      margin: 0em,
    ) + config-store(
      header-right: none,
      footer-right: none,
      footer-progress: false,
    ),
  )[
    #align(center + horizon)[
      #text(size: thanks-primary-size, weight: "bold", fill: thanks-primary-fill)[Thank You!]
      #v(16pt)
      #text(size: thanks-secondary-size)[Questions & Comments Welcome]
    ]
  ]
]
