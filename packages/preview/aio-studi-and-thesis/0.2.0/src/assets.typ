#import "utils.typ": *

// Card
#let card(
  primary-color: dark-blue,
  background-color: light-blue,
  title: none,
  img: none,
  body
) = {
  rect(fill: background-color, stroke: none, inset: 1.3em)[
    #text(1.2em, fill: primary-color, weight: "bold", title)
    
    #grid(
      columns: if is-not-none-or-empty(img) == false { (100%) } else { (75%, 25%) },
      body,
      if is-not-none-or-empty(img) {
        let offset = if is-not-none-or-empty(title) == false { 0em } else { -2em }
        box(inset: (top: offset))[#img]
      }
    )
  ]
}

// Author
#let author-box(
  background-color: light-blue,
  plural: false,
  body
) = {
  import "dictionary.typ": txt-author, txt-authors
  
  rect(fill: background-color, stroke: none, inset: 0.5em)[
    #text[ #emph(if plural { txt-authors } else { txt-author }): ]
    #text(weight: "bold", body)
  ]
}

// Buttons
#let button(
  url: "",
  fill: none,
  stroke: none,
  text-color: none,
  body
) = {
  show link: it => text(weight: "bold", it)
  
  if is-not-none-or-empty(url) {
    rect(
      fill: if fill != none { fill } else { dark-blue },
      stroke: if stroke != none { stroke } else { dark-blue },
      radius: 3pt,
      inset: .8em)[
        #link(url)[
          #text(
            fill: if text-color != none { text-color } else { white }
          )[
            #body #h(2pt) ↗ //$arrow.tr.filled$
          ]
        ]
      ]
  } else {
    h(1.5pt)
    box(
      fill: if fill != none { fill } else { silver },
      stroke: 1pt + if stroke != none { stroke } else { dark-grey },
      inset: 2pt,
      radius: 2pt,
      baseline: 20%
    )[
      #text(
        fill: if text-color != none { text-color } else { dark-grey }
      )[
        #body
      ]
    ]
    h(1.5pt)
  }
}