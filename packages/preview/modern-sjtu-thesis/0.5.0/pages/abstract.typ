#import "../utils/style.typ": ziti, zihao

#let abstract-page(
  keywords: (),
  twoside: false,
  info: (:),
  body,
) = {
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 16pt, spacing: 16pt)

  heading(level: 1)[摘#h(1em)要]

  body

  linebreak()
  linebreak()

  [*关键词：*#(("",)+ keywords.intersperse("，")).sum()]

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}

