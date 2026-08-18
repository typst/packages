#import "@preview/scripst:1.1.2": *

= 模板效果展示

== 扉页

文档的开头会显示标题、信息、作者、时间、摘要、关键词等信息，如该文档的扉页所示。

== 目录

如果`contents`参数为`true`，则会生成目录，效果见本文档目录。

== 文字样式与环境

Scripst 提供了一些常用的文字样式和环境，如粗体、斜体、标题、图片、表格、列表、引用、链接、数学公式等。

=== 字体

这是正常的文本。 This is a normal text.

*这是粗体的文本。* *This is a bold text.*

_这是斜体的文本。_ _This is an italic text._

安装 CMU Serif 字体以获得更好（类似LaTeX）的显示效果。

=== 环境

==== 标题

一级标题编号随文档语言而异，包括中文/罗马数字/希腊字母/假名/阿拉伯文数字/印地文数字等，其余级别标题采用阿拉伯数字编号。

==== 图片

图片环境会自动编号，如下所示：

#figure(
  image("pic/pic.jpg", width: 50%),
  caption: "散宝",
)<pic>

==== 表格

得益于 `tablem` 包，使用本模板时可以用 Markdown 的方式编写表格，如下所示：

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  #figure(
    three-line-table[
      | 姓名 | 年龄 | 性别 |
      | --- | --- | --- |
      | 张三 | 18 | 男 |
      | 李四 | 19 | 女 |
    ],
    caption: [`three-line-table`表格示例],
  )
  ```
][
  #figure(
    three-line-table[
      | 姓名 | 年龄 | 性别 |
      | --- | --- | --- |
      | 张三 | 18 | 男 |
      | 李四 | 19 | 女 |
    ],
    caption: [`three-line-table`表格示例],
  )
]

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  #figure(
    tablem[
      | 姓名 | 年龄 | 性别 |
      | --- | --- | --- |
      | 张三 | 18 | 男 |
      | 李四 | 19 | 女 |
    ],
    caption: [`tablem`表格示例],
  )
  ```
][
  #figure(
    tablem[
      | 姓名 | 年龄 | 性别 |
      | --- | --- | --- |
      | 张三 | 18 | 男 |
      | 李四 | 19 | 女 |
    ],
    caption: [`tablem`表格示例],
  )
]

可以选择`numbering: none,`使得表格不编号，如上所示，前面章节的表格并没有进入全文的表格计数器。

==== 数学公式

数学公式有行内和行间两种模式。

行内公式：$a^2 + b^2 = c^2$。

行间公式：
$
  a^2 + b^2 = c^2 \
  1 / 2 + 1 / 3 = 5 / 6
$
是拥有编号的。

得益于 `physica` 包，typst本身简单的数学输入方式得到了极大的扩展，并且仍然保留简洁的特性：
$
  & div vb(E)  & = & rho / epsilon_0 \
  & div vb(B)  & = & 0 \
  & curl vb(E) & = & -pdv(vb(B), t) \
  & curl vb(B) & = & mu_0 (vb(J) + epsilon_0 pdv(vb(E), t))
$

#newpara()

=== 列举

typst 为列举提供了简单的环境，如所示：

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  - 第一项
  - 第二项
  - 第三项
  ```
][
  - 第一项
  - 第二项
  - 第三项
]

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  +  第一项
  3. 第二项
  +  第三项
  ```
][
  + 第一项
  3. 第二项
  + 第三项
]

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  / 第一项: 1
  / 第二项: 2
  / 第三项: 3
  ```
][
  / 第一项: 1
  / 第二项: 2
  / 第三项: 3
]

#newpara()

=== 引用

#grid(columns: (1fr, 1fr), align: (horizon, horizon))[
  ```typst
  #quote(attribution: "爱因斯坦", block: true)[
    上帝不会掷骰子。
  ]
  ```
][
  #quote(attribution: "爱因斯坦", block: true)[
    上帝不会掷骰子。
  ]
]

#newpara()

=== 链接

#grid(columns: (1fr, 1fr), align: (horizon, horizon + center))[
  ```typst
  #link("https://www.google.com/")[Google]
  ```
][
  #link("https://www.google.com/")[Google]
]

#newpara()

=== 超链接与文献引用

利用`<lable>`和`@lable`可以实现超链接和文献引用。

== `#newpara()`函数

默认某些模块不自动换行。这是有必要的，例如，数学公式后面如果不换行就表示对上面的数学公式的解释。

但有时候我们需要换行，这时候就可以使用`#newpara()`函数。

区别于官方提供的 `#parbreak()` 函数，`#newpara()` 函数会在段落之间插入一个空行，这样无论在什么场景下，都会开启新的自然段。

只要你觉得需要换行，就可以使用`#newpara()`函数。

== labelset

得益于 typst 中的 `label` 函数，除了给这种类型添加标签外，还可以通过 label 方便地为所引用的对象设置样式。

因此，Scripst内置了一些常用的设置，你可以通过直接添加label来设置样式。

```typst
== Schrödinger equation <hd.x>

下面是 Schrödinger 方程：
$
  i hbar dv(,t) ket(Psi(t)) = hat(H) ket(Psi(t))
$ <text.blue>
其中
$
  ket(Psi(t)) = sum_n c_n ket(phi_n)
$ <eq.c>
是波函数。由此可以得到定态的 Schrödinger 方程：
$
  hat(H) ket(Psi(t)) = E ket(Psi(t))
$
<text.teal>
其中 $E$<text.red> 是#[能量]<text.lime>。
```

#newpara()

== Schrödinger equation <hd.x>

下面是 Schrödinger 方程：
$
  i hbar dv(, t) ket(Psi(t)) = hat(H) ket(Psi(t))
$ <text.blue>
其中
$
  ket(Psi(t)) = sum_n c_n ket(phi_n)
$ <eq.c>
是波函数。由此可以得到定态的 Schrödinger 方程：
$
  hat(H) ket(Psi(t)) = E ket(Psi(t))
$
<text.teal>
其中 $E$<text.red> 是#[能量]<text.lime>。

目前 Scripst 提供了以下的设置：
#figure(
  three-line-table[
    | 标签 | 功能 |
    | --- | --- |
    | `eq.c` | 给数学环境的公式取消编号 |
    | `hd.c` | 给标题取消编号，但还在目录中显示 |
    | `hd.x` | 给标题取消编号，且不在目录中显示 |
    | `text.{color}` | 给文本设置颜色 \ `color in (black, gray, silver, white, navy, blue, aqua, teal, eastern, purple, fuchsia, maroon, red, orange, yellow, olive, green, lime,)` |
  ],
  caption: [Label Set],
)

#caution(count: false)[
  上述字符串已关联特定样式，允许进行样式覆盖，但在调用`label` 和 `reference` 方法时，请保留这些字符串的原始定义。
]

#newpara()

== 由 Ratchet 驱动的统一编号 <ratchet>

Scripst 1.1.2 使用 #link("https://github.com/An-314/ratchet")[Ratchet 0.0.3] 作为统一编号引擎。Ratchet 负责公式、图片、表格、代码块以及自定义 `figure(kind: ...)` 计数器族的编号、标题层级重置和交叉引用；Scripst 的所有 countblock 也建立在这套机制之上。

这项集成使正文编号、交叉引用和目录条目共享同一份配置。每个计数器族都可以独立选择深度 `1`、`2` 或 `3`，新增 countblock 时也不再需要手动安装注册规则或标题重置规则。

#note(count: false)[
  Scripst 会自动配置 Ratchet，使用模板时无需再次导入。Ratchet 也可以作为独立包用于其他项目，详见 #link("https://typst.app/universe/package/ratchet")[Ratchet 的 Universe 页面]。
]

#newpara()

== countblock

#definition(subname: [countblock])[

  Countblock 是 Scripst 提供的一个计数器模块，用来对文档中的某些可以计数的内容进行计数。

  现在你看到的就是一个 `definition` 块，它是一个计数器模块的例子。
]

#newpara()

=== 默认提供的 countblock

Scripst 默认提供如下 countblock。表中的深度 `2` 表示跟随一级标题编号；它们都继承全局参数 `cb-counter-depth: 2`。

#figure(
  three-line-table[
    | 块名称 | `cb` 名称 | `counter-name` | 默认深度 | 颜色 | 调用函数 |
    | --- | --- | --- | --- | --- | --- |
    | Definition | `def` | `def` | `2` | `mycolor.green` | `#definition` |
    | Theorem | `thm` | `thm` | `2` | `mycolor.blue` | `#theorem` |
    | Proposition | `prop` | `prop` | `2` | `mycolor.violet` | `#proposition` |
    | Lemma | `lem` | `prop` | `2` | `mycolor.violet-light` | `#lemma` |
    | Corollary | `cor` | `prop` | `2` | `mycolor.violet-dark` | `#corollary` |
    | Remark | `rmk` | `prop` | `2` | `mycolor.violet-darker` | `#remark` |
    | Claim | `clm` | `prop` | `2` | `mycolor.violet-deep` | `#claim` |
    | Exercise | `ex` | `ex` | `2` | `mycolor.purple` | `#exercise` |
    | Problem | `prob` | `prob` | `2` | `mycolor.orange` | `#problem` |
    | Example | `eg` | `eg` | `2` | `mycolor.cyan` | `#example` |
    | Note | `note` | `note` | `2`（默认不计数） | `mycolor.grey` | `#note` |
    | Caution | `cau` | `cau` | `2`（默认不计数） | `mycolor.red` | `#caution` |
  ],
  caption: [Scripst 默认 countblock 配置],
  numbering: none,
)

`proposition`、`lemma`、`corollary`、`remark` 和 `claim` 的 `counter-name` 都是 `"prop"`，因此默认共享同一列编号和同一种重置深度；它们的标题和颜色仍然各自独立。

这些函数的参数和效果是一样的，只是计数器的名称不同。
```typst
#definition(
  subname: [],
  count: true,
  lab: none,
)[
  ...
]
```
参数说明如下
#three-line-table[
  | 参数 | 类型 | 默认值 | 说明 |
  | --- | --- | --- | --- |
  | `subname` | `array` | `[]` | 该条目的名称 |
  | `count` | `bool` | `true` | 是否计数 |
  | `lab` | `str` | `none` | 该条目的标签 |
]
下面是一个示例：
```typst
#theorem(subname: [_Fermat's Last Theorem_], lab: "fermat")[

  No three $a, b, c in NN^+$ can satisfy the equation
  $
    a^n + b^n = c^n
  $
  for any integer value of $n$ greater than 2.
]
#proof[Cuius rei demonstrationem mirabilem sane detexi. Hanc marginis exiguitas non caperet.]
```
就会创建一个定理块，并且计数：
#theorem(subname: [_Fermat's Last Theorem_], lab: "fermat")[

  No three $a, b, c in NN^+$ can satisfy the equation
  $
    a^n + b^n = c^n
  $
  for any integer value of $n$ greater than 2.
]

#newpara()

#proof[Cuius rei demonstrationem mirabilem sane detexi. Hanc marginis exiguitas non caperet.]

==== `subname` 参数

`subname` 是会显示在计数器后的信息，例如定理名称等。在上述例子中是“Fermat's Last Theorem”。

==== `lab` 参数

此外，你可以使用 `lab` 参数来为这个块添加一个标签，以便在文中引用。例如刚才的`fermat`定理块，你可以使用`@fermat`来引用它。

```typst
Fermat 并没有对 @fermat 给出公开的证明。
```
Fermat 并没有对 @fermat 给出公开的证明。

在默认提供的这些块中，`proposition`, `lemma`, `corollary`, `remark`, `claim`, 是共用同一个计数器的，效果如下：

#lemma[

  这是一个引理，请你证明它。
]

#proposition[

  这是一个命题，请你证明它。
]

#corollary[

  这是一个推论，请你证明它。
]

#remark[

  这是一个评论，请你注意它。
]

#claim[

  这是一个断言，请你证明它。
]

而其余的计数器是互相独立的。

==== `count` 参数

此外，对于`count`参数，如果你不想计数，可以将其设置为`false`。`note`和`caution`默认不计数。如果你想要计数，可以将其设置为`true`。

```typst
#note(count: true)[

  这是一个注记，请你注意它。
]

#note[

  这是一个注记，请你注意它。
]
```

#note(count: true)[

  这是一个注记，请你注意它。
]

#note[

  这是一个注记，请你注意它。
]

#newpara()

=== 调整所有 countblock 的深度 <cb-counter>

`cb-counter-depth` 是所有 countblock 的全局默认深度，可取 `1`、`2` 或 `3`：

- `1`：全文连续编号，如 `1, 2, 3`；
- `2`：随一级标题重置，如 `1.1, 1.2, 2.1`；
- `3`：随一级、二级标题重置，如 `1.1.1, 1.1.2, 1.2.1`。

例如，把所有没有单独指定深度的 countblock 调整为深度 `3`：

```typst
#show: scripst.with(
  countblocks: cb,
  cb-counter-depth: 3,
)
```

`cb-counter-depth` 只改变默认值。已经在 `countblocks` 中单独指定深度的计数器族不会受它影响。

=== 调整个别 countblock 的深度

使用 `set-countblock-depth` 可以覆盖某个计数器族的深度：

```typst
#let blocks = set-countblock-depth(cb, "thm", 3)

#show: scripst.with(
  countblocks: blocks,
  cb-counter-depth: 2,
)
```

此时只有 `theorem` 使用深度 `3`，其余独立计数器仍继承全局深度 `2`。

函数签名如下：

```typst
#set-countblock-depth(cb, name, depth, detach: false)
```

#three-line-table[
  | 参数 | 类型 | 默认值 | 说明 |
  | --- | --- | --- | --- |
  | `cb` | `dict` |  | 原 countblock 字典 |
  | `name` | `str` |  | 要调整的 `cb` 名称 |
  | `depth` | `int` |  | 新深度，只能是 `1`、`2` 或 `3` |
  | `detach` | `bool` | `false` | 是否从原共享计数器中拆出该块 |
]

==== 调整共享计数器族

`proposition`、`lemma`、`corollary`、`remark` 和 `claim` 共用 `counter-name: "prop"`。因此下面的写法会把整个共享族一起改为深度 `3`：

```typst
#let blocks = set-countblock-depth(cb, "lem", 3)
```

这是必要的：共享同一个计数器的块必须在相同标题位置一起重置，不能同时拥有不同深度。

==== 将一个块拆成独立深度

如果只希望 `lemma` 使用深度 `1`，同时让其他 `prop` 族成员继续使用深度 `2`，设置 `detach: true`：

```typst
#let blocks = set-countblock-depth(cb, "lem", 1, detach: true)
#let lemma = countblock.with("lem", blocks)

#show: scripst.with(
  countblocks: blocks,
  cb-counter-depth: 2,
)
```

`detach: true` 会把 `lemma` 的 `counter-name` 从 `"prop"` 改成 `"lem"`。因为计数器身份发生了变化，所以需要使用更新后的 `blocks` 重新封装 `lemma`。只调整本来就独立的 `theorem`、`definition` 等块的深度时，不需要重新封装默认函数。

=== 增添新的 countblock <new-cb>

使用 `add-countblock` 添加新块，并把更新后的字典传给 `scripst(countblocks: ...)`：

```typst
#let blocks = add-countblock(
  cb,
  "alg",
  "Algorithm",
  yellow,
  depth: 3,
)
#let algorithm = countblock.with("alg", blocks)

#show: scripst.with(
  countblocks: blocks,
  cb-counter-depth: 2,
)
```

此时 `algorithm` 使用独立计数器和深度 `3`；其他默认块仍使用全局深度 `2`。

`add-countblock` 的完整签名如下：

```typst
#add-countblock(cb, name, info, color, counter-name: none, depth: none)
```

#three-line-table[
  | 参数 | 类型 | 默认值 | 说明 |
  | --- | --- | --- | --- |
  | `cb` | `dict` |  | 原 countblock 字典 |
  | `name` | `str` |  | 新块在字典中的名称 |
  | `info` | `str` 或 `content` |  | 显示在块标题中的名称 |
  | `color` | `color` |  | 背景和左边框颜色 |
  | `counter-name` | `str` | `none` | 实际计数器名；默认与 `name` 相同 |
  | `depth` | `int` 或 `none` | `none` | 独立深度；`none` 表示继承 `cb-counter-depth` |
]

若要让新块共享已有编号，可以指定已有的 `counter-name`。例如让 `Assumption` 加入 theorem 的编号序列：

```typst
#let blocks = add-countblock(
  cb,
  "asm",
  "Assumption",
  aqua,
  counter-name: "thm",
)
#let assumption = countblock.with("asm", blocks)
```

共享 `counter-name` 的所有条目必须使用相同深度；否则 Scripst 会直接报错，避免出现显示编号和重置规则不一致。

=== `cb` 字典结构 <cb>

每一项的结构是 `(info, color, counter-name, depth)`。第四项 `depth` 可以省略或设为 `none`，表示继承全局 `cb-counter-depth`：

```typst
#let cb = (
  "def": ("Definition", mycolor.green, "def", none),
  "thm": ("Theorem", mycolor.blue, "thm", none),
  "prop": ("Proposition", mycolor.violet, "prop", none),
  "lem": ("Lemma", mycolor.violet-light, "prop", none),
  // ...
  "cb-counter-depth": 2,
)
```

#let blocks = add-countblock(cb, "test", "This is a test", teal)
#let test = countblock.with("test", blocks)

#newpara()

=== countblock 的使用

定义好一个块之后，就可以使用 `countblock` 函数来创建它：
```typst
#countblock(
  name,
  cb,
  subname: "",
  count: true,
  lab: none
)[
  ...
]
```
参数说明如下
#three-line-table[
  | 参数 | 类型 | 默认值 | 说明 |
  | --- | --- | --- | --- |
  | `name` | `str` | `` | 计数器的名称 |
  | `cb` | `dict` | `` | 计数器字典 |
  | `subname` | `str` | `` | 该条目的名称 |
  | `count` | `bool` | `true` | 是否计数 |
  | `lab` | `str` | `none` | 该条目的标签 |
]
- `name`是计数器的名称，也就是在 `add-countblock` 中显示指定的参数。
- `cb`是一个字典，其格式如@cb 所示。注意，你需要传含有该计数器的（最新的）`cb`，所以一定需要先更新`cb`，再传入。
- `subname`是会显示在计数器后的信息，例如定理名称等。
- `count`是一个布尔值，如果你不想计数，可以将其设置为`false`。
- `lab`是一个字符串，如果你想要为这个块添加一个标签，以便在文中引用，可以使用这个参数。

例如，使用在 @new-cb 中创建的 `test`：
```typst
#countblock("test", blocks)[
  1 + 1 = 2
]
```
#test[
  1 + 1 = 2
]

当然也可以将其封装成另一个函数：
```typst
#let test = countblock.with("test", blocks)
```
然后使用`test`函数：
```typst
#test[
  1 + 1 = 2
]
```
#test[
  1 + 1 = 2
]

=== 总结

Scripst 通过 `add-countblock` 扩展字典，通过 `countblocks` 将整个字典一次性交给模板，再通过 `countblock` 创建具体的块。编号、重置和引用都由 Ratchet 统一管理。

#example(count: false)[

  综合示例：默认块使用深度 `3`，仅把 `remark` 从 `prop` 共享族中拆出并设为深度 `1`，再创建深度 `2` 的 `algorithm`。

  ```typst
  #let blocks = set-countblock-depth(cb, "rmk", 1, detach: true)
  #let blocks = add-countblock(blocks, "alg", "Algorithm", yellow, depth: 2)
  #let remark = countblock.with("rmk", blocks)
  #let algorithm = countblock.with("alg", blocks)

  #show: scripst.with(
    // ...
    countblocks: blocks,
    cb-counter-depth: 3,
  )
  ```
  把字典和封装函数放在 `#show: scripst.with(...)` 之前即可。
]

#newpara()

== 一些其他的块

=== 空白块

#blankblock[

  此外，Scripst还提供了这样的无标题的块，你可以自定义颜色来使用。这样的块的样式和 countblock 一致。

  ```typst
  #blankblock(color: color.red)[
    #h(-1em)这是一个红色的块。
  ]
  ```
  #blankblock(color: color.red)[
    #h(-1em)这是一个红色的块。
  ]
]


=== 证明与$qed$（证明结束）

```typst
#proof[
  这是一个证明。
]
```

#proof[

  这是一个证明。
]

这提供一个简单的证明环境，以及证毕符号。

=== 解答

```typst
#solution[
  这是一个解答。
]
```

#solution[

  这是一个解答。
]

这提供一个简单的解答环境。

=== 分隔符

```typst
#separator
```
可以使用`#separator`函数来插入一个分隔符。

#separator

#newpara()

== 其他格式调整

=== 数学公式相关

==== 引用编号

为数学公式调节了引用

$
  laplacian = pdv(, x, 2) + pdv(, y, 2) + pdv(, z, 2)
$<laplacian>

对 @laplacian 的引用，格式不再是 #["式 @laplacian"]<text.red> 而是括号的形式。


==== `cases` 环境下的数学公式

`typst`原本的`cases`环境在数学公式中使用时，所有公式会显示成行内公式的形式。这有时候会导致美观性的问题。

$
  u(x,t) = #math.cases(
    $sum_(i=1)^oo 4/(n pi) sin((n pi x)/L) e^(-((n pi)/L)^2 alpha t) "  "& 0<x<L$,
    $0 "  " &"otherwise"$,
    gap: 1em,
  )
$

`scripst`提供了一个新的`cases`环境，可以在数学公式中使用。它的用法与原本的`cases`环境相同，如下所示：

```typst
$
  u(x,t) = cases(
    gap: #1em,
    sum_(i=1)^oo 4/(n pi) sin((n pi x)/L) e^(-((n pi)/L)^2 alpha t) "  "& 0<x<L,
    0 "  " &"otherwise"
  )
$

```

$
  u(x,t) = cases(
    gap: #1em,
    sum_(i=1)^oo 4/(n pi) sin((n pi x)/L) e^(-((n pi)/L)^2 alpha t) "  " & 0<x<L,
    0 "  " & "otherwise"
  )
$

这是鉴于使用时，通常都需要展示比较详细的公式，所以在`cases`环境中，`scripst`默认会将所有的公式都显示成行间公式的形式。

#note[
  如果你还想使用原来的`math.cases`，可以使用
  ```typst
  $
    u(x,t) = #math.cases(
    $sum_(i=1)^oo 4/(n pi) sin((n pi x)/L) e^(-((n pi)/L)^2 alpha t) "  "& 0<x<L$,
    $0 "  " &"otherwise"$,
    gap: 1em
  )
  $
  ```
  来使用。
]
