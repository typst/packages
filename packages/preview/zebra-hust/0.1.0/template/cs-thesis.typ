#import "@preview/zebra-hust:0.1.0": report, references, appendix, img

#show: report.with(
  preset: "cs-thesis",
  cover: (
    title: [基于 Typst 的论文排版研究],
    class: [计算机科学与技术 2201 班],
    student-id: [U2022xxxxx],
    name: [张三],
    teacher: [李四],
    report-date: [2026年6月],
  ),
  front-matter: (
    abstract-zh: [本文以论文排版为例，展示模板的章节、图表、参考文献和附录功能。],
    keywords-zh: ("论文排版", "Typst"),
    abstract-en: [This example demonstrates thesis typesetting with automatic headings, figures, tables, and references.],
    keywords-en: ("typesetting", "Typst"),
  ),
)

= 绪论

本章介绍研究背景。相关研究见 @zhang2020。

== 研究背景

正文标题不手写编号，由模板自动生成。

#img(path("images/go.png"), width: 25%, caption: [示例图片])

#figure(
  table(columns: 2, [项目], [结果], [示例], [通过]),
  caption: [示例结果],
) <results>

= 实验与分析

新章从新的一页开始，图表序号在章内重新计数。

#img(path("images/go.png"), width: 25%, caption: [第二章示例图片])

== 实验结果

实验数据如 @results 所示。

=== 讨论

这里填写讨论内容。

#pagebreak()
#heading(level: 1, numbering: none)[致谢]

感谢指导教师和同学在研究过程中给予的帮助。

#references(source: path("references.bib"))

#appendix(title: [补充材料])[
  == 编译与检查

  + 使用 `typst compile cs-thesis.typ cs-thesis.pdf` 编译。
  + 检查中英文摘要、目录和正文页码。
  + 检查第二章的图号是否从 `2-1` 开始，以及跨章表格引用是否正确。
]
