// 西安电子科技大学硕士学位论文 — 示例论文
//
// 本文件由 `typst init @preview/modern-xdu-thesis` 复制而来，**不需要仓库里的其他文件**。
// 按 `@preview` 引用包（而不是相对路径）是 Typst 模板的硬性要求：
// `typst init` 只复制 template/ 目录，任何 `../` 引用都会越界报错
// `path would escape the project root`。
//
// 字体：本模板不内置字体文件，按「系统字体优先 + 回退链」解析。
// 全篇只需 宋体 / 黑体 / Times New Roman 三种，详见 README「字体要求」。
// Windows 自带 SimSun / SimHei / Times New Roman；macOS 用 Songti SC / Heiti SC。

#import "@preview/modern-xdu-thesis:0.1.0": documentclass

#let (
  doc,
  cover, title-cn, title-en, declaration, abstract, abstract-en,
  list-of-figures, list-of-tables, notation, abbreviations, outline-page,
  mainmatter, appendix, references, acknowledgement, bio, 引用, 索引题注,
) = documentclass(
  degree: "professional",   // "academic" 学术学位 | "professional" 专业学位
  blind: false,             // 盲审模式
  info: (
    // ---- 题目 ----
    title: ("基于深度学习的毫米波大规模 MIMO", "信道估计研究"),
    title-en: ("Deep Learning based Channel Estimation", "for mmWave Massive MIMO Systems"),

    // ---- 作者 ----
    author: "张三",
    author-en: "Zhang San",

    // ---- 学科 / 领域 ----
    // 学术学位用一级学科 + 二级学科；专业学位用领域
    discipline: "电子科学与技术",
    discipline-en: "Electronic Science and Technology",
    subdiscipline: "电磁场与微波技术",
    domain: "人工智能",
    domain-en: "Artificial Intelligence",

    // ---- 学位 ----
    degree-name: "电子信息硕士",
    degree-name-en: "Master of Electronic Information",

    // ---- 导师 ----
    supervisor: ("李四", "教授"),
    supervisor-en: ("Li Si", "Professor"),
    // 企业导师仅专业学位使用；学术学位留 (none, none)
    enterprise-supervisor: ("王五", "高级工程师"),
    enterprise-supervisor-en: ("Wang Wu", "Senior Engineer"),

    // ---- 学院 / 日期 ----
    department: "电子工程学院",
    department-en: "School of Electronic Engineering",
    submit-date: (year: 2025, month: 6),

    // ---- 题名页左上角信息栏 ----
    school-code: "10701",
    clc: "TN82",
    student-id: "21011201234",
    secret-level: "公开",

    // ---- 摘要与关键词 ----
    abstract: [
      摘要是学位论文内容不加注释和评论的简短陈述，应简明扼要地陈述研究的目的、内容、方法、
      成果和结论，重点突出学位论文的创造性成果。本示例用于验证模板排版，实际使用时请替换为
      真实摘要内容。硕士学位论文中文摘要字数一般为 1000 字左右。
    ],
    abstract-en: [
      The Abstract is a brief description of the content of the dissertation without notes or
      comments. It represents concisely the research purpose, content, method, results and
      conclusion of the thesis, with emphasis on the creative achievements. This sample is used
      to verify the template layout; replace it with real content when writing.
    ],
    keywords: ("深度学习", "毫米波", "大规模 MIMO", "信道估计"),
    keywords-en: ("deep learning", "millimeter wave", "massive MIMO", "channel estimation"),

    // ---- 符号对照表 / 缩略语对照表（P3）----
    notation: (
      ("α", "路径损耗指数"), ("λ", "载波波长"),
      ("f_c", "载波频率"), ("T_s", "符号周期"),
    ),
    abbreviations: (
      ("MIMO", "Multiple-Input Multiple-Output", "多输入多输出"),
      ("OFDM", "Orthogonal Frequency Division Multiplexing", "正交频分复用"),
      ("SNR", "Signal-to-Noise Ratio", "信噪比"),
    ),
  ),
)

#show: doc

// ============================================================
// 前置部分（罗马页码；每页从奇数页起）
// ============================================================

#cover()

#pagebreak(to: "odd")
#title-cn()

#pagebreak(to: "odd")
#title-en()

#pagebreak(to: "odd")
#declaration()

#pagebreak(to: "odd")
#counter(page).update(1)
#abstract()

#pagebreak(to: "odd")
#counter(page).update(3)
#abstract-en()

// ============================================================
// 索引类（P3）
// ============================================================

#pagebreak(to: "odd")
#counter(page).update(5)
#list-of-figures()

#pagebreak(to: "odd")
#counter(page).update(7)
#list-of-tables()

#pagebreak(to: "odd")
#counter(page).update(9)
#notation()

#pagebreak(to: "odd")
#counter(page).update(11)
#abbreviations()

#pagebreak(to: "odd")
#counter(page).update(13)
#outline-page()

// ============================================================
// 正文（P4）—— 每章从奇数页起，编号由模板生成，不要手写
// ============================================================

#show: mainmatter.with(header-title: "西安电子科技大学硕士学位论文")

= 第一章 绪论

随着第五代移动通信系统的商用部署，毫米波频段因其丰富的频谱资源而受到广泛关注。
大规模多输入多输出（MIMO）技术通过在基站侧配置大规模天线阵列，能够显著提升频谱效率
与能量效率。然而，毫米波信道的稀疏性与高维度特性使得传统信道估计方法面临导频开销大、
计算复杂度高等挑战。本文围绕基于深度学习的毫米波大规模 MIMO 信道估计展开研究。

== 研究背景与意义

毫米波频段通常指 30 GHz 至 300 GHz 的电磁波频段，其可用带宽远大于传统微波频段。
但毫米波信号穿透能力弱、路径损耗大，需要借助大规模天线阵列的波束成形增益来补偿。

=== 毫米波信道特性

毫米波信道在角域呈现显著的稀疏性，这一特性为压缩感知类信道估计方法提供了理论基础。

==== 路径损耗模型

自由空间路径损耗随频率升高而增大，毫米波频段的路径损耗明显高于微波频段。

== 国内外研究现状

近年来，基于深度学习的信道估计方法得到了广泛研究，主要分为数据驱动与模型驱动两类。

= 第二章 系统模型与问题描述

本章建立毫米波大规模 MIMO 系统的信号模型，并给出信道估计问题的数学描述。

== 系统模型

考虑单基站单用户的毫米波大规模 MIMO 系统，基站配置均匀线性阵列。

#figure(rect(width: 5cm, height: 2.5cm),
  // 索引里显示短题注、正文里显示完整题注（相当于 LaTeX 的 \caption[短]{长}）
  caption: 索引题注([系统框图], [毫米波大规模 MIMO 系统框图]))

== 仿真参数

#figure(table(columns: 3, [参数], [符号], [取值],
    [载波频率], [$f_c$], [28 GHz],
    [带宽], [$B$], [500 MHz]),
  caption: [仿真参数设置])

== 信道估计问题描述

接收信号可表示为

$ bold(y) = bold(A) bold(h) + bold(n) $

其中 $bold(A)$ 为测量矩阵，$bold(h)$ 为待估计的稀疏信道向量。信道估计的目标是从观测
$bold(y)$ 中恢复 $bold(h)$#引用(1)。基于压缩感知的方法利用信道的稀疏性#引用(2, 3)，
在减少导频开销的同时保证估计精度。#引用(3) 指出，当测量矩阵满足有限等距性质时，
可以通过求解凸优化问题精确恢复稀疏信号。

// ============================================================
// 后置部分（P4）
// ============================================================

#pagebreak(to: "odd")
#appendix()

#pagebreak(to: "odd")
#references()

#pagebreak(to: "odd")
#acknowledgement()

#pagebreak(to: "odd")
#bio()
