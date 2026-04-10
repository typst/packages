#import "../utils/style.typ": ziti, zihao
#import "../utils/header.typ": main-text-page-header
#import "../utils/heading.typ": main-text-first-heading, other-heading

#let mainmatter(
  doctype: "master",
  twoside: false,
  body,
) = {
  set page(numbering: "1")
  counter(page).update(1)

  show: main-text-page-header.with(
    doctype: doctype,
    twoside: twoside,
  )
  show: main-text-first-heading.with(twoside: twoside)
  show: other-heading

  body
}