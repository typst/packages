/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let apply(doc) = {
    // Numbering parameters
  set heading(numbering: "1.1 - ")

  // H1 styling
  show heading.where(level:1): h => {
    set align(center)
    set text(
      size: 16pt,
      weight: "black",
      fill: red
    )
    if h.numbering != none {
      counter(heading).display(h.numbering)
    }
    upper(h.body)
    // image("banner-subheading.svg", width: 30%)
  }

  // H2 styling
  show heading.where(level:2): h => {
    set text(
      size:14pt,
      weight: "medium",
      fill: blue,
    )
    smallcaps(h)
    // image("small-banner-subheading.svg")
  }

  // H3 styling
  show heading.where(level: 3): h => {
    set text(
      size: 12pt,
      weight: "regular",
      fill: blue
    )
    if h.numbering != none {
      counter(heading).display(h.numbering).slice(0, -2)
    }
    smallcaps([• ] + h.body)
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

=== No more ideas

==== Sometimes dummy text is

===== Really important

==== Back again

=== Guess who's back ?

= My second section

#lorem(30)

== Another one
