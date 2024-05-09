// Utility to convert from snake_case to Title Case
#let snake-to-titlecase(str) = str.split("_").map(str => upper(str.slice(0, 1)) + lower(str.slice(1))).join(" ")

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  abstract: [],
  department: "",
  meta: (
    title: "Untitled",
    theme: "",
    project_period: "",
    project_group: "No group name provided",
    participants: (),
    supervisor: (),
    date: "Christmas Eve",
  ),
  body,
) = {

  // Set the document's basic properties.
  set document(author: meta.participants.map(a => a.name), title: meta.title)
  set page(numbering: "I", number-align: center)

  // Save heading and body font families in variables.
  let aau-blue = rgb(33, 26, 82)
  let body-font = "New Computer Modern"
  let sans-font = "New Computer Modern Sans"

  // Set document preferences, font family, heading format etc.
  set text(font: body-font, lang: "en")
  set heading(numbering: "1.1")
  show math.equation: set text(weight: 400)
  show heading: set text(font: sans-font)
  show link: underline
  
  // Front/cover page.
  page(background: image("AAUgraphics/aau_waves.svg", width: 100%, height: 100%), numbering: none,
    grid(columns: (100%), rows: (50%, 20%, 30%),
      align(center + bottom,
        box(fill: aau-blue, inset: 18pt, radius: 1pt, clip: false,
        {
          set text(fill: white, 12pt)
          align(center)[
            #text(font: sans-font, 2em, weight: 700, meta.title)\ \
            #meta.project_group\
            #((..meta.participants.map(author => author.name)).join(", ", last: " and "))
          ]
        }
      )),
      none,
      align(center, image("AAUgraphics/aau_logo_circle_en.svg", width: 25%))
    )
  )
    
  pagebreak()

  // Abstract page.
  page(
    grid(
      columns: (50%, 50%),
      rows: (30%, 70%),
      image("AAUgraphics/aau_logo_en.svg"),
      align(right + horizon)[
        *#(department)*\
        Aalborg University\
        http://cs.aau.dk
      ],
      box(width: 100%, height: 100%)[
        // List all key-value pairs from 'meta' map.
        #(meta.pairs().map(data =>
        [*#(snake-to-titlecase(data.at(0))):*\ #(
          if type(data.at(1)) == array {
            data.at(1).map(d => [#(d.name)]).join("\n")
          } else {
            data.at(1)
          }
          )]
        ).join("\n\n"))

        \
        *Copies:* 1\ \

        *Page Numbers:* #(locate(loc => counter(page).final(loc).at(0)))\ \
      ],
      box(width: 100%, height: 100%, stroke: black, inset: 8pt)[
        *Abstract:*\
        #abstract
      ]
    )
  )

  pagebreak()

  // Table of contents.
  page(outline(depth: 3, indent: true))
  
  pagebreak()

  // Preface page.
  page({
    text(16pt, weight: "extrabold")[Preface]
    align(
      center + bottom,
      grid(
        columns: (auto, auto),
        row-gutter: 5em,
        column-gutter: 2em,
        ..meta.participants.map(author => {
          align(center)[
              #line(length: 100%)
              #text(font: sans-font, 12pt, author.name)\
              #text(font: sans-font, 10pt, author.email)
          ]
        })
      )
    )
  })

  pagebreak()
  
  // Main body.
  set page(numbering: "1", number-align: center)
  counter(page).update(1)

  set par(justify: true)

  // Chapter Styling
  show heading.where(level: 1): h => {
    pagebreak(weak: true) 
    v(1em)
    let c = luma(70)
    set text(fill: c, size: 80pt)
    place(left, counter(heading).display()) 
    set text(fill: c, size: 20pt)
    place(right, dy: 1.6em, {h.body})
    place(right, dy: 2.7em, {line(length: 80%, stroke: 0.7pt + c)})
    v(6em)
  }

  // Increment header for bibliography
  show bibliography: body => {
    counter(heading).step()
    body
  }

  body
}
