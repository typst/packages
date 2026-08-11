#import "@preview/i-figured:0.2.4"
#import "@preview/theorion:0.4.0": *
#import "../utils/theoriom.typ": *
#import "@preview/equate:0.3.2": *
#import "../utils/style.typ": zihao, ziti
#import "../utils/header.typ": main-text-page-header
#import "../utils/heading.typ": main-text-first-heading, other-heading
#import "../utils/figurex.typ": preset

#let mainmatter(
  doctype: "master",
  twoside: false,
  enable-avoid-orphan-headings: false,
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
    enable-avoid-orphan-headings: enable-avoid-orphan-headings,
    auto-section-pagebreak-space: auto-section-pagebreak-space,
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

  // show math.equation: i-figured.show-equation.with(numbering: if doctype == "bachelor" { "(1-1)" } else { "(1.1)" })

  set math.equation(numbering: (..nums) => numbering(
    if doctype == "bachelor" { "(1-1a)" } else { "(1.1a)" },
    counter(heading).get().first(),
    ..nums,
  ))
  show: equate.with(breakable: true, sub-numbering: false)
  let equation-label(
    heading,
    equation,
  ) = [(#numbering("1", heading)#h(0em)#if doctype == "bachelor" [-] else [.]#equation)]
  let appendix-equation-label(
    heading,
    equation,
  ) = [(#numbering("A", heading)#h(0em)#if doctype == "bachelor" [-] else [.]#equation)]
  show ref: it => {
    if it.element == none {
      return it
    }
    let f = it.element.func()
    let h1 = query(heading.where().before(it.target)).last()
    if f == math.equation {
      let equation-location = query(it.target).first().location()
      let heading-index = counter(heading).at(equation-location).at(0)
      let equation-index = counter(math.equation).at(equation-location).at(0)
      link(
        it.target,
        it.element.supplement
          + [ ]
          + if h1.supplement == [附录] {
            appendix-equation-label(heading-index, equation-index)
          } else {
            equation-label(heading-index, equation-index)
          },
      )
    } else if it.element.supplement == [公式] {
      let equation-location = query(it.target).first().location()
      let heading-index = counter(heading).at(equation-location).at(0)
      let equation-index = counter(math.equation).at(equation-location).at(0) - 1
      link(
        it.target,
        it.element.supplement
          + [ ]
          + if h1.supplement == [附录] {
            appendix-equation-label(heading-index, equation-index)
          } else {
            equation-label(heading-index, equation-index)
          },
      )
    } else {
      it
    }
  }

  show math.equation: set text(font: ziti.math)
  set math.equation(number-align: end + bottom)

  show: show-theorion

  show cite: set text(font: "Times New Roman")
  show smartquote: set text(font: "Times New Roman")

  show raw: set text(font: ziti.dengkuan)

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
