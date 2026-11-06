#import "bookly-defaults.typ": *

#let front-matter(body) = {
  set heading(numbering: none)
  set page(numbering: "i")
  states.page-numbering.update("i")
  states.num-pattern.update(none)
  counter(page).update(0)

  body
}

// Main matter
#let main-matter(body) = context {
  set heading(numbering: "1.1.")

  let numbering = "1/1"
  if states.theme.get().contains("classic") {
    numbering = "1"
  }
  set page(numbering: numbering)

  states.page-numbering.update("1/1")
  states.num-heading.update("1")
  states.num-pattern.update("1.1.")
  states.num-pattern-fig.update("1.1")
  states.num-pattern-fig.update("1.1a")
  states.num-pattern-eq.update("(1.1a)")

  counter(page).update(0)

  body
}

// Back matter
#let back-matter(body) = {
  set page(header: none, footer: none)

  body
}

// Appendix
#let appendix(body) = context {
  set heading(numbering: "A.1.")

  let numbering = "1/1"
  if states.theme.get().contains("classic") {
    numbering = "1"
  }
  set page(numbering: numbering)

  // Reset heading counter
  counter(heading.where(level: 1)).update(0)

  // Reset heading counter for the table of contents
  counter(heading).update(0)

  // Update states for chapter function
  states.num-heading.update("A")
  states.num-pattern.update("A.1.")
  states.num-pattern-fig.update("A.1")
  states.num-pattern-subfig.update("A.1a")
  states.num-pattern-eq.update("(A.1a)")
  states.isappendix.update(true)

  body
}

// Part
#let part(title) = {
  states.counter-part.update(i => i + 1)
  set page(
    header: none,
    footer: none,
    numbering: none
  )

  set align(center + horizon)

  pagebreak(weak: true, to:"odd")

  context{
    if states.theme.get().contains("fancy") {
      line(stroke: 1.75pt + states.colors.get().primary, length: 104%)
      text(size: 2.5em)[#states.localization.get().part #states.counter-part.get()]
      line(stroke: 1.75pt + states.colors.get().primary, length: 35%)
      text(size: 3em)[*#title*]
      line(stroke: 1.75pt + states.colors.get().primary, length: 104%)
    } else if states.theme.get().contains("classic") {
      text(size: 2.5em)[#states.localization.get().part #states.counter-part.get()]
      v(1em)
      text(size: 3em)[*#title*]
    } else if states.theme.get().contains("modern") {
      place(top, dy: -11%)[
        #box(fill: gradient.linear(states.colors.get().primary, states.colors.get().primary.transparentize(55%), dir: ttb), height: 61%, width: 135%)[
          #set align(horizon)

          #text(size: 5em, fill: white)[*#states.localization.get().part #states.counter-part.get()*]
        ]
      ]

      place(center + horizon)[
        #box(outset: 1.25em, stroke: none, radius: 5em, fill: states.colors.get().primary)[
          #set text(fill: white, weight: "bold", size: 3em)
          #title
        ]
      ]
    }

    show heading: none
    if states.theme.get().contains("fancy") {
      heading(numbering: none)[#box[#text(fill:states.colors.get().primary)[#states.localization.get().part #states.counter-part.get() -- #title]]]
    } else {
      heading(numbering: none)[#box[#states.localization.get().part #states.counter-part.get() -- #title]]
    }
  }

  pagebreak(weak: true, to:"odd")
}