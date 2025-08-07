#import "monash-colors.typ": monash-bright-blue, monash-blue

/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let apply(doc) = {
    // Numbering parameters
  set heading(numbering: "1.1")

  // H1 styling - Modern with shadow effect
  show heading.where(level:1): he => {
    set align(center)
    box(width: 90%)[#{
      set par(justify: false)
      
      // Number styling
      if type(he.numbering) == str {
        set text(
          size: 16pt,
          weight: "bold",
          fill: monash-bright-blue,
                  )
        counter(heading).display(he.numbering)
        v(0.3em)
      } else if he.numbering != none {
        set text(
          size: 16pt,
          weight: "bold",
          fill: monash-bright-blue,
                  )
        upper((he.numbering)(he.level))
        v(0.3em)
      }
      
      // Title with modern styling
      set text(
        size: 24pt,
        weight: "bold",
        fill: monash-blue,
                hyphenate: false
      )
      upper(he.body)
      
      // Modern decorative element
      v(0.8em)
      box(width: 40%, height: 1.5pt, fill: monash-bright-blue)
      v(0.5em)
  }]
  }

  // H2 styling - Professional academic format
  show heading.where(level:2): he => {
    box(width: 100%)[#{
      set par(justify: false)
      set align(left)
      set text(
        size: 18pt,
        weight: "bold",
        fill: monash-blue,
              )
      if type(he.numbering) == str {
        counter(heading).display(he.numbering)
        [ ]
      }
      he.body
    }]
  }

  // H3 styling - Consistent with other headings
  show heading.where(level: 3): he => {
    box(width: 100%)[#{
      set par(justify: false)
      set align(left)
      set text(
        size: 16pt,
        weight: "bold",
        fill: monash-blue,
      )
      if type(he.numbering) == str {
        counter(heading).display(he.numbering)
        [ ]
      }
      he.body
    }]
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