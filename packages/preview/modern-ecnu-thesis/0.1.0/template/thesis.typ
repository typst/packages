#import "@preview/modern-ecnu-thesis:0.1.0": documentclass, indent, no-indent, word-count-cjk, total-words

// 模板用到的主要字体：https://github.com/jtchen2k/modern-ecnu-thesis/tree/main/fonts/
// 如果是在 Web App 上编辑，你应该手动上传上述字体文件，否则不能正常使用「楷体」和「仿宋」。
// 如果在本地编辑，将使用 Windows / macOS 内置的宋体、黑体、楷体、仿宋字体。

#let (
  // 布局函数
  twoside, doc, preface, mainmatter, mainmatter-end, appendix,
  // 页面函数
  fonts-display-page, cover, decl-page, committee, abstract, abstract-en, bilingual-bibliography,
  outline-page, list-of-figures, list-of-tables, notation, acknowledgement,
) = documentclass(
  // doctype: "bachelor",  // "bachelor" | "master" | "doctor", 文档类型，默认为硕士生 master
  doctype: "master",
  // degree: "academic",  // "academic" | "professional", 学位类型，默认为学术型 academic
  degree: "academic",
  // anonymous: true,  // 盲审模式
  twoside: false, // 双面模式，会加入空白页，便于打印。双面模式下 front matter 部分页码始终在右侧。
  // 可自定义字体，先英文字体后中文字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」。
  // fonts: (楷体: ("Times New Roman", "FZKai-Z03S"))
  info: (
    // 如有需要，title 与 department 均支持多行。可以使用 \n 来分行或使用列表。
    title: ("基于 Typst 的", "华东师范大学学位论文"),
    title-en: "Typst Thesis Template for\nEast China Normal University",
    grade: "20XX",
    student-id: "31415926536",
    author: "张三",
    author-en: "San Zhang",
    department: ("信息学部", "计算机科学与技术学院"),
    department-en: "School of Computer Science and Technology\nFaculty of Information",
    // 专业 / 专业学位类别
    major: "某专业",
    major-en: "Computer Science",

    // 研究生相关：研究方向 / 专业学位领域
    field: "某方向",
    field-en: "XX Field",
    supervisor: ("李四", "教授"),
    supervisor-en: ("Prof.", "Si Li"),
    // supervisor-ii: ("王五", "副教授"),
    // supervisor-ii-en: ("Assoc. Prof.", "Wu Wang"),
    submit-date: datetime.today(),
    // 密级与分类号，按照教务要求，可留白
    secret-level: "",
    clc: "",
    // 答辩委员会成员
    committee-members: (("赵六", "教授", "华东师范大学", "主席")),
  ),
  // 参考文献源
  bibliography: bibliography.with("ref.bib"),
)

// 文稿设置。fix-cjk 用于修复中文字符的换行问题。
#show: doc.with(fix-cjk: true)

// 字体展示测试页
// #fonts-display-page()

// 封面页
#cover(
  // 这里的可选参数可以用于调整封面字段每一行的长度
  title-line-length: 320pt,
  title-line-length-en: 300pt,
  meta-info-line-length: 200pt,
  meta-info-line-length-en: 230pt,
)

// 声明页（仅研究生）
#decl-page()

// 答辩委员会页（仅研究生）
#committee()

// 前言
#show: preface

// 中文摘要
#abstract(
  keywords: ("天行健", "君子以", "自强", "不息")
)[
  滚滚长江东逝水，浪花淘尽英雄。是非成败转头空。青山依旧在，几度夕阳红。白发渔樵江渚上，惯看秋月春风。一壶浊酒喜相逢。古今多少事，都付笑谈中。
]

// 英文摘要
#abstract-en(
  keywords: ("To", "be", "or", "not", "to", "be")
)[
  #lorem(100)
]

// 目录。preface 中的项目均可以通过可选的 outlined 属性控制是否在目录中显示
#outline-page(outlined: false)

// 插图目录
#list-of-figures()

// 表格目录
#list-of-tables()

// 符号表
#notation[
  / DFT: 密度泛函理论 (Density functional theory)
  / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
  / RAII: 资源获取即初始化 (Resource Acquisition Is Initialization)
]

// 正文
// 可选的，可以通过 #show: mainmatter.with(figure-clearance: 0pt) 来设置浮动图表的间距或其他参数
#show: mainmatter

// 字数统计开始
#show: word-count-cjk

= 导　论

== 列表

=== 无序列表

这里是一些无序列表示例：

- 无序列表项一
- 无序列表项二
  - 无序子列表项一
  - 无序子列表项二

=== 有序列表

这里是一些有序列表示例：

+ 有序列表项一
+ 有序列表项二
  + 有序子列表项一
  + 有序子列表项二

=== 术语列表

/ 术语一: 术语解释
/ 术语二: 术语解释

== 图表

引用@tbl:timing，引用@tbl:timing-tlt，以及@fig:ecnu-logo。引用图表时，表格和图片分别需要加上 `tbl:`和`fig:` 前缀才能正常显示编号。

#figure(
  caption: [常规表],
)[
  #table(
    align: center + horizon,
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  )
] <timing>

#figure(
  caption: [三线表],
)[
  #table(
    columns: 4,
    stroke: none,
    table.hline(),
    [t], [1], [2], [3],
    table.hline(stroke: .5pt),
    [y], [0.3s], [0.4s], [0.8s],
    table.hline(),
  )
] <timing-tlt>

你可以使用 figure 的 `placement` 属性 #footnote[
  需要 Typst 版本 >= 0.12.0：#link("https://github.com/typst/typst/releases/tag/v0.12.0")。
] 来设置类似的浮动图表位置。可用的值有 `top`、`bottom` 与 `none`，分别对应 LaTeX 中的 t、b 与 h。若要实现类似 LaTeX 中 `p` 属性的整页图表，可结合 `pagebreak()` 函数与图片上下的 `h(1fr)` 来实现。


#figure(
  placement: top, // 顶部浮动
  caption: [顶部浮动图片。A floating figure at the top.],
)[
  #image("images/ecnu-emblem.svg", width: 20%)
] <ecnu-logo>

== 数学公式

可以像 Markdown 一样写行内公式 $x + y$，以及带编号的行间公式：

$ phi.alt := (1 + sqrt(5)) / 2 $ <ratio>

引用数学公式需要加上 `eqt:` 前缀，则由@eqt:ratio，我们有：

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

我们也可以通过 `<->` 标签来标识该行间公式不需要编号

$ y = integral_1^2 x^2 dif x $ <->

而后续数学公式仍然能正常编号。

$ F_n = floor(1 / sqrt(5) phi.alt^n) $

== 引用 <sec:ref>

可以像这样引用参考文献：图书 #[@蒋有绪1998] 和会议 #[@中国力学学会1990]，或者引用段落：@sec:ref。

== 代码块

代码块支持语法高亮。引用时需要加上 `lst:` @lst:code

#figure(
  caption:[代码块],
)[
```cpp
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, world!" << endl;
    return 0;
}
```
] <code>

== 缩进

模板的所有段落默认都有首行缩进。如果需要取消缩进，可以使用 `#no-indent`。若需手动缩进，可以使用 `#indent`。

#no-indent 比如，这是一个没有首行缩进的段落。

== 中文字符的换行

模板默认启用了 CJK 字符的换行修复。启用该修复后，你可以在源代码中
任
意
换
行
，
// 或插入注释。只有两个连续的换行会被视为段落分割。
模板输出时不会把中文源码里的换行转为空格，而只把西文内的换行转换为空格（this
is
an
example）。在启用该修复后，Tinymist 的定位功能可能会失效，你可以将 `#show: doc.with(fix-cjk: true)` 一行修改为 `#show: doc.with(fix-cjk: false)`。来临时禁用该修复。

== 字数统计

正文与附录的的总字数为：#total-words。你也可以使用以下命令来使用 `typst` 命令行统计字数 / 字符数：

```bash
typst query thesis.typ '<total-words>' 2>/dev/null --field value --one
typst query thesis.typ '<total-characters>' 2>/dev/null --field value --one
```

= 正　文

// 用于生成占位符。可删除。
#import "@preview/kouhu:0.1.0": kouhu
#kouhu(builtin-text: "zhufu", length: 1348)

== 正文子标题

=== 正文子子标题

#[
#set enum(numbering: "1)", indent: 0.75em)
+ 自定义列表编号与缩进
+ 自定义列表编号与缩进
]

// 手动分页示例
#if twoside {
  pagebreak() + " "
}

// 中英双语参考文献
// 默认使用修改后的 gb-7714-2015-numeric-nosup.csl 样式（引用文字非上标格式）。该文件嵌入在模板内。如需使用上标格式，使用 Typst 自带的 gb-t-7714-2015-numeric 即可。
// 将 full 设置为 false 可以只显示正文中引用的文献。
#bilingual-bibliography(full: true, style: "./gb-t-7714-2015-numeric-nosup.csl")

// 致谢
#acknowledgement[

_感谢以下模板提供的参考：_


- #link("https://github.com/nju-lug/modern-nju-thesis")[modern-nju-thesis] by #link("https://github.com/Orangex4")[OrangeX4]
- #link("https://github.com/YijunYuan/ECNU-Undergraduate-LaTeX")[ECNU-Undergraduate-LaTeX] by #link("https://github.com/YijunYuan")[YijunYuan]
- #link("https://www.overleaf.com/latex/templates/hua-dong-shi-fan-da-xue-shuo-shi-lun-wen-mo-ban-2023/ctvnwyqtsbbz")[华东师范大学硕士论文模板-2023] by ivyee17
- #link("https://github.com/ECNU-ICA/ECNU_graduation_thesis_template")[ECNU_graduation_thesis_template] by #link("https://github.com/ECNU-ICA")[ECNU-ICA]
- #link("https://github.com/DeepTrial/ECNU-Dissertations-Latex-Template")[ECNU-Dissertations-Latex-Template] by #link("https://github.com/DeepTrial")[Karl Xing]
]

// 手动分页
#if twoside {
  pagebreak() + " "
}

// 附录。可选地，可以重置标题 counter
#show: appendix.with(reset-counter: false)

= 附录

== 附录子标题

=== 附录子子标题

附录内容，这里也可以加入图片，例如@fig:appendix-img。

#figure(
  caption: [图片测试],
)[
#image("images/ecnu-emblem.svg", width: 20%)
] <appendix-img>

= 攻读硕/博士学位期间科研情况

#[
// Typst 暂不支持多 bibliography 功能。因此需用有序列表来手动列出参考文献。
#set enum(numbering: "[1]")
#set par(justify: false)

+ J. von Neumann, “First draft of a report on the EDVAC,” IEEE Annals of the History of Computing, vol. 15, no. 4, pp. 27–75, 1993, doi: 10.1109/85.238389.
+ A. M. Turing, “On Computable Numbers, with an Application to the Entscheidungsproblem,” Proceedings of the London Mathematical Society, vol. s2-42, no. 1, pp. 230–265, 1937, doi: 10.1112/plms/s2-42.1.230.
]

