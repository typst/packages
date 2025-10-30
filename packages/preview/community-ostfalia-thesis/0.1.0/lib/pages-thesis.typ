//
// Description: Custom pages for the thesis template
// Author     : Silvan Zahno
//
#import "helpers.typ": *

#let page-title-thesis(
  title: none,
  subtitle: none,
  template: "thesis",
  date: datetime.today(),
  lang: "en",
  school: (
    name: none,
    orientation: none,
    specialisation: none,
  ),
  author: (
    gender      : none,
    name        : none,
    email       : none,
    degree      : none,
    affiliation : none,
    place       : none,
    url         : none,
    signature   : none,
  ),
  professor: none,
  expert:none,
  logos: (
    topleft: none,
    topright: none,
    bottomleft: none,
    bottomright: none,
  ),
  extra-content-top: none,
  extra-content-bottom: none,
) = {

  set page(
    margin: (
      top:3.0cm,
      bottom:3.0cm,
      rest:3.5cm
    )
  )
  //-------------------------------------
  // Page content
  //
  let content-up = {
    //line(length: 100%)
    if school != none {
      //v(0.5fr)
      // Degree Programme
      if school.orientation != none {
        align(center, [#text(size:larger,
          i18n("degree-programme", lang: lang)
        )])
        v(1em)
      }

      // Orientation
      if school.orientation != none {
        align(center, [#text(size:larger,
          school.orientation
        )])
        v(1em)
      }

      // Specialisation
      if school.specialisation != none {
        align(center, [#text(size:large,
          [#i18n("major", lang: lang) #school.specialisation]
        )])
        v(2em)
      }
    }

    if extra-content-top != none {
      extra-content-top
    }

    // BACHELOR'S THESIS / Practical Project Report
    if template == "thesis" {
      align(center, [#text(size:huge,
        [*#i18n("thesis-title", lang: lang)*]
      )])
      v(1em)
    } else if template == "practical-project"{
      align(center, [#text(size:huge,
        [*#i18n("practical-project-title", lang: lang)*]
      )])
      v(1em)
    }

    // AUTHORs
    align(center, [#text(size:large, [
      #if type(author) == array [
        #enumerating-authors(
          items: author,
          multiline: true,
        )
      ] else [
        #author.name
        #v(1em)
        #i18n("matriculation-number", lang: lang): #author.matrikelnummer
      ]
      #v(2em)
    ])])

    titlebox(
      title: title,
      subtitle: subtitle,
    )

    if extra-content-bottom != none {
      extra-content-bottom
    }
  }

  let content-down = [
    #v(2em)
    #if professor != none and (professor.affiliation != none or professor.name != none or professor.email != none ) [
      #i18n("professor", lang: lang)\
      #professor.affiliation#if (professor.affiliation != none and professor.name != none) or (professor.affiliation != none and professor.email != none) {[, ]}#professor.name#if professor.name != none and professor.email != none {[,]} #link("mailto:professor.email")[#professor.email]
      \ \
    ]
    #if expert != none and (expert.affiliation != none or expert.name != none or expert.email != none ) [
      #i18n("expert", lang: lang)\
      #expert.affiliation#if (expert.affiliation != none and expert.name != none) or (expert.affiliation != none and expert.email != none) {[, ]}#expert.name#if expert.name != none and expert.email != none {[,]} #link("mailto:expert.email")[#expert.email]
      \ \
    ]
    #if template == "thesis" [
      #i18n("submission-date", lang: lang)\
      #icu-datetime.fmt(date, locale: lang, length: "medium")
      //#date.display("[day] [month repr:long] [year]")
    ] else if template == "practical-project" [
      #i18n("submission-date", lang: lang)\
      #icu-datetime.fmt(date, locale: lang, length: "medium")
      //#date.display("[day] [month repr:long] [year]")
    ]
    #v(1em)
  ]

  // grid(
  //   columns: (50%, 50%),
  //   rows: (10%, 63%, 20%, 7%),
  //   align(left+horizon)[#logos.topleft],
  //   align(right+horizon)[#logos.topright],
  //   row-gutter: (1cm, 0pt, 0pt), // Add 1 cm of space between top logos and text
  //   grid.cell(
  //     colspan: 2,
  //     align(horizon)[#content-up]
  //   ),
  //   grid.cell(
  //     colspan: 2,
  //     align(horizon)[#content-down]
  //   ),
  //   align(left+horizon)[#logos.bottomleft],
  //   align(right+horizon)[#logos.bottomright],
  // )

  grid(
    columns: (50%, 50%),
    rows: (
      auto, // Top logos
      1cm,  // 1 cm space
      auto, // content-up
      1fr,  // Flexible space to push the rest down
      auto, // content-down
      auto  // Bottom logos
    ),

    // Logos
    align(left+horizon)[#logos.topleft],
    align(right+horizon)[#logos.topright],

    grid.cell(colspan: 2, []), // Empty, 1cm-tall cell

    grid.cell(
      colspan: 2,
      align(horizon)[#content-up]
    ),

    grid.cell(colspan: 2, []), // Empty, 1fr-tall cell, can get squished

    grid.cell(
      colspan: 2,
      align(horizon)[#content-down]
    ),

    align(left+horizon)[#logos.bottomleft],
    align(right+horizon)[#logos.bottomright],
  )
}

#let summary(
  title: none,
  author: none,
  year: none,
  degree: none,
  field: none,
  professor: none,
  partner: none,
  logos: (
    main: none,
    topleft: none,
    bottomright: none,
  ),
  objective: none,
  address: none,
  lang: "en",
  body
) = {
  set page(
    margin: (
      top: 5.5cm,
      bottom: 3cm,
      x: 1.8cm,
    ),
    header: [
      #logos.topleft//#image(, width: 7.5cm)
    ],
    footer-descent: 0cm,
    footer: [
      #table(
        columns: (50%, 50%),
        stroke: none,
        align: (left + horizon, right + horizon),
        [
          #if address != none {
            option-style()[#address]
          } else {[
            #option-style()[HES-SO Valais Wallis • rue de l'Industrie 23 • 1950 Sion \ +41 58 606 85 11 • #link("mailto"+"info@hevs.ch")[info\@hevs.ch] • #link("www.hevs.ch")[www.hevs.ch]]
          ]}
        ],[
          #logos.bottomright
        ],
      )
    ],
  )

  set text(size: 9pt)
  set par(justify: true)

  table(
    columns: (5.4cm, 1.2cm, 1fr),
    stroke: none,
    inset: 0pt,
    [
      #if logos.main != none {
        logos.main
      } else {
        box(width: 5.4cm, height: 5cm)
      }

      #v(1cm)

      #align(center)[
        #heading(level: 3, numbering:none, outlined: false)[
          #text(15pt)[
            #i18n("thesis-title", lang: lang)\ | #h(0.3cm) #year #h(0.3cm) |
          ]
        ]
      ]

      #v(0.5cm)

      //#square(size: 0.7cm, fill: blue.lighten(70%))

      #v(0.6cm)
      #set text(size: 10pt)

      #i18n("degree-programme", lang: lang)\
      _#[#degree]_

      #v(0.6cm)

      #i18n("major", lang: lang)\
      _#[#field]_

      #v(0.6cm)

      #if professor != none {[
        #i18n("professor", lang: lang)\
        _#[#professor.name]_\
        _#[#professor.email]_
        #v(0.6cm)
      ]}

      #if partner != none {[
        #i18n("partner", lang: lang)\
        _#[#partner.name]_\
        _#[#partner.affiliation]_
      ]}

    ],[],[
      #align(left, text(15pt)[
        #heading(numbering:none, outlined: false)[#title]
      ])
      #table(
        columns: (0cm, 3.5cm, 1fr),
        stroke: none,
        align: left + horizon,
        [
          //#square(size: 0.7cm, fill: blue.lighten(70%))
        ],[
          #set text(
            size: 12pt,
            fill: gray.darken(50%),
          )
          #let graduate_l = if author.gender == "feminin" {
            i18n("graduate-f", lang: lang)
          } else if author.gender == "inclusive" {
            i18n("graduate-i", lang: lang)
          } else {
            i18n("graduate", lang: lang)
          }

          #graduate_l
        ],[
          #set text(size: 10pt)
          #author.name
        ]
      )

      #v(1.5cm)

      #heading(level: 3, numbering:none, outlined: false)[
        #text(12pt)[#i18n("objective", lang: lang)]
      ]

      #if objective == none {
        [
          #i18n("objective-text")
        ]
      } else {
        objective
      }

      #v(0.6cm)

      #heading(level: 3, numbering:none, outlined: false)[
        #text(12pt)[#i18n("methods-experiences-results", lang: lang)]
      ]

      #body
    ]
  )
}

#let page-reportinfo(
  author: (),
  date: none,
  lang: "en",
) = {
  heading(numbering:none, outlined: false)[#i18n("report-info", lang: lang)]
  v(2em)
  heading(numbering:none, outlined: false)[*#i18n("contact-info", lang: lang)*]

  let author_l = if author.gender == "feminin" {
    i18n("author-f", lang: lang)
  } else if author.gender == "inclusive" {
    i18n("author-i", lang: lang)
  } else {
    i18n("author", lang: lang)
  }
  let student_l = if author.gender == "feminin" {
    i18n("student-f", lang: lang)
  } else if author.gender == "inclusive" {
    i18n("student-i", lang: lang)
  } else {
    i18n("student", lang: lang)
  }
  table(
    columns: (auto, auto),
    stroke: none,
    align: left + top,
    table.cell(rowspan: 4)[#if author.email != none {[#author_l:]}], [#author.name],
    [#author.matrikelnummer],
    if lang == "fr" {
      [#if author.degree != none {student_l} #author.degree]
    } else {
      [#author.degree #if author.degree != none {student_l}]
    },

    [#author.affiliation],
    [#if author.email != none {[#i18n("email", lang: lang):]}], [#link("mailto:author.email")[#author.email]],
  )

  v(5em)
  [
    *#i18n("declaration-title", lang: lang)* \
    #i18n("declaration-text", lang: lang)
  ]

  table(
    stroke: none,
    columns: (auto,auto),
    align: left + horizon,
    [#i18n("declaration-signature-prefix", lang: lang)], [#author.place#if author.place != none{[,]} #date.display("[day].[month].[year]")],
    [#i18n("declaration-signature", lang: lang)],
    if author.signature != none {[
      #v(0.5cm)
      #pad(x: 2.5em, author.signature)
      #line(start: (0cm,-0.7cm),length:5cm)
    ]} else {[
      #line(start: (0cm,1.5cm),length:7cm)
    ]},
  )
}

#let page-pdf(
  data: none,
) = {
  if data != none {
    set page(
      margin: (0cm),
      header: none,
      footer: none,
    )
    muchpdf(
      data,
      width: 100%,
    )
  }
}
