#import "@local/modern-fzu-thesis:0.1.0": documentclass

// 你首先应该安装 https://github.com/zenor0/modern-fzu-thesis/tree/main/fonts/ 里的所有字体，
// 如果是 Web App 上编辑，你应该手动上传这些字体文件，否则不能正常使用「楷体」和「仿宋」，导致显示错误。
#let place-sign(align: center + horizon, dx: 0pt, dy: 0pt, ..args, body) = {
  sym.zws
  place(align, dx: dx, dy: dy, ..args)[#box(body)]
}

#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
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
) = documentclass(
  // doctype: "bachelor",  // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为本科生 bachelor
  // degree: "academic",  // "academic" | "professional", 学位类型，默认为学术型 academic
  // anonymous: true,  // 盲审模式
  // twoside: true, // 双面模式，会加入空白页，便于打印, Not working, redundant paging number will appear yet.
  // 你会发现 Typst 有许多警告，这是因为 modern-nju-thesis 加入了很多不必要的 fallback 字体
  // 你可以自定义字体消除警告，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  // fonts: (楷体: (name: "Times New Roman", covers: "latin-in-cjk"), "FZKai-Z03S")),
  info: (
    title: ("基于DALI协议的", "照明控制系统"),
    title-en: "My Title in English",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    author-en: "Ming Xing",
    department: "某学院",
    department-en: "School of Chemistry and Chemical Engineering",
    major: "某专业",
    major-en: "Chemistry",
    // 你可以使用模板提供的 place-sign 函数来放置电子签名，例如：
    // supervisor: place-sign(dy: 6pt)[#image("images/sign.png", height: 1.5cm)],
    // supervisor: "李四",
    // supervisor-ii: "王五",
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
// 可以指定 title 参数来设置封面标题, 默认为本科生毕业设计(论文)
// #cover(title: "基于DALI协议的照明控制系统")
#cover()

// 诚信承诺书
// 同样的，你可以使用模板提供的 place-sign 函数来放置电子签名，例如：
#decl-page(
  student-sign: place-sign(align: horizon, dx: -15pt, dy: 3pt)[#image("images/sign.png", height: 1.5cm)],
  teacher-sign: place-sign(align: horizon, dx: -15pt, dy: 3pt)[#image("images/sign.png", height: 1.5cm)],
)


// 前言
#show: preface

// 中文摘要
#abstract(keywords: ("我", "就", "测试用", "关键词"))[
  随着人民生活水平的提高和光源的发展，人们对照明的要求越来越高，要求利用灯光营造和谐的气氛、舒适的环境，创造一种动态的效果，以及操作上的简便，这样人们对照明的要求越来越高，传统的建筑照明受到了时代的强烈冲击。同时，由于能源有限，建设“节约型社会”的观念得到了人们的认同。据有关资料统计，目前世界上总发电量的25%用于照明，并且社会对照明智能化和绿色化的要求也越加迫切。

  智能照明控制系统，就是根据某一区域的功能、时段，室内光亮度或该区域的用途，用计算机技术和通讯技术及数字调光技术相结合，使照明系统自动化。智能照明系统的种类有许多种，目前发展与推广速度较快的技术，就是本文所介绍的基于DALI（Digital Addressable Lighting Interface）协议的智能照明技术。



]

// 英文摘要
#abstract-en(keywords: ("Dummy", "Keywords", "Here", "It Is"))[
  With the improvement of people’s living standard and the development of lighting equipment, the demand for advanced lighting is also escalating. This happens for many reasons, for example, people pursue an atmosphere of harmony, a comfortable living environment and the creation of dynamic effect by using lamplight. As a result of the expanded demand, traditional architecture illumination has suffered a blow. Meanwhile, because of the limited energy, the conception of Thrift Society is widely recognized. According to related statistics, a quarter of the world’s total electricity generation is used for lighting. On the part of the society, the demand for green lighting and intelligent lighting is also becoming increasingly urgent

  For a particular region, in conformity with it’s function, the period of time, it’s indoor brightness and it’s purpose of use, the intelligent lighting control system can automatize the lighting system with the integrated technologies of computer, communication and digital light regulation. The sorts of the intelligent lighting system can be various, and the technology introduced in this paper, which is based on DALI, is currently developing and promoting rapidly.

  ……

]


// 目录
#outline-page()

// 插图目录
// #list-of-figures()

// 表格目录
// #list-of-tables()

// 正文
#show: mainmatter

// 符号表
// #notation[
//   / DFT: 密度泛函理论 (Density functional theory)
//   / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
// ]

= 使用指南

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

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:nju-logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

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
  image("images/fzu_logo.svg", width: 20%),
  caption: [图片测试],
) <nju-logo>


== 数学公式

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由 @eqt:ratio，我们有：

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

你也可以使用 @lst:typst-code 引入第三方模块来支持更丰富的代码块显示

#import "@preview/zebraw:0.5.4": zebraw
#show: zebraw

#figure(
  ```typst
  #import "@preview/zebraw:0.5.4": zebraw
  #show: zebraw
  ```,
  caption: [第三方模块代码],
) <typst-code>

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption: [zebraw渲染的代码块],
) <zebraw-code>

你也可以使用 @lst:lovelace 来显示算法伪代码

#figure(
  ```typst
  #import "@preview/lovelace:0.3.0": *
  ```,
  caption: [算法伪代码模块 lovelace],
) <lovelace>

#import "@preview/lovelace:0.3.0": *

#figure(
  kind: "algorithm",
  supplement: [算法],

  pseudocode-list(booktabs: true, numbered-title: [我的算法])[
    + do something
    + do something else
    + *while* still something to do
      + do even more
      + *if* not done yet *then*
        + wait a bit
        + resume working
      + *else*
        + go home
      + *end*
    + *end*
  ],
) <cool>

See @cool for details on how to do something cool.
= 正文预览

== 正文子标题

光注入建筑予生命，色彩渗透空间予运动。这是一个光的世界，是一个运动的世界。随着人民生活水平的提高和光源的发展，人们对照明的要求越来越高，除普遍要求的节能以外，还要求利用灯光营造和谐的气氛、舒适的环境，创造一种动态的效果，以及操作上的简便，这样人们对照明的要求越来越高，传统的建筑照明受到了时代的强烈冲击。智能照明应运而生。并迅速地向前发展，以致形成照明发展又一个重要趋势。


== 正文子标题

随着国家经济的不断快速发展，人们生活水平的不断提高，照明在人们日常生活以及工作中的作用也显得越发重要。据有关资料统计，目前世界上总发电量的25%用于照明，并且社会对照明智能化和绿色化的要求也越加迫切。例如在大型建筑物、商厦、音乐厅、博物馆、大学、演播室、会议厅等应用场合，对照明控制的智能化、绿色化和节能等都提出了较高的要求。

随着国家经济的不断快速发展，人们生活水平的不断提高，照明在人们日常生活以及工作中的作用也显得越发重要。据有关资料统计，目前世界上总发电量的25%用于照明，并且社会对照明智能化和绿色化的要求也越加迫切。例如在大型建筑物、商厦、音乐厅、博物馆、大学、演播室、会议厅等应用场合，对照明控制的智能化、绿色化和节能等都提出了较高的要求。

随着国家经济的不断快速发展，人们生活水平的不断提高，照明在人们日常生活以及工作中的作用也显得越发重要。据有关资料统计，目前世界上总发电量的25%用于照明，并且社会对照明智能化和绿色化的要求也越加迫切。例如在大型建筑物、商厦、音乐厅、博物馆、大学、演播室、会议厅等应用场合，对照明控制的智能化、绿色化和节能等都提出了较高的要求。

照明可分为天然照明和人工照明两大类。天然照明（比如阳光）受自然条件的限制，不能根据人们的要求保持、随时随地可用、明暗可调、光线稳定的采光。在夜晚或天然光线不足的地方，需要采用人工照明。人工照明主要用电光源来实现。


=== 正文子子标题

正文内容


= 结论
<no-numbering>

使用 `<no-numbering>` 标签可以取消标题编号。

// 手动分页
#if twoside {
  pagebreak() + " "
}

// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
#bilingual-bibliography(full: true)

// 致谢
#acknowledgement[
  本模板基于南京大学学位论文 #link("https://github.com/nju-lug/modern-nju-thesis")[modern-nju-thesis] 魔改。

  感谢模板原作者 #link("https://github.com/Orangex4")[OrangeX4], 感谢 typst 项目组，感谢 typst 中文社区。感谢 NJU-LUG，感谢 NJUThesis LaTeX 模板。
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

#figure(
  image("images/fzu_logo.svg", width: 20%),
  caption: [图片测试],
) <appendix-img>
