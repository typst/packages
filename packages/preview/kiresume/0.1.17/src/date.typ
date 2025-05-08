/// Creates a formatted date with a short month and a year (e.g. "Jan 2025").
///
/// -> content
#let date(
  /// -> int
  year: 0,
  /// -> int
  month: 1
) = {
  datetime(year: year, month: month, day: 1).display("[month repr:short] [year repr:full]")
}

/// Creates a formatted date range, using "Present" in place of a missing end date.
/// 
/// Panics when the start date is `none`.
/// 
/// -> content
#let range(
  /// -> date | none
  from: none, 
  /// -> date | none
  to: none
) = {
  if from == none {
    panic("range.from must not be none - please pass a valid date")
  }

  ( 
    from
    + " " 
    + $dash.em$ 
    + " " 
    + { if to == "Jan 0000" { "Present" } else { to } }
  )
}
