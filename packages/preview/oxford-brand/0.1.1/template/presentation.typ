#import "oxford.typ": colours

#let presentation(
  logo: "../assets/oxford-logo-square-rgb.png",
  secondary-logo: none,
  secondary: none,
) = {
  let serif = ("Noto Serif", "Times New Roman")
  let sans = ("Roboto", "Arial")
  let notch = "../assets/oxford-notched-line.png"
  let notch-white = "../assets/oxford-notched-line-white.png"
  let logo-x = 0.85in
  let logo-size = 0.78in

  let base(dark: false, fill: none, body) = {
    set page(
      width: 13.333in,
      height: 7.5in,
      margin: 0pt,
      fill: if fill != none { fill } else if dark { colours.blue } else { white },
    )
    set text(font: sans, fill: if dark { white } else { colours.blue })
    body
  }

  let lockup(dark: false, size: logo-size, x: logo-x, y: 0.35in) = place(top + left, dx: x, dy: y)[
    #if secondary-logo != none {
      grid(
        columns: (size, 0.06in, size), column-gutter: 0.05in,
        image(logo, width: size),
        align(center + horizon, image(if dark { notch-white } else { notch }, height: 0.72in, fit: "contain")),
        image(secondary-logo, width: size),
      )
    } else if secondary != none {
      grid(
        columns: (size, 0.06in, 2.7in), column-gutter: 0.05in,
        image(logo, width: size),
        align(center + horizon, image(if dark { notch-white } else { notch }, height: 0.72in, fit: "contain")),
        align(left + horizon, text(size: 13pt, fill: if dark { white } else { colours.blue })[#secondary]),
      )
    } else {
      image(logo, width: size)
    }
  ]

  let footer(dark: false, credit: none) = place(bottom + right, dx: -0.55in, dy: -0.28in)[
    #text(size: 8pt, fill: if dark { colours.cool-grey } else { colours.ash-grey })[
      #if credit != none { credit + h(0.18in) } University of Oxford
    ]
  ]

  // A supplied Typst figure/chart takes precedence over a simple image path.
  let figure-box(visual: none, picture: none, width: 4.4in, height: 3.2in) = block(width: width, height: height)[
    #align(center + horizon)[
      #if visual != none { visual } else if picture != none { image(picture, width: width, height: height, fit: "contain") }
    ]
  ]

  let visual-area(visual: none, picture: none, height: 4.35in) = block(
    width: 12.0in,
    height: height,
    fill: colours.off-white,
    inset: 0.28in,
  )[
    #if visual != none { visual } else if picture != none { align(center + horizon)[image(picture, width: 11.44in, height: height - 0.56in, fit: "contain")] }
  ]

  (
    title_image: (title, picture, credit: none) => [
      #pagebreak(weak: true)
      #base()[
        #place(top + left, dx: 0.16in, dy: 0.12in)[#image(picture, width: 13.013in, height: 7.26in, fit: "cover")]
        #place(top + left, dy: 0.95in)[#rect(width: 6.8in, height: 6.55in, fill: colours.blue)]
        #lockup(size: 1.2in, y: 0.35in)
        #place(left + top, dx: logo-x, dy: 3.4in)[
          #block(width: 5.7in)[#text(font: serif, size: 32pt, fill: white)[#title]]
        ]
        #if credit != none {
          place(bottom + right, dx: -0.55in, dy: -0.28in)[#text(size: 8pt, fill: white)[#credit]]
        }
      ]
    ],
    title: (title, subtitle: none, dark: false) => [
      #pagebreak(weak: true)
      #base(dark: dark)[
        #place(top + left)[#rect(width: 13.333in, height: 0.95in, fill: if dark { white } else { colours.blue })]
        #lockup(dark: not dark, size: 1.2in, y: 0.35in)
        #if dark {
          place(left + bottom, dx: logo-x, dy: -0.85in)[
            #block(width: 10.8in)[
              #text(font: serif, size: 32pt)[#title]
              #if subtitle != none { v(0.2in); text(size: 16pt)[#subtitle] }
            ]
          ]
        } else {
          place(left + top, dx: logo-x, dy: 2.7in)[
            #block(width: 7.4in)[
              #text(font: serif, size: 32pt)[#title]
              #if subtitle != none { v(0.2in); text(size: 16pt)[#subtitle] }
            ]
          ]
        }
        #footer(dark: dark)
      ]
    ],
    section: (title) => [
      #pagebreak(weak: true)
      #base(fill: colours.off-white)[
        #lockup()
        #place(left + horizon, dx: logo-x)[#text(font: serif, size: 34pt)[#title]]
        #place(left + horizon, dx: 0.35in)[#rect(width: 0.12in, height: 1.5in, fill: colours.blue)]
        #footer()
      ]
    ],
    text_only: (title, lead: none, body: none, panel: false) => [
      #pagebreak(weak: true)
      #base()[
        #lockup()
        #if panel { place(left + top, dx: 0.65in, dy: 1.45in)[#rect(width: 12.0in, height: 4.9in, fill: colours.off-white)] }
        #place(left + top, dx: if panel { 0.85in } else { logo-x }, dy: 1.65in)[
          #block(width: if panel { 11.44in } else { 9.9in })[
            #text(font: serif, size: 32pt)[#title]
            #if lead != none { v(0.22in); text(size: 17pt)[#lead] }
            #if body != none { v(0.28in); text(size: 16pt, fill: colours.charcoal)[#body] }
          ]
        ]
        #footer()
      ]
    ],
    text_figure: (title, lead: none, body: none, visual: none, picture: none, credit: none) => [
      #pagebreak(weak: true)
      #base()[
        #lockup()
        #place(left + top, dx: logo-x, dy: 1.65in)[
          #block(width: if visual == none and picture == none { 9.9in } else { 6.25in })[
            #text(font: serif, size: 30pt)[#title]
            #if lead != none { v(0.22in); text(size: 17pt)[#lead] }
            #if body != none { v(0.22in); text(size: 16pt, fill: colours.charcoal)[#body] }
          ]
        ]
        #if visual != none or picture != none { place(right + bottom, dx: -0.55in, dy: -0.55in)[#figure-box(visual: visual, picture: picture)] }
        #footer(credit: credit)
      ]
    ],
    two_column: (title, left-title, left-body, right-title, right-body) => [
      #pagebreak(weak: true)
      #base()[
        #lockup()
        #place(left + top, dx: logo-x, dy: 1.65in)[#text(font: serif, size: 30pt)[#title]]
        #place(left + top, dx: logo-x, dy: 2.65in)[
          #grid(
            columns: (5.0in, 5.0in), column-gutter: 0.45in,
            [#text(size: 16pt, fill: colours.charcoal)[#text(fill: colours.blue)[#left-title]#linebreak()#left-body]],
            [#text(size: 16pt, fill: colours.charcoal)[#text(fill: colours.blue)[#right-title]#linebreak()#right-body]],
          )
        ]
        #footer()
      ]
    ],
    two_column_figure: (title, left-title, left-body, right-title, right-body, visual: none, picture: none, credit: none) => [
      #pagebreak(weak: true)
      #base()[
        #lockup()
        #place(left + top, dx: logo-x, dy: 1.65in)[#text(font: serif, size: 30pt)[#title]]
        #place(left + top, dx: logo-x, dy: 2.65in)[
          #grid(
            columns: (2.75in, 2.75in), column-gutter: 0.35in,
            [#text(size: 16pt, fill: colours.charcoal)[#text(fill: colours.blue)[#left-title]#linebreak()#left-body]],
            [#text(size: 16pt, fill: colours.charcoal)[#text(fill: colours.blue)[#right-title]#linebreak()#right-body]],
          )
        ]
        #if visual != none or picture != none { place(right + bottom, dx: -0.55in, dy: -0.55in)[#figure-box(visual: visual, picture: picture)] }
        #footer(credit: credit)
      ]
    ],
    three_column: (title, first-title, first-body, second-title, second-body, third-title, third-body) => [
      #pagebreak(weak: true)
      #base()[
        #lockup()
        #place(left + top, dx: logo-x, dy: 1.65in)[#text(font: serif, size: 30pt)[#title]]
        #place(left + top, dx: logo-x, dy: 2.65in)[
          #grid(
            columns: (3.2in, 3.2in, 3.2in), column-gutter: 0.32in,
            [#text(size: 16pt, fill: colours.charcoal)[#text(fill: colours.blue)[#first-title]#linebreak()#first-body]],
            [#text(size: 16pt, fill: colours.charcoal)[#text(fill: colours.blue)[#second-title]#linebreak()#second-body]],
            [#text(size: 16pt, fill: colours.charcoal)[#text(fill: colours.blue)[#third-title]#linebreak()#third-body]],
          )
        ]
        #footer()
      ]
    ],
    box_grid: (title, items, nrows: 2, ncols: 2, highlighted: (), deactivated: ()) => [
      #page(width: 13.333in, height: 7.5in, margin: 0pt, fill: white)[
        #set text(font: sans, fill: colours.blue)
        #let row-height = (3.8in - (nrows - 1) * 0.18in) / nrows
        #place(left + top, dx: logo-x, dy: 1.65in)[#block(width: 11.44in)[#text(font: serif, size: 30pt)[#title]]]
        #place(left + top, dx: 0.65in, dy: 2.55in)[
          #block(width: 12.0in, height: 3.8in)[
            #grid(
              columns: range(ncols).map(_ => 1fr),
              rows: range(nrows).map(_ => row-height),
              column-gutter: 0.18in,
              row-gutter: 0.18in,
              ..items.enumerate().map(((i, item)) => {
                let number = i + 1
                let active = highlighted.contains(number)
                let muted = deactivated.contains(number)
                block(
                  width: 100%,
                  height: 100%,
                  fill: if active { colours.royal-blue } else if muted { rgb("#FAF9F9") } else { colours.off-white },
                  inset: 0.24in,
                )[
                  #text(size: 18pt, fill: if active { white } else if muted { colours.stone-grey } else { colours.charcoal })[#item]
                ]
              }),
            )
          ]
        ]
        #lockup()
        #footer()
      ]
    ],
    image_caption: (picture, caption, credit: none) => [
      #pagebreak(weak: true)
      #base()[
        #place(top + left)[#rect(width: 13.333in, height: 7.5in, fill: white)]
        #place(top + left, dx: 0.28in, dy: 0.74in)[#image(picture, width: 12.773in, height: 6.02in, fit: "cover")]
        #place(top + left, dy: 6.76in)[#rect(width: 13.333in, height: 0.74in, fill: colours.blue)]
        #lockup(dark: true, y: 6.37in)
        #place(left + bottom, dx: 0.65in, dy: -1.3in)[
          #block(width: 6.0in, fill: colours.blue, inset: (x: 0.27in, y: 0.24in))[
            #text(size: 16pt, fill: white)[#caption]
          ]
        ]
        #if credit != none { place(bottom + right, dx: -0.55in, dy: -0.28in)[#text(size: 8pt, fill: white)[#credit]] }
      ]
    ],
    figure: (visual: none, picture: none, title: none, credit: none) => [
      #pagebreak(weak: true)
      #base()[
        #if visual != none {
          place(top + left)[#block(width: 13.333in, height: 7.5in)[#align(center + horizon)[#visual]]]
        } else if picture != none {
          place(top + left)[#image(picture, width: 13.333in, height: 7.5in, fit: "cover")]
        }
        #if title != none {
          place(left + top, dx: 0.85in, dy: 0.85in)[
            #block(width: 6.4in, fill: colours.blue, inset: 0.25in)[#text(font: serif, size: 28pt, fill: white)[#title]]
          ]
        }
        #if credit != none { place(bottom + right, dx: -0.55in, dy: -0.28in)[#text(size: 8pt, fill: white)[#credit]] }
      ]
    ],
    visual_caption: (title, visual: none, picture: none, credit: none) => [
      #pagebreak(weak: true)
      #base()[
        #lockup()
        #place(left + top, dx: 0.65in, dy: 1.55in)[
          #block(width: 12.0in, fill: colours.blue, inset: (x: 0.28in, y: 0.18in))[
            #text(font: serif, size: 24pt, fill: white)[#title]
          ]
        ]
        #place(left + top, dx: 0.65in, dy: 2.45in)[#visual-area(visual: visual, picture: picture, height: 3.9in)]
        #footer(credit: credit)
      ]
    ],
    contact: (name, organisation, url, social: none, dark: false) => [
      #pagebreak(weak: true)
      #base(dark: dark, fill: if dark { none } else { colours.off-white })[
        #place(top + left, dy: 6.76in)[#rect(width: 13.333in, height: 0.74in, fill: if dark { colours.off-white } else { colours.blue })]
        #lockup(dark: not dark, y: 6.37in)
        #place(left + top, dx: logo-x, dy: 1.75in)[
          #text(size: 15pt)[Contact us]
          #v(0.12in)
          #text(size: 13pt, fill: if dark { white } else { colours.charcoal })[#organisation#linebreak()#name#linebreak()#url]
        ]
        #if social != none { place(left + top, dx: logo-x, dy: 4.95in)[#text(size: 11pt, fill: if dark { white } else { colours.charcoal })[#social]] }
        #place(bottom + right, dx: -0.55in, dy: -0.28in)[#text(size: 8pt, fill: if dark { colours.blue } else { white })[University of Oxford]]
      ]
    ],
  )
}
