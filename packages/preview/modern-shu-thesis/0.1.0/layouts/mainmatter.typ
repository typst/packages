#import "../style/font.typ": ziti, zihao
#import "../style/heading.typ": main-heading

#let mainmatter(
  doctype: "master",
  body,
) = {
  set page(numbering: "1")
  counter(page).update(1)
  show: main-heading
  // set page( margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3.18cm))
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 24pt-1em, spacing: 24pt-1em,justify: true)
  body
}