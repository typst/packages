// pages/abstract.typ
// Abstract-Seite — optional, eigene Seite, kein TOC-Eintrag
// api-design §8b: erscheint nach Deckblatt, vor TOC; Seitennummerierung Römisch
// Kein Heading im TOC — heading(outlined: false)

#import "@preview/linguify:0.5.0": linguify

/// Render the abstract page.
///
/// - content: Typst content (the abstract body)
/// - lang: "de" | "en"
#let render-abstract(content, lang) = {
  heading(level: 1, numbering: none, outlined: false)[#linguify("abstract-title")]

  v(1em)

  // 90% Seitenbreite, zentriert, linksbündig innerhalb (analog clean-hwr)
  align(center)[
    #block(width: 90%)[
      #align(left)[
        #set par(justify: true)
        #content
      ]
    ]
  ]

  pagebreak()
}
