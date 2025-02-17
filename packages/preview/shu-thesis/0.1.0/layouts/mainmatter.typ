#import "../style/font.typ": ziti, zihao
#import "../style/heading.typ": main-heading

#let mainmatter(
  doctype: "master",
  body,
) = {
  set page(numbering: "1")
  counter(page).update(1)
  show: main-heading
  body
}