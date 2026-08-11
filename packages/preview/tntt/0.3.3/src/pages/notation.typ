/// Notation Page
///
/// - twoside (bool): Whether to use two-sided layout.
/// - outlined (bool): Whether to outline the page.
/// - title (content): The title of the notation page.
/// - width (length | relative): The width of the notation grid.
/// - columns (array): The widths of the grid columns for terms and descriptions.
/// - row-gutter (length): The vertical space between rows.
/// - chunked (bool): Whether to chunk the content by parbreaks.
/// - blank-row-gutter (length | none): The vertical space for blank rows, defaults to `row-gutter * 2` if not specified.
/// - args (dictionary): Additional arguments for the grid layout.
/// - it (content): The content of the notation page.
/// -> content
#let notation(
  // from entry
  twoside: false,
  // options
  outlined: false,
  title: [符号和缩略语说明],
  width: 100%,
  columns: (96pt, 1fr),
  row-gutter: 12pt,
  chunked: false,
  blank-row-gutter: none,
  ..args,
  // self
  it,
) = {
  assert(type(row-gutter) == length, message: "row-gutter must be a length value here.")

  let blank-row-gutter = if blank-row-gutter == none { 1.5 * row-gutter }

  let blank-row-inset = if chunked { (blank-row-gutter - 2 * row-gutter) / 2 } else { -row-gutter / 2 }

  pagebreak(weak: true, to: if twoside { "odd" })

  heading(level: 1, numbering: none, outlined: outlined, title)

  align(center, block(width: width, align(start, grid(
    columns: columns,
    row-gutter: row-gutter,
    ..args,
    ..it
      .children
      .filter(it => it.func() == parbreak or it.func() == terms.item)
      .map(it => if (it.func() == parbreak) {
        grid.cell(none, colspan: 2, inset: (y: blank-row-inset))
      } else { (it.term, it.description) }) // terms.item
      .flatten()
  ))))

  /// Notation page is the last page of the front matter,
  /// so we need to ensure it ends with a page break before the main matter in two-sided mode.
  if twoside { pagebreak() + " " }
}
