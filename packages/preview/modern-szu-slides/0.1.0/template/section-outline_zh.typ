// 大纲 / 目录 (中文)

#import "@preview/touying:0.6.1": slide

#import "slide-functions.typ": outline-item, no-break
#import "slide-text.typ": cover-accent, outline-heading-size, outline-rule

#let outline-section = [
  #slide[
    #pad(top: -1em)[
      #stack(
        dir: ttb,
        spacing: 0.8em,
        [
          #text(size: outline-heading-size, weight: "bold", fill: cover-accent)[大纲]
          #line(length: 100%, stroke: 1.4pt + outline-rule)
        ],
        [
          #stack(
            dir: ttb,
            spacing: 0.55em,
            [
              #outline-item(
                [01],
                [第一部分],
                [*研究背景与动机*],
              )
            ],
            [
              #outline-item(
                [02],
                [第二部分],
                [*核心方法与架构*],
              )
            ],
            [
              #outline-item(
                [03],
                [第三部分],
                [*实验评估与分析*],
              )
            ],
            [
              #outline-item(
                [04],
                [总结展望],
                [*工作总结与未来规划*],
              )
            ],
          )
        ],
      )
    ]
  ]
]
