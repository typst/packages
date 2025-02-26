#import "@preview/xyznote:0.2.0": *

#show: xyznote.with(
  title: "xyznote",
  author: "wardenxyz",
  abstract: "A simple typst note template",
  createtime: "2024-11-27",
  lang: "zh",
  bibliography-style: "ieee",
  bibliography-file: bibliography("refs.bib"), //注释这一行删除参考文献页面
)

= 介绍

这是一个简单的 Typst 笔记模板 @xyznote，用于记录笔记、学习、工作等内容

= 使用

直接新建一个 `.typ` 文件，然后在文件中打出 `typst`，代码片段会补全，然后按照提示填写即可

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

= 鸣谢

本项目借用了以下三个项目的代码

https://github.com/a-kkiri/SimpleNote @SimpleNote

https://github.com/DVDTSB/dvdtyp @dvdtyp

https://github.com/gRox167/typst-assignment-template @typst-assignment-template

#sectionline

#tipbox[
  contents
]

#markbox[
  contents
]