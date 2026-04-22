#let report-template(
  title: "Title",
  subtitle: "Master of Science HES SO in\n Engineering",
  author: "Your Name",
  teacher: "Teacher Name",
  orientation: "Orientation",
  date: datetime.today(),
  confidential: false,
  company: "Company Name",
  body,
  state: "To be finalized",
  file-name: "mse-hes-thesis.typ",
  project-type: "Travail de Master",
  accent-color: rgb(40, 94, 151),
  acknowledgments: [#lorem(50)],
  en-resume: [#lorem(50)],
  fr-resume: [#lorem(50)],
  lang: "en",
  font: "Arial",
) = {
  // CONFIG
  set text(font: font)
  set par(justify: true)
  set document(title: title, author: author)


  let t = (
    en: (
      toc: "Table of Contents",
      ack: "Acknowledgments",
      resume: "Abstract",
      declaration: "Declaration of authenticity",
      declaration_content: "I hereby affirm that this assignment is my own written work and that I have used no other sources or aids other than those indicated. All passages that have been quoted from publications or paraphrased from these sources are indicated as such. Additionally, any assistance from artificial intelligence tools has been appropriately acknowledged and documented.",
      produced_by: "Produced by",
      supervision: "Under the supervision of",
      collaboration: "In collaboration with",
      date_pub: "Date of publication",
      author: "Author",
      name: "Name",
      table: "Table",
      code: "Code",
    ),
    fr: (
      toc: "Table des matières",
      ack: "Remerciements",
      resume: "Résumé",
      declaration: "Déclaration d'authenticité",
      declaration_content: "Je certifie par la présente que ce travail est le fruit de mon propre travail écrit et que je n’ai utilisé
aucune autre source ou aide que celles indiquées. Tous les passages qui ont été cités à partir de
publications ou paraphrasés à partir de ces sources sont indiqués comme tels. De plus, toute aide
provenant d’outils d’intelligence artificielle a été correctement mentionnée et documentée.",
      produced_by: "Réalisé par",
      supervision: "Sous la supervision de",
      collaboration: "En collaboration avec",
      date_pub: "Date de publication",
      author: "Auteur",
      name: "Nom",
      table: "Tableau",
      code: "Code",
    ),
  )

  let tr(key) = t.at(lang).at(key)
  // PAGE DE GARDE
  set page(
    paper: "a4",
    margin: (x: 2cm, bottom: 3.5cm, top: 3cm),
    header: [
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        gutter: 0pt,
        grid.cell(
          align: top,
          [#v(1cm) #image("imgs/hes-so.svg", width: 4cm)],
        ),
        grid.cell(
          align: top,
          [#v(1cm)
            #image("imgs/corner-hes.svg", width: 1cm)],
        ),
      )
    ],
  )


  align(center)[
    #v(3em)
    #image("imgs/mse-full.svg", width: 65%)
    #v(1em)

    #text(size: 30pt, weight: "extrabold", accent-color)[#title]

    #v(2em)

    #text(size: 24pt, weight: "bold", accent-color)[
      #subtitle
    ]

    #v(2em)

    #text(size: 20pt, weight: "bold", accent-color)[
      Profil/Orientation #orientation
    ]

    #if confidential [
      #image("imgs/confidential.png", width: 50%)
    ] else [
      #v(8.4em)
    ]

    #v(0.5em)

    #text(size: 11pt)[
      #tr("date_pub"): #date.display("[day].[month].[year]")
    ]

    #v(5em)

    #align(left)[
      *#tr("produced_by")*:\
      #text(size: 16pt)[#tr("author") #author]

      #v(1em)

      #text(size: 12pt)[
        _#tr("supervision")_ #teacher \
        _#tr("collaboration")_ #company
      ]
    ]
  ]


  pagebreak()

  set page(
    paper: "a4",
    margin: (x: 2cm, bottom: 3.5cm),
    header: [
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        gutter: 0pt,
        grid.cell(image("imgs/hes-so-master.jpg", width: 3cm)),
        grid.cell(image("imgs/corner-hes.svg", width: 1cm)),
      )
    ],
    footer: context [
      //separator line
      #h(0.1em)
      #text("INGÉNIERIE ET ARCHITECTURE", size: 10pt, fill: rgb(194, 47, 103), weight: "bold")
      #v(-0.8em)
      #line(length: 100%, stroke: 0.1mm)
      #v(-0.5em)
      #{
        show table.cell: set text(size: 7pt)
        grid(
          columns: (1fr, 10fr),
          align: (left, right),
          gutter: 1pt,
          grid.cell(
            image("imgs/hes-corner-bottom.svg"),
          ),
          grid(
            table(
              stroke: 0.5pt,
              columns: (2fr, 1fr, 0.5fr),
              align: (left, right, right),
              [#file-name],
              table.cell(state, colspan: 2),
              [HES-SO / Domaine I&A / MSE / #project-type],
              table.cell(date.display("[day]-[month]-[year]") + " - " + author, align: left),
              [\- #numbering("1 / 1", ..counter(page).get(), ..counter(page).at(<end-document>)) -],
            ),
          ),
        )
      }
    ],
  )

  show figure.where(kind: raw): set figure(supplement: tr("code"))
  show figure.where(kind: table): set figure(supplement: tr("table"))


  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )


  show raw.where(block: true): block.with(
    fill: luma(250),
    radius: 3pt,
    stroke: .6pt + luma(200),
    inset: (x: 3em, y: 1em),
    width: auto,
    clip: false,
  )
  show heading: set text(
    fill: accent-color,
    weight: "bold",
  )
  show heading.where(level: 1): set text(
    size: 20pt,
  )
  show heading.where(level: 2): set text(
    size: 16pt,
  )

  show heading.where(level: 3): set text(
    size: 14pt,
  )
  show heading.where(level: 4): set text(
    size: 11pt,
  )


  outline(target: selector(heading).before(<appendix>), title: tr("toc"), depth: 3)

  pagebreak()
  [= #tr("declaration")
    #tr("declaration_content")
    #v(1em)
    #grid(
      columns: (1fr, 1fr),
      align: (left, left),
      grid.cell(
        v(2em),
      ),
      grid.cell(
        text(
          "Date : " + date.display("[day].[month].[year]") + "\n" + tr("name") + " : " + author,
        ),
      ),
    )

    #pagebreak()
    = #tr("ack")
    #acknowledgments
    #pagebreak()
    = Resume (English version)
    #en-resume
    = Résumé (version française)
    #fr-resume
  ]

  pagebreak()
  // Heading design
  set heading(numbering: "1.")
  body
  [#h(0.1em) <end-document>]
}

#let appendix(
  lang: "en",
  body,
) = {
  let t = (
    en: (
      appendix: "Appendix",
      appendices: "Appendices",
    ),
    fr: (
      appendix: "Annexe",
      appendices: "Annexes",
    ),
  )

  let tr(key) = t.at(lang).at(key)

  set heading(numbering: "A", supplement: [#tr("appendix")])
  counter(heading).update(0)

  outline(target: heading.where(supplement: [#tr("appendix")]), title: tr("appendices"))
  pagebreak()

  set figure(numbering: (..num) => context {
    counter(heading).display()
  })
  body
}
