/// display some content side-by-side
///
/// - columns (none, auto, integer): Set the amount of columns
/// - gutter (length): grid gutter
/// - ..cols (content): content to show
/// -> content
#let side-by-side(columns: auto, gutter: 1em, ..cols) = {

  let cols = cols.pos()
  let columns = if columns == auto { (1fr,) * cols.len() } else { columns }

  assert(
    columns.len() == cols.len(),
    message: "number of columns must match number of cols"
  )

  grid(columns: columns, gutter: gutter, ..cols)

}
