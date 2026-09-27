// 示例：主要研究工作 (中文)
#import "@preview/modern-szu-slides:0.1.0": *

#let work-section = [
  = 主要工作

  == 方案总体设计

  在此详细阐述主要方案的设计理念与系统架构流程。

  #align(center)[
    #rect(
      width: 70%,
      height: 100pt,
      fill: rgb("#fcf7f8"),
      stroke: 1pt + rgb("#a20040").lighten(60%),
      radius: 6pt,
    )[
      #align(center + horizon)[
        #text(size: 13pt, fill: rgb("#a20040"))[📊 系统架构流程图（可替换为实际图片）]
      ]
    ]
    #v(0.3em)
    #text(size: 11pt, fill: gray.darken(20%))[图 1: 总体方案架构示意图]
  ]

  #pagebreak()

  == 实验评估与对比

  展示核心实验指标及与基线方法的对比结果：

  #align(center)[
    #table(
      columns: (1.5fr, 1fr, 1fr, 1.2fr),
      align: center + horizon,
      stroke: (x, y) => if y == 0 { (bottom: 1.2pt + rgb("#a20040")) } else { (bottom: 0.5pt + luma(220)) },
      fill: (x, y) => if y == 0 { rgb("#fbf7f8") } else { none },
      table.header([*方法 (Method)*], [*准确率 (%)*], [*F1-Score*], [*推断时延 (ms)*]),
      [Baseline A], [88.4], [0.86], [45.2],
      [Baseline B], [91.2], [0.89], [38.7],
      [*本文方法 (Ours)*], [*95.6*], [*0.94*], [*22.1*],
    )
  ]
]
