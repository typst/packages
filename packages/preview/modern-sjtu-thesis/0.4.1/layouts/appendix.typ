#import "../utils/header.typ": appendix-page-header
#import "../utils/heading.typ": appendix-first-heading, other-heading
#import "@preview/i-figured:0.2.4"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/equate:0.3.2": equate

#let appendix(
  doctype: "master",
  twoside: false,
  body,
) = {
  show: appendix-page-header.with(doctype: doctype, twoside: twoside)
  show: appendix-first-heading.with(doctype: doctype, twoside: twoside)
  show: other-heading.with(appendix: true)

  show heading: i-figured.reset-counters.with(extra-kinds: ("image", "image-en", "table", "table-en", "algorithm"))
  show figure: i-figured.show-figure.with(
    extra-prefixes: (image: "img:", algorithm: "algo:"),
    numbering: if doctype == "bachelor" { "A1-1" } else { "A.1" },
  )
  set figure(outlined: false)

  // show math.equation: i-figured.show-equation.with(
  //   numbering: if doctype == "bachelor" { numbly("(A{1})", "(A{1}-{2})") } else { "(A.1)" },
  // )

  set math.equation(
    numbering: (..nums) => numbering(
      if doctype == "bachelor" { "(A-1a)" } else { "(A.1a)" },
      counter(heading).get().first(),
      ..nums,
    ),
  )
  show: equate.with(breakable: true, sub-numbering: false)
  let equation-label(
    heading,
    equation,
  ) = [(#numbering("A", heading)#h(0em)#if doctype == "bachelor" [-] else [.]#equation)]
  let mainmatter-equation-label(
    heading,
    equation,
  ) = [(#numbering("1", heading)#h(0em)#if doctype == "bachelor" [-] else [.]#equation)]
  show ref: it => {
    if it.element == none {
      return it
    }
    let f = it.element.func()
    let h1 = counter(heading.where(level: 1, supplement: [附录]).before(it.target)).get().first()
    let main-h1 = counter(heading.where(level: 1).before(it.target)).get().first()
    let h1-last = query(heading.where().before(it.target)).last()
    if f == math.equation {
      let equation-location = query(it.target).first().location()
      let heading-index = counter(heading).at(equation-location).at(0)
      let equation-index = counter(math.equation).at(equation-location).at(0)
      link(
        it.target,
        it.element.supplement
          + [ ]
          + if h1-last.supplement == [附录] {
            equation-label(heading-index, equation-index)
          } else {
            mainmatter-equation-label(heading-index, equation-index)
          },
      )
    } else if it.element.supplement == [公式] {
      let equation-location = query(it.target).first().location()
      let heading-index = counter(heading).at(equation-location).at(0)
      let equation-index = counter(math.equation).at(equation-location).at(0) - 1
      let eq = query(it.target).first().body.value
      link(
        it.target,
        it.element.supplement
          + [ ]
          + if h1-last.supplement == [附录] {
            equation-label(heading-index, equation-index)
          } else {
            mainmatter-equation-label(heading-index, equation-index)
          },
      )
    } else {
      it
    }
  }

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
