#let layouts = (
  "small": ("height": 9cm, "space": 1.4cm),
  "medium": ("height": 10.5cm, "space": 1.6cm),
  "large": ("height": 12cm, "space": 1.8cm),
)

#let slides(
  content,
  title: none,
  subtitle: none,
  footer-title: none,
  footer-subtitle: none,
  date: none,
  authors: (:),
  layout: "medium",
  ratio: 4/3,
  count: "dot",
  footer: true,
  toc: true,
  theme: "normal"
) = {
  // Theme Color of Tsinghua University
  let theme-color = color.rgb(102, 8, 116) // Tsinghua Red
  // Parsing
  if layout not in layouts {
      panic("Unknown layout " + layout)
  }
  let (height, space) = layouts.at(layout)
  let width = ratio * height

  if count not in (none, "dot", "number") {
    panic("Unknown Count, valid counts are 'dot' and 'number', or none")
  }

  if theme not in ("normal", "full") {
      panic("Unknown Theme, valid themes are 'full' and 'normal'")
  }

  // Colors
  if theme-color == none {
      theme-color = blue.darken(50%)
  }
  let block-color = theme-color.lighten(90%)
  let body-color = theme-color.lighten(80%)
  let header-color = theme-color.lighten(65%)
  let fill-color = theme-color.lighten(50%)

  // Setup
  set document(
    title: title,
    author: for pair in authors {
      pair.at(0) + ": " + pair.at(1) + "\n"
    },
  )
  set heading(numbering: "1.a")

  // PAGE----------------------------------------------
  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: 1.0 * space, bottom: 0.6 * space),
  // HEADER
    header: [
      #context {
        let page = here().page()
        let headings = query(selector(heading.where(level: 2)))
        let heading = headings.rev().find(x => x.location().page() <= page)

        if heading != none {
          set align(top)
          if (theme == "full") {
            block(
              width: 100%,
              fill: theme-color,
              height: space * 0.85,
              outset: (x: 0.5 * space)
            )[
              #set text(1.4em, weight: "bold", fill: white)
              #v(space / 2)
              #heading.body
              #if not heading.location().page() == page [
                #{numbering("(i)", page - heading.location().page() + 1)}
              ]
            ]
          } else if (theme == "normal") {
            v(space / 8)
            grid(
              columns: (3fr, 1fr),
              align: (left + top, right + top),
              // fill: (white.darken(50%), white.darken(80%)), // DEBUG
              block(
                width: 100%,
                height: 100%
              )[
                #set text(1.4em, weight: "bold", fill: theme-color)
                #v(space / 4)
                #heading.body
                #if not heading.location().page() == page [
                  #{numbering("(i)", page - heading.location().page() + 1)}
                ]
              ],
              block(
                width: 100%,
                height: 100%
              )[
                #image(
                  "img/logo.png",
                  height: 65%,
                )
              ]
            )
          }
        }
    }
  // COUNTER
    #if count == "dot" {
      v(-space / 1.8)
      set align(right + top)
      context {
        let last = counter(page).final().first()
        let current = here().page()
        // Before the current page
        for i in range(1,current) {
          link((page:i, x:0pt,y:0pt))[
            #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt+fill-color))
          ]
        }
        // Current Page
        link((page:current, x:0pt,y:0pt))[
            #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt+fill-color))
          ]
        // After the current page
        for i in range(current+1,last+1) {
          link((page:i, x:0pt,y:0pt))[
            #box(circle(radius: 0.08cm, stroke: 1pt+fill-color))
          ]
        }
      }
    } else if count == "number" {
      v(-space / 1.5)
      set align(right + top)
      context {
        let last = counter(page).final().first()
        let current = here().page()
        set text(weight: "bold")
        set text(fill: white) if theme == "full"
        set text(fill: theme-color) if theme == "normal"
        [#current / #last]
      }
    }
    ],
    header-ascent: 0%,
  // FOOTER
    footer: [
      #if footer == true {
        set text(0.7em)
        // Colored Style
        if (theme=="full") {
          columns(2, gutter:0cm)[
            // Left side of the Footer
            #align(left)[#block(
              width: 100%,
              outset: (left:0.5*space, bottom: 0cm),
              height: 0.3*space,
              fill: fill-color,
              inset: (right:3pt)
            )[
              #v(0.1*space)
              #set align(right)
              #smallcaps()[#if footer-title != none {footer-title} else {title}]
              ]
            ]
            // Right Side of the Footer
            #align(right)[#block(
              width: 100%,
              outset: (right:0.5*space, bottom: 0cm),
              height: 0.3*space,
              fill: body-color,
              inset: (left: 3pt)
            )[
              #v(0.1*space)
              #set align(left)
              #if footer-subtitle != none {
                  footer-subtitle
              } else if subtitle != none {
                  subtitle
              } else {
                date
              }
            ]
          ]
          ]
        }
        // Normal Styling of the Footer
        else if (theme == "normal") {
          box()[#line(length: 50%, stroke: 2pt+fill-color )]
          box()[#line(length: 50%, stroke: 2pt+body-color)]
          v(-0.3cm)
          grid(
            columns: (1fr, 1fr),
            align: (right,left),
            inset: 4pt,
            [#smallcaps()[
              #if footer-title != none {footer-title} else {title}]],
            [#if footer-subtitle != none {
                footer-subtitle
            } else if subtitle != none {
                subtitle
            } else if authors != none {
                  if (type(authors) != array) {authors = (authors,)}
                  authors.join(", ", last: " and ")
                } else [#date]
            ],

          )
        }
      }
    ],
    footer-descent:0.3*space,
  )


  // SLIDES STYLING--------------------------------------------------
  // Section Slides
  show heading.where(level: 1): x => {
    set page(header: none,footer: none, margin: 0cm)
    set align(horizon)
      grid(
        columns: (1fr, 3fr),
        inset: 10pt,
        align: (horizon, left),
        fill: (theme-color, white),
        [#block(height: 100%)[
          #place(
            horizon + right,
            image(
              "img/logo_2.png",
              height: 70%,
            ),
            dx: 90pt,
          )
        ]],
        [#text(1.2em, weight: "bold", fill: theme-color)[#x]]
      )

  }
  show heading.where(level: 2): pagebreak(weak: true) // this is where the magic happens
  show heading: set text(1.1em, fill: theme-color)


  // ADD. STYLING --------------------------------------------------
  // Terms
  show terms.item: it => {
    set block(width: 100%, inset: 5pt)
    stack(
      block(fill: header-color, radius: (top: 0.2em, bottom: 0cm), strong(it.term)),
      block(fill: block-color, radius: (top: 0cm, bottom: 0.2em), it.description),
    )
  }

  // Code
  show raw.where(block: false): it => {
    box(fill: block-color, inset: 1pt, radius: 1pt, baseline: 1pt)[#text(size:8pt ,it)]
  }

  show raw.where(block: true): it => {
    block(radius: 0.5em, fill: block-color,
          width: 100%, inset: 1em, it)
  }

  // Bullet List
  show list: set list(marker: (
    text(fill: theme-color)[•],
    text(fill: theme-color)[‣],
    text(fill: theme-color)[-],
  ))

  // Enum
  let color_number(nrs) = text(fill:theme-color)[*#nrs.*]
  set enum(numbering: color_number)

  // Table
  show table: set table(
    stroke: (x, y) => (
      x: none,
      bottom: 0.8pt+black,
      top: if y == 0 {0.8pt+black} else if y==1 {0.4pt+black} else { 0pt },
    )
  )

  show table.cell.where(y: 0): set text(
    style: "normal", weight: "bold") // for first / header row

  set table.hline(stroke: 0.4pt+black)
  set table.vline(stroke: 0.4pt)

  // Quote
  set quote(block: true)
  show quote.where(block: true): it => {
    v(-5pt)
    block(
      fill: block-color, inset: 5pt, radius: 1pt,
      stroke: (left: 3pt+fill-color), width: 100%,
      outset: (left:-5pt, right:-5pt, top: 5pt, bottom: 5pt)
      )[#it]
    v(-5pt)
  }

  // Link
  show link: it => {
    if type(it.dest) != str { // Local Links
      it
    }
    else {
      underline(stroke: 0.5pt+theme-color)[#it] // Web Links
    }
  }

  // Outline
  set outline(
    // target: heading.where(level: 1),
    indent: auto,
  )

  show outline: set heading(level: 2) // To not make the TOC heading a section slide by itself
  // Bibliography
  set bibliography(
    title: none
  )


  // CONTENT---------------------------------------------
  // Title Slide
  if (title == none) {
    panic("A title is required")
  }
  else {
    if (type(authors) != dictionary) {
      panic("Authors must be an dictionary")
    }
    set page(footer: none, header: none, margin: 0cm)
    // block for the title
    block(
      inset: (x:0.5*space, y:2em),
      fill: theme-color,
      width: 100%,
      height: 60%,
      align(bottom)[#text(2.0em, weight: "bold", fill: white, title)]
    )
    // block for the subtitle
    block(
      above: 0%,
      height: 20%,
      width: 100%,
      // fill: theme_color.lighten(90%), // DEBUG
      inset: (x:0.5*space,top:1em, bottom: 1em),
      if subtitle != none {[
        #text(1.4em, fill: theme-color, weight: "bold", subtitle)
      ]}
    )
    // block for the authors and logo
    block(
      above: 0%,
      height: 20%,
      width: 100%,
      // fill: theme_color.lighten(80%), // DEBUG
      inset: 0em,
      grid(
        columns: (2fr, 1fr),
        // fill: (theme_color.lighten(80%), theme_color.lighten(90%)), // DEBUG
        align: (left + bottom, right + bottom),
        inset: 0em,
        gutter: 0em,
        block(
          width: 100%,
          height: 100%,
          // fill: theme_color.lighten(80%), // DEBUG
          inset: (x:0.6*space, y:0.35*space),
        )[#align(left + bottom)[
          #for pair in authors {
            pair.at(1) + "\n"
          }
          ]
        ],
        block(
          width: 100%,
          height: 100%,
          // fill: theme_color.lighten(90%), // DEBUG
          inset: (x:0.3*space, y:0.2*space),
        )[
          #image(
          "img/logo.png",
          // height:15%,
          )
        ]
      )
    )
  }

  // Outline
  if (toc == true) {
    outline()
  }
  // Normal Content
  content

}
