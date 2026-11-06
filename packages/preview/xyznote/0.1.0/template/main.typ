#import "@preview/xyznote:0.1.0": *

#show: note.with(
  title: "xyznote",
  author: "wardenxyz",
  abstract: "一个简单的 Typst 笔记模板",
  createtime: "2024-11-27",
  bibliography-file: "ref.bib",
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

```python
def hello():
  print("Hello, Typst!")
```

@aa

= 鸣谢

本项目借用了以下三个项目的代码

https://github.com/gRox167/typst-assignment-template @typst-assignment-template

https://github.com/DVDTSB/dvdtyp @dvdtyp

https://github.com/a-kkiri/SimpleNote @SimpleNote
