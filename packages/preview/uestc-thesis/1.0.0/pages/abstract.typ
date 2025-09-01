#import "../utils/header.typ": header-content
#import "@preview/pointless-size:0.1.1": zh



#let abstract(abstract-cn:[], abstract-en:[], keywords:[], keywords-en:[]) = {

  set page(numbering: "I")
  counter(page).update(1)

  let format_abstract_cn = text.with(font: "Times New Roman", size: zh(-4), weight: "bold")
  let format_abstract_en = text.with(font: "Times New Roman", size: zh(-4), weight: "regular")

  // 中文摘要
  set page(
    header: header-content("摘要")
  )
  [
  #v(24pt, weak: false)
  #align(center)[
    #text(font: "SimHei", size: 15pt, weight: "bold")[摘　要]
  ]
  #v(18pt, weak: false)

  #par(first-line-indent: 2em, justify: true)[
    #abstract-cn
  ]

  #v(12pt)
  #align(left)[
    #text(font: "SimHei", weight: "bold")[关键词]：#text[#keywords]
  ]


  #pagebreak()
  #set page(
    header: header-content(text(font: "Times New Roman", size: zh(-3))[ABSTRACT])
  )
  #set par(first-line-indent: 2em, justify: true)
  #v(24pt, weak: false)
  // 英文摘要
  #align(center)[
    #text(font: "Times New Roman", size: zh(-4), weight: "bold")[ABSTRACT]
  ]
  #v(18pt, weak: false)

  #text(font: "Times New Roman", size: zh(-4))[#abstract-en]

  #v(12pt)
  #par(hanging-indent: 4em)[
    #format_abstract_en(weight: "bold")[Keywords]: #format_abstract_en[#keywords-en]
  ]

  ]


}