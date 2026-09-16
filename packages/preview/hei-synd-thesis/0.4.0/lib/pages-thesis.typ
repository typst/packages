//
// Description: Custom pages for the thesis template
// Author     : Silvan Zahno
//
#import "helpers.typ": *

#let format-email(email) = {
  if email == none {
    return none
  }
  return link("mailto:" + email)
}

#let page-title-contact-block(person) = {
  if person == none {
    return []
  }
  let fields = (
    person.affiliation,
    person.name,
    format-email(person.email)
  ).filter(v => v != none)
  return fields.join[, ]
}

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
    (
      gender      : none,
      name        : none,
      email       : none,
      degree      : none,
      affiliation : none,
      place       : none,
      url         : none,
      signature   : none,
    )
  ),
  professor: none,
  expert: none,
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
      top: 3.0cm,
      bottom: 3.0cm,
      rest: 3.5cm
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
        align(center, text(size: larger,
          i18n("degree-programme", lang: lang)
        ))
        v(1em)
      }

      // Orientation
      if school.orientation != none {
        align(center, text(size: larger,
          school.orientation
        ))
        v(1em)
      }

      // Specialisation
      if school.specialisation != none {
        align(center, text(size: large,
          [#i18n("major", lang: lang) #school.specialisation]
        ))
        v(2em)
      }
    }

    if extra-content-top != none {
      extra-content-top
    }

    // BACHELOR'S THESIS / Midterm Report
    if template == "thesis" {
      align(center, text(size: huge,
        [*#i18n("thesis-title", lang: lang)*]
      ))
      v(1em)
    } else if template == "midterm"{
      align(center, text(size: huge,
        [*#i18n("midterm-title", lang: lang)*]
      ))
      v(1em)
    }

    // DIPLOMA YEAR
    align(center, text(size: huge,
      [*#i18n("diploma", lang: lang) #date.display("[year]")*]
    ))
    v(1em)

    // AUTHORs
    align(center, text(size: large, {
      if author.len() > 1 {
        enumerating-authors(
          items: author,
          multiline: true,
        )
      } else {
        author.at(0).name
      }
      v(2em)
    }))

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
    #if professor != () [
      #i18n("professor", lang: lang)\
      #professor.map(page-title-contact-block).join(linebreak())
      \ \
    ]
    #if expert != () [
      #i18n("expert", lang: lang)\
      #expert.map(page-title-contact-block).join(linebreak())
      \ \
    ]
    #if template == "thesis" [
      #i18n("submission-date", lang: lang)\
      #icu-datetime.fmt(date, locale: lang, length: "medium")
      //#date.display("[day] [month repr:long] [year]")
    ] else if template == "midterm" [
      #i18n("submission-date", lang: lang)\
      #icu-datetime.fmt(date, locale: lang, length: "medium")
      //#date.display("[day] [month repr:long] [year]")
    ]
    #v(1em)
  ]

  grid(
    columns: (50%, 50%),
    rows: (10%, 63%, 20%, 7%),
    align(left+horizon)[#logos.topleft],
    align(right+horizon)[#logos.topright],
    //stroke: 0.5pt,
    grid.cell(
      colspan: 2,
      align(horizon)[#content-up]
    ),
    grid.cell(
      colspan: 2,
      align(horizon)[#content-down]
    ),
    align(left+horizon)[#logos.bottomleft],
    align(right+horizon)[#logos.bottomright],
  )
}

#let summary-graduate-line(author, lang) = {
  let gender = if author != none and "gender" in author {author.gender} else {none}
  let name = if author != none and "name" in author {author.name} else {none}
  let title = get-gendered-label(gender, "graduate", lang: lang)
  return ({
    set text(
      size: 12pt,
      fill: gray.darken(50%),
    )
    title
  },{
    set text(size: 10pt)
    name
  } )
}

#let summary-contact-block(person) = {
  if person == none {
    return []
  }
  let fields = (
    person.name,
    format-email(person.email)
  ).filter(v => v != none)
  return fields.join(linebreak())
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
    footer: table(
      columns: (50%, 50%),
      stroke: none,
      align: (left + horizon, right + horizon),
      if address != none {
        option-style()[#address]
      } else {
        option-style()[HES-SO Valais Wallis • rue de l'Industrie 23 • 1950 Sion \ +41 58 606 85 11 • #link("mailto"+"info@hevs.ch")[info\@hevs.ch] • #link("www.hevs.ch")[www.hevs.ch]]
      },
      logos.bottomright,
    ),
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
        #heading(level: 3, numbering: none, outlined: false)[
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

      #if professor != () [
        #i18n("professor", lang: lang)\
        #professor.map(summary-contact-block).join(v(0.5em))
        #v(0.6cm)
      ]

      #if partner != () [
        #i18n("partner", lang: lang)\
        #partner.map(summary-contact-block).join(v(0.5em))
      ]

    ],
    [],
    [
      #align(left, text(15pt)[
        #heading(numbering: none, outlined: false)[#title]
      ])
      #table(
        columns: (3.5cm, 1fr),
        stroke: none,
        align: left + horizon,
        ..author.map((a) => summary-graduate-line(a, lang)).flatten()
      )

      #v(1.5cm)

      #heading(level: 3, numbering: none, outlined: false)[
        #text(12pt)[#i18n("objective", lang: lang)]
      ]

      #if objective == none {
        i18n("objective-text")
      } else {
        objective
      }

      #v(0.6cm)

      #heading(level: 3, numbering: none, outlined: false)[
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
  heading(numbering: none, outlined: false)[#i18n("report-info", lang: lang)]
  v(2em)
  heading(numbering: none, outlined: false)[*#i18n("contact-info", lang: lang)*]

  let author_l = get-gendered-label(author.at(0).gender, "author", lang: lang)
  let student_l = get-gendered-label(author.at(0).gender, "student", lang: lang)

  table(
    columns: (auto, auto),
    stroke: none,
    align: left + top,
    table.cell(rowspan: 3)[#if author.at(0).email != none {[#author_l:]}], [#author.at(0).name],
    if lang == "fr" {
      [#if author.at(0).degree != none {student_l} #author.at(0).degree]
    } else {
      [#author.at(0).degree #if author.at(0).degree != none {student_l}]
    },
    author.at(0).affiliation,
    if author.at(0).email != none [#i18n("email", lang: lang):], link("mailto:author.at(0).email")[#author.at(0).email],
  )

  v(5em)
  [
    *#i18n("declaration-title", lang: lang)* \
    #i18n("declaration-text", lang: lang)
  ]

  table(
    stroke: none,
    columns: (auto, auto),
    align: left + horizon,
    i18n("declaration-signature-prefix", lang: lang), [#author.at(0).place#if author.at(0).place != none{[,]} #date.display("[day].[month].[year]")],
    i18n("declaration-signature", lang: lang),
    if author.at(0).signature != none {
      v(0.5cm)
      pad(x: 2.5em, author.at(0).signature)
      line(start: (0cm, -0.7cm), length: 5cm)
    } else {
      line(start: (0cm, 1.5cm), length: 7cm)
    },
  )
}

#let page-pdf(
  img: none,
) = {
  if img != none {
    set page(
      margin: (0cm),
      header: none,
      footer: none,
    )
    img
  }
}
