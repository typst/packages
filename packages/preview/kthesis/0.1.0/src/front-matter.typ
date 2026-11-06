#import "./utils.typ": t, join-names

#let title-page(
  title: "Primary Language Title Goes Here",
  subtitle: "Primary Language Subtitle Goes Here",
  alt-title: "Alternative Language Title Goes Here",
  alt-subtitle: "Alternative Language Title Goes Here",
  alt-lang: "sv", // either "en" or "sv"
  degree: "Master's Program, Computer Science",
  date: datetime.today(),
  authors: ("Newt Yellow", "Bellatrix Green"),
  supervisors: ("Minerva Red", "Filius Blue"),
  examiner-name: "Brian Gold",
  examiner-school: "School of Electrical Engineering and Computer Science",
  host-company: "Företaget AB", // may be none!
  host-org: "CERN", // may be none!
) = page(
  margin: (top: 65mm, bottom: 30mm, left: 74pt, right: 35mm),
  {
    text(size: 25pt, strong(title))

    v(10pt)

    text(size: 18pt, subtitle)

    v(10mm)

    for author in authors {
      text(size: 14pt, upper(author))
      linebreak()
    }

    v(1fr)

    [
      *#degree* \
      *#t("date"):* #date.display("[month repr:long] [day], [year]")
    ]

    v(5mm)

    let super-label = if supervisors.len() == 1 {
      t("supervisor")
    } else {
      t("supervisors")
    }

    [
      *#super-label:* #join-names(supervisors) \
      *#t("examiner"):* #examiner-name \
      #hide[*#t("examiner"):*] #emph(examiner-school) \
    ]

    if host-company != none {
      [*#t("host-company"):* #host-company]
      linebreak()
    }

    if host-org != none {
      [*#t("host-org"):* #host-org]
      linebreak()
    }

    [
      *#t("alt-title"):* #text(lang: alt-lang, alt-title) \
      *#t("alt-subtitle"):* #text(lang: alt-lang, alt-subtitle)
    ]
  },
)

#let copyright-page(
  year: 2025,
  authors: ("Astronaut Boulder", "Cat Dog"),
) = page(
  margin: (top: 250mm, bottom: 30mm, left: 74pt, right: 35mm),
  {
    v(1fr)

    [#sym.copyright #year #sym.space.quad #join-names(authors)]
  },
)

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

  // explicit lang is necessary for it to be shown correctly in header,
  // since it's extracted without the above set rule's effects and so
  // would otherwise be displayed in the document's primary language
  heading(outlined: false, depth: 1, text(lang: lang, abstract-heading))

  body

  heading(outlined: false, depth: 2, keywords-heading)

  keywords.join(", ")
}

#let signed-acknowledgements(
  city: "Stockholm",
  date: datetime.today,
  authors: ("Gary Lose", "Harriet Lung"),
  body,
) = {
  heading(outlined: false, depth: 1, t("ack-heading"))

  body

  v(5pt)

  [#city, #date.display("[month repr:long] [year]")]
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
