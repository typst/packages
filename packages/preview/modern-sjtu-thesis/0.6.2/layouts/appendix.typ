#import "../utils/header.typ": appendix-page-header
#import "../utils/heading.typ": appendix-first-heading, other-heading
#import "@preview/i-figured:0.2.4"
#import "../utils/equationx.typ": equationx-ref, equationx
#import "../utils/figurex.typ": show-subimages

#let appendix(
  doctype: "master",
  twoside: false,
  ziti: (:),
  body,
) = {
  show: appendix-page-header.with(doctype: doctype, twoside: twoside, ziti: ziti)
  show: appendix-first-heading.with(doctype: doctype, twoside: twoside, ziti: ziti)
  show: other-heading.with(appendix: true, ziti: ziti)

  show heading: i-figured.reset-counters.with(extra-kinds: ("image", "image-en", "table", "table-en", "algorithm"))
  show figure: i-figured.show-figure.with(extra-prefixes: (image: "img:", algorithm: "algo:"), numbering: if doctype
    == "bachelor" { "A-1" } else { "A.1" })
  set figure(outlined: false)

  show: equationx.with(numbering: if doctype == "bachelor" { "(A-1)" } else { "(A.1)" })
  show ref: it => {
    if it.element == none {
      return it
    }
    let eq = equationx-ref(it, default-numbering: if doctype == "bachelor" { "(A-1)" } else { "(A.1)" })
    if eq != none {
      return eq
    }
    it
  }

  show: show-subimages

  body
}
