#import "../utils/header.typ": appendix-page-header
#import "../utils/heading.typ": appendix-first-heading
#import "@preview/i-figured:0.2.4"

#let appendix(
  doctype: "master",
  twoside: false,
  body,
) = {
  show: appendix-page-header.with(doctype: doctype, twoside: twoside)
  show: appendix-first-heading.with(doctype: doctype, twoside: twoside)

  show heading: i-figured.reset-counters.with(extra-kinds: ("image", "image-en", "table", "table-en", "algorithm"))
  show figure: i-figured.show-figure.with(
    extra-prefixes: (image: "img:", algorithm: "algo:"),
    numbering: if doctype == "bachelor" { "1-1" } else { "A.1" },
  )
  set figure(outlined: false)

  show math.equation: i-figured.show-equation.with(numbering: if doctype == "bachelor" { "(1-1)" } else { "(A.1)" })

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
    }
  }

  body
}
