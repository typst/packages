#import "../utils/header.typ": no-numbering-page-header
#import "../utils/heading.typ": no-numbering-first-heading

#let bibliography-page(
  doctype: "master",
  twoside: false,
  bibfunc: none,
  full: true,
) = {
  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )

  show: no-numbering-page-header.with(
    doctype: doctype,
    bachelor-bib: if doctype == "bachelor" { true } else { false },
  )
  show: no-numbering-first-heading

  set bibliography(
    title: if doctype == "bachelor" { "参  考  文  献" } else { "参考文献" },
    style: "gb-7714-2015-numeric",
    full: full,
  )

  bibfunc

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
