#let pset(
  class: "6.100",
  title: "PSET 0",
  student: "Alyssa P. Hacker",
  date: datetime.today(),
  subproblems: "1.1.a.i",
  collaborators: (),
  doc,
) = {
  [
    /* Convert collaborators to a string if necessary */
    #let collaborators = if type(collaborators) == array { collaborators.join(", ") } else { collaborators }

    /* Problem + subproblem headings */
    #set heading(
      numbering: (..nums) => {
        nums = nums.pos()
        if nums.len() == 1 {
          [Problem #nums.at(0):]
        } else {
          numbering(subproblems, ..nums)
        }
      },
    )

    /* Set metadata */
    #set document(title: [#class - #title], author: student, date: date)

    /* Set up page numbering and continued page headers */
    #set page(
      numbering: "1",
      header: context {
        if counter(page).get().first() > 1 [
          #set text(style: "italic")
          #class -- #title
          #h(1fr)
          #student
          #if collaborators != none { [w/ #collaborators] }
          #block(line(length: 100%, stroke: 0.5pt), above: 0.6em)
        ]
      },
    )

    /* Add numbering and some color to code blocks */
    #show raw.where(block: true): it => {
      block(width: 100% - 0.5em, radius: 0.3em, stroke: luma(50%), inset: 1em, fill: luma(98%))[
        #show raw.line: l => context {
          box(width: measure([#it.lines.last().count]).width, align(right, text(fill: luma(50%))[#l.number]))
          h(0.5em)
          l.body
        }
        #it
      ]
    }

    /* Make the title */
    #align(
      center,
      {
        text(size: 1.6em, weight: "bold")[#class -- #title \ ]
        text(size: 1.2em, weight: "semibold")[#student \ ]
        emph[
          #date.display("[year]-[month]-[day]")
          #if collaborators != none {
            [
              \ Collaborators: #collaborators
            ]
          }
        ]
        box(line(length: 100%, stroke: 1pt))
      },
    )

    #doc
  ]
}
