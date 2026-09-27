// 致谢页 (中文)
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
      #text(size: thanks-primary-size, weight: "bold", fill: thanks-primary-fill)[感谢各位老师聆听！]
      #v(16pt)
      #text(size: thanks-secondary-size)[敬请各位专家批评指正]
    ]
  ]
]
