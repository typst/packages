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
  set par(spacing: 21pt-1em, leading: 21pt-1em,justify: true)


  heading(level: 1)[摘#h(1em)要]
  body
  linebreak()
  linebreak()
  [*关键词*：#(("",)+ keywords.intersperse("；")).sum()]
  pagebreak(weak: true)

  heading(level: 1)[ABSTRACT]
  v(1em)
  body-en
  linebreak()
  linebreak()
  [*Keywords*：#(("",)+ keywords-en.intersperse("; ")).sum()]
  pagebreak(weak: true)
}

