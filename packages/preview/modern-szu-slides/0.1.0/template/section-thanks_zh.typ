// 致谢页 (中文)

#import "@preview/touying:0.6.1": slide, config-page, config-store

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
      #text(size: thanks-primary-size, weight: "bold", fill: thanks-primary-fill)[感谢各位老师聆听！]
      #v(16pt)
      #text(size: thanks-secondary-size)[敬请各位专家批评指正]
    ]
  ]
]
