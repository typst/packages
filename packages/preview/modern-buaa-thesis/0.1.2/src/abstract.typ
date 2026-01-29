#import "@preview/cuti:0.3.0": show-cn-fakebold

#import "constant.typ": font-size, font-type
#import "utils.typ": distr

#let abstract(keyword: (), body) = {
  show: show-cn-fakebold

  [
    #set align(center)
    #set text(size: font-size.three, font: font-type.hei, lang: "cn")

    #v(0.5em)
    *#distr("摘要", 3em)*
    #v(0.5em)
  ]

  [
    #set align(center)
    #set text(size: font-size.five, font: font-type.hei, lang: "cn")

    #v(2.5pt)
    \
    #v(2.5pt)
  ]

  set par(
    first-line-indent: (amount: 2em, all: true),
    justify: true,
  )


  body

  [
    #set text(size: font-size.small-four, font: font-type.hei, lang: "cn")

    *关键词*：#keyword.join("，")
  ]
}

#let abstract-en(keyword: (), body) = {
  [
    #set align(center)
    #set text(size: font-size.three, font: font-type.hei, lang: "cn")
    #set par(leading: 1em, spacing: 1em)

    #v(0.5em)
    *Abstract*
    #v(0.5em)
  ]

  [
    #set align(center)
    #set text(size: font-size.five, font: font-type.hei, lang: "cn")

    #v(2.5pt)
    \
    #v(2.5pt)
  ]

  set par(
    first-line-indent: (amount: 2em, all: true),
    justify: true,
  )
  show par: it => {
    v(2.5pt)
    it
    v(2.5pt)
  }

  body

  [
    #set text(size: font-size.small-four, font: font-type.hei, lang: "cn")

    *Keywords*: #keyword.join(", ")
  ]
}
