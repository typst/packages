#let image-panel(graphic, caption, height) = {
  set image(width: 100%, height: height, fit: "contain")
  show figure: set block(above: 0pt, below: 0pt, breakable: false)
  show figure.caption: set align(center)
  set figure(gap: 0.46em)
  figure(graphic, kind: image, numbering: none, caption: caption)
}

#let image-aside(side, graphic, caption, width, height, gutter, vertical, spacing, body) = {
  let panel = grid.cell(align: center + vertical, image-panel(graphic, caption, height))
  let prose = grid.cell(breakable: true, align: start + top, body)
  let (columns, cells) = if side == left { ((width, 1fr), (panel, prose)) } else { ((1fr, width), (prose, panel)) }
  block(above: spacing, below: spacing, grid(columns: columns, column-gutter: gutter, ..cells))
}

/// Place a figure to the left of a prose column.
#let image-left(graphic, caption: none, width: 34%, height: auto, gutter: 1.48em, vertical: top, spacing: 2.38em, body) = {
  image-aside(left, graphic, caption, width, height, gutter, vertical, spacing, body)
}

/// Place a figure to the right of a prose column.
#let image-right(graphic, caption: none, width: 34%, height: auto, gutter: 1.48em, vertical: top, spacing: 2.38em, body) = {
  image-aside(right, graphic, caption, width, height, gutter, vertical, spacing, body)
}

/// Center a figure and its caption in the running text.
#let image-center(graphic, caption: none, width: 75%, height: auto, spacing: 1.12em) = {
  let panel = grid.cell(breakable: false, align: center, image-panel(graphic, caption, height))
  block(above: spacing, below: spacing, grid(columns: (1fr, width, 1fr), [], panel, []))
}
