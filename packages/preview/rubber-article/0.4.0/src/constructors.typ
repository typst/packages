// This file contains functions that will generate some content.

#import "dependencies.typ": *

/// This function will display the frontmatter of the document.
/// This includes the title, authors, and date.
///
/// Example usage:
/// ```typ
/// #maketitle(
///   title: "The Title of the Paper",
///   authors: ("Authors Name",),
///   date: "2025-01-01",
/// )
/// ```
///
/// -> content
#let maketitle(
  /// The title of the document.
  /// -> string | content
  title: "",
  /// The authors of the document.
  /// -> array
  authors: (),
  /// The date of the document.
  /// -> string | content | datetime
  date: none,
  /// Use title and author information for
  /// the document metadata.
  /// -> bool
  metadata: true,
) = {
  if metadata {
    set document(author: authors, title: title)
  }
  // Author information.

  let authors-text = {
    set text(size: 1.1em)
    pad(
      top: 0.5em,
      bottom: 0.5em,
      x: 2em,
      grid(
        columns: (1fr,) * calc.min(3, authors.len()),
        gutter: 1em,
        ..authors.map(author => align(center, author)),
      ),
    )}
    // Frontmatter

    align(center)[
      #v(60pt)
      #block(text(weight: 400, 18pt, title))
      #v(1em, weak: true)
      #authors-text
      #v(1em, weak: true)
      #block(text(weight: 400, 1.1em, date))
      #v(20pt)
    ]
  }

  /// This function will display a custom table. The table uses the `pillar` package
  /// under the hood to interact with the table in a similar manner as in Latex.
  /// This means, that the columns and vertical lines can be defined with a string.
  /// Furthermore, the table automatically adds 3 horizontal lines.
  ///
  ///
  /// Example usage:
  /// ```typ
  /// #ctable(
  ///   cols:"l|cr",
  ///   [A], [B], [C],
  ///  ..range(1,16).map(str),
  /// )
  /// ```
  /// -> content
  #let ctable(
    ..data,
    /// A string that defines the columns and vertical lines of the table.
    /// -> string
    cols: "ccc",
    /// The linesytle of the table, especially the top and bottom horizontal lines.
    /// -> length
    stroke: .75pt,
    /// The linesytle of the middle horizontal line.
    /// -> length
    middle-stroke: .6pt,
    /// The linesytle of the vertical lines.
    /// -> length
    vertical-stroke: .75pt,
    /// The number of header rows.
    /// -> int
    header-rows: 1,
  ) = table(
    ..pillar.cols(cols, stroke: vertical-stroke),
    table.hline(y: 0, stroke: stroke),
    table.hline(y: header-rows, stroke: middle-stroke),
    ..data,
    table.hline(stroke: stroke),
  )
