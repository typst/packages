#import "@preview/showybox:2.0.4": showybox
#import "@preview/headcount:0.1.0": *
#let statementnum = counter("statementnum")
#let statement = state("statementsplist", ("@@@defaultkey@@@": ("default", "default", "default")))

#let newstatementsp(
  box-name: none,
  box-display: none,
  title-color: none,
  box-color: none,
  ) = {
  context {
    statement.update(statementsplist => {
      statementsplist.insert(box-name, (box-display, title-color, box-color))
    statementsplist
    })
  }
}

#let statementsp(
  box-name: none,
  box-label: none,
  box-title: none,
  number: true,
  body,
  ) = [
  #if number {
    context statementnum.step()
  }
  #context {
    if box-label != "" and box-label != none and not number {
      assert(false, message: "Error: This is statementsp. If you want to use label, you should set number to true.")
    }
    let box-title-display = ""
    if box-title != none {
      if box-title != "" {
        box-title-display = ": " + box-title
      }
    }
    if number {
      showybox(
        title: underline(offset: 2.5pt)[#statement.get().at(box-name).at(0) #counter(heading).get().at(0).#statementnum.get().at(0)] + box-title-display,
        breakable: true,
        title-style: (
          color: statement.get().at(box-name).at(1),
          boxed-style: (
            anchor: (
              x: left,
              y: horizon,
            ),
            offset: (
              x: 0em,
            ),
            radius: (0pt),
          ),
        ),
        frame: (
          title-color: statement.get().at(box-name).at(2),
          body-color: white,
          border-color: statement.get().at(box-name).at(2),
          radius: 0pt,
          thickness: 1.5pt,
          body-inset: 10pt,
        )
      )[
        #body
        #h(1fr) $square$
      ]
      } else {
        showybox(
        title: underline(offset: 2.5pt)[#statement.get().at(box-name).at(0)] + box-title-display,
        breakable: true,
        title-style: (
          color: statement.get().at(box-name).at(1),
          boxed-style: (
            anchor: (
              x: left,
              y: horizon,
            ),
            offset: (
              x: 0em,
            ),
            radius: (0pt),
          ),
        ),
        frame: (
          title-color: statement.get().at(box-name).at(2),
          body-color: white,
          border-color: statement.get().at(box-name).at(2),
          radius: 0pt,
          thickness: 1.5pt,
          body-inset: 10pt,
        )
      )[
        #body
        #h(1fr) $square$
      ]
    }
  }
  #if box-label != none {
    label(box-name + ":" + box-label)
  }
]
#let linksp(label) = {
  context {
    let box-name = ""
    let label-str = str(label)
    let letter-check = 0
    while letter-check < label-str.len() {
      if label-str.at(letter-check) == ":" {
        break
      }
      box-name = box-name + label-str.at(letter-check)
      letter-check = letter-check + 1
    }
    let box-display = statement.get().at(box-name).at(0)
    let link-display = box-display + " " + str(counter(heading).at(label).at(0)) + "." + str(statementnum.at(label).at(0))
    link(label)[#link-display]
  }
}