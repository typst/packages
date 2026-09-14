#import "@preview/simple-nwu-year-paper:0.1.0": template

// === 1. 长文本摘要 ===
#let zh-abstract = [
  本文设计并实现了一个基于 Typst 的西北大学学年论文排版系统。针对传统排版工具排版效率低、配置复杂的问题，本模板利用 Typst 的高效编译特性，构建了符合学校规范的学术论文排版流水线。
  通过对封面、摘要、正文以及参考文献生命周期的统一拦截管理，实现了章内图表公式联动编号、全自动目录生成以及跨平台的双轨字体回退机制。实际测试表明，该系统能够显著提升论文撰写效率，保证排版格式的严格合规。
]

#let en-abstract = [
  This paper designs and implements an academic year paper typesetting system for Northwest University based on Typst. Aiming at the problems of low efficiency and complex configuration of traditional typesetting tools, this template utilizes the efficient compilation characteristics of Typst to build a typesetting pipeline that complies with university regulations. Through the unified interception and management of the lifecycles of the cover, abstract, main body, and bibliography, it realizes chapter-independent numbering of figures, tables, and formulas.
]

// === 2. 调用模板 ===
#show: template.with(
  // --- 结构与组件开关 ---
  doc-show-cover: true, // 启用封面
  doc-show-zh-abstract: true, // 启用中文摘要
  doc-show-en-abstract: true, // 启用英文摘要
  doc-show-outline: true, // 启用目录

  // --- 设置字体族 ---
  font-serif: (
    "Times New Roman",
    "Source Han Serif",
    "SimSun",
    "STSong",
  ),
  font-sans: (
    "Arial",
    "Source Han Sans",
    "Microsoft YaHei",
    "SimHei",
  ),

  // --- 文档元数据 ---
  meta-lang: "zh",
  meta-title: [基于 Typst 的西北大学学年论文\ 排版系统设计与实现],
  meta-stu-name: [张三],
  meta-stu-number: "2026000001",
  meta-tch-name: [李四 教授],
  meta-department: [计算机科学与技术学院],
  meta-major: [软件工程],
  meta-grade: "2026级",

  // --- 摘要与关键词 ---
  meta-zh-abstract: zh-abstract,
  meta-zh-keywords: ([Typst 论文], [西北大学], [自动化排版], [开源模板]),

  meta-en-abstract: en-abstract,
  meta-en-keywords: ([Typst Template], [Northwest University], [Typesetting], [Academic Paper]),

  // --- 参考文献路径 ---
  meta-bib-path: "/template/ref.bib",
)


// === 3. 正文测试内容 ===
= 引言 <introduction>
这是你的第一章引言内容。借助于 Typst 强大的实时编译特性，我们可以极其丝滑地进行学术论文的排版工作。

== 研究背景与意义
这是二级标题。在高校中，学年论文与毕业论文的格式审查往往耗费了师生大量的精力。开发一套符合规范的 Typst 模板具有重要的现实意义。

=== 国内外研究现状
这是三级标题。这里是一段长文本测试。 #lorem(200)

= 核心架构设计
这是第二章。用来测试多章节的一级标题，以及图表公式的章内联动编号效果。

== 数学公式重置测试
我们在这里插入一个数学公式，它应该被自动编号为 (2.1)：
$ E = m c^2 $

再来一个行内公式测试 $a^2 + b^2 = c^2$，以及紧接着的块级公式，它应该自动递增为 (2.2)：
$ P(A|B) = (P(B|A) P(A)) / P(B) $

== 图表联动编号测试
测试一张图片的插入与自动编号（预期为：图 2-1）：
#figure(
  image("assets/logo.png", width: 40%),
  caption: [校徽样式测试],
) <nwu-logo>

测试一个表格的插入与自动编号（预期为：表 2-1）：
#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 10pt,
    align: horizon,
    [*项目*], [*传统排版 (Word)*], [*本模板 (Typst)*],
    [编译速度], [慢 / 易卡顿], [毫秒级实时预览],
    [格式合规], [需手动调整，易错], [底层强约束],
    [公式输入], [极其繁琐], [优雅语法],
  ),
  caption: [排版工具性能对比测试表],
) <compare-table>

= 系统实现与测试
这是第三章。在这里我们可以测试交叉引用（References）是否正常。

如@introduction 所述，本系统的核心设计在于自动化。我们可以通过标签轻松引用图表，例如查看@nwu-logo 展现的视觉效果，或者参考@compare-table 中的数据对比。

#lorem(500)
