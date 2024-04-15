#import "@preview/ctheorems:1.1.2": *
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

= Ch1

= Ch2

#pagebreak()
#bibliography(
  "refer.bib",
  title: [参考文献],
  style: "gb-7714-2005-numeric",
)