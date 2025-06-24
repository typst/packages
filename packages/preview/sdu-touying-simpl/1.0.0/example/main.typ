// #import "@preview/sdu-touying-simpl:1.0.0" :*
#import "../lib.typ" :*
// https://typst.app/universe/package/timeliney
#import "@preview/timeliney:0.3.0"

// https://typst.app/universe/package/codly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#codly(languages: codly-languages)
//https://typst.app/universe/package/fletcher
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge

//https://typst.app/universe/package/ctheorems
// 数学定理相关
#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$) // 设置定理结束符号
#let cdefinition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em))

#let cexample = thmplain("example", "Example").with(numbering: none)
#let cproof = thmproof("proof", "Proof")

#let ctheorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)
//https://typst.app/universe/package/showybox
#import "@preview/showybox:2.0.4": showybox

// https://typst.app/universe/package/gentle-clues
#import "@preview/gentle-clues:1.2.0": *

#set text(font: (
  (
    name: "Inria Serif",
    covers: "latin-in-cjk",
  ),
  "Noto Serif CJK SC"
))
// #set text(font: "Source Han Serif", lang: "CN",region: "CN")
#show: sdu-theme.with(
  aspect-ratio: "16-9",
   config-info(
    title: [Typst template for Shandong University],
    subtitle: [Continuously Improving...],
    author: [孙更欣],
    date: datetime.today(),
    institution: [计算机科学与技术学院],
    logo:sdu-logo
  ),
  footer-line-color: sdu-red,
)
#set heading(numbering: "1.1")
#show heading.where(level: 1): set heading(numbering: "1.")
#title-slide()
#outline-slide([Outline])
#let typst-color = rgb("#239DAD")

#let Typst = text(fill: typst-color, weight: "bold", "Typst")

#let Touying = text(fill: rgb("#425066"), weight: "bold", "Touying")

#let Markdown = text(fill: rgb(purple), weight: "bold", "Markdown")


#let TeX = {
  set text(font: "New Computer Modern", weight: "regular")
  box(width: 1.7em, {
    [T]
    place(top, dx: 0.56em, dy: 0.22em)[E]
    place(top, dx: 1.1em)[X]
  })
}

#let LaTeX = {
  set text(font: "New Computer Modern", weight: "regular")
  box(width: 2.55em, {
    [L]
    place(top, dx: 0.3em, text(size: 0.7em)[A])
    place(top, dx: 0.7em)[#TeX]
  })
}


// Functions

#let linkto(url, icon: "link") = link(url, box(baseline: 30%, move(dy: -.15em, octique-inline(icon))))

#let keydown(key) = box(stroke: 2pt, inset: .2em, radius: .2em, baseline: .2em, key)
= 介绍

== 什么是 Typst？

- *介绍：*
  - #Typst 是为写作而诞生的基于标记的排版系统。#Typst 的目标是成为功能强大的排版工具，并且让用户可以愉快地使用它。#pause

- *简单来说：*
  - #Typst = #LaTeX 的排版能力 + #Markdown 的简洁语法 + 强大且现代的脚本语言 #pause

- *运行环境：*Web Wasm / CLI / LSP Language Server

- *编辑器：*Web App #linkto("https://typst.app/") / VS Code / Neovim / Emacs
== Typst 速览

#slide[
  #set text(.5em)

  ```typ
  #set page(width: 10cm, height: auto)
  #set heading(numbering: "1.")

  = Fibonacci sequence
  The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$.
  It can also be expressed in _closed form:_

  $ F_n = round(1 / sqrt(5) phi.alt^n)，quad phi.alt = (1 + sqrt(5)) / 2 $

  #let count = 8
  #let nums = range(1, count + 1)
  #let fib(n) = (
    if n <= 2 { 1 }
    else { fib(n - 1) + fib(n - 2) }
  )

  The first #count numbers of the sequence are:

  #align(center, table(
    columns: count,
    ..nums.map(n => $F_#n$),
    ..nums.map(n => str(fib(n))),
  ))
  ```

  来源：Typst 官方 Repo #linkto("https://github.com/typst/typst")
][
  #set align(center + horizon)

  #image("figures/fibonacci.png", height: 100%)
]

== Typst 优势

- *语法简洁：*上手难度跟 #Markdown 相当，文本源码可阅读性高。#pause

- *编译速度快：*
  - Typst 使用 Rust 语言编写，即 `typ(esetting+ru)st`。
  - 增量编译时间一般维持在*数毫秒*到*数十毫秒*。#pause

- *环境搭建简单：*不像 #LaTeX 安装起来困难重重，#Typst 原生支持中日韩等非拉丁语言，官方 Web App 和本地 VS Code 均能*开箱即用*。#pause

- *现代脚本语言：*
  - 变量、函数、闭包与错误检查 + 函数式编程的纯函数理念
  - 可嵌套的 `[标记模式]`、`{脚本模式}` 与 `$数学模式$` #strike[不就是 JSX 嘛]
  - 统一的包管理，支持导入 WASM 插件和按需自动安装第三方包

== Typst 对比其他排版系统

#slide[
  #set text(.7em)
  #let 难 = text(fill: rgb("#aa0000"), weight: "bold", "难")
  #let 易 = text(fill: rgb("#007700"), weight: "bold", "易")
  #let 多 = text(fill: rgb("#aa0000"), weight: "bold", "多")
  #let 少 = text(fill: rgb("#007700"), weight: "bold", "少")
  #let 慢 = text(fill: rgb("#aa0000"), weight: "bold", "慢")
  #let 快 = text(fill: rgb("#007700"), weight: "bold", "快")
  #let 弱 = text(fill: rgb("#aa0000"), weight: "bold", "弱")
  #let 强 = text(fill: rgb("#007700"), weight: "bold", "强")
  #let 较强 = text(fill: rgb("#007700"), weight: "bold", "较强")
  #let 中 = text(fill: blue, weight: "bold", "中等")
  #let cell(top, bottom) = stack(spacing: .2em, top, block(height: 2em, text(size: .7em, bottom)))

  #v(1em)
  #figure(
    table(
      columns: 8,
      stroke: none,
      align: center + horizon,
      inset: .5em,
      table.hline(stroke: 2pt),
      [排版系统], [安装难度], [语法难度], [编译速度], [排版能力], [模板能力], [编程能力], [方言数量],
      table.hline(stroke: 1pt),
      [LaTeX], cell[#难][选项多 + 体积大 + 流程复杂], cell[#难][语法繁琐 + 嵌套多 + 难调试], cell[#慢][宏语言编译\ 速度极慢], cell[#强][拥有最多的\ 历史积累], cell[#强][拥有众多的\ 模板和开发者], cell[#中][图灵完备\ 但只是宏语言], cell[#中][众多格式、\ 引擎和发行版],
      [#Markdown], cell[#易][大多编辑器\ 默认支持], cell[#易][入门语法十分简单], cell[#快][语法简单\ 编译速度较快], cell[#弱][基于 HTML排版能力弱], cell[#中][语法简单\ 易于更换模板], cell[#弱][图灵不完备 \ 需要外部脚本], cell[#多][方言众多\ 且难以统一],
      [Word], cell[#易][默认已安装], cell[#易][所见即所得], cell[#中][能实时编辑\ 大文件会卡顿], cell[#强][大公司开发\ 通用排版软件], cell[#弱][二进制格式\ 难以自动化], cell[#弱][编程能力极弱], cell[#少][统一的标准和文件格式],
      [#Typst], cell[#易][安装简单\ 开箱即用], cell[#中][入门语法简单\ 进阶使用略难], cell[#快][增量编译渲染\ 速度最快], cell[#较强][已满足日常\ 排版需求], cell[#强][制作和使用\ 模板都较简单], cell[#强][图灵完备\ 现代编程语言], cell[#少][统一的语法\ 统一的编译器],
      table.hline(stroke: 2pt),
    ),
  )
]

#slide[
  #set align(center + horizon)
  #v(-1.5em)
  #image("figures/meme.png", height: 80%)
  #v(-1.5em)
  From reddit r/LaTeX #linkto("https://www.reddit.com/r/LaTeX/comments/z2ifki/latex_vs_word_vs_pandoc_markdown/") and modfied by OrangeX4
]

= 安装

== 云端使用

- 官方提供了 Web App，可以直接在浏览器中使用 #linkto("https://typst.app/") #pause

- *优点：*
  - 即开即用，无需安装。
  - 类似于 #LaTeX 的 Overleaf，可以直接编辑、编译、分享文档。
  - 拥有*「多人协作」*支持，可以实时共同编辑。#pause

- *缺点：*
  - 中文字体较少，经常需要手动上传字体文件，但有上传大小限制。
  - 缺少版本控制，目前无法与 GitHub 等代码托管平台对接。


== 本地使用（推荐）

- *VS Code 方案（推荐）*
  - 在插件市场安装「Tinymist Typst」插件。
  - 新建一个 `.typ` 文件，然后按下 #keydown[Ctrl] + #keydown[K] #keydown[V] 即可实时预览。
  - *不再需要其他配置*，例如我们并不需要命令行安装 Typst CLI。#pause

- *Neovim / Emacs 方案*
  - 可以配置相应的 LSP 插件和 Preview 插件。#pause

- *CLI 方案：* `typst compile --root <DIR> <INPUT_FILE>`
  - Windows: `winget install --id Typst.Typst`
  - macOS: `brew install typst`
  - Linux：查看 Typst on Repology #linkto("https://repology.org/project/typst/versions")

= 快速入门

== Hello World

#slide[
  #set text(.5em)

  ````typ
  #set page(width: 20em, height: auto)
  #show heading.where(level: 1): set align(center)

  #show "Typst": set text(fill: blue, weight: "bold")
  #show "LaTeX": set text(fill: red, weight: "bold")
  #show "Markdown": set text(fill: purple, weight: "bold")

  = Typst 讲座

  Typst 是为 *学术写作* 而生的基于 _标记_ 的排版系统。

  Typst = LaTeX 的排版能力 + Markdown 的简洁语法 + 现代的脚本语言

  #underline[本讲座]包括以下内容：

  + 快速入门 Typst
  + Typst 编写各类模板
    - 笔记、论文、简历和 Slides
  + Typst 高级特性
    - 脚本、样式和包管理
  + Typst 周边生态开发体验
    - Pinit、MiTeX、Touying 和 VS Code 插件

  ```py
  print('Hello Typst!')
  ```
  ````
][
  #set align(center + horizon)
  #v(-1em)
  #image("figures/poster.png", height: 95%)
]


== 标记只是语法糖

#slide[
  ````typ
  = 一级标题

  == 二级标题

  简单的段落，可以*加粗*和_强调_。

  - 无序列表
  + 有序列表
  / 术语: 术语列表

  ```py
  print('Hello Typst!')
  ```
  ````
][
  ````typ
  #heading(level: 1, [一级标题])

  #heading(level: 2, [二级标题])

  简单的段落，可以#strong[加粗]和#emph[强调]。

  #list.item[无序列表]
  #enum.item[有序列表]
  #terms.item[术语][术语列表]

  #raw(lang: "py", block: true, "print('Hello Typst!')")
  ````
]

== 核心概念

- *Simplicity through Consistency*
  - 类似 #Markdown 的特殊标记语法，实现*「内容与格式分离」*。
  - `= 一级标题` 只是 `#heading[一级标题]` 的*语法糖*。#pause
- *标记模式和脚本模式*
  - 标记模式下，使用井号 `#` 进入脚本模式，如 `#strong[加粗]`。
    - 脚本模式下不需要额外井号，例如 `#heading(strong([加粗]))`
    - 大段脚本代码可以使用花括号 `{}`，例如 `#{1 + 1}`。#pause
  - 脚本模式下，使用方括号 `[]` 进入标记模式，称为*内容块*。
    - #Typst 是强类型语言，有常见的数据类型，如 `int` 和 `str`。
    - 内容块 `[]` 类型 `content` 是 #Typst 的核心类型，可嵌套使用。
    - `#fn(..)[XXX][YYY]` 是 `#fn(.., [XXX], [YYY])` 的*语法糖*。


== Set/Show Rules

- *Set 规则可以设置样式，即「为函数设置参数默认值」的能力。*
  - 例如 `#set heading(numbering: "1.")` 用于设置标题的编号。
  - 使得 `#heading[标题]` 变为 `#heading(numbering: "1.", [标题])`。#pause

- *Show 规则用于全局替换，即在语法树上进行「宏编程」的能力。*
  - 例如 `#show "LaTeX": "Typst"` 将单词 `LaTeX` 替换为 `Typst`。
  - 例如让一级标题居中，可以用*「箭头函数」*：
    - #block(
        width: 100%,
        fill: luma(240),
        inset: (x: .3em, y: 0em),
        outset: (x: 0em, y: .3em),
        radius: .2em,
        ```typ
        #show heading.where(level: 1): body => {
          set align(center)
          body
        }
        ```,
      )
    - 化简为 `#show heading.where(level: 1): set align(center)`


== 数学公式

- `$x$` 是行内公式，`$ x^2 + y^2 = 1 $ <circle>` 是行间公式。#pause

- 与 #LaTeX 的差异：
  - `(x + 1) / x >= 1 => 1/x >= 0`
  - #raw(lang: "latex", `\frac{x + 1}{x} \ge 1 \Rightarrow \frac{1}{x} \ge 0`.text) #pause

- *报告，我想用 LaTeX 语法：*#linkto("https://github.com/mitex-rs/mitex")

```typ
#import "@preview/mitex:0.2.2": *

Write inline equations like #mi("x") or #mi[y].
#mitex(`
  \frac{x + 1}{x} \ge 1 \Rightarrow \frac{1}{x} \ge 0
`)
```
== Touying 对比其他 Slides 方案

#slide[
  #set text(.7em)
  #let 难 = text(fill: rgb("#aa0000"), weight: "bold", "难")
  #let 易 = text(fill: rgb("#007700"), weight: "bold", "易")
  #let 慢 = text(fill: rgb("#aa0000"), weight: "bold", "慢")
  #let 快 = text(fill: rgb("#007700"), weight: "bold", "快")
  #let 弱 = text(fill: rgb("#aa0000"), weight: "bold", "弱")
  #let 强 = text(fill: rgb("#007700"), weight: "bold", "强")
  #let 中 = text(fill: blue, weight: "bold", "中等")
  #let cell(top, bottom) = stack(spacing: .2em, top, block(height: 2em, text(size: .7em, bottom)))

  #v(1em)
  #figure(
    table(
      columns: 8,
      stroke: none,
      align: center + horizon,
      inset: .5em,
      table.hline(stroke: 2pt),
      [方案], [语法难度], [编译速度], [排版能力], [模板能力], [编程能力], [动画效果], [代码公式],
      table.hline(stroke: 1pt),
      [*PowerPoint*], cell[#易][所见即所得], cell[#快][实时编辑], cell[#强][大公司开发\ 通用软件], cell[#强][模板数量最多\ 容易制作模板], cell[#弱][编程能力极弱\ 难以显示进度], cell[#强][动画效果多\ 但用起来复杂], cell[#难][难以插入代码和公式 #strike[贴图片]],
      [Beamer], cell[#难][语法繁琐 + 嵌套多 + 难调试], cell[#慢][宏语言编译\ 速度极慢], cell[#弱][使用模板后\ 排版难以修改], cell[#中][拥有较多模板\ 开发模板较难], cell[#中][图灵完备\ 但只是宏语言], cell[#中][简单动画方便\ 无过渡动画], cell[#易][基本默认支持],
      [#Markdown], cell[#易][入门语法十分简单], cell[#快][语法简单\ 编译速度较快], cell[#弱][语法限制\ 排版能力弱], cell[#弱][难以制作模板\ 只有内置模板], cell[#弱][图灵不完备\ 需要外部脚本], cell[#中][动画效果全看提供了什么], cell[#易][基本默认支持],
      [#Touying], cell[#易][语法简单\ 使用方便], cell[#快][增量编译渲染\ 速度最快], cell[#中][满足日常学术\ Slides 需求], cell[#强][制作和使用\ 模板都较简单], cell[#强][图灵完备\ 现代编程语言], cell[#中][简单动画方便\ 无过渡动画], cell[#易][默认支持\ MiTeX 包],
      table.hline(stroke: 2pt),
    ),
  )
]

= 部分基础功能展示

注：这里也可以有内容

== 我是谁

我是基于touying制作的非官方Typst模板，用于展示山东大学的学术成果。
== A long long long long long long long long long long long long long long long long long long long long long long long long Title

展示超长标题
== 想分列显示？

#columns(
  3,
  [展示`void fn`
  #colbreak()
  *Second column.第二列*
  #colbreak()
  #sdu-logo
  ],
)

== 模块
#tblock(title:"标题",[内容])
== 列表
#columns(
  2,
  [- 无序列表
  
  - 第二项

  #colbreak()

  + 有序列表1
+ 有序列表2
  ]
)

== 表格
//表格内容设置在main.typ中

#[
  #set align(center+horizon)
  #let a = table.cell(
    fill: green.lighten(60%),
  )[A]
  #let b = table.cell(
    fill: aqua.lighten(60%),
  )[B]



  #table(
    columns: 4,
    [], [Exam 1], [Exam 2], [Exam 3],

    [John], [], a, [],
    [Mary], [], a, a,
    [Robert], b, a, b,
  )
]
== 数学公式
行内公式：$a^2 + b^2 = c^2$
块级公式：

$ E=m c^2\ angle.l a, b angle.r &= arrow(a) dot arrow(b) \
                       &= a_1 b_1 + a_2 b_2 + ... a_n b_n \
                       &= sum_(i=1)^n a_i b_i.  $

== 数学定理
#cdefinition[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
]
#cexample[
  The numbers $2$, $3$, and $17$ are prime.
  @cor_largest_prime shows that this list is not exhaustive!
]

#ctheorem("Euclid")[
  There are infinitely many primes.
]
#cproof[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]
#corollary[
  There is no largest prime number.
] <cor_largest_prime>
#corollary[
  There are infinitely many composite numbers.
]
#ctheorem[
  There are arbitrarily long stretches of composite numbers.
]
#cproof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n #qedhere
  $
]
= 小组件

== 时间轴，很简单

//timeliney: https://typst.app/universe/package/timeliney
#timeliney.timeline(
  show-grid: true,
  {
    import timeliney: *
      
    headerline(group(([*2023*], 4)), group(([*2024*], 4)))
    headerline(
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
      group(..range(4).map(n => strong("Q" + str(n + 1)))),
    )
  
    taskgroup(title: [*Research*], {
      task("Research the market", (0, 2), style: (stroke: 2pt + gray))
      task("Conduct user surveys", (1, 3), style: (stroke: 2pt + gray))
    })

    taskgroup(title: [*Development*], {
      task("Create mock-ups", (2, 3), style: (stroke: 2pt + gray))
      task("Develop application", (3, 5), style: (stroke: 2pt + gray))
      task("QA", (3.5, 6), style: (stroke: 2pt + gray))
    })

    taskgroup(title: [*Marketing*], {
      task("Press demos", (3.5, 7), style: (stroke: 2pt + gray))
      task("Social media advertising", (6, 7.5), style: (stroke: 2pt + gray))
    })

    milestone(
      at: 3.75,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Conference demo*\
        Dec 2023
      ])
    )

    milestone(
      at: 6.5,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *App store launch*\
        Aug 2024
      ])
    )
  }
)

== 代码块，很优雅

#slide[
```typc
pub fn main() {
    println!("Hello, world!");
}
```
][
  //codly: https://typst.app/universe/package/codly
```rust
pub fn main() {
    println!("Hello, world!");
}
```
]

== 用节点和箭头绘制图表

#slide[
  #set text(size: .5em,)

```typc
#diagram(cell-size: 15mm, $
  G edge(f, ->) edge("d", pi, ->>) & im(f) \
  G slash ker(f) edge("ur", tilde(f), "hook-->")
$)
```
][
  #align(center,{
  diagram(cell-size: 15mm, $
    G edge(f, ->) edge("d", pi, ->>) & im(f) \
    G slash ker(f) edge("ur", tilde(f), "hook-->")
  $)
  })
  #footnote[https://typst.app/docs]
]

#slide[
#set text(size: .5em,)

```typc
#import fletcher.shapes: diamond
#set text(font: "Comic Neue", weight: 600)

#diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
  edge("-|>"),
  node((0,1), align(center)[
    Hey, wait,\ this flowchart\ is a trap!
  ], shape: diamond),
  edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1)
)
```
][
  #align(center,{
import fletcher.shapes: diamond
set text(font: "Comic Neue", weight: 600)

diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
  edge("-|>"),
  node((0,1), align(center)[
    Hey, wait,\ this flowchart\ is a trap!
  ], shape: diamond),
  edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1)
)
  })
]

#slide[
  #set text(size: .5em,)

```typc
#set text(10pt)
#diagram(
  node-stroke: .1em,
  node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
  spacing: 4em,
  edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
  node((0,0), `reading`, radius: 2em),
  edge(`read()`, "-|>"),
  node((1,0), `eof`, radius: 2em),
  edge(`close()`, "-|>"),
  node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
  edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),
  edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
)
```
][
  
  #align(center,{
set text(10pt)
diagram(
  node-stroke: .1em,
  node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
  spacing: 4em,
  edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
  node((0,0), `reading`, radius: 2em),
  edge(`read()`, "-|>"),
  node((1,0), `eof`, radius: 2em),
  edge(`close()`, "-|>"),
  node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
  edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),
  edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
)
  })
]

#slide[
  #set text(size: .5em)

```typc
#diagram(cell-size: 15mm, $
  G edge(f, ->) edge("d", pi, ->>) & im(f) \
  G slash ker(f) edge("ur", tilde(f), "hook-->")
$)
```
][
  #align(center,{
  diagram(cell-size: 15mm, $
    G edge(f, ->) edge("d", pi, ->>) & im(f) \
    G slash ker(f) edge("ur", tilde(f), "hook-->")
  $)
  })
]

== 展示框，很有趣

#slide[
  #set text(size: .5em)

```typc
#showybox(
  [Hello world!]
)
```
```typc
showybox(
  frame: (
    dash: "dashed",
    border-color: red.darken(40%)
  ),
  body-style: (
    align: center
  ),
  sep: (
    dash: "dashed"
  ),
  shadow: (
	  offset: (x: 2pt, y: 3pt),
    color: yellow.lighten(70%)
  ),
  [This is an important message!],
  [Be careful outside. There are dangerous bananas!]
)
```

][
  #align(center,{

  showybox(
  [Hello world!]
  )

showybox(
  frame: (
    dash: "dashed",
    border-color: red.darken(40%)
  ),
  body-style: (
    align: center
  ),
  sep: (
    dash: "dashed"
  ),
  shadow: (
	  offset: (x: 2pt, y: 3pt),
    color: yellow.lighten(70%)
  ),
  [This is an important message!],
  [Be careful outside. There are dangerous bananas!]
)

  })
]

== 提示框

#slide[
  #set text(size: .5em)
```typc
#info[ This is the info clue ... ]
#tip(title: "Best tip ever")[Check out this cool package]
```
][
  #align(center,{
info[ This is the info clue ... ]
tip(title: "Best tip ever")[Check out this cool package]
  })
]

== 类obsidian

#info[This is information]

#success[I'm making a note here: huge success]

#warning[First warning...]


#question[Question?]

#example[An example make things interesting]


= 页面

== focus-slide

#focus-slide[
  聚焦页
]

== matrix-slide

#matrix-slide[
  left
][
  middle
][
  right
]

#matrix-slide(columns: 1)[
  top
][
  bottom
]

#matrix-slide(columns: (1fr, 2fr, 1fr), ..(lorem(8),) * 9)

== 引用
引用如下（此处为空）。
#bibliography("bibliography.bib", title: none)
== 致谢<touying:unoutlined>
+ #Typst 官方文档 #linkto("https://typst.app/docs")

+ *#Typst 中文教程* #linkto("https://github.com/typst-doc-cn/tutorial")

+ *Typst 非官方中文交流群* 793548390

+ *OrangeX4 的 Typst 讲座* #linkto("https://github.com/OrangeX4/typst-talk")（几乎占了介绍内容的全部）

+ *Touying 官方文档* #linkto("https://touying-typ.github.io/")

+ *中科大touying-pres-ustc模板* #linkto("https://github.com/Quaternijkon/touying-pres-ustc")

+ *touying-brandred-uobristol* #linkto("https://github.com/HPDell/touying-brandred-uobristol")
#ending-slide[
  #align(center + horizon)[
  #set text(size: 3em, weight: "bold", sdu-red)

  THANKS FOR ALL

  敬请指正！
]
]




