#import "@preview/pointless-size:0.1.2": zh as zh-size

#import "/src/fonts.typ"


#let _list-keywords(header, keywords, sep) = {
  show heading: set text(weight: "regular")
  show heading: it => box(it.body)
  linebreak()
  context {
    place(dy: -2.5pt, heading(header, numbering: none))
    let size = measure(heading(header, numbering: none))
    par(first-line-indent: size.width, sep + keywords)
  }
}

#let abstract(zh, en, title-en) = {
  show title: set align(center)
  show title: set text(font: fonts.sans, zh-size(-2))

  // 中文摘要页
  v(1em)
  title()
  heading(numbering: none)[摘要]
  zh.abstract
  _list-keywords([关键词], zh.keywords.join([，]), [：])
  pagebreak(weak: true)

  // 英文摘要页
  v(1em)
  set text(lang: "en", region: "us")
  title(title-en)
  heading(numbering: none)[Abstract]
  en.abstract
  _list-keywords([Keywords], en.keywords.join([, ]), [: ])
  pagebreak(weak: true)
}
