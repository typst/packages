// # Tables. Tabelas.
// NBR 14724:2024 5.9, IBGE Apresentação tabular 1993

#import "../style/style.typ": (
  font_size_for_smaller_text, simple_leading_for_smaller_text, simple_spacing_for_smaller_text,
)

#let format_table(body) = {
  // IBGE Apresentação tabular 1993 4.3.3
  // Tables should not have vertical lines
  // Tables should have horizontal lines only around header and at bottom of the table
  set table(stroke: (x, y) => (
    top: if y <= 1 { 1pt } else { 0pt },
    bottom: 1pt,
  ))

  // Table header should be bold
  show table.cell.where(y: 0): strong

  // The first column should be left-aligned, and the following columns should be right-aligned
  set table(
    align: (x, y) => {
      if y == 0 {
        center + horizon
      } else if x == 0 {
        left + horizon
      } else {
        right + horizon
      }
    },
  )

  // The content of a table should be in a smaller font size
  set text(
    size: font_size_for_smaller_text,
  )
  set par(
    leading: simple_leading_for_smaller_text,
    spacing: simple_spacing_for_smaller_text,
  )
  body
}
