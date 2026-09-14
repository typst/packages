#import "@preview/modern-bnu-thesis:0.0.2": documentclass, indent

// 你首先应该安装 https://github.com/nju-lug/modern-nju-thesis/tree/main/fonts/FangZheng 里的所有字体，
// 如果是 Web App 上编辑，你应该手动上传这些字体文件，否则不能正常使用「楷体」和「仿宋」，导致显示错误。

#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
  // mainmatter-end,
  appendix,
  // 页面函数
  fonts-display-page,
  cover,
  decl-page,
  abstract,
  abstract-en,
  bilingual-bibliography,
  outline-page,
  list-of-figures,
  list-of-tables,
  notation,
  acknowledgement,
  achievement,
) = documentclass(
  // doctype: "bachelor",  // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为本科生 bachelor
  // degree: "academic",  // "academic" | "professional", 学位类型，默认为学术型 academic
  // anonymous: true,  // 盲审模式
  twoside: false, // 双面模式，会加入空白页，便于打印
  // 可自定义字体，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")),
  info: (
    title: ("基于 Typst 的北京师范大学学位论文模板", ""),
    title-en: "AN INTRODUCTION TO TYPST THESIS TEMPLATE OF
    BEIJING NORMAL UNIVERSITY",
    grade: "20XX",
    student-id: "2021108xxxx",
    author: "张　三",
    author-en: "Ming Xing",
    department: "某学院",
    department-en: "School of Airtifi",
    major: "某专业",
    major-en: "Chemistry",
    supervisor: ("李　四", "教　授", "人工智能学院"),
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

// 封面页
#cover()

// 声明页
#decl-page()


// 前言
#show: preface



// 中文摘要
#abstract(keywords: ("我", "就是", "测试用", "关键词"))[
  摘要是学位论文的内容不加注释和评论的简要陈述。摘要应具有独立性和自含性，即不阅读论文的全文，就能获得必要的信息。摘要一般应说明研究工作的目的、方法、结果和结论等，应突出论文的创新点。
  
  博士学位论文的摘要一般 2000 字左右，硕士学位论文的摘要一般1000 字左右。摘要中应尽量避免采用图、表、化学结构式、非公知公用的符号和术语。英文摘要的内容应与中文摘要相对应。
  
  关键词是为了便于文献索引和检索工作，从学位论文中选取出来用以表示全文主题内容信息的单词或术语。每篇论文选取 3 － 8 个关键词，每个关键词之间用逗号间隔，另起一行，排在摘要内容下方。
]

// 英文摘要
#abstract-en(
  keywords: ("Dummy", "Keywords", "Here", "It Is"),
)[
  #set par(first-line-indent: 2em)
  An abstract is a brief statement of the content of a thesis without annotations or comments. The abstract should be
  independent and self-contained, meaning that neces- sary information can be obtained without reading the full text of
  the paper. The abstract should generally explain the purpose, methods, results, and conclusions of the research work,
  and highlight the innovative points of the paper.
  
  The abstract for a doctoral thesis is generally around 2000 words, while the abstract for a master’s thesis is generally
  around 1000 words. The use of diagrams, tables, chem- ical structural formulas, symbols and terminology that are not
  commonly used should be avoided as much as possible in the abstract. The content of the English abstract should
  correspond to the Chinese abstract.
  
  Keyword is a word or term selected from a thesis to represent the topic information of the entire text for the
  convenience of literature indexing and retrieval work. Select 3-8 keywords for each paper, separated by commas, and
  start a new line below the abstract content.
]


// 目录
#outline-page()

// 插图目录
#list-of-figures()

// 表格目录
#list-of-tables()

// 正文
#show: mainmatter

// 符号表
// #notation[
//   / DFT: 密度泛函理论 (Density functional theory)
//   / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
// ]

#include "./chapters/ch1.typ"

#include "./chapters/ch2.typ"





= 导 论


== 列 表

=== 无序列表

- 无序列表项一
- 无序列表项二
  - 无序子列表项一
  - 无序子列表项二

=== 有序列表

+ 有序列表项一
+ 有序列表项二
  + 有序子列表项一
  + 有序子列表项二

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
      ), caption: [三线表]) <timing-tlt>
    ]
  ),
)

#figure(image("images/bnu-emblem.svg", width: 20%), caption: [图片测试]) <nju-logo>


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

可以像这样引用参考文献：图书#[@蒋有绪1998]和会议#[@中国力学学会1990]。

== 代码块

代码块支持语法高亮。引用时需要加上 `lst:` @lst:code

#figure(```py
  def add(x, y):
    return x + y
  ```, caption: [代码块]) <code>


= 正 文

== 正文子标题

=== 正文子子标题

正文内容


// 手动分页
#if twoside {
  pagebreak() + " "
}

// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
#bilingual-bibliography(full: true)



#achievement(
  papers: (
    "Yang Y, Ren T L, Zhang L T, et al. Miniature microphone with silicon-based fer-
    roelectric thin films[J]. Integrated Ferroelectrics, 2003, 52:229-235.",
    "杨轶, 张宁欣, 任天令, 等. 硅基铁电微声学器件中薄膜残余应力的研究[J]. 中国机械工程, 2005, 16(14):1289-1291.",
    "杨轶, 张宁欣, 任天令, 等. 集成铁电器件中的关键工艺研究[J]. 仪器仪表学报, 2003, 24(S4):192-193.",
    "Yang Y, Ren T L, Zhu Y P, et al. PMUTs for handwriting recognition. In press[J]. (已被Integrated Ferroelectrics录用)",
  ),
  patents: (
    "任天令, 杨轶, 朱一平, 等. 硅基铁电微声学传感器畴极化区域控制和电极连接的方法: 中国, CN1602118A[P]. 2005-03-30.",
    "Ren T L, Yang Y, Zhu Y P, et al. Piezoelectric micro acoustic sensor based on ferroelectric materials: USA, No.11/215, 102[P]. (美国发明专利申请号.)"
  ),
)

// 致谢
#acknowledgement[
  感谢 NJU-LUG 的 modern-nju-thesis，感谢 Thesis Template of Beijing Normal University in LaTeX 模板。
]

// 手动分页
#if twoside {
  pagebreak() + " "
}


// 附录
#show: appendix

= 附录

== 附录子标题

=== 附录子子标题

附录内容，这里也可以加入图片，例如@fig:appendix-img。

#figure(image("images/bnu-emblem.svg", width: 20%), caption: [图片测试]) <appendix-img>


// 正文结束标志，不可缺少
// 这里放在附录后面，使得页码能正确计数
// #mainmatter-end()