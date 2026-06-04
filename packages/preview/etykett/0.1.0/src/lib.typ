/// Renders a grid of labels. This sets up the page, creates the grid, and inserts the label
/// contents.
///
/// -> content
#let labels(
  /// A label grid sheet definition as created by @@sheet().
  /// -> dictionary
  sheet: none,
  /// Whether to turn the whole grid upside down. This can be useful when there is a need to feed
  /// the grid sheets upside-down into the printer.
  /// -> bool
  upside-down: false,
  /// The inset inside the individual labels; useful to make sure the label content fits even if
  /// the printer's feeding leads to small alignment inaccuracies. Either a single length or a
  /// dictionary of lengths similar to that accepted by `grid()`: valid keys are `left`, `right`,
  /// `top`, `bottom`, `x`, `y`, and `rest`. If a dictionary is given, missing sides default to 0pt,
  /// but if omitted completely this defaults `1mm`.
  /// -> length | dictionary
  inset: 1mm,
  /// Whether the direction of content in individual (sub)labels is the regular page orientation,
  /// or flipped by 90 degrees. This us useful if the label sheet has e.g. wide labels, but they are
  /// used as tall labels instead.
  /// -> bool
  flipped: false,
  /// When set to a dictionary containing integers `rows` and `columns`, each label is further
  /// subdivided into a grid as defined. This is useful if the labels on available grid sheets are
  /// too big for the desired labels. No insets are added around sublabels inside the same label. If
  /// a dictionary is given but a key is missing, that value defaults to 1.
  /// -> dictionary | none
  sublabels: none,
  /// Whether to show the label and sublabel bounds by a thin, gray stroke.
  /// -> bool
  debug: false,
  /// The actual label contents to print in each label (or sublabel, if applicable).
  /// -> arguments
  ..labels,
) = {
  import "schemas.typ" as schemas: z

  sheet = z.parse(sheet, schemas.sheet)
  inset = z.parse(inset, schemas.inset)
  sublabels = z.parse(sublabels, schemas.sublabels)
  assert.eq(labels.named().len(), 0)
  let labels = labels.pos()

  let (paper, margins, flipped: page-flipped, gutters, rows, columns) = sheet
  if upside-down and type(margins) == dictionary {
    // if it's not a dictionary all margins are the same anyway
    let (left, right, top, bottom) = margins
    margins = (left: right, right: left, top: bottom, bottom: top)
  }

  set page(paper: paper) if type(paper) == str
  set page(width: paper.width, height: paper.height) if type(paper) != str
  set page(margin: margins, flipped: page-flipped)

  labels = labels.chunks(sublabels.rows * sublabels.columns)

  for label-chunk in labels.chunks(rows * columns) {
    show: if upside-down {
      rotate.with(180deg)
    } else {
      it => it
    }
    grid(
      rows: rows*(1fr,),
      columns: columns*(1fr,),
      row-gutter: gutters.y,
      column-gutter: gutters.x,
      inset: inset,
      stroke: if debug { 0.5pt+gray },
      ..labels.map(label => {
        grid(
          rows: sublabels.rows*(1fr,),
          columns: sublabels.columns*(1fr,),
          stroke: if debug { 0.5pt+gray },
          ..label.map(sublabel => {
            show: {
              if flipped { rotate.with(-90deg, reflow: true) }
              else { it => it }
            }
            show: block.with(width: 100%, height: 100%)
            sublabel
          }),
        )
      }),
    )
  }
}

/// Inserts a number of identical (sub)labels.
///
/// Example:
///
/// ```typ
/// #etykett.labels(
///   // ... sheet configuration
///
///   ..repeat(3, my-label),
/// )
/// ```
///
/// -> array
#let repeat(
  /// The number of (sub)labels to insert.
  /// -> int
  n,
  /// The content of the (sub)labels.
  /// -> content
  body,
) = {
  n * (body,)
}

/// Inserts a number of empty (sub)labels. This is useful for reusing a sheet of labels that has
/// been partially used already.
///
/// Example:
///
/// ```typ
/// #etykett.labels(
///   // ... sheet configuration
///
///   ..skip(3),
///   // ... add actual labels
/// )
/// ```
///
/// -> array
#let skip(
  /// The number of empty (sub)labels to insert.
  /// -> int
  n
) = {
  repeat(n, none)
}

/// Returns a dictionary containing the definitions of a label grid sheet.
///
/// -> dictionary
#let sheet(
  /// The paper size, either as a name like `"a4"`, or a dictionary with lengths `width` and
  /// `height`.
  /// -> string | dictionary
  paper: none,
  /// The page margins, either a single length or a dictionary of lengths similar to that accepted
  /// by `page()`: valid keys are `left`, `right`, `top`, `bottom`, `x`, `y`, and `rest`. If omitted
  /// (or a side in the dictionary is missing), that value defaults to `0pt`.
  /// -> length | dictionary
  margins: 0pt,
  /// Whether the sheet is flipped, i.e. landscape
  /// -> bool
  flipped: false,
  /// The gutters between labels, either a single length or a dictionary of lengths with keys `x`
  /// and `y`. If omitted (or a value in the dictionary is missing), that value defaults to `0pt`.
  /// -> length | dictionary
  gutters: 0pt,
  /// The number of rows in the grid of labels. The available space is distributed evenly.
  /// -> int
  rows: none,
  /// The number of columns in the grid of labels. The available space is distributed evenly.
  /// -> int
  columns: none,
) = {
  import "schemas.typ" as schemas: z
  z.parse((
    paper: paper,
    margins: margins,
    flipped: flipped,
    gutters: gutters,
    rows: rows,
    columns: columns,
  ), schemas.sheet)
}
