#import "@preview/linguify:0.5.0": linguify

/// Renders the title page of the document.
///
/// This function generates a complete title page with optional logos,
/// title, authors, publication date, metadata table, and signature lines.
/// The layout adapts depending on which logos are provided and merges
/// any custom entries into the default metadata display.
///
/// Elements included:
/// - University and/or company logos
/// - Paper type and title
/// - Author names
/// - Publication date and additional field information
/// - Metadata table (student ID, enrollment year, semester, company supervisor, word count)
/// - Signature lines with optional custom labels
/// - Automatic page break after the title page
///
/// Parameters:
/// - language (str, default: "en"):
///     Document language, used for date formatting and localization.
///
/// - metadata (dictionary, default: see below):
///     Metadata used to populate the title page:
///     (
///       paper-type: [],
///       title: [PTB Template],
///       student-id: "",
///       authors: none,
///       company: "",
///       enrollment-year: "",
///       semester: "",
///       company-supervisor: "",
///       authors-per-line: 2,
///       field-of-study: none,
///       university: none,
///       date-of-publication: none,
///       uni-logo: none,
///       company-logo: none,
///     )
///
/// - custom-entries (dictionary, default: ()):
///     Optional additional metadata entries to be merged into the default table.
///
/// - label-signature-left (content, default: []):
///     Label shown below the left signature line; falls back to
///     localized default if empty.
///
/// - label-signature-right (content, default: []):
///     Label shown below the right signature line; falls back to
///     localized default if empty.
///
/// - word-count (content or none, default: none):
///     Optional word count displayed in the metadata table.
///
/// Returns:
/// - content:
///     A fully formatted title page including logos, heading, authors,
///     metadata table, and signature lines, followed by a page break.
///
/// Example:
/// ```typst
/// #_render-title-page(
///   language: "en",
///   metadata: (
///     title: [My Thesis],
///     authors: ["Max Mustermann"],
///     student-id: "123456",
///     university: [Sample University]
///   ),
///   word-count: 12500
/// )
/// ```
#let _render-title-page(
  metadata: (
    paper-type: [],
    title: [PTB Template],
    student-id: "",
    authors: none,
    company: "",
    enrollment-year: "",
    semester: "",
    company-supervisor: "",
    // These do not need to be changed by the user
    authors-per-line: 2,
    field-of-study: none,
    university: none,
    date-of-publication: none,
    uni-logo: none,
    company-logo: none,
  ),
  custom-entries: (),
  label-signature-left: [],
  label-signature-right: [],
  word-count: none,
) = {
  let equal-spacing = 0.25fr
  set align(center)

  // Logo settings
  v(equal-spacing)
  if metadata.at("uni-logo", default: none) != none and metadata.at("company-logo", default: none) != none {
    grid(
      columns: (1fr, 1fr),
      rows: (auto),
      grid.cell(
        colspan: 1,
        align: center + horizon,
        metadata.uni-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center + horizon,
        metadata.company-logo,
      ),
    )
  } else if metadata.at("company-logo", default: none) != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center + horizon,
        metadata.company-logo,
      )
    )
  } else {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center + horizon,
        metadata.at("uni-logo", default: image("../template/images/header_logo.png", width: 46%))
      ),
    )
  }
  v(equal-spacing)

  // Title settings
  let line-length = 90%
  text(1em, weight: 700, baseline: -13.5pt, metadata.at("paper-type", default: []))
  line(length: line-length)
  text(2em, weight: 700, metadata.title)
  line(length: line-length)

  // Author information.
  let authorsText = ""

  if type(metadata.authors) == str {
    authorsText = metadata.authors
  } else if type(metadata.authors) == array {
    let lines = metadata.authors.chunks(metadata.at("authors-per-line", default: 2))
    for line in lines {
      authorsText = authorsText + (line.join(", ")) + "\n"
    }
  }

  pad(
    top: 2.9em,
    text(
      1.3em,
      strong(authorsText)
    )
  )

  // Middle section
  context {
    text(
      1.1em,
      [
        #linguify("published-on")
        #metadata.at(
          "date-of-publication",
          default: if text.lang == "de" {
            datetime.today().display("[day].[month].[year]")
          } else {
            datetime.today().display()
          }
        )
      ]
    )
  }
  v(0.6em, weak: true)
  $circle.filled.small$
  v(0.6em, weak: true)
  metadata.at("field-of-study", default: linguify("field-of-study-default"))
  v(0.6em, weak: true)
  metadata.at("university", default: linguify("university-default"))

  v(equal-spacing)

  let merge-entries(defaults, customs) = {
    let base = defaults
    for entry in customs {
      let idx = entry.at("index", default: base.len())
      base.insert(idx, (entry.key, entry.value))
    }
    base
  }

  let default-entries = (
    (linguify("titlepage-company"), metadata.company),
    (linguify("titlepage-enrollment-year"), metadata.enrollment-year),
    (linguify("titlepage-semester"), metadata.semester),
    (linguify("titlepage-student-id"), metadata.student-id),
    (linguify("titlepage-company-supervisor"), metadata.company-supervisor),
    (linguify("titlepage-word-count"), word-count),
  )

  let final-entries = merge-entries(default-entries, custom-entries)

  {
    show table.cell.where(x: 0): strong
    table(
      columns: 2,
      stroke: none,
      align: left,
      column-gutter: 5%,
      ..final-entries.flatten()
    )
  }

  v(2*equal-spacing)

  let sig_left = if label-signature-left == [] {
    linguify("titlepage-signature-left")
  } else {
    label-signature-left
  }
  let sig_right = if label-signature-right == [] {
    linguify("titlepage-signature-right")
  } else {
    label-signature-right
  }

  table(
    columns: (50%,50%),
    stroke: none,
    inset: 20pt,
    align: left,
    [#line(length: 100%)#sig_left],
    [#line(length: 100%)#sig_right],
  )

  v(equal-spacing)
  pagebreak()
  set align(left)
}
