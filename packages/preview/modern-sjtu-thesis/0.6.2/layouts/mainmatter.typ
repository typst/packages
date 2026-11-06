#import "@preview/i-figured:0.2.4"
#import "@preview/theorion:0.6.0": *
#import "../utils/theoriom.typ": *
#import "../utils/style.typ": zihao
#import "../utils/header.typ": main-text-page-header
#import "../utils/heading.typ": main-text-first-heading, other-heading
#import "../utils/figurex.typ": preset, show-subimages
#import "../utils/equationx.typ": equationx-ref, equationx

#let mainmatter(
  doctype: "master",
  twoside: false,
  enable-avoid-orphan-headings: false,
  auto-section-pagebreak-space: 15%,
  ziti: (:),
  body,
) = {
  set page(numbering: "1")
  counter(page).update(1)

  show: main-text-page-header.with(
    doctype: doctype,
    twoside: twoside,
    ziti: ziti,
  )
  show: main-text-first-heading.with(
    doctype: doctype,
    twoside: twoside,
    ziti: ziti,
  )
  show: other-heading.with(
    enable-avoid-orphan-headings: enable-avoid-orphan-headings,
    auto-section-pagebreak-space: auto-section-pagebreak-space,
    ziti: ziti,
  )

  show: preset

  show heading: i-figured.reset-counters.with(extra-kinds: (
    "image",
    "image-en",
    "table",
    "table-en",
    "algorithm",
    "algorithm-en",
  ))
  show figure: i-figured.show-figure.with(extra-prefixes: (image: "img:", algorithm: "algo:"), numbering: if doctype
    == "bachelor" { "1-1" } else { "1.1" })

  show: equationx.with(numbering: if doctype == "bachelor" { "(1-1)" } else { "(1.1)" })
  show ref: it => {
    if it.element == none {
      return it
    }
    let eq = equationx-ref(it, default-numbering: if doctype == "bachelor" { "(1-1)" } else { "(1.1)" })
    if eq != none {
      return eq
    }
    let f = it.element.func()
    if f == heading and it.element.level > 1 and it.element.supplement != [附录] {
      link(it.target, [第] + h(.3em) + it + [节])
    } else if f == heading and it.element.level == 1 and it.element.supplement == [附录] {
      let equation-location = query(it.target).first().location()
      let heading-index = counter(heading).at(equation-location).at(0)
      link(it.target, it.element.supplement + numbering("A", heading-index))
    } else {
      it
    }
  }

  show math.equation: set text(font: ziti.math)
  set math.equation(number-align: end + bottom)

  show: show-theorion

  show cite: set text(font: ziti.en-serif)
  show smartquote: set text(font: ziti.en-serif)

  show raw: set text(font: ziti.dengkuan)

  show: show-subimages.with(english-gap: true)

  context [
    #metadata(state("total-words-cjk").final()) <total-words>
    #metadata(state("total-characters").final()) <total-chars>
  ]

  body
}
