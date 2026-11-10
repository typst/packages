#let styles = ("1.", "(a)", "(i)")

#let enum-offset = state("offset", 0)

#let q-counter = counter("q")

#let q(body) = [
  #q-counter.step()

  #context {
    let num = q-counter.display("1.")
    enum-offset.update(1)

    block(width: 100%, above: 0.75em, below: 1em)[
      #place(left)[#box(width: 0.5em, align(right, num))]
      #pad(left: 1.3em, body)
    ]

    enum-offset.update(0)
  }
]

#let a(body) = [
  #block(
    width: 100%,
    // In the future, these should be optional arguments 
    // fill: none,
    // radius: 0pt,
    inset: 10pt,
    stroke: 1pt + black,
    breakable: true,
  )[#body]
]

#let br() = pagebreak()


#let hw(
  title-text: none,
  number: 1, 
  author: none, 
  class: none, 
  due-date: none, 
  body,
) = {

  counter(page).update(0)

  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context {
      if counter(page).get().first() > 0 [
        #align(center)[
          #counter(page).display()
        ]
      ]
    },
  )

  set text(
    size: 12pt,
    lang: "en",
    font: "New Computer Modern"
  )

  set enum(
    full: true,
    numbering: (..nums) => context {
      let offset = enum-offset.get()
      let depth = nums.pos().len() + offset
      let style = styles.at(depth - 1)
      numbering(style, nums.pos().last())
    }
  )


  align(horizon + center, block[
    #if title-text != none [
      #title[#title-text]
    ] else [
      #title[Homework #number Submission]
    ]

    #class

    #author

    #due-date
  ])


  pagebreak()

  body
}
