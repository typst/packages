// The starter content in this template file is additionally available under
// MIT No Attribution. See LICENSE-MIT-0.txt and README.md for details.

#import "@preview/simply-ysu-touying:0.2.0": *

#show: ysu-theme.with(
  aspect-ratio: "16-9",
  // Short chapter labels of the footer navigation.
  nav-labels: ("背景", "方法", "总结"),
  config-info(
    title: [燕山大学 Touying 演示模板],
    author: [张三],
    supervisor: [李四#h(1em)教授],
    subject: [学科专业],
    school: [学院名称],
    date: datetime.today(),
    stage: [学术汇报],
    stage-en: [Academic Presentation],
  ),
)

#title-slide()

#outline-slide()

= 研究背景
#chapter-opener(
  question: [本章要回答的#hl[核心问题]是什么？],
  keywords: ([关键词一], [关键词二]),
)

== 1.1 研究背景
#takeaway[用一句话写出本页结论，它会成为页眉主标题]

- 一级标题 `= 章名` 生成章节扉页，二级标题 `== 页名` 生成内容页。
- `#takeaway[...]` 设置结论句，`#sub[...]` 设置面包屑中的小节。
- 用 `#hl[...]` 标出关键术语，用 `#key[...]` 标出本页唯一的关键结论。

= 研究方法

== 2.1 方法概述
#takeaway[分组框、块箭头与结论条组织“问题—方法—结论”]

#grid(
  columns: (1fr, auto, 1fr),
  column-gutter: 0.25cm,
  align: horizon,
  group-box(label: [问题], red: true)[
    #sub-box[问题一：……]
    #sub-box[问题二：……]
  ],
  block-arrow[方法],
  group-box(label: [方法])[
    #sub-box[方法一：……]
    #sub-box[方法二：……]
  ],
)
#v(0.3cm)
#conclude(label: [结论])[本章提出的方法解决了#hl[……]问题]

= 总结

== 3.1 主要结论

#points(rule: true, [结论一：……], [结论二：……], [结论三：……])

#ending-slide()
