#import "/utils/utils.typ": heh-logo
#import "/components/headers/headers.typ": logo-year-title
#import "/utils/states.typ": heh-config

#let tfe-cover-page(
  show-year: false,
) = context {
  set page(margin: (x: 45pt, y: 45pt), header: none, footer: none)
  set text(font: ("Roboto", "Inter"), size: 14pt)
  show link: set text(fill: black)
  let config = heh-config.get()
  logo-year-title(show-title: false)

  v(.4fr)

  align(
    center,
    text(
      size: 14pt,
      top-edge: 1.25em,
      spacing: 100% + 2pt,
    )[
      HAUTE ÉCOLE DE LA COMMUNAUTÉ FRANÇAISE EN HAINAUT \
      #config.campus.naming.full-name \
      #config.campus.contact.address-line1 - #config.campus.contact.address-line2
    ],
  )

  v(1fr)

  align(
    center,
    text(size: 16pt, weight: "bold")[
      #config.document.title
    ],
  )

  v(.3fr)

  align(
    center,
    text(size: 12pt)[
      #config.document.description
    ],
  )

  v(1fr)

  let columns-amount = 2
  if (show-year) {
    columns-amount = 3
  }

  columns(columns-amount)[
    Promoteur.trice interne : #config.document.internal-promoter
    #colbreak()
    #if (show-year) {
      align(center, config.document.exam-session)
      colbreak()
    }
    #align(right, {
      grid(
        columns: (auto, auto),
        gutter: .5em,
        [Rédigé par : ],
        {
          align(left, {
            for author in config.document.authors {
              author.at(0)
              linebreak()
            }
          })
        },
      )
    })
  ]

  pagebreak()
}

#tfe-cover-page()
