/// display some content side-by-side
///
/// - columns (none, auto, integer): Set the amount of columns
/// - gutter (length): grid gutter
/// - ..cols (content): content to show
/// -> content
#let side-by-side(columns: none, gutter: 1em, ..cols) = {
  
  let cols = cols.pos()
  let columns = if columns ==  none { (1fr,) * cols.len() } else { columns }

  assert(
    columns.len() == cols.len(),
    message: "number of columns must match number of cols"
  )
  
  grid(columns: columns, gutter: gutter, ..cols)
  
}

/// utility function to stick header and following block together
#let stick-together(a, b, threshold: 3em) = {
  block(a + v(threshold), breakable: false)
  v(-1 * threshold)
  b
}
