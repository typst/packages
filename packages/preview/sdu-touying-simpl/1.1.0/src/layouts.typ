// Default primary color
#let _default-primary = rgb("#880000")

// Multi-column layout with optional divider lines
#let sdu-columns(n, divider: false, primary: _default-primary, ..bodies) = {
  let items = bodies.pos()
  if divider {
    let cells = ()
    for (i, item) in items.enumerate() {
      cells.push(item)
      if i < items.len() - 1 {
        cells.push(line(angle: 90deg, length: 100%, stroke: 0.5pt + primary.lighten(60%)))
      }
    }
    grid(
      columns: items.len() * 2 - 1,
      column-gutter: 0em,
      ..cells,
    )
  } else {
    grid(
      columns: (1fr,) * n,
      column-gutter: 1.5em,
      ..items,
    )
  }
}

// Card component with optional title bar
#let sdu-card(title: none, body, primary: _default-primary) = {
  block(
    width: 100%,
    stroke: 1pt + luma(200),
    radius: 6pt,
    clip: true,
    {
      if title != none {
        block(
          width: 100%,
          inset: (x: 12pt, y: 8pt),
          stroke: (bottom: 1pt + primary.lighten(70%)),
          text(fill: primary, weight: "bold", size: 0.9em, title),
        )
      }
      block(
        width: 100%,
        inset: 12pt,
        body,
      )
    },
  )
}

// Highlight block
#let sdu-highlight(body, primary: _default-primary) = {
  block(
    width: 100%,
    fill: primary.lighten(92%),
    stroke: (left: 3pt + primary),
    radius: 2pt,
    inset: (x: 12pt, y: 8pt),
    body,
  )
}

// Quote / callout block
#let sdu-quote(body, source: none, primary: _default-primary) = {
  block(
    width: 100%,
    inset: (left: 16pt, right: 12pt, top: 10pt, bottom: 10pt),
    {
      // Large decorative quotation mark
      place(
        top + left,
        dx: -4pt,
        dy: -8pt,
        text(size: 2.5em, fill: primary.transparentize(80%), weight: "bold", ["]),
      )
      // Quote body
      set text(style: "italic")
      body
      // Source attribution
      if source != none {
        v(0.5em)
        set text(style: "normal", size: 0.85em, fill: luma(120))
        [— ] + source
      }
    },
  )
}
