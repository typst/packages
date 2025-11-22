/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let apply(doc) = {
    // Numbering parameters
  set heading(numbering: "1.1 - ")

  // H1 styling
  show heading.where(level:1): he => {
    set align(center)
    box(width: 75%)[#{
      set text(
        size: 20pt,
        weight: "black",
        fill: rgb("CE0037"),
        font: "New Computer Modern Sans",
        hyphenate: false
      )
      if he.numbering != none {
        counter(heading).display(he.numbering)
      }
      upper(he.body)
      image("assets/filet-long.svg", width: 30%)
      v(0.5em)
  }]
  }

  // H2 styling
  show heading.where(level:2): he => {
    set text(
      size:20pt,
      weight: "medium",
      fill: rgb("00677F"),
    )
    smallcaps(he)
    v(-0.5em)
    image("assets/filet-court.svg")
    v(0.3em)
  }

  // H3 styling
  show heading.where(level: 3): he => {
    set text(
      size: 16pt,
      weight: "regular",
      fill: rgb("01426A")
    )
    if he.numbering != none {
      counter(heading).display(he.numbering).slice(0, -2)
    }
    smallcaps([• ] + he.body)
  }

  // H4 styling
  show heading.where(level: 4): he => {
    he
    v(0.2em)
  }

  // Quick fix for paragraph indentation...
  // Any superior entity who might be reading, please forgive me
  show heading: he => {
    {
      set par(first-line-indent: 0pt)
      he
    }
    par()[#text(size: 0em)[#h(0em)]]
  }

  // Don't forget to return doc cause
  // we're in a template
  doc
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

=== Guess who's back ?

#lorem(40)

= My second section

#lorem(30)

== Another one
