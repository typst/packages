#import "../presentate.typ": slide
#import "../store.typ": *

#let empty-slide(..args) = {
  set page(margin: 0pt, header: none, footer: none)
  slide(..args, logical-slide: false)
}

#let template(
  aspect-ratio: "16-9",
  body,
) = {
  set page(paper: "presentation-" + aspect-ratio)
  set text(font: "Lato", size: 22pt)
  show math.equation: set text(font: "Lete Sans Math")
  show heading.where(level: 1): it => {
    set align(center + horizon)
    empty-slide(it, animated: false)
  }
  body
}

#let slide = slide.with(
  body-fn: block.with(width: 100%, height: 1fr),
)
