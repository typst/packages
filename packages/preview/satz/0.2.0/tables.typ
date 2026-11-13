#import "defaults.typ": defaults, merge

/// Scientific table with repeated column headings and booktabs-style rules.
///
/// ```example
/// #scientific-table(
///   columns: 2,
///   header: ([Method], [Score]),
///   [Baseline], [0.71],
///   [Proposed], [0.84],
/// )
/// ```
///
/// - columns (positive int or non-empty array): column count or native Typst
///   column widths, such as `(1fr, auto)`; defaults to 1
/// - header (array): non-empty array of header cells, one per column
/// - config (dictionary): partial nested overrides merged over the exported
///   `defaults` dictionary. Hover `satz.defaults` for the shared keys, types,
///   meanings, and baseline values. `scientific-table` reads `tables.stroke`,
///   `tables.inset`, and `tables.font-size`; other accepted values do not affect
///   this helper. The merge helper does not validate unknown values.
#let scientific-table(columns: 1, header: (), config: (:), ..args) = {
  assert((type(columns) == int and columns > 0) or (type(columns) == array and columns.len() > 0),
    message: "scientific-table columns must be a positive integer or a non-empty array of column widths")
  assert(type(header) == array and header.len() > 0,
    message: "scientific-table needs header cells")
  let c = merge(defaults, config)
  set par(justify: false)
  set text(hyphenate: false)
  show table: set text(size: c.tables.font-size)
  show table.cell.where(y: 0): strong
  let options = (stroke: none, inset: c.tables.inset, align: left) + args.named()
  table(
    columns: columns,
    ..options,
    table.header(
      table.hline(stroke: 1.6 * c.tables.stroke),
      ..header,
      table.hline(stroke: c.tables.stroke),
    ),
    ..args.pos(),
    table.footer(table.hline(stroke: 1.6 * c.tables.stroke)),
  )
}

/// Apply scientific table-figure layout with a document-level show rule.
///
/// Native figures and their labels retain numbering, references, and outlines.
///
/// ```example
/// #show: scientific-tables.with(breakable: true)
/// #figure(table(...), caption: [Long table]) <tab:long>
/// ```
///
/// - body (content): the document section whose table figures should be styled
/// - breakable (bool): allow table figures to continue across pages; defaults
///   to false
/// - config (dictionary): partial nested overrides merged over the exported
///   `defaults` dictionary. Hover `satz.defaults` for the shared keys, types,
///   meanings, and baseline values. This rule reads `tables.caption-gap`,
///   `tables.caption-position`, and `captions.size`; `breakable` independently
///   controls whether matching table figures may span pages. Other accepted
///   values do not affect this rule. The merge helper does not validate them.
#let scientific-tables(body, breakable: false, config: (:)) = {
  let c = merge(defaults, config)
  // Setting block(width: 100%) here would leak into cell blocks and make
  // auto columns consume the available width before fr columns are sized.
  show figure.where(kind: table): set block(breakable: breakable)
  show figure.where(kind: table): set figure(gap: c.tables.caption-gap)
  show figure.where(kind: table): set figure.caption(position: c.tables.caption-position)
  show figure.caption.where(kind: table): set align(left)
  show figure.caption.where(kind: table): set par(justify: false)
  show figure.caption.where(kind: table): set text(size: c.captions.size)
  body
}
