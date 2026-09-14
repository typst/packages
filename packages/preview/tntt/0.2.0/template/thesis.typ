#import "@preview/tntt:0.2.0": define-config

/// 以下字体配置适用于安装了 Windows 10/11 字体及 Windows 10/11 简体中文字体扩展的设备，
/// 请勿修改 font-family 中定义的键值，一般情况下，其含义为：
/// - SongTi: 宋体，正文字体，通常对应西文中的衬线字体
/// - HeiTi: 黑体，标题字体，通常对应西文中的无衬线字体
/// - KaiTi: 楷体，用于说明性文本和主观性的表达
/// - FangSong: 仿宋，通常用于注释、引文及权威性阐述
/// - Mono: 等宽字体，对于代码，会优先使用此项，推荐中文字体使用黑体或楷体，或者一些流行的中文等宽字体
///
/// 对于 MacOS 用户，可以使用 `Songti SC`、`Heiti SC`、`Kaiti SC`、`Fangsong SC` 和 `Menlo`
///
/// 对于 Linux 用户，可以使用 `Noto Serif CJK`、`Noto Sans CJK`、`Noto Serif Mono CJK` 或
/// `Source Han Serif`、`Source Han Sans`、`Source Han Mono` 或文泉驿字体等
#let font-family = (
  SongTi: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "NSimSun",
  ),
  HeiTi: (
    (name: "Arial", covers: "latin-in-cjk"),
    "SimHei",
  ),
  KaiTi: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "KaiTi",
  ),
  FangSong: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "STFangSong",
  ),
  Mono: (
    (name: "DejaVu Sans Mono", covers: "latin-in-cjk"),
    "SimHei",
  ),
)

#let (
  /// global options
  twoside,
  /// layouts
  meta,
  doc,
  front-matter,
  main-matter,
  back-matter,
  /// pages
  fonts-display,
  cover,
  copyright,
  abstract,
  abstract-en,
  outline-wrapper,
  figure-list,
  table-list,
  notation,
  bilingual-bibliography,
  acknowledge,
  declaration,
  achievement,
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
    submit-date: datetime.today(),
  ),
  // 参考文献源
  bibliography: bibliography.with("ref.bib"),
  // 字体配置
  fonts: font-family,
)

// 文稿设置
#show: meta

// 字体展示测试页，在配置好字体后请注释或删除此项
#fonts-display()

// 封面页
#cover()

/// ----------- ///
/// Doc Layouts ///
/// ----------- ///
#show: doc

// 授权页
#copyright()

/// ------------ ///
/// Front Matter ///
/// ------------ ///
#show: front-matter

// 中文摘要
#abstract(keywords: ("关键词1", "Keyword2", "关键词3"))[
  本文制作了清华大学本科学位论文 Typst 模板，规定了论文各部分内容格式与样式，详细介绍了模板的使用和制作方法，以帮助本科生进行学位论文写作，降低编辑论文格式的不规范性和额外工作量。
]

// 英文摘要
#abstract-en(keywords: ("Keyword1", "关键词2", "Keyword3"))[
  This article creates a Tsinghua University undergraduate thesis Typst template, which stipulates formats and styles of each section and details usage and creation of template, with the purpose of supporting undergraduate students writing thesis, reducing non-standardization and additional workload in editing thesis format.
]

// 目录
#outline-wrapper()

// 插图目录
#figure-list()

// 表格目录
#table-list()

/// ----------- ///
/// Main Matter ///
/// ----------- ///
#show: main-matter

// 符号表
#notation[
  / DFT: 密度泛函理论 (Density functional theory)
  / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
]

= 导　引

== 排印

此部分是对字体配置导引的补充。

本模板目前只对中文做了适配，如果您需要用英文或其他语言撰写论文，请在 `meta` 中设置 `language` 和 `region`，同时需要对部分页面的内置内容进行修改，相关选项请参考提供的注释信息的源码。

原则上，如果您使用英文撰写，也无需涉及到深度的字体配置修改，默认提供的字体配置尊重西文字体，即您的字体配置可以无缝切换到西文排版，具体参考上文提供的内置字族与西文的对应关系。

除了预定义的字族外，文档默认提供了与 Word 相容的中文字号习惯，对于内置的字体选项，除了传入 length 外，可以直接传入中文字号，如：

```typ
#fonts-display(size: "小三")
#fonts-display(size: 15pt)
```

上述的代码可分别设置字体展示页的字号为小三和 15pt，字号的对应关系如下：

#figure(
  table(
    columns: 8,
    [初号], [42pt], [小初], [36pt], [一号], [26pt], [小一], [24pt],
    [二号], [22pt], [小二], [18pt], [三号], [16pt], [小三], [15pt],
    [四号], [14pt], [中四], [13pt], [小四], [12pt], [五号], [10.5pt],
    [小五], [9pt], [六号], [7.5pt], [小六], [6.5pt], [七号], [5.5pt],
    [小七], [5pt],
  ),
  caption: [字号与 pt 对应关系],
)

大部分情况下，您都无需关注内置模板的字体选项，除非您需要使用到一些特殊的字体或字号，或者需要使用到一些特殊的排版效果。

== 结构

*本模板提供的文档结构*可分为四个层次，其涵义如下：

- 封面（cover）
- 前辅文（front matter）：即正文前部分
  - 授权页（copyright）
  - 中文摘要（abstract） ← 前辅文从此页开始计数
  - 英文摘要（abstract-en）
  - 目录（outline-wrapper）
  - 插图目录（figure-list）
  - 表格目录（table-list）
  - 符号表（notation）
- 正文（main matter） ← 正文重新计数
- 后辅文（back matter）：即正文后部分
  - 参考文献（bilingual-bibliography）
  - 致谢页（acknowledge）
  - 声明页（declaration）
  - 附录（appendix）
  - 成果页（achievement）

== 布局

参考模板的结构设计，布局上也拆分为了四个部分，分别为：

- `doc`：文档总体布局
- `front-matter`：前辅文布局
- `main-matter`：正文布局
- `back-matter`：后辅文布局

除此之外，还有一个额外的 `meta` 用于控制文档元信息，其中包含了*基础的文本设置*（语言、区域和字体回滚开关）和*页面设置*，同时也包含了 *PDF 的元信息*（标题、作者等）。

得益于 typst 的设计，可以在封面后使用 `doc` 来控制封面后所有内容的布局，其中主要为*段落设置*（两端对齐、行距、段距等）和一些默认的*文本设置*等。`front-matter` 和 `main-matter` 包含一个计数器，其中，后者还包含一些额外的正文文本配置。原则上讲，扉页（title page，未包括在论文中）和版权页（copyright page）不需要计数器，因而将其置于 `#show: front-matter` 规则之前，尽管在排版上其实质为前辅文的一部分。`back-matter` 包含了重置计数器的开关和一些额外的图表排序设置。

== 页面

参考模板的结构设计，除了正文和附录部分由样式控制而不提供页面，其余页面均已经内置，同时还提供了额外的字体展示页面用于调整字体配置。

部分内置页面和布局提供了用于额外配置字体的选项，如：

```typ
#fonts-display(fonts: (
  SongTi: ((name: "Times New Roman", covers: "latin-in-cjk"), "SimHei"))
)
```

其可设置*在字体展示页中*使宋体（SongTi）使用 Times New Roman 和 SimHei 字族。

除了封面页和字体展示页外，所有内置页面均提供了适配双面打印的 `twoside` 选项，部分页面还提供了适用匿名模式的 `anonymous` 选项，*大部分情况下，您不需要额外配置这些页面*。在匿名模式下，封面页的信息会被隐藏，同时涉及个人信息的页面（如致谢页、成果页等）不会显示。

部分页面还提供了一些额外的个性化选项，但多数情况下您应该也不会使用到这些选项，您可以参考提供的注释信息和源码来进一步了解。

== 参考

*除了使用到的清华大学图形素材外，本模板基于 MIT 协议开源*，您可以在 GitHub 上找到本模板的源代码和使用说明，项目地址为 #link("https://github.com/chillcicada/tntt/")，欢迎提供反馈和建议。

typst 语法可以参考 #link("https://typst.app/docs/")[Typst 官方文档] 和 #link("https://typst-doc-cn.github.io/docs/")[Typst 中国社区的翻译]，常见问题可以参考 #link("https://typst.dev/guide/")[Typst 中文社区导航]，进阶学习可以参考 #link("https://typst.dev/tutorial/")[小蓝书]。

此外，对于一些常用的工具，您可以查找 #link("https://typst.app/universe/")[universe] 中的包进一步了解，本模板旨在提供基础的开箱即用的功能，您可以在此基础上进行扩展和修改。

#line(length: 100%)

#align(center)[*以下部分为完整的示例，包含了大部分的功能和用法。*]

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

除此之外，社区也提供了 #link("https://typst.app/universe/package/tablem")[tablem] 用于创建类似 markdown 写法的表格。

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

对于一些常用的写法，社区提供了 #link("https://typst.app/universe/package/physica")[physica] 包来简化物理公式的书写和 #link("https://typst.app/universe/package/unify")[unify] 包来便于创建单位。

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

/// ----------- ///
/// Back Matter ///
/// ----------- ///
#show: back-matter

// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
#bilingual-bibliography(full: true)

// 致谢
#acknowledge[
  非常感谢 #link("https://github.com/OrangeX4")[OrangeX4] 为南京大学学位论文 Typst 模板 #link("https://typst.app/universe/package/modern-nju-thesis")[modern-nju-thesis] 所做的贡献，本项目移植自由 OrangeX4 及 nju-lug 维护的 modern-nju-thesis 模板，感谢他们所作工作。

  移植过程中主要参考了 #link("https://github.com/fatalerror-i/ThuWordThesis")[清华大学学位论文 Word 模板] 和 #link("https://github.com/tuna/thuthesis")[清华大学学位论文 LaTeX 模板]，在此表达感谢。

  感谢#link("https://github.com/Myriad-Dreamin")[纸叶#strike[姐姐]]开发的 #link("https://github.com/Myriad-Dreamin/tinymist")[Tinymist] 工具。

  感谢 #link("https://typst.app/")[Typst] 团队的努力，感谢 Typst 中文社区。

  感谢所有本项目的贡献者。
]

// 声明页
#declaration()

// 手动分页
#if twoside {
  pagebreak() + " "
}

= 附录

== 附录子标题

=== 附录子子标题

附录内容，这里也可以加入图片，例如@fig:appendix-img。

#figure(
  image("media/logo.jpg", width: 20%),
  caption: [图片测试],
) <appendix-img>

// 成果页
#achievement[
  在课题研究中获得的成果，如申请的专利或已正式发表和已有正式录用函的论文等。没有相关内容请删除本章节。
]
