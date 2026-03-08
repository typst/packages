#import "../utils/utils.typ": ziti, zihao, i-figured

#let translation-en(
  title-en : [Thesis Title],
  authors-en : ("author1", "author2", "author3"),
  abstract-en : [#lorem(80)],
  keywords-en : [keywords1, keywords2, keywords3],
  it
) = {

  set text(font: "TeX Gyre Pagella")

  align(center)[
    #par(
      justify: false,
      text(24pt, fill: rgb("004b71"), title-en, weight: "bold")
    )

    #v(1em)

    #text(12pt,
      authors-en.enumerate()
      .map(((i, author-en)) => box[#author-en])
      .join("，")
    )

    #v(1em)

  ]

  set par(first-line-indent: 0em, leading: 1em)

  align(left)[
    #text(font: "TeX Gyre Pagella", weight: "bold")[Abstract:]#h(5pt)#abstract-en

    #text(font: "TeX Gyre Pagella", weight: "bold")[Keywords:]#h(5pt)#keywords-en
  ]

  v(1em)

  show: columns.with(1)
  counter(heading).update(0)

  set heading(outlined: false)
  show heading: it => {
    set par(first-line-indent: 0em) // 重置段落属性
    set text(font: "TeX Gyre Heros", fill: rgb("004b71"), size: 12pt)
    align(left)[
      #context counter(heading).display("1. ") #it.body
    ]
  }

  show figure: i-figured.show-figure.with(numbering: "1-1")
  show figure.where(kind: table): i-figured.show-figure.with(numbering: "1.1")

  set par(first-line-indent: 2em)

  it
}

#let translation-cn(
  title-cn : [论文标题],
  authors-cn : ("作者1", "作者2", "作者3"),
  abstract-cn : [#lorem(80)],
  keywords-cn : [关键词1, 关键词2, 关键词3],
  it
) = {
  align(center)[
    #par(
      justify: false,
      text(24pt, fill: rgb("004b71"), title-cn, weight: "bold")
    )

    #v(1em)

    #text(12pt,
      authors-cn.enumerate()
      .map(((i, author-cn)) => box[#author-cn])
      .join("，")
    )

    #v(1em)

  ]

  set par(first-line-indent: 0em)

  align(left)[
    #text(font: ziti.黑体, weight: "bold")[摘要：]#abstract-cn

    #text(font: ziti.黑体, weight: "bold")[关键词：]#keywords-cn
  ]

  v(1em)

  show: columns.with(1)
  counter(heading).update(0)

  set heading(outlined: false)
  show heading: it => {
    set par(first-line-indent: 0em) // 重置段落属性
    set text(font: ziti.黑体)
    align(left)[
      #context counter(heading).display("1. ") #it.body
    ]
  }

  show figure: i-figured.show-figure.with(numbering: "1-1")
  show figure.where(kind: table): i-figured.show-figure.with(numbering: "1.1")

  set par(first-line-indent: 2em)

  it
}

#let translation-bilingual(
  title : (
    CN: [Thesis Title],
    EN: [Thesis Title]
  ),
  authors : (
    CN: ("作者1", "作者2", "作者3"),
    EN: ("author1", "author2", "author3")
  ),
  abstract : (
    CN: [#lorem(80)],
    EN: [#lorem(80)]
  ),
  keywords : (
    CN: [关键词1, 关键词2, 关键词3],
    EN: [keywords1, keywords2, keywords3]
  ),
  content: (
    CN: [#lorem(80)],
    EN: [#lorem(80)],
  )
) = {

translation-en(
  title-en : title.EN,
  authors-en : authors.EN,
  abstract-en : abstract.EN,
  keywords-en : keywords.EN,
)[#content.EN]

pagebreak()

translation-cn(
  title-cn : title.CN,
  authors-cn : authors.CN,
  abstract-cn : abstract.CN,
  keywords-cn : keywords.CN,
)[#content.CN]
} 
