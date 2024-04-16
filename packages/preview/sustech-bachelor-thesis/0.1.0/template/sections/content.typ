#import "@preview/ctheorems:1.1.2": *
#import "info.typ": isCN
#show: thmrules

#let indent = h(2em)
#let theorem = thmbox(
  "theorem",
  "定理",
)

#let define = thmbox(
  "definition",
  "定义",
)

#let prop = thmbox(
  "property",
  "性质",
)

#let notation = thmbox(
  "notation",
  "符号",
)

#let mapsto = $|->$

#let abstract = (
  [
    #lorem(100)
  ],
  [
    #lorem(10)
  ]
)

= Ch1. 测试

== 我的 test 1.1

= Ch2. 测试

== 我的 test 1.2
#lorem(20)@wang2010guide.

#lorem(20)@kopka2004guide.
=== 我的 test 1.3

#pagebreak()
#bibliography(
  "refer.bib",
  title: [References 参考文献],
  style: "gb-7714-2005-numeric",
)