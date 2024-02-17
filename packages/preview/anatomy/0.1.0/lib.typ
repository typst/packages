#let metrics(
  size, typeface,
  _text,
  top-edges: ( "ascender", "cap-height", "x-height", "baseline" ),
  bottom-edges: ( "descender", )
) = {
  set text(
    size,
    font: typeface,
  )

  let edges = top-edges + bottom-edges

  // Calulate metrics and update their corresponding states
  style(styles => {
    let set-metric(edge, above-baseline: true) = {
      let frame = measure(text(
        top-edge: if above-baseline { edge } else { "baseline" },
        bottom-edge: if above-baseline { "baseline" } else { edge }
      )[.], styles)

      state(edge).update(
        (if above-baseline { 1 } else { -1 } * frame.height)
      )
    }

    for edge in top-edges { set-metric(edge) }
    for edge in bottom-edges { set-metric(edge, above-baseline: false) }
  })

  locate(loc => {
    let get-metric(edge) = state(edge).at(loc)
    let top-edge = edges.first()
    let bottom-edge = edges.last()
    let stroke_width = 0.5pt
    let description-size = (1 + 2 / 3) / 10 * 1em

    block(
      width: 100%,
      above: description-size,
      below: description-size, {
      set align(left)

      box(
        height: get-metric(top-edge) - get-metric(bottom-edge),
        clip: true,
        text(
          top-edge: top-edge,
          bottom-edge: bottom-edge,
          _text
        )
      )

      for edge in edges {
        place(top, move(
          dy: get-metric(top-edge) - get-metric(edge) -
            stroke_width / 2,
          grid(
            columns: 2,
            gutter: description-size / 4,
            line(
              length: 100%,
              stroke: stroke_width
            ),
            text(
              description-size,
              // Place edge description at the half of x-height
              top-edge: get-metric("x-height") / size / 2 * 1em,
              edge
            )
          )
        ))
      }
    })
  })
}
