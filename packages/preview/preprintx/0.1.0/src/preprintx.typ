#let preprintx(
  title: none,
  authors: (),
  affils: (),
  abstract: none,
  keywords: (),
  correspondence: none,
  doc,
) = {
  set text(font: "STIX Two Text", size: 10pt)
  show heading: set text(font: "Helvetica")
  show heading.where(level: 1): it => {
    set text(11pt)
    pad(bottom: 11pt, it)
  }

  show heading.where(level: 2): it => {
    set text(9pt)
    box(it) + "."
  }
  show heading.where(level: 3): it => {
    set text(9pt)
    emph(box(it) + ".")
  }
  show bibliography: set text(font: "Helvetica", size: 8pt)
  show figure: it => {
    place(
      auto,
      float: true,
      scope: "parent",
    )[
      #it.body
      #it.caption
    ]
  }
  show figure.caption: set text(font: "Helvetica", size: 8pt)

  set page(
    paper: "us-letter",
    margin: 0.75in,
    footer: context [
      #align(
        right + horizon,
        if authors.len() == 1 [
          #text(
            font: "Helvetica",
            size: 7pt,
            authors.at(0).at(0).split(",").at(0),
          )
          #text(
            font: "Helvetica",
            size: 7pt,
          )[$bar.v$ _Preprint_ $bar.v$]
          #text(
            font: "Helvetica",
            size: 7pt,
            counter(page).display("1"),
          )
        ] else if authors.len() == 2 [
          #text(
            font: "Helvetica",
            size: 7pt,
            authors.at(0).at(0).split(",").at(0) + " & " + authors.at(1).at("name").split(",").at(0),
          )
          #text(
            font: "Helvetica",
            size: 7pt,
          )[$bar.v$ _Preprint_ $bar.v$]
          #text(
            font: "Helvetica",
            size: 7pt,
            counter(page).display("1"),
          )
        ] else [
          #text(
            font: "Helvetica",
            size: 7pt,
            authors.at(0).at(0).split(",").at(0),
          ) #text(
            font: "Helvetica",
            size: 7pt,
            "et al.",
            style: "italic",
          )
          #text(
            font: "Helvetica",
            size: 7pt,
          )[$bar.v$ _Preprint_ $bar.v$]
          #text(
            font: "Helvetica",
            size: 7pt,
            counter(page).display("1"),
          )

        ],
      )],
    columns: 2,
  )
  place(
    top + center,
    float: true,
    scope: "parent",
  )[
    #set align(center)
    *#text(24pt, title)*
    #text(font: "Helvetica", size: 8pt)[

      *#authors.map(a => [#a.at(0).split(",").at(1) #a.at(0).split(",").at(0)#super(a.at(1))]).join(",", last: " and")*
    ]

    #text(font: "Helvetica", size: 7pt)[
      #affils.pairs().map(a => [#super(a.at(0))#a.at(1)\ ]).join()
    ]
  ]

  set align(left)
  set par(justify: true)
  [
    #text(font: "STIX Two Text", size: 9pt)[*#abstract*]
    \
    \
    #text(font: "Helvetica", size: 7pt)[
      *#keywords.join(" " + $bar.v$ + " ")*

      _*#if correspondence == none [] else [\u{2709} #correspondence]*_
      \
      \
    ]
  ]
  doc
}

