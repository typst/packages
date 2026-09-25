#import "@preview/modern-ucas-thesis:0.3.0": documentclass
// 本地开发时可用相对路径导入（上级目录的 lib.typ）代替上一行。
// 中文字体来自系统字库；如缺字，将 `fontset` 改为已安装字体对应的预设（见 fontset 参数注释）。
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
  list-of-figures-and-tables,
  notation,
  acknowledgement,
  backmatter,
  bifigure,
  bitable,
  continued-table,
  auto-table,
  aligned-equation,
) = documentclass(
  doctype: "doctor", // "bachelor" | "master" | "doctor" | "postdoc", 文档类型，默认为博士生 doctor
  degree: "academic", // "academic" | "professional", 学位类型，默认为学术型 academic
  anonymous: false, // 盲审模式
  twoside: true, // 双面模式，会加入空白页，便于打印
  fontset: "mac", // 选择预定义的字体组："windows" | "mac" | "fandol" | "adobe"
  // fonts参数可用于覆盖或补充fontset中的字体设置
  // 例如：仅想更改某一种字体时，可以这样设置
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S")),
  // 或者需要自定义特定字体以解决警告和兼容性问题时
  // fonts: (黑体: (name: "Times New Roman", covers: "latin-in-cjk"), "SimHei")),
  info: (
    title: ("基于 Typst 的", "中国科学院大学学位论文"),
    title-en: "Thesis/Dissertation of UCAS Based on Typst",
    // 导师信息：结构化字典列表 (name:, title:, affiliation:)，多导师第一导师在前。
    // 完整填写"姓名、专业技术职务、工作单位"三项（《指导意见》一·（一）·4）。
    supervisors: (
      (name: "李四", title: "教授", affiliation: "中国科学院××研究所"),
      (name: "王五", title: "研究员", affiliation: "中国科学院××研究所"),
    ),
    supervisors-en: (
      (name: "Si Li", title: "Professor", affiliation: "×× Institute, CAS"),
      (name: "Wu Wang", title: "Professor", affiliation: "×× Institute, CAS"),
    ),
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    author-en: "Zhang San",
    department: "中国科学院科技战略咨询研究院",
    department-en: "Institutes of Science and Development",
    major: "管理科学与工程",
    major-en: "Management Science and Engineering",
    category: "管理学博士",
    category-en: "Management Science",
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
#abstract(keywords: ("中国科学院大学", "学位论文", "模板"))[
  中文摘要、英文摘要、目录、论文正文、参考文献、附录、致谢、攻读学位期间发表的学术论文与其他相关学术成果等均须由另页右页（奇数页）开始。
]

// 英文摘要
#abstract-en(keywords: (
  "University of Chinese Academy of Sciences",
  "Thesis",
  "Typst Template",
))[
  Chinese abstracts, English abstracts, table of contents, the main contents, references, appendix, acknowledgments,
  author's resume and academic papers published during the degree study and other relevant academic achievements must
  start with another right page (odd-numbered page).
]

// 目录
#outline-page()

// 图表目录
#list-of-figures-and-tables()

// 符号列表
#notation()[

  字符

  // @typstyle off
  #table(
    columns: (1fr, auto, auto),
    align: (left, left, left),
    stroke: none,
    // 表格内容与左边距的距离为 0，使其与正文完全左对齐
    inset: (left: 0pt),
    table.header()[*Symbol*][*Description*][*Unit*],
    [$R$], [the gas constant], [$m^2 dot s^(-2) dot K^(-1)$],
    [$C_v$], [specific heat capacity at constant volume], [$m^2 dot s^(-2) dot K^(-1)$],
    [$C_p$], [specific heat capacity at constant pressure], [$m^2 dot s^(-2) dot K^(-1)$],
    [$E$], [specific total energy], [$m^2 dot s^(-2)$],
    [$e$], [specific internal energy], [$m^2 dot s^(-2)$],
    [$h_T$], [specific total enthalpy], [$m^2 dot s^(-2)$],
    [$h$], [specific enthalpy], [$m^2 dot s^(-2)$],
    [$k$], [thermal conductivity], [$"kg" dot m dot s^(-3) dot K^(-1)$],
    [$S_(i j)$], [deviatoric stress tensor], [$"kg" dot m^(-1) dot s^(-2)$],
    [$tau_(i j)$], [viscous stress tensor], [$"kg" dot m^(-1) dot s^(-2)$],
    [$delta_(i j)$], [Kronecker delta], [1],
    [$I_(i j)$], [identity tensor], [1],
  )

  算子

  #table(
    columns: (1fr, auto),
    align: (left, left),
    stroke: none,
    inset: (left: 0pt),
    table.header()[*Symbol*][*Description*],
    [$Delta$], [difference],
    [$nabla$], [gradient operator],
    [$delta^(plus.minus)$], [upwind-biased interpolation scheme],
  )

  缩写

  #table(
    columns: (1fr, auto),
    align: (left, left),
    stroke: none,
    inset: (left: 0pt),
    table.header()[*Symbol*][*Description*],
    [CFD], [Computational Fluid Dynamics],
    [CFL], [Courant-Friedrichs-Lewy],
    [EOS], [Equation of State],
    [JWL], [Jones-Wilkins-Lee],
    [WENO], [Weighted Essentially Non-Oscillatory],
    [ZND], [Zeldovich-von Neumann-Döring],
  )
]

// 正文
#show: mainmatter

= 绪论<chap:introduction>

== 背景

2022年修订的《中国科学院大学 研究生学位论文撰写规范和指导意见》（以下简称《指导意见》）从2023年冬季批次开始实施。为方便各位同学使用，特提供此模板。

您在使用此模板进行学位论文撰写时，只需根据《指导意见》在相应章节填写具体内容即可。

本模板在第2章提供了本模板的使用说明，在第3章中提供了《指导意见》中关于内容和格式的部分要求，请仔细阅读。

== 系统要求<sec:system>

#link("https://typst.app/")[Typst]是一款现代化的排版系统，支持在主流编辑器和编译环境（如 VS Code、Neovim、Emacs 等）中高效工作。Typst 采用即时编译技术，用户能够实时预览文档渲染结果，极大提升了学术及专业文档的编写体验。与传统的 LaTeX 系统相比，Typst 拥有更为简洁明了的语法设计，降低了学习曲线，非常适合初学者及非专业排版用户使用。

当前，Typst 官方已提供跨平台支持，兼容 Windows、Linux、macOS 以及网页版（Typst Web App）。用户可通过各软件的官方网站获取最新版本，建议避免使用非官方渠道下载。编辑器与 Typst CLI 安装完成后，即可实现本地编译，无需额外配置。对于初学者，推荐直接使用 Typst Web App 进行在线编辑与预览，无需本地环境配置，且支持多人协作。值得注意的是，Typst 不依赖于传统 LaTeX 编译引擎，而基于 WebAssembly 技术实现高效渲染，具备良好的跨平台兼容性，能够满足绝大多数用户的学术写作需求。

// @typstyle off
#auto-table(
  caption-zh: [支持的Typst的编译环境和编辑器],
  caption-en: [Supported Typst Compilation Environments and Editors],
  columns: 6,
  align: center,
  header: ([名称], [编辑器], [编译器环境], [预览方案], [是否支持即时编译], [语言服务]),
  label: <tbl:Typst_intro>,
  [WebAPP], [Code Mirror], [wasm], [渲染图片], [是], [优秀],
  [VSCode], [VSCode], [native], [webview], [是], [良好],
  [neovim], [neovim], [native], [webview], [是], [良好],
  [Emacs], [Emacs], [native], [webview], [是], [良好],
  [typst-cli], [任意编辑器], [native], [PDF阅读器], [否], [无],
)

= Typst使用说明<chap:guide>

为了方便使用并更好地展示Typst的现代排版特性，本模板框架和文件结构经过精细设计，尽可能模块化各个功能和板块，以方便用户进行高效编辑。

== 项目结构简介

=== 编译方法

Typst CLI 提供两种编译方式：

(a) `compile`：用于单次编译生成 PDF

(b) `watch` ：持续监听文件变更并自动重新编译。

本模板默认使用系统字库中的字体（如 macOS 的宋体/黑体）。如需指定字体目录，可通过 `--font-path` 选项指定，即：```bash typst compile template/thesis.typ --font-path fonts```。此外，`--open` 选项可在编译完成后自动打开 PDF，`-o <FILE>` 可指定输出文件路径。


=== 项目根目录

(a) `lib.typ`：模板库入口文件，定义了 `documentclass` 函数，用于配置文档类型、字体、论文信息等全局参数。

(b) `typst.toml`：模板配置文件，包含模板元数据、版本信息及导出配置。

(c) `README.md`：模板说明文档。

(d) `LICENSE`：开源许可证文件。

(e) `Makefile`：编译脚本，提供便捷的编译命令。

(f) `format-typst.sh`：代码格式化脚本。

=== template 文件夹

存放论文主文件及章节内容，是撰写论文时主要关注和修改的位置。当前结构仅供参考，用户可按个人习惯自由组织。

(a) `thesis.typ`：论文主文件，包含文档配置、页面生成及章节引用。

(b) `ref.bib`：参考文献数据库文件

(c) `images/`：图片资源目录


=== layouts 文件夹

包含文档布局定义文件，控制论文各部分的页面布局。

(a) `doc.typ`：文档整体布局设置，包含页面尺寸、页边距、页眉页脚等。

(b) `preface.typ`：前言部分布局（摘要、目录等）。

(c) `mainmatter.typ`：正文部分布局。

(d) `appendix.typ`：附录部分布局。

=== pages 文件夹

包含各类页面的具体实现，如封面、声明、摘要等。

(a) `master-cover.typ` / `bachelor-cover.typ`：研究生/本科生封面页。

(b) `master-decl-page.typ` / `bachelor-decl-page.typ`：研究生/本科生声明页。

(c) `master-abstract.typ` / `bachelor-abstract.typ`：中文摘要页。

(d) `master-abstract-en.typ` / `bachelor-abstract-en.typ`：英文摘要页。

(e) `outline-page.typ`：目录页。

(f) `list-of-figures-and-tables.typ`：图表目录页。

(g) `notation.typ`：符号表页。

(h) `acknowledgement.typ`：致谢页。

(i) `backmatter.typ`：后置部分（作者简介、学术成果等）。

(j) `fonts-display-page.typ`：字体展示测试页。

=== utils 文件夹

包含各类工具函数和辅助模块。

(a) `bilingual-bibliography.typ`：双语参考文献处理。

(b) `custom-figure.typ`：模板内双语图表封装（`bifigure`, `bitable`，供论文正文直接调用，默认避免图表标题与主体跨页拆分）。

(c) `bilingual-figured.typ`：通用图表编号/双语标题引擎（可独立作为外部包引用）。

(d) `continued-table.typ`：续表工具（统一提供 `auto-table` 自动续表与 `continued-table` 手动续表）。

(e) `aligned-equation.typ`：多行对齐公式。

(f) `custom-numbering.typ`：自定义章节编号样式。

(g) `style.typ`：字体和样式定义。

=== 其他文件夹

`docs` 文件夹存放模板的相关文档，如定制指南、版权声明等。

== 功能介绍

=== 图片

论文中图片的插入通常分为单图和多图，下面分别加以介绍：

(a) 单图插入

使用 `bifigure` 函数插入单图，该函数基于原生 `figure` 函数封装，支持双语标题。模板默认启用分章编号，建议统一使用带前缀引用：图片 `@fig:label`、表格 `@tbl:label`、公式 `@eqt:label`。模板中的双语图表样式由 `thesis-bilingual-caption-style` 统一配置。

#bifigure(
  // 示例占位图（发布包不含校徽文件）：用自己的图片替换该 rect 即可
  rect(width: 6cm, height: 3cm, fill: luma(235), stroke: (
    paint: luma(180),
    thickness: .5pt,
  )),
  caption-zh: [示例图片],
  caption-en: [Example Figure],
) <example-fig>

如 @fig:example-fig 所示。

(b) 多图插入

使用 `grid` 函数实现多图排列，每个子图仍使用 `bifigure` 函数以支持独立的双语标题。子图可通过 `note` 参数添加注释，注释会显示在子图标题下方，并以"注："开头。

若需要调整双语标题行距、段前段后间距或跨页策略，可在
`utils/custom-figure.typ` 中修改 `thesis-bilingual-caption-style`。

=== 表格

#align(center, (
  stack(dir: ltr)[
    #bitable(
      table(
        align: center + horizon,
        columns: 4,
        [t], [1], [2], [3],
        [y], [0.3s], [0.4s], [0.8s],
      ),
      caption-zh: [常规表],
      caption-en: [Regular Table],
    ) <timing>
  ][
    #h(50pt)
  ][
    // @typstyle off
    #bitable(
      table(
        columns: 4,
        stroke: none,
        table.hline(),
        [t], [1], [2], [3],
        table.hline(stroke: .5pt),
        [y], [0.3s], [0.4s], [0.8s],
        table.hline(),
      ),
      caption-zh: [三线表],
      caption-en: [Three-line Table],
    ) <timing-tlt>
  ]
))

#bitable(
  table(
    columns: 3,
    align: center,
    table.header([项目], [数值], [单位]),
    [A], [10.5], [cm],
    [B], [20.3], [kg],
    [C], [15.2], [m/s],
  ),
  caption-zh: [带注释的实验数据表],
  caption-en: [Experimental Data Table with Note],
  note: [所有数值均为三次测量的平均值。],
) <with-note>

上述表示例可通过 @tbl:timing、@tbl:timing-tlt、@tbl:with-note 引用。

==== 自动续表

当表格数据较多需要跨页时，使用 `auto-table` 可以自动在续页显示"续表"标记和表头。
`auto-table` 会主动采用可分页渲染，因此不受 `bitable` 默认 `keep_together: true` 的防跨页约束，适合长表。

#let regional-base = (
  ([北京], [41611], [5.2], [2184], [190580]),
  ([上海], [47218], [5.0], [2487], [189880]),
  ([广东], [135010], [4.8], [12701], [106310]),
  ([江苏], [128222], [5.8], [8515], [150520]),
  ([浙江], [82553], [6.0], [6577], [125520]),
  ([山东], [92069], [5.5], [10163], [90590]),
  ([四川], [60133], [5.8], [8372], [71830]),
  ([湖北], [55803], [5.6], [5775], [96620]),
  ([福建], [54355], [5.1], [4188], [129800]),
  ([湖南], [50015], [4.9], [6622], [75530]),
  ([河北], [36137], [5.3], [5665], [64280]),
  ([安徽], [38728], [5.7], [5142], [70820]),
  ([河南], [48206], [5.4], [6478], [71050]),
  ([广西], [23778], [4.6], [3038], [49320]),
  ([江西], [26907], [5.0], [3481], [77230]),
  ([山西], [23134], [5.1], [3056], [49780]),
)

#let regional-rows = ()
#for round in range(1, 6) {
  for row in regional-base {
    regional-rows.push(row.at(0))
    regional-rows.push(row.at(1))
    regional-rows.push(row.at(2))
    regional-rows.push(row.at(3))
    regional-rows.push(row.at(4))
  }
}

// @typstyle off
#auto-table(
  caption-zh: [各地区经济指标],
  caption-en: [Regional Economic Indicators],
  columns: 5,
  align: center,
  stroke: none,
  header: (
    table.hline(), [地区], [GDP（亿元）], [增长率（%）], [人口（万）], [人均GDP（元）],
    table.hline(stroke: .5pt),
  ),
  label: <regional>,
  ..regional-rows,
  table.hline(),
)

自动续表示例可通过 @tbl:regional 引用。

==== 手动续表

如果不启用自动续表，或希望精确控制续表位置，可以使用 `continued-table`：

// 先创建原表
#bitable(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    stroke: none,
    table.hline(),
    [项目], [测试组], [数值], [单位],
    table.hline(stroke: .5pt),
    [A], [I], [10.5], [cm],
    [B], [I], [20.3], [kg],
    [C], [I], [15.2], [m/s],
    [D], [I], [8.7], [kg],
    table.hline(),
  ),
  caption-zh: [实验数据],
  caption-en: [Experimental Data],
) <manual-continued>

// 手动续表
#continued-table(
  <tbl:manual-continued>,
  align(center)[
    #table(
      columns: (auto, auto, auto, auto),
      align: center + horizon,
      stroke: none,
      table.hline(),
      [项目], [测试组], [数值], [单位],
      table.hline(stroke: .5pt),
      [E], [II], [11.8], [cm],
      [F], [II], [19.6], [kg],
      [G], [II], [14.1], [m/s],
      [H], [II], [9.2], [kg],
      table.hline(),
    )
  ],
  note: [续表数据为补充实验结果。],
)

原表可通过 @tbl:manual-continued 引用。

==== 卧排表

当表格列数较多、横向宽度超出版心时，可使用 `landscape: true` 将整表逆时针旋转 90°，使表顶朝页面左侧、表底朝右侧，符合《撰写规范》"顶左底右"的方位要求（见@tbl:landscape-table）。卧排表不跨页，应控制在一页之内；其标题与注释随表格一同旋转，方位保持一致。`bitable` 与 `auto-table` 均支持该参数。

#bitable(
  table(
    columns: 7 * (auto,),
    align: center + horizon,
    stroke: none,
    table.hline(),
    [序号], [样本编号], [测量项目], [测量值], [单位], [方法], [备注],
    table.hline(stroke: .5pt),
    [1], [S-001], [长度], [12.45], [cm], [游标卡尺], [室温],
    [2], [S-002], [质量], [34.80], [g], [电子天平], [三次平均],
    [3], [S-003], [温度], [25.3], [℃], [热电偶], [稳态读数],
    [4], [S-004], [压强], [101.3], [kPa], [气压计], [海拔修正],
    [5], [S-005], [频率], [50.0], [Hz], [频率计], [市电标称],
    table.hline(),
  ),
  caption-zh: [多列宽表（卧排）],
  caption-en: [Wide Multi-column Table (Landscape)],
  landscape: true,
) <landscape-table>

卧排表可通过 @tbl:landscape-table 引用，引用文本仍按常规横排渲染。

=== 数学公式

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用按章节编号的数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

较长的数学公式如必须分行书写，只能在`+,-,×,÷,＜,＞`等运算符
之后转行，序号编于最后一行右顶格使用 `aligned-equation` 可将编号对齐到最后一行右侧：

#aligned-equation[$
  f(x) & = a x^2 + b x + c \
       & = a(x^2 + b/a x) + c \
       & = a(x + b/(2a))^2 + c - b^2/(4a)
$] <quadratic>

由 @eqt:quadratic 可知，任意二次函数都可以化为顶点式。

=== 参考文献

// 顺序编码制（gb-7714-2015-numeric）：序号置于方括号中并上标，由 CSL 自动渲染。
// 单篇引用：图书[1]。
// 同一处引用多篇：将多个 @key 紧邻书写（或用 #cite 相邻调用），CSL 自动合并为
//   [1,2]（非连续，英文逗号分隔）、[1-3]（连续，短横线连接），勿用分号隔开。
// 两处独立引用：各自上标，如 [1]和会议[2]。
可以像这样引用参考文献：图书#[@蒋有绪1998]和会议#[@中国力学学会1990]。同一处引用多篇文献时紧邻书写，非连续如@蒋有绪1998@中国力学学会1990，连续如@蒋有绪1998@中国力学学会1990@WHO1970。

=== 代码块

代码块支持语法高亮。引用时需要加上标签 @code

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption: [代码块],
) <code>

= 中国科学院大学研究生学位论文撰写规范指导意见（节选）<chap:ucas>

学位论文是研究生在掌握已有的科学知识的基础上，运用科学思维和一定的科学方法、技术与工具，面向特定的科学领域所存在的科学问题，开展创新性研究而产生的科学研究成果。

学位论文是研究生科研工作成果的集中体现，是评判学位申请者学术水平、授予其学位的主要依据，是科研领域重要的文献资料。撰写学位论文是对研究生科学研究能力的基本训练，是研究生学业与研究成效的基本检验，也是科研与创新能力的重要体现。

为提高研究生学位论文的撰写质量，促进学位论文在内容和格式上的规范化，参照《学位论文编写规则》（GB/T 7713.1—2006）、《信息与文献 参考文献著录规则》（GB/T 7714—2015）和《学术出版规范
期刊学术不端行为界定》（CY/T
174—2019）等国家有关标准，特制定本指导意见（2021年修订）。各学科群学位评定分委员会（以下简称各学科群分会）可结合本学科领域的特点，参考本指导意见，制订符合本学科领域特点与要求的学位论文撰写具体要求。

本指导意见从2023年冬季批次开始实施。

== 组成及要求

学位论文一般由以下几个部分组成：封面、原创性声明及授权使用声明、摘要、目录、符号说明（若有）、正文、参考文献、附录（若有）、致谢、作者简历及攻读学位期间发表的学术论文与其他相关学术成果等。

=== 封面

一律采用中国科学院大学规定的统一中英文封面，封面包含内容如下：
#set enum(numbering: "（1）")
+ 密级,涉密或延迟公开论文必须在论文封面标注密级，同时注明保密年限。公开论文不标注密级，可删除此行。
+ 论文题目，应简明扼要地概括和反映整个论文的核心内容，一般不宜超过25个汉字（符），英文题目一般不应超过150个字母，必要时可加副标题。题目中应尽量避免使用缩略词、首字母缩写词、字符、代号和公式等。
+ 作者姓名,根据《中国人名汉语拼音字母拼写规则》（GB/T 28039—2011），英文封面中的姓和名分写，姓在前，名在后，姓名之间用空格分开。姓和名需写全拼，姓全大写，名首字母大写。外国留学生姓名书写顺序以护照格式为准，字母全部大写。
+ 指导教师，需同时填写导师姓名、专业技术职务和工作单位。如果有多位导师（均需经培养单位批准，并在学籍系统备案），第一导师在前，第二导师等依次在后。学位论文在指导小组的指导下完成的，应注明指导小组成员相应信息。
+ 学位类别，包括学科门类（学术型）或专业学位类别以及学位级别。学科门类如理学、医学等，专业学位类别如应用统计、工商管理等。学位级别包括硕士、博士。
+ 学科专业，填写攻读学位的一级学科/二级学科或专业学位类别/领域全称，须与学籍信息一致，不可用简写。
+ 培养单位，填写就读研究所或学院、系全称，如中国科学院××研究所、中国科学院大学××学院。
+ 时间，填写论文提交学位授予单位的年月，使用阿拉伯数字标注。一般夏季申请学位的论文标注6月，冬季申请学位的论文标注12月。例如：2023年6月，2023年12月。

=== 原创性声明及授权使用声明

本部分内容提供统一的模版，提交时作者和导师须亲笔签名。如遇导师无法签字时，培养单位应做出适当处理。

=== 摘要和关键词

论文摘要包括中文摘要和英文摘要（Abstract）两部分。论文摘要应概括地反映出本论文的主要内容，说明本论文的主要研究目的、内容、方法、结论。要突出本论文的创造性成果或新见解，不宜使用公式、图表、表格或其他插图材料，不标注引用文献。中文摘要的字数由各学科群分会根据本分会涉及学科专业的特点提出具体要求。英文摘要与中文摘要内容应保持一致。留学生用其他语种撰写学位论文时，应有详细的中文摘要，字数由各学科群分会具体制定，建议一般不少于5000字。

摘要最后注明本文的关键词（3～5个）。关键词是为了文献标引和检索工作，从论文中选取出来，用以表示全文主题内容信息的单词或术语。关键词以显著的字符另起一行并隔行排列于摘要下方，左顶格，中文关键词间用中文逗号隔开。英文关键词应与中文关键词对应，首字母应大写，用英文逗号隔开。

摘要应另起一页，与正文前的内容连续编页（用罗马字符）。

=== 目录

目录应包括论文正文中的全部内容的标题，以及参考文献、附录（若有）和致谢等，不包括中英文摘要。目录页由论文的章、条、附录等序号、名称和页码组成。正文章节题名要求最多编到第三级标题，即×.×.×（如1.1.1）。一级标题顶格书写，二级标题缩进一个汉字符位置，三级标题缩进两个汉字符位置。论文中若有图表，应有图表目录，置于目录页之后，另页编排。图表目录应有序号、图题或表题和页码。

目录应另起一页，与正文前的内容连续编页（用罗马字符）。

=== 符号说明（若有）

如果论文中使用了大量的物理量符号、标志、缩略词、专门计量单位、自定义名词和术语等，应编写成注释说明汇集表。若上述符号等使用数量不多，可以不设此部分，但必须在论文中首次出现时加以说明。
论文中若有符号说明，应置于目录之后、正文之前，另起一页，与正文前的内容连续编页（用罗马字符）。

=== 正文
正文一般包括绪论、论文主体、研究结论与展望等部分。

#set enum(numbering: "（1）")
+ 绪论应包括选题的背景和意义，国内外相关研究成果与进展述评，本论文所要解决的科学与技术问题、所运用的主要理论和方法、基本思路和论文结构等。绪论应独立成章，用足够的文字叙述，不与摘要雷同。要实事求是，不夸大也不弱化前人的工作和自己的工作。
+ 论文主体是正文的核心部分，占主要篇幅，它是将学习和研究过程中调查、观察和测试所获得的材料和数据，经过思考判断、加工整理和分析研究，进而形成论点。依据学科专业及具体选题，论文主体可以有不同的表现形式，可以按照章与节的结构表述，也可以按照“研究背景与意义—研究方法与过程—研究结果与讨论”的表述形式组织论文。但主体内容必须实事求是，客观诚实，准确完备，合乎逻辑，层次分明，简明可读。
+ 研究结论是对整个论文主要成果的总结，不是正文中各章小结的简单重复，应准确、完整、明确、精炼。应明确凝练出本研究的主要创新点，对论文的学术价值和应用价值等加以分析和评价，说明本项研究的局限性或研究中尚难解决的问题，并提出今后进一步在本研究方向进行研究工作的设想或建议。结论部分应严格区分本人研究成果与他人科研成果的界限。

=== 参考文献

本着严谨求实的科学态度撰写论文，凡学位论文中有引用或参考、借鉴他人思想或成果之处，均应按一定的引用规范，列于文末（通篇正文之后），参考文献部分应与正文的文献引用一一对应，注重合理引用，严禁抄袭剽窃等学术不端行为。

=== 附录（若有）

主要列入正文内过分冗长的公式推导、供查读方便所需的辅助性数学工具或表格、数据图表、程序全文及说明、调查问卷、实验说明等。

=== 致谢

对给予各类资助、指导和协助完成研究工作，以及提供各种对论文工作有利条件的单位及个人表示感谢。致谢应实事求是，切忌浮夸与庸俗之词。致谢末尾应具日期，日期与论文封面一致。

=== 作者简历及攻读学位期间发表的学术论文与其他相关学术成果

作者简历应包括从大学起到申请学位时的个人学习工作经历。按学术论文发表的时间顺序，列出作者本人在攻读学位期间发表或已录用的学术论文清单（著录格式同参考文献）。其他相关学术成果可以是申请的专利、获得的奖项及完成的项目等代表本人学术成就的各类成果。

== 撰写要求

=== 学位论文基本要求

学位论文必须是一篇系统的、完整的学术论文，遵循既定的学术规范与要求，不仅要符合学位论文的形式规范，更要符合学位论文的质量规范。做到：学术观点明确，立论正确，方法科学，材料翔实，数据可靠，推理严谨，论证充分，引用规范，结构合理，层次分明，文字通顺，表达准确，学风严谨。研究成果体现作者独到的学术见解、科学论证与创新性结论，表明作者掌握了坚实的基础理论和系统的专门知识，具有独立地从事科学研究的能力。

硕士学位论文选题应为本学科重要领域，有一定的理论意义或应用价值；在理论或方法上有一定的创新，解决了科学或生产实践中某一项重要的问题，取得重要的研究成果，具有较好的社会效益或应用前景。

博士学位论文选题应为本学科前沿领域，有重要的理论意义或应用价值；在理论或方法上有较大的创新，解决了科学或生产实践中某一项重大的问题，取得突破性的研究成果，具有重要的社会效益或应用前景。

=== 论文原创性要求

学位论文应为学位申请者在导师的指导下独立完成的科学研究成果，为作者本人的原创性成果，系研究生经过多年的专业学习和科学研究，运用科学思维、科学方法或工具，探索科学领域中的某一科学问题，提出问题，分析问题，解决问题。学位论文中要有清晰完整的文献综述，但不能以文献综述来代替学位论文。论文引用规范合理，没有伪造、篡改、剽窃、他人代写、论文买卖及其它学术不端行为。

=== 论文创新性要求

学位论文的研究既包括创造知识，即创新、发现和发明，是对未知世界及其规律的探索，也包括整理知识，即对已有知识分析整理，使其规范化、系统化，是对已有知识的传承。创新活动，贯穿了学位论文研究与写作的全过程，如提出新的学术思想、科学概念、假说、学说、定理、定律，设计新的观察方法和实验手段，建立新的科学模型，研制出新的产品，设计出新的工艺流程，发现新的物种等。学位论文的价值在于探索未知，发现科学发展中的规律与特征。学位论文要体现其应有的严谨性与探索性，在原创性的基础上实现对已有知识的超越、突破或颠覆，发现前所未有的科学问题，提出前所未有的分析论证，得出前所未有的科学结论。

=== 学位论文的字数要求
学位论文最重要的意义在于其学术研究的创新性，应将学位论文的质量水平作为主要考量，不以字数多少作为特别要求，但各学科群分会可根据本领域涉及的学科专业特点做相应规定。

=== 文字、标点符号和数字

除外国来华留学生、外语专业研究生以及特殊需要外，学位论文一律用国家正式公布实施的简化汉字书写。标点符号的用法以《标点符号用法》（GB/T 15834—2011）为准。数字用法以《出版物上数字用法》（GB/T 15835—2011）为准。

外国来华留学生可用中文或英文撰写学位论文，但应有详细的中英文摘要。外语专业的学位论文应用所学专业相应的语言撰写，摘要应使用中文和所学专业相应的语言对照撰写。

为了便于国际合作与交流，中文学位论文亦可有英文或其他文字的副本。

=== 论文正文

（1）章节和各章标题

论文正文须由另页右页（奇数页）开始，用阿拉伯数字连续编码，一直到全文最后。正文内部新章节无须另页右页（奇数页）开始。
论文可参考“绪论-研究背景与意义-研究方法与过程-研究结果与讨论-研究结论与展望”的结构形式撰写，各主体研究内容可分别单独成为章节并作为章节标题使用。

各章标题中尽量不采用英文缩写词，对必须采用者，应使用本行业的通用缩写词。标题中尽量不使用标点符号。

（2）序号

#strong[标题序号]

论文标题分层设序。层次以少为宜，根据实际需要选择。各层次标题一律用阿拉伯数字连续编号。以三级标题为宜，最多四级。若确需要再增加一级，以小括号形式表示；不同层次的数字之间用小圆点“.”相隔，末位数字后面不加点号，如“1.1”，“1.1.1”等；章的标题居中排版，各层次的序号均左起顶格排，序号与题名间空一个汉字符。

#strong[图表等编号]

论文中的图、表、附注、公式、算式等，一律用阿拉伯数字分章依序连续编码。其标注形式应便于互相区别，如：图1-1（第1章第一个图）、图2-2（第2章第二个图）；表3-2（第3章第二个表）等。附录的图表参考正文的编号方式，如附图1-1或附表1-1。

#strong[页码]

正文页码从绪论开始按阿拉伯数字（1，2，3……）连续编排，页码应位居左页左下角、右页右下角；正文前的部分（中英文摘要、目录等）用大写罗马数字（I，II，III…）单独编排，页码位于页面下方居中。

（3）页眉

页眉从摘要开始，奇数页上标明“摘要”、“Abstract”、“目录”、“图表目录”等，偶数页上标明论文题目（英文摘要标明英文题目）。正文（即第1章开始到最后一章）的页眉，奇数页上标明每一章名称，偶数页上标明论文题目。参考文献、附录、致谢等的页眉，奇数页标明“参考文献”、“附录”、“致谢”等，偶数页标明论文题目。页眉居中设置。

（4）名词和术语

科技名词术语及设备、元件的名称，应采用全国科学技术名词审定委员会公布的权威标准或其他相关权威信息源规定的术语或名称。标准中未规定的术语要采用行业通用术语或名称。全文名词术语必须统一。一些特殊名词或新名词应在适当位置加以说明或注解。双名法的生物学名部分均为拉丁文，并为斜体字。

采用英语缩写词时，除本行业广泛应用的通用缩写词外，文中第一次出现的缩写词应该用括号注明英文原词。新的外来名词应用括号注明英语全称和缩写语。

（5）量和单位

量和单位要严格执行《国际单位制及其应用》（GB 3100-93）、《有关量、单位和符号的一般原则》（GB3101—93）有关量和单位的规定。量的符号一般为单个拉丁字母或希腊字母，并一律采用斜体（pH例外）。

（6）图和表

论文中若有图和表，应设置图表目录，先列图后列表，置于目录页后，另页编排。

#strong[(1) 图]

图片大小适当，图边界在页面范围内（图边界离页面边界距离大于页边距）。若图片中包含文字，文字大小不超过正文文字大小。 图包括曲线图、构造图、示意图、框图、流程图、记录图、地图、照片等，宜插入正文适当位置。引用的图必须注明来源。具体要求如下：

- 图应具有“自明性”，即只看图、图题和图注，不阅读正文，就可理解图意。每一图应有简短确切的图题，连同图序置于图下居中。
- 图中的符号标记、代码及实验条件等，可用最简练的文字横排于图框内或图框外的某一部位作为图注说明，全文统一。图题建议用中文及英文两种文字表达。
- 照片图要求主要显示部分的轮廓鲜明，便于制版，如用放大、缩小的复制品，必须清晰，反差适中，照片上应有表示目的物尺寸的标尺。
- 图片一般设为高6cm×宽8cm，但高、宽也可根据图片量及排版需要按比例缩放。中文（宋体）英文（Times New Roman）图注为五号字，1.25倍行距。
- 文中尽量不用世界地图、全国地图！如果一定要用，凡涉国界图件（国内部分地区、全国、世界部分地区、全球）必须使用自然资源部标准地图底图（下载网址：http://bzdt.ch.mnr.gov.cn），所用底图边界要完全无修改（包括南海诸岛位置），为适应排版时图的缩放，比-
  例尺一律用线段比例尺，而不用数字比例尺。并在图题下注明“注：该图基于自然资源部标准地图服务网站下载的审图号为GS(2021)××××号的标准地图制作，底图边界无修改。”

#strong[(2) 表]

表的编排一般是内容和测试项目由左至右横读，数据依序竖排，应有自明性，引用的表必须注明来源。具体要求如下：

- 每一表应有简短确切的题名，连同表序置于表上居中。必要时，应将表中的符号、标记、代码及需说明的事项，以最简练的文字横排于表下作为表注。表题建议用中文及英文两种文字表达。
- 表内同一栏数字必须上下对齐。表内不应用“同上”、“同左”等类似词及“″”符号，一律填入具体数字或文字，表内“空白”代表无此项，“—”或“…”（因“—”可能与代表阴性反应相混）代表未发现，“0”该表实测结果为零。表内未测出值可以用“N.D.
  ”表示。
- 表格尽量用“三线表”，避免出现竖线，避免使用过大的表格，确有必要时可采用卧排表，正确方位应为“顶左底右”，即表顶朝左，表底朝右。表格太大需要转页时，需要在续表表头上方注明“续表”，表头也应重复排出。
- 中文（宋体）英文（Times New Roman）表注为五号字，1.25倍行距。

（7）表达式

论文中的表达式需另行起，原则上应居中。若有两个以上的表达式，应从“1”开始的阿拉伯数字进行编号，并将编号置于括号内。编号采用右端对齐。表达式较多时可分章编号。

较长的表达式如必须转行，只能在+，-，×，÷，＜，＞等运算符之后转行，序号编于最后一行右顶格。

=== 参考文献
参考文献格式规范参照《信息与文献 参考文献著录规则》（GB/T
7714—2015），或可参照国际刊物通行的参考文献格式。各学科群分会可根据本学科的一般规范制定相应的参考文献格式。文后参考文献和参考文献在正文中的标注方式可采用“顺序编码制”或“著者—出版年制”。确定采用某种方法后，文后参考文献和参考文献在正文中的标注方式要对应。

文后参考文献按“顺序编码制”组织时，各篇文献应按正文部分首次引用时标注的序号依次列出；文后参考文献按“著者—出版年制”组织时，条目不排序号，先按语种分类排列，语种顺序是：中文、日文、西文、俄文、其他文种；然后按著者字序和出版年排列。中文和日文按第一著者的姓氏笔画排序，中文也可按汉语拼音字母顺序排列，西文和俄文按第一著者姓氏字母顺序排列。当一个著者有多篇文献并为第一著者时，该著者单独署名的文献排在前面（并按出版年份的先后排列），接着排该著者与其他人合写的文献。
文后参考文献加标题“参考文献”，并列入全文目录。 凡正文里标注了参考文献的，其文献都必须列入文后参考文献。文后参考文献应集中著录于正文之后，不分章节著录。 正文中未被引用但被阅读或具有补充信息的文献可集中列入附录中，其标题为“荐读书目”。

详细内容请参考《中国科学院大学研究生学位论文撰写规范指导意见》。

== 排版与印刷要求

#bitable(
  table(
    align: center,
    columns: 2,
    [项目名称], [要求],
    [纸张], [A4（210mm×297mm），幅面白色],
    [页面设置], [上、下2.54cm，左、右3.17cm，页眉、页脚距页边界1.5cm],
    [封面], [采用国科大统一格式],
    [页眉], [宋体小五号居中，英文和阿拉伯数字用Times New Roman体],
    [页码], [Times New Roman体小五号],
  ),
  caption-zh: [排版和印刷要求],
  caption-en: [Typesetting and Printing Requirements],
) <tbl:typo_and_print_require>

=== 印刷及装订要求
论文封面使用中国科学院大学统一的封面格式。学位论文用A4标准纸（210 mm×297
mm）打印、印刷或复印，按顺序装订成册。自中文摘要起双面印刷，之前部分单面印刷。中文摘要、英文摘要、目录、论文正文、参考文献、附录、致谢、作者简历及攻读学位期间发表的学术论文与其他相关学术成果等，均须由另页右页（奇数页）开始。论文必须用线装或热胶装订，不使用钉子装订。封面用纸一般为150克花纹纸（需保证论文封面印刷质量，字迹清晰、不脱落），博士学位论文封面颜色为红色，硕士学位论文封面颜色为蓝色。

=== 书脊
学位论文的书脊用黑体，英文和阿拉伯数字用Times New Roman体，字号一般为小四号，可根据论文厚度适当调整。上方写论文题目，中间写作者姓名，下方写“中国科学院大学”，距上下边界均为3cm左右。


// 中英双语参考文献
// 默认使用 gb-7714-2015-numeric 样式
// bilingual-bibliography 已内置奇数页起始分页（见 utils/bilingual-bibliography.typ），
// 无需在此额外 pagebreak，否则会产生多余空白页。
#bilingual-bibliography(full: true)

// 附录
#show: appendix

= 附录

== 附录中的多行公式

附录中的多行公式使用 `aligned-equation` 函数，编号对齐到最后一行右侧：

#aligned-equation[$
  e^x & = sum_(n=0)^infinity x^n / n! \
      & = 1 + x + x^2/2 + x^3/6 + dots.c
$] <app-taylor>

由 @eqt:app-taylor 可以得到自然指数函数的 Taylor 展开。

== 附录中的图表

附录中的图表与正文使用相同的 `bifigure`/`bitable`/`auto-table`/`continued-table` 函数，无需额外传参。模板会自动将附录图表的前缀由正文的"图/表"切换为"附图/附表"（英文 `Appendix Figure`/`Appendix Table`），并使编号在附录内从 1 重新计数（如附图1-1、附表1-1），符合《撰写规范》"附录的图表参考正文的编号方式，如附图1-1或附表1-1"的要求。引用方式与正文一致，统一使用带前缀引用：`@fig:label`、`@tbl:label`。

=== 附录中的图与表

#bifigure(
  // 示例占位图（发布包不含校徽文件）：用自己的图片替换该 rect 即可
  rect(width: 6cm, height: 3cm, fill: luma(235), stroke: (
    paint: luma(180),
    thickness: .5pt,
  )),
  caption-zh: [附录插图示例],
  caption-en: [Appendix Figure Example],
) <app-emblem>

如 @fig:app-emblem 所示，附录插图自动以"附图1-1"编号。

#bitable(
  table(
    columns: (auto, auto),
    align: center + horizon,
    stroke: none,
    table.hline(),
    [项目], [说明],
    table.hline(stroke: .5pt),
    [前缀], [附图 / 附表],
    [编号], [附录内从 1 重新计数],
    table.hline(),
  ),
  caption-zh: [附录表格示例],
  caption-en: [Appendix Table Example],
) <app-summary>

如 @tbl:app-summary 所示，附录表格自动以"附表1-1"编号。

=== 附录中的续表

附录中的 `auto-table` 与 `continued-table` 同样会自动使用"附表"前缀。当附录表格数据较多需要跨页时，使用 `auto-table` 可自动在续页显示"续表"标记和表头；若希望精确控制续表位置，可先创建原表再用 `continued-table` 续接，其 `source` 参数须使用带前缀的标签 `<tbl:...>`。

#auto-table(
  caption-zh: [附录自动续表示例],
  caption-en: [Appendix Auto-continued Table Example],
  columns: 2,
  align: center,
  stroke: none,
  header: (
    table.hline(),
    [序号],
    [说明],
    table.hline(stroke: .5pt),
  ),
  label: <app-auto>,
  [1],
  [附录续表第一项],
  [2],
  [附录续表第二项],
  [3],
  [附录续表第三项],
  [4],
  [附录续表第四项],
  [5],
  [附录续表第五项],
  [6],
  [附录续表第六项],
  [7],
  [附录续表第七项],
  [8],
  [附录续表第八项],
  [9],
  [附录续表第九项],
  [10],
  [附录续表第十项],
  [11],
  [附录续表第十一项],
  [12],
  [附录续表第十二项],
  [13],
  [附录续表第十三项],
  [14],
  [附录续表第十四项],
  [15],
  [附录续表第十五项],
  [16],
  [附录续表第十六项],
  [17],
  [附录续表第十七项],
  [18],
  [附录续表第十八项],
  [19],
  [附录续表第十九项],
  [20],
  [附录续表第二十项],
  table.hline(),
)

自动续表示例可通过 @tbl:app-auto 引用。

// 手动续表：source 须使用带前缀的标签 <tbl:...>
#continued-table(
  <tbl:app-summary>,
  align(center)[
    #table(
      columns: (auto, auto),
      align: center + horizon,
      stroke: none,
      table.hline(),
      [项目], [补充说明],
      table.hline(stroke: .5pt),
      [前缀], [由"表"切换为"附表"],
      [编号], [与原表一致，附表1-1],
      table.hline(),
    )
  ],
  note: [附录续表继承原表的"附表"前缀与编号。],
)

=== 无编号的展示性表格

附录中的对照表、说明性表格若无需编号、无需收录于图表目录，可直接使用原生 `table` 函数，并用 `#align(center)[#strong[...]]` 手动添加居中加粗标题。此类表格不参与图表编号，与上文 `bitable`（编号为附表1-1、收录于图表目录）形成互补：需要引用的表格用 `bitable`，仅作展示的表格用原生 `table`。

#align(center)[#strong[学位类别中英文对照表（节选）]]

#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: center + horizon,
    stroke: none,
    table.hline(),
    table.header([学位类别], [中文名称], [英文名称]),
    [学术型博士], [理学博士], [Doctor of Philosophy],
    [学术型硕士], [理学硕士], [Master of Natural Science],
    [专业学位], [工程硕士], [Master of Engineering],
    table.hline(),
  )
]

// 致谢
#acknowledgement[
  感谢 modern-ucas-thesis。
]


#backmatter[
  // 作者简历部分
  #strong[作者简历：]


  ××××年××月——××××年××月，在××大学××院（系）获得学士学位。

  ××××年××月——××××年××月，在××大学××院（系）获得硕士学位。

  ××××年××月——××××年××月，在中国科学院××研究所（或中国科学院大学××院系）攻读博士/硕士学位。

  工作经历：


  // 学术论文部分
  #v(1em)
  #strong[已发表（或正式接受）的学术论文：（书写格式同参考文献）]

  (1) 已发表工作 1

  (2) 已发表工作 2

  // 专利部分
  #v(1em)
  #strong[申请或已获得的专利：（无专利时此项不必列出）]

  (1) 专利名称

  (2) 专利名称

  // 研究项目及获奖情况
  #v(1em)
  #strong[参加的研究项目及获奖情况：]

  (1) 项目名称

  (2) 获奖名称
]
