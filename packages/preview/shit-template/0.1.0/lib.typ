#import "config/equation.typ": equation
#import "config/fonts.typ": fonts
#import "config/headingstyle.typ": headingstyle
#import "config/pagestyle.typ": pagestyle
#import "config/tables.typ": tables

#let ieee-paper(
  title: "",
  authors: (),
  affiliations: (),
  corres-name: "",
  corres-email: "",
  funding: "",
  abstract: [],
  keywords: [],
  impact: [],
  body
) = {
  show: pagestyle
  show: fonts

  //设置为中文文档
  set text(lang: "zh")

//论文标题
  align(center)[
    #v(-0.5em)
    #text(fill: rgb("#800080"), size: 24pt)[#title]
    #v(0.5em)
  ]

//作者及其单位信息
  align(center)[
    #set par(leading: 0.4em)
    
    #text(weight: "bold")[
      #authors.map(a => [
        #a.name #super[#a.marks]
      ]).join("，")
    ] 
    #v(-0.2em)
    在此填写作者的单位信息和资助信息 \
    #v(-0.3em)
  
    #[
      #set text(size: 9pt)
      #for affil in affiliations [
        #super[#affil.id] #affil.name \
      ]
      
      #v(-0.2em)
      通讯作者: #corres-name (e-mail: #corres-email) \
      #funding \
      本文包含补充材料
    ]
    #v(1.5em)
  ]

//段落标题
  pad(x: 0pt)[
    #set text(size: 9pt)
    #set par(leading: 1.15 * 0.6em, first-line-indent: 0pt)
    #text(fill: rgb("#800080"), weight: "bold")[ABSTRACT / 摘要]#abstract
    #v(1em)
    #text(fill: rgb("#800080"), weight: "bold")[INDEX TERMS / 关键词]#keywords
    #v(1em)
    #text(fill: rgb("#800080"), weight: "bold")[IMPACT STATEMENT / 影响声明]#impact
    #v(1em)
  ]

  show: equation
  show: headingstyle

  set par(leading: 0.6em, justify: true, first-line-indent: 2em)
  show figure.caption: set text(size: 8pt)

  show: doc => columns(2, gutter: 4.2mm, doc)

  show cite: it => super(text(fill: rgb("#c00100"))[#it])

  body

  [
    #show heading: it => align(center)[
      #v(0.2em)
      #text(size: 10pt, weight: "regular")[#smallcaps(it.body)] 
      #v(0.1em)
    ]
    #heading(numbering: none)[REFERENCES / 参考文献]
  ]
  [
    #set text(size: 9pt)

    #set par(
      leading: 0.4em,
      spacing: 0.6em,
      justify: true
    )

    #show regex("\\[[0-9]+\\]"): set text(fill: rgb("#c00100"))
    
    #bibliography("/template/refs.bib", style: "ieee", title: none, full: true)
  ]
}