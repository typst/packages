// 示例：主要研究工作 (中文)

#import "slide-functions.typ": card, conclusion-card, small-title

#let placeholder = "assets/szu-logo-gold.svg"

#let work-section = [
  = 主要工作

  == 方案总体设计

  在此详细阐述主要方案的设计理念与系统架构流程。

  #align(center)[
    #image(placeholder, width: 40%)
    #text(size: 12pt)[图 1: 总体方案架构示意图（可替换为实际图片）]
  ]

  #pagebreak()

  == 核心技术与算法

  #card(
    [核心模块设计],
    [
      + 模块一：动态特征自适应对齐与增强模块
      + 模块二：多尺度注意力分层聚合网络
      + 模块三：基于对比学习的目标正则化约束
    ],
    fill: rgb("#fff8f4"),
  )

  #pagebreak()

  == 实验评估与结果

  #small-title[实验效果对比]

  #conclusion-card(
    [实验结论],
    [本文方法在标准基准数据集上取得了领先性能，相较基线方法推理延迟降低 15%，准确率提升 4.2%。],
  )
]
