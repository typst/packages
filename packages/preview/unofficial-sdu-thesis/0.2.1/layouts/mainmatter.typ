#import "../styles/fonts.typ": fonts, fontsize
#import "../styles/heading.typ": main-heading
#let mainmatter(
  doctype: "master",
  body,
) = {
  // set page(numbering: "1")
  set heading(numbering: "1.1")

  // 这很抽象，使用footer实现的页码标注...
  set page(footer: align(center)[#text(rgb("808080"))[#context counter(page).display("1")]])
  counter(page).update(1)
  show: main-heading
  set text(font: fonts.宋体, size: fontsize.小四)
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: 23pt - 1em,
    spacing: 23pt - 1em,
    justify: true,
  )
  body
}
