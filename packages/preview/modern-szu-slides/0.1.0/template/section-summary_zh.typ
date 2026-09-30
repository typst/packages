// 示例：总结与展望 (中文)
#import "@preview/modern-szu-slides:0.1.0": *

#let summary-section = [
  = 总结与展望

  == 工作总结

  #block(
    fill: rgb("#f1f8ff"),
    stroke: 0.5pt + rgb("#0366d6"),
    inset: 15pt,
    radius: 6pt,
  )[
    *工作一：理论与框架构建*
    #v(4pt)
    核心方案：构建了端到端自适应表征学习架构与特征聚合网络。
    #v(4pt)
    实验指标：基准评测数据集准确率达到 94.8%，达到业界领先水平。
  ]

  #v(8pt)

  #block(
    fill: rgb("#fff8f4"),
    stroke: 0.5pt + rgb("#d9730d"),
    inset: 15pt,
    radius: 6pt,
  )[
    *工作二：高效轻量化与工程落地*
    #v(4pt)
    核心方案：设计了动态通道剪枝与知识蒸馏策略，压缩模型达 62%。
    #v(4pt)
    实验指标：在边缘嵌入式平台实现 45 FPS 实时低延迟推理。
  ]
]
