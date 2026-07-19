#import "@preview/xyznote:0.4.0": *

#show: xyznote.with(
  title: "xyznote",
  author: "wardenxyz",
  abstract: "A simple typst note template",
  createtime: "2024-11-27",
  lang: "zh",
  bibliography-style: "ieee",
  preface: [
    #lorem(110)
  ], //注释这一行删除序页
  bibliography-file: bibliography("refs.bib"), //注释这一行删除参考文献页面
)

= 介绍

这是一个简单的 Typst 笔记模板 @xyznote，用于记录笔记、学习、工作等内容

= 公式

$
  (a + b)^2 = a^2 + 2a b + b^2
$

$a^2-b^2 = (a-b)(a+b)$

= 代码


#figure(
  ```python
  def hello():
    print("Hello, Typst!")
  ```,

  caption: "代码示例",
)

= 自定义样式

This is #highlight(fill: blue.C)[highlighted in blue]. This is #highlight(fill: yellow.C)[highlighted in yellow]. This is #highlight(fill: green.C)[highlighted in green]. This is #highlight(fill: red.C)[highlighted in red].

#sectionline

#brainstorming(lang: "en")[
  This is a brainstorming.
]

#definition[
  This is a definition.
]

#pagebreak()

#question[
  This is a question.
]

#task[
  This is a task.
]

#brainstorming(lang: "zh")[
  This is a brainstorming.
]

#definition(lang: "zh")[
  This is a definition.
]

#question(lang: "zh")[
  This is a question.
]

#task(lang: "zh")[
  This is a task.
]

#sectionline

#tipbox[
  contents
]

#markbox[
  contents
]

#sectionline

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    [77],[77],[77],
    [77],[77],[77],
    [77],[77],[77],
  )
)

= 鸣谢

本项目借用了以下三个项目的代码

https://github.com/a-kkiri/SimpleNote @SimpleNote

https://github.com/DVDTSB/dvdtyp @dvdtyp

https://github.com/gRox167/typst-assignment-template @typst-assignment-template

https://github.com/spidersouris/touying-unistra-pristine @touying-unistra-pristine
