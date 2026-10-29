#import "@preview/slides-nudt:0.1.0": *

// Edit the cover fields here; theme.typ stays reusable.
#show: use-theme.with(
  title: [Attention Is All You Need],
  subtitle: [Transformer 架构与注意力机制],
  author: [汇报人：姓名],
  date: [汇报日期],
  institution: [单位 / 学院 / 实验室],
)

#title-slide()
#toc-slide()

= 研究动机

== 从循环网络到注意力

机器翻译等序列任务通常需要建模长距离依赖。循环神经网络按序处理 token，难以充分并行；卷积模型也需要多层传播信息。

本文提出 Transformer：以注意力机制为核心建立序列表示，不使用循环或卷积结构，并行处理序列中的位置。

*核心问题*：能否只依靠注意力机制完成序列到序列的建模？

== 模型结构

#table(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  stroke: none,
  [*编码器*], [*解码器*],
  [堆叠相同的层；每层包含多头自注意力和前馈网络。],
  [使用掩码自注意力，并通过编码器-解码器注意力读取源序列表示。],
)

#v(0.4em)

每个子层使用残差连接与层归一化。位置编码注入序列顺序信息，使模型在没有循环结构时仍能区分 token 位置。

== 缩放点积注意力

给定查询 $Q$、键 $K$ 和值 $V$，注意力计算为：

#align(center)[
  #text(size: 1.25em)[$"Attention"(Q, K, V) = "softmax"(Q K^T / sqrt(d_k)) V$]
]

- $Q K^T$ 衡量查询与各键之间的匹配程度。
- 除以 $sqrt(d_k)$ 用于控制点积随维度增大而变大的幅度。
- Softmax 得到权重，再对值向量加权求和。

== 多头注意力

模型将表示投影到多个子空间并行计算注意力，再拼接结果并投影回模型维度。不同注意力头可以关注不同位置和关系。

#compact-code(
  "head_i = Attention(Q W_i^Q, K W_i^K, V W_i^V)\nMultiHead(Q, K, V) = Concat(head_1, ..., head_h) W^O",
  height: 5.5em,
)

== 实验与讨论

论文在 WMT 机器翻译任务上评估模型，报告了有竞争力的翻译质量和较短的训练时间。实验支持了并行注意力架构在序列建模任务上的有效性。

*主要贡献*
- 用自注意力替代循环和卷积，提升训练并行度。
- 通过多头机制联合关注不同表示子空间。
- 提供了简洁、可扩展的编码器-解码器架构。

*讨论问题*：注意力计算在序列长度上包含两两交互，长序列会带来较高的时间和显存开销。后续工作可从稀疏注意力、分块计算等方向改进。

= 总结

== Takeaways

1. Transformer 将注意力作为序列建模的核心组件。
2. 多头注意力、位置编码、残差连接和前馈层共同构成模型基础。
3. 该架构成为后续大规模预训练语言模型的重要基础。

#v(0.5em)

参考文献：Vaswani et al., *Attention Is All You Need*, NeurIPS 2017。

#end-slide[
  #align(center)[
    #text(size: 1.4em, weight: "bold")[谢谢]
    #v(0.7em)
    #text(size: 0.9em)[欢迎讨论]
  ]
]
