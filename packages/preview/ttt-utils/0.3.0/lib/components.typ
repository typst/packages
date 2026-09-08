// -----------
// Pattern
// -----------

/// Creates a checked pattern like in a checkered notebook. \
/// This can be used as background for a box.
///
/// -> tiling
#let caro-pattern(
  /// size of the caros in the pattern
  /// -> length
  size: 0.5cm,
  /// color of the background of the pattern
  /// -> color
  fill: none,
  /// color of the lines in the pattern
  /// -> stroke
  stroke: (paint: black, thickness: 0.5pt, dash: "dotted"),
) = {
  tiling(
    size: (size, size),
    square(
      size: size,
      stroke: stroke,
      fill: fill,
    )
  )
}

/// Creates a checked pattern like in a checkered notebook. \
/// This can be used as background for a box.
///
/// -> tiling
#let line-pattern(
  /// height of the lines in the pattern
  /// -> length
  height: 0.9cm,
  /// color of the lines in the pattern
  /// -> stroke
  stroke: (paint: black, thickness: 0.8pt, dash: "dotted"),
) = {
  tiling(
    size: (84pt, height),
    place(
      dy: height - 1pt,
      line(
        length: 100%,
        stroke: stroke
      )
    )
  )
}

/// Create a block of lines like in a lined notebook.
///
/// ```example
/// #lines(2)
/// ```
///
/// -> content
#let lines(
  /// number of rows
  /// -> int
  rows,
  /// height of the lines
  /// -> length
  height: 9mm,
  border: none,
  stroke: (paint: black, thickness: 0.8pt, dash: "dotted"),
  /// -> content
  body
) = {


  layout(container-size => {
    set par(
      leading: height - 0.7em,
      spacing: 2 * height - 0.7em ,
    )
    context {
      let body-size = measure(
        width: container-size.width,
        body,
      )

      block(
        height: calc.max(body-size.height + (height - 0.9em.abs), rows * height + 6pt),
        width: 100%,
        stroke: border,
        fill: line-pattern(height: height, stroke: stroke),
        inset: (x: 1em, y: height - 0.9em),
      )[

        #body
      ]
    }
  })
}

/// Create a checked grid like in a checkered notebook. \
/// This is a new approach using the tiling feature of typst. Uses @caro-pattern.
///
/// ```example
/// #caro-box(3, cols: 10, size: 0.8cm)[$1+1$]
/// ```
///
/// -> content
#let caro(
  rows,
  cols: auto,
  size: 0.5cm,
  radius: 0pt,
  fill: white,
  border: none,
  body
) = {
  layout(container-size => {
    let cols = if( cols == auto ){ int(container-size.width.cm() / size.cm()) } else { cols }

    block(
      height: (rows * size) + 0.5pt,
      width: (cols * size) + 0.5pt,
      stroke: border,
      fill: caro-pattern(size: size, fill: fill),
      inset: (x: size/2, y: 0.16cm),
      radius: radius,
    )[#body]
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
  stroke: (top: 0.7pt, left: 0.7pt, rest: 1pt),
  radius: 1pt,
  fill: fill,
  if (tick) { align(horizon + center, sym.checkmark) }
)

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
  assert.eq(type(points),int, message: "expected points to be an integer, found" + str(type(points)))
  tag(fill: gray.lighten(35%))[#points #text(0.8em,smallcaps[#if points==1 [PT$\u{0020}$] else [PTs]])]
}


#let hint(body, pre:"Hint:") = {
  strong(delta: -100)[#pre #body]
}

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
