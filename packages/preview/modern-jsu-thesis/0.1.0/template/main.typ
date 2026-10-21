/*

该模板用于江苏大学本科毕业论文（非官方，只是按照学校给出的word模板复刻，存在不被认可的风险）。GitHub仓库：https://github.com/han0126/modern-jsu-thesis

注意事项：
如要使用img、tbl等图标、公式样式，需引用下述代码：
`
#import "@preview/modern-jsu-thesis:0.1.0": *
`

*/
#import "@preview/modern-jsu-thesis:0.1.0": *
#import "@preview/modern-jsu-thesis:0.1.0": template as jsu-thesis

#show: jsu-thesis.with(
  zh-title: "中文论文题目",
  zh-keywords: ("关键词1", "关键词2", "关键词3"),
  zh-abstract: [
    摘要是论文的内容不加注释和评论的简短陈述。
  ],

  en-title: "English Title",
  en-keywords: ("Keyword 1", "Keyword 2", "Keyword 3"),
  en-abstract: [
    This is the English abstract.
  ],

  college: [XX学院],   // 学院名称
  class: [XX班],          // 班级
  author: [XX],               // 姓名
  number: [XXXX],             // 学号
  instructor: [XX],           // 指导教师姓名
  post: [XX],                 // 指导教师职称
  year: [20XX],
  month: [X],
)

#heading(numbering: none)[引言]

= 绪论

在此撰写绪论内容。

= 正文（使用示例）

== 这是二级标题

=== 这是三级标题

正文内容。

== 插入图片

#img(
  image("figures/logo.png", width: 40%),
  caption: [江苏大学logo],
)

=== 插入表格

#tbl(
  table(
    columns: (1fr, 1fr),
    align: center + horizon,
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header()[*示例*][*示例*],
    table.hline(stroke: 0.8pt),
    [示例], [示例],
    [示例], [示例],
    table.hline(stroke: 1.5pt),
  ),
  caption: [三线表样例],
)

=== 公式

#equation(
  $
    max {F({t_1},{t_2})} = sum^3_(i=1) sum^5_(j=1) T(i,j) dot x_(i j)
  $
)

=== 参考文献

这是一段文本#cite(<ref1>)

= 结论

在此撰写结论。

#heading(numbering: none)[参考文献]

#bibliography("refs.bib", style: "gb-7714-2015-numeric", title: none)

#heading(numbering: none)[致谢]

在此撰写致谢（可选）。

#heading(numbering: none)[附录]

附录（可选）主要包括一些不宜放在正文中的支撑材料。
