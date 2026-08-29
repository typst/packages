#import "./utils.typ": join-names, maybe-sans-serif, months-no, t, thesis-type-keys

#let title-page(
  title: "Example Title in Primary Language",
  subtitle: "Example Subtitle in Primary Language",
  authors: ("Newt Yellow", "Bellatrix Green"),
  supervisors: ("Minerva Red", "Filius Blue"),
  degree-name: "Example degree name",
  faculty: "Example faculty",
  department: "Example department",
  level: "master",
  date: datetime.today(),
  lang: "en",
  logo: image("../assets/NTNU_logo_liggende_med_visjon.svg", width: 45mm),
  style,
) = {
  set page(margin: (top: 30mm, bottom: 30mm, inside: 35mm, outside: 25mm))
  set align(left)
  set text(size: 10pt, font: maybe-sans-serif(style))

  // --- Author, title, subtitle (optional) ---
  let author-text = text(
    size: 16pt,
    fill: rgb("#555555"),
    authors.join(", "),
  )
  let title-text = text(
    size: 22pt,
    weight: "bold",
    title,
  )
  let subtitle-text = if subtitle != none {
    text(size: 13pt, subtitle)
  }

  [
    #author-text

    #title-text

    #subtitle-text
  ]

  v(1fr)

  // Necessary as of 2026-08-24 because datetime.display doesn't automatically translate based on the text language.
  // See: https://github.com/typst/typst/issues/2840
  // And: https://github.com/typst/typst/issues/1537
  let formatted-date = if lang == "en" [
    #date.display("[month repr:long] [year]")
  ] else {
    let translated-month(dt) = months-no.at(dt.month() - 1)
    [#translated-month(date) #date.year()]
  }

  let thesis-type = t(thesis-type-keys.at(level))

  let supervisor-label = if supervisors.len() == 1 {
    t("supervisor")
  } else {
    t("supervisors")
  }

  [
    #thesis-type #t("in") #degree-name \
    #if supervisors != () and supervisors != none [
      #supervisor-label: #supervisors.join(", ") \
    ]
    #formatted-date

    \

    #t("uni-long") \
    #if faculty != none [ #faculty \ ]
    #if department != none [ #department \ ]
  ]

  v(2.5em)

  // --- NTNU Logo ---
  if logo != none {
    logo
  } else {
    image("../assets/ntnu_logo.svg", width: 44mm)
  }
}

#let copyright-page(
  year: 2026,
  authors: ("Astronaut Boulder", "Cat Dog"),
  publisher: "NTNU",
) = {
  set page(margin: (top: 27mm, bottom: 30mm, inside: 35mm, outside: 25mm))
  set text(size: 9pt, fill: rgb("#555555"))

  v(1fr)
  [
    #sym.copyright #year #if type(authors) == array { authors.join(", ") } else { authors } \
    #publisher
  ]
}

#let localized-abstract(
  lang: "en",
  abstract-heading: none,
  keywords-heading: none,
  keywords: ("Magic", "Wonder"),
  body,
) = {
  if abstract-heading == none {
    abstract-heading = t("abstract-heading")
  }

  if keywords-heading == none {
    keywords-heading = t("keywords-heading")
  }

  set text(lang: lang)

  heading(outlined: false, depth: 1, text(lang: lang, abstract-heading))

  body

  if keywords.len() > 0 [
    #v(1.5em)
    #strong(keywords-heading): #keywords.join(", ")
  ]
}

#let signed-acknowledgements(
  city: "Trondheim",
  date: datetime.today(),
  authors: ("Gary Lose", "Harriet Lung"),
  body,
) = {
  heading(outlined: false, depth: 1, "Preface")

  body

  v(1.5em)

  let formatted-date = if type(date) == datetime {
    date.display("[month repr:long] [year]")
  } else {
    str(date)
  }

  [#city, #formatted-date]
  for author in authors {
    linebreak()
    author
  }
}

#let indices = {
  pagebreak(weak: true, to: "odd")
  {
    show outline.entry.where(level: 1): it => {
      v(1em, weak: true)
      strong(it)
    }

    outline(title: t("table-of-contents"), indent: auto)
  }

  let images-target = figure.where(kind: image, outlined: true)
  context if (query(images-target).len() > 0) {
    pagebreak(weak: true, to: "odd")
    outline(title: t("list-of-figures"), target: images-target)
  }

  let tables-target = figure.where(kind: table, outlined: true)
  context if (query(tables-target).len() > 0) {
    pagebreak(weak: true, to: "odd")
    outline(title: t("list-of-tables"), target: tables-target)
  }

  let code-target = figure.where(kind: raw, outlined: true)
  context if (query(code-target).len() > 0) {
    pagebreak(weak: true, to: "odd")
    outline(title: t("list-of-listings"), target: code-target)
  }
}

#let extra-preamble(title: "Additional Preamble", body) = {
  pagebreak(weak: true, to: "odd")
  heading(outlined: false, depth: 1, title)

  body
}
