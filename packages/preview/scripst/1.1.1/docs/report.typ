#import "@preview/scripst:1.1.1": *

#show: scripst.with(
  template: "report",
  title: [Scripst 的使用方法],
  info: [report样式],
  author: ("AnZrew",),
  time: datetime.today().display(),
  abstract: [Scripst 是一款简约易用的 Typst 语言模板，适用于日常文档、作业、笔记、论文等多种场景。],
  keywords: (
    "Scripst",
    "Typst",
    "模板",
  ),
  preface: [
    Typst 是一种简单的文档生成语言，它的语法类似于 Markdown 的轻量级标记，利用合适的 `set` 和 `show` 指令，可以高自由度地定制文档的样式。

    Scripst 是一款简约易用的 Typst 语言模板，适用于日常文档、作业、笔记、论文等多种场景。
  ],
  contents: true,
  content-depth: 3,
  matheq-depth: 2,
  lang: "zh",
)

#include "chap1.typ"

#separator

在引入模板后通过这样的方式创建一个`report`文件：

```typst
#show: scripst.with(
  template: "report",
  title: [Scripst 的使用方法],
  info: [这是文章的模板],
  author: ("作者1", "作者2", "作者3"),
  time: datetime.today().display(),
  abstract: [摘要],
  keywords: ("关键词1", "关键词2", "关键词3"),
  preface: [前言]
  contents: true,
  content-depth: 2,
  matheq-depth: 2,
  lang: "zh",
)
```

这些参数以及其含义见 @para 。

这样你就可以开始撰写你的文档了。

= 模板参数说明 <para>

Scripst 的模板提供了一些参数，用来定制文档的样式。

```typst
#let scripst(
  template: "book",  // str: ("article", "book", "report")
  title: "",            // str, content, none
  info: "",             // str, content, none
  author: (),           // str, content, array, none
  time: "",             // str, content, none
  abstract: none,       // str, content, none
  keywords: (),         // array
  preface: none,        // str, content, none
  font-size: 11pt,      // length
  contents: false,      // bool
  content-depth: 2,     // int
  matheq-depth: 2,      // int: (1, 2)
  lang: "zh",           // str: ("zh", "en", "fr", ...)
  body,
) = {
  ...
}
```

#newpara()

== tempalate

#figure(
  three-line-table[
    | 参数 | 类型 | 可选值 | 默认值 | 说明 |
    | --- | --- | --- | --- | --- |
    | template | `str` | `("article", "book", "report")` | `"article"` | 模板类型 |
  ],
  numbering: none,
)

#newpara()

目前 Scripst 提供了三种模板，分别是 article 、book 和 report 。

本模板采用 report 模板。

- article：适用于日常文档、作业、小型笔记、小型论文等
- book：适用于书籍、课程笔记等
- report：适用于实验报告、论文等

此外的字符串传入会导致`panic`：`"Unknown template!"`。

#include "chap2.typ"

#include "chap3.typ"

#include "chap4.typ"
