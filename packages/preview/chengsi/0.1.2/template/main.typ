#import "@preview/chengsi:0.1.2": notes, environments
#import "config.typ": config

#let demo = config + (
  title: "澄思使用手册",
  subtitle: "Chengsi Guide",
  author: "澄思 · Chengsi",
  description: [用法、配色与排版的完整说明，末尾附一份示例笔记。],
)
#let env = environments(config: demo)
#let epigraph = env.epigraph
#let appendix = env.appendix
#let ip(x, y) = $lr(chevron.l #x, #y chevron.r)$
#show: notes.with(config: demo)

// 前八章是用法说明，第九章是一份完整的示例笔记。
// 开始写自己的笔记时，可以直接删除前八章，只留最后一章作为骨架。

= 开始使用

#epigraph(author: [孔子], source: [《论语·卫灵公》])[
  工欲善其事，必先利其器。
]

澄思是一份给长期书写准备的数学笔记模板。中英混排、封面与目录、定理与证明、章首题辞、代码片段、参考文献共用同一套版式，三套配色只换颜色不改规则，且不依赖任何第三方包。

== 模板有什么

- 封面、目录与页眉页码；封面不出现页码，目录用罗马数字，正文从 1 开始。
- 定义、定理、引理、命题、推论、例题、练习、证明、札记，共九种环境。
- 章首题辞：单行引文自动右对齐，需要换行时自动左对齐，支持中英对照。
- 代码块：语言标识、标题栏、可选行号，长代码自然跨页且行号不重置。
- 参考文献：数字编号、点击跳转、悬挂编号；外部链接带细下划线。

三种配色共享全部版式规则：字体、字号、间距、编号和分页完全一致，默认仍是原版青绿 `teal`。

== 初始化项目

要求 Typst 0.15.0 或更新版本。运行：

```sh
typst init @preview/chengsi:0.1.2 my-notes
cd my-notes
typst compile main.typ
```

初始化之后需要你动手的只有三样：`config.typ` 填标题、作者与字体，`main.typ` 写正文，`references.bib` 管文献。

== 最小的入口文件

```typst
#import "@preview/chengsi:0.1.2": notes, environments
#let config = (title: "数学笔记", author: "你的名字", cover: false, toc: false)
#let env = environments(config: config)
#show: notes.with(config: config)

= 实数
#(env.theorem)(title: [平方非负])[
  对任意 $x in RR$，有 $x^2 >= 0$。
]
```

四条语句就能得到一份可以编译的笔记：前两条取来模板与配置，第三条创建环境，第四条 `notes` 之后才真正开始。`#show: notes.with(...)` 是分界线，之前是准备，之后是正文，目录会从这个位置往后编排。

== 文件结构

#table(
  columns: (1fr, 2.6fr),
  table.header([文件 / File], [作用 / Role]),
  [`main.typ`], [正文入口。章节、公式、环境的书写都在这里。],
  [`config.typ`], [配置字典。日常只改这一个文件即可。],
  [`references.bib`], [文献库。只有被引用过的条目才会出现在文末。],
  [`lib.typ`], [公开入口，导出 `notes`、`environments`、`defaults`、`themes`。],
  [`template.typ`], [版式实现：封面、目录、页眉、标题与环境样式。],
  [`themes.typ`], [三套配色定义，键为 `teal`、`indigo`、`sepia`。],
  [`styles/`], [代码高亮配色，每种主题一个 `.tmTheme` 文件。],
)

迁移模板时请把 `styles/` 一并复制：`template.typ` 会按下沉主题读取对应的高亮文件。

== 三个公开函数

`notes(config: (:), body)` 应用整体版式，`environments(config: (:))` 返回环境字典，两者应当收到同一个配置字典。此外 `defaults` 是包默认值字典，`themes` 是以 `teal`、`indigo`、`sepia` 为键的配色字典，需要派生自己的版本时可以直接读取。

== 许可与署名

代码、主题文件、文档以及 `template/` 中原创的示例内容采用 #link("https://github.com/zhaozigu/typst-chengsi-template/blob/main/LICENSE")[MIT-0] 许可，可以自由使用、修改与分发，无需保留署名或许可文本。示例里明确标注来源的古典引文与书目信息不主张为本项目原创，项目也不分发第三方字体或书籍全文。

= 常用配置

#epigraph(author: [老子], source: [《道德经·第二十二章》])[
  少则得，多则惑。
]

所有配置都写在 `config.typ` 的一个字典里，然后用一句 `#import` 交给模板：

```typst
#import "config.typ": config
```

没有填写的项使用包默认值，也就是 `defaults` 里的那一份。写错字段名会直接报错而不是被悄悄忽略——宁可编译失败，也不想一条配置静默失效。

== 封面与目录

`title`、`subtitle`、`description` 决定封面的主标题、副标题与引言；`author`、`institution`、`date`、`edition` 决定封面页脚的作者、机构、日期与卷次，其中日期是手写的文本，不会自动填今天。`cover` 与 `toc` 是各自独立的开关，短笔记可以把两者都关掉。

`lang` 取 `"zh"`、`"en"` 或 `"bilingual"`，它决定自动生成的目录标题与环境名称，不会替你翻译正文。`toc-depth: 2` 控制目录深度，`toc-title: auto` 时按 `lang` 生成标题，也可直接传 `[目次]` 这样的内容块。

页眉显示当前页所属章节。标题很长时容易被页码挤窄，可以用简短的章节名称并设置 `running-title`。

== 编号

定义、定理、引理、命题、推论和练习共用一条*全文连续*的序列（定义 1、定理 2、练习 3 ……）；例题另有一条序列（例 1、例 2 ……）；行间公式再有一条独立的全文连续编号。三条序列都不按章重置。`none` 可以分别关掉它们：

```typst
theorem-numbering: "1",   // 定义、定理、引理、命题、推论、练习
example-numbering: "1",   // 例题
equation-numbering: "(1)", // 行间公式
theorem-numbering: none,  // 全部关闭
```

关闭编号之后不要再对相应对象使用交叉引用。从 0.1.0 升级时请注意：例题不再占用定理序列，后续环境的编号会相应变化。

== 页面、字号与间距

`paper` 与 `margin` 控制纸张与页边距。`leading` 是同一段落内部的行间距，`paragraph-spacing` 是段落之间的距离，两者分开控制。`heading-before` 与 `heading-after` 管二级及更深层标题的前后留白，一级章标题下方的留白由 `chapter-after` 单独负责，不受 `heading-after` 影响。

标题字号分三级可调：`chapter-label-size` 是章首“章节 / CHAPTER”标识的字号，`chapter-title-size`、`section-title-size`、`subsection-title-size` 分别对应一级、二级和三级以下的标题。公式默认随周围文字缩放（`math-scale: 98%`），`equation-spacing` 控制行间公式的上下留白，`environment-title-gap` 给所有环境的标题与正文之间再补一点空隙。

== 速查表

#table(
  columns: (1.6fr, 2.2fr),
  table.header([配置项 / Key], [作用 / Purpose]),
  [`title`, `subtitle`, `description`], [封面主标题、副标题和引言],
  [`author`, `institution`], [作者与机构],
  [`date`, `edition`], [日期与卷次；日期为手写文本],
  [`lang`], [`"zh"`、`"en"` 或 `"bilingual"`；只影响自动生成的环境名],
  [`cover`, `toc`], [独立开关封面与目录],
  [`toc-depth: 2`, `toc-title: auto`], [目录深度与自定义目录标题],
  [`chapter-break: true`], [一级标题是否另起一页；短笔记可关闭],
  [`heading-numbering: "1.1"`], [标题编号格式；`none` 关闭],
  [`equation-numbering: "(1)"`], [行间公式编号；`none` 关闭],
  [`theorem-numbering: "1"`], [定义、定理、引理、命题、推论、练习的共用编号],
  [`example-numbering: "1"`], [例题的独立编号],
  [`paper: "a4"`, `margin`], [纸张与页边距],
  [`font-size: 10.5pt`, `leading: 0.8em`], [正文字号与段内行间距],
  [`paragraph-spacing: 1.2em`], [段落之间的间距，与 `leading` 分别控制],
  [`heading-before`, `heading-after`], [二级及更深层标题前后的间距],
  [`chapter-label-size`, `chapter-title-size`], [章首标识与一级章标题字号],
  [`section-title-size`, `subsection-title-size`], [二级节标题与三级以下标题字号],
  [`accent`, `tint`], [强调色与环境浅底色],
  [`rule`, `cover-paper`], [细线色与封面底色],
  [`ink`, `muted`], [正文色与次要文字色],
  [`headers`, `page-numbers`], [页眉与页码],
  [`running-title`], [页眉左侧的短标题，长章节名可在此缩短],
)

表中是包的默认值。初始化得到的 `config.typ` 用了更宽松的一组：`paragraph-spacing: 1.5em`、`heading-after: 1.5em`、`chapter-label-size: 15pt`、`chapter-title-size: 25pt`、`section-title-size: 15pt`。

== 两套现成组合

随堂速记：不要封面与目录，章节连排，环境名用中文。

```typst
cover: false,
toc: false,
chapter-break: false,
lang: "zh",
```

黑白打印：保留全部结构，只把颜色换成灰阶。

```typst
accent: rgb("333333"),
tint: rgb("F7F7F7"),
rule: rgb("D8D8D8"),
cover-paper: white,
```

= 配色主题

#epigraph(
  author: [Claude Monet], source: [attributed],
  italic: true,
  translation: [颜色是我日复一日的痴迷、欢愉与折磨。（译文）],
)[Color is my day-long obsession, joy and torment.]

三套配色共享同一份版式代码，切换只改 `config.typ` 里的一行，然后重新编译：

```typst
theme: "indigo",
```

#table(
  columns: (1fr, 2fr, 1.2fr),
  table.header([主题名 / Theme], [配色 / Palette], [强调色 / Accent]),
  [`"teal"`], [原版青绿，暖白封面], [`#22645E`],
  [`"indigo"`], [冷调靛蓝，浅蓝灰封面], [`#45578B`],
  [`"sepia"`], [暖调赭棕，米色封面], [`#855C35`],
)

主题只改变颜色：封面、正文与次要文字、各级标题、题辞、定理底色、细线、链接、引用、代码背景与语法高亮。字体、字号、间距、编号与分页规则完全不动，默认仍是原版 `teal`。

== 覆盖单个颜色

显式写出的颜色优先于主题。例如保留靛蓝的整体关系，只把强调色调深：

```typst
theme: "indigo",
accent: rgb("334477"),
```

`link-color` 与 `citation-color` 保持 `auto` 时跟随强调色，也可以分别指定。不需要自定义时，请把 `config.typ` 末尾那几个颜色项留成注释，否则它们会覆盖所选主题。

== 迁移时要带上什么

配色在 `themes.typ`，代码高亮在 `styles/quiet.tmTheme`、`styles/indigo.tmTheme`、`styles/sepia.tmTheme`。`code-theme: auto` 会自动匹配所选主题，`none` 则彻底关闭高亮；手动指定的代码主题优先于配色主题。

完全自定义代码配色时，可以直接编辑 `styles/quiet.tmTheme`，或者在配置里传入自己的主题文件：

```typst
code-theme: read("my-theme.tmTheme", encoding: none),
```

= 字体

#epigraph(
  author: [Eric Gill], source: [An Essay on Typography, 1931],
  italic: true,
  translation: [字形是实在的物，不是物的图画。（译文）],
)[Letters are things, not pictures of things.]

#table(
  columns: (1fr, 1.5fr, 2.3fr),
  table.header([用途 / Use], [默认字体 / Font], [选择理由 / Why]),
  [英文正文], [Libertinus Serif], [字面开阔，有书籍感，带真正的斜体],
  [中文正文], [Noto Serif SC], [宋体结构，适合长篇中文阅读],
  [标题], [Noto Sans SC], [与正文形成清晰层次],
  [数学公式], [New Computer Modern Math], [独立的 OpenType 数学字体，支持复杂公式],
  [代码], [DejaVu Sans Mono], [清晰的等宽字符],
)

== 安装与后备

默认字体都是开源字体，项目不分发字体文件。Typst 网页编辑器可以直接使用它们；本地命令行内置了 Libertinus、New Computer Modern 和 DejaVu，中文还需要自己安装 #link("https://fonts.google.com/noto/specimen/Noto+Serif+SC")[Noto Serif SC] 与 #link("https://fonts.google.com/noto/specimen/Noto+Sans+SC")[Noto Sans SC]。

字体放在固定目录时用 `--font-path` 指定：

```sh
typst compile --font-path /path/to/fonts main.typ
```

请留意编译警告，缺失字体会影响排版效果：Typst 会退回后备字体，行宽与重心都会变。

== 换成自己的

五个用途分别对应 `font-latin`、`font-cjk`、`font-heading`、`font-math`、`font-code`，都可以单独替换。换成别的数学字体时请确认它支持 OpenType MATH，否则积分、求和与大括号会退化为普通字形。

= 数学环境与交叉引用

#epigraph(
  author: [Bertrand Russell], source: [The Study of Mathematics, 1902],
  italic: true,
  translation: [数学若以正当的方式看待，不仅拥有真理，也拥有至高的美。（译文）],
)[Mathematics, rightly viewed, possesses not only truth, but supreme beauty.]

`env` 提供 `definition`、`theorem`、`lemma`、`proposition`、`corollary`、`example`、`exercise`、`proof`、`remark`、`epigraph`。前七种可以编号、加 `title`、挂标签；证明和札记不编号，标题按 `lang` 自动生成。

#table(
  columns: (1.3fr, 2.5fr),
  table.header([环境 / Environment], [样式 / Appearance]),
  [定理], [浅色底与细强调线，突出核心结论],
  [定义], [强调名称和编号，无底色],
  [引理、命题、推论], [无底色，配浅色细线],
  [例题、练习], [无底色、无边框，深色标题],
  [证明、札记], [较轻的标题，保持与上下文连贯],
)

== 编号与标签

定义一个对象时把标签写在正文末尾，引用时写 `@` 加上标签名，编号由模板维护：

```typst
#(env.definition)(title: [连续 / Continuity])[
  称 $f$ 在 $x_0$ 处连续，若对任意 $epsilon > 0$ 存在 $delta > 0$，
  当 $abs(x-x_0) < delta$ 时 $abs(f(x)-f(x_0)) < epsilon$。
] <def-cont>

#(env.theorem)(title: [四则运算保持连续性])[
  若 $f,g$ 在 $x_0$ 处连续，则 $f+g$ 与 $f g$ 也在此处连续。
] <thm-cont-arith>

#(env.proof)[
  由 @def-cont 分别取 $delta_1, delta_2$，取较小者再用三角不等式合并。
]
```

上面这段源码排出来是这样的：

#(env.definition)(title: [连续 / Continuity])[
  称 $f$ 在 $x_0$ 处连续，若对任意 $epsilon > 0$ 存在 $delta > 0$，
  当 $abs(x-x_0) < delta$ 时 $abs(f(x)-f(x_0)) < epsilon$。
] <def-cont>

#(env.theorem)(title: [四则运算保持连续性])[
  若 $f,g$ 在 $x_0$ 处连续，则 $f+g$ 与 $f g$ 也在此处连续。
] <thm-cont-arith>

#(env.proof)[
  由 @def-cont 分别取 $delta_1, delta_2$，取较小者再用三角不等式合并。
]

标签名不要与 `.bib` 里的条目 key 重名。可以给常用环境绑定短名称，之后写 `#theorem(...)` 就够了：

```typst
#let theorem = env.theorem
#let proof = env.proof
```

== 取消单个公式编号

公式默认带编号。想要某一行不参与编号，临时包一层：

```typst
#math.equation(block: true, numbering: none)[$ e^(i pi) + 1 = 0 $]
```

== 拆分成文件

长篇笔记可以把章节放进单独文件，在 `#show: notes.with(...)` 之后 include：

```typst
#include "chapters/analysis.typ"
```

被 include 的文件若要用 `env`，应自己 import 模板与配置并创建环境，不要再次调用 `#show: notes`。环境本身允许自然跨页，标题会尽量与随后的正文留在一起；证明末尾附一个空心方块。

= 章首题辞

#epigraph(source: [《左传·襄公二十五年》])[
  言之无文，行而不远。
]

在 `= 章节标题` 之后、正文之前插入题辞即可。默认占正文宽度的 72%，靠右放在页面上，使用较深灰色的小号衬线字。单行短题辞连同署名整体右对齐；一旦需要换行就自动改为左对齐，署名紧接其下。中英对照时，只要原文与译文都能各自容纳在一行，同样保持右对齐。

题辞不计入目录，也不占用编号；没有题辞的章节不需要任何额外设置。

== 基本写法

`main.typ` 已经绑定了 `#let epigraph = env.epigraph`。新建入口文件时，记得在创建 `env` 之后加上这一行。

```typst
= 极限与连续

#epigraph(author: [孔子], source: [《论语·为政》])[
  学而不思则罔，思而不学则殆。
]

这里开始写本章正文。
```

`author` 与 `source` 都可以省略，`source` 支持内容块，可以放书名、页码甚至 `#link(...)`。引文本身想收进文献表却不显示编号时，像示例那样补一句 `#cite(<analects>, form: none)` 即可。

== 中英对照

英文原文可设 `italic: true`，中文译文用 `translation` 传入并保持正体。模板不会自动生成引号或译文，标点由你控制。

== 调整外观

全局外观在 `config.typ` 中修改：

```typst
epigraph-width: 72%,
epigraph-size: 9.5pt,
epigraph-align: right,      // left / center / right
epigraph-text-align: auto,  // auto 按排版宽度选；也可强制 left / right
epigraph-color: rgb("505D60"),
chapter-after: 4mm,         // 章标题下方留白
epigraph-after: 8mm,        // 题辞与正文之间留白
```

单条题辞可以覆盖宽度、整体位置与区内文字对齐：`placement` 控制整个引文区放在哪里，`text-align` 控制区内的文字与署名靠哪边。

```typst
#epigraph(width: 85%, placement: center, text-align: left, author: [作者], source: [书名])[
  在这里填写引文。
]
```

题辞作为一个整体分页，适合几行短引文，署名不会与引文分离。长篇摘录请放进正文或 `remark` 环境。

= 代码

#epigraph(
  author: [Harold Abelson], source: [《计算机程序的构造和解释》],
  italic: true,
  translation: [程序写出来是给人读的，顺便能让机器跑起来。（译文）],
)[Programs must be written for people to read, and only incidentally for machines to execute.]

带语言标记的代码围栏可以直接使用。代码块为浅灰底、细分隔线、语言标识与等宽字，中文注释有中文字体后备；关键字、字符串、数值与注释用克制的青、棕、紫、灰区分。样式只负责展示，不会运行代码。

== 三种常见语言

```python
import numpy as np
A = np.array([[2, 1], [1, 2]])
print(np.linalg.eigvalsh(A))
```

```julia
using LinearAlgebra
A = [2 1; 1 2]
println(eigvals(Symmetric(A)))
```

```matlab
A = [2 1; 1 2];
disp(eig(A));
```

`python`、`julia`、`matlab` 三种语言已在本机编译验证。也可以使用 Typst 原生支持的其他标记，例如 `bash`、`json`、`rust`、`typ`。代码块的语言栏还支持 `mathematica`、`wolfram` 与 `wl`，分别显示为 Mathematica 与 Wolfram Language；是否与 Typst 的语法高亮对应，取决于 Typst 对该语言标记的支持。没有标记的代码块仍有样式，只是不做高亮。

行内代码用单反引号，例如 `` `np.array` ``，显示为浅底标签，字号与正文一致。

== 标题与行号

需要文件名或行号时，用 `env.code` 把代码块包起来：

````typst
#(env.code)(title: [projection.jl], numbers: true)[
```julia
using LinearAlgebra
u = [1.0, 1.0]
println(dot(u, u))
```
]
````

也可以先绑定 `#let code = env.code`，之后写 `#code(...)`。`title` 是右上角的标题，`numbers` 决定这一个块是否显示行号。行号由原始代码行生成，不会插入源代码；多行字符串与注释保留连续的语法高亮状态。较长代码可以自然跨页，行号不会因翻页重置，标题栏只在开头出现一次。

外部文件可以这样插入，同样可以再包一层 `env.code`：

```typst
#raw(read("scripts/demo.py"), lang: "python", block: true)
```

长行会按可用宽度排版，但建议自己在合理位置断行，尤其是长字符串和长路径。

== 相关配置

#table(
  columns: (1.2fr, 2.6fr),
  table.header([配置项 / Key], [默认值与用途 / Default and purpose]),
  [`font-code`], [`"DejaVu Sans Mono"`，代码字体],
  [`code-size`], [`9pt`，代码块字号],
  [`code-inline-size`], [`1em`，行内代码字号；`1em` 表示与正文同号],
  [`code-leading`], [`0.55em`，代码行间距],
  [`code-fill`], [`rgb("F4F6F5")`，代码背景色],
  [`code-header`], [`true`，语言栏；显式传入标题时仍显示标题栏],
  [`code-line-numbers`], [`false`，全局行号开关],
  [`code-tab-size`], [`4`，制表符宽度],
  [`code-theme`], [`auto` 跟随项目主题，`none` 关闭高亮],
)

行内代码跟随同一套颜色，字号与正文一致，可用 `code-inline-size` 单独调整。语法高亮与语言支持基于 Typst 的 `raw` 接口，没有额外的 Python、Julia 或 MATLAB 排版依赖。

= 参考文献与链接

#epigraph(author: [孔子], source: [《论语·述而》])[
  述而不作，信而好古。
]
#cite(<analects>, form: none)

正文里默认使用数字引用，点击编号即可跳到文末条目。参考文献独立成页，用较小字号、悬挂编号与舒展的行距，并以不编号的标题进入目录。外部网址和 DOI 使用强调色的细下划线；目录、定理与文献的内部跳转不加下划线。

== 引用与文献表

```typst
进一步阅读可参见 @axler2024。
关于内积空间，参见 #cite(<axler2024>, supplement: [第 6 章])。
多篇文献可以连续引用：@axler2024 @strang2010。

// 文末只放一次，不必另写“= 参考文献”。
#bibliography("references.bib")
```

本手册末尾已经调用文献表。正文中的引用 key 必须与 `.bib` 中的条目对应，也不要与定理等对象的标签重名。

默认只列出实际引用的条目。想列出整个资料库，用 `#bibliography("references.bib", full: true)`；想把某一条收进文献表却不在正文显示编号，用 `#cite(<analects>, form: none)`——本页的题辞来源就是这样处理的。

== 添加条目

沿用下面的结构即可，也可以从文献管理软件导出 BibLaTeX 的 `.bib` 文件：

```bibtex
@book{axler2024,
  author = {Axler, Sheldon},
  title = {Linear Algebra Done Right},
  edition = {4},
  publisher = {Springer},
  date = {2024},
  doi = {10.1007/978-3-031-41026-0},
  url = {https://linear.axler.net/}
}
```

`doi` 填标识符，`url` 填完整网址；在线资料可以加 `urldate = {2026-09-06}` 记录你实际访问的日期。显示哪些字段由所选引用格式决定，例如存在 DOI 时可能就不再显示 URL。模板不会改写作者、排序或编号规则。

示例中的 @axler2024 元数据取自 #link("https://link.springer.com/book/10.1007/978-3-031-41026-0")[Springer 书籍页]，@strang2010 取自 #link("https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/")[MIT OpenCourseWare]。请把示例资料替换或补充为自己实际使用的来源。

== 超链接

普通链接直接使用 Typst 原生语法，推荐给长网址起个易读的名字：

```typst
#link("https://linear.axler.net/")[教材主页]
#link("https://doi.org/10.1007/978-3-031-41026-0")[电子版 DOI]
```

例如 #link("https://linear.axler.net/")[教材主页] 与 #link("https://doi.org/10.1007/978-3-031-41026-0")[电子版 DOI]，两者都只在文外侧留出一条细线。

== 相关配置

#table(
  columns: (1.35fr, 2.45fr),
  table.header([配置项 / Key], [默认值与用途 / Default and purpose]),
  [`bibliography-style`], [`"ieee"`，数字编号；也可用 `"apa"` 或 `"gb-7714-2015-numeric"`],
  [`bibliography-title`], [`auto`，按 `lang` 生成；也可传 `[主要参考资料]`],
  [`bibliography-new-page`], [`true`，参考文献另起一页；短笔记可设为 `false`],
  [`bibliography-size`], [`9.5pt`，文献条目字号],
  [`bibliography-spacing`], [`1.1em`，条目之间的间距],
  [`link-color`, `citation-color`], [`auto`，跟随强调色；也可分别指定],
  [`link-underline`], [`true`，只给外部链接加细下划线],
)

切换引用格式后，文内引用与文末文献会一起更新。作者年份格式还可以用 `#cite(<axler2024>, form: "prose")` 生成叙述式引用。多文件项目中的 `.bib` 路径相对于调用 `bibliography` 的文件。

= 示例：分析与代数

#epigraph(author: [荀子], source: [《荀子·劝学》])[
  不积跬步，无以至千里；不积小流，无以成江海。
]

前面八章讲的是模板的用法，本章是一份完整的示例笔记：题辞、九种环境、表格、三种语言的代码与参考文献都在里面出现了一遍。开始写自己的内容时，可以把这一章留作骨架，前面的说明删掉即可。

== 极限与连续

#epigraph(author: [孔子], source: [《论语·为政》])[
  学而不思则罔，思而不学则殆。
]
#cite(<analects>, form: none)

数学分析的起点，是把“无限接近”转化为可以检验的语言。本节从数列极限出发，记录定义、直觉与证明之间的联系。

_The art of analysis begins with making approximation precise._

=== 数列的收敛

#(env.definition)(title: [数列极限 / Limit of a sequence])[
  设 $(a_n)$ 为实数列。若存在 $L in RR$，使得对任意 $epsilon > 0$，
  都存在 $N in NN$，当 $n >= N$ 时有 $abs(a_n - L) < epsilon$，
  则称 $(a_n)$ 收敛于 $L$，记作 $a_n -> L$。
] <def-limit>

量词的先后顺序是定义的核心：$N$ 可以依赖 $epsilon$，但不应依赖后续选取的 $n$。

#(env.theorem)(title: [极限的唯一性 / Uniqueness])[
  若实数列 $(a_n)$ 收敛，则它的极限唯一。
] <thm-unique>

#(env.proof)[
  假设 $a_n -> L$ 且 $a_n -> M$，但 $L != M$。
  取 $epsilon = abs(L-M)/3$，由 @def-limit，对充分大的 $n$ 有
  $ abs(L-M) <= abs(L-a_n) + abs(a_n-M) < 2/3 abs(L-M). $ <eq-unique>
  这与 $abs(L-M) > 0$ 矛盾，故 $L=M$。
]

=== 从定义到估计

#(env.example)(title: [$1/n -> 0$])[
  给定 $epsilon > 0$，取整数 $N > 1/epsilon$。对任意 $n >= N$，
  有 $abs(1/n - 0) <= 1/N < epsilon$，因此极限为 $0$。
]

#(env.remark)[
  证明中的关键是先写出目标不等式，再反推 $N$ 的选择。
  式 @eq-unique 则展示了三角不等式如何把两个局部估计连接起来。
]

== 内积与正交

#epigraph(
  author: [Isaac Newton], source: [Letter to Robert Hooke, 1676],
  italic: true,
  translation: [如果我看得更远，那是因为我站在巨人的肩上。（译文）],
)[If I have seen further it is by standing on the sholders of Giants.]

内积使向量空间具有长度与角度。投影把抽象的几何直觉转化为可计算的表达式。进一步阅读可参见 Axler 的教材 @axler2024 和 Strang 的课程 @strang2010。

=== 内积空间

#(env.definition)(title: [实内积 / Real inner product])[
  实向量空间 $V$ 上的内积 $ip(x,y)$ 是一个对称双线性型，
  且满足 $ip(x,x) >= 0$，等号当且仅当 $x=0$。
  由此定义范数 $norm(x) = sqrt(ip(x,x))$。
]

#(env.theorem)(title: [Cauchy–Schwarz 不等式])[
  对任意 $x,y in V$，有
  $ abs(ip(x,y)) <= norm(x) norm(y). $ <eq-cs>
  等号成立当且仅当 $x,y$ 线性相关。
] <thm-cs>

#(env.proof)[
  当 $y=0$ 时显然成立。若 $y != 0$，对任意 $t in RR$，
  $ 0 <= norm(x-t y)^2
      = norm(x)^2 - 2t ip(x,y) + t^2 norm(y)^2. $
  取 $t = ip(x,y) / norm(y)^2$，整理即得 @eq-cs。
  等号成立恰好对应 $x=t y$。
]

=== 正交投影

若 $u_1, dots, u_k$ 是子空间 $W$ 的一组标准正交基，则
$ op("proj")_W(x) = sum_(i=1)^k ip(x,u_i) u_i. $ <eq-proj>

#(env.corollary)(title: [最佳逼近 / Best approximation])[
  令 $p = op("proj")_W(x)$，则对任意 $w in W$，
  $ norm(x-w)^2 = norm(x-p)^2 + norm(p-w)^2 >= norm(x-p)^2. $
]

#(env.remark)[
  @thm-cs 控制内积的大小；@thm-unique 则控制极限的歧义。
  自动引用会保留对象名称与编号，点击即可跳转。
]

== 计算、练习与回顾

=== 二项式与上升阶乘

对于正整数 $j,k$，二项式系数可以写成
$ binom(k+j-1, k) = frac(j(j+1)(j+2) dots.h.c (j+k-1), k!). $

固定 $k$ 后，它是关于 $j$ 的 $k$ 次多项式。例如
$ binom(j+2, 3) &= (j(j+1)(j+2))/6 \
                  &= j^3/6 + j^2/2 + j/3. $

#(env.lemma)(title: [首项系数])[
  多项式 $j(j+1) dots.h.c (j+k-1)$ 是首一多项式，
  因此 $binom(k+j-1,k)$ 关于 $j$ 的首项系数为 $1/k!$。
]

=== 矩阵与分段函数

公式使用独立的数学字体，矩阵、黑板粗体与积分符号保持一致。
$ A = mat(2, 1; 1, 2), quad
  f(x) = cases(x^2 & "if " x >= 0, -x & "if " x < 0). $

#(env.exercise)(title: [从计算到解释])[
  + 求矩阵 $A$ 的特征值与一组标准正交特征向量。
  + 用 @eq-proj 将 $(1,0)$ 投影到 $W = op("span")((1,1))$。
  + 直接从定义证明：若 $a_n -> a$、$b_n -> b$，则 $a_n+b_n -> a+b$。
]

=== 一页回顾

#table(
  columns: (1.05fr, 1.7fr, 1.25fr),
  table.header([概念 / Concept], [关键表达 / Key idea], [方法 / Method]),
  [极限], [$forall epsilon > 0, exists N$], [控制误差],
  [内积], [$abs(ip(x,y)) <= norm(x) norm(y)$], [二次型非负],
  [投影], [$x-p perp W$], [正交分解],
)

#(env.remark)(title: [下一步 / Next steps])[
  每次记录一个定义、一条核心结论，以及一个能暴露误解的反例。
  留下问题，往往比抄下答案更有价值。
  也可从 #link("https://linear.axler.net/")[作者提供的教材主页]继续阅读。
]

== 数值实验

用三种语言计算同一个正交投影：令 $x=(1,0)$、$u=(1,1)$，
则 $p = (x dot u)/(u dot u) u = (1/2,1/2)$。计算是检验直觉的一种方式。

=== Python

```python
import numpy as np

# Project x onto the span of u
x = np.array([1.0, 0.0])
u = np.array([1.0, 1.0])
p = (x @ u) / (u @ u) * u
assert np.allclose(p, [0.5, 0.5])
print("projection:", p)
```

=== Julia

#(env.code)(title: [projection.jl], numbers: true)[
```julia
using LinearAlgebra

# 向量在一维子空间上的投影
x = [1.0, 0.0]
u = [1.0, 1.0]
p = dot(x, u) / dot(u, u) * u
@assert p ≈ [0.5, 0.5]
println("projection: ", p)
```
]

=== MATLAB

```matlab
% Project a column vector
x = [1; 0];
u = [1; 1];
p = (u' * x) / (u' * u) * u;
assert(norm(p - [0.5; 0.5]) < 1e-12);
disp('projection:');
disp(p);
```

三种写法都对应 @eq-proj；用 `assert` 检查结果，用 `p` 保存投影向量。

#appendix([图片与题注])[

本章本身就是用 `env.appendix` 起的附录：编号改用 A、B、C，标识行写「附录 / APPENDIX」，小节编号为 A.1。补充材料另起一章写在文末即可。

图片用 Typst 原生的 `figure` 插入，编号与题注交给模板：

```typst
#figure(image("assets/plot_1.png", width: 74%),
  caption: [概率随 $n$ 的变化 / Probability versus $n$]) <fig-probability>
```

路径相对于当前 `.typ` 文件，`assets/` 是模板自带的资源目录。排出来是这样：

#figure(
  image("assets/plot_1.png", width: 74%),
  caption: [概率随 $n$ 的变化 / Probability versus $n$],
) <fig-probability>

题注居中排在图片下方：编号用强调色加粗，正文用小号灰色字，与定理环境的标题共用同一套字体。图片与题注作为整体分页；省略 `caption` 就只留图片，也不占编号；写 @fig-probability 即可引用。表格套进 `figure` 会得到表题与独立的表编号。

== 相关配置

#table(
  columns: (1.35fr, 2.45fr),
  table.header([配置项 / Key], [默认值与用途 / Default and purpose]),
  [`appendix-numbering`], [`"A.1"`，附录章的编号格式；`"A"` 则只给章编号],
  [`figure-caption-size`], [`9pt`，图片与表格的题注字号],
  [`figure-caption-color`], [`auto`，跟随 `muted`；也可直接指定颜色],
)

]

#appendix([更新日志])[

澄思各版本的变更记录，按发布时间倒序排列。版本号与包管理器上的 `@preview/chengsi` 一致。

== 0.1.2

- 新增 `appendix` 附录环境：附录改用 A、B、C 独立编号，由 `appendix-numbering` 控制；章标识行写「附录 / APPENDIX」，且不影响其后正文章节的编号。
- 统一图片与表格的题注版式：图居中，编号用强调色，正文为小号灰色字排在下方，通过 `figure-caption-size` 与 `figure-caption-color` 配置。中英双语文档里引用显示为「图 / Figure 1」「表 / Table 1」，且图与题注不会被分页拆开。
- 扩充随包模板：新增「图片与题注」附录、`template/assets/` 中的示例插图，以及新配置项的相关说明。
- 行内代码改用正文字号（原先固定 `0.85em`），不再比周围文字显小；新增 `code-inline-size` 选项（默认 `1em`）可按项目调整。

== 0.1.1

- 例题改用独立计数器，编号格式由 `example-numbering` 配置；其余类定理环境继续共用 `theorem-numbering`。
- 新增可配置项：段间距、标题前后的间距，以及章节标识、章／节／小节标题的字号。
- 调大了默认的段落与标题间距、章标识字号，并同步更新随包模板的配置：留白更宽松、标题更大。
- 代码块语言标签新增 Mathematica 与 Wolfram Language。

== 0.1.0

澄思（Chengsi）的第一个正式版本。

- 中文、英文与中英双语的数学环境。
- 封面、目录、章首题辞、交叉引用与参考文献。
- 青绿、靛蓝、暖赭棕三套配色，配套的语法高亮主题。
- 完整示例：分析、线性代数与数值实验。

]

#bibliography("references.bib")
