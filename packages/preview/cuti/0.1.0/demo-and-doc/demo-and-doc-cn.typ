#import "../lib.typ": *
#import "@preview/sourcerer:0.2.1": code

#set par(justify: true)

#show heading: show-cn-fakebold

= Cuti Demo & 中文文档

== 简介

Cuti 是利用 `text` 的 `stroke` 属性生成伪粗体的工具。该工具通常可用于为宋体、黑体、楷体等字体提供“粗体”。

Cuti 使用 0.02857em 作为 `stroke` 的参数。在 Microsoft Office 中，使用伪粗体会给字符添加一个 0.02857em 的描边。（实际上，精确值可能是 $1/35$。）


#line(length: 100%)

== 光速上手

在文档顶端加入

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  #import "@preview/cuti:0.1.0": show-cn-fakebold
  #show text: show-cn-fakebold
  #show strong: show-cn-fakebold
  ```
)

宋体、黑体、楷体的加粗就工作了。

#line(length: 100%)

== fakebold

不带其他参数的 `#fakebold[]` 会为字符添加#fakebold[伪粗体]效果。

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  Fakebold: #fakebold[#lorem(5)] \
  Bold: #text(weight: "bold", lorem(5)) \ 
  Bold + Fakebold: #fakebold[#text(weight: "bold", lorem(5))] \ 
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  Fakebold: #fakebold[#lorem(5)] \
  Bold: #text(weight: "bold", lorem(5)) \
  Bold + Fakebold: #fakebold[#text(weight: "bold", lorem(5))]
]

`#fakebold[]` 有一个 `base-weight` 参数，可以用于指定基于什么字重描边。 默认情况或 `base-weight: none` 时，基准字重会从上文继承。

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  Bold + Fakebold: #fakebold(base-weight: "bold")[#lorem(5)] \
  #set text(weight: "bold")
  Bold + Fakebold: #fakebold[#lorem(5)]
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  Bold + Fakebold: #fakebold(base-weight: "bold")[#lorem(5)] \
  #set text(weight: "bold")
  Bold + Fakebold: #fakebold[#lorem(5)]
]

#line(length: 100%)

== #regex-fakebold

`#regex-fakebold` 设计上是用于多语言、多字体情境的，可以根据参数 `reg-exp` 内的正则表达式只将匹配到的字符应用伪粗体格式。它也可以接受 `base-weight` 参数。

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  + RegExp `[a-o]`: #regex-fakebold(reg-exp: "[a-o]")[#lorem(5)]
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] \
  #set text(weight: "bold")
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。]
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  + RegExp `[a-o]`: #regex-fakebold(reg-exp: "[a-o]")[#lorem(5)] \
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] \
  #set text(weight: "bold")
  + RegExp `\p{script=Han}`: #regex-fakebold(reg-exp: "\p{script=Han}")[衬衫的价格是9磅15便士。] 
]

在上面的例子 \#3 中, `9` 和 `15` 是由字体提供的“真”粗体，而其他字符是用 `regular` 字重描边得到的伪粗体。

#line(length: 100%)

== show-fakebold

在多语言、多字体的场景中，不同的语言通常使用不同的字体，但是不是所有的字体都自带 `bold` 字重。需要 `strong` 或者 `bold` 效果时，每次都使用  `#fakebold`  `#regex-fakebold` 并不方便。所以，我们提供了用于设置 `show` 规则 `#show-fakebold` 函数。

`show-fakebold` 和 `regex-fakebold` 有着相同的参数。默认情况下 `show-fakebold` 使用 `"."` 作为正则表达式，也就是说所有字符带加粗或`strong`属性都会被伪粗体加粗（如果配置了相应的 `show` 规则）。

请注意：`show text` 规则和 `show strong` 规则需要分别配置。

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  #show text: show-fakebold
  Regular: #lorem(10) \
  #text(weight: "bold")[Bold: #lorem(10)]
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  #show text: show-fakebold
  Regular: #lorem(10) \
  #text(weight: "bold")[Bold: #lorem(10)]
]

正常情况下字体提供的加粗与伪粗体叠加的效果不是我们想要的。一般需要指定正则表达式、指定伪粗体的生效范围。

#code(
  numbering: true,
  radius: 0pt,
  text-style: (font: ("Courier New", "SimHei")),
  ```typst
  #show strong: it => show-fakebold(reg-exp: "\p{script=Han}", it)
  Regular: 我正在使用 Typst 排版。 \
  Strong: *我正在使用 Typst 排版。*
  ```
)

#block(
  stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
  inset: 10pt,
)[
  #show strong: it => show-fakebold(reg-exp: "\p{script=Han}", it)
  Regular: 我正在使用 Typst 排版。 \
  Strong: *我正在使用 Typst 排版。*
]

`show-fakebold` 也接受 `base-weight` 参数。


#line(length: 100%)

== cn-fakebold & show-cn-fakebold

这两个都是为中文排版封装的。

- `cn-fakebold` 是 `regex-fakebold` 的封装，默认的正则范围是中文字符与常见标点符号。
- `show-cn-fakebold` 是 `show-fakebold` 的封装，默认的正则范围是中文字符与常见标点符号，使用方法见“光速上手”小节。

