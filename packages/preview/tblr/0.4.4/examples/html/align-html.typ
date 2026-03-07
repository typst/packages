#import "@preview/tblr:0.4.4": *

// #set page(height: auto, width: auto, margin: 0em)

== HTML/EPUB tables with #link("https://github.com/tshort/tblr/")[tblr]

#html.elem(
  "style",
  "
  table { border-collapse: collapse; font-family: Arial, sans-serif; }
  th, td { padding: 0.5rem 0.75rem; border: 1px solid #ccc; }
  th { background: #eee; text-align: left; }
  td.num { white-space: nowrap; }

  /* Grid container for each number */
  .decimal-cell {
    display: inline-grid;
    align-items: baseline;
  }
  .decimal-cell span {
    white-space: pre-wrap;
  }
  .cell-right{ text-align: right; }
  .cell-left{ text-align: left; padding-left: 0.0em; }
",
)

Decimal-aligned table:

#context tblr(
  columns: 3,
  col-apply((1, 2), within: "body", decimal-align),
  header-rows: 2,
  // header
  table.cell(rowspan: 2)[],
  table.cell(colspan: 2)[Aligned Columns],
  [A],
  [B],
  // "A", [B], "C",
  // "D", "E", "F",
  // body
  "alpha",
  "Text",
  "hello&",
  "beta",
  "10000",
  "&hello",
  "gamma",
  "0.12345",
  "3x",
  "delta",
  ".1",
  "30. mi.",
  "epsilon",
  "1.00",
  "100,000 sq. mi.",
  "zeta",
  "300.",
  "192.168.1.1 ip",
  "eta",
  "-0.999999",
  "v1.0.2",
)

Table generated with custom alignments:

#let df = (
  Polar: ("-130.5", "50.2∠120.3°", "100∠-120°", "2.3∠1.2°"),
  Complex: ("130.5", "50.2+ j90.3", "100- j110", "-90- j120"),
)

#let align-polar = split-and-align.with(
  //          50  .2         ∠      120  .3°
  format: ("\d+", "[^∠]*", "∠", "\d+"),
  align: (right, left, right, right, left),
)
// Regex meanings:
// \d+:   one or more digits
// [^∠]*: anything but ∠
// ∠:     ∠
// \d+:   one or more digits
// The last element is everything after the last match.

#let align-complex = split-and-align.with(
  format: ("\d+", "[^+−-]*", ".*j", "\d+"),
  align: (right, left, right, right, left),
)


#context tblr(
  header-rows: 1,
  rows(0, stroke: (bottom: 1pt)),
  col-apply(within: "body", 0, align-polar),
  col-apply(within: "body", 1, align-complex),
  content-hook: from-dataframe,
  // content
  df,
)

