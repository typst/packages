// ============================================================
// Konfigurierbare Vorlage für wissenschaftliche Arbeiten
// ============================================================

#let dhbw-template(
  // ----------------------------------------------------------
  // Metadaten
  // ----------------------------------------------------------
  meta: (
    art-der-arbeit: "Bachelorarbeit",
    titel-der-arbeit: "",
    titel-zeile1: [],
    titel-zeile2: [],
    autor-der-arbeit: "",
    anschrift-zeile1: "",
    anschrift-zeile2: "",
    abteilung: "",
    firma: "",
    kurs: "",
    studienrichtung: "Digital Business Management",
    matrikelnummer: "",
    studiengangsleiter: "",
    wiss-betreuer: "",
    firmen-betreuer: "",
    abgabedatum: "",
  ),

  // ----------------------------------------------------------
  // Allgemeines Seitenlayout
  // ----------------------------------------------------------
  paper: "a4",

  page-margin: (
    left: 3cm,
    right: 4cm,
    top: 2.5cm,
    bottom: 2.5cm,
  ),

  page-number-align: right + bottom,

  // ----------------------------------------------------------
  // Standardschrift und Absatzformatierung
  // ----------------------------------------------------------
  language: "de",

  font: (
    "Times New Roman",
    "Libertinus Serif",
  ),

  font-size: 12pt,
  text-hyphenate: true,

  paragraph-justify: true,
  paragraph-leading: 0.82em,
  paragraph-spacing: 1em,

  // ----------------------------------------------------------
  // Überschriften
  // ----------------------------------------------------------
  heading-numbering: "1.1",
  heading-align: left,
  heading-below: 1em,

  // ----------------------------------------------------------
  // Inhaltsverzeichnis
  // ----------------------------------------------------------
  show-table-of-contents: true,
  table-of-contents-title: [Inhaltsverzeichnis],

  outline-level-one-bold: true,
  outline-level-one-spacing: 0.6em,

  // ----------------------------------------------------------
  // Abbildungsverzeichnis
  // ----------------------------------------------------------
  show-figure-outline: true,
  figure-outline-title: [Abbildungsverzeichnis],

  // ----------------------------------------------------------
  // Fußnoten
  // ----------------------------------------------------------
  footnote-font-size: 10pt,
  footnote-leading: 0.65em,
  footnote-spacing: 0.35em,
  footnote-indent: 1.2em,

  // ----------------------------------------------------------
  // Titelblatt
  // ----------------------------------------------------------
  company-logo: none,
  university-logo: none,

  institution-name: [
    Duale Hochschule Baden-Württemberg Mannheim
  ],

  faculty-name: [
    Fakultät Wirtschaft
  ],

  study-prefix: [Studienrichtung BWL –],

  institution-font-size: 14pt,
  work-type-font-size: 14pt,

  title-width: 14cm,
  title-font-size: 11.8pt,
  title-box-inset: 8mm,
  title-box-stroke: 0.6pt + black,

  title-data-font-size: 11pt,
  title-data-label-width: 6.2cm,
  title-data-column-gutter: 0.8cm,
  title-data-row-gutter: 3mm,

  // ----------------------------------------------------------
  // Optionale Bestandteile
  // ----------------------------------------------------------
  nondisclosure: none,
  nondisclosure-title: [Sperrvermerk],

  acronyms: (),
  acronyms-title: [Abkürzungsverzeichnis],
  acronym-column-width: 3.6cm,
  acronym-column-gutter: 1cm,
  acronym-row-gutter: 0.45em,
  acronym-font-size: 10pt,

  gender-notice: none,
  gender-notice-title: [Gender-Hinweis],

  appendix: none,
  appendix-title: [Anhang],
  appendix-numbering: "A.1",

  // ----------------------------------------------------------
  // Literaturverzeichnis
  // ----------------------------------------------------------
  bibliography-content: none,
  bibliography-title: [Literaturverzeichnis],

  bibliography-font-size: 10pt,
  bibliography-justify: false,
  bibliography-leading: 0.8em,
  bibliography-spacing: 1.2em,
  bibliography-hanging-indent: 1.8cm,

  // ----------------------------------------------------------
  // Ehrenwörtliche Erklärung
  // ----------------------------------------------------------
  show-declaration: true,
  declaration-title: [Ehrenwörtliche Erklärung],
  declaration-content: none,
  declaration-signature-height: 3cm,

  // ----------------------------------------------------------
  // Dokumentinhalt
  // ----------------------------------------------------------
  body,
) = {
  // ==========================================================
  // Globales Layout
  // ==========================================================

  set page(
    paper: paper,
    margin: page-margin,
    number-align: page-number-align,
  )

  set text(
    lang: language,
    font: font,
    size: font-size,
    hyphenate: text-hyphenate,
  )

  set par(
    justify: paragraph-justify,
    leading: paragraph-leading,
    spacing: paragraph-spacing,
  )

  set heading(numbering: heading-numbering)

  show heading: set align(heading-align)
  show heading: set block(below: heading-below)

  if outline-level-one-bold {
    show outline.entry.where(level: 1): set text(
      weight: "bold",
    )
  }

  show outline.entry.where(level: 1): set block(
    above: outline-level-one-spacing,
  )

  // ==========================================================
  // Fußnotenformatierung
  // ==========================================================

  show footnote.entry: entry => {
    set text(size: footnote-font-size)

    set par(
      justify: false,
      leading: footnote-leading,
      spacing: footnote-spacing,
    )

    pad(left: footnote-indent)[
      #h(-footnote-indent)
      #entry
    ]
  }

  // ==========================================================
  // Interne Hilfsfunktionen
  // ==========================================================

  let front-heading(title) = [
    #heading(
      level: 1,
      numbering: none,
      outlined: true,
      bookmarked: true,
    )[
      #title
    ]
  ]

  let title-box(line-one, line-two) = align(center)[
    #block(
      width: title-width,
      inset: (
        top: title-box-inset,
        bottom: title-box-inset,
      ),
      stroke: (
        top: title-box-stroke,
        bottom: title-box-stroke,
      ),
    )[
      #set par(
        justify: false,
        spacing: 0em,
        leading: 0.95em,
      )

      #set text(
        size: title-font-size,
        weight: "bold",
        hyphenate: false,
      )

      #align(center)[
        #box[#line-one]

        #if line-two != [] {
          linebreak()
          box(line-two)
        }
      ]
    ]
  ]

  // ==========================================================
  // Titelblatt
  // ==========================================================

  let titlepage = page(numbering: none)[
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0pt,

      align(left)[
        #if company-logo != none {
          company-logo
        }
      ],

      align(right)[
        #if university-logo != none {
          university-logo
        }
      ],
    )

    #v(2.5em)

    #align(center)[
      #set par(
        justify: false,
        spacing: 0em,
        leading: 0.8em,
      )

      #text(size: institution-font-size)[
        #institution-name \
        #faculty-name \
        #study-prefix #meta.studienrichtung
      ]

      #v(4em)

      #text(
        size: work-type-font-size,
        weight: "bold",
      )[
        #meta.art-der-arbeit
      ]
    ]

    #v(8mm)

    #title-box(
      meta.titel-zeile1,
      meta.titel-zeile2,
    )

    #v(7em)

    #set text(size: title-data-font-size)

    #set par(
      justify: false,
      spacing: 0em,
      leading: 0.8em,
    )

    #grid(
      columns: (title-data-label-width, 1fr),
      column-gutter: title-data-column-gutter,
      row-gutter: title-data-row-gutter,
      align: (left + top, left + top),

      [#text(weight: "semibold")[Eingereicht von:]],
      [
        #meta.autor-der-arbeit \
        #meta.anschrift-zeile1 \
        #meta.anschrift-zeile2
      ],

      [#text(weight: "semibold")[Matrikelnummer:]],
      [#meta.matrikelnummer],

      [#text(weight: "semibold")[Firma:]],
      [#meta.firma],

      [#text(weight: "semibold")[Abteilung:]],
      [#meta.abteilung],

      [#text(weight: "semibold")[Kurs:]],
      [#meta.kurs],

      [#text(weight: "semibold")[Studiengangsleiter:]],
      [#meta.studiengangsleiter],

      [#text(weight: "semibold")[Wissenschaftliche Betreuung:]],
      [#meta.wiss-betreuer],

      [#text(weight: "semibold")[Betriebliche Betreuung:]],
      [#meta.firmen-betreuer],

      [#text(weight: "semibold")[Abgabetermin:]],
      [#meta.abgabedatum],
    )
  ]

  // ==========================================================
  // Abkürzungsverzeichnis
  // ==========================================================

  let acronym-outline = [
    #front-heading(acronyms-title)
    #v(0.8em)

    #set text(size: acronym-font-size)

    #set par(
      justify: false,
      leading: 0.6em,
      spacing: 0em,
    )

    #grid(
      columns: (acronym-column-width, 1fr),
      column-gutter: acronym-column-gutter,
      row-gutter: acronym-row-gutter,
      align: (left + top, left + top),

      ..acronyms.map(item => (
        [#strong(item.at(0))],
        [#item.at(1)],
      )).flatten(),
    )
  ]

  // ==========================================================
  // Ehrenwörtliche Erklärung
  // ==========================================================

  let default-declaration = [
    Ich versichere hiermit, dass ich die vorliegende Arbeit
    mit dem Titel

    #v(0.3em)

    „#emph[#meta.titel-der-arbeit]“

    #v(0.3em)

    selbstständig verfasst und keine anderen als die angegebenen
    Quellen und Hilfsmittel benutzt habe. Ich versichere zudem,
    dass die eingereichte elektronische Fassung mit der
    gedruckten Fassung übereinstimmt.
  ]

  let declaration = [
    #front-heading(declaration-title)

    #if declaration-content == none {
      default-declaration
    } else {
      declaration-content
    }

    #v(declaration-signature-height)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 1cm,

      [
        #line(length: 100%)
        #v(0.2cm)
        Ort, Datum
      ],

      [
        #line(length: 100%)
        #v(0.2cm)
        #meta.autor-der-arbeit
      ],
    )
  ]

  // ==========================================================
  // Dokumentausgabe
  // ==========================================================

  // Titelblatt
  titlepage

  // ----------------------------------------------------------
  // Vorspann mit römischer Seitennummerierung
  // ----------------------------------------------------------

  set page(numbering: "I")
  counter(page).update(2)

  if nondisclosure != none {
    front-heading(nondisclosure-title)
    nondisclosure
    pagebreak()
  }

  if show-table-of-contents {
    outline(title: table-of-contents-title)
    pagebreak()
  }

  if acronyms.len() > 0 {
    acronym-outline
    pagebreak()
  }

  if show-figure-outline {
    front-heading(figure-outline-title)

    outline(
      title: none,
      target: figure.where(kind: image),
    )

    pagebreak()
  }

  if gender-notice != none {
    front-heading(gender-notice-title)
    gender-notice
    pagebreak()
  }

  // Position für die spätere Fortsetzung der römischen
  // Seitennummerierung speichern.
  [
    #metadata(()) <frontmatter-end>
  ]

  // ----------------------------------------------------------
  // Hauptteil mit arabischer Seitennummerierung
  // ----------------------------------------------------------

  set page(numbering: "1")
  counter(page).update(1)

  body

  // ----------------------------------------------------------
  // Textnachlauf mit fortgesetzter römischer Nummerierung
  // ----------------------------------------------------------

  pagebreak()
  set page(numbering: "I")

  context [
    #counter(page).update(
      counter(page).at(<frontmatter-end>).first() + 1
    )
  ]

  // ----------------------------------------------------------
  // Optionaler Anhang
  // ----------------------------------------------------------

  if appendix != none {
    front-heading(appendix-title)

    set heading(numbering: appendix-numbering)
    counter(heading).update((0, 0))

    appendix
    pagebreak()
  }

  // ----------------------------------------------------------
  // Literaturverzeichnis
  // ----------------------------------------------------------

  if bibliography-content != none {
    front-heading(bibliography-title)
    v(0.8em)

    show bibliography: set text(
      size: bibliography-font-size,
    )

    show bibliography: set par(
      justify: bibliography-justify,
      leading: bibliography-leading,
      spacing: bibliography-spacing,
      hanging-indent: bibliography-hanging-indent,
    )

    bibliography-content
    pagebreak()
  }

  // ----------------------------------------------------------
  // Ehrenwörtliche Erklärung
  // ----------------------------------------------------------

  if show-declaration {
    declaration
  }
}