#import "./utils.typ": (
  t,
  tl,
  extract-name,
  author-names,
  resolve-logo,
  format-date,
  localized-field,
  thesis-title,
)

#let framed-cover(
  lang: "en",
  localized-info: (:),
  authors: (),
  date: datetime.today(),
  logo,
) = page(
  footer: none,
  {
    set text(lang: lang)
    set par(leading: 1.2em)

    align(center)[
      #block(
        width: 100%,
        stroke: 1pt + black,
        inset: 2em,
        align(center)[
          #v(1em)
          #text(size: 14pt)[#localized-info.at(lang).at("diploma-project")]
          #v(6em)
          #text(size: 20pt, weight: "bold", thesis-title(localized-info.at(lang).at("title")))
          #v(5em)
          #for name in authors {
            text(size: 16pt, weight: "bold", name)
            linebreak()
          }
          #v(2em)
          #box(width: 80%, logo)
          #v(1fr)
          #text(size: 14pt, weight: "bold", localized-info.at(lang).at("department"))
          #v(12em)
          #text(size: 14pt, weight: "bold", format-date(date, lang: lang))
        ],
      )
    ]
  },
)

#let submission-page(
  lang: "en",
  localized-info: (:),
  authors: (),
  advisors: (),
  date: datetime.today(),
) = page(
  footer: none,
  {
    set text(lang: lang)
    set par(leading: 1.2em)

    align(center)[
      #text(size: 14pt)[#tl("university", lang)]
      #v(0.5em)
      #localized-info.at(lang).at("faculty")
      #v(0.5em)
      #localized-info.at(lang).at("department")
      #v(5em)
      #v(3em)
      #text(size: 20pt, weight: "bold", thesis-title(localized-info.at(lang).at("title")))
      #v(3em)
      #for name in authors {
        text(size: 16pt, weight: "bold", name)
        linebreak()
      }
      #v(10em)
      #for advisor in advisors {
        text(size: 14pt)[
          #tl("advisor", lang)#if lang == "en" [:]
        ]
        linebreak()
        text(size: 14pt, weight: "bold", extract-name(advisor))
        linebreak()
        v(0.5em)
      }
      #v(5em)
      #par(
        justify: true,
        localized-field(
          localized-info.at(lang),
          lang,
          "submission-statement",
          "submission-statement-default",
        ),
      )
      #v(1fr)
      #text(size: 14pt, format-date(date, lang: lang))
    ]
  },
)

#let declaration-page(lang: "en") = page(
  footer: none,
  {
    set text(lang: lang)
    set par(leading: 1.2em, justify: true)

    align(center)[
      #text(size: 14pt, weight: "bold", tl("declaration-heading", lang))
    ]
    v(2em)

    [
      #tl("declaration-body", lang)
      #link(tl("ethics-code-url", lang))
      #tl("declaration-body-end", lang)
    ]
  },
)

#let advisory-committee-page(
  lang: "en",
  localized-info: (:),
  authors: (),
  committee: (:),
  date: datetime.today(),
) = page(
  footer: none,
  {
    set text(lang: lang)
    set par(leading: 1.2em)

    align(center)[
      #text(size: 14pt, weight: "bold", tl("advisory-committee", lang))
      #v(3em)
      #v(3em)
      #text(size: 20pt, weight: "bold", thesis-title(localized-info.at(lang).at("title")))
      #v(3em)
      #text(size: 16pt)[#tl("presented-by", lang)]
      #linebreak()
      #for name in authors {
        text(size: 16pt, name)
        linebreak()
      }
    ]

    v(10em)

    set align(left)
    par[
      #text(size: 12pt)[
        *#tl("supervisor", lang):* #committee.at("supervisor")
      ]
    ]
    for member in committee.at("members", default: ()) {
      par[
        #text(size: 12pt)[
          *#tl("committee-member", lang):* #member
        ]
      ]
    }

    v(1fr)
    align(center)[
      #tl("university", lang), #format-date(date, lang: lang)
    ]
  },
)

#let localized-abstract(
  lang: "en",
  abstract-heading: none,
  keywords-heading: none,
  keywords: (),
  body,
) = {
  set text(lang: lang)

  let ah = abstract-heading
  if ah == none {
    ah = tl("abstract-heading", lang)
  }
  let kh = keywords-heading
  if kh == none {
    kh = tl("keywords-heading", lang)
  }

  page(
    footer: none,
    {
      heading(outlined: false, bookmarked: true, depth: 1, ah)
      set par(leading: 0.9em)
      body
      v(1em)
      [*#kh:* #keywords.join(", ")]
    },
  )
}

#let acknowledgements-page(lang: "en", body) = page(
  footer: none,
  {
    set text(lang: lang)
    set par(leading: 1.2em)

    heading(outlined: false, bookmarked: true, depth: 1, tl("ack-heading", lang))
    body
  },
)

#let indices(lang: "en", abbreviations: none) = {
  set text(lang: lang)

  pagebreak()
  show outline.entry: it => {
    v(0.35em, weak: true)
    it
  }
  outline(
    title: text(weight: "bold", upper(tl("table-of-contents", lang))),
    indent: auto,
  )

  context {
    if query(figure.where(kind: table)).len() > 0 {
      pagebreak()
      outline(
        title: text(weight: "bold", upper(tl("list-of-tables", lang))),
        target: figure.where(kind: table),
      )
    }
  }

  context {
    if query(figure.where(kind: image)).len() > 0 {
      pagebreak()
      outline(
        title: text(weight: "bold", upper(tl("list-of-figures", lang))),
        target: figure.where(kind: image),
      )
    }
  }

  if abbreviations != none {
    pagebreak()
    heading(
      outlined: true,
      bookmarked: true,
      depth: 1,
      upper(tl("list-of-abbreviations", lang)),
    )
    abbreviations
  }
}
