#import "../utils/convert.typ": to-str

/// Generate title page for technical report
///
/// -> content
#let title-page(
  /// Title of the report
  ///
  /// -> content | string
  title: [],
  /// Name(s) of Author(s)
  ///
  /// -> string | array
  author: "",
  /// Name of Company/Institution
  ///
  /// -> content | string
  company: [],
  /// Confidentiality Level
  ///
  /// -> content | string
  confidential: [],
  /// Date of submission
  ///
  /// -> datetime
  date: datetime.today(),
  /// Enable double-sided printing
  ///
  /// -> bool
  double-sided: true,
  /// Date format string
  ///
  /// -> string
  date-format: "[month repr:long] [day], [year]",
  /// This will be placed below the date, can be used for acknowledgement, footnote or other purposes
  ///
  /// -> content
  body,
) = {
  set page(margin: auto, header: none, footer: none)
  set align(center + horizon)
  set pagebreak(weak: true, to: if double-sided { "odd" })

  grid(
    columns: 1,
    gutter: (
      23pt,
      31pt,
      40pt,
      35pt,
      0.17em,
    ),
    align: center + top,

    line(length: 100%, stroke: 3pt),
    text(size: 17.28pt)[#title],
    line(length: 100%, stroke: 3pt),
    [
      #set text(size: 12pt)
      #to-str(author)\
      #company\
      #strong(confidential)
    ],
    [
      #set text(size: 12pt)
      #date.display(date-format)
    ],
    body,
  )
  v(70pt)

  pagebreak()
}
