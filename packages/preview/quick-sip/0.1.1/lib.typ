#let page-number() = (
  context {
    counter(page).display()
  }
)

#let section(
  title,
  fill-clr: rgb("FFFFFF"),
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
            box(width: 67mm, stroke: 2pt, outset: 4pt, fill: fill-clr)[
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
          box(width: 67mm, stroke: 2pt, outset: 4pt, fill: fill-clr)[
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

#let step(a, b) = (
  context {
    v(1pt)
    counter("step").step() // Update the step counter
    set text(size: 9.8pt)

    // Get the current step number
    let step-num = counter("step").get()
    let section-num = counter("section").get()
    text[#str(step-num.at(0) + 1) #label("step" + "-" + str(section-num.at(0)) + "-" + str(step-num.at(0) + 1))]

    h(10pt)
    if (a != none and a != "" and (b == none or b == "")) {
      a
    } else if (a != none and a != "" and b != none and b != "") {
      a
      " "
      box(width: 1fr, repeat[.])
      " "
      b
    }

    linebreak()
  }
)


#let condition(fill-bg: rgb("EAEAEAFF"), body) = (
  context {
    if (body.has("children")) {
      let condition-width = measure(
        text(size: 7pt)[
          Condition:
        ],
      ).width


      box(width: 100%, inset: (y: 3pt, x: 3pt), outset: (y: 4pt), fill: fill-bg)[

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
      box(width: 100%, inset: (y: 3pt, x: 3pt), outset: (y: 4pt), fill: fill-bg)[

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

#let objective(fill-bg: rgb("EAEAEAFF"), body) = (
  context {
    box(width: 100%, inset: (y: 3pt, x: 3pt), outset: (y: 4pt), fill: fill-bg)[
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

#let note(fill-bg: rgb("edf7f7ff"), body) = (
  context {
    box(width: 100%, outset: (y: 4pt), inset: (x: 4pt), fill: fill-bg)[
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


#let caution(fill-bg: rgb("edf7f7ff"), body) = (
  context {
    stack(
      spacing: 4pt,
      line(length: 100%, stroke: 2pt + rgb("d98d00ff")),

      grid(
        columns: 2,
        column-gutter: 6pt,
        text(weight: "bold", size: 9.8pt)[Caution!], text(weight: "bold", size: 9.8pt)[#body],
      ),

      line(length: 100%, stroke: 2pt + rgb("d98d00ff")),
    )
  }
)

#let bullet(phrase) = (
  context {
    phrase
    linebreak()
  }
)

#let choose-one(fill-bg: rgb("edf7f7ff"), body) = (
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

    // text[#("option" + str(globalOption + 1)) ]

    context {
      let localOption = counter("localOption").get().at(0)
      let globalOption = counter("globalOption").get().at(0)
      // text[#globalOption #localOption]
      if (localOption > 1) {
        let pos = locate(label("option" + str(globalOption - 1))).position()
        let currPos = locate(label("option" + str(globalOption))).position()

        if (currPos.page == pos.page) {
          // text[#pos.y #currPos.y]
          // linebreak()
          // text["Previous Option Page: " #pos.page]
          // text["Current Option Page: " #currPos.page]
          place(top, line(start: (pos.x - 25.5pt, pos.y - 20pt), end: (currPos.x - 25.5pt, currPos.y - 20pt)))
        }
      }
    }
  }
)


#let detail(body) = (
  context {
    body
  }
)

#let tab(body) = {
  move(
    dx: 17pt,
    box(
      width: 100% - 16pt,
      body,
    ),
  )
}



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



#let goto(step) = (
  context {
    let section-num = counter("section").get().at(0)
    move(
      dx: 18pt,
      grid(
        columns: 3,
        align: horizon,
        column-gutter: 3pt,
        path(
          fill: black, // Color of the first triangle
          closed: true, // Close the triangle
          (0pt, 0pt), // Bottom-left corner
          (5pt, 2.83pt), // Rightmost point
          (0pt, 5pt), // Top-left corner
        ),
        path(
          fill: black, // Color of the first triangle
          closed: true, // Close the triangle
          (0pt, 0pt), // Bottom-left corner
          (5pt, 2.83pt), // Rightmost point
          (0pt, 5pt), // Top-left corner
        ),
        link(label("step" + "-" + str(section-num) + "-" + str(step)))[#text(weight: "bold")[Go to step #step]],
      ),
    )
  }
)


#let wait() = {
  repeat[#stack(dir: ltr, rect(width: 2mm, height: 1mm, fill: black), h(2mm))]
}

#let substep(a, b) = {
  v(1pt)
  set text(size: 9.8pt)
  move(
    dx: 25pt,
    dy: -2pt,
    box(
      width: 100% - 25pt,

      if (a != none and a != "" and (b == none or b == "")) {
        a
      } else if (a != none and a != "" and b != none and b != "") {
        a
        " "
        box(width: 1fr, repeat[.])
        " "
        b
      },
    ),
  )
}


#let index() = context {
  let elems = query(<section>)

  if elems.len() == 0 {
    return
  }

  align(center, text(weight: "bold")[INDEX])

  for body in elems {
    text([#link(body.location(), body.child.body)])
    box(width: 1fr, repeat[.])
    text[#body.location().page()]
    linebreak()
  }

  pagebreak()
}


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
