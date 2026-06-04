#import "@preview/pinit:0.1.3": pin, pinit-place
#import "../utils/style.typ": 字号, 字体
#import "../utils/indent.typ": fake-par
#import "../utils/double-underline.typ": double-underline
#import "../utils/custom-tablex.typ": gridx, colspanx
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/custom-heading.typ": heading-content
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd

// 研究生英文摘要页
#let master-abstract-en(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "Abstract",
  outlined: true,
  abstract-title-weight: "regular",
  stoke-width: 0.5pt,
  info-value-align: center,
  info-inset: (x: 0pt, bottom: 0pt),
  info-key-width: 74pt,
  grid-inset: 0pt,
  column-gutter: 2pt,
  row-gutter: 10pt,
  anonymous-info-keys: ("author-en", "supervisor-en", "supervisor-ii-en"),
  leading: 1.5 * 15.6pt - 0.7em,
  spacing: 2.5em,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title-en: "ECNU Thesis Template for Typst",
    author-en: "Zhang San",
    department-en: "XX Department",
    major-en: "XX Major",
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }


  pagebreak-from-odd(twoside: twoside)

  set page(
    header: {
      heading-content(doctype: doctype, twoside: twoside, fonts: fonts)
    }
  )

  [
    #set par(leading: leading, justify: true)

    // #show par: set block(spacing: spacing)
    #set block(spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #set align(center)
    #block[
        #set text(font: fonts.黑体, size: 字号.小三, weight: "bold")
        Abstract
    ]



    #set align(left)



    #set text(font: fonts.宋体, size: 字号.小四)

    #body


    #block[
      *Keywords: * _#(("",) + keywords.intersperse(", ")).sum()_
    ]
  ]
}