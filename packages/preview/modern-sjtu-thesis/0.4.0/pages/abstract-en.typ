#import "../utils/style.typ": ziti, zihao

#let abstract-en-page(
  keywords: (),
  doctype: "master",
  twoside: false,
  info: (:),
  body,
) = {
  set text(font: ziti.songti, size: zihao.xiaosi)

  if doctype == "bachelor" {
    heading(level: 1)[#text(font: "Arial")[ABSTRACT]]
  } else {
    heading(level: 1)[Abstract]
  }

  set par(
    first-line-indent: if doctype == "bachelor" { 2em } else { 1.5em },
    leading: if doctype == "bachelor" { 11pt } else { 16pt },
    spacing: if doctype == "bachelor" { 11pt } else { 16pt },
  )

  body

  linebreak()
  linebreak()

  [*Key words: *#(("",)+ keywords.intersperse(", ")).sum()]

  set par(spacing: 16pt)

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}

