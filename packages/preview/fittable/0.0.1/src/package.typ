#let is-auto(a) = a == auto
#let is-content(a) = type(a) == content
#let is-fr(a) = type(a) == fraction
#let is-int(a) = type(a) == int
#let is-ratio(a) = type(a) == ratio
// relative = ratio + absolute
#let is-rel(a) = type(a) == relative

#let transpose(m) = array.zip(..m)

#let reshape(arr, new-shape) = {
  let flat = arr.flatten()
  if new-shape.len() == 1 {
    return flat
  } else {
    let size = new-shape.slice(1).product()
    return range(new-shape.at(0)).map(i => reshape(
      flat.slice(i * size, (i + 1) * size),
      new-shape.slice(1),
    ))
  }
}

#let intrinsic(con) = measure(con).width

/// A table layout that automatically adds `1fr` into `auto` columns to fill the available space.
///
/// -> content
#let fit(
  /// The function to use for the layout, either `table` or `grid`.
  ///
  /// -> table | grid
  func: table,
  /// The column sizes. If the page or container size is enough to fit this layout,
  /// the `auto` columns would be added with `1fr` to fill the remaining space.
  /// Otherwise, the layout would fall back to the default layout.
  ///
  /// -> auto | int | relative | fraction | array
  columns: (),
  /// Variadic parameters are the content and other parameters passed to `func`.
  /// Note that `colspan` and `rowspan` are not supported now.
  ///
  /// -> arguments
  ..children,
) = context layout(size => {
  let cells = children
    .pos()
    .fold((), (l, arg) => {
      if is-content(arg) {
        if arg.func() == func.header or arg.func() == func.footer {
          // Extract the cells from the header / footer
          return l + arg.children
        } else if arg.func() == func.hline or arg.func() == func.vline {
          // Ignore lines
          return l
        }
      }
      // Otherwise, it's a cell
      return l + (arg,)
    })

  let cols = (
    if is-int(columns) { (auto,) * columns } else if is-auto(columns) { (auto,) } else { columns }
  ).map(col => if is-ratio(col) {
    size.width * col
  } else if is-rel(col) {
    size.width * col.ratio + col.length
  } else {
    col
  })

  let n-col = cols.len()
  let matrix = reshape(cells, (calc.div-euclid(cells.len(), n-col), n-col))

  let intrinsics = transpose(matrix).map(col => calc.max(..col.map(intrinsic)))
  let specified = cols
    .zip(intrinsics)
    .fold(
      0pt,
      (acc, (spec, intus)) => acc + if is-auto(spec) { intus } else if is-fr(spec) { 0pt } else { spec },
    )

  if specified.to-absolute() >= size.width {
    // Not enough space, fall back to the default layout.
    return func(columns: columns, ..children)
  }

  let divisor = cols.fold(0, (acc, spec) => (
    acc + if is-auto(spec) { 1 } else if is-fr(spec) { spec / 1fr } else { 0 }
  ))
  let res = if divisor == 0 { 0pt } else { (size.width - specified) / divisor }

  cols = cols
    .zip(intrinsics)
    .map(
      ((spec, intus)) => if is-auto(spec) { intus + res } else if is-fr(spec) { res * (spec / 1fr) } else { spec },
    )
  return func(columns: cols, ..children)
})
