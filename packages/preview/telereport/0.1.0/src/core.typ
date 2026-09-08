#import "utils.typ": *
#import "i18n.typ": i18n

#let tp-logo-cover = "assets/Logo_Telecom_IPParis_RVB_noir_H.svg"
#let tp-logo-header = "assets/Logo_Telecom_IPParis_RVB_noir_V.svg"
#let tp-red = rgb("#bf1238")
#let tp-grey = luma(30%)
#let tp-black = luma(0) // == black, but anyway

#let telereport(
  title: none, // main title of the document
  short-title: none, // (optional) shorter title used in the header
  subtitle: none, // subtitle of the document, present in the cover only
  authors: (), // author(s) of the document, see documentation for more info
  supervisors: (), // if any, specify the supervisors of the report
  keywords: (), // keywords, explicit
  abstract: none, // abstract, explicit
  date: none, // date, explicit
  sidebar-text: none, // the vertical text on the cover's sidebar
  logo: true, // choose weather the TP logo should be added in the cover/header
  lang: "en", // support only for "fr" and "en", see documentation for more info
  font: "Arial", // font used in the document, explicit
  show-mail: false, // display the e-mail of the authors when provided
  show-colored-bar: true, // display colored bar at the bottom of content pages
  body,
) = {
  if lang != "fr" and lang != "en" {
    panic("Invalid language, only 'fr' and 'en' are supported.")
  }

  set text(font: font, lang: lang)
  // --- COVER PAGE ---
  page(margin: 0pt)[
    #grid(
      columns: (2.5cm, 1fr),
      rows: 100%,

      // --- LEFT SIDEBAR ---
      rect(
        width: 100%,
        height: 100%,
        fill: tp-red,
        stroke: none,
        inset: 0pt,
        align(bottom + center)[
          #pad(bottom: 2cm)[
            #if sidebar-text != none {
              rotate(-90deg, reflow: true)[
                #text(
                  fill: white,
                  size: 1.8em,
                  tracking: 0.1em,
                  weight: "bold",
                  smallcaps(sidebar-text),
                )
              ]
            }
          ]
        ],
      ),
      // --- COVER PAGE CONTENT ---
      box(width: 100%, height: 100%)[

        #pad(
          1cm,
          align(center + horizon)[

            #if logo {
              place(
                top + left,
                image(tp-logo-cover, height: 3cm),
              )
            }

            #let group-title = (
              if title != none { text(2.5em, weight: "bold", title) },
              if subtitle != none { text(1.5em, fill: tp-grey, subtitle) },
            ).filter(it => it != none)

            #let group-people = (
              if authors.len() > 0 {
                text(1.2em, [
                  #format-names(authors, show-mail: show-mail)
                ])
              },
              v(4em),
              if supervisors.len() > 0 {
                text(
                  1.1em,
                  [_#i18n("supervision_t", lang)_ \ #v(0.5em)
                    #format-names(supervisors, show-mail: show-mail)],
                )
              },
            ).filter(it => it != none)

            #let group-meta = (
              if abstract != none {
                block(width: 90%)[
                  #set par(justify: true)
                  *#i18n("abstract_t", lang)* \
                  #abstract
                ]
              },
              if keywords.len() > 0 {
                block([*#i18n("keywords_t", lang):* #keywords.join(", ")])
              },
            ).filter(it => it != none)

            #let main-blocks = (
              if group-title.len() > 0 {
                stack(dir: ttb, spacing: 1.5em, ..group-title)
              },

              if group-people.len() > 0 {
                stack(dir: ttb, spacing: 2em, ..group-people)
              },

              if group-meta.len() > 0 {
                stack(dir: ttb, spacing: 1.5em, ..group-meta)
              },
            ).filter(it => it != none)

            #stack(dir: ttb, spacing: 4em, ..main-blocks)

            #if date != none {
              place(
                bottom + center,
                dy: -1cm,
                text(size: 1.2em, fill: tp-grey, date),
              )
            }
          ],
        )
      ],
    )
  ]

  // --- CONTENT PAGE FORMAT ---
  set page(
    margin: (top: 3.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    numbering: "1/1",
    header: context {
      set text(size: 0.9em, fill: tp-grey)
      let current-page = here().page()
      let all-hdgs = query(heading.where(level: 1))

      let before-hdgs = all-hdgs.filter(h => h.location().page() < current-page)
      let page-hdgs = all-hdgs.filter(h => h.location().page() == current-page)

      // check if there is a heading on the current page that just started
      // this method is not ideal, but should work in most cases
      let current-section = if (
        page-hdgs.len() > 0 and page-hdgs.first().location().position().y < 4cm
      ) {
        page-hdgs.first().body
      } else if before-hdgs.len() > 0 {
        before-hdgs.last().body
      } else {
        none
      }

      grid(
        columns: (1fr, auto),
        gutter: 1.5em,

        align(horizon)[
          #grid(
            columns: (65%, 1fr, auto),
            align(left + horizon)[
              #if short-title != none {
                short-title
              } else if title != none { title }
            ],
            [],
            align(right + horizon)[
              #current-section
            ],
          )
          #v(0.3em)
          #line(length: 100%, stroke: 0.5pt + tp-grey)
        ],

        align(right + horizon)[
          #if logo {
            image(tp-logo-header, height: 2cm)
          }
        ],
      )
    },
    footer: context {
      align(center)[
        #text(fill: tp-red, weight: "bold")[
          #counter(page).display("1 / 1", both: true)
        ]
      ]
      if show-colored-bar {
        place(
          bottom + center,
          dy: -0.65cm,
          stack(
            dir: ltr,
            rect(width: 1cm, height: 0.3cm, fill: tp-grey, stroke: none),
            rect(width: 1cm, height: 0.3cm, fill: tp-black, stroke: none),
            rect(width: 1cm, height: 0.3cm, fill: tp-red, stroke: none),
          ),
        )
      }
    },
  )

  show heading: it => {
    let barette-v = stack(
      dir: ttb,
      rect(width: 2pt, height: 0.3em, fill: tp-grey, stroke: none),
      rect(width: 2pt, height: 0.3em, fill: tp-black, stroke: none),
      rect(width: 2pt, height: 0.3em, fill: tp-red, stroke: none),
    )

    let barettes-v = box(baseline: 15%, stack(
      dir: ltr,
      spacing: 0.2em,
      ..(barette-v,) * it.level,
    ))
    set text(weight: "semibold")
    block(above: 1.25em, below: 1em)[
      #barettes-v
      #h(0.3em)
      #if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.5em)
      }
      #it.body
    ]
  }

  body
}
