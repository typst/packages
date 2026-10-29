//! ⚠️ 开发期用下方 @local 导入（编译带 --root .，改 lib.typ 即时生效）；提交 PR 前必须切回 @preview
#import "@preview/jiangcai-jufe-master-thesis:0.1.1": *
// #import "@local/jiangcai-jufe-master-thesis:0.1.1": *

//! 版本模式："review" 完整版（默认）/ "blind" 送审匿名版 / "print" 无封面打印版
//! 命令行临时切换：--input mode=blind（不改源文件）
#version-mode.update(sys.inputs.at("mode", default: "review"))

/*
 * ============================================================
 * 江西财经大学硕士学位论文 Typst 模板 —— 使用教程示例文档
 *
 * 双重角色：模板功能的完整示例（封面/声明/摘要/目录/正文/图表公式/
 * 参考文献/附录/致谢），也是 Typst 语言与本模板的使用教程（正文以
 * 系统手册方式分章讲解常用写法）。
 * 使用时将各部分替换为你自己的论文内容即可。
 * ============================================================
 */

//! 封面：中英文题目分两行；作者、导师、学位等信息逐项替换
#cover(
  zh-title1: [Typst学位论文排版实践教程],
  zh-title2: [——以江西财经大学硕士学位论文模板为例],
  en-title1: [Practical Guide to Typst Thesis Typesetting:],
  en-title2: [JXUFE Master's Template],
  author: [张三],
  mentor: [李四],
  degree: [硕#h(1em)士],
  academy: [统计与数据科学学院],
  subject: [应用统计],
  research: [Typst模板开发],
)

//! 独创性声明与使用授权说明（固定内容，一般无需修改）
//! 电子签名与日期（可选）：三个参数传图片即浮于横线上方，版式与空手签一致
#declaration(
  // signature: image("./assets/sign-author.png", height: 1.6em),
  // mentor-signature: image("./assets/sign-mentor.png", height: 1.6em),
  // date: image("./assets/date.png", height: 1.4em),
)

//! 中英文摘要与关键词（前置部分，罗马数字页码）
#show: typeset-fore
#abstract(
  zh-abstract: [
    Typst 是一款新兴的标记式电子排版系统（Markup-based Typesetting System），具有语法简洁、增量编译迅速、错误提示友好等特点，为学位论文排版提供了 LaTeX 之外的新选择。本教程以江西财经大学硕士学位论文格式规范为依据，系统介绍基于 Typst 的 jiangcai-jufe-master-thesis 模板的使用方法。该模板内置封面、独创性声明、中英文摘要、多套目录、图表公式与三线表环境、GB/T 7714 参考文献样式。字体严格使用规范指定的标准字体（宋体、黑体、楷体、仿宋及 Times New Roman 等，均为 Windows 系统自带），包内 `fonts/` 目录另存有这些字体文件，可供缺少字体的电脑安装使用。全文按照系统手册方式组织，依次说明 Typst 的安装与编译、文档组装顺序、文字段落排版、插图与三线表、数学公式、代码与算法以及参考文献的写法，并以随机段落演示长篇正文的排版效果。借助本模板，作者只需关注论文内容本身，即可快速获得符合学校规范的排版结果。
  ],
  zh-keywords: [Typst；学位论文；排版模板；标记语言；GB/T 7714],
  en-abstract: [
    Typst is a new markup-based typesetting system featuring concise syntax, fast incremental compilation and friendly error messages, offering an alternative to LaTeX for thesis typesetting. Following the format regulations of Jiangxi University of Finance and Economics for master's theses, this guide systematically introduces the jiangcai-jufe-master-thesis package, which provides a cover page, an originality declaration, Chinese and English abstracts, multiple tables of contents, environments for figures, tables, equations, three-line tables and code listings, and a GB/T 7714 bibliography style. It uses the standard fonts required by the regulations (SimSun, SimHei, KaiTi, FangSong and Times New Roman, all supplied with Windows); copies of these font files are included in the package's fonts directory for installation on machines that lack them. The guide is organised as a systematic manual covering installation and compilation, document assembly, text formatting, figures and tables, mathematics, code and algorithms, and bibliographies, with placeholder paragraphs demonstrating the long-document layout. With this template, authors can focus on their content and quickly obtain a thesis that complies with the university regulations.
  ],
  en-keywords: [Typst; Degree thesis; Typesetting template; Markup language; GB/T 7714],
)

/*
 * 多套目录：中/英/图/表/公式目录默认生成，代码、算法目录用开关开启，
 * 无对应条目的目录自动整页跳过；缩略语对照表与主要符号表为可选页
 * （abbrev-list/symbol-list 开关 + abbrev-body/symbol-body 内容，
 * 数据维护在 tables/ 目录的 xlsx 中，tlt() 读取生成）
 */
#multi-outline(
  code-list: true,
  algorithm-list: true,
  abbrev-list: true,
  abbrev-body: tlt(read("./tables/缩略语对照表.xlsx", encoding: none)),
  symbol-list: true,
  symbol-body: tlt(read("./tables/主要符号表.xlsx", encoding: none)),
)

//! ==================== 正文（阿拉伯数字页码从 1 开始） ====================
/*
 * 标题旁 #en[English Title] 标注英文标题，供英文目录自动提取，未标注的回退显示原文。
 * 标签必须写在 #en[...] 之后（如 `= 绪论 #en[Introduction] <first>`），否则英文标记脱离标题
 */
#show: typeset-back

= Typst 与本模板简介 #en[Introduction to Typst and the Template] <first>

== Typst 简介 #en[What is Typst]

电子排版是学位论文写作中的重要环节。自 Donald E. Knuth 于 20 世纪 70 年代末创建 TeX 系统以来@knuth1986texbook ，以 Leslie Lamport 的 LaTeX 为代表的宏包长期是科技排版的事实标准@lamport1994latex 。然而传统 LaTeX 工作流存在编译链路复杂、辅助文件繁多、错误信息晦涩等问题。Typst 是 2023 年起开源的新一代标记式排版系统（Markup-based Typesetting System），源于 Laurenz Mädje 在柏林工业大学的硕士论文@madje2022typst ，由 Mädje 与 Martin Haug 设计实现，其编译器以 Rust 编写、借助 WebAssembly（WASM）实现插件扩展，具有语法轻量、增量编译与即时预览、函数式样式系统等特点。

与“内容与格式分离”的 LaTeX 理念相似，Typst 同样以纯文本源文件描述文档，便于版本管理与协作；不同之处在于 Typst 将包管理、字体管理、引用与目录等功能全部内建，一条命令即可完成编译，无需配置复杂的工具链。本模板即在此基础上，将江西财经大学硕士学位论文的格式规范封装为可直接调用的函数库。

== 安装与编译 #en[Installation and Compilation]

Typst 提供 Windows、macOS 与 Linux 预编译版本，可通过官网下载，或使用系统包管理器安装，如 Windows 下执行 `winget install --id Typst.Typst`。安装后在终端执行 `typst --version` 确认版本，本模板要求编译器版本不低于 0.14.2。

常用编译命令如下：单次编译使用 `typst compile thesis.typ`；写作时使用 `typst watch thesis.typ` 可在保存后自动重编译；字体严格使用规范指定的标准字体（宋体、黑体、楷体、仿宋、Times New Roman 等），均为 Windows 系统自带；编译时建议追加字体路径参数，即 `typst compile thesis.typ --font-path fonts`，缺少字体的电脑便直接加载包内 `fonts/` 目录中的标准字体文件，也可事先安装这些字体。完整的命令行参数说明可查阅官方文档@typst-docs。

== 模板的获取与使用 #en[Obtaining and Using the Template]

本模板发布在 Typst Universe 官方包仓库@typst-universe，包名为 `jiangcai-jufe-master-thesis`。使用时无需手动下载，只需在论文源文件首行写入导入语句 `#import "@preview/jiangcai-jufe-master-thesis:0.1.1": *`，编译器即会自动获取；离线环境下也可将包目录放入本地包缓存。模板目录中，`lib.typ` 为排版核心库，`template/thesis.typ` 即本教程示例文件，`fonts/` 存放标准字体文件（电脑缺少对应字体时可直接安装），`assets/` 存放封面标识素材。

== 论文格式要求速览 #en[Format Specification at a Glance]

学校格式规范的各项要求均已内置于模板，写作时无需手工调整。模板对主要格式要求的落实情况汇总如@表-格式速查 所示；各元素的完整字体配置另见第三章@表-字体配置。速查表数据同样维护在 `tables/` 目录的 xlsx 中，由 `tlt()` 读取生成（写法见第四章三线表一节）。

#figure(
  tlt(
    read("./tables/论文格式要求速查表.xlsx", encoding: none),
    columns: (8.5em, 1fr),
    auto-height: true,
  ),
  caption: [论文格式要求速查表],
) <表-格式速查>

== 本教程的组织结构 #en[Organisation of this Guide]

本教程按照“由整体到局部”的顺序组织，共六章：

- 第二章说明文档的整体组装顺序与前置部分（封面、声明、摘要、目录）；
- 第三章讲解文字与段落排版（标题、字体、行内格式、列表）；
- 第四章介绍插图、三线表、数学公式、代码清单与算法的写法，以及混排方式、编号与交叉引用；
- 第五章介绍参考文献、附录、致谢与版本模式；
- 第六章总结使用要点、常见问题与学习资源。

模板文档从源文件到 PDF 的总体组装与排版流程如@图-组装排版流程 所示。

#figure(
  image("./imgs/文档组装与排版流程.png", width: 90%),
  caption: [文档组装与排版流程],
  gap: 0.35em,
) <图-组装排版流程>

= 文档结构与前置部分 #en[Document Structure and Front Matter]

== 总体组装顺序 #en[Overall Assembly Order]

一篇完整论文在源文件中的组装顺序为：封面 `cover()`、独创性声明 `declaration()`、中英文摘要 `abstract()`、多套目录 `multi-outline()`，随后通过 `#show: typeset-back` 切换到正文排版规则，再依次书写正文、参考文献 `bibliography()`、附录与致谢。

== 封面 #en[Cover Page]

封面通过 `cover()` 函数生成，主要命名参数包括：中文题目两行 `zh-title1`、`zh-title2`，英文题目两行 `en-title1`、`en-title2`，以及作者 `author`、导师 `mentor`、学位类别 `degree`、所在学院 `academy`、学科专业 `subject` 与研究方向 `research`。题目较长时由第二行参数承担副标题，无需手动换行。

== 独创性声明 #en[Originality Declaration]

`declaration()` 生成独创性声明与论文使用授权说明两页，内容由学校统一规定，一般无需修改；签名与日期可打印出来手写后扫描，也可直接使用电子签名即手写日期扫描图片

== 中英文摘要 #en[Chinese and English Abstracts]

`abstract()` 接受四个内容参数：中文摘要正文 `zh-abstract`、中文关键词 `zh-keywords`、英文摘要正文 `en-abstract` 与英文关键词 `en-keywords`。关键词之间中文用中文分号分隔、英文用英文分号。正文段落中首次出现的专业术语建议给出全称与缩写，如电子排版（Electronic Typesetting，ET），后文即可直接使用缩写 ET。

== 目录与页码体系 #en[Outlines and Page Numbering]

`multi-outline()` 最多可生成七套目录：中文目录、英文目录、图目录、表目录、公式目录、代码目录与算法目录。后五套图表类目录各有一个布尔开关——`figure-list`、`table-list`、`equation-list` 默认开启，`code-list`、`algorithm-list` 默认关闭，按需传参即可，如 `#multi-outline(code-list: true)` 追加代码目录、`#multi-outline(figure-list: false)` 去掉图目录。开关开启但全文没有对应条目时，该目录整页自动跳过（连标题页也不出现），因此开着的开关不会造成空白目录页。各章标题旁的 `#en[English Title]` 标记在正文中不渲染任何内容，只向英文目录提供英文标题；未加标记的标题在英文目录中回退显示中文原文。目录条目、页码与点线引导均由模板自动维护，增删章节后无需手工调整。

页码样式（Page Number Style）由模板内部状态自动切换：前置部分使用罗马数字，正文部分使用阿拉伯数字，奇偶页页眉也分别显示论文题目与当前章标题，作者无需手工分页。

缩略语对照表（List of Abbreviations）为前置部分的可选页，也由 `multi-outline()` 统一生成：`abbrev-list` 开关控制是否出现（默认关闭），`abbrev-body` 提供对照表内容——数据同样维护在 `tables/缩略语对照表.xlsx` 中、用 `tlt()` 读取生成三线表，不加 figure 题注，故不占“表 X.X”编号、也不进入表目录。该页置于各目录之后，页码延续罗马数字，标题同时进入中英文目录；主要符号表（List of Symbols）与之同理，经 `symbol-list` 开关与 `symbol-body` 内容启用，置于缩略语对照表之后。

= 文字与段落排版 #en[Text and Paragraph Formatting]

== 标题层级与自动编号 #en[Heading Levels and Numbering]

模板支持五级标题，分别以 `=`、`==`、`===`、`====`、`=====` 标记。一级标题编号为“X”样式，二、三级标题编号为“X.X”、“X.X.X”，四、五级标题不进入目录，正文内部最多建议使用到三级标题。标题与图、表、公式的编号均与一级标题计数器联动，每进入新的一章自动重置；写作中调整章节顺序后，所有编号、引用与目录都会自动更新，无需手工维护。

=== 多级标题演示 #en[Multi-level Heading Demo]

==== 四级标题

四级标题以 `====` 标记，编号形如“（1）”。其字体字号与正文一致——宋体小四、首行缩进二字符，仅靠编号与正文段落区分，且不进入目录。

===== 五级标题及其比较

五级标题以 `=====` 标记，编号形如“①”，格式与四级标题相同，同样不进入目录。一至三级标题为黑体、独立成行并编入目录，四、五级标题则与正文同体同号，更接近带序号的段落标记，这是两类标题的根本差别。

== 字体与中西文混排 #en[Fonts and CJK-Latin Mixed Typesetting]

模板的字体配置与用途对应关系如@表-字体配置 所示：前八项为学校规范指定的标准字体，均为 Windows 系统自带；数学公式字体随编译器内置（Times New Roman 缺少 OpenType MATH 数学表，不能直接用于公式），代码字体为模板自选。缺少字体的电脑可安装包内 `fonts/` 目录中的字体文件（见表中”字体文件”列），或编译时用 `--font-path fonts` 临时加载。

#figure(
  tlt(
    read("./tables/字体配置对照表.xlsx", encoding: none),
    columns: (1.7fr, 1.5fr, 1.1fr, 0.7fr),
  ),
  caption: [模板字体配置与用途对照],
) <表-字体配置>

正文中西文混排时，字体列表自动为汉字与西文字符选用对应字体，并在中西文边界加入适度间距。中文不加粗字体字形，加粗效果由伪粗体技术合成；中文论文一般以加粗而非斜体表示强调。

== 行内格式与脚注 #en[Inline Formatting and Footnotes]

常见行内格式包括：以星号书写的#strong[加粗]、以函数书写的#underline[下划线]、以反引号书写的行内代码 `typst compile`，以及行内数学公式如 $a^2 + b^2 = c^2$。上标与下标可直接写作 $x^2$、$x_1$。脚注用于对正文作补充说明#footnote([脚注内容以五号字排于页脚，无需手工调整位置])。

== 列表 #en[Lists]

无序列表以短横线“-”起头，用于罗列并列事项：

- 封面与声明信息应与研究生院要求逐项核对；
- 编译时建议带上 `--font-path fonts` 参数，电脑缺少标准字体时直接加载包内字体文件（也可手动安装）；
- 提交前应检查目录页码与参考文献编号是否已自动更新。

有序列表以加号“+”起头，用于表示有先后顺序的步骤：

+ 安装 Typst 编译器并确认版本号；
+ 在首行导入模板并填写封面信息；
+ 按组装顺序补全前置部分与正文章节；
+ 编译生成 PDF 并逐项校对格式。

= 图表、公式与代码排版 #en[Figures, Tables, Equations and Code]

//! 行内公式的代码-效果对照（不编号）：左列 Typst 代码，右列渲染结果
#let demo(src, body) = table(
  columns: (1.1fr, 1fr),
  stroke: none,
  inset: (x: 0.6em, y: 0.4em),
  align: (center + horizon, center + horizon),
  raw(src, lang: "typ", block: true), body,
)

本章示例统一采用代码与渲染效果对照的排版：除行内公式由本教程自定义的 `demo()` 函数作不编号的左右对照外，其余对照代码均为带编号题注的代码清单——短内容用模板函数 `beside()` 左右并置，长内容上代码、下效果通栏排列（`beside()` 的写法详见「混排」一节）。

== 插图 #en[Figures]

插图以 `figure()` 包裹 `image()` 生成，图题 `caption` 排于图下方，编号”章号.序号”并自动进入图目录；图片宽度建议以页面宽度的百分比指定，如 `width: 90%`。@图-插图排版流程 展示了典型的插图排版处理流程，其写法与效果左右对照如下（对照代码也是带题注编号的代码清单，见@代码-插图写法）：

#beside(
  [
    #code(
      ```typ
      #figure(
        image(
          "./imgs/插图排版流程图.png",
          width: 90%,
        ),
        caption: [插图排版处理流程示意图],
      ) <图-插图排版流程>
      ```,
      caption: [插图的写法],
    ) <代码-插图写法>
  ],
  [
    #figure(
      image("./imgs/插图排版流程图.png", width: 100%),
      caption: [插图排版处理流程示意图],
    ) <图-插图排版流程>
  ],
)

- 图片引自其他文献时需在图注处标注出处，如“图片来源：作者根据相关资料改绘”。

== 三线表 #en[Three-line Tables]

学位论文中的数据表统一采用三线表形式。模板提供 `tlt()` 函数，直接读取 xlsx 文件数据并生成三线表，数据与排版因此可以分离维护：表格内容在 Excel 或 WPS 中编辑保存于 `tables/` 目录，源文件中以 `tlt(read("./tables/xxx.xlsx", encoding: none))` 读取。@表-三线表格式 在演示用法的同时，说明了三线表自身的格式要求，其写法如@代码-三线表写法 所示：

#code(
  ```typ
  #figure(
    tlt(read("./tables/三线表格式说明.xlsx", encoding: none)),
    caption: [三线表格式说明],
  ) <表-三线表格式>
  ```,
  caption: [三线表的写法],
) <代码-三线表写法>

#figure(
  tlt(read("./tables/三线表格式说明.xlsx", encoding: none)),
  caption: [三线表格式说明],
) <表-三线表格式>

- 数据行行高缺省固定（与规范表格的固定行高一致），单元格以单行为宜；确有长文字需要容纳时传 `auto-height: true` 令行高随内容自适应撑高（如表 1.1 的写法）；列宽缺省按列数等分，需要时传 `columns` 参数指定（如表 1.1、表 3.1 的写法）；
- `read()` 写在使用者文件中，可保证 xlsx 路径始终相对于论文源文件解析。

== 数学公式 #en[Mathematics]

本模板的公式示例统一使用 Typst 原生数学语法（与 LaTeX 语法相近但更简洁，如分式直接写 `a/b`、根式写 `sqrt(x)`）。习惯 LaTeX 数学写法的作者也可借助社区包 mitex，以 LaTeX 语法书写公式后再由该包转换排版；本教程示例不引入该包，全部使用原生语法。

行内公式书写于一对美元符号之内，随段落流动排版（此为本章唯一不编号的对照示例——行内公式无需编号，其对照代码也不编号）：

#demo(
  "$E = m c^2$",
  [$E = m c^2$],
)

独立成行的行间公式在美元符号两侧留空行书写，自动获得”章号.序号”形式的编号（右对齐、半角括号）。行间公式无论长短，对照排版一律为代码清单在上、公式效果在下，如@代码-质能方程 与@eq-emc2 所示：

#code(
  ```typ
  $ E = m c^2 $ <eq-emc2>
  ```,
  caption: [行间公式的写法],
) <代码-质能方程>

$ E = m c^2 $ <eq-emc2>

一元二次方程 $a x^2 + b x + c = 0$ 的求根公式如@代码-求根公式 与@eq-quadratic 所示：

#code(
  ```typ
  $ x = (-b +- sqrt(b^2 - 4 a c))/(2 a) $ <eq-quadratic>
  ```,
  caption: [求根公式的写法],
) <代码-求根公式>

$ x = (-b +- sqrt(b^2 - 4 a c))/(2 a) $ <eq-quadratic>

多行公式以反斜杠分行、以 `&=` 标记对齐位置，编号赋予整个公式块；`min` 等算子的约束条件写在算子正下方。带约束的最小化问题如@eq-opt 所示：

#code(
  ```typ
  $
    min_(x in RR) f(x) & = 1/2 x^T A x + b^T x \
         "s.t." quad A x & = b
  $ <eq-opt>
  ```,
  caption: [多行对齐公式的写法],
) <代码-多行公式>

$
  min_(x in RR) f(x) & = 1/2 x^T A x + b^T x \
     "s.t." quad A x & = b
$ <eq-opt>

数学符号字体由编译器内置的 New Computer Modern Math 提供，希腊字母、求和符号、矩阵等均可直接在数学模式中输入。

== 代码清单 #en[Code Listings]

代码清单通过 `code()` 函数生成，题注位于上方，编号为”章号.序号”，正文引用时自动显示为”代码 X.X”；所有代码清单自动收入代码目录（`multi-outline(code-list: true)` 开启时）。代码块以三个反引号围栏并注明语言，即可获得语法高亮；代码体顶格左对齐。例如，一份最小论文源文件的骨架如@代码-最小骨架 所示。过长的代码清单建议放入附录，正文仅保留关键片段。

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

  #references("/refs.bib")
  #appendix[附录内容……]
  #thanks[致谢内容……]
  ```,
  caption: [最小论文源文件骨架],
) <代码-最小骨架>

== 算法环境 #en[Algorithm Environment]

算法伪代码通过 `algorithm()` 函数排版，可通过 `input` 与 `output` 参数给出输入输出；算法步骤用 `\` 分行，行首行号自动编排（不需要编号时传 `numbered: false`），嵌套层级用 `#h(2em)` 缩进（更深层级递进叠加，如 `#h(4em)`）。算法框与三线表一样整体居中、框内文字左对齐，编号方式与图表一致；所有算法自动收入算法目录（`multi-outline(algorithm-list: true)` 开启时）。经典的二分查找（Binary Search）过程如@算法-二分查找 所示，其写法与渲染效果上下对照如下（对照代码见@代码-算法写法）。过长的算法同样建议放入附录。

#code(
  ```typ
  #algorithm(
    caption: [二分查找],
    input: [有序数组 $A[1..n]$，目标值 $x$],
    output: [$x$ 在数组中的下标；不存在时返回 0],
    [
      $l arrow.l 1$，$r arrow.l n$\
      while $l <= r$ do\
      #h(2em) $m arrow.l floor((l + r) / 2)$\
      #h(2em) if $A[m] = x$ then return $m$\
      #h(2em) else if $A[m] < x$ then\
      #h(4em) $l arrow.l m + 1$\
      #h(2em) else\
      #h(4em) $r arrow.l m - 1$\
      end while\
      return 0
    ],
  ) <算法-二分查找>
  ```,
  caption: [算法环境的写法],
) <代码-算法写法>

#algorithm(
  caption: [二分查找],
  input: [有序数组 $A[1..n]$，目标值 $x$],
  output: [$x$ 在数组中的下标；不存在时返回 0],
  [
    $l arrow.l 1$，$r arrow.l n$\
    while $l <= r$ do\
    #h(2em) $m arrow.l floor((l + r) / 2)$\
    #h(2em) if $A[m] = x$ then return $m$\
    #h(2em) else if $A[m] < x$ then\
    #h(4em) $l arrow.l m + 1$\
    #h(2em) else\
    #h(4em) $r arrow.l m - 1$\
    end while\
    return 0
  ],
) <算法-二分查找>

== 混排 #en[Mixed Layouts]

上下混排无需特殊处理，按书写顺序依次排版即可，本章插图、三线表与数学公式三节的“代码在上、效果在下”即是。左右混排按混排元素是否相同分两种情形，模板分别提供 `beside()` 与 `subfloat()` 两个函数实现，均令各栏等宽并置、同组不被分页拆散。算法框与 `tlt()` 表在混排栏内自动撑满栏宽；原生 `table` 进混排则需自行以 fr 声明列宽（如下列各例），否则按内容收缩、栏内留白。

本章行内公式的”代码+效果”对照由本教程自定义的 `demo()` 函数实现——两列无边框表格，左列放 `raw` 代码块，右列放渲染结果，源码如@代码-demo 所示。行内公式无需编号，其对照代码也不编号；本章其余对照代码均为带题注编号的代码清单。

#code(
  ```typ
  #let demo(src, body) = table(
    columns: (1.1fr, 1fr),
    stroke: none,
    inset: (x: 0.6em, y: 0.4em),
    align: (center + horizon, center + horizon),
    raw(src, lang: "typ", block: true),
    body,
  )
  ```,
  caption: [代码与渲染效果对照排版的 demo() 函数],
) <代码-demo>

*不同元素*左右混排时用 `beside()` 并置，每栏各放一个独立元素：各自占用独立的编号与题注——图题在下方，表、代码与算法的题注在上方，位置差异属各自样式，并排时无需对齐。`beside()` 令各栏等宽、纵向居中对齐。下面六组示例依次演示左代码右图（@代码-插图写法 与@图-插图排版流程）、左代码右表（@代码-混排准确率 与@表-混排准确率）、左代码右算法（@代码-一趟冒泡 与@算法-一趟冒泡）、左图右表（@图-混排组装流程 与@表-混排超参数）、左算法右图（@算法-顺序查找 与@图-混排插图步骤）与左算法右表（@算法-累加求和 与@表-混排实验数据）：

#beside(
  [#code(
    ```typ
    #figure(
      table(
        columns: (1fr, 1fr),
        stroke: none,
        align: center + horizon,
        table.hline(stroke: 1.5pt),
        [*方法*], [*准确率*],
        table.hline(stroke: 0.75pt),
        [方法甲], [92.3%],
        [方法乙], [94.1%],
        table.hline(stroke: 1.5pt),
      ),
      caption: [两种方法的准确率],
    ) <表-混排准确率>
    ```,
    caption: [混排准确率],
  ) <代码-混排准确率>],
  [#figure(
    table(
      columns: (1fr, 1fr),
      stroke: none,
      align: center + horizon,
      table.hline(stroke: 1.5pt),
      [*方法*], [*准确率*],
      table.hline(stroke: 0.75pt),
      [方法甲], [92.3%],
      [方法乙], [94.1%],
      table.hline(stroke: 1.5pt),
    ),
    caption: [两种方法的准确率],
  ) <表-混排准确率>],
)

#beside(
  [#code(
    ```typ
    #algorithm(
      caption: [一趟冒泡],
      input: [数组 $A[1..n]$],
      output: [最大元素移至末尾的数组 $A$],
      [
        for $i arrow.l 1$ to $n - 1$ do\
        #h(1em) if $A[i] > A[i + 1]$ then\
        #h(2em) 交换 $A[i]$ 与 $A[i + 1]$
      ],
    ) <算法-一趟冒泡>
    ```,
    caption: [一趟冒泡],
  ) <代码-一趟冒泡>],
  [#algorithm(
    caption: [一趟冒泡],
    input: [数组 $A[1..n]$],
    output: [最大元素移至末尾的数组 $A$],
    [
      for $i arrow.l 1$ to $n - 1$ do\
      #h(1em) if $A[i] > A[i + 1]$ then\
      #h(2em) 交换 $A[i]$ 与 $A[i + 1]$
    ],
  ) <算法-一趟冒泡>],
)

#beside(
  [#figure(
    image("./imgs/文档组装与排版流程.png", width: 100%),
    caption: [文档组装与排版流程],
  ) <图-混排组装流程>],
  [#figure(
    table(
      columns: (1fr, 1fr),
      stroke: none,
      align: center + horizon,
      table.hline(stroke: 1.5pt),
      [*参数*], [*取值*],
      table.hline(stroke: 0.75pt),
      [学习率], [0.01],
      [批大小], [32],
      table.hline(stroke: 1.5pt),
    ),
    caption: [训练超参数],
  ) <表-混排超参数>],
)

#beside(
  [#algorithm(
    caption: [顺序查找],
    input: [数组 $A[1..n]$，目标值 $x$],
    output: [$x$ 在数组中的下标；不存在时返回 0],
    [
      for $i arrow.l 1$ to $n$ do\
      #h(1em) if $A[i] = x$ then return $i$\
      return 0
    ],
  ) <算法-顺序查找>],
  [#figure(
    image("./imgs/插图排版流程.png", width: 100%),
    caption: [插图排版步骤],
  ) <图-混排插图步骤>],
)

#beside(
  [#algorithm(
    caption: [累加求和],
    input: [数组 $A[1..n]$],
    output: [各元素之和 $s$],
    [
      $s arrow.l 0$\
      for $i arrow.l 1$ to $n$ do\
      #h(1em) $s arrow.l s + A[i]$
    ],
  ) <算法-累加求和>],
  [#figure(
    table(
      columns: (1fr, 1fr),
      stroke: none,
      align: center + horizon,
      table.hline(stroke: 1.5pt),
      [*样本*], [*得分*],
      table.hline(stroke: 0.75pt),
      [甲], [85],
      [乙], [91],
      table.hline(stroke: 1.5pt),
    ),
    caption: [两组样本得分],
  ) <表-混排实验数据>],
)

*相同元素*左右混排且联系紧密时，可共享一个编号：`subfloat()` 将同类子元素等宽并置、顶端对齐，（a）（b）子题手工标注，总题注统一说明。子题位置与该类元素的总题注位置一致——图的子题排于子图下方，表、代码与算法的子题排于上方。@图-子图示例、@表-子表示例、@代码-子代码示例 与@算法-子算法示例 依次演示子图、子表、子代码与子算法的写法：

#subfloat(
  caption: [文档组装与插图排版流程（子图示例）],
  ([（a）文档组装流程], image("./imgs/文档组装流程.png", width: 100%)),
  ([（b）插图排版流程], image("./imgs/插图排版流程.png", width: 100%)),
) <图-子图示例>

#subfloat(
  kind: table,
  caption: [两组实验数据对比（子表示例）],
  (
    [（a）第一组实验数据],
    table(
      columns: (1fr, 1fr),
      stroke: none,
      align: center + horizon,
      table.hline(stroke: 1.5pt),
      [*样本*], [*得分*],
      table.hline(stroke: 0.75pt),
      [甲], [85],
      [乙], [91],
      table.hline(stroke: 1.5pt),
    ),
  ),
  (
    [（b）第二组实验数据],
    table(
      columns: (1fr, 1fr),
      stroke: none,
      align: center + horizon,
      table.hline(stroke: 1.5pt),
      [*样本*], [*得分*],
      table.hline(stroke: 0.75pt),
      [丙], [88],
      [丁], [79],
      table.hline(stroke: 1.5pt),
    ),
  ),
) <表-子表示例>

#subfloat(
  kind: raw,
  caption: [两个最小 Typst 函数（子代码示例）],
  (
    [（a）问候函数],
    ```typ
    #let hi(n) = [你好，#n！]
    ```,
  ),
  (
    [（b）平方函数],
    ```typ
    #let sq(x) = x * x
    ```,
  ),
) <代码-子代码示例>

#subfloat(
  kind: "algorithm",
  caption: [两种极值查找（子算法示例）],
  (
    [（a）求最大值],
    [
      $m arrow.l A[1]$\
      for $i arrow.l 2$ to $n$ do\
      #h(1em) if $A[i] > m$ then $m arrow.l A[i]$
    ],
    [数组 $A[1..n]$],
    [最大值 $m$],
  ),
  (
    [（b）求最小值],
    [
      $m arrow.l A[1]$\
      for $i arrow.l 2$ to $n$ do\
      #h(1em) if $A[i] < m$ then $m arrow.l A[i]$
    ],
    [数组 $A[1..n]$],
    [最小值 $m$],
  ),
) <算法-子算法示例>

== 编号与交叉引用 #en[Numbering and Cross References]

- 编号规则：图、表、公式、代码与算法均按“章号.序号”编号，与一级标题计数器联动、每章自动重置；增删条目或调整章节顺序后，编号、引用与各套目录全部自动更新，无需手工维护；
- 添加标签：需引用的元素在源码末尾加 `<标签>`，如 `<图-组装排版流程>`；标签只是内部代号，建议按内容语义命名而非写死编号——无论标签叫什么，正文显示的编号始终取自元素的实际计数；
- 正文引用：写作 `@标签`，图、表、代码、算法自动渲染为“图 X.X”“表 X.X”等形式，公式渲染为“式（X.X）”——引用文字用全角括号、公式编号本身用半角括号，与学校 Word 模板一致；引用编号与前后汉字之间自动留有规范要求的小间隔；
- 配套目录：图、表、公式目录默认生成，代码、算法目录经 `multi-outline()` 开关开启，条目与页码自动维护。

以本章为例`@图-插图排版流程`、`@表-三线表格式`、`@eq-emc2`、`@代码-最小骨架`与`@算法-二分查找`分别显示为图 4.1、表 4.1、式（4.1）、代码 4.6 与算法 4.1。

= 参考文献与文档收尾 #en[Bibliography and Back Matter]

== 参考文献 #en[Bibliography]

参考文献数据维护在 `refs.bib` 文件中，采用 BibTeX 语法。正文引用处写作 `@文献key`，编译后按正文首次出现的顺序自动编号，引用标记以上标呈现；文末只需一行 `#references("/template/refs.bib")`，模板即按 GB/T 7714—2025#footnote([国家标准全文公开系统：https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=C6CE52E55AC09B9C79A20AEA77CEDD14]) 顺序编码制生成文献表。只有被正文实际引用的条目才会出现在文献表中。

GB/T 7714—2025 为不同类型的文献规定了相应的著录格式，模板生成的文献表会自动按类型排版。常见类型的引用示例如下：期刊论文@knuth1984literate、专著@bringhurst2004elements、中文专著@liuhaiyang2013latex、学位论文@madje2022typst、会议论文@conf-typst、标准@gbt7714-2025、报纸文章@news-copyright、报告@cnnic-2025、专利@wangxuan-1985、地图@map-china、数据集@dataset-geo 与电子资源@typst-docs；读者可对照文末文献表查看各类型的著录格式。多文献合并引用写作 `[@key1@key2]`，如@knuth1986texbook@lamport1994latex 以及@knuth1986texbook@lamport1994latex@madje2022typst。

== 附录与致谢 #en[Appendix and Acknowledgements]

附录内容（可含多段、表格与插图）整体包入 `#appendix[...]`；致谢内容包入 `#thanks[...]`。致谢末尾的姓名与年月自动取自 `cover()` 填写的 `author`、`year`、`month`，无需重复手填；送审匿名版下致谢整节（含标题）自动不渲染，中英文目录中也不会出现。

== 版本模式 #en[Version Modes]

通过文档顶部的 `#version-mode.update(...)` 选择三种版本，亦可在命令行用 `--input` 临时指定而不改动源文件：

- `"review"`：导师阅览完整版（默认），封面、声明、致谢齐全；
- `"blind"`：送审匿名版，封面信息表隐去作者与导师整行，独创性声明页与致谢整节自动消失；
- `"print"`：无封面打印版，封面不渲染（页眉论文标题不受影响），声明页起排为第 1 页。

```bash
typst compile thesis.typ blind.pdf --input mode=blind
typst compile thesis.typ print.pdf --input mode=print
```

模式值拼写错误时编译会立即报错并列出合法取值；Tinymist 预览不传 `--input`，始终按默认的 review 版渲染。

= 总结与展望 #en[Conclusion and Outlook]

== 使用要点小结 #en[Summary of Key Points]

使用本模板时请把握四个要点：第一，编译时带上 `--font-path fonts`，缺少标准字体的电脑可直接加载或安装包内字体文件，以保证字体与模板一致；第二，严格按照封面、声明、摘要、目录、正文、参考文献、附录、致谢的顺序组装文档；第三，所有图、表、公式与章节编号均自动维护，不要在正文中手写编号；第四，标题的英文译名通过 `#en[...]` 标注，标签必须写在 `#en[...]` 之后。

== 常见问题 #en[Frequently Asked Questions]

- *包缓存未更新*：通过 `@preview` 导入的包会被编译器缓存到用户目录下，修改包源码后若编辑器仍显示旧效果，应将改动同步到缓存目录后再重新编译。
- *提示缺少字体*：检查系统是否已安装规范要求的标准字体，或确认 `--font-path` 指向包内 `fonts/` 目录。
- *xlsx 读取失败*：通常是路径或文件名问题，建议数据文件统一放在 `tables/` 目录并使用相对路径。

== 学习资源与展望 #en[Further Resources and Prospect]

进一步学习可从三条线索展开：通读 Typst 官方文档掌握完整语法@typst-docs；在 Typst Universe 上研究其他开源包的实现@typst-universe；回溯 TeX 与排版学的经典文献，理解排版惯例的由来@knuth1986texbook。

未来本模板将随学校格式规范与 Typst 版本持续更新，并计划补充更多学院的封面参数与常用文体环境，希望能帮助同学们从繁琐的格式调整中解放出来，把精力集中于论文内容本身。

#references("/template/refs.bib")

#appendix[
  附录用于放置不宜放入正文但又有参考价值的材料，如调查问卷、补充实验结果、程序源代码等。下表汇总了编译本模板所需的环境与依赖包版本。

  #align(center)[
    #tlt(read("./tables/编译环境与依赖.xlsx", encoding: none))
  ]
]

#thanks[
  本教程示例中的致谢段落为占位文本，请替换为你自己的内容。可以向导师在论文选题、研究方案设计与论文撰写修改过程中给予的悉心指导致以谢意，感谢学院各位任课教师的教诲、同门与同学在学习生活中给予的帮助，以及家人的理解与支持，并感谢参与论文评审与答辩的各位专家学者提出的宝贵意见。
]
