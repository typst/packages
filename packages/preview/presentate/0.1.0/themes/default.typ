#import "../presentate.typ" as p
#import "../store.typ": *

#let empty-slide(..args,) = {
  set page(margin: 0pt)
  p.slide(..args, logical-slide: false)
}

#let template(body, aspect-ratio: "16-9") = {
  set page(paper: "presentation-" + aspect-ratio)
  set text(font: "Lato", size: 25pt)
  show math.equation: set text(font: "Lete Sans Math")
  show heading.where(level: 1): it => {
    set align(center + horizon)
    empty-slide(it)
  }
  body
}
