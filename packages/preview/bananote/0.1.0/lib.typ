
// This style is for internal research notes.
// It is modeled roughly after the Dagstuhl LIPIcs style, https://submission.dagstuhl.de/documentation/authors

#import "@preview/pergamon:0.5.0": *

#let sans = ("New Computer Modern Sans", "Libertinus Serif")
#let sans-weight = 800
#let serif = "Libertinus Serif"

#let text-size = 11pt

#let darkgreen = green.darken(20%)
#let darkblue = blue.darken(20%)

#let fcite = format-citation-authoryear()
#let fref = format-reference(
  name-format: "{given} {family}",
  format-quotes: it => it,
  print-date-after-authors: true,
  reference-label: fcite.reference-label,
  suppress-fields: (
    "*": ("month", "day",),
    "inproceedings": ("editor", "publisher", "pages", "location")
  ),
  eval-scope: ("todo": x => text(fill: red, x)),
  bibstring: ("in": "In"),
  bibstring-style: "long",
)

#let print-bananote-bibliography() = {
  print-bibliography(
    format-reference: fref, 
    sorting: "nyt",
    label-generator: fcite.label-generator,
  )
}

#let note(
  title: none,
  authors: (),
  date: datetime.today(),
  version: none,
  highlight-by: (),
  doc
) = {
  set text(font: serif, size: text-size)
  set page(margin: (x: 2.5cm, y: 3cm), numbering: "1")
  set par(first-line-indent: 0em, spacing: 1.4em, justify: true, leading: 0.7em)

  // TITLE AND AUTHORS
  if title != none {
    text(font: sans, size: 17pt, weight: sans-weight, title)
    parbreak()
  }

  for (i, author) in authors.enumerate() {
    let name = if type(author) == array { author.at(0) } else { author }
    let affiliation = if type(author) == array and author.len() > 1 { author.at(1) } else { "" }


    text(size: text-size, weight: "bold", name)
    if i == 0 and date != none {
      h(1fr)
      date.display("[day] [month repr:long] [year]")
    }

    if affiliation == none and i > 1 and version == none [
    ] else {
      linebreak()
      affiliation
      if i == 0 and version != none {
        h(1fr) 
        [Version #version]
      }
    }
    parbreak()
  }
  
  // FORMAT HEADINGS
  set heading(numbering: "1.1 ")
  let heading-size = 12pt
  show heading.where(level: 1): it => {
    v(2em, weak: true)
    
    block(below: 1em)[ // block ensures that title and yellow box stay together on pagebreaks
      #place(dx:-3mm-2em, dy:-3.5pt)[
        #box(width: 2em)[
            #context {
              align(right)[
                  #box(fill: yellow, width: 1em, height: 1em)[
                    #if it.numbering != none {
                      align(center+horizon,            
                        text(font: sans, weight: sans-weight, size: heading-size, [#counter(heading).get().first()])
                      )
                    } 
                  ]
              ]
            }
        ]
      ]

      #text(font: sans, weight: sans-weight, size: heading-size, it.body)
    ]
    // v(-0.2em)
  }
  
  show heading.where(level: 2): set text(font: sans, weight: sans-weight, size: heading-size)
  show heading.where(level: 2): set block(below: 1em, above: 2em)
  show heading.where(level: 3): set text(font: sans, weight: sans-weight)
  show heading.where(level: 4): it => text(font: sans, weight: sans-weight, size: text-size)[*#it.body.*]


  // PERGAMON
  let maybe-highlight(reference) = {
    if type(highlight-by) == array {
      highlight-by.any(name => name in family-names(reference.fields.labelname))
    } else {
      highlight-by in family-names(reference.fields.labelname)
    }
  }

  show link: set text(darkblue) // for non-citations
  show ref: set text(darkblue)
  show link: it => if-citation(it, value => {
    let color = if maybe-highlight(value.reference) { darkgreen } else { darkblue }
    set text(fill: color)
    it
  })


  refsection(format-citation: fcite.format-citation, doc)
}

#let abstract(abstr) = {
  v(2em)
  block[
    #line(length: 100%)
    #place(dx: 2em, dy: -1em, box(
      fill: white,
      inset: 6pt,
      text(font: sans, weight: sans-weight)[Abstract]
    ))
  ]
  v(-0.2em)

  abstr

  v(-0.1em)
  line(length: 100%)
  v(0.5em)
}
