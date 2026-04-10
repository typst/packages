#import "@preview/tntt:0.3.0"
#import tntt: define-config, use-size

/// 以下字体配置适用于安装了 Windows 10/11 字体及 Windows 10/11 简体中文字体扩展的设备，
/// 请勿修改 font-family 中定义的键值，一般情况下，其含义为：
/// - SongTi: 宋体，正文字体，通常对应西文中的衬线字体
/// - HeiTi: 黑体，标题字体，通常对应西文中的无衬线字体
/// - KaiTi: 楷体，用于说明性文本和主观性的表达
/// - FangSong: 仿宋，通常用于注释、引文及权威性阐述
/// - Mono: 等宽字体，对于代码，会优先使用此项，推荐中文字体使用黑体或楷体，或者一些流行的中文等宽字体
/// - Math: 数学字体，通常用于数学公式和符号，推荐使用无衬线字体或楷体
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
    "FangSong",
  ),
  Mono: (
    (name: "DejaVu Sans Mono", covers: "latin-in-cjk"),
    "SimHei",
  ),
  Math: (
    "New Computer Modern Math",
    "KaiTi",
  ),
)

#let (
  /// global options
  twoside,
  use-fonts,
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
  equation-list,
  notation,
  bilingual-bibliography,
  acknowledge,
  declaration,
  achievement,
) = define-config(
  doctype: "bachelor",
  degree: "academic",
  anonymous: false, // 盲审模式
  twoside: false, // 双面模式，会加入空白页，便于打印
  info: (
    title: "本科生综合论文训练标题",
    author: "某某某",
    department: "××××",
    major: "××××××××",
    supervisor: ("某某某", "教授"),
    submit-date: "二○二四年十一月",
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
#abstract(keywords: ("关键词 1", "关键词 2", "关键词 3", "关键词 4", "关键词 5"))[
  论文的摘要是对论文研究内容和成果的高度概括。摘要应对论文所研究的问题及其研究目的进行描述，对研究方法和过程进行简单介绍，对研究成果和所得结论进行概括。摘要应具有独立性和自明性，其内容应包含与论文全文同等量的主要信息。使读者即使不阅读全文，通过摘要就能了解论文的总体内容和主要成果。

  论文摘要的书写应力求精确、简明。切忌写成对论文书写内容进行提要的形式，尤其要避免“第 1 章……；第 2 章……；……”这种或类似的陈述方式。

  关键词是为了文献标引工作、用以表示全文主要内容信息的单词或术语。每篇论文应选取 3～5 个关键词，每个关键词中间用分号分隔。
]

// 英文摘要
#abstract-en(keywords: ("Keyword 1", "Keyword 2", "Keyword 3", "Keyword 4", "Keyword 5"))[
  An abstract of a dissertation is a summary and extraction of research work and contributions. Included in an abstract should be description of research topic and research objective, brief introduction to methodology and research process, and summarization of conclusion and contributions of the research. An abstract should be characterized by independence and clarity and carry identical information with the dissertation. It should be such that the general idea and major contributions of the dissertation are conveyed without reading the dissertation.

  An abstract should be concise and to the point. It is a misunderstanding to make an abstract an outline of the dissertation and words “the first chapter”, “the second chapter” and the like should be avoided in the abstract.

  Keywords are terms used in a dissertation for indexing, reflecting core information of the dissertation. The number of keywords should be between 3 and 5, with semi-colons used in between to separate one another.
]

// 目录
#outline-wrapper()

// 插图目录
#figure-list()

// 表格目录
#table-list()

// 符号表
// 建议按符号、希腊字母、缩略词等部分编制，每一部分按首字母顺序排序。
#notation[
  / D#sub[m]: 预混通道外径 (mm)

  / $delta$: 总压损失系数，$delta = Delta p_(2-3) slash p_2 (%)$

  / DFT: 密度泛函理论 (Density functional theory)
  / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
  / ONIOM: 分层算法 (Our own N-layered Integrated molecular Orbital and molecular Mechanics)

  / TnTT: Typst & Tsinghua University Thesis Template （清华大学综合论文训练 Typst 模板）
]

/// ----------- ///
/// Main Matter ///
/// ----------- ///
#show: main-matter

= 引　言

== 一级节标题第一条

此部分是论文主体部分的文字格式示例。

=== 二级节标题第一条

主体部分一般从引言（绪论）开始，以结论结束。

引言（绪论）应包括论文的研究目的、流程和方法等。

论文研究领域的历史回顾，文献回溯，理论分析等内容，应独立成章，用足够的文字叙述。

主体部分由于涉及的学科、选题、研究方法、结果表达方式等有很大的差异，不能作统一的规定。但是，必须实事求是、客观真切、准确完备、合乎逻辑、层次分明、简练可读。

=== 二级节标题第二条

论文中应引用与研究主题密切相关的参考文献。参考文献的写法应遵循国家标准《信息与文献 参考文献著录规则》（GB/T 7714—2015）；符合特定学科的通用范式，可使用APA或《清华大学学报（哲学社会科学版）》格式，且应全文统一，不能混用。此处是正文中引用参考文献的上标标注示例[1]。

当论文中的字、词或短语，需要进一步加以说明，而又没有具体的文献来源时，用注释。注释一般在社会科学中用得较多。应控制论文中的注释数量，不宜过多。由于论文篇幅较长，建议采用文中编号加“脚注”的方式。此处是脚注格式规范示例①。

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

大部分情况下，您都无需关注内置模板的字体选项，除非您需要使用到一些特殊的字体或字号，或者需要使用到一些特殊的排版效果。如果你想在一些场合使用中文字号，你可以使用模板提供的 `use-size` 函数，如：

```typ
#import tntt: use-size
#text(size: use-size("小三"), "这将使这段文字显示为「小三」大小。")
```

`use-size` 允许传入形如 16pt 的 `length` 类型的参数，因而推荐使用。

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
  - 公式目录（equation-list）
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

其可设置*在字体展示页中*使宋体（SongTi）使用 Times New Roman 和 SimHei 字族。需要注意的时，为了控制不同页面渲染的协调性，该选项只在更换过字体的内置页面中有设置，如果你需要更改无 `fonts` 参数的页面，通常情况下你可以通过传入 `text` 装饰过的 `content` 来实现，如：

```typ
#abstract(back: text(font: use-fonts("KaiTi"))[*关键词：*])[
  论文的摘要是对论文研究内容和成果的高度概括。摘要应对论文所研究的问题及其研究目的进行描述，对研究方法和过程进行简单介绍，对研究成果和所得结论进行概括。摘要应具有独立性和自明性，其内容应包含与论文全文同等量的主要信息。使读者即使不阅读全文，通过摘要就能了解论文的总体内容和主要成果。
]
```

除了封面页和字体展示页外，大部分内置页面均提供了适配双面打印的 `twoside` 选项，部分页面还提供了适用匿名模式的 `anonymous` 选项，*大部分情况下，您不需要额外配置这些页面*。在匿名模式下，封面页的信息会被隐藏，同时涉及个人信息的页面（如致谢页、成果页等）不会显示。

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

$ "黄金比例": phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

我们也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

对于一些常用的写法，社区提供了 #link("https://typst.app/universe/package/physica")[physica] 包来简化物理公式的书写和 #link("https://typst.app/universe/package/unify")[unify] 包来便于创建单位。

== 参考文献

可以像这样引用参考文献：图书#[@zhukezhen1973]和会议#[@dupont1974bone]。

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

= 结　语

== 目前存在的问题

- 部分字体在不同平台上的显示效果可能存在差异，此问题在 Word 和 Latex 中同样存在；
- 文档的排版和样式可能需要根据个人需求进行调整，当前模板提供了最大限度的自由化选项，但目前尚未补全文档，可能需要一定的 Typst 使用经验才能上手，不过，并不鼓励修改内置的选项；
- 目前 Typst 仍然存在一些功能限制，包括但不限于如下的问题：
  - 导出的 PDF 中编号信息缺失，但相较于不提供导出书签的官方 Word 版本，此问题可以忽略；
  - 目前数学公式目录无法忽略附录中的公式，但由于数学公式索引并不启用，因而此问题也可以忽略；
  - 某些细节处可能与 Word 模板存在差异，必须强调的一点时，当前模板已经最大限度参考了 Word 模板的设计，调整了很多细节上的差异，但由于官方的 Word 模板自身问题不少，同时由于 Word 排版引擎本身的限制（浮动行距等），因而无法做到完全一致；
  - 当前 Typst 不支持多参考文献（Bibliography）实例，因而对附录部分和成就页部分的参考文献处理较为粗暴，可以理解为没有实现链接的 Word 参考文献样式，这样做主要是考虑到成就页部分的参考文献一般不会被引用，因而如果在附录中有链接参考的需求，您可能需要手动用 `cite` 函数来引用对应的参考文献。

// 手动分页
#if twoside { pagebreak() + " " }

/// ----------- ///
/// Back Matter ///
/// ----------- ///
#show: back-matter

// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
#bilingual-bibliography()

// 手动分页
#if twoside { pagebreak() + " " }

// 附录
= 外文资料的调研阅读报告（或书面翻译）

#align(center)[调研阅读报告题目（或书面翻译题目）]

写出至少 5000 外文印刷字符的调研阅读报告或者书面翻译 1-2 篇（不少于2 万外文印刷符）。

== #lorem(3)

=== #lorem(3)

附录内容，这里也可以加入图片，例如@fig:appendix-img。默认情况下，附录内的图表不会加入到对应的索引中。

#figure(
  image("media/logo.jpg", width: 20%),
  caption: [图片测试],
) <appendix-img>

#v(22pt)

#align(center)[参考文献（或书面翻译对应的原文索引）]

#{
  set text(size: use-size("五号"))

  set enum(
    body-indent: 20pt,
    numbering: "[1]",
    indent: 0pt,
  )

  [
    + 某某某. 信息技术与信息服务国际研讨会论文集: A 集［C］北京：中国社会科学出版社，1994.
  ]
}

= 其他内容

不宜放在正文中，但有参考价值的内容，如公式的推演、编写的算法语言程序设计、图纸、数据表格等。没有相关内容请删除本章节。

// 致谢
#acknowledge[
  致谢对象，原则上仅限于在学术方面对学位论文的完成有较重要帮助的团体和人士（不超过半页纸）。

  #line(length: 100%)

  // mask 用于在匿名模式下隐藏内容
  #import tntt: mask-text

  非常感谢 #link("https://github.com/OrangeX4")[OrangeX4] 为南京大学学位论文 Typst 模板 #link("https://typst.app/universe/package/modern-nju-thesis")[modern-nju-thesis] 所做的贡献，本项目移植自由 OrangeX4 及 nju-lug 维护的 modern-nju-thesis 模板，感谢他们所作工作。

  移植过程中主要参考了 #link("https://github.com/fatalerror-i/ThuWordThesis")[清华大学学位论文 Word 模板] 和 #link("https://github.com/tuna/thuthesis")[清华大学学位论文 LaTeX 模板]，在此表达感谢。

  感谢#link("https://github.com/Myriad-Dreamin")[纸叶#mask-text("姐姐")]开发的 #link("https://github.com/Myriad-Dreamin/tinymist")[Tinymist] 工具。

  感谢 #link("https://typst.app/")[Typst] 团队的努力，感谢 Typst 中文社区。

  感谢所有本项目的贡献者。
]

// 声明页
#declaration()

// 成果页
#achievement[
  #text(font: use-fonts("HeiTi"), size: use-size("四号"))[学术论文：]

  1. ZHOU R, HU C, OU T, et al. Intelligent GRU-RIC Position-Loop Feedforward Compensation Control Method with Application to an Ultraprecision Motion Stage[J], IEEE Transactions on Industrial Informatics, 2024, 20(4): 5609-5621.
  2. 杨轶, 张宁欣, 任天令, 等. 硅基铁电微声学器件中薄膜残余应力的研究[J]. 中国机械工程, 2005, 16(14):1289-1291.
  3. YANG Y, REN T L, ZHU Y P, et al. PMUTs for handwriting recognition. In press[J]. (已被Integrated Ferroelectrics录用)

  #v(2em)

  #text(font: use-fonts("HeiTi"), size: use-size("四号"))[专利：]

  4. 胡楚雄, 付宏, 朱煜, 等. 一种磁悬浮平面电机: ZL202011322520.6[P]. 2022-04-01.
  5. REN T L, YANG Y, ZHU Y P, et al. Piezoelectric micro acoustic sensor based on ferroelectric materials: No.11/215, 102[P]. (美国发明专利申请号.)

  #line(length: 100%)

  在课题研究中获得的成果，如申请的专利或已正式发表和已有正式录用函的论文等。没有相关内容请删除本章节。
]
