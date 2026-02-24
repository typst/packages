
// Creates the optional index on the first page
#let index() = context {
  let elems = query(<section>) // get every section with the label section

  if elems.len() == 0 {
    return
  }

  align(center, text(weight: "bold")[INDEX]) // Title INDEX

  for body in elems {
    text([#link(body.location(), body.child.body)])
    box(width: 1fr, repeat[.])
    text[#body.location().page()]
    linebreak()
  }

  pagebreak() // Always start QRH after the index
}

// Define a section layout with a title, fill color, and body content
#let section(
  title,
  body,
) = (
  context {
    if (title != none and title != "") {
      counter("section").step()

      counter("step").update(0)
      let box-height = measure(
        align(
          center,
          stack(
            // Line behind the box
            move(line(length: 100%, stroke: 2pt)),

            // The box with text
            box(width: 67mm, stroke: 2pt, outset: 4pt, fill: rgb("FFFFFF"))[
              #v(0.8mm)
              #set text(size: 10pt)
              #box(width: 60mm)[
                #align(center)[#upper(strong(title))]
              ]
              #v(0.8mm)
            ],
          ),
        ),
      ).height

      align(
        center,
        stack(
          // Line behind the box
          move(dy: box-height / 2, line(length: 100%, stroke: 2pt)),

          // The box with text
          box(width: 67mm, stroke: 2pt, outset: 4pt, fill: rgb("FFFFFF"))[
            #v(0.8mm)
            #set text(size: 10pt)
            #box(width: 60mm)[
              #align(center)[#upper(strong(title)) #label("section")]
            ]
            #v(0.8mm)
          ],

          v(1.3mm),
        ),
      )

      body

      align(center)[
        #box(
          width: 20%,
          height: 2.2mm,
          stack(
            dir: ltr,
            ..for i in range(4) {
              (
                square(size: 2.2mm, fill: black),
                h(1.85mm),
              )
            },
          ),
        )
      ]

      linebreak()
    }
  }
)

// At the top of a section in a box with fill-bg
#let condition(body) = (
  context {
    if (body.has("children")) {
      let condition-width = measure(
        text(size: 7pt)[
          Condition:
        ],
      ).width


      box(width: 100%, inset: (y: 3pt, x: 3pt), outset: (y: 4pt), fill: rgb("EAEAEAFF"))[

        #box(
          grid(
            columns: 2,
            align: horizon,
            column-gutter: 6pt,
            row-gutter: 5pt,
            text(size: 7pt)[Condition:],
            text(size: 9.6pt)[One or more of these occur:],
            // Add an empty space in the first column to shift #body
            [ ],
            move(
              dx: 5pt,
              text(size: 9.6pt)[
                #grid(
                  columns: 2,
                  align: horizon,
                  row-gutter: 5pt,
                  column-gutter: 2pt,
                  ..for c in body.children {
                    if (c != [ ] and c != (:)) {
                      (
                        circle(radius: 1.178mm / 2, fill: black),
                        c.at("body"),
                      )
                    }
                  }
                )
              ],
            )
          ),
        )

      ]
    } else {
      box(width: 100%, inset: (y: 3pt, x: 3pt), outset: (y: 4pt), fill: rgb("EAEAEAFF"))[

        #box(
          grid(
            columns: 2,
            align: horizon,
            column-gutter: 6pt,
            row-gutter: 5pt,
            text(size: 7pt)[Condition:], text(size: 9.6pt)[#body],
          ),
        )

      ]
    }
  }
)

// Goes under a condition, with fill-bg
#let objective(body) = (
  context {
    box(width: 100%, inset: (y: 3pt, x: 3pt), outset: (y: 4pt), fill: rgb("EAEAEAFF"))[
      // #v(5pt)
      #box(
        grid(
          columns: 2,
          align: horizon,
          column-gutter: 6pt,
          text(size: 7pt)[Objective:], text(size: 9.6pt)[#body],
        ),
      )
    ]
  }
)

// A step that is automatically numbered for each section
#let step(prompt, ..actions) = (
  context {
    let actionsPos = actions.pos()
    let thisAction = if (actionsPos.len() > 0) { actionsPos.at(0) } else { "" }
    v(1pt)
    counter("step").step() // Update the step counter
    set text(size: 9.8pt)

    // Get the current step number
    let step-num = counter("step").get()
    let section-num = counter("section").get()
    text[#str(step-num.at(0) + 1) #label(
        "step" + "-" + str(section-num.at(0)) + "-" + str(step-num.at(0) + 1),
      )] // label with step and section number so that it can be referenced by a goto

    h(10pt)


    prompt
    if thisAction != "" {
      " "
      box(width: 1fr, repeat[.])
      " "
      thisAction
    }


    linebreak()
  }
)

// A step that is indented from the left only and has no number
#let substep(prompt, ..actions) = {
  let actionsPos = actions.pos()
  let thisAction = if (actionsPos.len() > 0) { actionsPos.at(0) } else { "" }
  v(1pt)
  set text(size: 9.8pt)
  move(
    dx: 25pt,
    dy: -2pt,
    box(
      width: 100% - 25pt,
      [
        #prompt
        #if thisAction != "" {
          " "
          box(width: 1fr, repeat[.])
          " "
          thisAction
        }
      ],
    ),
  )
}

// Move content in for a tab indent and limit width
#let tab(body) = {
  move(
    dx: 17pt,
    box(
      width: 100% - 16pt,
      body,
    ),
  )
}

// Callout of caution with line-col
#let caution(body) = (
  context {
    stack(
      spacing: 4pt,
      line(length: 100%, stroke: 2pt + rgb("#d98d00ff")),

      grid(
        columns: 2,
        column-gutter: 6pt,
        text(weight: "bold", size: 9.8pt)[Caution!], text(weight: "bold", size: 9.8pt)[#body],
      ),

      line(length: 100%, stroke: 2pt + rgb("#d98d00ff")),
    )
  }
)

// Callout for a note with fill-bg
#let note(body) = (
  context {
    box(width: 100%, outset: (y: 4pt), inset: (x: 4pt), fill: rgb("edf7f7ff"))[
      #box(
        grid(
          columns: 2,
          align: top,
          column-gutter: 6pt,
          text(size: 9pt, weight: "bold")[Note:], text(size: 10pt)[#body],
        ),
      )
    ]
  }
)

// Choose one conditional with a line drawn between each step
#let choose-one(body) = (
  context {
    counter("step").step()
    counter("localOption").update(0)
    let step-num = counter("step").get()
    text[#str(step-num.at(0) + 1) #label("step" + str(step-num.at(0) + 1))]
    h(10pt)
    text()[Choose one:]
    linebreak()
    body
  }
)

// An option inside a choose-one conditional
#let option(body) = (
  context {
    counter("globalOption").step()
    counter("localOption").step()
    let globalOption = counter("globalOption").get().at(0)
    move(
      dx: 16pt,
      box(
        width: 100% - 16pt,
        grid(
          columns: 2,
          column-gutter: 3pt,
          rotate(45deg)[#box(width: 2.2mm, height: 2.2mm, fill: black) #label(("option" + str(globalOption + 1)))],
          body,
        ),
      ),
    )

    context {
      let localOption = counter("localOption").get().at(0)
      let globalOption = counter("globalOption").get().at(0)
      if (localOption > 1) {
        let pos = locate(label("option" + str(globalOption - 1))).position()
        let currPos = locate(label("option" + str(globalOption))).position()

        if (currPos.page == pos.page) {
          place(top, line(start: (pos.x - 25.5pt, pos.y - 20pt), end: (currPos.x - 25.5pt, currPos.y - 20pt)))
        }
      }
    }
  }
)

// Links to another step
#let goto(stepRef) = context {
  let section-num = counter("section").get().at(0)
  let triangle = curve(
    fill: black,
    curve.move((0pt, 0pt)), // Start at bottom-left corner
    curve.line((5pt, 2.83pt)), // Line to rightmost point
    curve.line((0pt, 5pt)), // Line to top-left corner
    curve.close(), // Close back to start
  )

  let target-label = if type(stepRef) == int {
    "step" + "-" + str(section-num) + "-" + str(stepRef)
  } else {
    stepRef
  }

  let step-text = if type(stepRef) == int {
    str(stepRef)
  } else {
    str(counter("step").at(label(stepRef)).at(0) + 1)
  }

  move(dx: 18pt)[
    #grid(
      columns: (auto, auto, 1fr),
      column-gutter: 3pt,
      align: horizon,
      triangle,
      triangle,
      link(label(target-label))[
        #text(weight: "bold")[Go to step #step-text]
      ],
    )
  ]
}

// End the current section
#let end() = {
  align(center)[
    #box(
      width: 20%,
      height: 2.2mm,
      stack(
        dir: ltr,
        ..for i in range(4) {
          (
            square(size: 2.2mm, fill: black),
            h(1.85mm),
          )
        },
      ),
    )
  ]
}

// long line with lots of dots
#let wait() = {
  repeat[#stack(dir: ltr, rect(width: 2mm, height: 1mm, fill: black), h(2mm))]
}

// Show the current page number (INTERNAL)
#let page-number() = (
  context {
    counter(page).display() // Display the current page number
  }
)

#let QRH(title: none, body) = {
  set page(
    width: 105mm,
    height: 177mm,
    margin: (bottom: 12mm, top: 8mm, x: 9mm),
    footer: [
      #line(start: (0pt, -6pt), length: 100%)
      #place(
        left,
        dy: -2pt,
        text(size: 6pt, fill: rgb("000000"))[
          #datetime.today().display()
        ],
      )
      #place(
        center,
        dy: -2pt,
        text(size: 6pt, fill: rgb("000000"))[
          #page-number()
        ],
      )
      #place(
        right,
        dy: -2pt,
        text(size: 6pt, fill: rgb("000000"))[
          #title
        ],
      )
    ],
  )
  set text(size: 9.6pt)
  body
}
