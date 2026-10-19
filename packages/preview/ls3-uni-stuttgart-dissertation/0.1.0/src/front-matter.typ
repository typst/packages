// front-matter.typ
//
// Front-matter sections for the dissertation: abstracts, Danksagung,
// Erklärung, abbreviations, notation, table of contents, and the
// conditional lists of figures, tables, and listings.

#import "common.typ": fonts

// Localized strings.
#let _labels(language) = {
  if language == "german" {
    (
      contents: "Inhaltsverzeichnis",
      figures: "Abbildungsverzeichnis",
      tables: "Tabellenverzeichnis",
      listings: "Programmauflistung",
      abbreviations: "Abkürzungsverzeichnis",
      notation: "Symbolverzeichnis",
      danksagung: "Danksagung",
      lebenslauf: "Lebenslauf",
    )
  } else {
    (
      contents: "Contents",
      figures: "List of Figures",
      tables: "List of Tables",
      listings: "List of Listings",
      abbreviations: "Abbreviations",
      notation: "Notation",
      danksagung: "Acknowledgements",
      lebenslauf: "Curriculum Vitae",
    )
  }
}

// German summary of two to four pages, the Kurzzusammenfassung of
// Promotionsordnung § 2 (3). Headed "Zusammenfassung" as in most recent
// IWS Hefte.
#let abstract-de-section(body) = {
  heading(level: 1, numbering: none, outlined: true)[Zusammenfassung]
  body
}

// English summary of two to four pages.
#let abstract-en-section(body) = {
  heading(level: 1, numbering: none, outlined: true)[Abstract]
  body
}

// Acknowledgements.
#let danksagung-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.danksagung]
  body
}

// Declaration of independent authorship per Promotionsordnung § 6 (2).
// Always German: it addresses the faculty.
#let erklaerung-section() = {
  heading(level: 1, numbering: none, outlined: false)[Erklärung]
  [Ich erkläre hiermit, dass ich, abgesehen von den ausdrücklich bezeichneten Hilfsmitteln, die Dissertation selbständig verfasst habe.]
  v(2.5cm)
  grid(
    columns: (1fr, 1cm, 1fr),
    align: (center, center, center),
    [#line(length: 80%, stroke: 0.5pt) \ Ort, Datum],
    [],
    [#line(length: 80%, stroke: 0.5pt) \ Unterschrift],
  )
}

// Abbreviations chapter.
#let abbreviations-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.abbreviations]
  body
}

// Notation chapter.
#let notation-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.notation]
  body
}

// Table of contents. Level-1 entries sans bold without dotted leader,
// as in the IWS Hefte, deeper levels default.
#let toc(language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: false)[#labels.contents]

  show link: set text(fill: black)

  show outline.entry.where(level: 1): it => {
    v(1.5em, weak: true)
    link(
      it.element.location(),
      text(font: fonts.sans, weight: "bold")[
        #it.prefix() #it.element.body
        #h(1fr)
        #it.page()
      ],
    )
  }
  show outline.entry.where(level: 2): it => {
    v(0.55em, weak: true)
    it
  }
  show outline.entry.where(level: 3): it => {
    v(0.35em, weak: true)
    it
  }

  outline(title: none)
}

// List of figures. Emits nothing when the document has no image figures.
#let lof(language: "english") = context {
  if query(figure.where(kind: image)).len() == 0 { return }
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.figures]
  outline(title: none, target: figure.where(kind: image))
}

// List of tables. Emits nothing when the document has no table figures.
#let lot(language: "english") = context {
  if query(figure.where(kind: table)).len() == 0 { return }
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.tables]
  outline(title: none, target: figure.where(kind: table))
}

// List of listings. Emits nothing when the document has no raw figures.
#let lol(language: "english") = context {
  if query(figure.where(kind: raw)).len() == 0 { return }
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.listings]
  outline(title: none, target: figure.where(kind: raw))
}
