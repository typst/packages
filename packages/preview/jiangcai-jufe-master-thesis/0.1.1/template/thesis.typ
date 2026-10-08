//! 开发阶段用相对路径直接导入本地 lib.typ（改完即生效，无需同步 preview 缓存）；
//! ⚠️ 提交 PR 前必须切换为下面注释中的 @preview 写法（已发布模板的标准写法）
#import "@preview/jiangcai-jufe-master-thesis:0.1.1": *
// #import "../lib.typ": *

//! ============================================================
//! 江西财经大学硕士学位论文 Typst 模板 —— 使用教程示例文档
//! 本文件同时承担两个角色：
//! 1. 模板功能的完整示例：封面/声明/摘要/目录/正文/图表公式/参考文献/附录/致谢；
//! 2. Typst 语言与本模板的使用教程：正文以系统手册方式分章讲解常用写法。
//! 夹杂英文术语的常见写法——首次出现写"中文（English，ABBR）"，后文直接用缩写。
//! 使用时将各部分替换为你自己的论文内容即可。
//! ============================================================

//! 封面（中英文题目分两行；作者、导师、学位等信息请逐项替换）
#cover(
  zh-title1: [Typst学位论文排版实践教程],
  zh-title2: [——以江西财经大学硕士学位论文模板为例],
  en-title1: [A Practical Guide to Typst Theses],
  en-title2: [The JUFE Master Thesis Template],
  author: [章某某],
  mentor: [马某某],
  degree: [硕#h(1em)士],
  academy: [统计学院],
  subject: [电子排版],
  research: [Typst模板开发],
)

//! 独创性声明与使用授权说明（固定内容，一般无需修改）
#declaration()

//! 中文摘要与英文摘要（前置部分，罗马数字页码）
#show: typeset-fore
#abstract(
  zh-abstract: [
    Typst 是一款新兴的标记式电子排版系统（Markup-based Typesetting System），具有语法简洁、增量编译迅速、错误提示友好等特点，为学位论文排版提供了 LaTeX 之外的新选择。本教程以江西财经大学硕士学位论文格式规范为依据，系统介绍基于 Typst 的 jiangcai-jufe-master-thesis 模板的使用方法。该模板内置封面、独创性声明、中英文摘要、多套目录、图表公式与三线表环境、GB/T 7714 参考文献样式。字体严格使用规范指定的标准字体（宋体、黑体、楷体、仿宋及 Times New Roman 等，均为 Windows 系统自带），包内 `fonts/` 目录另存有这些字体文件，可供缺少字体的电脑安装使用。全文按照系统手册方式组织，依次说明 Typst 的安装与编译、文档组装顺序、文字段落排版、数学公式、插图与表格、代码与算法以及参考文献的写法，并以随机段落演示长篇正文的排版效果。借助本模板，作者只需关注论文内容本身，即可快速获得符合学校规范的排版结果。
  ],
  zh-keywords: [Typst；学位论文；排版模板；标记语言；GB/T 7714],
  en-abstract: [
    Typst is a new markup-based typesetting system featuring concise syntax, fast incremental compilation and friendly error messages, offering an alternative to LaTeX for thesis typesetting. Following the format regulations of Jiangxi University of Finance and Economics for master's theses, this guide systematically introduces the jiangcai-jufe-master-thesis package, which provides a cover page, an originality declaration, Chinese and English abstracts, multiple tables of contents, environments for figures, tables, equations, three-line tables and code listings, and a GB/T 7714 bibliography style. It uses the standard fonts required by the regulations (SimSun, SimHei, KaiTi, FangSong and Times New Roman, all supplied with Windows); copies of these font files are included in the package's fonts directory for installation on machines that lack them. The guide is organised as a systematic manual covering installation and compilation, document assembly, text formatting, mathematics, figures and tables, code and algorithms, and bibliographies, with placeholder paragraphs demonstrating the long-document layout. With this template, authors can focus on their content and quickly obtain a thesis that complies with the university regulations.
  ],
  en-keywords: [Typst; Degree thesis; Typesetting template; Markup language; GB/T 7714],
)

//! 目录（中文目录 / 英文目录 / 图、表、公式目录，均自动生成）
#multi-outline()

//! 缩略语对照表（前置部分可选页；如不需要，整段删除即可。
//! 标题用 #en[...] 标注英文后，会同时进入中英文目录，页码延续罗马数字）
#{
  set page(
    margin: (
      top: 3.5cm,
      bottom: 2.5cm,
      left: 2.5cm,
      right: 2.5cm,
    ),
    header-ascent: 0.5cm,
    header: context [
      #set par(spacing: 0.9em)
      #set text(font: ("Times New Roman", "SimSun"), size: zh(5))
      #set align(center + bottom)
      #let is-odd = calc.odd(counter(page).get().at(0))
      #let head-text = if is-odd {
        context paper-title.get()
      } else {
        calc-headings(query(heading.where(level: 1))).at(here().page() - 1)
      }
      #head-text
      #v(-6pt)
      #line(length: 100%, stroke: 0.5pt)
    ],
    footer-descent: 0.5em,
    footer: context [
      #set text(font: "Times New Roman", size: zh(-5))
      #set align(center + top)
      #counter(page).display("I")
    ],
  )
  show heading.where(level: 1): set align(center)
  set heading(level: 1, numbering: none)
  [
    #heading(level: 1)[缩略语对照表 #en[List of Abbreviations]]
    #v(0.5em)
    //! 与正文三线表一致：数据维护在 tables/缩略语对照表.xlsx 中，用 tlt() 读取生成。
    //! 前置部分的对照表不加 figure 题注，故不参与正文"表 X.X"编号，也不进入表目录
    #align(center)[
      #tlt(read("./tables/缩略语对照表.xlsx", encoding: none))
    ]
  ]
}

//! ==================== 正文（阿拉伯数字页码从 1 开始） ====================
//? 各级标题旁用 #en[English Title] 标注英文标题，英文目录自动提取；
//? 正文与中文目录不受影响；未标注的标题在英文目录中回退显示原文。
//? 注意：若标题需要加标签 <lab>，标签必须写在 #en[...] 之后，否则标签会打断标题体，
//? 导致英文标记脱离标题（如 `= 绪论 #en[Introduction] <first>`）。
#show: typeset-back

= Typst 与本模板简介 #en[Introduction to Typst and the Template] <first>

== Typst 简介 #en[What is Typst]

电子排版是学位论文写作中的重要环节。自 Donald E. Knuth 于 20 世纪 70 年代末创建 TeX 系统以来#[@knuth1986texbook]，以 Leslie Lamport 的 LaTeX 为代表的宏包长期是科技排版的事实标准#[@lamport1994latex]。然而传统 LaTeX 工作流存在编译链路复杂、辅助文件繁多、错误信息晦涩等问题。Typst 是 2023 年起开源的新一代标记式排版系统（Markup-based Typesetting System），由 Haug 等设计实现#[@haug2023typst]，其编译器以 Rust 编写、借助 WebAssembly（WASM）实现插件扩展，具有语法轻量、增量编译与即时预览、函数式样式系统等特点。

与"内容与格式分离"的 LaTeX 理念相似，Typst 同样以纯文本源文件描述文档，便于版本管理与协作；不同之处在于 Typst 将包管理、字体管理、引用与目录等功能全部内建，一条命令即可完成编译，无需配置复杂的工具链。本模板即在此基础上，将江西财经大学硕士学位论文的格式规范封装为可直接调用的函数库。

== 安装与编译 #en[Installation and Compilation]

Typst 提供 Windows、macOS 与 Linux 预编译版本，可通过官网下载，或使用系统包管理器安装，如 Windows 下执行 `winget install --id Typst.Typst`。安装后在终端执行 `typst --version` 确认版本，本模板要求编译器版本不低于 0.14.2。

常用编译命令如下：单次编译使用 `typst compile thesis.typ`；写作时使用 `typst watch thesis.typ` 可在保存后自动重编译；字体严格使用规范指定的标准字体（宋体、黑体、楷体、仿宋、Times New Roman、Courier New 等），均为 Windows 系统自带；编译时建议追加字体路径参数，即 `typst compile thesis.typ --font-path fonts`，缺少字体的电脑便直接加载包内 `fonts/` 目录中的标准字体文件，也可事先安装这些字体。完整的命令行参数说明可查阅官方文档#[@typst-docs]。

== 模板的获取与使用 #en[Obtaining and Using the Template]

本模板发布在 Typst Universe 官方包仓库#[@typst-universe]，包名为 `jiangcai-jufe-master-thesis`。使用时无需手动下载，只需在论文源文件首行写入导入语句 `#import "@preview/jiangcai-jufe-master-thesis:0.1.1": *`，编译器即会自动获取；离线环境下也可将包目录放入本地包缓存。模板目录中，`lib.typ` 为排版核心库，`template/thesis.typ` 即本教程示例文件，`fonts/` 存放标准字体文件（电脑缺少对应字体时可直接安装），`assets/` 存放封面标识素材。

== 本教程的组织结构 #en[Organisation of this Guide]

本教程按照"由整体到局部"的顺序组织：第二章说明文档的整体组装顺序与前置部分；第三章讲解文字与段落排版；第四章介绍数学公式；第五章介绍插图与三线表；第六章介绍代码清单、算法环境与参考文献；第七章总结使用要点、常见问题与学习资源。模板文档从源文件到 PDF 的总体组装与排版流程如#[@图1.1]所示。

#figure(
  image("./imgs/文档组装与排版流程.png", width: 90%),
  caption: [文档组装与排版流程],
  gap: 0.35em,
) <图1.1>

= 文档结构与前置部分 #en[Document Structure and Front Matter]

== 总体组装顺序 #en[Overall Assembly Order]

一篇完整论文在源文件中的组装顺序为：封面 `cover()`、独创性声明 `declaration()`、中英文摘要 `abstract()`、多套目录 `multi-outline()`，随后通过 `#show: typeset-back` 切换到正文排版规则，再依次书写正文、参考文献 `bibliography()`、附录与致谢。前置部分与正文使用不同的 show 规则与页码体系：前置部分页码为罗马数字，正文从阿拉伯数字 1 重新计数。

== 封面 #en[Cover Page]

封面通过 `cover()` 函数生成，主要命名参数包括：中文题目两行 `zh-title1`、`zh-title2`，英文题目两行 `en-title1`、`en-title2`，以及作者 `author`、导师 `mentor`、学位类别 `degree`、所在学院 `academy`、学科专业 `subject` 与研究方向 `research`。题目较长时由第二行参数承担副标题，无需手动换行。

== 独创性声明 #en[Originality Declaration]

`declaration()` 生成独创性声明与论文使用授权说明两页，内容由学校统一规定，一般无需修改；签名与日期处留有下划线，打印后手写即可。

== 中英文摘要 #en[Chinese and English Abstracts]

`abstract()` 接受四个内容参数：中文摘要正文 `zh-abstract`、中文关键词 `zh-keywords`、英文摘要正文 `en-abstract` 与英文关键词 `en-keywords`。关键词之间中文用分号分隔、英文同样使用分号。正文段落中首次出现的专业术语建议给出全称与缩写，如电子排版（Electronic Typesetting，ET），后文即可直接使用缩写 ET。

== 目录与页码体系 #en[Outlines and Page Numbering]

`multi-outline()` 一次生成五套目录：中文目录、英文目录、图目录、表目录与公式目录。各章标题旁的 `#en[English Title]` 标记在正文中不渲染任何内容，只向英文目录提供英文标题；未加标记的标题在英文目录中回退显示中文原文。目录条目、页码与点线引导均由模板自动维护，增删章节后无需手工调整。

页码样式（Page Number Style）由模板内部状态自动切换：前置部分使用罗马数字，正文部分使用阿拉伯数字，奇偶页页眉也分别显示论文题目与当前章标题，作者无需手工分页。

缩略语对照表为前置部分的可选页，其整段代码独立于 `multi-outline()`，不需要时直接整段删除即可，不影响其余目录。

= 文字与段落排版 #en[Text and Paragraph Formatting]

== 标题层级与自动编号 #en[Heading Levels and Numbering]

模板支持五级标题，分别以 `=`、`==`、`===`、`====`、`=====` 标记。一级标题（章）编号为"第 X 章"样式，二、三级标题编号为"X.X""X.X.X"，四、五级标题不进入目录，正文内部最多建议使用到三级标题。

=== 多级标题演示 #en[Multi-level Heading Demo]

==== 四级标题

正文内容text正文内容text正文内容text正文内容text正文内容text正文内容text正文内容text正文内容text

===== 五级标题及其比较

多级标题的编号由模板集成的编号库与一级标题计数器联动实现，每进入新的一章，图、表、公式计数器自动重置，因此图号始终为"章号.序号"形式。写作中调整章节顺序后，所有编号与目录都会自动更新。

== 字体与中西文混排 #en[Fonts and CJK-Latin Mixed Typesetting]

模板严格使用学校规范指定的标准字体：正文为宋体 SimSun，第一至三级标题为黑体 SimHei，封面中文题名及作者、学位、专业等填写项为楷体 KaiTi，中文摘要的关键词为仿宋 FangSong，西文统一使用 Times New Roman，代码使用 Courier New。这些字体均为 Windows 系统自带；在缺少字体的电脑上，可安装包内 `fonts/` 目录中的字体文件，或编译时用 `--font-path fonts` 临时加载。正文中西文混排时，字体列表自动为汉字与西文字符选用对应字体，并在中西文边界加入适度间距。中文不加粗字体字形，加粗效果由伪粗体技术合成；中文论文一般以加粗而非斜体表示强调。

== 行内格式与脚注 #en[Inline Formatting and Footnotes]

常见行内格式包括：以星号书写的#strong[加粗]、以函数书写的#underline[下划线]、以反引号书写的行内代码 `typst compile`，以及行内数学公式如 $a^2 + b^2 = c^2$。上标与下标可直接写作 $x^2$、$x_1$。脚注用于对正文作补充说明#footnote([脚注内容以五号字排于页脚，无需手工调整位置])。

== 列表 #en[Lists]

无序列表以短横线起头，用于罗列并列事项：

- 封面与声明信息应与研究生院要求逐项核对；
- 编译时建议带上 `--font-path fonts` 参数，电脑缺少标准字体时直接加载包内字体文件（也可手动安装）；
- 提交前应检查目录页码与参考文献编号是否已自动更新。

有序列表以加号起头，用于表示有先后顺序的步骤：

+ 安装 Typst 编译器并确认版本号；
+ 在首行导入模板并填写封面信息；
+ 按组装顺序补全前置部分与正文章节；
+ 编译生成 PDF 并逐项校对格式。

== 交叉引用 #en[Cross References]

为需要引用的图、表、公式、代码或章节添加标签（Label），如 `<图1.1>`，在正文中以 `#[@图1.1]` 引用即可，编号由编译器自动填入。如#[@图1.1]所示，引用文字与编号之间、编号与后续汉字之间均留有规范要求的小间隔；章节调整后引用编号自动更新，无需全文手工查找替换。

= 数学公式 #en[Mathematics]

== 行内公式与行间公式 #en[Inline and Display Equations]

行内公式书写于一对美元符号之内，如质能方程 $E = m c^2$，随段落流动排版。独立成行的行间公式在美元符号两侧留空行书写，自动获得"章号.序号"形式的编号，如#[@eq-emc2]所示：

$ E = m c^2 $ <eq-emc2>

一元二次方程 $a x^2 + b x + c = 0$ 的求根公式如#[@eq-quadratic]所示：

$ x = (-b +- sqrt(b^2 - 4 a c))/(2 a) $ <eq-quadratic>

== 多行对齐公式 #en[Aligned Multi-line Equations]

多行公式以反斜杠分行、以 `&=` 标记对齐位置，编号赋予整个公式块。例如带约束的最小化问题可以写作#[@eq-opt]：

$
  "min"_(x in RR) f(x) & = 1/2 x^T A x + b^T x \
       "s.t." quad A x & = b
$ <eq-opt>

== 公式编号与引用 #en[Equation Numbering and References]

公式编号与一级标题计数器联动，正文引用时模板自动渲染为"式（X.X）"形式。因此#[@eq-emc2]、#[@eq-quadratic]与#[@eq-opt]分别显示为式（4.1）、式（4.2）与式（4.3），删除或调换公式顺序后编号与引用同步更新。数学符号字体由编译器内置的数学字体提供，希腊字母、求和符号、矩阵等均可直接在数学模式中输入。

= 插图与表格 #en[Figures and Tables]

== 插入图片 #en[Inserting Figures]

插图以 `figure()` 包裹 `image()` 生成，图题通过 `caption` 参数给出，排版于图的下方；图片宽度建议以页面宽度的百分比指定，如 `width: 90%`。图号自动编为"章号.序号"，并自动进入图目录。典型的插图排版处理流程如#[@图5.1]所示。

#figure(
  image("./imgs/插图排版流程图.png", width: 90%),
  caption: [插图排版处理流程示意图],
  gap: 0.35em,
) <图5.1>
注：图注以小一号字排于图题下方，用于对图中符号、配色等作补充说明。

图片来源：若图片引自其他文献，需在此标注出处，如"图片来源：作者根据相关资料改绘"。

== 三线表 #en[Three-line Tables]

学位论文中的数据表统一采用三线表形式。模板提供 `tlt()` 函数，直接读取 xlsx 文件数据并生成三线表，数据与排版因此可以分离维护：表格内容在 Excel 或 WPS 中编辑保存于 `tables/` 目录，源文件中以 `tlt(read("./tables/xxx.xlsx", encoding: none))` 读取。表题排版于表的上方，表号同样按"章号.序号"编制，如#[@表5.1]所示。

#figure(
  tlt(read("./tables/内置字体对照表.xlsx", encoding: none)),
  caption: [模板内置字体对照表],
) <表5.1>
注：`read()` 写在使用者文件中，可保证 xlsx 路径始终相对于论文源文件解析。

== 多子图 #en[Subfigures]

若干联系紧密的图可共享一个图号，以 `grid()` 并排排版，子图标题（a）（b）手工标注。#[@图5.2]以两张流程示意图为例演示多子图的常见写法。

#figure(
  grid(
    columns: 2,
    gutter: 1.5em,
    align: center + bottom,
    [
      #image("./imgs/文档组装流程.png", width: 100%)
      #align(center)[（a）文档组装流程]
    ],
    [
      #image("./imgs/插图排版流程.png", width: 100%)
      #align(center)[（b）插图排版流程]
    ],
  ),
  caption: [文档组装与插图排版流程（子图示例）],
) <图5.2>

= 代码、算法与参考文献 #en[Code Listings, Algorithms and Bibliography]

== 代码清单 #en[Code Listings]

代码清单通过 `code()` 函数生成，题注位于上方，编号为"章号.序号"，正文引用时自动显示为"代码 X.X"。代码块以三个反引号围栏并注明语言，即可获得语法高亮。例如，一份最小论文源文件的骨架如#[@代码6.1]所示。

//! code() 环境：代码左对齐、整体左缩进 2 字符，编号"章号.序号"，caption 在上方
#code(
  ```typ
  #import "@preview/jiangcai-jufe-master-thesis:0.1.1": *

  #cover(zh-title1: [论文题目], author: [姓名])
  #declaration()
  #show: typeset-fore
  #abstract(zh-abstract: [摘要正文], zh-keywords: [关键词])
  #multi-outline()

  #show: typeset-back
  = 绪论 #en[Introduction]
  正文内容……
  ```,
  caption: [最小论文源文件骨架],
) <代码6.1>

== 算法环境 #en[Algorithm Environment]

算法伪代码通过 `algorithm()` 函数排版，可通过 `input` 与 `output` 参数给出输入输出，算法框左对齐并整体缩进两个字符，编号方式与图表一致。经典的二分查找（Binary Search）过程如#[@算法6.1]所示。

#algorithm(
  caption: [二分查找],
  input: [有序数组 $A[1..n]$，目标值 $x$],
  output: [$x$ 在数组中的下标；不存在时返回 0],
  [
    1　$l arrow.l 1$，$r arrow.l n$\
    2　while $l <= r$ do\
    3　#h(2em) $m arrow.l floor((l + r) / 2)$\
    4　#h(2em) if $A[m] = x$ then return $m$\
    5　#h(2em) else if $A[m] < x$ then $l arrow.l m + 1$ else $r arrow.l m - 1$\
    6　end while\
    7　return 0
  ],
) <算法6.1>

== 参考文献 #en[Bibliography]

参考文献数据维护在 `refs.bib` 文件中，采用 BibTeX 语法，条目类型覆盖期刊论文、专著、标准、电子资源与预印本等。正文引用处写作 `#[@knuth1984literate]`，编译后按正文首次出现的顺序自动编号；文末通过 `bibliography()` 指定 `gb-7714-2015-numeric` 样式，即按 GB/T 7714—2015 顺序编码制生成文献表#[@gbt7714-2015]。经典的排版工程文献阐述了"文学化编程"的思想#[@knuth1984literate]，而排版风格学的系统讨论可参阅 Bringhurst 的著作#[@bringhurst2004elements]；中文作者可参考刘海洋编写的入门教材#[@liuhaiyang2013latex]。只有被正文实际引用的条目才会出现在文献表中。

= 总结与展望 #en[Conclusion and Outlook]

== 使用要点小结 #en[Summary of Key Points]

使用本模板时请把握四个要点：第一，编译时带上 `--font-path fonts`，缺少标准字体的电脑可直接加载或安装包内字体文件，以保证字体与模板一致；第二，严格按照封面、声明、摘要、目录、正文、参考文献、附录、致谢的顺序组装文档；第三，所有图、表、公式与章节编号均自动维护，不要在正文中手写编号；第四，标题的英文译名通过 `#en[...]` 标注，标签必须写在 `#en[...]` 之后。

== 常见问题 #en[Frequently Asked Questions]

开发或离线使用本模板时，最常见的问题是本地包缓存：通过 `@preview` 导入的包会被编译器缓存到用户目录下，修改包源码后若编辑器仍显示旧效果，应将改动同步到缓存目录后再重新编译。此外，若日志中出现缺少字体的提示，应检查系统是否已安装规范要求的标准字体，或确认 `--font-path` 指向包内 `fonts/` 目录；xlsx 读取失败通常是路径或文件名问题，建议数据文件统一放在 `tables/` 目录并使用相对路径。

== 学习资源与展望 #en[Further Resources and Prospect]

进一步学习可从三条线索展开：通读 Typst 官方文档掌握完整语法#[@typst-docs]；在 Typst Universe 上研究其他开源包的实现#[@typst-universe]；回溯 TeX 与排版学经典文献理解排版惯例的由来#[@knuth1986texbook]。

未来本模板将随学校格式规范与 Typst 版本持续更新，并计划补充更多学院的封面参数与常用文体环境，希望能帮助同学们从繁琐的格式调整中解放出来，把精力集中于论文内容本身。

//! 参考文献（标题由 bibliography 生成，"参 考 文 献"字间空格为格式要求；
//! #en[References] 不渲染任何内容，仅供英文目录提取英文标题）
#show heading.where(level: 1): set align(center)
#set heading(level: 1, numbering: none)
#bibliography(
  "./refs.bib",
  style: "gb-7714-2015-numeric",
  title: [参 考 文 献 #en[References]],
)

= 附录 #en[Appendix]

附录用于放置不宜放入正文但又有参考价值的材料，如调查问卷、补充实验结果、程序源代码等。下表汇总了编译本模板所需的环境与依赖包版本。

#align(center)[
  #tlt(read("./tables/编译环境与依赖.xlsx", encoding: none))
]

= 致#h(2em)谢 #en[Acknowledgements]

本教程示例中的致谢段落为占位文本，请替换为你自己的内容。可以向导师在论文选题、研究方案设计与论文撰写修改过程中给予的悉心指导致以谢意，感谢学院各位任课教师的教诲、同门与同学在学习生活中给予的帮助，以及家人的理解与支持，并感谢参与论文评审与答辩的各位专家学者提出的宝贵意见。

#v(2em)
#set align(right)
姓名#h(2em)

#datetime.today().display("[year]年[month padding:none]月")
