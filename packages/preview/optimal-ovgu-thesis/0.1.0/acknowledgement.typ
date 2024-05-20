#import "components.typ": body-font, variable-pagebreak

#let oot-acknowledgement(heading: "Acknowledgements", is-doublesided: none, body) = {
  set align(center)

  v(0.1fr)

  if heading.len() > 0 {
    text(font: body-font, 1em, weight: "semibold", heading)
    v(1em)
  }

  text(body)

  v(1fr)
  variable-pagebreak(is-doublesided)
}