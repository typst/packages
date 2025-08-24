#import "../styling.typ" as styling

#let body-inset = 0.8em
#let stroke-width = 0.13em
#let corner-radius = 5pt

#let boxy(title, tags, body, supplement, number, accent-color) = {
  assert(
    type(accent-color) == color,
    message: "Please provide a color as argument for the frame instance"
      + supplement,
  )

  let stroke = accent-color + stroke-width

  let round-bottom-corners-of-tags = body == []
  let display-title = title not in ([], "")
  let round-top-left-body-corner = title in ([], none) and tags == ()

  let header() = align(
    left,
    {
      let inset = 0.5em

      let tag-elements = tags
      if display-title {
        let title-cell = grid.cell(fill: accent-color, title)
        tag-elements.insert(0, title-cell)
      }

      let rounded-corners = (top: corner-radius)
      if round-bottom-corners-of-tags {
        rounded-corners.bottom = corner-radius
      }

      let rendered-tags = if tag-elements == () [] else {
        let grid-cells = tag-elements.intersperse(grid.vline(stroke: stroke))
        let tag-grid = grid(columns: tag-elements.len(), align: horizon, inset: inset, ..grid-cells)
        box(clip: true, stroke: stroke, radius: rounded-corners, tag-grid)
        h(1fr)
      }

      let supplement-str = box(inset: inset)[#supplement #number]

      layout(((width: available-width)) => {
        if measure(rendered-tags + supplement-str).width < available-width {
          rendered-tags
          supplement-str
        } else [
          #supplement #number \
          #rendered-tags
        ]
      })
    },
  )

  let board() = {
    let round-corners = (bottom: corner-radius, top-right: corner-radius)
    if round-top-left-body-corner {
      round-corners.top-left = corner-radius
    }
    align(
      left,
      block(
        width: 100%,
        inset: body-inset,
        radius: round-corners,
        stroke: stroke,
        spacing: 0em,
        outset: (y: 0em),
        {
          // Divide constructs a line where we need to inject the stroke style because we only have access to the color here
          show: styling.dividers-as({
            v(body-inset - 1em)
            line(length: 100% + 2 * body-inset, stroke: stroke)
            v(body-inset - 1em)
          })
          body
        },
      ),
    )
  }

  let parts = ()

  let rounded-corners = (bottom: corner-radius)

  if title != none {
    parts.push(header())
  }

  if body != [] {
    parts.push(board())
  }

  stack(..parts)
}

