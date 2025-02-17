#import "../style/font.typ": ziti, zihao
#import "../style/heading.typ": none-heading

#let abstract-page(
  keywords: (),
  keywords-en: (),
  body,
  body-en,
) = {
  show: none-heading
  set page(numbering: "I")
  counter(page).update(1)
  set text(font: ziti.songti, size: zihao.xiaosi)
  heading(level: 1)[摘#h(1em)要]
  v(-1em)
  set par(first-line-indent: 2em, spacing: 20pt, justify: false)

  body

  linebreak()
  linebreak()

  [*关键词*：#(("",)+ keywords.intersperse("；")).sum()]

  pagebreak(weak: true)

  heading(level: 1)[ABSTRACT]
  set par(first-line-indent: 2em, leading: 16pt, spacing: 20pt)

  body-en

  linebreak()
  linebreak()

  [*Keywords*：#(("",)+ keywords-en.intersperse("; ")).sum()]

  pagebreak(weak: true)
}

