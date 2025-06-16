/// Helper and utility functions

/// Create a block of lines like in a lined notebook.
///
/// - rows (int): number of rows to
/// -> content
#let lines(rows) = {
    for _ in range(rows) {
        block(above: 0.9cm, line(length:100%, stroke: 0.3pt + black.lighten(20%)) )
    }
}

/// Create a checked grid like in a checkered notebook.
///
/// - rows (int): number of rows to
/// - cols (auto, int): define the number of cols, if auto cols are 0.5cm wide.
/// -> content
#let caro(rows, cols:auto) = {
  layout(size => {
    let cols = if( cols == auto ){ int(size.width.cm() / 0.5) } else { cols }
    table(
      columns: (0.5cm,) * cols, 
      rows: (0.5cm,) * rows,
      stroke: 0.3pt + luma(140),
      table.cell(y: rows - 1)[],
    )
  })
}

/// Create a small line with a label like a signature field in a form. 
///
/// - label (string): label which is rendered underneath the line.
/// - width (length): width of the field.
/// - value (content, any): content which is shown inside the field.
/// -> content
#let field(label, width: 3.5cm, value: none) = {
  box(
    stroke: (bottom: 0.5pt), 
    width: width, 
    height: 0.8cm,
    inset: (bottom: 3pt)
  )[
    #align(bottom + center,value)
    #place(bottom + end,dy: 12pt)[#text(10pt, label)]
  ] 
}

/// Create a checkbox
///
/// - fill (color): background color of the box
/// - tick (bool): if true a checkmark symbol is shown inside the box.
/// -> content
#let checkbox(fill: none, tick: false) = box(
  width: 0.8em, 
  height: 0.8em, 
  stroke: 0.7pt, 
  radius: 1pt, 
  fill: fill,
  if (tick) { align(horizon + center, sym.checkmark) }
)

/// Create a rounded box around some content.
///
/// - body (content): the content to show.
/// - ..args (arguments): passed to typst `box` function
#let frame(body, ..args) = box(radius: 3pt, stroke: 0.5pt, inset: 1em, ..args, body)

/// Create a autosized small colored and rounded box around the content.
///
/// - value (content): the content to show
/// - fill (color): background of the box
/// -> content
#let tag(value, fill: orange.lighten(45%)) = {
  if value != none {
    context {
      let size = measure(value)
      box(
        width: size.width + 6pt,
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        radius: 2pt,
        fill: fill
      )[#value]
    }
  }
}


/// Create a small tag label with the given amount of points. 
///
/// - points (int): given get_points
/// -> content
#let point-tag(points) = {
  assert.eq(type(points),int)
  tag(fill: gray.lighten(35%))[#points #text(0.8em,smallcaps[#if points==1 [PT$\u{0020}$] else [PTs]])]
}