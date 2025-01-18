#import "@preview/modern-bnu-course-paper:0.1.0": documentclass, indent

// 你首先应该安装 https://github.com/nju-lug/modern-nju-thesis/tree/main/fonts/FangZheng 里的所有字体，
// 如果是 Web App 上编辑，你应该手动上传这些字体文件，否则不能正常使用「楷体」和「仿宋」，导致显示错误。

#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
  mainmatter-end,
  appendix,
  // 页面函数
  fonts-display-page,
  cover,
  abstract,
  bilingual-bibliography,
  outline-page,
  notation,
  acknowledgement,
) = documentclass(
  twoside: false, // 双面模式，会加入空白页，便于打印
  // 可自定义字体，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")),
  info: (
    title: ("基于Typst的北京师范大学课程论文模板", ""),
    title-en: "Beijing Normal University course paper template based on Typst",
    grade: "2024",
    student-id: "202422017xxx",
    author: "张　三",
    author-en: "Zhang San",
    department: "未来设计学院",
    department-en: "School of Airtifi",
    major: "美术与书法",
    major-en: "Art and calligraphy",
    supervisor: ("李　四", "教　授", "未来设计学院"),
    supervisor-en: "Professor My Supervisor",
    // supervisor-ii: ("王五", "副教授"),
    // supervisor-ii-en: "Professor My Supervisor",
    submit-date: datetime.today(),
  ),
  // 参考文献源
  bibliography: bibliography.with("ref.bib"),
)

// 文稿设置
#show: doc

// 字体展示测试页
// #fonts-display-page()

// 中文摘要
#abstract(keywords: ("这里", "就是", "测试用", "关键词"))[
  不加注释和评论的简要陈述就是摘要。摘要应具有独立性和自含性，即不阅读论文的全文，就能获得必要的信息。摘要一般应说明研究工作的目的、方法、结果和结论等，应突出论文的创新点。课程论文的摘要请控制字数，尽可能简介。

  // #indent 关键词是为了便于文献索引和检索工作，从学位论文中选取出来用以表示全文主题内容信息的单词或术语。每篇论文选取 3 － 8 个关键词，每个关键词之间用逗号间隔，另起一行，排在摘要内容下方。
]


// 目录（默认不需要目录）
// #outline-page()

// 正文
#show: mainmatter

= 导 论

== 列 表

=== 无序列表

- 无序列表项一
- 无序列表项二

=== 有序列表

+ 有序列表项一
+ 有序列表项二

=== 术语列表

/ 术语一: 术语解释
/ 术语二: 术语解释

== 图表

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:nju-logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

#align(
  center,
  (
    stack(
      dir: ltr,
    )[
      #figure(table(align: center + horizon, columns: 4, [t], [1], [2], [3], [y], [0.3s], [0.4s], [0.8s]), caption: [常规表]) <timing>
    ][
      #h(50pt)
    ][
      #figure(table(
        columns: 4,
        stroke: none,
        table.hline(),
        [t],
        [1],
        [2],
        [3],
        table.hline(stroke: .5pt),
        [y],
        [0.3s],
        [0.4s],
        [0.8s],
        table.hline(),
      ), caption: [三线表（一般使用）]) <timing-tlt>
    ]
  ),
)

\ 
#figure(image("images/bnu-emblem.svg", width: 50%), caption: [图片测试]) <nju-logo>

#indent 图片（如@fig:nju-logo）、公式、表格后另起一段请使用 `\#indent`

== 数学公式

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

我们也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

== 参考文献

可以像这样引用参考文献：图书#[@蒋有绪1998]和会议@中国力学学会1990。

== 代码块

代码块支持语法高亮。引用时需要加上 `lst:` @lst:code

#figure(```py
  def add(x, y):
    return x + y
  ```, caption: [代码块]) <code>


= 材料与方法

== 数据集

== 实验设计

= 结果

= 讨论
Conclusion and Future Work...

Limitations of the study...


// 手动分页
// #if twoside {
//   pagebreak() + " "
// }

// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式

#bilingual-bibliography(full: true)

// 符号表
// #notation[
//   / DFT: 密度泛函理论 (Density functional theory)
//   / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
// ]

// 致谢
// #acknowledgement[
//   感谢 NJU-LUG，感谢 BNU LaTeX 模板。
// ]



// 正文结束标志，不可缺少
// 这里放在附录后面，使得页码能正确计数
#mainmatter-end()