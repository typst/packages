#!/usr/bin/env -S typst c
#import "@preview/tntt:0.5.0"
#import tntt: define-config, use-size

/// 以下字体配置适用于安装了 Windows 10/11 字体及 Windows 10/11 简体中文字体扩展的设备，
/// 请勿修改 font-family 中定义的键值，除 Math 数学字体外，修改西文字体时请使用 `latin-in-cjk` 覆盖字体范围
///
/// 对于 MacOS 用户，可以使用 `Songti SC`、`Heiti SC`、`Kaiti SC`、`Fangsong SC` 和 `Menlo` 作为替代
///
/// 对于 Linux 用户，可以使用 `Source Han Serif`、`Source Han Sans`、`Source Han Mono` 或文泉驿字体等进行配置
#let font-family = (
  SongTi: ((name: "Times New Roman", covers: "latin-in-cjk"), "NSimSun"),
  HeiTi: ((name: "Arial", covers: "latin-in-cjk"), "SimHei"),
  KaiTi: ((name: "Times New Roman", covers: "latin-in-cjk"), "KaiTi"),
  FangSong: ((name: "Times New Roman", covers: "latin-in-cjk"), "FangSong"),
  Mono: ((name: "DejaVu Sans Mono", covers: "latin-in-cjk"), "SimHei"),
  Math: ("New Computer Modern Math", "KaiTi"),
)

#let (
  ..config,
  /// global utilities
  use-fonts,
  use-en-font,
  use-cjk-fonts,
  use-twoside,
  /// layouts
  meta,
  doc,
  front-matter,
  main-matter,
  back-matter,
  /// pages
  fonts-display,
  cover,
  cover-en,
  spine,
  committee,
  copyright,
  abstract,
  abstract-en,
  outline-wrapper,
  master-list,
  figure-table-list,
  figure-list,
  table-list,
  equation-list,
  notation,
  bilingual-bibliography,
  acknowledge,
  declaration,
  achievement,
  record-sheet,
  comments,
  resolution,
) = define-config(
  // 学位层级，可选值: bachelor, master, doctor, postdoc
  // 模板内容会根据学位自动调整，对于不需要的内容会自动忽略
  degree: "bachelor",
  degree-type: "academic",
  anonymous: false, // 盲审模式
  twoside: false, // 双面模式，会加入空白页，便于打印
  // 如下的信息会写入到 PDF 元数据中
  info: (
    title: "清华大学学位论文 Typst 模板\n使用示例文档",
    // 等价于（如果你需要将标题用 content 表示，请用下面的写法）
    // title: ("清华大学学位论文 Typst 模板", "使用示例文档"),
    author: "某某某",
    // 论文提交日期，封面仅显示年月，但具体日期会写入到 PDF 元数据中
    date: datetime.today(),
    // 指定论文提交日期，可填写任意时间
    // date: datetime(year: 2026, month: 5, day: 30),
    // （并不建议）将日期具体到时分秒，需要自行换算到 UTC 时间
    // 如下设置日期为北京时间 2026 年 5 月 30 日 10:30 AM，对应 UTC 时间的 2:30 AM
    // date: datetime(year: 2026, month: 5, day: 30, hour: 2, minute: 30, second: 0),
  ),
  bibliography: read("ref.bib"), // 参考文献源
  fonts: font-family, // 应用字体配置
)

// 文稿设置，默认应用 LaTeX/i-figured 引用兼容模式（引用标签时可添加 `fig:` 等前缀）
#show: it => meta(it)
// 等价于如下写法
// #show: meta
// 但由于技术限制，该写法会导致 meta 的类型提示损坏，因而此处显式使用函数调用

// 字体展示测试页，在配置好字体后请注释或删除此项
#fonts-display()

// 中文封面页
#cover(
  // 用于中文封面的额外信息
  info: (
    department: "××××",
    major: "××××××××",
    // 学位名称，可按学术类型或是工程类型编写，对本科生无效
    degree-name: "工学硕士",
    supervisor: ("某某某", "教授"),
    // 多指导老师示例
    // supervisor: ("某某某", "教授", "某某", "副教授"),
    // 联合指导教师/副指导教师，对本科生无效
    co-supervisor: ("某某某", "教授"),
  ),
)

// 英文封面页，仅适用于研究生及以上
#cover-en(
  // 用于英文封面的额外信息
  info: (
    title: "An Introduction to Typst Thesis Template of Tsinghua University",
    author: "Xue Ruini",
    major: "Computer Science and Technology",
    degree-name: "Master of Science",
    supervisor: ("Professor Zheng Weimin",),
    co-supervisor: ("Professor Chen Wenguang",),
  ),
)

// 书脊页，仅适用于研究生及以上
// #spine()

/// ----------- ///
/// Doc Layouts ///
/// ----------- ///
#show: it => doc(it)

// 强制让 × 使用中文字体显示，此处仅为让示例文档美观显示，可删除
#show "×": set text(font: use-cjk-fonts("SongTi"))

// 学位论文指导小组、公开评阅人和答辩委员会名单，仅适用于研究生及以上
// committee 的信息不会从 info 中继承，需要单独提供，如下内容仅供参考
// 定义的 supervisors, reviewers 和 defenders 键值名称请勿修改
// 请确保每个成员的信息完整，每个条目均为 (姓名, 职称, 工作单位)，不完整的条目将被忽略
#committee(
  // 设置 supervisors 为 () 将隐藏指导小组名单
  // supervisors: (),
  supervisors: (
    ("李××", "教授", "清华大学"),
    ("王××", "副教授", "清华大学"),
    ("张××", "助理教授", "清华大学"),
  ),
  // 设置 reviewers 为 () 表示无公开评阅人，等价于 `reviewers: [无（全隐名评阅）]`
  // 如需彻底隐藏公开评阅人名单，可将 reviewers 设置为 none
  reviewers: (),
  // reviewers: (
  //   ("刘××", "教授", "清华大学"),
  //   ("陈××", "副教授", "××××大学"),
  //   ("杨××", "研究员", "中国××××科学院×××××××研究所"),
  // ),
  // 设置 defenders 为 (:) 将隐藏答辩委员会名单
  // defenders: (:),
  defenders: (
    // 如下定义的键值会在生成表格时直接使用，可根据需要进行增删，如果为空值将会被自动忽略
    主席: (
      ("赵××", "教授", "清华大学"),
    ),
    委员: (
      ("刘××", "教授", "清华大学"),
      ("杨××", "研究员", "中国××××科学院×××××××研究所"),
      ("黄××", "教授", "××××大学"),
      ("周××", "副教授", "××××大学"),
    ),
    秘书: (
      ("吴××", "助理研究员", "清华大学"),
    ),
  ),
)

// 授权页
#copyright()

/// ------------ ///
/// Front Matter ///
/// ------------ ///
#show: it => front-matter(it)

// 中文摘要
// 默认情况下会将中文关键词和摘要内容嵌入到 PDF 中，设置 embeded 为 false 可禁用该行为
#abstract(keywords: ("关键词 1", "关键词 2", "关键词 3", "关键词 4", "关键词 5"))[
  论文的摘要是对论文研究内容和成果的高度概括。摘要应对论文所研究的问题及其研究目的进行描述，对研究方法和过程进行简单介绍，对研究成果和所得结论进行概括。摘要应具有独立性和自明性，其内容应包含与论文全文同等量的主要信息。使读者即使不阅读全文，通过摘要就能了解论文的总体内容和主要成果。

  论文摘要的书写应力求精确、简明。切忌写成对论文书写内容进行提要的形式，尤其要避免“第 1 章……；第 2 章……；……”这种或类似的陈述方式。

  关键词是为了文献标引工作、用以表示全文主要内容信息的单词或术语。每篇论文应选取 3～5 个关键词，每个关键词中间用分号分隔。
]

// 英文摘要
#abstract-en(keywords: ("Keyword 1", "Keyword 2", "Keyword 3", "Keyword 4", "Keyword 5"))[
  An abstract of a dissertation is a summary and extraction of research work and contributions. Included in an abstract should be description of research topic and research objective, brief introduction to methodology and research process, and summarization of conclusion and contributions of the research. An abstract should be characterized by independence and clarity and carry identical information with the dissertation. It should be such that the general idea and major contributions of the dissertation are conveyed without reading the dissertation.

  An abstract should be concise and to the point. It is a misunderstanding to make an abstract an outline of the dissertation and words "the first chapter", "the second chapter" and the like should be avoided in the abstract.

  Keywords are terms used in a dissertation for indexing, reflecting core information of the dissertation. The number of keywords should be between 3 and 5, with semi-colons used in between to separate one another.
]

// 目录
#outline-wrapper()

// 总清单
// #master-list()

// 插图和附表清单
// #figure-table-list()

// 插图清单
#figure-list()

// 附表清单
#table-list()

// 公式清单
// #equation-list()

// 符号表
// 建议按符号、希腊字母、缩略词等部分编制，每一部分按首字母顺序排序。
#notation[
  / $upright(a), upright(c_1), upright(c_2)$: 临时替换变量

  / $upright(D_m)$: 预混通道外径 (mm)
  / Ga: 空气质量流量 (kg/s)
  / Ma: 进口空气马赫数，$"Ma" = v_2 slash gamma R T_2$

  / gamma: 比热比=1.4
  / $delta$: 总压损失系数，$delta = Delta p_(2-3) slash p_2 (%)$
  / $phi_"LLO"$: 贫燃着火极限

  / CFD: 计算流体力学 (Computational Fluid Dynamics)
  / DFT: 密度泛函理论 (Density functional theory)
  / LBO: 贫燃熄火极限 (Lean Blowout Value)
  / ONIOM: 分层算法 (Our own N-layered Integrated molecular Orbital and molecular Mechanics)
  / PES: 势能面 (Potential Energy Surface)
  / PIV: 颗粒图像速度仪 (Particle Image Velocimetry)
  / SCF: 自洽场 (Self-Consistent Field)
  / SCRF: 自洽反应场 (Self-Consistent Reaction Field)
  / TS: 过渡态 (Transition State)
  / TST: 过渡态理论 (Transition State Theory)
  / ZPE: 零点振动能 (Zero Vibration Energy)

  / TnTT: *非官方*清华大学 Typst 论文模板
]

/// ----------- ///
/// Main Matter ///
/// ----------- ///
#show: it => main-matter(it)

= 导　引

== 结构

*本模板提供的文档结构*可分为四个层次，其涵义如下：

- 文档前内容：封面、授权页等相对独立的内容
  - 中文封面（cover）
  - 英文封面（cover-en） ← 仅适用于研究生及以上
  - 书脊页（spine） ← 仅适用于研究生及以上
  - 指导小组与答辩委员会名单（committee） ← 仅适用于研究生及以上
  - 授权页（copyright）
- 前辅文（front-matter）：即正文前部分
  - 中文摘要（abstract） ← 前辅文从此页开始计数
  - 英文摘要（abstract-en）
  - 目录（outline-wrapper）
  - 插图目录（figure-list）
  - 表格目录（table-list）
  - 公式目录（equation-list）
  - 符号表（notation）
- 正文（main-matter） ← 正文重新计数
  - 正文内容
- 后辅文（back-matter）：即正文后部分
  - 参考文献（bilingual-bibliography）
  - 附录内容
  - 致谢页（acknowledge）
  - 声明页（declaration）
  - 简历/个人成果页（achievement）
  - 综合论文训练记录表（record-sheet） ← 仅适用于本科生
  - 指导教师学术评语（comments） ← 仅适用于硕士生及以上
  - 答辩委员会决议书（resolution） ← 仅适用于硕士生及以上

模板将自动根据 degree 调整内容和样式，如封面页、授权页、声明页等，即使在源码中引入了这些页面，这些页面也不会出现在最终的文档中。

依据上述的结构设计，本模板将文档拆分为了四个布局和多个页面，布局用于控制文档的整体样式和结构，页面用于控制具体页面的内容和样式。在所有配置前，模板会首先应用 `meta` 用于控制文档的元配置，其中包含了*基础的文本设置*（语言、区域和字体回滚开关）和*页面设置*（），同时也包含了 *PDF 的元信息*（标题、作者等）；封面页自身完全独立，模板会在封面页后应用全局样式布局 `doc`，用于控制封面页后所有内容的样式和结构，其中主要为*段落设置*（两端对齐、行距、段距等）和一些默认的*文本设置*等。`front-matter`、`main-matter` 和 `back-matter` 只涉及页面、标题与图表编号和相关的计数器配置。

`doc` 中定义了所有影响全局的样式，如段落设置、字体配置、引用样式等，如：

```typ
#show: it => doc(it, cite-style: "normal")
```

上述代码可将所有引用样式设置为正常的直立格式而非上标（super）格式。大部分布局和页面均提供了一定的内置选项用于个性化调整，您可以使用 #link("https://typst.app/docs/reference/foundations/function/#definitions-with", underline(`.with(...)`)) 覆盖函数的默认值。建议使用 Tinymist 进行编辑，Tinymist 会为编辑器提供相关的代码注释和类型提示，也可以直接在源码中查看相关的注释文档，以帮助您更好地使用和调整模板。

== 参考

*除了项目封面使用到的清华大学图形素材外，本模板基于 MIT 协议开源*，您可以在 GitHub 上找到本模板的源代码和使用说明，项目地址为 #link("https://github.com/chillcicada/tntt/")，欢迎提供反馈和建议。

typst 语法可以参考 #link("https://typst.app/docs/", underline[Typst 官方文档]) 和 #link("https://typst-doc-cn.github.io/docs/", underline[Typst 中国社区的翻译])，常见问题可以参考 #link("https://typst.dev/guide/", underline[Typst 中文社区导航])，进阶学习可以参考 #link("https://typst.dev/tutorial/", underline[小蓝书])。

此外，对于一些常用的工具，您可以查找 #link("https://typst.app/universe/", underline[universe]) 中的包进一步了解，本模板旨在提供基础的开箱即用的功能，您可以在此基础上进行扩展和修改。

#line(length: 100%)

#align(center)[*以下部分为完整的示例，参考了本科生综合论文训练模板和 ThuThesis 提供的内容，包含了大部分的功能和用法。*]

= 引　言

== 一级节标题第一条，此处是为了给出跨行目录悬挂对齐的示例此处是为了给出跨行目录悬挂对齐的示例

此部分是论文主体部分的文字格式示例。

=== 二级节标题第一条，为了给出跨行目录悬挂对齐的示例此处是为了给出跨行目录悬挂对齐的示例

主体部分一般从引言（绪论）开始，以结论结束。

引言（绪论）应包括论文的研究目的、流程和方法等。

论文研究领域的历史回顾，文献回溯，理论分析等内容，应独立成章，用足够的文字叙述。

主体部分由于涉及的学科、选题、研究方法、结果表达方式等有很大的差异，不能作统一的规定。但是，必须实事求是、客观真切、准确完备、合乎逻辑、层次分明、简练可读。

=== 二级节标题第二条

论文中应引用与研究主题密切相关的参考文献。参考文献的写法应遵循国家标准《信息与文献 参考文献著录规则》（GB/T 7714—2015）；符合特定学科的通用范式，可使用APA或《清华大学学报（哲学社会科学版）》格式，且应全文统一，不能混用。此处是正文中引用参考文献的上标标注示例@zhangkun1994。

当论文中的字、词或短语，需要进一步加以说明，而又没有具体的文献来源时，用注释。注释一般在社会科学中用得较多。应控制论文中的注释数量，不宜过多。由于论文篇幅较长，建议采用文中编号加“脚注”的方式。此处是脚注格式规范示例#footnote[脚注处序号“①，……，⑩”的字体是“正文”，不是“上标”，序号与脚注内容文字之间空半个汉字符，脚注的段落格式为：单倍行距，段前空0磅，段后空0磅，悬挂缩进1.5字符；字号为小五号字，汉字用宋体，外文用Times New Roman体。]。

可以像这样引用参考文献：图书#[@zhukezhen1973]和会议#cite(<dupont1974bone>)。

= 图、表及表达式示例

引用图表时，可以直接使用 `<lab>` 和 `@ref` 来引用，如 @fig-example、@tbl-example 和 @eqt-example。

// 如果偏好 LaTeX/i-figured 风格的引用样式，即使用 `@fig:`, `@tbl:`, `@eqt:`, `@lst:`, `@alg:` 等前缀为引用进行分类，在 `meta` 中启用 `use-latex-ref` 后也可以使用如下引用形式：@fig:fig-example，@tbl:tbl-example，@eqt:eqt-example，@lst:lst-example，@alg:example-pseudocode。

== 论文中图的示例

图应具有“自明性”，即只看图、图题和图例，不阅读正文，就可理解图意。示例如下：

#figure(
  image("media/图的示例.png", width: 9.74cm),
  caption: [不同光源照射30分钟后测定的紫菌样品紫外－可见吸收光谱，此处给出目录跨行后对齐的演示此处给出目录跨行后对齐的演示],
) <fig-example>

@fig-example 为不同光源照射30分钟后测定的紫菌样品紫外－可见吸收光谱#footnote[图题文字要求：图题置于图下方，图题前空两格，图题字号为小五号字，汉字用宋体，外文用Times New Roman体。]。

将一个 `figure` 的类型（`kind`）设置为 `grid` 以将其标记为组图，组图仅适用于多图排列（即 `figure` 类型为 `image`）的情况，*如果组图中涉及其他类型时，不会将其标记为子图处理*。

#figure(
  grid(columns: (1fr,) * 3, align: horizon)[
    #figure(
      image("media/图的示例.png", width: 80%),
      // 仅设置 outlined 为 false 会导致子图编号更新但不再大纲中显示，
      // 设置 numbering 为 none 则进一步不更新图编号
      numbering: none,
      outlined: false,
      caption: [该图不会编入图表目录],
    )
  ][
    #figure(
      block("这是子图示例1", stroke: red + 1pt, inset: 1em),
      caption: [这是子图示例1],
    )
  ][
    #figure(
      block("这是子图示例2", stroke: red + 1pt, inset: 1em),
      caption: [这是子图示例2],
    )
  ],
  caption: [子图排列示例],
  kind: grid, // 将 kind 设置为 grid 以将其标记为组图
  supplement: [图],
) <fig-subexample>

== 论文中表的示例

表应具有“自明性”。表的编排，一般是内容和测试项目由左至右横读，数据依序竖读。示例如下：

#[
  #set text(size: use-size("五号"))

  #figure(
    table(
      align: (x, y) => { if x == 4 and y >= 1 { left + horizon } else { center + horizon } },
      columns: (2.25cm, 2.75cm, 2.25cm, 2.75cm, 5cm),
      stroke: none,
      table.hline(stroke: 1.5pt),
      [], [文字举例], [中文字体、字号要求], [英文及数字字体、字号要求], [其他格式要求],
      table.hline(stroke: .75pt),
      [章标题], [第1章 引言], [黑体三号], [Arial三号], [居中书写，单倍行距，段前空24磅，段后空18磅],
      [一级节标题], [4.1 标题示例], [黑体四号], [Arial四号], [居左书写，行距为固定值20磅，段前空24磅，段后空6磅],
      [二级节标题], [3.2.2 标题示例], [黑体中四], [Arial中四], [居左书写，行距为固定值20磅，段前空12磅，段后空6磅],
      [三级节标题], [5.3.3.2 标题示例], [黑体小四], [Arial小四], [居左书写，行距为固定值20磅，段前空12磅，段后空6磅],
      table.hline(stroke: 1.5pt),
    ),
    caption: [字体、字型、字号及段落格式要求],
  ) <tbl-example>
]

@tbl-example 为字体、字型、字号及段落格式要求。

除此之外，社区也提供了 #link("https://typst.app/universe/package/tablem", underline[tablem]) 用于创建类似 markdown 写法的表格。

== 论文中表达式的示例

表达式主要是指数字表达式，例如数学表达式，也包括文字表达式。示例如下：

$
  "NH"^+_4 + 2"O"_2 -> "NO"^-_3 + "H"_2"O" + 2"H"^+
$ <eqt-example>

@eqt-example 为铵与氧气的反应。社区提供了 #link("https://typst.app/universe/package/typsium", underline[typsium]) 包和 #link("https://typst.app/universe/package/alchemist", underline[alchemist]) 用于简化化学符号和反应方程式的书写。

默认情况下，行间公式都会自动编号，可以通过 `-` 标签（`<->`）来标识该行间公式不需要编号：

$ y = integral_1^2 x^2 dif x $ <->

此标签是不可引用的，这等价于：

#math.equation($ y = integral_1^2 x^2 dif x $, numbering: none, block: true)

后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

此外，也可以像 Markdown 一样写行内公式 $x + y$。对于一些常用的写法，社区提供了 #link("https://typst.app/universe/package/physica", underline[physica]) 包来简化物理公式的书写和 #link("https://typst.app/universe/package/unify", underline[unify]) 包来便于创建单位。

== 论文中代码块和算法的示例

*此部分在规范中未做要求。*Typst 中代码块默认支持语法高亮。如 @lst-example。

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption: [代码块],
) <lst-example>

此外，社区也提供了 #link("https://typst.app/universe/package/codly", underline[codly]) 和 #link("https://typst.app/universe/package/zebraw", underline[zebraw]) 包用于创建更美观的代码块。

对于算法和伪代码，社区提供了 #link("https://typst.app/universe/package/lovelace", underline[lovelace]) 包用于创建，如：

#[
  #import "@preview/lovelace:0.3.0": pseudocode-list

  #figure(
    kind: "algorithm",
    supplement: [算法],
    pseudocode-list[
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
    caption: [伪代码示例],
  ) <example-pseudocode>
]

使用 @example-pseudocode 引用该伪代码示例。

= 结　语

== 目前存在的问题

尽管 Typst 的语法和表达能力较为强大，其生态也初具雏形，但由于整体仍处于快速发展阶段，而模板本身也没有经过充分的验证和迭代，因而目前仍存在一些问题和限制，包括但不限于如下内容：

- 部分字体在不同平台上的显示效果可能存在差异。此问题在 Word 和 LaTeX 中同样存在，Typst 对 OpenType 的支持也在完善，强烈建议按照学校官方模板的字体进行配置和渲染；
- 文档的排版和样式需要一定的个性化配置。模板的结构和接口设计一定程度参考了 LaTeX 模板 #link("https://github.com/tuna/thuthesis", underline[thuthesis])，目前仅提供了英文的注释文档。此外，受限于使用基数，很多设计尚在摸索中，欢迎提供改进建议；
- #strike[公式索引无法忽略附录公式。]由于学校不要求公式索引，此问题暂时搁置；
- 某些细节处可能与 Word / LaTeX 模板存在差异。本模板在排版设计上以官方 Word 模板和过往论文等为主，但由于 Word 模板自身问题不少，同时不同引擎间存在差异，无法做到完全一致；
- #strike[不支持多参考文献源，]不支持多参考文献实例。目前通过将参考文献源转化为字节以支持多参考文献源，GB/T 7714 参考文献样式使用 #link("https://typst.app/universe/package/gb7714-bilingual", underline[alexandria]) 包处理，但其对多参考文献实例的支持有限，当前仍使用单参考文献实例。理论上可以通过 #link("https://typst.app/universe/package/alexandria", underline[alexandria]) 包解决，由于 Typst 相关开发正在推进，因而并未采用。考虑单参考文献实例对论文编辑影响并不严重，目前在对附录部分部分的参考文献处理较为粗暴，可以理解为没有实现双向链接的参考文献样式，这样做主要是考虑到成就页部分的参考文献一般不会被正文引用，因而如果在附录中有链接参考的需求，您可能需要手动用 `cite` 函数来引用对应的参考文献或手动管理编号链接。

此外，由于官方提供的 Word 模板中也存在诸多问题，很多事项并未在规范中完全注明或比较随意，因而一些排版出入是合理的。

更多对 Typst 中文排版问题与细节的讨论参见社区提供的 #link("https://gap.zhtyp.art/", underline[clreq 文档])。

== 许可证

*本模板基于 MIT 协议开源，您可以自由使用、修改和分发，但必须包含原始的版权声明，同时作者不对任何使用本模板的行为承担责任。*当前开源仓库仅托管于 GitHub，地址为 #underline(link("https://github.com/chillcicada/tntt"))；对于模板封面中使用到的清华大学校徽与校名的图形文件，皆取自#link("https://vi.tsinghua.edu.cn/", underline[清华大学视觉形象系统])，仅用于制作论文封面，项目维护者未进行任何修改，除模板本身使用外，未对封面进行二次分发；在编写模板示例文档时参考了近年的诸多论文规范规范，使用了其中的部分内容和图片作为实例，其版权归属于相应作者，仅在本示例文档中使用。最后，如果您有问题，建议您到 GitHub 仓库讨论或向 #underline(link("mailto:2210227279@qq.com")) 发送邮件。

/// ----------- ///
/// Back Matter ///
/// ----------- ///
#show: it => back-matter(it)

// Typst 使用 CSL 样式来处理参考文献，但由于 CSL 样式自身约束性有限
// 因而模板对 gb-7714-2015-numeric 进行了一定的修改
// 中英双语参考文献，默认使用 gb-7714-2015-numeric 样式，设置 style 以切换样式
// #bilingual-bibliography(style: "gb-7714-2015-author-date")
// 除了内置的样式外，style 也接受 CSL 路径，相关内容请参考 Typst 的官方文档
#bilingual-bibliography()

// 附录
// 对于本科生：请关注院系对此部分的具体需求进行调整
// 此处使用 `if false` 来包裹并注释示例内容，以使编辑器的语法高亮和结构提示功能仍然可用
// 如果需要启用此部分内容请修改为 `if true` 或删去 `if` 条件包裹
#if false [
  = 外文资料的调研阅读报告（或书面翻译）

  #align(center)[调研阅读报告题目（或书面翻译题目）]

  写出至少 5000 外文印刷字符的调研阅读报告或者书面翻译 1-2 篇（不少于2 万外文印刷符）。

  == #lorem(3)

  === #lorem(3)

  附录内容，这里也可以加入图片，例如@appendix-img。默认情况下，附录内的图表不会加入到对应的索引中。引用前面的图片也可以正常显示@fig-example。

  #figure(image("media/图的示例.png", width: 50%), caption: [图片测试]) <appendix-img>

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
]

// 手动应用双面打印布局，仅在双面打印模式生效
// 此处仅供示意，如果不需要的话，可自行删除
#use-twoside()

= 其他内容

附录作为主体部分的补充，并不是必需的。

不宜放在正文中，但有参考价值的内容，如公式的推演、编写的算法语言程序设计、图纸、数据表格等。没有相关内容请删除本章节。

下列内容可以作为附录编于论文后：

——为了整篇论文材料的完整，但编入正文又有损于编排的条理性和逻辑性，这一材料包括比正文更为详尽的信息、研究方法和技术更深入的叙述，对了解正文内容有用的补充信息等。

——由于篇幅过大或取材于复制品而不便于编入正文的材料。

——不便于编入正文的罕见珍贵资料。

——对一般读者并非必要阅读，但对本专业同行有参考价值的资料。

——正文中未被引用但被阅读或具有补充信息的文献。

——某些重要的原始数据、数学推导、结构图、统计表、计算机打印输出件等。

#figure(
  kind: grid,
  supplement: [图],
  caption: [附录中组图示例，附录中的图默认不会排入目录中],
  grid(
    columns: (1fr,) * 2,
    figure(block("这是附录中的子图示例1", stroke: red + 1pt, inset: 1em), caption: [这是附录中的子图示例1]),
    figure(block("这是附录中的子图示例2", stroke: red + 1pt, inset: 1em), caption: [这是附录中的子图示例2]),
  ),
)

$
  1 + 1 = 2
$ <->

$
  e^(i pi) + 1 = 0
$

#v(2em)

#align(center)[参考文献]

#{
  set text(size: use-size("五号"))
  set enum(body-indent: 20pt, numbering: "[1]", indent: 0pt)

  [
    + 某某某. 信息技术与信息服务国际研讨会论文集: A 集［C］北京：中国社会科学出版社，1994.
  ]
}

// 致谢
#acknowledge[
  致谢对象，原则上仅限于在学术方面对学位论文的完成有较重要帮助的团体和人士（不超过半页纸）。

  #line(length: 100%)

  衷心感谢指导教师××教授对本人的精心指导。他的言传身教将使我终生受益。

  感谢×××××实验室××教授，以及×××××全体老师和同窗们的热情帮助和支持！

  ……

  本课题承蒙×××××基金资助，特此致谢。

  #line(length: 100%)

  #par(first-line-indent: 0em)[*关于本模板的致谢如下：*]

  非常感谢 #link("https://github.com/OrangeX4", underline[OrangeX4]) 为南京大学学位论文 Typst 模板 #link("https://typst.app/universe/package/modern-nju-thesis", underline[modern-nju-thesis]) 所做的贡献，本项目移植于由 OrangeX4 及 nju-lug 维护的 modern-nju-thesis 模板，感谢他们所作工作。

  移植过程中主要参考了 #link("https://github.com/fatalerror-i/ThuWordThesis", underline[清华大学学位论文 Word 模板]) 和 #link("https://github.com/tuna/thuthesis", underline[清华大学学位论文 LaTeX 模板])，在模板更新的过程中主要参考了官方提供的 Word 模板，在此表达感谢。

  感谢 #link("https://www.myriad-dreamin.com/", underline[纸夜]) 开发的 #link("https://github.com/Myriad-Dreamin/tinymist", underline[Tinymist])工具，您可以通过 #link("https://afdian.com/a/camiyoru", underline[Afdian]) 对纸夜大大进行捐赠来支持他的工作。

  感谢 #link("https://github.com/typst", underline[Typst 团队]) 的努力，感谢 #link("https://github.com/typst-doc-cn", underline[Typst 中文社区])。

  感谢所有本项目的贡献者。
]

// 声明页
// 对于本科生和硕士生及以上会应用不同的样式，也可以自定义输入内容
#declaration()
// 涉密论文请启用 confidential 选项，适用于硕士生及以上
// #declaration(confidential: true)
// 使用自定义正文内容
// #declaration(body: [这是一段声明内容。])

// 个人简历、在学期间完成的相关学术成果说明页，没有相关内容请删除本章节。
#achievement(
  // 个人简历仅适用于研究生及以上，本科生不会显示此部分
  resume: [
    197×年××月××日出生于四川××县。

    1992年9月考入××大学化学系××化学专业，1996年7月本科毕业并获得理学学士学位。

    1996年9月免试进入清华大学化学系攻读××化学博士至今。
  ],
  paper: [
    1. *Yang Y*, Ren T L, Zhang L T, et al. Miniature microphone with silicon- based ferroelectric thin films[J]. Integrated Ferroelectrics, 2003, 52:229-235.
    2. *杨轶*, 张宁欣, 任天令, 等. 硅基铁电微声学器件中薄膜残余应力的研究[J]. 中国机械工程, 2005, 16(14):1289-1291.
    3. *杨轶*, 张宁欣, 任天令, 等. 集成铁电器件中的关键工艺研究[J]. 仪器仪表学报, 2003, 24(S4):192-193.
    4. *Yang Y*, Ren T L, Zhu Y P, et al. PMUTs for handwriting recognition. In press[J]. (已被Integrated Ferroelectrics录用)
  ],
  patent: [
    5. 胡楚雄, 付宏, 朱煜, 等. 一种磁悬浮平面电机: ZL202011322520.6[P]. 2022-04-01.
    6. REN T L, YANG Y, ZHU Y P, et al. Piezoelectric micro acoustic sensor based on ferroelectric materials: No.11/215, 102[P]. (美国发明专利申请号.)
  ],
)

// 论文训练记录表，仅适用于本科生的综合论文训练
// 此部分内容没有固定格式要求，以下内容仅供参考
#record-sheet(
  // 补充学生基本信息
  info: (
    student-id: "2022000000",
    class: "××××××",
  ),
  // 主要内容以及进度安排
  content: [
    #v(2em)

    *主要内容*：针对……问题，通过……方法/实验，提出了……，实现了……，验证了……；

    *进度安排*：2024年11月～12月，完成文献调研与开题报告撰写；2025年1月～3月，完成实验设计与数据收集；2025年4月～5月，完成数据分析与论文撰写；2025年6月，完成论文修改与答辩准备。
  ],
  // 中期检查评语
  mid-term-comment: [
    论文提出了……
  ],
  // 指导教师评语
  instructor-comment: [
    论文提出了……
  ],
  // 评阅人评语
  reviewer-comment: [
    论文提出了……
  ],
  // 答辩委员会评语
  defense-comment: [
    论文提出了……
  ],
)

// 指导教师评语，仅适用于研究生及以上
#comments[
  论文提出了……
]

// 答辩委员会决议书，仅适用于研究生及以上
#resolution[
  论文提出了……

  论文取得的主要创新性成果包括：

  1. ……
  2. ……
  3. ……

  论文工作表明作者在 ××××× 具有 ××××× 知识，具有 ×××× 能力，论文 ××××，答辩 ××××。

  答辩委员会表决，（× 票/一致）同意通过论文答辩，并建议授予 ×××（姓名）×××（门类）学博士/硕士学位。
]
