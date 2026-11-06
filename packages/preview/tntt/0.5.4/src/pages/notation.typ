/// Notation Page
///
/// - twoside (bool, str): Whether to use two-sided layout.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - title (content): The title of the notation page.
/// - width (length, relative): The width of the notation grid.
/// - columns (array): The widths of the grid columns for terms and descriptions.
/// - row-gutter (length): The vertical space between rows.
/// - chunked (bool): Whether to chunk the content by parbreaks.
/// - blank-row-gutter (length, none): The vertical space for blank rows, defaults to `row-gutter * 2` if not specified.
/// - it (content): The content of the notation page.
/// -> content
#let notation(
  // from entry
  twoside: false,
  // options
  title: [符号和缩略语说明],
  outlined: false,
  bookmarked: true,
  width: 100%,
  columns: (96pt, 1fr),
  row-gutter: 12pt,
  chunked: false,
  blank-row-gutter: none,
  // self
  it,
) = {
  assert(type(row-gutter) == length, message: "row-gutter must be a length value here.")

  import "../utils/util.typ": twoside-pagebreak

  let blank-row-gutter = if blank-row-gutter == none { 1.5 * row-gutter }

  let blank-row-inset = if chunked { (blank-row-gutter - 2 * row-gutter) / 2 } else { -row-gutter / 2 }

  let select-term = it => if (it.func() == terms.item) { (it.term, it.description) } else {
    grid.cell(none, colspan: 2, inset: (y: blank-row-inset)) // it.func() == parbreak
  }

  twoside-pagebreak(twoside)

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)

  align(center, block(width: width, align(start, grid(
    columns: columns, row-gutter: row-gutter,
    ..it.children.filter(it => it.func() == parbreak or it.func() == terms.item).map(select-term).flatten()
  ))))
}
