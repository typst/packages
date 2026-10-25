/// LaTeX-like knob marker for list
///
/// Example: `#set list(marker: components.knob-marker(primary: rgb("005bac")))`
///
/// - primary (color): The color of the marker.
///
/// -> content
#let knob-marker(primary: rgb("#005bac"), scaling: 100%) = {
  let radius = scaling * 0.25em
  box(
    width: 0.5em,
    height: 2 * radius,
    baseline: radius - 0.35em,
    circle(
      fill: gradient.radial(
        primary.lighten(100%),
        primary.darken(40%),
        focal-center: (30%, 30%),
      ),
      radius: radius,
    ),
  )
}


#let apply-marker-style(color: none, body) = context {
  if color == none {
    color = text.fill
  }
  set list(marker: it => {
    let default-markers = (
      knob-marker(primary: color, scaling: 80%),
      sym.bullet,
      sym.bullet.tri,
      sym.dash,
    )
    text(fill: color, default-markers.at(calc.min(it, default-markers.len() - 1)))
  })
  show enum: set text(fill: color)
  show enum.item: set text(fill: text.fill)
  show terms.item: it => {
    text(weight: "semibold", fill: color, it.term)
    h(0.6em)
    it.description
    linebreak()
  }

  body
}
