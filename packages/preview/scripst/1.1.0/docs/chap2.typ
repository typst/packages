#import "@preview/scripst:1.1.0": *

== title

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | title | `content`, `str`, `none`| `""` | 文档标题 |
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
    | info | `content`, `str`, `none`| `""` | 文档信息 |
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
    | author | `array`| `()` | 文档作者 |
  ],
  numbering: none,
)

#newpara()

文档的作者。要传入`str`或者`content`的列表。

#caution(count: false)[
  注意，如果是一个作者的情况，请不要传入`str`或者`content`，而是传入一个`str`或者`content`的列表，例如：`author: ("作者",)`
]

#newpara()

会在文章的开头以 $min(\#"authors", 3)$ 个作为一行显示。

== time

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | time | `content`, `str`, `none`| `""` | 文档时间 |
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
    | abstract | `content`, `str`, `none`| `none` | 文档摘要 |
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
    | keywords | `array`| `()` | 文档关键词 |
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
    | font-size | `length`| `11pt` | 文档字体大小 |
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
    | contents | `bool`| `false` | 是否生成目录 |
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
    | content-depth | `int`| `2` | 目录的深度 |
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
    | matheq-depth | `int`| `1`, `2` | `2` | 数学公式的深度 |
  ],
  numbering: none,
)

#newpara()

数学公式编号的深度。默认为`2`。

一般会在不分章节的情况下使用`1`，分章节的情况下使用`2`。

== lang

#figure(
  three-line-table[
    | 参数 | 类型 | 默认值 | 说明 |
    | --- | --- | --- | --- |
    | lang | `str`| `"zh"` | 文档语言 |
  ],
  numbering: none,
)

#newpara()

文档的语言，默认为`"zh"`。

接受#link("https://en.wikipedia.org/wiki/ISO_639-1")[ISO_639-1]编码格式传入，如`"zh"`、`"en"`、`"fr"`等。

== body

在使用 `#show: scripst.with(...)` 时，`body` 参数是不用手动传入的，typst 会自动将剩余的文档内容传入 `body` 参数。
