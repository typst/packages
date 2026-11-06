#import "../utils/header.typ": no-numbering-page-header
#import "../utils/heading.typ": no-numbering-first-heading

#let acknowledgement-page(
  doctype: "master",
  twoside: false,
  anonymous: false,
  body,
) = {
  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )

  if anonymous {
    return
  }

  show: no-numbering-page-header.with(
    doctype: doctype,
    twoside: twoside,
    bachelor-ackn: if doctype == "bachelor" { true } else { false },
  )
  show: no-numbering-first-heading

  heading(level: 1)[致#h(if doctype == "bachelor" {1.5em} else {1em})谢]

  body

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
