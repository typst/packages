#import "@preview/scripst:1.1.1": *

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

`countblock` 环境中的计数器深度。默认为`2`。

如果改变了`countblock`计数器的默认深度，你在使用时候还需要指定改变了的深度，或者重新封装函数。详情见 @cb-counter 。

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

段落内间距。在中文文档中默认是`1em`。

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
  ],
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
  ],
]


== body

在使用 `#show: scripst.with(...)` 时，`body` 参数是不用手动传入的，typst 会自动将剩余的文档内容传入 `body` 参数。
