#import "@preview/modern-tongji-thesis:0.2.0": *

#let example-image = "../figures/example-image.svg"

= 浮动体 <float>

在本章（@float）中，我们将介绍浮动体的概念、分类及其在论文中的使用。

浮动的意思是，最终排版的图形位置不一定与源文件中的位置对应，这也是新手在使用 #LaTeX 和Typst时可能会遇到的问题。
浮动体的正确使用可以提高论文的可读性和美观程度，但也需要注意不要过度使用或使其影响正文的连贯性。

在Typst中，浮动体以 #raw("#figure()", lang: "typ") 的形式实现。不同类型的浮动体都是在此基础上进行扩展的。#raw("#figure()", lang: "typ") 的基础语法如@lst:floatcode
所示。

#figure(
  ```typ
                      #figure(
                        <content>,
                        <placement>,
                        <caption>,
                        <kind>,
                        <supplement>,
                      )
                      ```, caption: [Typst的#raw("#figure()", lang: "typ") 参数列表], placement: none, kind: raw,
) <lst:floatcode>

其中，`content` 是浮动体的具体内容，如图片、表格、代码等；`placement` 是浮动体的位置：`none` 表示不浮动，`auto`
表示自动浮动，`top` 表示浮动到页面顶部，`bottom` 表示浮动到页面底部；`caption` 是浮动体的标题；`kind`
是浮动体的类型，用于计数和索引；`supplement` 是浮动体的类型的中文名称。

== 浮动体的分类 <floats-class>

浮动体包括图片、表格和代码等，它们的共同特点是可以自由浮动在页面中，不会影响正文的排版。

=== 插图

插图是论文中最常见的浮动体，它可以是矢量图（SVG）或位图（PNG、JPG、GIF等）。在Typst中，插图以 #raw("#image()", lang: "typ") 的形式实现，这个函数最重要的参数是
`path`，它指定了插图的源文件路径；具体的文档参见#link("https://typst.app/docs/reference/visualize/image/")[#emph[插图]]。

==== 单个插图

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
  #figure(
    image(example-image, width: 70%),
    caption: [单个插图示例],
  )
  ```, [
  #figure(image(example-image, width: 70%), caption: [单个插图示例])
])

=== 多个插图

要同时展示多个插图，我们可以把一个 #raw("#grid()", lang: "typ") 作为 #raw("#figure()", lang: "typ") 的
`content` 参数，也可以把多个 #raw("#figure()", lang: "typ") 作为 #raw("#grid()", lang: "typ") 的
`content` 参数。前者只能指定一个标题和编号，后者可以为每个插图指定不同的标题和编号。

下面，我们以 $2 times 2$ 的网格为例，展示多个插图的使用方法。

==== 单个标题和编号

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
  #figure(grid(
    columns: 2,
    rows: 2,
    gutter: 5pt,
    image(example-image),
    image(example-image),
    image(example-image),
    image(example-image),
  ), caption: [多个插图示例1]) <fig:multifigure1>
  ```, [
    #figure(
      grid(
        columns: 2, rows: 2, gutter: 5pt, image(example-image), image(example-image), image(example-image), image(example-image),
      ), caption: [多个插图示例1],
    ) <fig:multifigure1>
  ],
)

===== 多个标题和编号

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
  #figure(grid(
    columns: 2,
    rows: 2,
    gutter: 5pt,
    [#figure(image(example-image), caption: [示例2]) <fig:multifigure2>],
    [#figure(image(example-image), caption: [示例3]) <fig:multifigure3>],
    [#figure(image(example-image), caption: [示例4]) <fig:multifigure4>],
    [#figure(image(example-image), caption: [示例5]) <fig:multifigure5>],
  ))
  ```, [
    #figure(
      grid(
        columns: 2, rows: 2, gutter: 5pt, [#figure(image(example-image), caption: [示例2]) <fig:multifigure2>], [#figure(image(example-image), caption: [示例3]) <fig:multifigure3>], [#figure(image(example-image), caption: [示例4]) <fig:multifigure4>], [#figure(image(example-image), caption: [示例5]) <fig:multifigure5>],
      ),
    )
  ],
)

==== 子图

当需要为共用一个编号的多个子图添加（a）（b）等子标题时，使用 `imagex()` 和 `subfig()`：

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
  #imagex(
    subfig(image(example-image, width: 80%), caption: [左侧视图], lbl-name: "left"),
    subfig(image(example-image, width: 80%), caption: [右侧视图], lbl-name: "right"),
    columns: (1fr, 1fr),
    caption: [多子图示例],
  ) <fig:subfig>
  引用：见@fig:subfig:left 和@fig:subfig:right。
  ```, [
    #imagex(
      subfig(image(example-image, width: 80%), caption: [左侧视图], lbl-name: "left"),
      subfig(image(example-image, width: 80%), caption: [右侧视图], lbl-name: "right"),
      columns: (1fr, 1fr),
      caption: [多子图示例],
    ) <fig:subfig>
  ],
)

=== 跨页续表

本模板提供 `continued-table()` 函数，支持自动\u201c续表 X\u201d标记和三线表样式：

```typ
#continued-table(
  header: (
    [*测试程序*], [*运行时间 (s)*], [*同步时间 (s)*], [*检查点时间 (s)*],
  ),
  columns: 4,
  caption: [跨页续表示例],
  [CG.C.2], [23.05], [0.002], [0.116#table-note("模拟数据")],
  ... // 更多行
)
```

下面是一个跨页续表实例：

#continued-table(
  header: (
    [*测试程序*], [*运行时间 (s)*], [*同步时间 (s)*], [*检查点时间 (s)*],
  ),
  columns: 4,
  caption: [跨页续表示例],
  [CG.C.2], [23.05], [0.002], [0.116#table-note("模拟数据")],
  [CG.A.4], [15.06], [0.003], [0.067],
  [CG.A.8], [13.38], [0.004], [0.072],
  [MG.A.2], [9.72], [0.002], [0.015],
  [MG.B.4], [31.44], [0.003], [0.009],
  [MG.C.8], [41.20], [0.001], [0.055],
  [EP.C.2], [495.49], [0.001], [0.009],
  [EP.C.4], [397.69], [0.002], [0.015],
  [EP.C.8], [196.74], [0.003], [0.018],
  [1], [3.14], [0.002], [],   [2], [6.28], [0.002], [],
  [3], [9.42], [0.003], [],   [4], [12.56], [0.001], [],
  [5], [15.70], [0.004], [],  [6], [18.84], [0.002], [],
  [7], [21.98], [0.003], [],  [8], [25.12], [0.001], [],
  [9], [28.26], [0.002], [],  [10], [31.40], [0.003], [],
)

=== 表格

表格是论文中常见的浮动体，它可以是简单的表格，也可以是复杂的表格。编排表格时应简单明了、表达一致，内容明晰易懂，表文呼应，内容一致。在Typst中，表格以 #raw("#table()", lang: "typ") 的形式实现。同样地，我们需要把 #raw("#table()", lang: "typ") 作为 #raw("#figure()", lang: "typ") 的
`content` 参数。

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
    #figure(
        table(
          columns: 4,
          stroke: none,
          toprule(), midrule(),
          [*_t_*], [1], [2], [3],
          midrule(),
          [*_y_*], [0.3s], [0.4s], [0.8s],
          bottomrule(),
        ),
        caption: [计时结果],
    ) <tbl:table1>
      ```, [
    #figure(
      table(
        columns: 4,
        stroke: none,
        toprule(), midrule(),
        [*_t_*], [1], [2], [3],
        midrule(),
        [*_y_*], [0.3s], [0.4s], [0.8s],
        bottomrule(),
      ), caption: [计时结果],
    ) <tbl:table1>
  ],
)

Typst 内置 `table` 已支持三线表所需的所有功能（`table.hline`、`table.cell` 的 `colspan`/`rowspan`、`stroke: none` 等）。本模板已集成三线表辅助命令 `toprule`、`midrule`、`bottomrule` 和 `cmidrule`：

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
  #figure(
    table(
      columns: 3,
      stroke: none,
      align: center + horizon,

      toprule(),
      table.cell(colspan: 2)[*Item*], [],  table.cell(rowspan: 2)[*Price* (\$)],
      cmidrule(start: 0, end: 2, ),
      [*Animal*], [*Description*], [],
      midrule(),
      table.cell(rowspan: 2)[Gnat], [per gram], table.cell(align: right)[13.65],
      [], [each], table.cell(align: right)[0.01],
      [Gnu], [stuffed], table.cell(align: right)[92.50],
      [Emu], [stuffed], table.cell(align: right)[33.33],
      [Armadillo], [frozen], table.cell(align: right)[8.99],
      bottomrule(),
    ),
    caption: [三线表示例],
    kind: table,
  )
  ```, [
    #figure(
      table(
        columns: 3,
        stroke: none,
        align: center + horizon,

        toprule(),
        table.cell(colspan: 2)[*Item*], [],  table.cell(rowspan: 2)[*Price* (\$)],
        cmidrule(start: 0, end: 2, ),
        [*Animal*], [*Description*], [],
        midrule(),
        table.cell(rowspan: 2)[Gnat], [per gram], table.cell(align: right)[13.65],
        [], [each], table.cell(align: right)[0.01],
        [Gnu], [stuffed], table.cell(align: right)[92.50],
        [Emu], [stuffed], table.cell(align: right)[33.33],
        [Armadillo], [frozen], table.cell(align: right)[8.99],
        bottomrule(),
      ), caption: [三线表示例], kind: table,
    )
  ],
)

关于跨页表格，Typst 0.11 起内置 `table` 已支持 `table.header()` 跨页重复表头。下面是一个跨页表格的完整示例：

```typ
#figure(
  table(
    columns: 4,
    align: center,
    stroke: none,
    inset: 8pt,
    table.header(
      toprule(),
      [*项目*], [*值*], [*单位*], [*备注*],
      midrule(),
    ),
    [Alpha], [23.05], [ms], [],
    [Beta], [15.06], [ms], [注1],
    ...range(1, 40).map(i => ([#i], [#i * 3.14], [ms], [])),
    midrule(),
    bottomrule(),
  ),
  kind: table,
  caption: [跨页表格（表头重复）],
)
```

下面是一个跨页表格的实际渲染效果：

#figure(
  table(
    columns: 4,
    align: center,
    stroke: none,
    inset: 8pt,
    table.header(
      toprule(),
      [*测试程序*], [*运行时间 (s)*], [*同步时间 (s)*], [*检查点时间 (s)*],
      midrule(),
    ),
    [CG.C.2], [23.05], [0.002], [0.116],
    [CG.A.4], [15.06], [0.003], [0.067],
    [CG.A.8], [13.38], [0.004], [0.072],
    [MG.A.2], [9.72], [0.002], [0.015],
    [MG.B.4], [31.44], [0.003], [0.009],
    [MG.C.8], [41.20], [0.001], [0.055],
    [EP.C.2], [495.49], [0.001], [0.009],
    [EP.C.4], [397.69], [0.002], [0.015],
    [EP.C.8], [196.74], [0.003], [0.018],
    [1], [3.14], [ms], [],   [2], [6.28], [ms], [],   [3], [9.42], [ms], [],
    [4], [12.56], [ms], [],  [5], [15.70], [ms], [],  [6], [18.84], [ms], [],
    [7], [21.98], [ms], [],  [8], [25.12], [ms], [],  [9], [28.26], [ms], [],
    [10], [31.40], [ms], [], [11], [34.54], [ms], [], [12], [37.68], [ms], [],
    [13], [40.82], [ms], [], [14], [43.96], [ms], [], [15], [47.10], [ms], [],
    [16], [50.24], [ms], [], [17], [53.38], [ms], [], [18], [56.52], [ms], [],
    [19], [59.66], [ms], [], [20], [62.80], [ms], [], [21], [65.94], [ms], [],
    [22], [69.08], [ms], [], [23], [72.22], [ms], [], [24], [75.36], [ms], [],
    [25], [78.50], [ms], [], [26], [81.64], [ms], [], [27], [84.78], [ms], [],
    [28], [87.92], [ms], [], [29], [91.06], [ms], [], [30], [94.20], [ms], [],
    [31], [97.34], [ms], [], [32], [100.48], [ms], [], [33], [103.62], [ms], [],
    [34], [106.76], [ms], [], [35], [109.90], [ms], [], [36], [113.04], [ms], [],
    midrule(),
    bottomrule(),
  ),
  kind: table,
  caption: [计时结果],
)

=== 算法

在偏向于计算机科学的论文中，算法是常见的浮动体；常以伪代码的形式出现。我们引入了 `algo` 宏包，以实现伪代码的排版。在Typst中，算法以 #raw("#algo()", lang: "typ") 的形式实现。
同样地，我们需要把 #raw("#algo()", lang: "typ") 作为 #raw("#figure()", lang: "typ") 的
`content` 参数。

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
  #figure(algo(
    title: [
      #set text(size: 15pt)
      #emph(smallcaps("Fib")) ],
    parameters: ([#math.italic("n")],),
    comment-prefix: [#sym.triangle.stroked.r ],
    comment-styles: (fill: rgb(100%, 0%, 50%)),
    indent-size: 15pt,
    indent-guides: 1pt + gray,
    inset: 5pt,
    fill: luma(250),
  )[
    if $n < 0$:#i\
    return null#d\
    if $n = 0$ or $n = 1$:#i\
    return $n$#d\
    \
    let $x <- 0$\
    let $y <- 1$\
    for $i <- 2$ to $n-1$:#i #comment[so dynamic!]\
    let $z <- x+y$\
    let $x <- y$\
    let $y <- z$#d\
    \
    return $x+y$
  ], caption: [计算斐波那契数列], kind: "algo", supplement: "算法") <algo:fib>
  ```, [
    #figure(
      algo(
        title: [ // note that title and parameters
          #set text(size: 15pt) // can be content
          #emph(smallcaps("Fib")) ], parameters: ([#math.italic("n")],), comment-prefix: [#sym.triangle.stroked.r ], comment-styles: (fill: rgb(100%, 0%, 50%)), indent-size: 15pt, indent-guides: 1pt + gray, inset: 5pt, fill: luma(250),
      )[
        if $n < 0$:#i\
        return null#d\
        if $n = 0$ or $n = 1$:#i\
        return $n$#d\
        \
        let $x <- 0$\
        let $y <- 1$\
        for $i <- 2$ to $n-1$:#i #comment[so dynamic!]\
        let $z <- x+y$\
        let $x <- y$\
        let $y <- z$#d\
        \
        return $x+y$
      ], caption: [计算斐波那契数列], kind: "algo", supplement: "算法",
    ) <algo:fib>
  ],
)

=== 代码

我们也可以把代码作为浮动体，以便于在论文中展示代码。在Typst中，代码作为 #raw("#figure()", lang: "typ") 的
`content` 参数，以构建浮动体。

#figure(
  ```python
  def fibonacci(n: int) -> int:
      """
      Calculates the nth Fibonacci number.

      Args:
          n (int): Index of the desired Fibonacci number. Must be non-negative.

      Returns:
          int: The nth Fibonacci number.

      Raises:
          ValueError: If the input is negative.
      """
      if n < 0:
          raise ValueError("Negative arguments are not supported")
      if n == 0:
          return 0
      if n == 1:
          return 1
      return fibonacci(n - 1) + fibonacci(n - 2)
  ```, caption: [计算斐波那契数列的Python实现], kind: raw,
) <lst:fibpy>

== 浮动体和公式的交叉引用 <floats>

在论文中，我们经常需要引用浮动体，如 "见图1.1"、"见表2.2"、"见算法3.3"
等。本模板通过 Typst 内置的 `figure` 编号系统，
按章节自动为浮动体分配 "章节号.浮动体序号" 格式的编号。

在引用@floats-class 提到的浮动体类型时，我们需要给出浮动体的类型，如 `fig`（图）、`tbl`（表）、`algo`（算法）、`lst`（代码）
等，用冒号 `:` 与浮动体的标签分隔。在Typst中，我们可以使用 `@fig:xxx` 的形式引用浮动体。在渲染时，Typst会自动将 `@fig:xxx` 转换为
"图X.X" 的形式。下面是一个例子。

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
如@fig:multifigure1、@tbl:table1、@algo:fib 和@lst:fibpy 所示。
  ```, [
  如@fig:multifigure1、@tbl:table1、@algo:fib 和@lst:fibpy 所示。
])

在引用公式时，我们可以直接用 `@eqt-demo` 的形式引用公式。在渲染时，Typst 会自动显示为 "(X.X)" 的编号。下面是一个例子。

$
  A = pi r^2
$ <eqt-demo>

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
如@eqt-demo 所示。
  ```, [
  如@eqt-demo 所示。
])
