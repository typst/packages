// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify-raw
#import "@preview/glossarium:0.5.10": print-glossary

/// Internal state to track whether we are currently rendering an outline.
/// -> state
#let __in-outline = state("in-outline", false)

/// Creates a caption that conditionally includes a source reference.
///
/// When rendered in an outline (e.g., list of figures), only the caption text
/// is shown. In the document body, both the caption and source are displayed.
/// This prevents source citations from interfering with outline sorting,
/// especially when using IEEE bibliography style.
///
/// ```example
/// #caption-with-source(
///   [System architecture],
///   [(Source: Author)]
/// )
/// ```
/// -> content
#let caption-with-source(
  /// The main caption text. -> content
  caption-text,
  /// The source reference (typically a citation like `[@source]`). -> content
  source,
) = context {
  if __in-outline.at(here()) {
    caption-text
  } else {
    caption-text + " " + source
  }
}

/// Creates a spaced horizontal line for use within tables.
///
/// Returns an array of three table elements: a spacing cell, a horizontal line,
/// and another spacing cell. This creates visual separation between table sections
/// with consistent vertical padding.
///
/// ```example
/// #table(
///   columns: 2,
///   stroke: none,
///   [Header A], [Header B],
///   ..table-hline-spaced(0.3em, 2),
///   [Data 1], [Data 2],
/// )
/// ```
/// -> array
#let table-hline-spaced(
  /// The vertical spacing (inset) above and below the line. -> length
  space,
  /// The number of columns in the table (for colspan). -> int
  columns,
  /// Additional arguments passed to `table.hline()`.
  ..hline-args,
) = {
  return (
    table.cell(colspan: columns, inset: space, {}),
    table.hline(..hline-args),
    table.cell(colspan: columns, inset: space, {}),
  )
}

/// Creates a raw table figure with custom caption formatting.
///
/// This function wraps a table in a figure with special styling:
/// - Uses Roman numeral ("I") numbering for the outer figure
/// - Nested figures inside tables use standard Arabic numerals
/// - Captions are displayed above the table with the supplement in uppercase
///   and the body in small caps
///
/// ```example
/// #tablefigure-raw(
///   caption: [Custom Table],
///   table(
///     columns: 2,
///     [A], [custom],
///     [table], [style],
///   )
/// )
/// ```
/// -> content
#let tablefigure-raw(
  /// Optional caption for the table figure. -> content | none
  caption: none,
  /// Optional label string for cross-referencing. -> str | none
  reference: none,
  /// The table content to display. -> content
  body,
) = {
  set figure(numbering: "I")
  show figure.where(kind: table): it => {
    set figure(numbering: "1") // Unsert "I" numbering for nested figures inside tables
    block({
      if it.caption != none {
        [#upper(it.caption.supplement) #it.caption.counter.display()]
        linebreak()
        smallcaps(it.caption.body)
      }
      it.body
    })
  }
  [
    #figure(
      body,
      caption: caption,
      kind: table,
    )
    #if reference != none {
      label(reference)
    }
  ]
}

/// Creates a styled table with academic/scientific formatting.
///
/// Applies professional table styling commonly used in academic papers:
/// - Left-aligned text with no cell strokes
/// - Double horizontal lines at the top and bottom
/// - Single horizontal line below the header row
/// - Consistent vertical spacing around lines
///
/// ```example
/// #styled-table(
///   columns: 3,
///   table-content: (
///     table.header(
///       [*Name*], [*Value*], [*Unit*]
///     ),
///     [Temperature], [25], [°C],
///     [Pressure], [101.3], [kPa],
///   ),
/// )
/// ```
/// -> content
#let styled-table(
  /// Array of table cells and control elements.
  /// Can include `table.header`, `table.cell`, and `table.hline` elements. -> array
  table-content: (),
  /// Column specification passed to `table()`.
  /// Can be a number of columns, an array of widths, or `auto`. -> auto | int | array
  columns: auto,
  /// Additional arguments passed to `table()`.
  ..args,
) = {
  // General styling
  set table(align: left, stroke: none)
  show table: set par(justify: false)
  let col-count = if type(columns) == array { columns.len() } else if (
    type(columns) == int
  ) { columns } else { 1 }
  let additional-v-space = .2em

  // heading-content stroke
  let last-heading-row = -1
  for (index, item) in table-content.enumerate() {
    if type(item) == content and item.func() == table.header {
      last-heading-row = index
    }
  }

  if last-heading-row != -1 {
    for item in table-hline-spaced(additional-v-space, col-count) {
      table-content.insert(last-heading-row + 1, item)
    }
  }

  // Top and bottom double line strokes
  table-content.insert(0, table.cell(
    colspan: col-count,
    inset: additional-v-space,
    {},
  ))
  table-content.insert(0, table.hline())
  table-content.insert(0, table.cell(colspan: col-count, inset: 2pt, {}))
  table-content.insert(0, table.hline())
  table-content.push(table.cell(
    colspan: col-count,
    inset: additional-v-space,
    {},
  ))
  table-content.push(table.hline())
  table-content.push(table.cell(colspan: col-count, inset: 2pt, {}))
  table-content.push(table.hline())
  table(
    columns: columns,
    ..table-content,
    ..args,
  )
}

/// Creates a complete styled table figure with caption and reference support.
///
/// This is the main function for creating publication-ready tables. It combines
/// @styled-table for formatting with @tablefigure-raw for figure wrapping,
/// providing a convenient all-in-one solution.
///
/// ```example
/// #tablefigure(
///   columns: 3,
///   caption: [Results],
///   table-content: (
///     table.header(
///       [*Trial*], [*Group*], [*Result*]
///     ),
///     [1], [Control], [Baseline],
///     [2], [Test A], [+15%],
///   ),
/// )
/// ```
/// -> content
#let tablefigure(
  /// Array of table cells and control elements. -> array
  table-content: (),
  /// Optional caption for the table. -> content | none
  caption: none,
  /// Optional label string for cross-referencing. -> str | none
  reference: none,
  /// Additional arguments passed to @styled-table and `table()`,
  /// such as `columns`, `align`, etc.
  ..args,
) = {
  tablefigure-raw(caption: caption, reference: reference, styled-table(
    table-content: table-content,
    ..args,
  ))
}

#let __linguify-content(..args) = {
  context eval(linguify-raw(..args), mode: "markup")
}

/// Displays a glossary without interfering with the glossary shown at the end of the document.
///
/// Usefull when wanting to display part of a glossary in the document content.
///
/// Wraps `print-glossary` by `glossarium`. See the #link("https://typst.app/universe/package/glossarium/")[glossarium documentation] for more information.
///
/// -> content
#let inline-glossary(
  /// The list of entries -> array
  entry-list,
  /// The list of groups to display (only included groups will be shown the rest will be hidden) -> array
  groups,
  /// Whether to show group headings or not -> bool
  display-headings: false,
  /// Additional arguments passed to `print-glossary` -> arguments
  ..args,
) = {
  let custom-print-reference(
    entry,
    show-all: false,
    disable-back-references: false,
    deduplicate-back-references: false,
    minimum-refs: 1,
    description-separator: ": ",
    shorthands: none,
    user-print-gloss: none,
    user-print-title: none,
    user-print-description: none,
    user-print-back-references: none,
  ) = {
    user-print-gloss(
      entry,
      show-all: show-all,
      disable-back-references: true,
      deduplicate-back-references: deduplicate-back-references,
      minimum-refs: minimum-refs,
      description-separator: description-separator,
      user-print-title: user-print-title,
      user-print-description: user-print-description,
      user-print-back-references: user-print-back-references,
    )
  }

  let args-cp = args.named()
  if not display-headings {
    args-cp.insert("user-print-group-heading", (..args) => {})
  }

  print-glossary(
    entry-list,
    groups: groups,
    user-print-reference: custom-print-reference,
    ..args-cp,
  )
}
