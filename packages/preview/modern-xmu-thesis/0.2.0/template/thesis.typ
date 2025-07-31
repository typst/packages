#import "@preview/modern-xmu-thesis:0.2.0": documentclass

#let (
  // 布局函数
  twoside,
  doc,
  preface,
  mainmatter,
  appendix,
  // 页面函数
  cover,
  integrity,
  acknowledgement,
  abstract,
  abstract-en,
  outline-page,
  outline-page-en,
  bilingual-bibliography,
) = documentclass(
  twoside: true, // 双面模式，会加入空白页，便于打印
  info: (
    title: ("基于 Typst 的", "厦门大学本科毕业论文模板"),
    title-en: "An XMU Undergraduate Thesis Template\nPowered by Typst",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    department: "某学院",
    major: "某专业",
    supervisor: ("李四", "教授"),
    // supervisor-outside: ("王五", "副教授"),
    submit-date: datetime.today(),
  ),
)

#show: doc

// 封面页
#cover()

// 诚信承诺书
#integrity()

// ====== 前言 ======
#show: preface

// 致谢
#acknowledgement()[
  致谢语应以简短的文字对课题研究与论文撰写过程中曾直接给予帮助的人员（例如指导教师、答疑教师及其他人员）表示自己的谢意。

  如果本模板的使用对你有帮助，你也可以将其作为致谢的一部分。
]

// 中文摘要
#abstract(
  keywords: ("本科毕业论文", "厦门大学", "Typst"),
  // outlined: true,
  // outline-title: "中文摘要",
  // outline-title-en: "Abstract (Chinese Ver.)",
)[
  // 导入 LaTeX 图标
  #import "@preview/metalogo:1.2.0": LaTeX

  本模板参考#link("https://github.com/nju-lug/modern-nju-thesis")[南京大学学位论文模板 modern-nju-thesis]与#link("https://github.com/F5Soft/xmu-template")[厦门大学本科毕业论文 #LaTeX 模版]，并根据《厦门大学本科毕业论文（设计）规范》@XMUThesisStandard 进行制作。

  本模版提供高清封面、诚信承诺书、中英文摘要环境、中英文目录自动生成、附录环境、参考文献环境、致谢环境等。本模板通过 Typst
  字体 fallback 功能，适配了 Windows 和 macOS 系统的字体，将以思源黑体/宋体、Windows 自带黑体/宋体、macOS
  自带黑体/宋体的优先级使用编译环境中存在的字体。

  建议使用前先完整浏览本模板中的所有内容，以完整地了解使用模板的方法与 Typst 的基础用法。
]

// 英文摘要

#abstract-en(
  twoside: false,
  keywords: ("Undergraduate Thesis", "Xiamen University", "Typst"),
  // outlined: true,
  // outline-title: "英文摘要",
  // outline-title-en: "Abstract (English Ver.)",
)[
  // 导入 LaTeX 图标
  #import "@preview/metalogo:1.2.0": LaTeX

  This template is based on #link("https://github.com/nju-lug/modern-nju-thesis")[modern-nju-thesis] template and #link("https://github.com/F5Soft/xmu-template")[Xiamen University Undergraduate Thesis #LaTeX Template], and is created according to the _Xiamen University Undergraduate Dissertation (Design) Specification_@XMUThesisStandard.

  This template provides high-resolution cover, integrity commitment letter, Chinese and English abstract environments, automatic generation of Chinese and English tables of contents, appendix environment, reference environment, acknowledgment environment, etc. Through Typst's font fallback feature, this template adapts fonts for Windows and macOS systems, using Source Han Sans/Serif, Windows built-in Sans/Serif, and macOS built-in Sans/Serif fonts in order of priority based on what fonts are available in the compilation environment.

  It is recommended to fully browse all the content in this template before use to fully understand how to use the template and the basic usage of Typst.
]

// 中文目录页
#outline-page()

//  英文目录页
// 此处可以传入 `entry-numbering` 参数，用于设置英文版目录中，各级标题的前缀
#outline-page-en(twoside: false)

// ====== 正文部分 ======
#show: mainmatter

= 使用说明#metadata((en: "Introduction"))

== 环境配置#metadata((en: "Environment Setup"))

首先，需要配置好 Typst 环境，这里推荐使用 Web APP#footnote[https://typst.app/ ，中国大陆地区可以正常访问。] 在线编辑或 VSCode + Tinymist 插件本地编辑。

=== 在线编辑#metadata((en: "Editing Online"))

Web App 有些类似于 Overleaf，提供了在线编辑和编译的功能，适合不想在本地安装 VSCode 的用户。但是 Web App 并没有安装本地 Windows 或 MacOS 所拥有的字体，所以字体上可能存在差异，需要自行手动上传用到的字体。并且 Web App 是全英文页面，因此更推荐本地编辑。

只需在 Web App 中选择 「Start from template」，在弹出窗口中选择「modern-xmu-thesis」，即可在线创建模板并使用。

=== 本地编辑#metadata((en: "Editing Locally"))

VSCode + Tinymist 需要先在官网#footnote[https://code.visualstudio.com/download]上下载安装 VSCode，随后在右侧的「扩展/Extension」中搜索 Tinymist 进行安装。

在 VSCode 中按下「Ctrl + Shift + P」打开命令界面，输入「Typst: Show available Typst templates (gallery) for picking up a template」打开 Tinymist 提供的模板列表，然后从里面找到 modern-xmu-thesis，点击「+」号即可创建对应的论文模板。

最后用 VS Code 打开生成的目录，打开 thesis.typ 文件，并按下「Ctrl + K, V」进行实时编辑和预览。

== 编译#metadata((en: "Compiling"))

在 Web App 中，编辑完毕后，点击左上角的「File」按钮，选择「Export」中的「PDF」，即可下载编译得到的 PDF 文件。

在 VSCode 中，编辑完毕后，按下「Ctrl + Shift + P」打开命令界面，输入「Typst: Export the Opened File as PDF」，即可导出编译得到的 PDF 文件。

== 使用模板#metadata((en: "Using the Template"))

本模版根据《厦门大学本科毕业论文（设计）规范》@XMUThesisStandard 制作，使用时无需考虑各种格式指令，只需设置好章节标题，填充摘要、附录、参考文献、致谢等内容即可。

如果需要自定义部分样式，目前需要阅读源码中的注释来对一些函数传入的参数进行修改。如果有一定 Typst 基础，也可以 Fork 本模板的仓库，进行本地修改和编译。

= 使用示例#metadata((en: "Usage Examples"))

== 二级标题#metadata((en: "Section (English Ver.)"))

一级标题（章）总会另起一页。

=== 三级标题#metadata((en: "Subsection (English Ver.)"))

#import "@preview/zebraw:0.4.8": zebraw // 导入代码块美化包

使用@lst:创建各级标题 来创建带英文元数据的各级标题。

#figure(
  zebraw(lang: false)[
    ```typst
    = 一级标题#metadata((en: "Chapter"))
    == 二级标题#metadata((en: "Section"))
    === 三级标题#metadata((en: "Subsection"))
    ```
  ],
  kind: raw,
  caption: [创建各级标题],
) <创建各级标题>

==== 四级标题#metadata((en: "Subsubsection (English Ver.)"))

《厦门大学本科毕业论文（设计）规范》中要求一般不使用四级标题，因此如果未设置 `outline-page` 中的 depth 参数，四级标题将不会显示在目录中。

== 列表#metadata((en: "List"))

=== 有序列表#metadata((en: "Ordered List"))

+ 有序列表项一
+ 有序列表项二
  + 有序子列表项一
  + 有序子列表项二

=== 无序列表#metadata((en: "Unordered List"))

- 无序列表项一
- 无序列表项二
  - 无序子列表项一
  - 无序子列表项二

=== 术语列表#metadata((en: "Glossary List"))

/ 术语一: 术语解释
/ 术语二: 术语解释

== 图表#metadata((en: "Figures and Tables"))

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:xmu-logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

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
        caption: [常规表#footnote[《厦门大学本科毕业论文（设计）规范》中要求表格应优先采用三线表]],
      ) <timing>
    ][
      #h(50pt)
    ][
      #figure(
        table(
          columns: 4,
          stroke: none,
          table.hline(stroke: 1pt),
          [t], [1], [2], [3],
          table.hline(stroke: .75pt),
          [y], [0.3s], [0.4s], [0.8s],
          table.hline(stroke: 1pt),
        ),
        caption: [三线表],
      ) <timing-tlt>
    ]
  ),
)

#figure(
  image("images/xmu-logo.svg", width: 20%),
  caption: [厦门大学校徽],
) <xmu-logo>

=== 数学绘图#metadata((en: "Plotting"))

一般而言，建议将绘图部分放在 Python 或 MATLAB 或其他软件中进行，在论文中使用其导出的图像。Typst 也有一些合适的包用于绘图，例如较老的「cetz-plot#footnote[https://typst.app/universe/package/cetz-plot]」与较新的「lilaq#footnote[https://typst.app/universe/package/lilaq]」包。此处用 lilaq 包进行简单的绘图演示。

#figure(
  {
    import "@preview/lilaq:0.1.0" as lq
    // 修复 https://github.com/lilaq-project/lilaq/issues/7，该 issue 已关闭，但版本尚未更新
    set par(first-line-indent: 2em) // TODO: 当 lilaq 版本更新至 0.1.1 及以上时删除此行。
    let x = lq.linspace(0, 10)
    lq.diagram(
      title: [$sin x$ 的函数图像],
      xlabel: $x$,
      ylabel: $y$,

      lq.plot(x, x.map(x => calc.sin(x))),
    )
  },
  caption: [数学绘图示例],
)

=== 画图#metadata((en: "Drawing"))

对于复杂的图形，建议使用「所见即所得」式的绘图工具绘制图形并导入到论文中。Typst 有一些用于画图的包，最基础的是「cetz#footnote[https://typst.app/universe/package/cetz]」，类似于 LaTeX 中的 tikz 包；此外还有专注于流程图绘制的「fletcher#footnote[https://typst.app/universe/package/fletcher]」包。此处用 fletcher 包进行简单的画图演示。

#figure(
  {
    import "@preview/fletcher:0.5.7": diagram, node, edge
    diagram(
      cell-size: 15mm,
      $
        G edge(f, ->) edge("d", pi, ->>) & im(f) \
        G slash ker(f) edge("ur", tilde(f), "hook-->")
      $,
    )
  },
  caption: [流程图示例],
)

== 公式#metadata((en: "Formulas"))

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

我们也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

== 代码与伪代码#metadata((en: "Codes and Pseudocodes"))

如果只是简单地展示代码，只需要使用 「\`\`\`」将代码进行包裹即可，这与 Markdown 的语法一致。Typst 的代码块支持语法高亮，就像@lst:code 一样。引用时需要加上 `lst:` 前缀。如果需要对代码块进行一定美化，就像@lst:创建各级标题 一样，则可以使用「zebraw#footnote[https://typst.app/universe/package/zebraw]」包进行美化。

#figure(
  ```py
  def add(x, y):
    return x + y
  ```,
  caption: [代码块示例],
) <code>

对于展示算法使用的伪代码，可以使用「lovelace#footnote[https://typst.app/universe/package/lovelace]」包绘制。

#figure(
  kind: "algorithm",
  supplement: [算法],
  {
    import "@preview/lovelace:0.3.0": *
    pseudocode-list(booktabs: true)[
      - *Function* DFS(G, $v$)
      - Input: 图 G = (V, E) 和起始顶点 $v$
      - Output: 图 G 的深度优先遍历序列
      + 标记顶点 $v$ 为已访问
      + 将 $v$ 加入遍历序列
      + *for* *each* 顶点 $w in$ Adj[$v$] *do*
        + *if* $w$ 未被访问 *then*
          + 递归调用 DFS(G, $w$)
        + *end* *if*
      + *end* *for*
    ]
  },
  caption: [伪代码示例],
)

== 参考文献#metadata((en: "References"))

参考文献使用 BibTeX 格式的 .bib 文件，根据规范使用 GB/T 7714－2005《文后参考文献著录规则》进行编排。

你可以像引用其他标签一样引用参考文献，例如`@lu2021deepxde`@lu2021deepxde。

// ====== 附录 ======
// 手动分页
#if twoside {
  set page(header: none, footer: none)
  pagebreak(weak: true, to: "odd")
}

// 参考文献
// 默认使用 gb-7714-2005-numeric 样式
#bilingual-bibliography(bibliography: bibliography.with("ref.bib"))

// 手动分页
#if twoside {
  set page(header: none, footer: none)
  pagebreak(weak: true, to: "odd")
}

#show: appendix

= 附录#metadata((en: "Appendix"))

== 附表#metadata((en: "Tables"))

这里放一些附录的内容，例如表格或其他说明。如@tbl:appendix-table。制作模板时间精力有限，因此附录不会自动编号。如需编号为「附录 A」，请手动添加。

#figure(
  table(
    columns: 4,
    stroke: none,
    table.hline(stroke: 1pt),
    [t], [1], [2], [3],
    table.hline(stroke: .75pt),
    [y], [0.3s], [0.4s], [0.8s],
    table.hline(stroke: 1pt),
  ),
  caption: [附录表格示例],
) <appendix-table>

附录中图表和公式编号均以大写字母开头，区别于正文部分的编号。

$ 1 / pi = (2 sqrt(2)) / (99^2) sum_(k=0)^oo ((4k)!) / (k!^4) (26390k + 1103) / (396^(4k)) $

== 厦门大学本科毕业论文（设计）规范摘要#metadata((en: "Abstract of Xiamen University Undergraduate Dissertation (Design) Specification"))

- 毕业论文（设计）一般包括：前置部分、正文、参考文献、附录 4 个部分。

- 题目应简洁、明确、有概括性，避免使用不常见的缩略词、缩写字。中文题目一般不宜超过 20 个字，必要时可增加副标题。英文题目应与中文题目内容相同。

- 主修专业毕业论文（设计）封面使用 160g 白色双胶纸，辅修封面为 160g 浅黄色皮纹纸。内页均为 A4 规格 80g 双胶纸。

- 章的标题占2行，标题以外的文字为1.5倍行距。

- 上边距和左边距应留 25mm 以上间隙，下边距和右边距应分别留 20mm 以上间隙。

- 每页须加“页眉”和“页码”。奇数页页眉内容为当前章名，如“第一章 绪论”。偶数页页眉内容为论文题目。学位论文的页码，正文、参考文献、附录部分用阿拉伯数字连续编码并居中，前置部分用罗马数字单独连续编码居中（封面除外）。

- 封面中文标题：二号黑体

- 封面英文标题：三号 Times New Roman 加粗

- 中文摘要标题：小三号黑体

- 中文关键词标题：小四号黑体

- 中文摘要、关键词内容：小四号宋体

- 英文摘要标题：小三号 Times New Roman 加粗

- 英文关键词标题：小四号 Times New Roman 加粗

- 英文摘要、关键词内容：小四号 Times New Roman

- 中文目录标题：小三号黑体

- 中文目录中章的标题：四号黑体

- 中文目录中节的标题：小四号黑体

- 中文目录中三级标题：小四号宋体

- 英文目录标题：小三号 Times New Roman 加粗

- 英文目录中章的标题：四号 Times New Roman 加粗

- 英文目录中节的标题：小四号 Times New Roman 加粗

- 英文目录中三级标题：小四号 Times New Roman

- 章的标题：小三号黑体

- 节的标题：四号黑体

- 三级标题：小四号黑体

- 正文：小四号宋体

- 页眉：小五号宋体

- 页码：小五号 Times New Roman

- 注释内容：小五号宋体

- 表格、图的标题、单位、表头：五号宋体加粗

- 表格内容：五号宋体

- 表格、图的资料来源：小五号宋体

- 参考文献标题：小三号黑体

- 中文参考文献表：五号宋体

- 英文参考文献表：五号 Times New Roman

- 附录标题：小三号黑体

- 致谢标题：小三号黑体

- 致谢内容：小四号宋体

对于中英文混杂的内容，中文的字体若是用宋体，英文的字体则采用 Times New Roman；中文的字体若是黑体，英文的字体则采用 Arial。
