#import "@preview/tntt:0.1.0": define-config

#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
  appendix,
  // 页面函数
  fonts-display,
  cover,
  copy,
  abstract,
  abstract-en,
  outline-config,
  figure-list,
  table-list,
  notation,
  bilingual-bibliography,
  ack,
  decl,
  achv,
) = define-config(
  doctype: "bachelor", // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为本科生 bachelor
  degree: "academic", // "academic" | "professional", 学位类型，默认为学术型 academic
  anonymous: false, // 盲审模式
  twoside: true, // 双面模式，会加入空白页，便于打印
  info: (
    title: ("基于 Typst 的", "清华大学学位论文"),
    title-en: "My Title in English",
    author: "张三",
    author-en: "Ming Xing",
    department: "某某系",
    department-en: "School of Chemistry and Chemical Engineering",
    major: "某某专业",
    major-en: "Chemistry",
    supervisor: ("李四", "教授"),
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
#fonts-display()

// 封面页
#cover()

// 授权页
#copy()

// 前言
#show: preface

// 中文摘要
#abstract(keywords: ("关键词1", "Keyword2", "关键词3"))[
  本文制作了清华大学本科学位论文 Typst 模板，规定了论文各部分内容格式与样式，详细介绍了模板的使用和制作方法，以帮助本科生进行学位论文写作，降低编辑论文格式的不规范性和额外工作量。
]

// 英文摘要
#abstract-en(keywords: ("Keyword1", "关键词2", "Keyword3"))[
  This article creates a Tsinghua University undergraduate thesis Typst template, which stipulates formats and styles of each section and details usage and creation of template, with the purpose of supporting undergraduate students writing thesis, reducing non-standardization and additional workload in editing thesis format.
]

// 目录
#outline-config()

// 插图目录
#figure-list()

// 表格目录
#table-list()

// 正文
#show: mainmatter

// 符号表
#notation[
  / DFT: 密度泛函理论 (Density functional theory)
  / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
]

= 导　论

== 列表

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

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

#align(
  center,
  (
    stack(dir: ltr)[
      #figure(
        table(
          align: center + horizon,
          columns: 4,
          [t], [1], [2], [3],
          [y], [0.3s], [0.4s], [0.8s],
        ),
        caption: [常规表],
      ) <timing>
    ][
      #h(50pt)
    ][
      #figure(
        table(
          columns: 4,
          stroke: none,
          table.hline(),
          [t], [1], [2], [3],
          table.hline(stroke: .5pt),
          [y], [0.3s], [0.4s], [0.8s],
          table.hline(),
        ),
        caption: [三线表],
      ) <timing-tlt>
    ]
  ),
)

#figure(
  image("media/logo.jpg", width: 50%),
  caption: [图片测试],
) <logo>


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

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption: [代码块],
) <code>

= 正　文

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

// 致谢
#ack[

]

// 声明页
#decl()

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

#figure(
  image("media/logo.jpg", width: 20%),
  caption: [图片测试],
) <appendix-img>

// 成果页
#achv[
  在课题研究中获得的成果，如申请的专利或已正式发表和已有正式录用函的论文等。没有相关内容请删除本章节。
]
