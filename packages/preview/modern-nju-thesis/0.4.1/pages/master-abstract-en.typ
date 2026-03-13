#import "@preview/pinit:0.2.2": pin, pinit-place
#import "../utils/style.typ": 字号, 字体
#import "../utils/double-underline.typ": double-underline
#import "../utils/custom-tablex.typ": gridx, colspanx
#import "../utils/invisible-heading.typ": invisible-heading

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
  outline-title: "ABSTRACT",
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
  leading: 1.27em,
  spacing: 1.27em,
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
  let info-key(body) = {
    rect(
      inset: info-inset,
      stroke: none,
      text(font: fonts.楷体, size: 字号.四号, body),
    )
  }

  let info-value(key, body) = {
    set align(info-value-align)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stoke-width + black),
      text(
        font: fonts.楷体,
        size: 字号.四号,
        bottom-edge: "descender",
        if anonymous and (key in anonymous-info-keys) {
          "█████"
        } else {
          body
        },
      ),
    )
  }

  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  [
    
    #set par(leading: leading, spacing: spacing,justify: true)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(font: fonts.楷体,size: 字号.小二, weight: "bold")

      #v(8pt)

      #double-underline((if not anonymous { "南京大学" }) + "研究生毕业论文英文摘要首页用纸")

      #v(-5pt)
    ]

    #gridx(
      columns: (56pt, auto, auto, 1fr),
      inset: grid-inset,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      info-key[#pin("title-en")THESIS:], colspanx(3, info-value("", " ")),
      colspanx(4, info-value("", " ")),
      colspanx(3, info-key[SPECIALIZATION:]), info-value("major-en", info.major-en),
      colspanx(3, info-key[POSTGRADUATE:]), info-value("author-en", info.author-en),
      colspanx(2, info-key[MENTOR:]), colspanx(2, info-value("supervisor-en", info.supervisor-en + if info.supervisor-ii-en != "" { h(1em) + info.supervisor-ii-en })),
    )

    // 用了很 hack 的方法来实现不规则表格长标题换行...
    #pinit-place("title-en", {
      set text(font: fonts.楷体, size: 字号.四号)
      set par(leading: 1.3em)
      h(58pt) + (("",)+ info.title-en).intersperse(" ").sum()
    })

    #v(3pt)

    #align(center, text(font: fonts.黑体, size: 字号.小三, weight: abstract-title-weight, "ABSTRACT"))

    #v(-5pt)

    

    #[#set text(font: fonts.楷体, size: 字号.小四)
      #set par(first-line-indent: (amount: 2em, all: true))

      #body
    ]

    #v(10pt)

    #[#set text(font: fonts.楷体, size: 字号.小四)
      KEYWORDS: #(("",)+ keywords.intersperse("; ")).sum()
      ]
  ]
}