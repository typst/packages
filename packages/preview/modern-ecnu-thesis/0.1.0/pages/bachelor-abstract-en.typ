#import "../utils/custom-cuti.typ": fakebold
#import "../utils/style.typ": 字号, 字体
#import "../utils/indent.typ": fake-par
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/custom-heading.typ": heading-content

// 本科生英文摘要页
#let bachelor-abstract-en(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "Abstract",
  outlined: true,
  anonymous-info-keys: ("author-en", "supervisor-en", "supervisor-ii-en"),
  leading: 1.2em,
  spacing: 1.25em,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title-en: "NJU Thesis Template for Typst",
    author-en: "Zhang San",
    department-en: "XX Department",
    major-en: "XX Major",
    supervisor-en: "Professor Li Si",
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }

  // 3.  内置辅助函数
  let info-value(key, body) = {
    if (not anonymous or (key not in anonymous-info-keys)) {
      body
    }
  }

  set page(header: {
    heading-content(doctype: "bachelor", twoside: twoside, fonts: fonts)
  })

  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  let s = state("title-en")

  [
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true)
    // #show par: set block(spacing: spacing)

    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(font: fonts.黑体, size: 字号.小三, weight: "bold")
      Abstract
    ]

    #v(1em)

    #set text(font: fonts.宋体, size: 字号.五号)

    #[
      #set par(first-line-indent: 2em)
      #fake-par
      #body
    ]

    #v(2.5em)

    *Keywords: *#h(0.25em)#(("",) + keywords.intersperse(", ")).sum()
  ]
}