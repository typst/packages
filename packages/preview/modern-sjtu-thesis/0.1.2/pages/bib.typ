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

  show: no-numbering-page-header.with(doctype: doctype)
  show: no-numbering-first-heading

  set bibliography(title: "参考文献", style: "gb-7714-2015-numeric", full: full)

  bibfunc

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}