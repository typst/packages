// 建议在正式编辑论文时，采用 typst.app 中的已发布版本模板
#import "@preview/modern-sysu-thesis:0.3.0": bachelor as thesis

// 仅供开发调试使用
// #import "lib.typ": bachelor as thesis
#import thesis: abstract, acknowledgement, appendix

// 你首先应该安装 https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/tree/main/fonts 里的所有字体，
// 如果是 Web App 上编辑，你应该手动上传这些字体文件，否则不能正常使用「楷体」和「仿宋」，导致显示错误。

#show: thesis.doc.with(
  // 毕业论文基本信息
  thesis-info: (
    // 论文标题，将展示在封面、扉页与页眉上
    // 多行标题请使用数组传入 `("thesis title", "with part next line")`，或使用换行符：`"thesis title\nwith part next line"`
    title: ("基于 Typst 的", "中山大学学位论文模板"),
    title-en: "A Typst Template for SYSU thesis",

    // 论文作者信息：学号、姓名、院系、专业、指导老师
    author: (
      sno: "1xxxxxxx",
      name: "张三",
      grade: "2024",
      department: "某学院",
      major: "某专业",
    ),

    // 指导老师信息，以`("name", "title")` 数组方式传入
    supervisor: ("李四", "教授"),

    // 提交日期，默认为论文 PDF 生成日期
    submit-date: datetime.today(),
  ),

  // 参考文献来源
  bibliography: bibliography.with("ref.bib"),

  // 控制页面是否渲染
  pages: (
    // 封面可能由学院统一打印提供，因此可以不渲染
    cover: true,

    // 附录部分为可选。设置为 true 后，会在参考文献部分与致谢部分之间插入附录部分。
    appendix: true,
  ),

  // 论文内文各大部分的标题用“一、二…… （或1、2……）”， 次级标题为“（一）、（二）……（或
  // 1.1、2.1……）”，三级标题用“1、2……（或1.1.1、2.1.1……）”，四级标题用“（1）、（2）……
  //（或1.1.1.1、2.1.1.1……）”，不再使用五级以下标题。两类标题不要混编。
  // numbering: "一",

  // 双面模式，会加入空白页，便于打印
  twoside: false,
)

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

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:sysu-logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

#align(center, (stack(dir: ltr)[
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
]))

#figure(
  image("images/sysu_logo.svg", width: 20%),
  caption: [图片测试],
) <sysu-logo>


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
  caption:[代码块],
) <code>


= 正　文

== 正文子标题

=== 正文子子标题

正文内容

// 附录
#show: appendix

= 附录

== 附录章节题

=== 附录子标题
==== 附录子子标题

附录内容，这里也可以加入图片，例如@fig:appendix-img。

从正文内容里复制公式，以审查公式编号
$ F_n = floor(1 / sqrt(5) phi.alt^n) $

#figure(
  image("images/sysu_logo.svg", width: 20%),
  caption: [图片测试],
) <appendix-img>

// 致谢
#acknowledgement[
  感谢 NJU-LUG，感谢 NJUThesis LaTeX 模板。
]
