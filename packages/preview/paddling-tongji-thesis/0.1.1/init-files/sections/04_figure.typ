#import "@preview/paddling-tongji-thesis:0.1.1": *

#let example-image = "../figures/example-image.svg"

= 浮动体 <float>

在本节（@float）中，我们将介绍浮动体的概念、分类及其在论文中的使用。

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
) <floatcode>

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
  ), caption: [多个插图示例1]) <multifigure1>
  ```, [
    #figure(
      grid(
        columns: 2, rows: 2, gutter: 5pt, image(example-image), image(example-image), image(example-image), image(example-image),
      ), caption: [多个插图示例1],
    ) <multifigure1>
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
    [#figure(image(example-image), caption: [示例2]) <multifigure2>],
    [#figure(image(example-image), caption: [示例3]) <multifigure3>],
    [#figure(image(example-image), caption: [示例4]) <multifigure4>],
    [#figure(image(example-image), caption: [示例5]) <multifigure5>],
  ))
  ```, [
    #figure(
      grid(
        columns: 2, rows: 2, gutter: 5pt, [#figure(image(example-image), caption: [示例2]) <multifigure2>], [#figure(image(example-image), caption: [示例3]) <multifigure3>], [#figure(image(example-image), caption: [示例4]) <multifigure4>], [#figure(image(example-image), caption: [示例5]) <multifigure5>],
      ),
    )
  ],
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
          [*_t_*], [1], [2], [3],
          [*_y_*], [0.3s], [0.4s], [0.8s],
        ),
        caption: [计时结果],
    ) <table1>
      ```, [
    #figure(
      table(columns: 4, [*_t_*], [1], [2], [3], [*_y_*], [0.3s], [0.4s], [0.8s]), caption: [计时结果],
    ) <table1>
  ],
)

在 Typst 中，还没有像 #LaTeX 里的 `booktabs` 宏包那样的专门用于排版三线表的宏包。但我们引入了 `tablex` 宏包，可以手动实现三线表的排版。在本模板中，我们定制了 `toprule`、`midrule` 和 `bottomrule` 三个命令，用于绘制三线表的上中下三条线。我们还定制了 `cmidrule` 命令，用于绘制三线表的中间线。下面是一个例子。

#table(
  columns: (1fr, 1fr), [
    #set align(center)
    #strong[代码]
  ], [
    #set align(center)
    #strong[渲染结果]
  ], ```typ
  #figure(
    tablex(
      columns: 3,
      auto-lines: false,
      align: center + horizon,

      toprule(),
      colspanx(2)[*Item*], (),  rowspanx(2)[*Price* (\$)],
      cmidrule(start: 0, end: 2, ),
      [*Animal*], [*Description*], (),
      midrule(),
      rowspanx(2)[Gnat], [per gram], cellx(align: right)[13.65],
      (), [each], cellx(align: right)[0.01],
      [Gnu], [stuffed], cellx(align: right)[92.50],
      [Emu], [stuffed], cellx(align: right)[33.33],
      [Armadillo], [frozen], cellx(align: right)[8.99],
      bottomrule(),
    ),
    caption: [三线表示例],
    kind: table,
  )
  ```, [
    #figure(
      tablex(
        columns: 3, auto-lines: false, align: center + horizon, toprule(), colspanx(2)[*Item*], (), rowspanx(2)[*Price* (\$)], cmidrule(start: 0, end: 2), [*Animal*], [*Description*], (), midrule(), rowspanx(2)[Gnat], [per gram], cellx(align: right)[13.65], (), [each], cellx(align: right)[0.01], [Gnu], [stuffed], cellx(align: right)[92.50], [Emu], [stuffed], cellx(align: right)[33.33], [Armadillo], [frozen], cellx(align: right)[8.99], bottomrule(),
      ), caption: [三线表示例], kind: table,
    )
  ],
)

`tablex` 宏包也实现了跨页表格。然而，关于带有 “续表X.X”
说明文字的跨页表格，Typst目前还没有很好的解决方案。因此，我们建议在Typst实现这一功能之前，不要使用跨页表格，以免造成与官方模板的不一致。

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
  ], caption: [计算斐波那契数列], kind: "algo", supplement: "算法") <fib>
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
    ) <fib>
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
) <fibpy>

== 浮动体和公式的交叉引用 <floats>

在论文中，我们经常需要引用浮动体，如 “见图1.1”、“见表2.2”、“见算法3.3”
等。由于在Typst中，浮动体的编号没有预设好的 “章节号.浮动体序号”
的形式，我们引入了 `i-figured` 宏包，以实现我们需要的浮动体的交叉引用格式。

在引用@floats-class 提到的浮动体类型时，我们需要给出浮动体的类型，如 `fig`（图）、`tbl`（表）、`algo`（算法）、`lst`（代码）
等，用冒号 `:` 与浮动体的标签分隔。在Typst中，我们可以使用 `@fig:xxx` 的形式引用浮动体。在渲染时，Typst会自动将 `@fig:xxx` 转换为
“见图X.X” 的形式。下面是一个例子。

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

在引用公式时，我们也需要给出公式的类型（`eqt`），用冒号 `:` 与公式的标签分隔。在Typst中，我们可以使用 `@eqt:xxx` 的形式引用公式。在渲染时，Typst会自动将 `@eqt:xxx` 转换为
“公式~(X.X)” 的形式。下面是一个例子。

#table(columns: (1fr, 1fr), [
  #set align(center)
  #strong[代码]
], [
  #set align(center)
  #strong[渲染结果]
], ```typ
如@eqt:pir2 所示。
  ```, [
  如@eqt:pir2 所示。
])
