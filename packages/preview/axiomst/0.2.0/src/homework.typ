// axiomst/homework.typ - Homework template
#import "common.typ": show-solutions-state

#let homework(
  title: "Homework Assignment",
  author: "Student Name",
  course: "Course Code",
  email: "student@school.uni",
  date: datetime.today(),
  due-date: none,
  collaborators: [],
  margin-size: 2.5cm,
  show-solutions: true,
  body
) = {
  // Set the global solution visibility state
  show-solutions-state.update(show-solutions)

  set document(title: title, author: author)

  set page(
    paper: "a4",
    margin: (top: margin-size, bottom: margin-size, left: margin-size, right: margin-size),

    header: context {
      if counter(page).get().first() > 1 [
        #set text(style: "italic")
        #course #h(1fr) #author
        #if collaborators != none and type(collaborators) == array and collaborators.len() > 0 {
          [w/ #collaborators.join(", ")]
        }
        #block(line(length: 100%, stroke: 0.5pt), above: 0.6em)
      ]
    },

    footer: [
      #align(center)[Page #context counter(page).display() of #context counter(page).final().first()]
    ],
  )

  show raw.where(block: true): it => {
    block(
      width: 100% - 0.5em,
      radius: 0.3em,
      stroke: luma(50%),
      inset: 1em,
      fill: luma(98%)
    )[
      #show raw.line: l => context {
        box(
          width: measure([#it.lines.last().count]).width,
          align(right, text(fill: luma(50%))[#l.number])
        )
        h(0.5em)
        l.body
      }
      #it
    ]
  }

  show ref: it => {
    let element = it.element
    let loc = it.location()

    if element == none {
      return it
    }

    if element.func() == heading and element.level == 2 {
      [Problem #it.number]
    } else {
      it
    }
  }

  align(
    center,
    {
      text(size: 1.6em, weight: "bold")[#course -- #title \ ]

      text(size: 1.2em, weight: "semibold")[#author \ ]

      raw(email); linebreak()

      emph[#date.display("[month repr:long] [day], [year]")]

      box(line(length: 100%, stroke: 1pt))
    },
  )

  set heading(
    numbering: (..nums) => {
      nums = nums.pos()
      if nums.len() == 1 {
        [Problem #nums.at(0):]
      }
      else if nums.len() > 2 {
        [Part (#numbering("a", nums.at(1))):]
      }
    },
  )

  body
}
