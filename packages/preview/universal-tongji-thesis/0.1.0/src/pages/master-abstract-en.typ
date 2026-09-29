#import "@preview/pinit:0.1.3": pin, pinit-place
#import "../utils/style.typ": 字号, 字体
#import "../utils/indent.typ": fake-par
#import "../utils/double-underline.typ": double-underline
#import "../utils/custom-tablex.typ": gridx, colspanx
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/custom-heading.typ": heading-content, header
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd
#import "../utils/zh-aio.typ":*

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
  // info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表

  pagebreak-from-odd(twoside: twoside)

  set page(header: header(title: "Abstract", font: 字体.新罗马))
  heading({
    set text(font: 字体.Arial, size: zh(3), weight: "bold")
    [
      #v(4pt)
      ABSTRACT
    ]
  }, numbering: none, outlined: false)
  v(2pt)
  let ls = 9.2pt
  set par(leading: ls, spacing: ls, justify: true, first-line-indent: (amount: 2em, all: true), linebreaks: "simple")
  [

    #set block(spacing: spacing)

    #set align(left)

    #set text(font: 字体.新罗马, size: zh(-4))
    #v(6pt)
    #body
    #v(18pt)
    #block[
      #h(2em)*Key Words: * #(("",) + keywords.intersperse(", ")).sum()
    ]
  ]
}