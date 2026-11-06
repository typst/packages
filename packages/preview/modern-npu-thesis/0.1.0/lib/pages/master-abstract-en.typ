#import "../utils/style.typ": 字体, 字号
#import "../utils/header.typ": header-render
#import "../layouts/preface.typ": (
  preface-heading-above, preface-heading-below, preface-heading-size, preface-heading-weight,
)

#let master-abstract-en(
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  keywords: (),
  outline-title: "Abstract",
  outlined: true,
  anonymous-info-keys: ("author-en", "supervisor-en", "supervisor-ii-en"),
  leading: 1.0em,
  spacing: 1.0em,
  funding: none,
  body,
) = {
  fonts = 字体 + fonts
  info = (
    (
      title-en: "NPU Thesis Template for Typst",
      author-en: "Zhang San",
      department-en: "XX School",
      major-en: "XX",
      supervisor-en: "Li Si",
    )
      + info
  )

  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }

  pagebreak(weak: true, to: if twoside { "odd" })


  [
    #set par(leading: leading, spacing: spacing, justify: true)

    // 英文摘要标题使用 Times New Roman，加粗，其他样式统一配置
    #show heading.where(level: 1): it => {
      set text(font: "Times New Roman", size: preface-heading-size, weight: "bold")
      set block(above: 0pt, below: preface-heading-below)
      align(center, it)
    }
    #v(preface-heading-above)
    #heading(level: 1, outlined: outlined, outline-title)

    #[
      #set text(font: "Times New Roman", size: 字号.小四)
      #set par(first-line-indent: (amount: 2em, all: true))
      #body
    ]

    #v(1.5em)
    #text(font: "Times New Roman", size: 字号.小四)[
      #strong[Key words:] #(("",) + keywords.intersperse("; ")).sum()
    ]

    #v(1fr)

    #if funding != none [
      #set par(leading: 1.4em)
      #text(font: "Times New Roman", size: 字号.五号)[#funding]
    ]
  ]
}
