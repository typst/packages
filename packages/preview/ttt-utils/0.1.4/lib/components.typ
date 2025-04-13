// Helper and utility functions


/// Create a small line
///
/// ```example
/// Fill the #gap(2cm) .
/// ```
/// -> content
#let gap(
  length,
  stroke: (bottom: 0.5pt),
  value: none
) = {
  box(width: length, outset: (y: 0.5em), stroke: stroke, value)
}

/// Create a block of lines like in a lined notebook.
///
/// ```example
/// Lines: #lines(2)
/// ```
///
/// -> content
#let lines(
  /// number of rows
  /// -> int
  rows,
  /// height of the lines
  /// -> length
  height: 0.9cm,
) = {
    for _ in range(rows) {
        block(above: height, line(length:100%, stroke: 0.3pt + black.lighten(20%)) )
    }
}

/// Creates a checked pattern like in a checkered notebook. \
/// This can be used as background for a box.
///
/// -> tiling
#let caro-pattern(
  /// size of the caros in the pattern
  /// -> length
  size: 0.5cm
) = {
  tiling(
    size: (size, size),
    square(
      size: size,
      stroke: 0.3pt + luma(180)
    )
  )
}

/// Create a checked grid like in a checkered notebook. \
/// This is a new approach using the tiling feature of typst. Uses @caro-pattern.
///
/// ```example
/// #caro-box(3, cols: 10, size: 0.8cm)[$1+1$]
/// ```
///
/// -> content
#let caro-box(
  rows,
  cols: auto,
  size: 0.5cm,
  body
) = {
  layout(container-size => {
    let cols = if( cols == auto ){ int(container-size.width.cm() / size.cm()) } else { cols }

    box(
      height: rows * size,
      width: cols * size,
      stroke: 0.3pt + luma(180),
      fill: caro-pattern(size: size),
      inset: (x: size/2, y: size + 0.1cm)
    )[#body]
  })
}

/// Create a checked grid like in a checkered notebook.
/// ! Old approach using the table feature of typst.
///
/// ```example
/// #caro(3, cols: 10)
/// ```
///
/// -> content
#let caro(
  /// number of rows
  /// -> int
  rows,
  /// number of columns,
  /// if auto cols are 0.5cm wide.
  /// -> int | auto
  cols:auto
) = {
  layout(size => {
    let cols = if( cols == auto ){ int(size.width.cm() / 0.5) } else { cols }
    table(
      columns: (0.5cm,) * cols,
      rows: (0.5cm,) * rows,
      stroke: 0.3pt + luma(180),
      table.cell(y: rows - 1)[],
    )
  })
}

/// Create a small line with a label like a signature field in a form.
///
/// ```example
/// Due: #field("Date", value: "01.01.2021") \
/// Sign here: #field("Signature", width: 4cm)
/// ```
///
/// -> content
#let field(
  /// label which is rendered underneath the line.
  /// -> string
  label,
  /// width of the field.
  /// -> length
  width: 3.5cm,
  /// content which is shown inside the field.
  /// -> content | none
  value: none
) = {
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
/// ```example
/// #checkbox()
/// #checkbox(tick: true)
/// #checkbox(fill: red)
/// #checkbox(fill: green, tick: true)
/// ```
///
/// -> content
#let checkbox(
  /// background color of the box
  /// -> color
  fill: none,
  /// if true a checkmark symbol is shown inside the box.
  /// -> bool
  tick: false
) = box(
  width: 0.8em,
  height: 0.8em,
  stroke: 0.7pt,
  radius: 1pt,
  fill: fill,
  if (tick) { align(horizon + center, sym.checkmark) }
)

/// Create a rounded box around some content.
///
/// ```example
/// #frame[This is framed.]
/// ```
///
/// -> content
#let frame(
  /// the content to show.
  /// -> content
  body,
  /// - ..args (arguments): passed to typst `box` function
  /// -> arguments
  ..args
) = box(radius: 3pt, stroke: 0.5pt, inset: 1em, ..args, body)

/// Create a autosized small colored and rounded box around the content.
///
/// ```example
/// #tag("#tagged")
/// ```
///
/// -> content
#let tag(
  /// the content to show
  /// -> content
  value,
  /// background color
  /// -> color
  fill: orange.lighten(45%)
) = {
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
/// ```example
/// #point-tag(3)
/// ```
///
/// -> content
#let point-tag(
  /// given get_points
  /// -> int
  points
) = {
  assert.eq(type(points),int)
  tag(fill: gray.lighten(35%))[#points #text(0.8em,smallcaps[#if points==1 [PT$\u{0020}$] else [PTs]])]
}
