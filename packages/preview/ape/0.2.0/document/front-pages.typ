#let front-pages(style, small-caps, title, title-page, authors, outline, custom-outline) = {
  let sc(c) = {
    if small-caps == true {
      return smallcaps(c)
    } else {
      return c
    }
  }

  let small-title3 = {
    line(length: 100%)
    text(
      size: 22pt,
      font: "Noto Sans Georgian",
      align(
        center,
        [
          *#title.at(0) - #title.at(1)*
        ],
      ),
    )


    line(length: 100%)
    v(15pt)
  }
  let small-title2 = {
    align(
      center,
      box(
        width: 110%,
        inset: 0.75cm,

        radius: 0.5cm,
        stroke: 1pt,
        [



          #place(
            dy: -1.2cm,
            [
              #rect(fill: white)[
                #text(size: 20pt, [*#title.at(0)*])
              ]
            ],
          )




          #{
            if title.at(1).len() > 0 {
              place(
                dy: 0.3cm,
                dx: 99% - measure(text(size: 16pt, [*#title.at(1)*])).width,
                [
                  #rect(fill: white)[
                    #text(size: 16pt, [*#title.at(1)*])
                  ]
                ],
              )
            }
          }

        ],
      ),
    )
  }
  let small-title1 = {
    if type(title) == "string" {
      align(
        center,
        box(
          width: 110%,
          inset: 0.75cm,

          radius: 0.5cm,
          stroke: 1pt,
          [
            #set text(size: 20pt)
            #strong(title)
          ],
        ),
      )
    }
  }

  let small-title = {
    if style == "presentation" { } else if type(title) == "array" {
      if title-page or outline {
        small-title3
      } else {
        small-title2
      }
    } else {
      small-title1
    }
  }


  if title-page {
    align(
      center + horizon,
      [
        #text(
          hyphenate: false,
          {
            if type(title) == "string" {
              text(size: 7em, sc[*#title*])
            } else {
              [
                #text(size: 6em, sc(strong(title.at(1))))
                #v(-4em)
                #text(size: 3em, sc(title.at(0)))
              ]
            }
          },
        )


        #v(1cm)
        #{
          if type(authors) == "array" {
            if authors.len() > 0 {
              [
                #text(size: 1.45em, sc(authors.at(0)))
                \
              ]
            }
            if authors.len() > 1 {
              [
                #text(size: 1.45em, authors.slice(1).map(sc).join(" - "))
              ]
            }
          } else {
            [
              #text(size: 1.45em, sc(authors))
            ]
          }
        }



      ],
    )

    pagebreak()
    if outline {
      custom-outline
      pagebreak()
    }

    small-title
  } else {
    if outline {
      custom-outline
      pagebreak()
    }

    small-title

    v(15pt)
  }
}
