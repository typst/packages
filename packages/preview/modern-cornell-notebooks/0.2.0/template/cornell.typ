#import "../lib/lib.typ": *

#show: cornell-note.with(
  title: "康奈尔笔记",
  author: "aFei@CUAS",
  abstract: "线索 + 推导过程 + 思想",
  createtime: "2025-01-09",
  lang: "zh",
  bibliography-style: "ieee",
  preface: [
    这是一本具有个人风格的化工热力学复习笔记。主要包括基本公式怎么来的，而不包含公式怎么用的。这里涵盖了大量的推导，有志向做理论研究的同学或道友，应花费大量的时间抓住关键思想，琢磨公式的来龙去脉，为后续学业生涯钻研理论方面打好基础。

  ], 
  bibliography-file: bibliography("refs.bib"), 
)

= 介绍

#left-note[
  这是第一个侧边笔记。@aFeiNote
  
  侧边笔记的主要作用是提醒读者这一小节内容的线索是什么，帮助读者更好地理解笔记结构。

  第三段的测试文字。我看它有没有缩进。
]

这是一个简单的 Typst 笔记模板，用于记录笔记、学习、工作等内容

= 使用

直接新建一个 `.typ` 文件，然后在文件中打出 `typst`，代码片段会补全，然后按照提示填写即可@aFeiNote

= 公式

$
  (a + b)^2 = a^2 + 2a b + b^2
$

$a^2-b^2 = (a-b)(a+b)$

= 图片

// #figure(
//   image("../images/typst.png", width: 80%),
//   caption: "图片示例",
// )

= 代码


#figure(
  ```python
  def hello():
    print("Hello, Typst!")
  ```,

  caption: "代码示例",
)


#pagebreak()

= 自定义样式
#left-note[
  这是第三个侧边笔记
]

This is #highlight(fill: blue.C)[highlighted in blue]. This is #highlight(fill: yellow.C)[highlighted in yellow]. This is #highlight(fill: green.C)[highlighted in green]. This is #highlight(fill: red.C)[highlighted in red].

#brainstorming(lang: "en")[
  This is a brainstorming.
]

#left-note[
  这是第四个侧边笔记
]

#definition[
  This is a definition.
]

#left-note[
  这是第五个侧边笔记
]

#task[
  This is a task.
]

#question[
  This is a question.
]

#brainstorming(lang: "zh")[
  This is a brainstorming.
]

#left-note[
  这是第六个侧边笔记
]

#definition(lang: "zh")[
  This is a definition.
]

#sectionline
#left-note[
  这是第七个侧边笔记
]
#tipbox[
  contents
]

#markbox[
  contents
]

#sectionline
#left-note[
  这是第八个侧边笔记
]

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    [77],[77],[77],
    [77],[77],[77],
    [77],[77],[77],
  )
)

#bottom-note[
第二页的底部总结。 

底部总结的主要作用是帮助总结该章节主要用到的核心思想，核心公式，核心概念等。达到能只看底部总结就能由此完成本章右边主体区中所有公式的推导。

第三段的测试文字。
]
