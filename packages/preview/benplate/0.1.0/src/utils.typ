#import "@preview/drafting:0.2.2": *

/*------[TODO Tools]------*/

#let todo(body, color: yellow, label: "TODO") = {
  let shape = rect.with(inset: 0.75em, radius: 0.5em)
  inline-note(rect: shape, stroke: color, fill: color.lighten(60%))[
    #text(weight: 700)[#label]: #body
  ]
}

#let note(body, color: red) = {
  margin-note(stroke: color)[
    #set par(justify: false)
    #set text(weight: "medium")
    #body
  ]
}

#let comment(body, color: blue.darken(25%), initials: "") = {
  math.attach(tl: sh)[]
  inline-note(stroke: blue.darken(25%), par-break: false)[
    #body
  ]
}


/*------[Helper Functions]------*/

#let prose = (citation) => {
  set cite(form: "prose")
  citation
}

#let subfigure = figure.with(kind: "subfigure")
