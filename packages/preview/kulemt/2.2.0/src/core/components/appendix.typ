/// Appendices.
///
/// CHANGED: `to` is now a parameter, for the same reason as in
/// bibliography.typ -- 0.1.0 forced odd-page starts unconditionally, which
/// produces blank filler pages in a one-sided document.
/// -> content
#let insert-appendices(appendices, lang: "en", to: none) = {
  set heading(numbering: "A.1", supplement: "Appendix")

  pagebreak(weak: true, to: to)
  page(
    footer: context [
      #align(center)[#((here().page-numbering())(here().page()))]
    ],
    header: none,
  )[
    #set align(center)
    #v(40%)
    #text(size: 2.5em, weight: "semibold")[
      #if lang == "nl" { "Bijlagen" } else { "Appendices" }
    ]
  ]

  pagebreak(weak: true, to: to)

  set heading(numbering: "A.1")
  counter(heading).update(0)
  appendices
}
