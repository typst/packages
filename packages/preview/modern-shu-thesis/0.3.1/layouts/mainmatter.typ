#import "../style/font.typ": ziti, zihao
#import "../style/heading.typ": main-heading

#let mainmatter(
  doctype: "master",
  body,
) = {
  set page(numbering: "1")
  counter(page).update(1)
  show: main-heading
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: 23pt - 1em,
    spacing: 23pt - 1em,
    justify: true,
  )
  body
}
