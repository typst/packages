#let Chapter_three = [
  = 图表、算法格式

  == 插图

  图要有图题，并置于图的编号之后，图的编号和图题应置于图下方的居中位置。文中必须有关于本插图的提示，如“见@energy-distribution”。该页空白不够排写该图整体时，则可将其后文字部分提前排写，将图移到次页。

  #figure(
    image(
      "figures/energy-distribution.png", //图片的路径
      width: 80%, //图片的宽度
    ),
    caption: [内热源沿径向的分布], //图片的标题名称
  ) <energy-distribution>//图片的标识，通过该标识在正文中引入图片


  == 表格

  本模板使用 `tablex` 函数对表格进行封装，实现了自动续表和表格脚注功能，表格的引用须以 `tbl` 开头。

  === 三线表格

  编排表格应简单明了，表达一致，明晰易懂，表文呼应、内容一致。表题置于表上，研究生学位论文可以用中、英文两种文字居中排写，中文在上，也可以只用中文。

  表格的编排建议采用国际通行的三线表
  #footnote[三线表，以其形式简洁、功能分明、阅读方便而在科技论文中被推荐使用。
    三线表通常只有 3 条线，即顶线、底线和栏目线，没有竖线。]，如@threelinetable 所示。

  #figure(
    caption: [三线表格],
    table(
      columns: (8em, 8em, 8em),
      //设置表格列数和列宽比例
      stroke: 0pt,
      //设置表格边框宽度
      //标题行
      table.hline(end: 3, stroke: 1.25pt),
      //设置三线表的顶线，参数end: 3表示在第3列结束，stroke: 1.25pt表示线宽为1.25pt
      [Animal],
      //设置第一列内容
      [Desciption],
      //设置第二列内容
      [Price(\$)],
      //设置第三列内容
      table.hline(end: 3, stroke: 0.35pt),
      //设置三线表的中线，参数end: 3表示在第3列结束

      [Gnat], [per gram], [13.65],
      [], [each], [0.01],
      [Gnu], [stuffed], [92.50],
      [Emu], [stuffed], [33.33],
      [Armadillo], [frozen], [8.99],
      table.hline(end: 3, stroke: 1.25pt),
      //设置三线表的底线，参数end: 3表示在第3列结束，stroke: 1.25pt表示线宽为1.25pt
    ),
  ) <threelinetable>
  === 普通表格
  也可以使用普通表格，如@normallinetable 所示，但不建议使用。普通表格的编排应符合以下要求：
  - 表格边框线条清晰，线宽适当，表格内不得有过多的竖线和横线。

  #figure(
    caption: [普通表],
    table(
      columns: (8em, 8em, 8em),
      //设置表格列数和列宽比例
      stroke: 1pt,
      //设置表格边框宽度

      [Animal],
      //设置第一列内容
      [Desciption],
      //设置第二列内容
      [Price(\$)],
      //设置第三列内容

      [Gnat], [per gram], [13.65],
      [], [each], [0.01],
      [Gnu], [stuffed], [92.50],
      [Emu], [stuffed], [33.33],
      [Armadillo], [frozen], [8.99],
    ),
  ) <normallinetable>


  == 算法环境
  我们可以在论文中插入算法，可在学要插入算法的地方使用 `algo` 环境。
  #import "@preview/stu-bachelor-thesis:0.1.0": algo, comment, d, i
  #algo(
    line-numbers: false,
    strong-keywords: false,
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
    $x <- y$\
    $y <- z$#d\
    \
    return $x+y$
  ]

  == 代码环境

  我们可以在论文中插入算法，但是不建议插入大段的代码。如果确实需要插入代码，推荐使用 `codly` 包插入代码。

  #import "@preview/codly:1.3.0": *
  #import "@preview/codly-languages:0.1.10": *
  #show: codly-init.with()
  #codly(languages: codly-languages)

  #block(breakable: false)[
    ```python
    def fibonacci(n: int) -> int:
        # 输入：整数 n
        # 输出：Fibonacci 数列的第 n 项

        if n == 0:
            return 0
        if n == 1:
            return 1

        a = 0
        b = 1
        for i in range(2, n + 1):
            tmp = a + b
            a = b
            b = tmp
        return b
    ```
  ]
]
