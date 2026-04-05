#import "@preview/scripst:1.1.1": *

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
)

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
  &div vb(E) &=& rho / epsilon_0 \
  &div vb(B) &=& 0 \
  &curl vb(E) &=& -pdv(vb(B),t) \
  &curl vb(B) &=& mu_0 (vb(J) + epsilon_0 pdv(vb(E),t))
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

== countblock

#definition(subname: [countblock])[

  Countblock 是 Scripst 提供的一个计数器模块，用来对文档中的某些可以计数的内容进行计数。

  现在你看到的就是一个 `definition` 块，它是一个计数器模块的例子。
]

#newpara()

=== 默认提供的 countblock

Scripst 默认提供了一些计数器，你可以直接使用。分别是：

- 定义：`#definition`
- 定理：`#theorem`
- 命题：`#proposition`
- 引理：`#lamma`
- 推论：`#corollary`
- 评论：`#remark`
- 断言：`#claim`
- 练习：`#exercise`
- 问题：`#problem`
- 例子：`#example`
- 注记：`#note`
- 提醒：`#caution`

这些函数的参数和效果是一样的，只是计数器的名称不同。
```typst
#definition(
  subname: [],
  count: true,
  lab: none,
  cb-counter-depth: 2,
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
  | `cb-counter-depth` | `int` | `2` | 计数器的深度 |
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

==== `cb-counter-depth` 参数

对于该参数的详细解释见 @cb-counter。

=== `cb` 全局变量 <cb>

Scripst 通过全局变量 `cb` 记录着所有可以使用的计数器，以及全局的计数器深度 `cb-counter-depth`。

Scripst 中默认的`cb`是这样的：
```typst
#let cb = (
  "def": ("Definition", mycolor.green, "def"),
  "thm": ("Theorem", mycolor.blue, "thm"),
  "prop": ("Proposition", mycolor.violet, "prop"),
  "lem": ("Lemma", mycolor.violet-light, "prop"),
  "cor": ("Corollary", mycolor.violet-dark, "prop"),
  "rmk": ("Remark", mycolor.violet-darker, "prop"),
  "clm": ("Claim", mycolor.violet-deep, "prop"),
  "ex": ("Exercise", mycolor.purple, "ex"),
  "prob": ("Problem", mycolor.orange, "prob"),
  "eg": ("Example", mycolor.cyan, "eg"),
  "note": ("Note", mycolor.grey, "note"),
  "cau": ("⚠️", mycolor.red, "cau"),
  "cb-counter-depth": 2,
)
```

#newpara()

=== countblock 的新建与注册 <new-cb>

Scripst 提供了 `add-countblock` 函数来添加（或重载）一个计数器，以及 `reg-countblock` 函数来注册这个计数器。你可以通过在文档开头
```typst
#let cb = add-countblock(cb, "test", "This is a test", teal)
#show: reg-countblock.with("test")
```
来创建一个countblock。
#note[
  上面的代码意味着我们先更新了`cb`，再将其的计数器加入整个文档中。
]

#newpara()

==== 函数 `add-countblock`

函数 `add-countblock` 的参数如下
```typst
#add-countblock(cb, name, info, color, counter-name: none) {return cb}
```
参数说明如下
#three-line-table[
  | 参数 | 类型 | 默认值 | 说明 |
  | --- | --- | --- | --- |
  | `cb` | `dict` | `` | 计数器字典 |
  | `name` | `str` | `` | 计数器的名称 |
  | `info` | `str` | `` | 计数器的信息 |
  | `color` | `color` | `` | 计数器的颜色 |
  | `counter-name` | `str` | `none` | 计数器的编号 |
]
- `cb`是一个字典，其格式如@cb 所示。该函数的作用就是将`cb`更新，在使用时需要按照显示赋值。
  #note(count: false)[
    由于 typst 语言的函数不存在指针或引用，传入的变量不能修改，我们只能通过显式的返回值来修改变量。并且将其传入下一个函数。目前作者没有找到更好的方法。
  ]
- `name: (info, color, counter-name)`是一个计数器的基本信息。在渲染时，计数器的左上角会显示`info counter(counter-name)`例如`Theorem 1.1`作为该计数器的编号；颜色会是`color`颜色的。
- `counter-name`是计数器的编号，如果没有指定，那么会使用`name`作为编号。

==== 函数 `reg-countblock`

函数 `reg-countblock` 的参数如下
```typst
#show reg-countblock.with(name, cb-counter-depth: 2)
```
参数说明如下
#three-line-table[
  | 参数 | 类型 | 默认值 | 说明 |
  | --- | --- | --- | --- |
  | `counter-name` | `str` | `` | 计数器的编号 |
  | `cb-counter-depth` | `int` | `2` | 计数器的深度 |
]
- `counter-name`是计数器的编号，也就是在 `add-countblock` 中（未指定是`name`）显示指定的参数。例如默认提供的`clm`的计数器是`prop`。
- `cb-counter-depth`是你该计数器的深度，你可以指定为`1, 2, 3`。

#separator

此后你就可以使用 `countblock` 函数来使用这个计数器。

#let cb = add-countblock(cb, "test", "This is a test", teal)
#show: reg-countblock.with("test")

=== countblock 的计数器 <cb-counter>

前面并没有提到`cb-counter-depth`参数，在这一章我们详细讲解这个参数，以及其实现方式。

全局变量 `cb` 中的 `cb-counter-depth` 默认值是2。所以默认提供的 countblock 函数的计数器深度是2。

#note[
  如果你直接更改全局变量里的 `cb-counter-depth`，默认提供的计数器是不会改变的。这是因为在创建计数器时，会将原先的 `cb.at("cb-counter-depth")` 作为默认值传入。当更新 `cb` 时，原先的 `cb-counter-depth` 不会改变。所以你需要重新注册这个计数器。
]

计数器的逻辑与 @counter 的相同。

*如果你需要注册一个深度为3的计数器，你可以这样做：*
```typst
#let cb = add-countblock(cb, "test1", "This is a test1", green)
#show: reg-countblock.with("test1", cb-counter-depth: 3)
```
#let cb = add-countblock(cb, "test1", "This is a test1", green)
#show: reg-countblock.with("test1", cb-counter-depth: 3)

#newpara()

此外你可以通过`reg-default-countblock`函数来注册默认的计数器。例如你*希望所有的默认的计数器都是深度为3的*，你可以这样做：
```typst
#show: reg-default-countblock.with(cb-counter-depth: 3)
```
#show: reg-default-countblock.with(cb-counter-depth: 3)
当然，如果你仅仅这么做还不够，因为封装好的计数器还是以2为默认值。如果你直接调用
```typst
#definition[
  这是一个定义，请你理解它。
]
```
那么这个计数器的深度还是2。
#definition[
  这是一个定义，请你理解它。
]
所以你需要指定深度为3：
```typst
#definition(cb-counter-depth: 3)[
  这是一个定义，请你理解它。
]
```
#definition(cb-counter-depth: 3)[
  这是一个定义，请你理解它。
]
当然，你可以直接*进一步对其进行封装*：
```typst
#let definition = definition.with(cb-counter-depth: 3)
```
#let definition = definition.with(cb-counter-depth: 3)
之后再使用`definition`函数就会默认使用深度为3的计数器
```typst
#definition[
  这是一个定义，请你理解它。
]
```
#definition[
  这是一个定义，请你理解它。
]

#note[
  事实上，前文提到的 `cb-counter-depth` 参数就是在文档初始化的时候调用 `reg-default-countblock` 函数来设置的。
]

#newpara()

=== countblock 的使用

在定义并且注册一个块之后，就可以使用 `countblock` 函数来创建一个块：
```typst
#countblock(
  name,
  cb,
  cb-counter-depth: cb.at("cb-counter-depth"), // default: 2
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
  | `cb-counter-depth` | `int` | `cb.at("cb-counter-depth")` | 计数器的深度 |
  | `subname` | `str` | `` | 该条目的名称 |
  | `count` | `bool` | `true` | 是否计数 |
  | `lab` | `str` | `none` | 该条目的标签 |
]
- `name`是计数器的名称，也就是在 `add-countblock` 中显示指定的参数。
- `cb`是一个字典，其格式如@cb 所示。注意，你需要传含有该计数器的（最新的）`cb`，所以一定需要先更新`cb`，再传入。
- `cb-counter-depth`是你该计数器的深度，你可以指定为`1, 2, 3`。
- `subname`是会显示在计数器后的信息，例如定理名称等。
- `count`是一个布尔值，如果你不想计数，可以将其设置为`false`。
- `lab`是一个字符串，如果你想要为这个块添加一个标签，以便在文中引用，可以使用这个参数。

例如，我想使用我在 @new-cb 中创建的`test`计数器：
```typst
#countblock("test", cb)[
  1 + 1 = 2
]
```
#countblock("test", cb)[
  1 + 1 = 2
]

当然也可以将其封装成另一个函数：
```typst
#let test = countblock.with("test", cb)
```
然后使用`test`函数：
```typst
#test[
  1 + 1 = 2
]
```
#let test = countblock.with("test", cb)
#test[
  1 + 1 = 2
]

#newpara()

当然，对于在 @cb-counter 中注册的深度为3的`test1`计数器，我们需要在使用时指定深度：
```typst
#countblock("test1", cb, cb-counter-depth: 3)[
  1 + 1 = 2
]
#let test1 = countblock.with("test1", cb, cb-counter-depth: 3)
#test1[
  1 + 1 = 2
]
```
#countblock("test1", cb, cb-counter-depth: 3)[
  1 + 1 = 2
]
#let test1 = countblock.with("test1", cb, cb-counter-depth: 3)
#test1[
  1 + 1 = 2
]

=== 总结

Scripst 提供了一种简单的计数器模块，你可以通过 `add-countblock` 函数来添加一个计数器，通过 `reg-countblock` 函数来注册这个计数器，然后通过 `countblock` 函数来使用这个计数器。

对于默认的计数器，其深度为2，你可以通过 `reg-default-countblock` 函数来注册默认的计数器。

如果你希望所有 `countblock` 的深度为2，那么在你注册和使用的时候不必在意深度。

如果你希望所有 `countblock` 的深度为3，那么你需要在注册和使用的时候指定深度。

#example(count: false)[

  下面给出一个例子：使用者希望包括默认的所有 `countblock` 的计数器深度都是3，但希望 `remark` 与先前默认绑定的 `proposition`, `lemma`, `corollary`, `claim` 的计数器独立出来。再创建一个深度为 3 的 `algorithm` 计数器。

  ```typst
  #show: scripst.with(
    // ...
    cb-counter-depth: 3,
  )
  #let cb = add-countblock(cb, "rmk", "Remark", mycolor.violet-darker)
  #let cb = add-countblock(cb, "algorithm", "Algorithm", mycolor.yellow)
  #show: reg-countblock.with("rmk", cb-counter-depth: 3)
  #show: reg-countblock.with("algorithm", cb-counter-depth: 3)
  #let definition = definition.with(cb-counter-depth: 3)
  #let theorem = theorem.with(cb-counter-depth: 3)
  // ...
  #let remark = countblock.with("rmk", cb, cb-counter-depth: 3) // 这里需要重新封装是因为其计数器改变了
  #let algorithm = countblock.with("algorithm", cb, cb-counter-depth: 3)
  ```
  放在文档的开头，`#script` 之后即可。
]

#newpara()

== 一些其他的块

=== 空白块

#blankblock[

  此外，Scripst还提供了这样的无标题的块，你可以自定义颜色来使用。

  例如
  ```typst
  #blankblock(color: color.red)[
    这是一个红色的块。
  ]
  ```
  #blankblock(color: color.red)[
    这是一个红色的块。
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
