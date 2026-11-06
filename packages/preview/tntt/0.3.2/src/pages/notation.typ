/// Notation Page
///
/// - twoside (bool): Whether to use two-sided layout.
/// - outlined (bool): Whether to outline the page.
/// - title (content): The title of the notation page.
/// - width (length | relative): The width of the notation grid.
/// - columns (array): The widths of the grid columns for terms and descriptions.
/// - row-gutter (length): The vertical space between rows.
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
  ..args,
  // self
  it,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    title,
  )

  align(
    center,
    block(
      width: width,
      align(
        start,
        grid(
          columns: columns,
          row-gutter: row-gutter,
          ..args,
          ..it.children.filter(it => it.func() == terms.item).map(it => (it.term, it.description)).flatten()
        ),
      ),
    ),
  )

  if twoside { pagebreak() + " " }
}
