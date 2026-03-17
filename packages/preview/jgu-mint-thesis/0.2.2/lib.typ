#let accent-color = cmyk(0%, 100%, 80%, 20%)
#let _in-appendix = state("in-appendix", false)

#let _i18n = (
  en: (
    abstract: "Abstract",
    contents: "Contents",
    list-of-figures: "List of Figures",
    list-of-tables: "List of Tables",
    abbreviations: "Abbreviations",
    acknowledgements: "Acknowledgements",
    appendix: "Appendix",
    advisor: "Dissertation Advisor",
    examiners: "Examiners",
    chapter: "Chapter",
    section: "Section",
    cc-license: "This work is licensed via",
  ),
  de: (
    abstract: "Zusammenfassung",
    contents: "Inhaltsverzeichnis",
    list-of-figures: "Abbildungsverzeichnis",
    list-of-tables: "Tabellenverzeichnis",
    abbreviations: "Abkürzungsverzeichnis",
    acknowledgements: "Danksagung",
    appendix: "Anhang",
    advisor: "Betreuer",
    examiners: "Gutachter",
    chapter: "Kapitel",
    section: "Abschnitt",
    cc-license: "Diese Arbeit ist lizenziert unter",
  ),
)

#let frontmatter(
  title: none,
  abstract: [],
  author: "Jane Doe",
  examiners: ("Dear Advisor",),
  department: "Department of Physics",
  thesis-type: "dissertation", // "dissertation", "master", or "bachelor"
  doctor-of: "Philosophy",
  major: "Physics",
  institution: "Johannes Gutenberg University Mainz",
  location: "Mainz, Germany",
  completion-date: none,
  creative-commons: true,
  list-of-figures: false,
  list-of-tables: false,
  abbreviations: none,
  dedication: none,
  acknowledgements: none,
  statutory-declaration: none,
  logo: none,
  language: "en",
  doc,
) = {
  let s = _i18n.at(language)
  if completion-date == none {
    let today = datetime.today()
    completion-date = if language == "de" {
      let months-de = ("Januar", "Februar", "März", "April", "Mai", "Juni",
                       "Juli", "August", "September", "Oktober", "November", "Dezember")
      months-de.at(today.month() - 1) + " " + str(today.year())
    } else {
      today.display("[month repr:long] [year]")
    }
  }
  let first-chapter-seen = state("first-chapter-seen", false)

  set page(
    paper: "a4",
    margin: (x: 1.375in, y: 1.375in),
    numbering: "I",
  )
  set text(font: "New Computer Modern", size: 12pt, lang: language)

  set heading(numbering: "1.1")
  show heading.where(
    level: 1,
    outlined: true,
  ): it => context [
    #set align(right)
    #set text(20pt, weight: "regular")
    #pagebreak()
    #if it.numbering != none [
      #if not first-chapter-seen.get() [
        #first-chapter-seen.update(true)
        #counter(page).update(1)
      ]
      #v(25%)
      #text(100pt, accent-color, counter(heading).display())\
      #text(24.88pt, it.body)
      #v(4em)
    ] else [
      #v(25%)
      #text(23pt, it.body)
      #v(2em)
    ]
  ]
  show heading.where(level: 1): smallcaps
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    it
  }
  show heading.where(level: 2): set block(above: 2.1em)
  show heading.where(level: 3): set block(above: 2.1em)

  show heading: set heading(supplement: s.section)
  show heading.where(level: 1): set heading(supplement: s.chapter)

  set math.equation(numbering: (..num) => numbering(
    "(1.1.1)",
    counter(heading).get().first(),
    ..num,
  ))
  set figure(numbering: (..num) => numbering(
    "1.1.1",
    counter(heading).get().first(),
    ..num,
  ))
  set page(numbering: none)
  set align(center + horizon)
  counter(page).update(1)
  [
    #text(accent-color, 24.88pt)[#(title)]

    #v(100pt)
    #show: smallcaps

    #if language == "de" [
      #if thesis-type == "dissertation" [Eine Dissertation] else if thesis-type == "master" [Eine Masterarbeit] else [Eine Bachelorarbeit]\
      vorgelegt von\
      #author\
      dem\
      #department\
      #v(12pt)
      zur Erlangung des akademischen Grades\
      #if thesis-type == "dissertation" [
        Doktor der #doctor-of
      ] else if thesis-type == "master" [
        Master of Science
      ] else [
        Bachelor of Science
      ]\
      im Fach\
      #major
      #v(12pt)
      #institution\
      #location\
      #completion-date
    ] else [
      #if thesis-type == "dissertation" [A dissertation] else if thesis-type == "master" [A master's thesis] else [A bachelor's thesis]\
      presented by\
      #author\
      to\
      The #department\
      #v(12pt)
      in partial fulfillment of the requirements\
      for the degree of\
      #if thesis-type == "dissertation" [
        Doctor of #doctor-of
      ] else if thesis-type == "master" [
        Master of Science
      ] else [
        Bachelor of Science
      ]\
      in the subject of\
      #major
      #v(12pt)
      #institution\
      #location\
      #completion-date
    ]
  ]

  pagebreak()
  show link: it => {
    set text(fill: accent-color)
    it
  }

  [
    #if creative-commons [
      #(s.cc-license) #underline[
        #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0]
      ]
    ]

    Copyright #sym.copyright #datetime.today().display("[year]") #author

    #v(15%)
    #if logo != none { logo } else { image("img/logo.svg", width: 6cm) }
  ]
  if dedication != none {
    pagebreak()
    align(center + horizon, dedication)
  }
  pagebreak()

  // "Preliminary pages (abstract, table of contents, list of tables, graphs, illustrations, and
  // preface) should use small Roman numerals"
  counter(page).update(1)
  set page(numbering: "I")
  set align(left + top)
  if examiners.len() == 1 {
    [#(s.advisor): #examiners.first() #h(1fr) #author]
  } else {
    [#(s.examiners): #h(1fr) #author] + examiners.map(e => linebreak() + h(1em) + [#e]).join()
  }

  v(5%)
  align(center, text(accent-color, 17.28pt)[#(title)])
  v(7%)

  // to mimic Double Spacing
  // https://github.com/typst/typst/issues/106#issuecomment-2041051807
  set text(top-edge: 0.7em, bottom-edge: -0.4em)
  set par(justify: true, spacing: 1.8em, leading: 1em)

  align(center)[*#(s.abstract)*]

  set align(left)
  abstract
  pagebreak()

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): it => context {
    if it.element.func() == heading and _in-appendix.at(it.element.location()) and it.element.numbering != none {
      // Appendix chapter — indented sub-entry
      pad(left: 1.5em, it)
    } else {
      // Regular chapter or Appendix section marker — smallcaps
      smallcaps(it)
    }
  }

  show ref: it => {
    set text(fill: accent-color)
    it
  }
  show figure.caption: it => [
    #set text(size: 10pt)
    #set par(justify: true)
    #set align(left)
    #strong([#it.supplement
      #context it.counter.display(it.numbering):
    ]) #it.body
  ]

  show bibliography: it => {
    show heading.where(level: 1, outlined: true): it => [
      #set align(right)
      #set text(20pt, weight: "regular")
      #pagebreak()
      #v(25%)
      #text(100pt, accent-color, it.body.text.at(0, default: ""))\
      #text(24.88pt, it.body)
      #v(4em)
    ]
    set text(size: 10pt, top-edge: 0.7em, bottom-edge: -0.3em)
    set par(leading: 0.5em, spacing: 1.2em)
    it
  }

  outline(
    title: [
      #set text(23pt)
      #h(1fr)
      #(s.contents)
      #v(2em)
    ],
  )

  if list-of-figures {
    heading(level: 1, numbering: none, outlined: true)[#(s.list-of-figures)]
    {
      set text(top-edge: 0.7em, bottom-edge: -0.3em)
      set par(leading: 0.5em, spacing: 1.2em)
      outline(
        title: none,
        target: figure.where(kind: image),
      )
    }
  }

  if list-of-tables {
    heading(level: 1, numbering: none, outlined: true)[#(s.list-of-tables)]
    {
      set text(top-edge: 0.7em, bottom-edge: -0.3em)
      set par(leading: 0.5em, spacing: 1.2em)
      outline(
        title: none,
        target: figure.where(kind: table),
      )
    }
  }

  if abbreviations != none {
    heading(level: 1, numbering: none, outlined: true)[#(s.abbreviations)]
    let sorted = abbreviations.pairs().sorted(key: pair => pair.first())
    grid(
      columns: (auto, 1fr),
      column-gutter: 2em,
      row-gutter: 0.6em,
      ..sorted.map(pair => (strong(pair.first()), pair.last())).flatten()
    )
  }

  if acknowledgements != none {
    heading(level: 1, numbering: none, outlined: true)[#(s.acknowledgements)]
    acknowledgements
  }

  set page(numbering: "1")
  doc
  if statutory-declaration != none {
    page(margin: 0pt, numbering: none, statutory-declaration)
  }
}

#let appendix(
  language: "en",
  doc,
) = {
  let s = _i18n.at(language)
  _in-appendix.update(true)

  set heading(numbering: (..num) => {
    let nums = num.pos()
    if nums.len() == 1 {
      numbering("A", nums.first())
    } else {
      numbering("A.1", ..nums)
    }
  })
  show heading.where(
    level: 1,
    outlined: true,
  ): it => context {
    if it.numbering == none [
      // "Appendix" TOC marker — invisible in body
    ] else [
      #set align(left)
      #set text(20pt, weight: "regular")
      #pagebreak()
      #v(25%)
      #text(24.88pt)[#counter(heading).display(). #it.body]
      #v(4em)
    ]
  }
  show heading.where(level: 1): smallcaps
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    it
  }

  set math.equation(numbering: (..num) => {
    let ch = counter(heading).get().first()
    "(" + numbering("A", ch) + "." + numbering("1.1", ..num) + ")"
  })
  set figure(numbering: (..num) => {
    let ch = counter(heading).get().first()
    numbering("A", ch) + "." + numbering("1.1", ..num)
  })

  // Section divider — mirrors bibliography heading style
  {
    set align(right)
    pagebreak()
    v(25%)
    text(100pt, accent-color, s.appendix.at(0))
    linebreak()
    text(24.88pt)[#(s.appendix)]
    v(4em)
  }

  // Invisible heading — creates the TOC entry pointing to this page
  heading(level: 1, numbering: none, outlined: true)[#(s.appendix)]

  // Reset counter so appendix chapters start at A
  counter(heading).update(0)

  doc
}
