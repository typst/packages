#let quote-display(content) = {
  // Code

  show quote: it => {
    let att = [ --- ] + it.attribution

    if att == [ --- ] {
      att = []
    }

    grid(
      columns: (1fr, 15fr, 1fr),
      [],
      block(stroke: (left: black.lighten(70%) + 1.5pt), inset: (left: 10pt, top: 3pt, bottom: 3pt), align(
        left,
        it + att,
      )),
    )
  }

  content
}
