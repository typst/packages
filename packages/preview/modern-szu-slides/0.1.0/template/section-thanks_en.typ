// Acknowledgement / closing slide (English)

#import "@preview/touying:0.7.4": slide, config-page, config-store

#import "slide-text.typ": thanks-primary-size, thanks-secondary-size, thanks-primary-fill

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
      #text(size: thanks-primary-size, weight: "bold", fill: thanks-primary-fill)[Thank you for listening!]
      #v(16pt)
      #text(size: thanks-secondary-size)[Questions & Discussion]
    ]
  ]
]
