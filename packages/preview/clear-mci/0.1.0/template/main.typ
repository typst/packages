// 《现代化工》社区 Typst 模板 clear-mci —— 最小可用示例
//
// 编译：typst compile main.typ
// 本示例演示：中英文题名/摘要/关键词、不编号引言、一至三级标题、
// 图片与交叉引用、三线表与表注、自动编号公式、参考文献。
//
// 所有配置项均可省略，默认值即既有排版。需要覆盖时例如：
//   #show: mci.with(
//     body-font: "SimSun",
//     cn-title-font: "SimHei",
//     en-font: "Times New Roman",
//     math-font: "Cambria Math",
//     heading-1-pagebreak: false,
//   )

#import "@preview/clear-mci:0.1.0": *

#show: mci.with()

// ---------------- 中文题名、摘要、关键词 ----------------

#title-cn[示例：介孔 SiO#sub[2] 负载催化剂的制备与表征]

#abstract-cn[
  本文给出《现代化工》投稿稿件的最小结构示例，用于演示中文模板的题名、
  摘要、关键词、分级标题、图表、公式与参考文献等基本要素的自动排版与编号。
  示例内容仅作占位，不代表真实研究结论。
]

#keyword-cn[示例\;介孔材料\;催化氧化\;Typst 模板]

#pagebreak()

// ---------------- 英文题名、摘要、关键词 ----------------

#title-en[
  Example: Preparation and Characterization of Mesoporous SiO#sub[2]-Supported Catalysts
]

#abstract-en[
  This minimal example demonstrates the structure of a manuscript prepared with the
  community Typst template for Modern Chemical Industry, including title, abstract,
  keywords, sectioned headings, figures, tables, equations, and references. The content
  is illustrative only.
]

#keyword-en[
  example; mesoporous material; catalytic oxidation; Typst template
]

#pagebreak()

// ---------------- 正文 ----------------

// 引言使用一级标题样式但不编号：由此处声明 numbering: none 实现，
// 模板不匹配任何具体章节名称。
#heading(level: 1, numbering: none)[引言]

这是不编号的一级标题（引言）示例。含氯挥发性有机物的催化氧化是环境催化领域的
研究方向之一@duan2023@sun2016，介孔载体负载金属催化剂的相关研究也有报道@su2022@he2016。
本文仅演示排版结构，后续编号标题分别对应一、二、三级。

= 实验部分

== 催化剂制备

=== 样品合成

本小节演示三级编号标题。此处仅作占位说明。

= 结果与讨论

== 物相与结构

@fig-xrd 为示例图片的自动编号与交叉引用。

#figure(
  image("images/XRD.png", width: 80%),
  caption: [示例图片：广角 XRD 图谱],
) <fig-xrd>

样品的孔结构参数汇总于@tab-bet。

#figure(
  table(
    columns: (1.5fr, 1.5fr, 1fr),
    table.hline(stroke: 0.8pt),
    table.header(
      [样品],
      [$S_("BET")$/(m#super[2]·g#super[-1])],
      [$D_p$/nm],
    ),
    table.hline(stroke: 0.4pt),
    [样品 A], [603.4], [5.90],
    [样品 B], [966.0], [2.61],
    table.hline(stroke: 0.8pt),
  ),
  caption: [示例三线表：两种样品的比表面积与孔径],
) <tab-bet>

#table-note[
  $S_("BET")$：BET 比表面积；$D_p$：平均孔径。
]

转化率按@eq-conv 计算。

$ X = (overline(A_0) - overline(A_T)) / overline(A_0) times 100% $ <eq-conv>

#pagebreak()

#bibliography(
  "references.bib",
  style: "modern-chemical-industry-custom.csl",
  title: [参考文献],
)
