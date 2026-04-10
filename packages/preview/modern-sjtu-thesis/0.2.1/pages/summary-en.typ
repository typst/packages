#import "../utils/header.typ": no-numbering-page-header
#import "../utils/heading.typ": no-numbering-first-heading

#let summary-en-page(
  doctype: "bachelor",
  title: "Summary",
  twoside: false,
  body,
) = {
  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )

  if doctype != "bachelor" {
    return
  }

  counter(page).update(1)


  show: no-numbering-page-header.with(
    doctype: doctype,
    bachelor-sum: true,
  )
  show: no-numbering-first-heading

  heading(title, outlined: false)

  body

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
