#import "global.typ": *

//---------------------------------------------|  FRONT COVER  |---------------------------------------------//

#let _front-cover-page(
  title,
  background,
  authors,
  degree,
  department,
) = page(
  paper: "sis-g5",
  margin: 5mm,
  background: box(
    width: 100%-10mm,
    height: 100%-10mm,
    stroke: none
  )[
    #set image(width: 100%, height: 100%)
    #background
  ],
  foreground: place(
    bottom + right,
    dy: 17mm, dx: 13mm,
    image("../assets/LU-sigill.webp", width: 50%))
  )[
    #set par(justify: true, leading: 0.7em)
    #set text(font: font-secondary, size: size-secondary, fill: lu-bronze, weight: "bold", hyphenate: false)
    #place(
      right + top,
      dy: (1/7)*100%,
      block(
        width: 100%*(4/5),
        height: auto,
        inset: 5mm,
        outset: (right: 5mm),
        fill: white,
        align(
          left,
          grid(
            rows: 3,
            gutter: 1.5em,
            text(font: font-main, weight: "semibold", size: size-heading, title),
            line(length: 100%, stroke: (paint: lu-bronze)),
            upper()[
              #text(authors.map(author => author.name).join(", ", last: " & ")) \
              #degree's Thesis \
              #department \
              Faculty of Engineering | LTH | Lund University
            ]
          )
        )   
      )
    )
    #if debug {place(center + horizon, grid(rows: 7*(1fr,), columns: 5*(1fr,), stroke: 1pt))} // Used for debugging)
  ]

//---------------------------------------------|  TITLE PAGE  |---------------------------------------------//

#let _title-page(
  thesis-title,
  subtitle,
  authors,
  supervisors,
  examiner,
  degree,
  department,
  images,
  date
) = page()[
  #let print-authors = context {
    align(top, grid(rows: 1, columns: authors.len(), column-gutter: 2cm,..authors.map(author => [
          #stack(spacing: par.leading,
            text(weight: "regular", size: size-sub-sub-heading, {
              author.name
            }), 
            if "affiliation" not in author.keys(){v(par.leading)} else {author.affiliation},
            if "email" not in author.keys(){par.leading} else {link("mailto:" + str(author.email))}
          )
        ])))
  }
  #set align(center + horizon)
  #set text(hyphenate: false)
  #set stack(dir: ttb)
  #set par(justify: false, leading: 1em)
  #set line(length: 60%)
  #show link: emph
  #show title: set text(size: size-heading, font: font-main, weight: "semibold")
  #context{
    block(height: 100%, 
      grid(
        row-gutter: (1.25fr, 1.25fr, 1fr, 1fr),
        smallcaps[#degree's thesis #date.year() #linebreak() #department],
        grid(row-gutter: 3em,
          // line(),
          title(),
          // line(),
          ..if subtitle != none {(text(subtitle, size: size-sub-heading),)},
        ),
        print-authors,
        date.display("[month repr:long] [day padding:none], [year]"), 
        {
          let images-filtered = images.filter(img => type(img) == type(""))
          
          if images-filtered.len() != 0 {
            grid(column-gutter: 0.2fr,
              columns: (1fr,) * images-filtered.len(),
              ..images-filtered.map(img => image(img, fit: "contain", width: 5cm)))
          }
        },
      )
    )
  }
]

//---------------------------------------------|  INFORMATION PAGE  |---------------------------------------------//

#let _information-page(
  title,
  title-sv,
  subtitle,
  subtitle-sv,
  authors,
  company,
  supervisors,
  examiner,
  course-code,
  issn,
  department,
  date
) = page()[
  // #set align(top)
  #set par(first-line-indent: 0em, leading: 0.8em)
  #set block(below: 1fr)
  #v(4cm)
  #block()[
    #text(size: size-sub-heading, weight: "semibold", title) \ \
    #text(size: size-sub-sub-heading, subtitle)
  ]

  #block()[
    #sym.copyright #h(1em) #authors.map(author => author.name).join(", ", last: " & "), #date.year()
  ]

  #block(grid(
    columns: 2,
    gutter: 1.5em,
    ..if title-sv != none {
      (
        [Swedish title],
        [#title-sv#if subtitle-sv != none [: \ #subtitle-sv]],
      )
    },
    "Supervisor" + if supervisors.len() > 1 {"s"}, grid(
      row-gutter: 1em, ..supervisors.values().map(supervisor => [
        #supervisor.name  (#supervisor.affiliation)#if supervisor.email != none [, #link("mailto:" + supervisor.email)]
      ])
    ),
    "Examiner", [#examiner.name#if examiner.email != none [, #link("mailto:" + examiner.email)]],
    "Course code", [#course-code],
    ..if issn != none {
      (
        "ISSN",
        issn,
      )
    }
  ))

  #block(if company != none [Degree project carried out at #company.join(", ", last: " and ")])
  
  #block()[
      #department \ Faculty of Engineering, LTH \ Lund University #parbreak() Box 118 \ SE-221 00 Lund \ Sweden
  ]


  Typeset in Typst #sys.version \
  Printed by #link("https://www.ehuset.lth.se/tryckeriet/", [Tryckeriet i E-huset])
]

//---------------------------------------------|  BACK COVER  |---------------------------------------------//

#let _back-cover(
  degree,
  department,
  department-abbreviation,
  link,
  id,
  date
) = page(
    paper: "sis-g5",
    margin: 5mm,
  )[
    #set text(fill: lu-bronze, font: font-secondary, size: size-secondary, weight: "semibold")
    #if debug {place(center + horizon, grid(rows: 7*(1fr,), columns: 5*(1fr,), stroke: 1pt))} // Used for debugging
    #place(top + right, dx: -5mm, dy: 0.5/7*100%, rotate(90deg, reflow: true, text(size: 6pt, [Printed by Tryckeriet i E-huset, Lund #date.display("[year]")])))
    #place(center + bottom, dy: -1/7*100% , image("../assets/LU-RGB-ENG.png", height: 1/7*100%))
    #place(center + bottom, dy: -1/7*100% + 2cm , [
      Series of #degree's theses \
      #department \
      LU/LTH-#department-abbreviation #date.display("[year]")-#id \
      #link
    ]
  )]