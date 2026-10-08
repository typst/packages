// Front-matter page layout for abstract and acknowledgement pages.
// Supports both Chinese and English, with optional title and keywords (for abstracts).

#import "config.typ"

#let front-matter-page(
  heading-text: "",
  content: [],
  title: none,
  keywords: none,
  lang: "zh",
) = {
  let keywords-label = if lang == "zh" { "關鍵字：" } else { "Keywords: " }
  let keywords-sep = if lang == "zh" { "、" } else { ", " }

  page(numbering: "i")[
    #show heading.where(level: 1): it => {
      align(center, text(size: config.heading-size, weight: "bold", it.body))
      v(1.5em)
    }
    #heading(level: 1, numbering: none)[#heading-text]

    #set align(left)
    #set par(first-line-indent: 2em, leading: 1.5em, justify: true)
    #content

    #if keywords != none {
      v(2em)
      set par(first-line-indent: 0em)
      text(weight: "bold")[#keywords-label]
      keywords.join(keywords-sep)
    }
  ]
}
