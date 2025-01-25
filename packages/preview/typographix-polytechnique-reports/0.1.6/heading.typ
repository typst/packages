/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let apply(doc) = {
    // Numbering parameters
  set heading(numbering: "1.1 - ")

  // H1 styling
  show heading.where(level:1): he => {
    set align(center)
    box(width: 85%)[#{
      set par(justify: false)
      set text(
        size: 20pt,
        weight: "black",
        fill: rgb("CE0037"),
        font: "New Computer Modern Sans",
        hyphenate: false
      )
      if type(he.numbering) == str {
        counter(heading).display(he.numbering.slice(0, -3))
        linebreak()
      } else if he.numbering != none {
        upper((he.numbering)(he.level).slice(0, -2))
        linebreak()
      }
      upper(he.body)
      image("assets/filet-long.svg", width: 30%)
      v(0.5em)
  }]
  }

  // H2 styling
  show heading.where(level:2): he => {
    box()[#{
      set text(
        size:20pt,
        weight: "medium",
        fill: rgb("00677F"),
      )
      smallcaps(he)
      v(-0.5em)
      image("assets/filet-court.svg")
    }]
  }

  // H3 styling
  show heading.where(level: 3): he => {
    set text(
      size: 16pt,
      weight: "regular",
      fill: rgb("01426A")
    )
    if type(he.numbering) == str {
      counter(heading).display(he.numbering.slice(0, -3))
      [ • ]
    }

    smallcaps(he.body)
  }

  // H4 styling
  show heading.where(level: 4): he => {
    counter(heading).display(he.numbering)
    he.body
  }

  // Quick fix for paragraph indentation...
  // Any superior entity who might be reading, please forgive me
  show heading: he => {
      set par(first-line-indent: 0pt)
      he
  }

  // Don't forget to return doc cause
  // we're in a template
  doc
}

#let appendix(body, title: "Appendix") = {
  counter(heading).update(0)
  // From https://github.com/typst/typst/discussions/3630
  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      let s = ""
      if vals.len() == 1 {
        s += title + " "
      }
      s += numbering("A.1 -", ..vals)
      s
    },
  )

  body
}


/********************/
/* TESTING TEMPLATE */
/********************/

#show: apply

#outline()

= My first section

== A sub-section 

#heading(level: 2, numbering: none)[Sub-section without numbering]
#lorem(60)

=== No more ideas

==== Sometimes dummy text is

===== Really important
really ?

==== Back again

#heading(level: 3, numbering: none)[Sub-sub-section without numbering]

=== Guess who's back ?

#lorem(40)

= My second section

#lorem(30)

== Another one

#lorem(20)

#show: appendix.with(title: "Appendix")

= Some proofs
#lorem(50)

== Some theorem
#lorem(20)
