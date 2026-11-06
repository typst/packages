#import "../core.typ": ctu-layout

#let defaults = (
  university: "Fakulta elektrotechnická, ČVUT v Praze",
  toc-title: "Obsah",
)

#let fel-cover(
  title: "REPORT TITLE",
  subtitle: "REPORT SUBTITLE",
  author: "AUTHOR NAME",
  details: (),
  date: "DATE OF SUBMISSION",
  university: defaults.university,
  branch: "YOUR STUDY BRANCH",
  logo: none,
) = {
  page(
    numbering: none,
  )[
    #set align(center)

    // logo + faculty/branch info
    #stack(dir: ltr, spacing: 1.3em)[
      #logo
    ][
      #v(1.5em)
      #set align(left)
      #stack(dir: ttb, spacing: 12pt)[
        #text(university, size: 20pt, weight: "bold")
      ][
        #text(branch, size: 16pt)
      ]
    ]

    // main title block vertically centered
    #v(16em)
    #text(title, size: 24pt, weight: "bold")
    #v(-1.5em)
    #text(subtitle, size: 18pt)
    #v(5em)
    #text(author, 18pt)

    // author and year information at the bottom
    #align(bottom, block[
      #if details.len() > 0 {
        align(center)[
          #set text(size: 16pt)
          #grid(
            columns: (auto, auto),
            gutter: 0.8em,
            column-gutter: 0.5em,
            align: (right, left),
            ..details
              .pairs()
              .map(((klic, hodnota)) => (
                [*#klic:*],
                [#hodnota],
              ))
              .flatten()
          )
        ]
      }
      #v(0.5em)
      #text(date, 14pt)
    ])
  ]
}

#let fel-toc(
  title: defaults.toc-title,
) = {
  // style headings based on level
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true) // space above
    text(it, weight: 900, size: 13pt)
  }
  show outline.entry.where(level: 2): it => {
    v(4pt) // space above
    text(it, weight: 500, size: 12pt)
  }
  show outline.entry.where(level: 3): it => {
    v(2pt) // space above
    text(it, weight: 300, size: 11pt)
  }
  show outline.entry.where(level: 4): it => {
    v(2pt) // space above
    text(it, weight: 300, size: 10pt)
  }

  page(
    numbering: none,
  )[
    #align(center, heading(level: 1, outlined: false, numbering: none)[#title])
    #v(14pt)
    #outline(title: none, indent: 1.6em)
  ]
}

#let fel-declaration(
  author: "AUTHOR NAME",
  sign-date: datetime.today(),
) = {
  heading(level: 1, outlined: false, numbering: none)[Prohlášení]
  [
    Prohlašuji, že jsem závěrečnou práci vypracoval/a samostatně a uvedl/a veškeré použité
    informační zdroje v souladu s Metodickým pokynem o dodržování etických principů při
    přípravě vysokoškolských závěrečných prací a Rámcovými pravidly používání umělé
    inteligence na ČVUT pro studijní a pedagogické účely v Bc a Mgr studiu.

    Prohlašuji, že jsem v průběhu příprav a psaní závěrečné práce použil/a nástroje umělé
    inteligence. Vygenerovaný obsah jsem ověřil/a. Stvrzuji, že jsem si vědom/a, že za obsah
    závěrečné práce plně zodpovídám.

    #v(2em)

    v Praze dne #sign-date.display("[day]. [month]. [year]")

    #align(right)[
      ........................................\
      #author
    ]
  ]
}

#let fel-abstracts(
  abstract-cz: "ABSTRACT TEXT CZ",
  abstract-en: "ABSTRACT TEXT EN",
  keywords-cz: ("KEYWORDS", "CZ"),
  keywords-en: ("KEYWORDS", "EN"),
) = {
  grid(
    columns: (1fr, 1fr),
    gutter: 2em,
    [
      #heading(level: 1, outlined: false, numbering: none)[Abstrakt]
      #abstract-cz
    ],
    [
      #heading(level: 1, outlined: false, numbering: none)[Abstract]
      #abstract-en
    ],

    [
      #heading(level: 1, outlined: false, numbering: none)[Klíčová slova]
      #keywords-cz.join(", ")
    ],
    [
      #heading(level: 1, outlined: false, numbering: none)[Keywords]
      #keywords-en.join(", ")
    ],
  )
}

#let fel-thesis(
  title: "REPORT TITLE",
  subtitle: "REPORT SUBTITLE",
  author: "AUTHOR NAME",
  details: (),
  date: "DATE OF SUBMISSION",
  sign-date: datetime.today(),
  abstract-cz: "ABSTRACT TEXT CZ",
  abstract-en: "ABSTRACT TEXT EN",
  keywords-cz: ("KEYWORDS", "CZ"),
  keywords-en: ("KEYWORDS", "EN"),
  university: defaults.university,
  branch: "YOUR STUDY BRANCH",
  toc-title: defaults.toc-title,
  logo: none,
  gutter: false,
  body,
) = {
  // global cvut layout
  show: ctu-layout.with(title: title, author: author, gutter: gutter)

  // first pages scope
  {
    set page(
      margin: 3cm,
    )

    // cover page
    fel-cover(
      title: title,
      subtitle: subtitle,
      author: author,
      details: details,
      date: date,
      university: university,
      branch: branch,
      logo: logo,
    )
    pagebreak()

    // declaration of authorship
    fel-declaration(
      author: author,
      sign-date: sign-date,
    )
    pagebreak()

    // abstracts
    fel-abstracts(
      abstract-cz: abstract-cz,
      abstract-en: abstract-en,
      keywords-cz: keywords-cz,
      keywords-en: keywords-en,
    )
    pagebreak()

    // table of contents
    fel-toc(title: toc-title)
    pagebreak()
  }

  // reset page numbering
  set page(numbering: "1")
  counter(page).update(1)

  body // the actual thesis content
}
