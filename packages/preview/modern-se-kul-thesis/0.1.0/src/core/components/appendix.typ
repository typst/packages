#let insert-appendices(appendices) = {
  set heading(numbering: "A.1", supplement: "Appendix")
  // let heading-number = "1.1.1."
  // let heading-spacing = context h(
  //   measure(heading-number).width - measure(heading-number).width,
  // )
  pagebreak(weak: true, to: "odd")
  page(
    footer: context [#align(center)[#(
      (here().page-numbering())(here().page())
    )]],
    header: none,
  )[
    #set align(center)
    #v(40%)
    #text(size: 2.5em, weight: "semibold")[Appendices]
  ]

  pagebreak(weak: true, to: "odd")

  // shoddy hack, but it works
  // show heading: it => {
  //   if it.level == 1 { it } else {
  //     let size = if it.level == 2 {
  //       1.1em
  //     } else { 1em }
  //     set text(size, weight: "bold")
  //     let first-number = numbering(it.numbering, counter(heading).get().first())
  //
  //     let heading-number = (first-number, ..counter(heading).get().slice(1))
  //       .map(str)
  //       .join(".")
  //     [#linebreak()#heading-number #heading-spacing #it.body#linebreak()]
  //   }
  // }
  set heading(numbering: "A.1")
  counter(heading).update(0)
  appendices
}

