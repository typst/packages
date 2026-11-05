// ---------------------------------------------------------------------------
// Localization
// ---------------------------------------------------------------------------

#let translations = (
  cs: (
    university: "ČESKÉ VYSOKÉ UČENÍ TECHNICKÉ V PRAZE",
    supervisor: "Vedoucí práce",
    supervisors: "Vedoucí práce",
    abstract: "Abstrakt",
    keywords: "Klíčová slova",
    title: "Překlad názvu",
    acknowledgements: "Poděkování",
    toc: "Obsah",
    list-of-figures: "Seznam obrázků",
    list-of-tables: "Seznam tabulek",
    list-of-abbreviations: "Seznam zkratek",
    bibliography: "Literatura",
    region: "CZ",
    months: (
      "leden",
      "únor",
      "březen",
      "duben",
      "květen",
      "červen",
      "červenec",
      "srpen",
      "září",
      "říjen",
      "listopad",
      "prosinec",
    ),
  ),
  sk: (
    university: "ČESKÉ VYSOKÉ UČENÍ TECHNICKÉ V PRAZE",
    supervisor: "Vedúci práce",
    supervisors: "Vedúci práce",
    abstract: "Abstrakt",
    keywords: "Kľúčové slová",
    title: "Preklad názvu",
    acknowledgements: "Poďakovanie",
    toc: "Obsah",
    list-of-figures: "Zoznam obrázkov",
    list-of-tables: "Zoznam tabuliek",
    list-of-abbreviations: "Zoznam skratiek",
    bibliography: "Literatúra",
    region: "SK",
    months: (
      "január",
      "február",
      "marec",
      "apríl",
      "máj",
      "jún",
      "júl",
      "august",
      "september",
      "október",
      "november",
      "december",
    ),
  ),
  en: (
    university: "CZECH TECHNICAL UNIVERSITY IN PRAGUE",
    supervisor: "Supervisor",
    supervisors: "Supervisors",
    abstract: "Abstract",
    keywords: "Keywords",
    title: "Translated title",
    acknowledgements: "Acknowledgements",
    toc: "Contents",
    list-of-figures: "List of Figures",
    list-of-tables: "List of Tables",
    list-of-abbreviations: "List of Abbreviations",
    bibliography: "References",
    region: "US",
    months: (
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ),
  ),
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let _present(x) = x != none and x != "" and x != [] and x != ()

#let _format-date(date, tr) = {
  if date == none { return none }
  if date == auto { date = datetime.today() }
  if type(date) == datetime {
    tr.months.at(date.month() - 1) + " " + str(date.year())
  } else {
    date
  }
}

#let _chapters(style, body) = {
  set heading(numbering: style)
  set figure(numbering: n => numbering(
    style,
    counter(heading).get().first(),
    n,
  ))
  set math.equation(numbering: n => numbering(
    "(" + style + ")",
    counter(heading).get().first(),
    n,
  ))

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    for kind in (image, table, raw) { counter(figure.where(kind: kind)).update(0) }
    counter(math.equation).update(0)
    it
  }

  body
}

// ---------------------------------------------------------------------------
// Parts of the document
// ---------------------------------------------------------------------------

#let _title-page(
  tr,
  thesis-type,
  title,
  author,
  faculty,
  department,
  study-program,
  supervisors,
  logo,
  date-text,
) = [
  #set page(margin: 2.5cm, numbering: none)
  #set align(center)

  #text(size: 16pt, weight: "bold")[#tr.university]
  #if _present(faculty) [
    #v(0.4em)
    #text(size: 14pt, weight: "bold")[#faculty]
  ]
  #if _present(department) [
    #v(0.4em)
    #text(size: 12pt)[#department]
  ]

  #v(3cm)

  #text(size: 16pt, weight: "bold")[#thesis-type]
  #v(0.5em)
  #text(size: 20pt, weight: "bold")[#title]

  #v(2cm)

  #text(size: 16pt)[#author]
  #if _present(study-program) [
    #v(0.5em)
    #text(size: 12pt)[#study-program]
  ]

  #v(1fr)

  #if _present(logo) [
    #logo
    #v(2fr)
  ]

  #grid(
    columns: (1fr, 1fr),
    align: (left + bottom, right + bottom),
    [
      #if supervisors.len() > 0 [
        #text(weight: "bold")[
          #if supervisors.len() == 1 [#tr.supervisor] else [#tr.supervisors]
        ]
        #for supervisor in supervisors [
          #linebreak()
          #supervisor
        ]
      ]
    ],
    [
      #if _present(date-text) [#date-text]
    ],
  )
]

#let _front-matter(
  tr,
  assignment,
  declaration,
  abstracts,
  acknowledgements,
  show-toc,
  list-of-figures,
  list-of-tables,
  list-of-abbreviations,
) = {
  set page(numbering: "i")
  counter(page).update(1)

  for page-content in (assignment, declaration) {
    if _present(page-content) {
      pagebreak(weak: true)
      page-content
    }
  }

  if abstracts.len() > 0 {
    pagebreak(weak: true)
    for (i, a) in abstracts.enumerate() {
      if i > 0 { v(1.5em) }
      heading(level: 1, outlined: false)[#a.tr.abstract]
      a.body
      if a.keywords.len() > 0 {
        v(0.8em)
        [
          #set par(first-line-indent: 0pt)
          *#a.tr.keywords:* #a.keywords.join(", ")
        ]
      }
      if _present(a.title) {
        v(0.8em)
        [
          #set par(first-line-indent: 0pt)
          *#a.tr.title:* #a.title
        ]
      }
    }
  }

  if _present(acknowledgements) {
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#tr.acknowledgements]
    acknowledgements
  }

  if show-toc {
    pagebreak(weak: true)
    outline(title: tr.toc, depth: 3)
  }

  if list-of-figures {
    pagebreak(weak: true)
    outline(title: tr.list-of-figures, target: figure.where(kind: image))
  }

  if list-of-tables {
    pagebreak(weak: true)
    outline(title: tr.list-of-tables, target: figure.where(kind: table))
  }

  if list-of-abbreviations.len() > 0 {
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#tr.list-of-abbreviations]
    columns(2, gutter: 5em, {
      for (abbreviation, definition) in list-of-abbreviations {
        grid(
          columns: (1fr, 3fr),
          column-gutter: 1em,
          strong(abbreviation), definition,
        )
        v(0.2em)
      }
    })
  }
}

#let _main-matter(tr, body, bibliography, appendices) = {
  set page(numbering: "1")
  counter(page).update(1)

  [
    #show: _chapters.with("1.1")
    #body
  ]

  if bibliography != none {
    set std.bibliography(title: tr.bibliography)
    pagebreak(weak: true)
    bibliography
  }

  if appendices != none {
    counter(heading).update(0)
    show: _chapters.with("A.1")
    appendices
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let thesis(
  language: "en",

  thesis-type: "Thesis type",
  title: (:),
  author: "Name of the author",
  faculty: none,
  department: none,
  study-program: none,
  supervisors: (),
  logo: none,
  date: auto,

  abstract: (:),
  keywords: (:),

  acknowledgements: none,

  assignment: none,
  declaration: none,

  show-toc: true,
  list-of-figures: false,
  list-of-tables: false,
  list-of-abbreviations: (),
  bibliography: none,
  appendices: none,

  body,
) = {
  assert(
    language in translations,
    message: "`language` must be \"cs\", \"sk\" or \"en\"",
  )
  let tr = translations.at(language)

  let title-text = title.at(language, default: "Title")
  let supervisors = if type(supervisors) == str { (supervisors,) } else { supervisors }
  let date-text = _format-date(date, tr)

  // Only provided abstracts, own language first
  let order = (language,) + ("cs", "sk", "en").filter(l => l != language)
  let abstracts = order
    .filter(l => _present(abstract.at(l, default: none)))
    .map(l => (
      tr: translations.at(l),
      body: abstract.at(l),
      keywords: keywords.at(l, default: ()),
      title: if l == language { none } else { title.at(l, default: none) },
    ))

  // Metadata
  set document(
    title: title-text,
    author: author,
    description: author + ": " + title-text,
    keywords: keywords.values().flatten(),
  )

  // Typesetting
  set page(
    paper: "a4",
    margin: (x: 3.25cm, top: 3cm, bottom: 3.5cm),
  )

  set text(
    font: "Libertinus Serif",
    size: 11pt,
    lang: language,
    region: tr.region,
  )

  set par(
    justify: true,
    leading: 0.65em,
    spacing: 0.65em,
    first-line-indent: 1.5em,
  )

  show heading: it => if it.numbering == none { it } else {
    block(counter(heading).display(it.numbering) + h(0.5em) + it.body)
  }
  show heading.where(level: 1): set text(size: 1.65em, weight: "bold")
  show heading.where(level: 1): set block(above: 1.75em, below: 0.75em)
  show heading.where(level: 2): set text(size: 1.3em, weight: "bold")
  show heading.where(level: 2): set block(above: 1.5em, below: 0.75em)
  show heading.where(level: 3): set text(size: 1.1em, weight: "bold")
  show heading.where(level: 3): set block(above: 1.25em, below: 0.5em)

  show math.equation.where(block: true): set block(above: 1.2em, below: 1.2em)

  set figure(gap: 0.8em)
  show figure: set block(above: 1.5em, below: 1.5em)
  show figure.where(kind: raw): set align(left)
  show figure.where(kind: raw): set block(breakable: true)

  // Document parts
  _title-page(
    tr,
    thesis-type,
    title-text,
    author,
    faculty,
    department,
    study-program,
    supervisors,
    logo,
    date-text,
  )

  _front-matter(
    tr,
    assignment,
    declaration,
    abstracts,
    acknowledgements,
    show-toc,
    list-of-figures,
    list-of-tables,
    list-of-abbreviations,
  )

  _main-matter(tr, body, bibliography, appendices)
}
