#let metrics(
  size, typeface,
  _text,
  top-edges: ( "ascender", "cap-height", "x-height", "baseline" ),
  bottom-edges: ( "descender", ),
  typeset: ((:)) => []
) = style(styles => {
  let edges = top-edges + bottom-edges

  let get-metric(edge, above-baseline: true) = {
    let frame = measure(text(
      size,
      font: typeface,
      top-edge: if above-baseline { edge } else { "baseline" },
      bottom-edge: if above-baseline { "baseline" } else { edge }
    )[.], styles)

    return (if above-baseline { 1 } else { -1 } * frame.height)
  }

  let metrics = (:)
  for edge in top-edges { metrics.insert(edge, get-metric(edge)) }
  for edge in bottom-edges { metrics.insert(
    edge, get-metric(edge, above-baseline: false)) }

  locate(loc => {
    let top-edge = edges.first()
    let bottom-edge = edges.last()
    let stroke_width = 0.5pt
    let description-size = (1 + 2 / 3) / 10 * 1em

    set text(
      size,
      font: typeface,
    )

    block(
      width: 100%,
      above: description-size,
      below: description-size, {
      set align(left)

      box(
        height: metrics.at(top-edge) - metrics.at(bottom-edge),
        clip: true,
        text(
          top-edge: top-edge,
          bottom-edge: bottom-edge,
          features: ( "pkna", ),
          _text
        )
      )

      for metric in metrics.pairs() {
        place(top, move(
          dy: metrics.at(top-edge) - metric.at(1) -
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
              top-edge: metrics.at("x-height") / size / 2 * 1em,
              metric.at(0)
            )
          )
        ))
      }
    })
  })

  [ #typeset(metrics) ]
})
