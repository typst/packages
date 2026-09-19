#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/invisible-heading.typ": invisible-heading

// 研究生英文摘要页
#let master-abstract-en(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fontset: "mac",
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "Abstract",
  outlined: false,
  title-above: 24pt,
  title-below: 18pt,
  abstract-title-weight: "regular",
  stroke-width: 0.5pt,
  info-value-align: center,
  info-inset: (x: 0pt, bottom: 0pt),
  info-key-width: 74pt,
  grid-inset: 0pt,
  column-gutter: 2pt,
  row-gutter: 10pt,
  anonymous-info-keys: ("author-en", "supervisors-en"),
  // 1.25 倍行距：Typst leading 是额外间隙，取 行距.正文，勿写 1.25em。
  leading: 行距.正文,
  // 段前段后 0 磅：段间距不含行距，取与 leading 等值使段间基线距与行内一致。
  spacing: 行距.正文,
  body,
) = {
  // 1.  默认参数
  fonts = get-fonts(fontset) + fonts
  info = (
    (
      title-en: "UCAS Thesis Template for Typst",
      author-en: "Zhang San",
      department-en: "XX Department",
      major-en: "XX Major",
      supervisors-en: (
        (name: "Si Li", title: "Professor", affiliation: "×× Institute, CAS"),
      ),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }

  // 3.  内置辅助函数
  let info-key(body) = {
    rect(inset: info-inset, stroke: none, text(
      font: fonts.楷体,
      size: 字号.四号,
      body,
    ))
  }

  let info-value(key, body) = {
    set align(info-value-align)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stroke-width + black),
      text(
        font: fonts.楷体,
        size: 字号.四号,
        bottom-edge: "descender",
        if (anonymous and (key in anonymous-info-keys)) {
          "█████"
        } else {
          body
        },
      ),
    )
  }

  // 4.  正式渲染
  // 起始三件套（P30）：先清样式（填充页干净），再换页，最后重申前言域样式。
  set page(numbering: none, foreground: none)
  pagebreak(weak: true, to: if twoside { "odd" })
  set page(
    numbering: "I",
    footer: none,
    foreground: preface-foreground(info: info, fonts: fonts),
  )

  [
    #set text(font: "Times New Roman", size: 字号.小四)
    #set par(leading: leading, justify: true)
    #set par(spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #v(title-above)

    // 标题单倍行距：作用域内覆盖页面级的 1.25 倍行距
    #[
      #set par(leading: 行距.单倍, spacing: 0pt)
      #align(center, text(
        size: 字号.四号,
        weight: abstract-title-weight,
        strong[Abstract],
      ))
    ]

    #v(title-below)

    #[#set text(font: "Times New Roman", size: 字号.小四)
      #show smartquote: set text(font: "Times New Roman")
      #set par(first-line-indent: (amount: 2em, all: true))

      #body
    ]

    // 关键词与摘要间空一行：一行高度 = 正文基线距 21.6pt
    #v(21.6pt)

    #[#set text(font: "Times New Roman", size: 字号.小四)
      #show smartquote: set text(font: "Times New Roman")
      #strong[Key Words]: #(keywords.intersperse(", ")).sum()
    ]
  ]

  // 结尾 reset（P30）：覆盖后续自定义组装顺序下可能出现的填充页；
  // 标准顺序下由下一部分起始 reset 覆盖，此处幂等、无副作用。
  set page(numbering: none, foreground: none)
}
