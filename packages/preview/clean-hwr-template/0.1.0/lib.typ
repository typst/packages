#let hwr(
  language: "en",
  main-font: "TeX Gyre Termes",

  // Main Metadata for the title page
  metadata: (
    title: [PTB Template],
    student_id: "",
    authors: (),
    company: "",
    enrollment_year: "",
    semester: "",
    company_supervisor: "",
    // These do not need to be changed by the user
    field_of_study: none,
    university: none,
    date_of_publication: none,
    uni-logo: none,
    company-logo: none,
  ),
  custom_entries: (),
  word_count: none,

  // Declaration of authorship
  custom_declaration_of_authorship: [],

  // Abstract content
  abstract: [#lorem(30)],

  // A note that is only relevant if you write a german paper
  note-gender-inclusive-language: (
    enabled: false,
    title: ""
  ),

  // All the lists and outlines
  glossary: (
    title: "",
    entries: ()
  ),
  acronyms: (
    title: "",
    entries: ()
  ),
  figure-index: (
    enabled: false,
    title: ""
  ),
  table-index: (
    enabled: false,
    title: ""
  ),
  listing-index: (
    enabled: false,
    title: ""
  ),

  // Bibliography settings
  bibliography-object: none,
  citation_style: "hwr_citation.csl",

  // The content of the appendix
  appendix: (
    enabled: false,
    title: "",
    content: []
  ),

  body,
) = {
  import "@preview/acrostiche:0.5.2": *

  set document(author: metadata.authors, title: metadata.title)
  set page(numbering: none, number-align: center)
  set text(font: main-font, lang: language)
  let sup = if language == "de" [Kapitel] else [Chapter]
  set heading(numbering: "1.1", supplement: sup)

  // SETUP Acronyms
  if acronyms.entries != () {
    init-acronyms(acronyms.entries)
  }

  // SETUP Title page
  let equal_spacing = 0.25fr
  set align(center)

  // Logo settings
  v(equal_spacing)
  if metadata.at("uni-logo", default: "template/images/header_logo.png") != none and metadata.at("company-logo", default: none) != none {
    grid(
      columns: (1fr, 1fr),
      rows: (auto),
      grid.cell(
        colspan: 1,
        align: center,
        image(metadata.at("uni-logo", default: "template/images/header_logo.png"), width: 70%),
      ),
      grid.cell(
        colspan: 1,
        align: center,
        image(metadata.company-logo, width: 70%),
      ),
    )
  } else if metadata.at("uni-logo", default: "template/images/header_logo.png") != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        image(metadata.at("uni-logo", default: "template/images/header_logo.png"), width: 46%)
      ),
    )
  } else if metadata.at("company-logo", default: none) != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        image(company-logo, width: 46%),
      )
    )
  }
  v(equal_spacing)

  // Title settings
  let line_length = 90%
  line(length: line_length)
  text(2em, weight: 700, metadata.title)
  line(length: line_length)

  // Author information.
  pad(
    top: 2.9em,
    text(
      1.3em,
      strong(metadata.authors.join(", "))
    )
  )

  // Middle section
  if language == "de" {
    text(1.1em, [vorgelegt am #metadata.at("date_of_publication", default: datetime.today().display())])
  } else {
    text(1.1em, [published on #metadata.at("date_of_publication", default: datetime.today().display())])
  }
  v(0.6em, weak: true)
  $circle.filled.small$
  v(0.6em, weak: true)
  metadata.at("field_of_study", default: if language == "de" { "Informatik" } else { "Computer Science" })
  v(0.6em, weak: true)
  metadata.at("university", default: if language == "de" { "Hochschule für Wirtschaft und Recht Berlin" } else { "Berlin School of Economics and Law" })

  v(equal_spacing)

  let merge_entries(defaults, customs) = {
    let base = defaults
    for entry in customs {
      let idx = entry.at("index", default: base.len())
      base.insert(idx, (entry.key, entry.value))
    }
    base
  }

  if language == "de" {
    let default_entries = (
      ("Unternehmen:", metadata.company),
      ("Studienjahrgang:", metadata.enrollment_year),
      ("Semester:", metadata.semester),
      ("Matrikelnummer:", metadata.student_id),
      ("Betreuer im Unternehmen:", metadata.company_supervisor),
      ("Anzahl der Wörter:", word_count),
    )

    let final_entries = merge_entries(default_entries, custom_entries)

    show table.cell.where(x: 0): strong
    table(
      columns: 2,
      stroke: none,
      align: left,
      column-gutter: 5%,
      ..final_entries.flatten()
    )
  } else {
    let default_entries = (
      ("Company:", metadata.company),
      ("Enrollment Year:", metadata.enrollment_year),
      ("Semester:", metadata.semester),
      ("Student ID:", metadata.student_id),
      ("Company Supervisor:", metadata.company_supervisor),
      ("Word Count:", word_count),
    )

    let final_entries = merge_entries(default_entries, custom_entries)

    show table.cell.where(x: 0): strong
    table(
      columns: 2,
      stroke: none,
      align: left,
      column-gutter: 5%,
      ..final_entries.flatten()
    )
  }

  v(2*equal_spacing)

  if language == "de" {
    table(
      columns: (50%,50%),
      stroke: none,
      inset: 20pt,
      align: left,
      [#line(length: 100%)Unterschrift Ausbilder*in],
      [#line(length: 100%)Unterschrift Betreuer*in (HWR)],
    )
  } else {
    table(
      columns: (50%,50%),
      stroke: none,
      inset: 20pt,
      align: left,
      [#line(length: 100%)Signature of Supervisor (Company)],
      [#line(length: 100%)Signature of Supervisor (HWR)],
    )
  }

  v(equal_spacing)
  pagebreak()
  set align(left)
  // END OF TITLE PAGE

  // Abstract
  set page(numbering: "I", number-align: center)
  v(1fr)
  align(center)[
    #heading(
      outlined: false,
      numbering: none,
      text(0.85em, smallcaps[Abstract]),
    )
    #box(width: 90%)[#align(left)[#par(justify: true)[#abstract]]]
  ]
  v(1.618fr)
  pagebreak()

  if note-gender-inclusive-language.enabled and language == "de" {
    heading(note-gender-inclusive-language.at("title", default: "Hinweis zum sprachlichen Gendern"), numbering: none)
    [
      Aus Gründen der besseren Lesbarkeit wird im Text verallgemeinernd das generische Maskulinum verwendet.
      Diese Formulierungen umfassen gleichermaßen weibliche, männliche und diverse Personen.
    ]
    pagebreak()
  }

  // Declaration of authorship
  if custom_declaration_of_authorship != [] {
    custom_declaration_of_authorship
  } else if language == "de" {
    heading("Ehrenwörtliche Erkärung", numbering: none)
    [
      Ich erkläre ehrenwörtlich:

       + dass ich meinen Praxistransferbericht selbstständig verfasst habe,
       + dass ich die Übernahme wörtlicher Zitate aus der Literatur sowie die Verwendung der Gedanken anderer
        Autoren an den entsprechenden Stellen innerhalb der Arbeit gekennzeichnet habe,
       + dass ich meinen Praxistransferbericht bei keiner anderen Prüfung vorgelegt habe.

       Ich bin mir bewusst, dass eine falsche Erklärung rechtliche Folgen haben wird.
    ]
    v(4.0em)

    table(
      columns: (50%,50%),
      stroke: none,
      inset: 20pt,
      [#line(length: 100%)Ort, Datum], [#line(length: 100%)Unterschrift],
    )
    pagebreak()
  } else {
    heading("Declaration of Authorship", numbering: none)
    [
      I hereby declare that this work titled “#metadata.title” is my own and has been carried out independently,
      without the use of any sources or aids other than those stated.
      All passages that have been quoted directly or indirectly from other works have been clearly marked and referenced.

      I confirm that this work has not been submitted, either in whole or in part, for any other academic degree or qualification.
    ]
    v(4.0em)

    table(
      columns: (50%,50%),
      stroke: none,
      inset: 20pt,
      [#line(length: 100%)City, Date], [#line(length: 100%)Signature],
    )
    pagebreak()
  }

  // Content outline
  outline(depth: 3, indent: 2%)
  pagebreak()

  // Glossary
  if glossary.entries != () {
    import "@preview/glossarium:0.5.6": *
    show: make-glossary
    register-glossary(glossary.entries)

    heading(glossary.at("title", default: if language == "de" { "Glossar" } else { "Glossary" }), numbering: none)
    print-glossary(glossary.entries, show-all: true)
    pagebreak()
  }

  // Acronyms
  if acronyms.entries != () {
    print-index(outlined: true, title: acronyms.at("title", default: if language == "de" { "Acronyme" } else { "Acronyms" }))
    pagebreak()
  }

  // Display indices of figures, tables, and listings.
  let default_titles = (
    figure_title: "Index of Figures",
    table_title: "Index of Tables",
    listing_title: "Index of Listings"
  )
  if language == "de" {
    default_titles.figure_title = "Abbildungsverzeichnis"
    default_titles.table_title = "Tabellenverzeichnis"
    default_titles.listing_title = "Aufzählungsverzeichnis"
  }
  let fig-t(kind) = figure.where(kind: kind)
  if figure-index.enabled or table-index.enabled or listing-index.enabled {
    show outline: set heading(outlined: true)
    context {
      let imgs = figure-index.enabled
      let tbls = table-index.enabled
      let lsts = listing-index.enabled
      if imgs {
        outline(
          title: figure-index.at("title", default: default_titles.figure_title),
          target: fig-t(image),
        )
      }
      if tbls {
        outline(
          title: table-index.at("title", default: default_titles.table_title),
          target: fig-t(table),
        )
      }
      if lsts {
        outline(
          title: listing-index.at("title", default: default_titles.listing_title),
          target: fig-t(raw),
        )
      }
      if imgs or tbls or lsts {
        pagebreak()
      }
    }
  }

  set par(justify: true)
  set page(numbering: "1")

  body

  // Settings for pages after main body
  set heading(numbering: none)
  set page(numbering: "I")

  // Biblography
  if bibliography-object != none {
    set bibliography(style: citation_style)
    bibliography-object
  }

  // Appendix
  if appendix.enabled {
    pagebreak()
    heading(appendix.at("title", default: if language == "de" { "Anhang" } else { "Appendix" }), numbering: none)
    appendix.content
  }
}
