// Reference line and annotation series constructors.

/// Places a text annotation at an arbitrary position inside the plot area.
#let note(

  /// Content to display (text, math, or any Typst content).
  /// -> content
  body,

  /// Position as `(x, y)` in data coordinates.
  /// -> array
  pos,

  /// CeTZ anchor controlling which part of the content box sits at `pos`.
  /// -> str
  anchor: "center",

  /// Font size for the annotation text.
  /// -> length
  size: 9pt,
) = (annotation: body, pos: pos, anchor: anchor, size: size)

/// Draws a vertical reference line at a given x-coordinate.
#let vline(

  /// The x-coordinate where the vertical line is drawn.
  /// -> float
  x0,

  /// Stroke style for the line.
  /// -> stroke
  stroke: luma(100) + 0.6pt,

  /// Lower y-bound of the line. When `auto`, extends to the plot's ymin.
  /// -> auto | float
  ymin: auto,

  /// Upper y-bound of the line. When `auto`, extends to the plot's ymax.
  /// -> auto | float
  ymax: auto,
) = {
  let spec = (vline: x0, stroke: stroke)
  if ymin != auto { spec.insert("ymin", ymin) }
  if ymax != auto { spec.insert("ymax", ymax) }
  spec
}

/// Draws a horizontal reference line at a given y-coordinate.
#let hline(

  /// The y-coordinate where the horizontal line is drawn.
  /// -> float
  y0,

  /// Stroke style for the line.
  /// -> stroke
  stroke: luma(100) + 0.6pt,

  /// Left x-bound of the line. When `auto`, extends to the plot's xmin.
  /// -> auto | float
  xmin: auto,

  /// Right x-bound of the line. When `auto`, extends to the plot's xmax.
  /// -> auto | float
  xmax: auto,
) = {
  let spec = (hline: y0, stroke: stroke)
  if xmin != auto { spec.insert("xmin", xmin) }
  if xmax != auto { spec.insert("xmax", xmax) }
  spec
}
