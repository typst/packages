#let styles = ("1.", "(a)", "(i)")

#let enum-offset = state("offset", 0)

#let q-counter = counter("q")

#let q(body) = [
  // Reset custom enumeration to account for title page
  #q-counter.step()
  #enum-offset.update(1)

  // Enumeration should continue between and within questions and answers
  #context {
    let num = q-counter.display("1.")

    // Adjust manual enumeration spacing to match standard "+" syntax enumeration
    block(width: 100%, above: 0.75em, below: 1em)[
      #place(left)[#box(width: 0.5em, align(right, num))]
      #pad(left: 1.3em, body)
    ]
  }

  #enum-offset.update(0)
]


#let a(body) = [
  #block(
    breakable: true,
  )[
    #body
  ] <hw-answer>
]

#let br() = pagebreak()


#let hw(
  title-text: none,
  number: 1,
  author: none,
  class: none,
  institution: none,
  professor: none,
  due-date: none,
  answer-color: black,
  answer-background-fill: false,
  show-page-footer: true,
  show-problem-footer: true,
  body,
) = {
  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context {
      // Display page/problem counter after title page if enabled
      if counter(page).get().first() > 1 {
        grid(
          columns: (1fr, 1fr),
          if show-problem-footer {
            align(left)[
              Problem #q-counter.display()
            ]
          },
          if show-page-footer {
            align(right)[
              #counter(page).display()
            ]
          },
        )
      }
    },
  )

  set text(
    size: 12pt,
    lang: "en",
    font: "New Computer Modern",
  )

  set enum(
    full: true,
    numbering: (..nums) => context {
      let offset = enum-offset.get()
      let depth = nums.pos().len() + offset
      let style = styles.at(depth - 1)
      numbering(style, nums.pos().last())
    },
  )

  // Set the answer text and border to have answer-color
  show block.where(label: <hw-answer>): it => {
    block(
      width: 100%,
      inset: 10pt,
      stroke: 1pt + answer-color,
      fill: if answer-background-fill {
        answer-color.lighten(90%)
      } else {
        none
      },
      it,
    )
  }

  show label("hw-answer"): set text(fill: answer-color)

  // Style title page to (somewhat) follow APA style
  align(horizon + center, block[
    // If title-text is set, then use it instead of "Homework # Submission"
    #if title-text != none [
      #title[#title-text]
    ] else [
      #title[Homework #number Submission]
    ]

    #author

    #institution

    #class

    #professor

    #due-date
  ])

  pagebreak()

  body
}
