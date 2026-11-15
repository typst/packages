#import "i18n.typ": strings

#let declaration(
  author: [author],
  company-city: [company-city],
  confidential: bool,
  confidential-text: none,
  show-declaration: bool,
  show-ai-declaration: false,
  declaration-text: none,
  declaration-title: none,
  lang: "de",
) = {
  let translations = strings(lang)
  // String or array. Place and date are shared.
  let authors = if type(author) == array { author } else { (author,) }
  if show-declaration or confidential {
    pagebreak()
  }
  if show-declaration {
    set text(lang: lang)
    let today = datetime.today().display(translations.date-format)


    box(
      stroke: 1pt + luma(30),
      inset: 12pt,
    )[
      #align(center)[
        #text(size: 18pt, weight: "bold")[
          #if declaration-title == none {
            translations.declaration-title
          } else {
            declaration-title
          }]
      ]
      #v(8pt)

      #if declaration-text == none {
        translations.declaration-body
      } else {
        declaration-text
      }

      #if show-ai-declaration {
        parbreak()
        translations.declaration-ai
      }

      #v(3cm)

      // `inset` supplies the gap the old table had. Do not also set
      // `row-gutter`: the two add up and the block overflows sooner.
      #for (i, a) in authors.enumerate() {
        if i > 0 { v(0.6cm) }
        grid(
          columns: (1fr, 1fr, 1.4fr),
          align: (center, center, center),
          inset: (x: 0pt, y: 4pt),
          [#company-city], [#today], [#translations.signed #a],
          [#line(length: 100%, stroke: 0.8pt + luma(40))],
          [#line(length: 100%, stroke: 0.8pt + luma(40))],
          [#line(length: 100%, stroke: 0.8pt + luma(40))],
          [#translations.place], [#translations.date], [#translations.signature],
        )
      }
    ]


    v(12pt)
  }

  if confidential {
    align(bottom)[

      #box(
        stroke: 1pt + luma(30),
        width: 100%,
        inset: 12pt,
      )[
        #align(center)[
          #text(size: 18pt, weight: "bold")[#translations.confidential-title]
        ]
        #v(8pt)
        #if confidential-text == none {
          translations.confidential-body
        } else {
          confidential-text
        }
      ]
    ]
  }
}
