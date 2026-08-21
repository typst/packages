#import "@preview/scripst:1.1.2": *

== title

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | title | `content`, `str`, `none` | `""` | 文档标题 |
  ],
  numbering: none,
)

#newpara()

文档的标题。（不为空时）会出现在文档的开头和页眉中。

== info

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | info | `content`, `str`, `none` | `""` | 文档信息 |
  ],
  numbering: none,
)

#newpara()

文档的信息。（不为空时）会出现在文档的开头和页眉中。可以作为文章的副标题或者补充信息。

== author

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | author | `str`, `content`, `array`, `none` | `()` | 文档作者 |
  ],
  numbering: none,
)

#newpara()

文档的作者。要传入`str`或者`content`的列表，或者直接的`str`或者`content`对象。

#note(count: false)[
  注意，如果是一个作者的情况，可以只传入`str`或者`content`，在多个作者的时候传入一个`str`或者`content`的列表，例如：`author: ("作者1", "作者2")`
]

会在文章的开头以 $min(\#"authors", 3)$ 个作为一行显示。

== time

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | time | `content`, `str`, `none` | `""` | 文档时间 |
  ],
  numbering: none,
)

#newpara()

文档的时间。会出现在文档的开头和页眉中。

你可以选择用 typst 提供的 `datetime` 来获取或者格式化时间，例如今天的时间：

```typst
datetime.today().display()
```
#newpara()

== abstract

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | abstract | `content`, `str`, `none` | `none` | 文档摘要 |
  ],
  numbering: none,
)

#newpara()

文档的摘要。（不为空时）会出现在文档的开头。

建议在使用摘要前，首先定义一个`content`，例如：

```typst
#let abstract = [
  这是一个简单的文档模板，用来生成简约的日常使用的文档，以满足文档、作业、笔记、论文等需求。
]

#show: scripst.with(
  ...
  abstract: abstract,
  ...
)
```
然后将其传入`abstract`参数。

== keywords

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | keywords | `array` | `()` | 文档关键词 |
  ],
  numbering: none,
)

#newpara()

文档的关键词。要传入`str`或者`content`的列表。

和`author`一样，参数是一个列表，而不能是一个字符串。

只有在`abstract`不为空时，关键词才会出现在文档的开头。

== font-size

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | font-size | `length` | `11pt` | 文档字体大小 |
  ],
  numbering: none,
)

#newpara()

文档的字体大小。默认为`11pt`。

参考`length`类型的值，可以传入`pt`、`mm`、`cm`、`in`、`em`等单位。

== contents

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | contents | `bool` | `false` | 是否生成目录 |
  ],
  numbering: none,
)

#newpara()

是否生成目录。默认为`false`。

== content-depth

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | content-depth | `int` | `2` | 目录的深度 |
  ],
  numbering: none,
)

#newpara()

目录的深度。默认为`2`。

== matheq-depth

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | matheq-depth | `int` | `1`, `2`, `3` | `2` | 数学公式的深度 |
  ],
  numbering: none,
)

#newpara()

数学公式编号的深度。默认为`2`。

#note(count: false)[ 计数器的详细表现见 @counter 。 ]

#newpara()

== counter-depth <counter>

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | counter-depth | `int` | `1`, `2`, `3` | `2` | 计数器的深度 |
  ],
  numbering: none,
)

#newpara()

文中`figure`环境中的图片`image`，表格`table`，以及代码`raw`的计数器深度。默认为`2`。

#note(count: false, subname: [计数器的详细表现])[

  一个计数器的深度为`1`时，计数器的编号会是全局的，不会受到章节的影响，即`1`, `2`, `3`, ...。

  一个计数器的深度为`2`时，计数器的编号会受到一级标题的影响，即`1.1`, `1.2`, `2.1`, `2.2`, ...。但如果此时整个文档没有一级标题，Scripst 会自动将其转化为深度为`1`的情况。

  一个计数器的深度为`3`时，计数器的编号会受到一级标题和二级标题的影响，即`1.1.1`, `1.1.2`, `1.2.1`, `1.2.2`, `2.1.1`, ...。但如果此时整个文档没有二级标题但有一级标题，Scripst 会自动将其转化为深度为`2`的情况；如果没有一级标题，Scripst 会自动将其转化为深度为`1`的情况。
]
#newpara()

== cb-counter-depth

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | cb-counter-depth | `int`| `1`, `2`, `3` | `2` | `countblock` 的计数器深度 |
  ],
  numbering: none,
)

#newpara()

通过 `countblocks` 传入的 countblock 的默认编号深度，默认为 `2`。使用 `set-countblock-depth` 或 `add-countblock(depth: ...)` 指定的个别深度优先于该默认值。详情见 @cb-counter。

== countblocks

模板使用的 countblock 字典，默认为 `cb`。创建自定义 countblock 后，应当在 `#show: scripst.with(...)` 中通过该参数传入更新后的字典，以便 Ratchet 配置其编号和引用。

== matheq-outline

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | matheq-outline | `str`, `func` | `(1.1)`, `(A.1)`, ... | `(1.1)` | 数学公式的编号格式 |
  ],
  numbering: none,
)

#newpara()

公式编号的编号格式。默认为 `"(1.1)"`，即 `(1.1)`、`(1.2)`、`(2.1)`、`(2.2)` 等。

== counter-outline

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | counter-outline | `str`, `func` | `1.1`, `A.1`, ... | `1.1` | 计数器的编号格式 |
  ],
  numbering: none,
)

#newpara()

文中`figure`环境中的图片`image`，表格`table`，以及代码`raw`的编号格式。默认为`"1.1"`，即`1.1`、`1.2`、`2.1`、`2.2`等。

== matheq-color

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | matheq-color | `color` | `black`, `blue`, `red`, ... | `red` | 数学公式引用的颜色 |
  ],
  numbering: none,
)

#newpara()

数学公式引用的颜色。默认为`"red"`。

== counter-color

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | counter-color | `color` | `black`, `blue`, `red`, ... | `blue` | 计数器引用的颜色 |
  ],
  numbering: none,
)

#newpara()

计数器引用的颜色。默认为`"blue"`。

== link-color

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | link-color | `color` | `blue` | 超链接文字颜色 |
  ],
  numbering: none,
)

#newpara()

超链接文字的颜色。该设置不会改变 `matheq-color` 和 `counter-color` 分别指定的公式、图表及 countblock 引用颜色。

PDF 链接边框和鼠标悬浮反馈由 PDF 阅读器控制，Typst 目前不能可靠地自定义其外观。

== ref-color

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | ref-color | `color` | `red` | 普通 `@label` 引用的文字颜色 |
  ],
  numbering: none,
)

#newpara()

普通 `@label` 引用的颜色。公式引用仍由 `matheq-color` 控制，图表和 countblock 引用仍由 `counter-color` 控制。

== header

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | header | `bool` | `true` | 页眉 |
  ],
  numbering: none,
)

#newpara()

是否生成页眉。默认为`true`。

#note(count: false)[

  页眉包括文档的题目、信息和当前所在的章节标题。
  - 如果三者都存在，则将会三等分地显示在页眉中。
  - 如果文档没有信息，页眉仅会在最左最右显示文档的题目和当前所在的章节标题。
    - 进而如果文档没有题目，页眉仅会在最右侧显示当前所在的章节标题。
  - 如果文档没有任何一级标题，页眉将仅在最左最右显示文档的题目和信息。
    - 进而如果文档没有信息，页眉仅会在最左侧显示文档的题目。
  - 如果什么都没有，页眉将不会显示。
]

#newpara()

== lang

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | lang | `str` | `"zh"` | 文档语言 |
  ],
  numbering: none,
)

#newpara()

文档的语言，默认为`"zh"`。

接受#link("https://en.wikipedia.org/wiki/ISO_639-1")[ISO_639-1]编码格式传入，如`"zh"`、`"en"`、`"fr"`等。

== par-indent

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | par-indent | `length` | `2em` | 段落首行缩进 |
  ],
  numbering: none,
)

#newpara()

段落首行缩进。默认为`2em`。如果调节成`0em`，则为不缩进。

== par-leading

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | par-leading | `length` | 跟随`lang`设置 | 段落内的行间距 |
  ],
  numbering: none,
)

#newpara()

段落内间距。在中文文档中默认是`1em`。（中文文档可以设置为`0.5em`附近来接近 LaTeX 的默认效果。）

#note(count: false)[
  默认值会随着语言的选择而变化，具体情况见下表
  #three-line-table[
    | 语言类型 | 默认值 |
    | --- | --- |
    | 东亚文字（汉语、韩语、日语等） | 1em |
    | 南亚、东南亚、阿姆哈拉文字（泰语、越南语、缅甸语、印地语、阿姆哈拉语等） | 0.85em |
    | 阿拉伯文字（阿拉伯语、波斯语等） | 0.75em |
    | 斯拉夫文字（俄语、保加利亚语等） | 0.7em |
    | 其他文字 | 0.6em |
  ]
]

== par-spacing

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | par-spacing | `length` | 跟随`lang`设置 | 段落间距 |
  ],
  numbering: none,
)

#newpara()

段落间距。在中文文档中默认是`1.2em`。

#note(count: false)[
  默认值会随着语言的选择而变化，具体情况见下表
  #three-line-table[
    | 语言类型 | 默认值 |
    | --- | --- |
    | 东亚文字（汉语、韩语、日语等） | 1.2em |
    | 南亚、东南亚、阿姆哈拉文字（泰语、越南语、缅甸语、印地语、阿姆哈拉语等） | 1.3em |
    | 阿拉伯文字（阿拉伯语、波斯语等） | 1.25em |
    | 斯拉夫文字（俄语、保加利亚语等） | 1.2em |
    | 其他文字 | 1em |
  ]
]

== numbering-format

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | numbering-format | `str`, `function`, `none` | `"1.1"` | 章节标题的编号格式 |
  ],
  numbering: none,
)
#newpara()

章节标题的编号格式。默认为`"1.1"`，即`1.1`、`2.1`、`3.1`等。

你可以传入一个函数来实现自定义的编号格式，例如：

```typst
#let custom-numbering = (n, ..it) => "Chapter " + str(n) + " " + numbering("1.1", ..it)
```

#note[
  - 如果传入字符串，则会以其为pattern来格式化章节标题的编号，并且根据 `offset` 设置标题编号的偏移。
  - 如果传入函数，则会忽略掉 `offset` 的设置，一切按照函数的逻辑来进行编号。
]

== chapter-numbering-format

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | chapter-numbering-format | `str`, `function`, `none` | 根据语言而定 | 章节标题的编号格式 |
  ],
  numbering: none,
)

#note[
  目前 typst 如下的bug，当你以字符串的形式传入 `chapter-numbering-format` 时，如果字符串内含`"i"`，typst 会自动匹配当成罗马数字的格式来处理，例如`"i"`、`"ii"`、`"iii"`等。这个问题无法通过转义来解决。

  所以当你需要传入含有 `i` 的pattern时，建议使用函数的方式来传入，例如：
  ```typst
  #let custom-numbering = (n, ..it) => "Unit " + str(n)
  ```
  这样就可以避免 typst 的 bug 了。
]

#newpara()

== offset

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | offset | `int` | `0` | 章节标题的偏移 |
  ],
  numbering: none,
)
#newpara()

章节标题的偏移。默认为`0`。文档内的第一节会以 `1 + offset` 开始编号。所以 `offset` 的最小值为`-1`， 此时文档的第一节的编号是`0`。

== body

在使用 `#show: scripst.with(...)` 时，`body` 参数是不用手动传入的，typst 会自动将剩余的文档内容传入 `body` 参数。
