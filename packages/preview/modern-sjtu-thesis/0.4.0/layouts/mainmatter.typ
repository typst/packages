#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": ziti, zihao
#import "../utils/header.typ": main-text-page-header
#import "../utils/heading.typ": main-text-first-heading, other-heading
#import "../utils/figurex.typ": preset

#let mainmatter(
  doctype: "master",
  twoside: false,
  enable-auto-section-pagebreak: false,
  auto-section-pagebreak-space: 15%,
  body,
) = {
  set page(numbering: "1")
  counter(page).update(1)

  show: main-text-page-header.with(
    doctype: doctype,
    twoside: twoside,
  )
  show: main-text-first-heading.with(
    doctype: doctype,
    twoside: twoside,
  )
  show: other-heading.with(
    enable-auto-section-pagebreak: enable-auto-section-pagebreak,
    auto-section-pagebreak-space: auto-section-pagebreak-space,
  )

  show: preset

  show heading: i-figured.reset-counters.with(extra-kinds: ("image", "image-en", "table", "table-en", "algorithm"))
  show figure: i-figured.show-figure.with(
    extra-prefixes: (image: "img:", algorithm: "algo:"),
    numbering: if doctype == "bachelor" { "1-1" } else { "1.1" },
  )
  show math.equation: i-figured.show-equation.with(numbering: if doctype == "bachelor" { "(1-1)" } else { "(1.1)" })
  show math.equation: set text(
    font: (
      (name: "Noto Sans CJK SC", covers: regex("\p{script=Han}")),
      "Cambria Math",
    ),
  )
  set math.equation(number-align: end + bottom)

  show figure.where(kind: "subimage"): it => {
    if it.kind == "subimage" {
      let q = query(figure.where(outlined: true).before(it.location())).last()
      [
        #figure(
          it.body,
          caption: it.counter.display("(a)") + " " + it.caption.body,
          kind: it.kind + "_",
          supplement: it.supplement,
          outlined: it.outlined,
          numbering: "(a)",
          gap: 1em,
        )#label(str(q.label) + ":" + str(it.label))
      ]
    }
  }

  show figure.where(kind: "subimage-en"): it => {
    if it.kind == "subimage-en" {
      let q = query(figure.where(outlined: true).before(it.location())).last()
      [
        #figure(
          it.body,
          caption: if it.caption != none { it.counter.display("(a)") + " " + it.caption.body } else { none },
          kind: it.kind + "_",
          supplement: it.supplement,
          outlined: it.outlined,
          numbering: "(a)",
          gap: 1em,
        )
      ]
      v(0.5em)
    }
  }

  context [
    #metadata(state("total-words-cjk").final()) <total-words>
    #metadata(state("total-characters").final()) <total-chars>
  ]

  body
}
