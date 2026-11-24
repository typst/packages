// ============================================================
// Konfigurierbare Vorlage für wissenschaftliche Arbeiten
// ============================================================

#let dhbw-template(
  english: false,

  // ----------------------------------------------------------
  // Metadaten
  // ----------------------------------------------------------
  meta: (:),

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
  language: auto,

  font: (
    "Times New Roman",
    "Libertinus Serif",
  ),

  font-size: 12pt,
  text-hyphenate: true,

  paragraph-justify: true,
  paragraph-leading: auto,
  paragraph-spacing: auto,

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
  table-of-contents-title: auto,

  outline-level-one-bold: true,
  outline-level-one-spacing: 0.6em,

  // ----------------------------------------------------------
  // Abbildungsverzeichnis
  // ----------------------------------------------------------
  show-figure-outline: true,
  figure-outline-title: auto,

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
  company-logo-align: left + top,
  university-logo: none,
  university-logo-align: right + top,

  institution-name: auto,

  faculty-name: auto,

  study-prefix: auto,

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
  nondisclosure-title: auto,

  abstract: none,
  abstract-title: auto,

  acronyms: (),
  acronyms-title: auto,
  acronym-column-width: 3.6cm,
  acronym-column-gutter: 1cm,
  acronym-row-gutter: 0.45em,
  acronym-font-size: 10pt,

  gender-notice: none,
  gender-notice-title: auto,

  appendix: none,
  appendix-title: auto,
  appendix-numbering: "A.1",

  // ----------------------------------------------------------
  // Literaturverzeichnis
  // ----------------------------------------------------------
  bibliography-content: none,
  bibliography-title: auto,

  bibliography-font-size: 10pt,
  bibliography-justify: false,
  bibliography-leading: 0.8em,
  bibliography-spacing: 1.2em,
  bibliography-hanging-indent: 1.8cm,

  // ----------------------------------------------------------
  // Ehrenwörtliche Erklärung
  // ----------------------------------------------------------
  show-declaration: true,
  declaration-title: auto,
  declaration-content: none,
  declaration-signature-height: 3cm,

  // ----------------------------------------------------------
  // Dokumentinhalt
  // ----------------------------------------------------------
  body,
) = {
  let localized(german, english-text) = if english {
    english-text
  } else {
    german
  }

  let metadata-value(german-key, english-key, default-value) = meta.at(
    english-key,
    default: meta.at(german-key, default: default-value),
  )

  let resolved-meta = (
    art-der-arbeit: metadata-value("art-der-arbeit", "work-type", auto),
    titel-der-arbeit: metadata-value("titel-der-arbeit", "thesis-title", ""),
    titel-zeile1: metadata-value("titel-zeile1", "title-line-one", []),
    titel-zeile2: metadata-value("titel-zeile2", "title-line-two", []),
    autor-der-arbeit: metadata-value("autor-der-arbeit", "author", ""),
    anschrift-zeile1: metadata-value("anschrift-zeile1", "address-line-one", ""),
    anschrift-zeile2: metadata-value("anschrift-zeile2", "address-line-two", ""),
    abteilung: metadata-value("abteilung", "department", ""),
    firma: metadata-value("firma", "company", ""),
    studienjahrgang: metadata-value("studienjahrgang", "cohort", ""),
    kurs: metadata-value("kurs", "course", ""),
    studienrichtung: metadata-value(
      "studienrichtung",
      "field-of-study",
      "Digital Business Management",
    ),
    matrikelnummer: metadata-value("matrikelnummer", "student-id", ""),
    studiengangsleiter: metadata-value(
      "studiengangsleiter",
      "head-of-degree-programme",
      "",
    ),
    wiss-betreuer: metadata-value("wiss-betreuer", "academic-supervisor", ""),
    firmen-betreuer: metadata-value("firmen-betreuer", "company-supervisor", ""),
    abgabedatum: metadata-value("abgabedatum", "submission-date", ""),
  )

  let resolve-localized(value, german, english-text) = if value == auto {
    localized(german, english-text)
  } else {
    value
  }

  let resolved-language = resolve-localized(language, "de", "en")
  let resolved-table-of-contents-title = resolve-localized(
    table-of-contents-title,
    [Inhaltsverzeichnis],
    [Table of Contents],
  )
  let resolved-figure-outline-title = resolve-localized(
    figure-outline-title,
    [Abbildungsverzeichnis],
    [List of Figures],
  )
  let resolved-nondisclosure-title = resolve-localized(
    nondisclosure-title,
    [Sperrvermerk],
    [Confidentiality Notice],
  )
  let resolved-abstract-title = resolve-localized(
    abstract-title,
    [Abstract],
    [Abstract],
  )
  let resolved-acronyms-title = resolve-localized(
    acronyms-title,
    [Abkürzungsverzeichnis],
    [List of Abbreviations],
  )
  let resolved-gender-notice-title = resolve-localized(
    gender-notice-title,
    [Gender-Hinweis],
    [Gender Notice],
  )
  let resolved-appendix-title = resolve-localized(
    appendix-title,
    [Anhang],
    [Appendix],
  )
  let resolved-bibliography-title = resolve-localized(
    bibliography-title,
    [Literaturverzeichnis],
    [References],
  )
  let resolved-declaration-title = resolve-localized(
    declaration-title,
    [Ehrenwörtliche Erklärung],
    [Declaration of Authorship],
  )
  let resolved-institution-name = resolve-localized(
    institution-name,
    [Duale Hochschule Baden-Württemberg Mannheim],
    [Duale Hochschule Baden-Württemberg Mannheim],
  )
  let resolved-faculty-name = resolve-localized(
    faculty-name,
    [Fakultät Wirtschaft],
    [Fakultät Wirtschaft],
  )
  let resolved-study-prefix = resolve-localized(
    study-prefix,
    [Studienrichtung BWL –],
    [Studienrichtung BWL –],
  )
  let resolved-work-type = resolve-localized(
    resolved-meta.art-der-arbeit,
    [Bachelorarbeit],
    [Bachelor's Thesis],
  )
  let study-cohort = resolved-meta.studienjahrgang

  // ==========================================================
  // Globales Layout
  // ==========================================================

  set page(
    paper: paper,
    margin: page-margin,
    number-align: page-number-align,
  )

  set text(
    lang: resolved-language,
    font: font,
    size: font-size,
    hyphenate: text-hyphenate,
  )

  set par(
    justify: paragraph-justify,
    leading: if paragraph-leading == auto { 0.82em } else { paragraph-leading },
    spacing: if paragraph-spacing == auto { 1em } else { paragraph-spacing },
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

  let front-heading(title, outlined: true) = [
    #heading(
      level: 1,
      numbering: none,
      outlined: outlined,
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

  let has-value(value) = value != none and value != "" and value != []
  let title-label(german, english-text) = text(
    weight: "semibold",
    localized(german, english-text),
  )

  let submitted-by = (
    resolved-meta.autor-der-arbeit,
    resolved-meta.anschrift-zeile1,
    resolved-meta.anschrift-zeile2,
  ).filter(has-value).join(linebreak())

  let cohort-and-course = (
    study-cohort,
    resolved-meta.kurs,
  ).filter(has-value).join(" / ")

  let title-data-rows = (
    (
      title-label([Eingereicht von:], [Submitted by:]),
      submitted-by,
    ),
    (
      title-label([Matrikelnummer:], [Student ID:]),
      resolved-meta.matrikelnummer,
    ),
    (
      title-label([Firma:], [Company:]),
      resolved-meta.firma,
    ),
    (
      title-label([Abteilung:], [Department:]),
      resolved-meta.abteilung,
    ),
    (
      title-label(
        if has-value(study-cohort) { [Studienjahrgang / Kurs:] } else { [Kurs:] },
        if has-value(study-cohort) { [Cohort / Course:] } else { [Course:] },
      ),
      cohort-and-course,
    ),
    (
      title-label([Studiengangsleiter:], [Head of Degree Programme:]),
      resolved-meta.studiengangsleiter,
    ),
    (
      title-label([Wissenschaftliche Betreuung:], [Academic Supervisor:]),
      resolved-meta.wiss-betreuer,
    ),
    (
      title-label([Betriebliche Betreuung:], [Company Supervisor:]),
      resolved-meta.firmen-betreuer,
    ),
    (
      title-label([Abgabetermin:], [Submission Date:]),
      resolved-meta.abgabedatum,
    ),
  ).filter(row => has-value(row.at(1)))

  let title-logos = context {
    let company-logo-height = if company-logo == none {
      0pt
    } else {
      measure(company-logo).height
    }
    let university-logo-height = if university-logo == none {
      0pt
    } else {
      measure(university-logo).height
    }
    let logo-area-height = calc.max(
      company-logo-height,
      university-logo-height,
    )

    block(width: 100%, height: logo-area-height)[
      #if company-logo != none {
        place(company-logo-align, company-logo)
      }
      #if university-logo != none {
        place(university-logo-align, university-logo)
      }
    ]
  }

  // ==========================================================
  // Titelblatt
  // ==========================================================

  let titlepage = page(numbering: none)[
    #title-logos

    #v(2.5em)

    #align(center)[
      #set par(
        justify: false,
        spacing: 0em,
        leading: 0.8em,
      )

      #text(size: institution-font-size)[
        #resolved-institution-name \
        #resolved-faculty-name \
        #resolved-study-prefix #resolved-meta.studienrichtung
      ]

      #v(4em)

      #text(
        size: work-type-font-size,
        weight: "bold",
      )[
        #resolved-work-type
      ]
    ]

    #v(8mm)

    #title-box(
      resolved-meta.titel-zeile1,
      resolved-meta.titel-zeile2,
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

      ..title-data-rows.flatten(),
    )
  ]

  // ==========================================================
  // Abkürzungsverzeichnis
  // ==========================================================

  let acronym-outline = [
    #front-heading(resolved-acronyms-title)
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

  let default-declaration = if english {
    [
      I hereby declare that I have written the present thesis entitled

      #v(0.3em)

      #quote(emph(resolved-meta.titel-der-arbeit))

      #v(0.3em)

      independently and have used no sources or aids other than those
      indicated. I further declare that the submitted electronic version
      is identical to the printed version.
    ]
  } else {
    [
      Ich versichere hiermit, dass ich die vorliegende Arbeit
      mit dem Thema:

      #v(0.3em)

      „#emph[#resolved-meta.titel-der-arbeit]“

      #v(0.3em)

      selbstständig verfasst und keine anderen als die angegebenen
      Quellen und Hilfsmittel benutzt habe. Ich versichere zudem,
      dass die eingereichte elektronische Fassung mit der
      gedruckten Fassung übereinstimmt.
    ]
  }

  let declaration = [
    #front-heading(resolved-declaration-title)

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
        #localized([Ort, Datum], [Place, Date])
      ],

      [
        #line(length: 100%)
        #v(0.2cm)
        #resolved-meta.autor-der-arbeit
      ],
    )
  ]

  // ==========================================================
  // Dokumentausgabe
  // ==========================================================

  // Titelblatt
  titlepage

  if nondisclosure != none {
    page(numbering: none)[
      #front-heading(resolved-nondisclosure-title, outlined: false)
      #nondisclosure
    ]
  }

  // ----------------------------------------------------------
  // Vorspann mit römischer Seitennummerierung
  // ----------------------------------------------------------

  set page(numbering: "I")
  counter(page).update(2)

  if abstract != none {
    front-heading(resolved-abstract-title)
    strong(resolved-meta.titel-der-arbeit)
    parbreak()
    resolved-meta.autor-der-arbeit
    linebreak()
    [#localized([Matrikelnummer:], [Student ID:]) #resolved-meta.matrikelnummer]
    linebreak()
    if study-cohort != "" {
      [#localized([Studienjahrgang:], [Cohort:]) #study-cohort]
      linebreak()
    }
    [#localized([Kurs:], [Course:]) #resolved-meta.kurs]
    v(1em)
    abstract
    pagebreak()
  }

  if show-table-of-contents {
    outline(title: resolved-table-of-contents-title)
    pagebreak()
  }

  if acronyms.len() > 0 {
    acronym-outline
    pagebreak()
  }

  if show-figure-outline {
    front-heading(resolved-figure-outline-title)

    outline(
      title: none,
      target: figure.where(kind: image),
    )

    pagebreak()
  }

  if gender-notice != none {
    front-heading(resolved-gender-notice-title)
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

  context {
    let text-frame-height = measure([H]).height

    set par(
      leading: if paragraph-leading == auto {
        1.5em - text-frame-height
      } else {
        paragraph-leading
      },
      spacing: if paragraph-spacing == auto {
        3em - text-frame-height
      } else {
        paragraph-spacing
      },
    )

    body
  }

  // ----------------------------------------------------------
  // Textnachlauf mit fortgesetzter römischer Nummerierung
  // ----------------------------------------------------------

  pagebreak()
  set page(numbering: "I")

  context [
    #counter(page).update(
      counter(page).at(<frontmatter-end>).first()
    )
  ]

  // ----------------------------------------------------------
  // Optionaler Anhang
  // ----------------------------------------------------------

  if appendix != none {
    front-heading(resolved-appendix-title)

    set heading(numbering: appendix-numbering)
    counter(heading).update((0, 0))

    appendix
    pagebreak()
  }

  // ----------------------------------------------------------
  // Literaturverzeichnis
  // ----------------------------------------------------------

  if bibliography-content != none {
    front-heading(resolved-bibliography-title)
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