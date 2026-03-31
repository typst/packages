// pages/confidentiality.typ
// Sperrvermerk — drei Stufen: none (kein Aufruf), true (alles), chapters-struct
// CNT-20: Dem Deckblatt vorgeschaltet
// CNT-21: Keine Seitennummer, nicht in Zählung
// STR-01: Sperrvermerk außerhalb der Seitenzählung

#import "@preview/linguify:0.5.0": linguify

/// Render the confidentiality notice page.
///
/// Parameters:
/// - confidential: true | (chapters: (...), filename: "...") — never none (caller checks)
/// - company: str — automatically passed from top-level company: param
/// - title: str
/// - authors: array of (name, matrikel)
/// - date: str — already formatted
/// - lang: "de" | "en"
/// - city: str — city for signature field (default "Berlin")
/// - group-signature: bool — true = all authors sign (default), false = only first author signs
#let render-confidentiality(confidential, company, title, authors, date, lang, city: "Berlin", group-signature: true) = {
  // Keine Seitennummer, nicht in Zählung (CNT-21, STR-01, FMT-35)
  set page(numbering: none, footer: none, header: none)

  let author-names = authors.map(a => a.name).join(", ")

  align(center)[
    #v(2cm)
    #text(weight: "bold")[#title]
    #v(1cm)
    #text(style: "italic")[#author-names]
    #v(2.5cm)
    #text(weight: "bold", tracking: 3pt, size: 16pt)[#linguify("confidential-title")]
  ]

  v(1.5cm)

  if type(confidential) == bool and confidential == true {
    // Stufe 2: Gesamte Arbeit gesperrt
    linguify("confidential-text-all")
  } else {
    // Stufe 3: Konkrete Kapitel gesperrt
    let chapters-list = confidential.at("chapters", default: ())
    let filename = confidential.at("filename", default: none)

    linguify("confidential-intro-chapters")
    v(1em)

    // Tabelle der gesperrten Kapitel
    table(
      columns: (auto, 1fr),
      align: left,
      stroke: 0.5pt,
      ..chapters-list.map(ch => (
        ch.at("number", default: ""),
        ch.at("title", default: ""),
      )).flatten()
    )

    v(1em)

    if filename != none {
      linguify("confidential-short-version", args: (filename: filename))
    }
  }

  v(3cm)

  // Hinweis bei group-signature: false
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

  pagebreak()
}
