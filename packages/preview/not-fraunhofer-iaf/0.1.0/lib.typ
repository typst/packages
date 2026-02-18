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
  footer-clearance: "Restricted",
  date: none,
  authors: (),
  layout: "medium",
  ratio: 4/3,
  first-slide: true,
  bg-color: white,
  count: "dot",
  footer: true,
  toc: true,
  theme: "normal",
) = {
  // Parsing
  if layout not in layouts {
    panic("Unknown layout " + layout)
  }
  let (height, space) = layouts.at(layout)
  let width = ratio * height
  
  if count not in (none, "dot", "number", "dot-section") {
    panic("Unknown Count, valid counts are 'dot' and 'number', or none")
  }
  
  if theme not in ("normal", "full") {
    panic("Unknown Theme, valid themes are 'full' and 'normal'")
  }
  
  // Colors
  let title-color = color.rgb("#369b7d")
  let block-color = title-color.lighten(90%)
  let body-color = title-color.lighten(80%)
  let header-color = title-color.lighten(65%)
  let fill-color = title-color.lighten(50%)

  // Global logo (shown on every slide, bottom-right)
  let logo = image("logo/logo.jpg", width: 2cm)

  // Global font
  set text(font: "Frutiger LT Com",weight: "light")
  
  // Setup
  set document(
    title: title,
    author: authors,
  )
  set heading(numbering: "1.a")
  
  // PAGE----------------------------------------------
  set page(
    fill: bg-color,
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space * 1.2, bottom: 0.8 * space),
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
              fill: title-color,
              height: space * 0.85,
              outset: (x: 0.5 * space),
            )[
              #set text(1.4em, weight: "bold", fill: bg-color)
              #v(space / 2)
              #heading.body
              #if not heading.location().page() == page [
                #{ numbering("(i)", page - heading.location().page() + 1) }
              ]
            ]
          } else if (theme == "normal") {
            set text(1.4em, weight: "bold", fill: title-color)
            v(space / 2)
            heading.body
            if not heading.location().page() == page [
              #{ numbering("(i)", page - heading.location().page() + 1) }
            ]
          }
        }
      }
      // COUNTER ============================================================
      
      #if count == "dot" {
        // DOT COUNTER -------------------------
        
        set align(right + top)
        context {
          let last = counter(page).final().first()
          let current = here().page()
          let limit = calc.ceil(last / 2)
          // the limit automatically allows to have even rows of dots
          
          // if number of pages > 20
          if last > 20 {
            v(-space / 1.3)
            // first row of dots
            for i in range(1, limit + 1) {
              // Before the current page
              if i <= current {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.06cm, fill: fill-color, stroke: 1pt + fill-color))
                ]
              } // After the current page
              else {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.06cm, stroke: 1pt + fill-color))
                ]
              }
            }
            v(-space / 1.6)
            linebreak()
            // second row of dots
            for i in range(limit + 1, last + 1) {
              // Before the current page
              if i <= current {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.06cm, fill: fill-color, stroke: 1pt + fill-color))
                ]
              } // After the current page
              else {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.06cm, stroke: 1pt + fill-color))
                ]
              }
            }
          } else {
            // Normal Counter if number of pages < 20
            v(-space / 1.5)
            for i in range(1, last + 1) {
              // Before and including the current page
              if i <= current {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt + fill-color))
                ]
              } // After the current page
              else {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.08cm, stroke: 1pt + fill-color))
                ]
              }
            }
          }
        }
      } else if count == "dot-section" {
        // DOT SECTION COUNTER -------------------------
        v(-space / 1.5)
        set align(right + top)
        context {
          let last = counter(page).final().first()
          let current = here().page()
          
          // Logic to find the current section
          let sections = query(heading.where(level: 1))
          let current_section_nr = counter(heading).get().at(0)
          let current_section_page = {
            if current_section_nr > 0 {
              sections.at(int(current_section_nr - 1)).location().page()
            } else { 1 } // special case for first section (typically outline)
          }
          
          let next_section_page = {
            if current_section_nr < int(sections.len()) {
              sections.at(int(current_section_nr)).location().page()
            } else { last }
          }
          
          // Display the counter for all except last section
          if next_section_page - current_section_page < 3 {
            // For sections that only have 1 page leave the counter blank
            // NOTE: that it also dosnt show a counter if last section < 2 pages
          } else if current_section_nr < int(sections.len()) {
            // Current Section Dot
            link((page: current_section_page, x: 0pt, y: 0pt))[
              #box(rotate(-90deg)[#polygon.regular(
                stroke: 1pt + fill-color,
                size: 0.2cm,
                vertices: 3,
              )]) #h(0.1cm)
            ]
            // Prec and Current Pages Dot
            for i in range(current_section_page + 1, next_section_page) {
              if i <= current {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt + fill-color))
                ]
              } else {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.08cm, stroke: 1pt + fill-color))
                ]
              }
            }
            // Next Section Dot
            link((page: next_section_page, x: 0pt, y: 0pt))[
              #h(0.1cm) #box(rotate(90deg)[#polygon.regular(
                stroke: 1pt + fill-color,
                size: 0.2cm,
                vertices: 3,
              )])
            ]
          } else {
            // Current Section Dot
            link((page: current_section_page, x: 0pt, y: 0pt))[
              #box(rotate(-90deg)[#polygon.regular(
                stroke: 1pt + fill-color,
                size: 0.2cm,
                vertices: 3,
              )]) #h(0.1cm)
            ]
            // Prec and Current Pages Dot (note that the last slide is included by extending range + 1)
            for i in range(current_section_page + 1, next_section_page + 1) {
              if i <= current {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt + fill-color))
                ]
              } else {
                link((page: i, x: 0pt, y: 0pt))[
                  #box(circle(radius: 0.08cm, stroke: 1pt + fill-color))
                ]
              }
            }
          }
        }
      } else if count == "number" {
        // NUMBER COUNTER -------------------------
        v(-space / 1.5)
        set align(right + top)
        context {
          let last = counter(page).final().first()
          let current = here().page()
          set text(weight: "bold")
          set text(fill: white) if theme == "full"
          set text(fill: title-color) if theme == "normal"
          [#current / #last]
        }
      }
    ],
    header-ascent: 0%,
    // FOOTER ----------------------------------------------------
    footer: [
      #if footer == true {
        set text(0.7em)
        stack(
          spacing: 0pt,
          [
            // Colored Style
            #if (theme == "full") {
              columns(3, gutter: 0cm)[
                // Left side of the Footer
                #align(left)[#block(
                    width: 100%,
                    outset: (left: 0.5 * space, bottom: 0cm),
                    height: 0.3 * space,
                    fill: fill-color,
                    inset: (right: 3pt),
                  )[
                    #v(0.1 * space)
                    #set align(right)
                    #if footer-title != none {
                      smallcaps[footer-title]
                    } else {
                      context {
                        let current = here().page()
                        "Page " + str(current)
                      }
                    }
                  ]
                ]

                // Center Side of the Footer
                #align(center)[#block(
                    width: 100%,
                    outset: (right: 0.5 * space, bottom: 0cm),
                    height: 0.3 * space,
                    fill: body-color,
                    inset: (left: 3pt),
                  )[
                    #v(0.1 * space)
                    #set align(center)
                    #if footer-clearance != none {
                      strong(footer-clearance)
                    } else if date != none {
                      [#date]
                    } else {
                      none
                    }
                  ]
                ]
                
                // Right Side of the Footer
                #align(right)[#block(
                    width: 100%,
                    outset: (right: 0.5 * space, bottom: 0cm),
                    height: 0.3 * space,
                    fill: block-color,
                    inset: (left: 3pt),
                  )[
                    #v(0.1 * space)
                    #set align(left)
                    #if authors != none {
                      if (type(authors) != array) { authors = (authors,) }
                      authors.join(", ", last: " and ")
                    } else {
                      none
                    }
                  ]
                ]
              ]
            } else if (theme == "normal") {
              // Normal Styling of the Footer
              box()[#line(length: 50%, stroke: 2pt + fill-color)]
              box()[#line(length: 50%, stroke: 2pt + body-color)]
              v(-0.33cm)
              grid(
                columns: (1fr, 1fr, 1fr),
                align: (left, center, right),
                inset: 4pt,

                // Left: footer-title or page number
                [
                  #smallcaps()[
                    #if footer-title != none {
                      footer-title
                    } else {
                      context {
                        let current = here().page()
                        "Page " + str(current)
                      }
                    }
                  ]
                ],

                // Center: clearance or date
                [
                  #if footer-clearance != none {
                    strong(footer-clearance)
                  } else if date != none {
                    date
                  } else {
                    none
                  }
                ],

                // Right: authors
                [
                  #if authors != none {
                    if (type(authors) != array) { authors = (authors,) }
                    authors.join(", ", last: " and ")
                  } else {
                    none
                  }
                ],
              )
            }
          ],

          [
            #align(bottom + right)[
              #box(inset: 0.8cm)[
                #logo
              ]
            ]
          ],
        )
      }
    ],
    footer-descent: 0.5 * space,

    // LOGO ON EVERY SLIDE --------------------------------------
    foreground: [
      #align(bottom + right)[
        #box(inset: 0.8cm)[
          #logo
        ]
      ]
    ],
  )
  
  
  // SLIDES STYLING --------------------------------------------------
  // Section Slides
  show heading.where(level: 1): x => {
    set page(header: none, footer: none, margin: 0cm)
    set align(horizon)
    grid(
      columns: (1fr, 3fr),
      inset: 10pt,
      align: (right, left),
      fill: (title-color, bg-color),
      [#block(height: 100%)], [#text(1.2em, weight: "bold", fill: title-color)[#x]],
    )
  }
  show heading.where(level: 2): pagebreak(weak: true) // this is where the magic happens
  show heading: set text(1.1em, fill: title-color)
  
  
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
    box(fill: block-color, inset: 1pt, radius: 1pt, baseline: 1pt)[#text(it)]
  }
  
  show raw.where(block: true): it => {
    block(radius: 0.5em, fill: block-color, width: 100%, inset: 1em, it)
  }
  
  // Bullet List
  show list: set list(marker: (
    text(fill: title-color)[•],
    text(fill: title-color)[‣],
    text(fill: title-color)[⁃],
    text(fill: title-color)[-],
  ))
  
  // Enum
  let color_number(nrs) = text(fill: title-color)[*#nrs.*]
  set enum(numbering: color_number)
  
  // Table
  show table: set table(
    stroke: (x, y) => (
      x: none,
      bottom: 0.8pt + black,
      top: if y == 0 { 0.8pt + black } else if y == 1 { 0.4pt + black } else { 0pt },
    ),
  )
  
  show table.cell.where(y: 0): set text(
    style: "normal",
    weight: "bold",
  ) // for first / header row
  
  set table.hline(stroke: 0.4pt + black)
  set table.vline(stroke: 0.4pt)
  
  // Quote
  set quote(block: true)
  show quote.where(block: true): it => {
    v(-5pt)
    block(
      fill: block-color,
      inset: 5pt,
      radius: 1pt,
      stroke: (left: 3pt + fill-color),
      width: 100%,
      outset: (left: -5pt, right: -5pt, top: 5pt, bottom: 5pt),
    )[#it]
    v(-5pt)
  }
  
  // Link
  show link: it => {
    if type(it.dest) != str {
      // Local Links
      it
    } else {
      underline(stroke: 0.5pt + title-color)[#it] // Web Links
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
    title: none,
  )
  
  
  // CONTENT---------------------------------------------
  // Title Slide
  if (title == none) {
    panic("A title is required")
  } else if (first-slide == false) {
    // Remove the first page for custom arrangements
  } else {
    if (type(authors) != array) {
      authors = (authors,)
    }
    set page(footer: none, header: none, margin: 0cm)
    block(
      inset: (x: 0.5 * space, y: 1em),
      fill: title-color,
      width: 100%,
      height: 60%,
      align(bottom)[#text(2.0em, weight: "bold", fill: bg-color, title)],
    )
    block(
      height: 30%,
      width: 100%,
      inset: (x: 0.5 * space, top: 0cm, bottom: 1em),
      if subtitle != none {
        [
          #text(1.4em, fill: title-color, weight: "bold", subtitle)
        ]
      }
        + if subtitle != none and date != none { text(1.4em)[ \ ] }
        + if date != none { text(1.1em, date) }
        + align(left + bottom, authors.join(", ", last: " & ")),

    )
  }
  
  // Outline
  if (toc == true) {
    outline()
  }
  // Normal Content
  content
}