// pages/declaration.typ
// Ehrenwörtliche Erklärung mit 2025 KI-Klausel (Pflicht §3.11)
// CNT-01–05: Pflichtinhalt inkl. KI-Passagen-Kennzeichnung und Verantwortungsübernahme
// STR-10: Immer letztes Element des Dokuments
// declaration-lang: folgt entweder doc-lang oder eigenem Override

#import "@preview/linguify:0.5.0": linguify, linguify-raw

/// Render the declaration of authorship page.
///
/// - authors: array of (name, matrikel)
/// - decl-lang: "de" | "en" — language for the declaration text
/// - lang: "de" | "en" — document language (for labels if different)
/// - city: str — city for the place/date field (default "Berlin")
/// - group-signature: bool — true = all authors sign (default), false = only first author signs
#let render-declaration(authors, decl-lang, lang, city: "Berlin", group-signature: true) = {
  // Force declaration language for this page only
  set text(lang: decl-lang)

  heading(level: 1, numbering: none, outlined: true)[#linguify("declaration-title")]

  v(1.5em)

  // Pflichttext §3.11 — aus l10n, mit Pluralisierung für Gruppen
  // linguify-raw returns the FTL string; eval() converts it to Typst content
  let decl-text = context eval(
    "[" + linguify-raw("declaration-text", args: (author-count: authors.len())) + "]"
  )
  set par(justify: true)
  decl-text

  v(3cm)

  // Hinweis bei group-signature: false — genau wie bei declaration-lang ein Klärungshinweis
  if not group-signature and authors.len() > 1 {
    block(
      fill: rgb("#fff3cd"),
      stroke: 0.5pt + rgb("#856404"),
      radius: 3pt,
      inset: 8pt,
      width: 100%,
    )[
      #set text(size: 10pt)
      #linguify("group-signature-note")
    ]
    v(1em)
  }

  // Unterschriften-Zeilen — eine pro Autor (oder nur einer bei group-signature: false)
  // Layout: Linie zuerst, Label darunter (klassisches Formularfeld-Format)
  // breakable: false prevents a single signature block from splitting across pages
  let sig-authors = if group-signature { authors } else { (authors.at(0),) }

  for a in sig-authors {
    let sig-path = a.at("signature", default: none)
    block(breakable: false)[
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 2em,
        [
          #v(1.5cm)
          #line(length: 100%)
          #city, #linguify("declaration-place-date")
        ],
        if sig-path != none {
          [
            #image(sig-path, height: 1.5cm)
            #line(length: 100%)
            #linguify("declaration-signature") — #a.name
          ]
        } else {
          [
            #v(1.5cm)
            #line(length: 100%)
            #linguify("declaration-signature") — #a.name
          ]
        },
      )
    ]
    v(1em)
  }
}
