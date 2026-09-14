#import "../utils/header.typ": no-numbering-page-header
#import "../utils/heading.typ": no-numbering-first-heading
#import "../utils/bilingual-bibliography.typ": bilingual-bibliography
#import "../utils/style.typ": zihao

#let bibliography-page(
  doctype: "master",
  twoside: false,
  bibfunc: none,
  full: false,
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

  show bibliography: set text(size: zihao.wuhao)
  show bibliography: set par(leading: 1em, spacing: 1em)

  bilingual-bibliography(
    bibliography: bibfunc,
    title: if doctype == "bachelor" { "参  考  文  献" } else { "参考文献" },
    full: full,
  )

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
