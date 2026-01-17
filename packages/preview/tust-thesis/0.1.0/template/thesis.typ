#import "@preview/tust-thesis:0.1.0": *

#let (
  date,
  twoside,
  anonymous,
  info,
  doc,
  preface,
  mainmatter,
  appendix,
  cover,
  cover-en,
  declare,
  abstract,
  abstract-en,
  outline,
  image-outline,
  table-outline,
  algorithm-outline,
  nomenclature,
  bib,
  acknowledgement,
  task,
  codly-setup,
) = documentclass(
  date: datetime.today(), // 日期
  twoside: false, // 双面模式
  anonymous: false, // 盲审模式
  use-standard-code-format: false, // 使用规范代码格式（宋体）
  info: (
    student-id: "22104900",
    name: "张三",
    name-en: "Zhang San",
    title: "天津科技大学本科毕业设计（论文）模板",
    title-en: "Undergraduate Thesis Template for Tianjin University of Science and Technology",
    work-type: "design", // "design"(毕业设计) | "thesis"(毕业论文)
    school: "人工智能学院",
    major: "专业名称",
    research: "研究方向",
    grade: "2022",
    supervisor: "指导教师",
    supervisor-rank: "职称",
  ),
)

#show: doc

#cover()

#declare(
  // 如需显示签名图片，请取消注释并调整位置参数
  original-statement-sign: place(dx: 13cm, dy: -1.3cm, image("figures/student-sign.png", height: 2em)),
  authorization-author-sign: place(dx: 5cm, dy: -1.3cm, image("figures/student-sign.png", height: 2em)),
  supervisor-sign: place(dx: 4cm, dy: -1.2cm, image("figures/supervisor-sign.png", height: 2em)),
)

#task(
  // 如需自定义日期，请取消注释并填写
  // start-date: (year: "2024", month: "9", day: "1"),
  // end-date: (year: "2025", month: "6", day: "1"),
  // sign-date: (year: "2024", month: "9", day: "10"),
)[
  // 在此填写任务书内容
  1. 查阅相关文献，了解国内外研究现状。
  
  2. 完成开题报告，确定研究方案。
  
  3. 开展实验研究，收集数据并进行分析。
  
  4. 撰写论文初稿，并根据导师意见修改完善。
  
  5. 完成论文终稿并准备答辩。
]

#show: preface

#abstract(keywords: (
  "学位论文",
  "论文格式",
  "Typst",
  "模板",
))[
  本文介绍天津科技大学本科毕业设计（论文） Typst 模板的使用方法。该模板遵循学校规定的论文格式要求，包括封面、声明、任务书、摘要、目录、正文、参考文献、致谢等部分。模板采用模块化设计，用户只需修改基本信息和正文内容即可生成符合规范的论文。
  
  本模板参考上海交通大学学位论文Typst模板的设计思路，结合天津科技大学的具体要求进行调整和优化。
]

#abstract-en(keywords: ("thesis", "format", "Typst", "template"))[
  This document introduces the usage of Typst template for undergraduate design (thesis) at Tianjin University of Science and Technology. The template follows the university's thesis format requirements, including cover page, declaration, task assignment, abstract, table of contents, main body, references, and acknowledgement.
  
  With a modular design, users only need to modify basic information and main content to generate a compliant thesis. This template is developed with reference to Shanghai Jiao Tong University Thesis Typst Template and adapted to meet TUST's specific requirements.
]

#outline()

// #image-outline() // 插图目录，按需设置

// #table-outline() // 表格目录，按需设置

// #algorithm-outline() // 算法目录，按需设置

#nomenclature(
  width: 50%,
  columns: (1fr, 1.5fr),
)[
  / $epsilon$: 介电常数
  / $mu$: 磁导率
  / $epsilon$: 介电常数
  / $mu$: 磁导率
  / $epsilon$: 介电常数
  / $mu$: 磁导率
] // nomenclature 为单独一页的符号对照表

#show: mainmatter.with(use-standard-code-format: false)
#show: word-count-cjk // 正文字数统计

= 绪论 <chp:intro>

== 引言

学位论文是研究生从事科研工作的成果的主要表现，集中表明了作者在研究工作中获得的新的发明、理论或见解，是研究生申请硕士或博士学位的重要依据，也是科研领域中的重要文献资料和社会的宝贵财富。

=== 三级标题

更深层次的内容......

==== 四级标题

标题引用：@chp:intro @sec:meaning @app:flowchart

== 本文研究主要内容

本文主要研究......

== 本文研究意义 <sec:meaning>

本文的研究具有重要的理论和实践意义......

== 本章小结

本章介绍了论文的研究背景、研究意义和主要内容......

= 数学与引用文献的标注

== 数学

=== 数学和单位

包 `unify` 提供了更好的数字和单位支持，但与 `siunitx` 相比，只支持了`num`, `unit`, `qty`, `numrange`, `qtyrange` 五个函数：

#import "@preview/unify:0.7.1": *

- $num("-1.32865+-0.50273e-6")$
- $num("0.3e45", multiplier: "times")$
- $unit("kg m/s")$
- $unit("ohm")$
- $qty("0.13", "mm")$
- $qty("1.3+1.2-0.3e3", "erg/cm^2/s", space: "#h(2mm)")$
- $numrange("1,1238e-2", "3,0868e5", thousandsep: "'")$
- $numrange("10", "20", delimiter: "tilde")$
- $qtyrange("1e3", "2e3", "meter per second squared", per: "\\/", delimiter: "\"to\"")$
- $qtyrange("10", "20", "celsius", delimiter: "tilde")$

=== 数学符号和公式

按照国标GB/T3102.11—1993《物理科学和技术中使用的数学符号》，微分符号 $dif$ 应使用直立体。除此之外，数学常数也应使用直立体：

#let bf(x) = math.bold(math.upright(x))
#let ppi = $upright(pi)$
#let ee = $upright(e)$
#let ii = $upright(i)$

- 微分符号 $dif$： `dif`
- 圆周率 $ppi$： `upright(pi)`
- 自然对数的底 $ee$： `upright(e)`
- 虚数单位 $ii$： `upright(i)`

公式应另起一行居中排版。公式后应注明编号，按章顺序编排，编号右端对齐，如@equation 所示。

$
  ee^(ii ppi) + 1 = 0
$ <equation>

$
  (dif^2 u) / (dif t^2) = integral f(x) dif x
$

公式末尾是需要添加标点符号的，至于用逗号还是句号，取决于公式下面一句是接着公式说的，还是另起一句。

$
  (2h) / ppi limits(integral)_0^infinity (sin (omega delta)) / omega cos (omega x) dif omega = cases(
    h "," quad abs(x) < delta ",",
    h / 2 "," quad x = plus.minus delta ",",
    0 "," quad abs(x) > delta"."
  )
$

公式较长时最好在等号"$=$"处转行。子公式的引用请在该行公式后添加 `#<subequation>` 引用标签，如@subequation 所示。如果有某行公式不需要编号,请使用 `#<equate:revoke>` 标签。（此标签由 `equate` 包定义，目前不可自定义）

$
    & I(X_3; X_4) - I(X_3; X_4 | X_1) - I(X_3; X_4 | X_2) #<equate:revoke> \
  = & [I(X_3; X_4) - I(X_3; X_4 | X_1)] - I(X_3; X_4 | tilde(X_2)) \
  = & I(X_1; X_3; X_4) - I(X_3; X_4 | tilde(X_2)). #<subequation>
$

如果在等号处转行难以实现，也可在 $+$、$-$、$times$、$div$ 运算符号处转行，转行时运算符号仅书写于转行式前，不重复书写。

$
  1 / 2 Delta(f_(i j) f^(i j)) = 2 med &(sum_(i<j) x_(i j) (sigma_i - sigma_j)^2 + f_(i j) nabla_j nabla_i (Delta f) #<equate:revoke> \
    &+ nabla_k f_(i j) nabla^k f^(i j) + f^(i j) f^k [2 nabla_i R_(j k) - nabla_k R_(i j)]).
$

=== 定理环境

示例文件中使用 `theorion` 宏包配置了定理、引理和证明等环境。

这里举一个"定理"和"证明"的例子。

#let Res = math.op("Res")

#theorem(title: "留数定理")[
  假设 $U$ 是复平面上的一个单连通开子集，$a_1, dots, a_n$ 是复平面上有限个点，$f$ 是定义在 $U without {a_1, dots, a_n}$ 上的全纯函数，如果 $gamma$ 是一条把 $a_1, dots, a_n$ 包围起来的可求长曲线，但不经过任何一个 $a_k$，并且其起点与终点重合，那么：

  $
    limits(integral.cont)_gamma f(z) dif z = 2 ppi ii sum_(k=1)^n op(I)(gamma, a_k) Res(f, a_k).
  $ <res>

  如果 $gamma$ 是若尔当曲线，那么 $op(I)(gamma, a_k) = 1$，因此：

  $
    limits(integral.cont)_gamma f(z) dif z = 2 ppi ii sum_(k=1)^n Res(f, a_k).
  $ <resthm>

  在这里，$Res(f, a_k)$ 表示 $f$ 在点 $a_k$ 的留数，$op(I)(gamma, a_k)$ 表示 $gamma$ 关于点 $a_k$ 的卷绕数。卷绕数是一个整数，它描述了曲线 $gamma$ 绕过点 $a_k$ 的次数。如果 $gamma$ 依逆时针方向绕着 $a_k$ 移动，卷绕数就是一个正数，如果 $gamma$ 根本不绕过 $a_k$，卷绕数就是零。

  @thm:res 的证明。

  #proof[
    首先，由……

    其次，……

    所以……
  ]
] <thm:res>

== 引用文献的标注

正文中引用参考文献时，使用 `@Yu2001 @Cheng1999 @Li1999` 可以产生"上标引用的参考文献"，如 @Yu2001 @Cheng1999 @Li1999。

Typst 使用 Hayagriva 管理参考文献，有部分细节问题还在逐步修复。

= 图表、算法格式

== 插图

本模板使用 `imagex` 函数对图片环境进行封装，在实现子图，双语图题等复杂功能的同时，仍保留较高的自定义程度，将通过下面的示例进行说明。图片的引用须以 `img` 开头。

=== 单个图形

图要有图题，图题采用中文，并置于图的编号之后，图的编号和图题应置于图下方的居中位置。文中必须有关于本插图的提示，如@img:image 所示。该页空白不够排写该图整体时，则可将其后文字部分提前排写，将图移到次页。

#imagex(
  image(
    "figures/energy-distribution.png",
    width: 80%,
  ),
  caption: [内热源沿径向的分布],
  label-name: "image",
)

=== 多个图形

简单插入多个图形的例子如@img:SRR 所示。这两个水平并列放置的子图共用一个图形计数器，没有各自的子图题。

#imagex(
  image("figures/emissions-variation.png"),
  image("figures/emissions-2050.png"),
  columns: (1fr, 1fr),
  caption: [不同情景下上海市乘用车的温室气体排放量],
  label-name: "SRR",
)

如果多个图形相互独立，并不共用一个图形计数器，那么用 `grid` 或者 `columns` 就可以，如@img:parallel1 与@img:parallel2。

#grid(
  align: bottom,
  grid.cell(imagex(
    image("figures/emissions-variation.png"),
    caption: [温室气体排放量随时间变化的情况],
    label-name: "parallel1",
  )),
  grid.cell(imagex(
    image("figures/emissions-2050.png"),
    caption: [2050 年的温室气体排放量],
    label-name: "parallel2",
  )),
  columns: (1fr, 1fr),
)

如果要为共用一个计数器的多个子图添加子图题，使用 `subimagex`，如@img:subfigures 所示。

#imagex(
  subimagex(
    image("figures/emissions-variation.png"),
    caption: [温室气体排放量随时间变化的情况],
    label-name: "test1",
  ),
  subimagex(
    image("figures/emissions-2050.png"),
    caption: [2050 年的温室气体排放量],
    label-name: "test2",
  ),
  columns: (1fr, 1fr),
  caption: [不同情景下上海市乘用车的温室气体排放量],
  label-name: "subfigures",
)

== 表格

本模板使用 `tablex` 函数对表格进行封装，实现了自动续表和表格脚注功能，表格的引用须以 `tbl` 开头。

=== 基本表格

编排表格应简单明了，表达一致，明晰易懂，表文呼应、内容一致。表题置于表上。

表格的编排建议采用国际通行的三线表#footnote[三线表，以其形式简洁、功能分明、阅读方便而在科技论文中被推荐使用。三线表通常只有 3 条线，即顶线、底线和栏目线，没有竖线。]，如@tbl:standard-table 所示。

#tablex(
  [Gnat],
  [per gram],
  [13.65],
  [],
  [each],
  [0.01],
  [Gnu],
  [stuffed],
  [92.50],
  [Emu],
  [stuffed],
  [33.33],
  [Armadillo],
  [frozen],
  [8.99],
  header: (table.cell(colspan: 2)[Item], [], table.hline(end: 2, stroke: 0.25pt), [Animal], [Desciption], [Price(\$)]),
  columns: 3,
  caption: [一个颇为标准的三线表],
  label-name: "standard-table",
)

=== 复杂表格

我们经常会在表格下方标注数据来源，或者对表格里面的条目进行解释。可以用 `table-note` 在表格中添加表注，如@tbl:footnote-table 所示。

#tablex(
  [],
  [4.22],
  [120.0140#table-note("the second note.")],
  [],
  [333.15],
  [0.0411],
  [],
  [444.99],
  [0.1387],
  [],
  [168.6123],
  [10.86],
  [],
  [255.37],
  [0.0353],
  [],
  [376.14],
  [0.1058],
  [],
  [6.761],
  [0.007],
  [],
  [235.37],
  [0.0267],
  [],
  [348.66],
  [0.1010],
  align: horizon,
  breakable: false,
  header: (
    table.cell(rowspan: 2)[total],
    table.cell(colspan: 2)[20#table-note("the first note.")],
    table.cell(rowspan: 2)[],
    table.cell(colspan: 2)[40],
    table.cell(rowspan: 2)[],
    table.cell(colspan: 2)[60],
    table.hline(end: 3, stroke: 0.25pt),
    table.hline(start: 4, end: 6, stroke: 0.25pt),
    table.hline(start: 7, end: 9, stroke: 0.25pt),
    [www],
    [k],
    [www],
    [k],
    [www],
    [k],
  ),
  columns: 9,
  caption: [一个带有脚注的表格的例子],
  label-name: "footnote-table",
)

如某个表需要转页接排，`tablex` 自动实现了续表功能。接排时表题省略，表头应重复书写，并在右上方写"续表 xx"，如@tbl:long-table 所示。（注意：当表格跨页时，脚注不能添加在表头中，会导致重复标注，此时应传入参数 `breakable: false`，取消续表功能。）

#tablex(
  ..for i in range(15) {
    ([250], [88], [5900], [1.65])
  },
  header: (
    [感应频率 #linebreak() (kHz)],
    [感应发生器功率 #linebreak() (%×80kW)],
    [工件移动速度 #linebreak() (mm/min)],
    [感应圈与零件间隙 #linebreak() (mm)],
  ),
  columns: (25%, 25%, 25%, 25%),
  caption: [高频感应加热的基本参数],
  label-name: "long-table",
)

== 算法环境

本模板使用 `algox` 函数对算法环境进行封装，其中使用的算法包为 `lovelace`，需要自定义 `pseudocode-list` 的格式时可自行查询 `lovelace` 的文档。算法的应用须以 `algo` 开头。算法与表格一样也实现了跨页自动添加"须算法"的功能。

我们可以通过@algo:fibonacci 来计算斐波那契数列第 $n$ 项。

#let tmp = math.italic("tmp")
#algox(
  label-name: "fibonacci",
  caption: [斐波那契数列计算],
  pseudocode-list(line-gap: 1em, indentation: 2em)[
    - #h(-1.5em) *input:* integer $n$
    - #h(-1.5em) *output:* Fibonacci number $F(n)$
    + *if* $n = 0$ *then return* $0$
    + *if* $n = 1$ *then return* $1$
    + $a <- 0$
    + $b <- 1$
    + *for* $i$ *from* $2$ *to* $n$ *do*
      + $tmp <- a + b$
      + $a <- b$
      + $b <- tmp$
    + *end*
    + *return* $b$
  ],
)

== 代码环境

我们可以在论文中插入算法，但是不建议插入大段的代码。如果确实需要插入代码，推荐使用 `codly` 包插入代码。

```python
def fibonacci(n: int) -> int:
    """计算斐波那契数列的第 n 项"""
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

= 绘图

== 流程图 <sec:flowchart>

`fletcher` 是一个基于 `CeTZ` 的 `Typst` 包，用于绘制流程图，功能丰富，可参考 `fletcher` 的文档进行学习。

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: diamond, parallelogram

#imagex(
  diagram(
    node-stroke: 0.5pt,
    node-inset: 1em,
    edge-corner-radius: 0pt,
    spacing: 2.5em,

    (
      node((0, 0), "待测图片", corner-radius: 5pt),
      node((0, 1), "读取背景", shape: parallelogram),
      node((0, 2), "匹配特征点对"),
      node((0, 3), "多于阈值", shape: diamond),
    )
      .intersperse(edge("-|>"))
      .join(),
    (
      node((0, 4), "透视变换矩阵"),
      node((0, 5), "图像修正"),
      node((0, 6), "配准结果", corner-radius: 5pt),
    )
      .intersperse(edge("-|>"))
      .join(),
    node((3, 2), "重采"),
    edge("<|-", [是]),
    node((3, 3), "清晰?", shape: diamond),
    edge("-|>", [是]),
    node((3, 4), "仿射变换矩阵"),

    edge((0, 3), (0, 4), [是], "-|>"),
    edge((0, 3), (3, 3), [否], "-|>"),
    edge((3, 4), (0, 5), "-|>", corner: right),
    edge((3, 2), (0, 0), "-|>", corner: left),
  ),
  caption: [绘制流程图效果],
  caption-en: [Flow chart],
  label-name: "fletcher-example",
)

== 数据图

`lilaq` 是一个强大的 Typst 绘图库，可以绘制各种类型的数据图。

#import "@preview/lilaq:0.5.0" as lq

#let xs = (0, 1, 2, 3, 4)
#let (y1, y2) = ((1, 2, 3, 4, 5), (5, 3, 7, 9, 3))

#imagex(
  lq.diagram(
    width: 10cm,
    height: 6cm,

    title: [Precious data],
    xlabel: $x$,
    ylabel: $y$,

    lq.plot(xs, y1, mark: "s", label: [A]),
    lq.plot(xs, y2, mark: "o", label: [B]),
  ),
  caption: [绘制折线图效果],
  caption-en: [Line plots],
  label-name: "lilaq-line-example",
)

#import "@preview/suiji:0.4.0"
#let rng = suiji.gen-rng(33)
#let (rng, x) = suiji.uniform(rng, size: 20)
#let (rng, y) = suiji.uniform(rng, size: 20)
#let (rng, colors) = suiji.uniform(rng, size: 20)
#let (rng, sizes) = suiji.uniform(rng, size: 20)

#imagex(
  lq.diagram(
    width: 10cm,
    height: 6cm,

    lq.scatter(
      x,
      y,
      size: sizes.map(size => 1000 * size),
      color: colors,
      map: color.map.magma,
    ),
  ),
  caption: [绘制散点图效果],
  caption-en: [Scatter],
  label-name: "lilaq-scatter-example",
)

= 全文总结

== 主要结论

本文主要研究了......

正文与附录的总字数为：#total-words。 // 字数统计功能，仅供参考

== 研究展望

更深入的研究方向包括......

// 参考文献
#bib(
  bibfunc: bibliography.with("ref.bib"),
  full: false,
) // full: false 只显示已引用的文献，true 显示所有文献

#acknowledgement[
  本论文是在导师的悉心指导下完成的。导师渊博的专业知识、严谨的治学态度、精益求精的工作作风深深地感染和激励着我。在此谨向导师致以诚挚的谢意和崇高的敬意。
  
  感谢实验室的各位老师和同学，在学习和生活中给予我的关心和帮助。
  
  感谢我的家人和朋友，感谢他们一直以来的理解、支持和鼓励。
]

#show: appendix

= Maxwell Equations <app:flowchart>

#let bf(x) = math.bold(math.upright(x))

选择二维情况，有如下的偏振矢量：
$
  bf(E) & = E_z (r, theta) hat(bf(z)), \
  bf(H) & = H_r (r, theta) hat(bf(r)) + H_theta (r, theta) hat(bold(theta)).
$

对上式求旋度：
$
  nabla times bf(E) & = 1 / r (partial E_z) / (partial theta) hat(bf(r)) - (partial E_z) / (partial r) hat(bold(theta)), \
  nabla times bf(H) & = [1 / r partial / (partial r) (r H_theta) - 1 / r (partial H_r) / (partial theta)] hat(bf(z)).
$

因为在柱坐标系下，$macron(macron(mu))$ 是对角的，所以 Maxwell 方程组中电场 $bf(E)$ 的旋度：
$
  & nabla times bf(E) = upright(i) omega bf(B), \
  & 1 / r (partial E_z) / (partial theta) hat(bf(r)) - (partial E_z) / (partial r) hat(bold(theta)) = upright(i) omega mu_r H_r hat(bf(r)) + upright(i) omega mu_theta H_theta hat(bold(theta)).
$

所以 $bf(H)$ 的各个分量可以写为：
$
      H_r & = 1 / (ii omega mu_r) 1 / r (partial E_z) / (partial theta), \
  H_theta & = 1 / (ii omega mu_theta) 1 / r (partial E_z) / (partial r).
$

同样地，在柱坐标系下，$macron(macron(epsilon.alt))$ 是对角的，所以 Maxwell 方程组中磁场 $bf(H)$ 的旋度：
$
  & nabla times bf(H) = -ii omega bf(D), \
  & [1 / r partial / (partial r) (r H_theta) - 1 / r (partial H_r) / (partial theta)] hat(bf(z)) = -ii omega macron(macron(epsilon.alt)) bf(E) = -ii omega epsilon.alt_z E_z hat(bf(z)), \
  & 1 / r partial / (partial r)(r H_theta) - 1 / r (partial H_r) / (partial theta) = -ii omega epsilon.alt_z E_z.
$

由此我们可以得到关于 $E_z$ 的波函数方程：
$
  1 / (mu_theta epsilon.alt_z) 1 / r partial / (partial r) (r (partial E_z) / (partial r)) + 1 / (mu_r epsilon.alt_z) 1 / r^2 (partial^2 E_z) / (partial theta^2) + omega^2 E_z = 0.
$

= 实验数据

本附录提供了详细的实验数据。

#tablex(
  ..for i in range(10) {
    ([方法], str(i+1), str(0.85 + 0.01 * i), str(0.82 + 0.01 * i), str(0.83 + 0.01 * i))
  },
  header: (
    [方法名称], [编号], [准确率], [召回率], [F1分数]
  ),
  columns: 5,
  caption: [不同方法的性能对比数据],
  label-name: "exp-data",
)
