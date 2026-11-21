#import "@preview/thyme:0.1.0": *

#show: site.with(
  url: "https://example.org",
  title: "Ada Lovelace",
  description: "Analytical engine notes, formal systems, and symbolic computation.",
  author: "Ada Lovelace",
  stylesheets: (path("styles.css"),),
  src: path("site.typ"),
  wrap-main: false,
)

#file("pgp.txt", path("pgp.txt"))
#mount(path("contact.typ")) <contact>

// Markup that plain Typst content cannot express uses `html.elem`, which is Typst's
// own constructor. No wrapper and no parser.
#let role = tr(
  en: [Symbolic Computation · London],
  de: [Symbolische Berechnung · London],
)
#let intro = tr(
  en: [Designing mechanical notation and verifiable static documents without runtime dependencies.],
  de: [Entwurf mechanischer Notation und überprüfbarer statischer Dokumente ohne Laufzeitabhängigkeiten.],
)

#html.elem(
  "aside",
  attrs: (class: "note"),
  [A note written as plain Typst content.],
)

#html.elem("header", attrs: (class: "hero"), {
  html.elem("p", attrs: (class: "eyebrow"), role)
  html.h1("Ada Lovelace")
  html.p(intro)
  html.elem("nav", attrs: (class: "meta-links", "aria-label": "Links"), {
    link(<contact>)[contact]
    html.span(" ")
    link("pgp.txt")[pgp.txt]
    html.span(" ")
    link("sitemap.xml")[sitemap.xml]
  })
})

#html.elem("main", {
  html.elem("section", attrs: (id: "research"), {
    html.h2("01 Research")
    html.p[Bernoulli number recurrence schedules in $O(n^2)$ arithmetic operations.]
  })
})
