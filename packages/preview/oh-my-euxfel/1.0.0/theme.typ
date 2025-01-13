#import "@preview/polylux:0.3.1": *

#let xDarkBlue = rgb(11, 21, 70)
#let xOrange = rgb(243, 146, 0)
#let xLightBlue = rgb(85, 157, 187)


#let euxfel-theme(aspect-ratio: "16-9",
                  title: "Title", author: "Author",
                  title-page-header: true,
                  font: "New Computer Modern Sans",
                  body) = {
  let item-rect(fill-color) = [#rect(width: 30pt, height: 15pt, fill: fill-color)]
  set list(marker: ([#item-rect(xOrange)],
                    [#item-rect(xLightBlue)],
                    [#image("subsubitem.svg")]))
  set text(size: 18pt, font: font)

  set page(
    paper: "presentation-" + aspect-ratio,
    margin: (top: 70pt),
    header: context {
      if title-page-header or counter(page).get().first() > 1 {
        set text(size: 12pt)

        grid(columns: (1fr, 1fr), column-gutter: 50pt,
          {line(length: 100%); title},
          {stack(dir: ltr,
            align(left)[#line(length: 100%); #author],
            align(right)[#counter(page).display()]
          )}
        )
      }
    },
    footer: [
      #set text(size: 15pt)

      #stack(dir: ltr, spacing: 5pt,
        rect(width: 80pt, height: 10pt, fill: xDarkBlue),
        rect(width: 30pt, height: 10pt, fill: xDarkBlue),
        rect(width: 15pt, height: 10pt, fill: xOrange),
        [*European XFEL*]
      )
    ]
  )

  polylux-slide[
    #align(horizon)[
      #grid(
        columns: (3fr, 1fr),
        column-gutter: 50pt,

        align(left)[
          #set text(size: 22pt)
          = #title

          #author
        ],

        align(right)[
          #image("logo.svg")
        ]
      )
    ]
  ]

  body
}

#let slide(title, body) = {
  polylux-slide[
    == #title

    #v(15pt)

    #body
  ]
}
