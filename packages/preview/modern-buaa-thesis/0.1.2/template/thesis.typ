#import "@preview/modern-buaa-thesis:0.1.2": abstract, abstract-en, thesis

#let abstract-zh-text = [
  #show: abstract.with(keyword: ("关键词 1", "关键词 2"))

  这是我们的中文摘要
]

#let abstract-en-text = [
  #show: abstract-en.with(keyword: ("Keyword 1", "Keyword 2"))

  This is our English abstract.
]

#show: thesis.with(
  title: (zh: "博士生毕业论文的题目", en: "A Title for PhD Thesis"),
  author: (zh: "张三", en: "San Zhang"),
  teacher: (zh: "李四", en: "Si Li"),
  teacher-degree: (zh: "教授", en: "Prof."),
  college: (zh: "计算机学院", en: "School of Computer Science and Engineering"),
  major: (
    discipline: "计算机体系结构",
    direction: "模型分布式训练",
    discipline-first: "计算机科学与技术",
    discipline-direction: "计算机体系结构",
  ),
  date: (
    start: "2021年09月01日",
    end: "2026年06月30日",
    summit: "2026年06月10日",
    defense: "2026年06月10日",
  ),
  lib-number: "TP317",
  stu-id: "BY2406100",
  abstract: abstract-en-text,
  abstract-en: abstract-zh-text,
  bibliography: bibliography.with("ref.bib"),
  achievement: [
    在国际会议上发表了多篇论文，
    参与了多个开源项目的开发，
  ],
  acknowledgements: [
    感谢我的导师李四教授的指导和支持

    感谢我的家人和朋友的鼓励和帮助
  ],
  cv: [
    2021年09月 - 2026年06月：北京航空航天大学，计算机科学与技术专业，博士研究生

    2017年09月 - 2021年06月：北京航空航天大学，计算机科学与技术专业
  ],
)

= 绪论

== 什么是 Typst？

Typst 是一种现代的文档排版语言，旨在简化文档的编写和排版过程。它结合了编程的灵活性和传统排版的美观，使得用户可以轻松创建高质量的文档。

== 为什么使用 Typst？

使用 Typst 的原因包括：

1、简洁的语法：Typst 的语法设计简洁明了，易于学习和使用。

2、强大的功能：Typst 提供了丰富的功能，如数学公式支持、图形绘制、表格处理等，能够满足各种文档需求。

3、可扩展性：Typst 支持自定义函数和模块，使得用户可以根据自己的需求扩展功能。

#pagebreak()

= 支持的文档元素

== 图片引用

如@fig:logo 所示，我们在文档中插入一个图片，并为其添加了一个标题。

#figure(
  image("logo.png", width: 30%),
  caption: "这是一个北航的Logo",
) <fig:logo>

== 表格引用

如@tab:three-line 所示，我们在文档中插入一个三线表格，并为其添加了一个标题。

#figure(
  table(
    stroke: none,
    columns: (1fr, 1fr, 1fr, 1fr),
    align: center,
    table.hline(),
    table.header([*标题1*], [*标题2*], [*标题3*], [*标题4*]),
    table.hline(stroke: 0.5pt),
    [内容1], [内容1], [内容1], [内容1],
    [内容2], [内容2], [内容2], [内容2],
    [内容3], [内容3], [内容3], [内容3],
    [内容4], [内容4], [内容4], [内容4],
    table.hline(),
  ),
  caption: "这是一个三线表",
) <tab:three-line>

== 数学公式

这是一个行内公式：$E = m c^2$

这是一个行间公式：@mc2：

$ E = m c^2 $ <mc2>

== 文献引用

让我们引用两个文献吧 @heDeepResidualLearning2016 @vaswaniAttentionAllYou2023！

#pagebreak()
