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
  set par(spacing: 20pt - 1em, leading: 20pt - 1em, justify: true)
  body
  [*关键词*：#(("",)+ keywords.intersperse("；")).sum()]
  pagebreak(weak: true)

  heading(level: 1)[ABSTRACT]
  body-en
  [*Keywords*：#(("",)+ keywords-en.intersperse("; ")).sum()]
  pagebreak(weak: true)
}

