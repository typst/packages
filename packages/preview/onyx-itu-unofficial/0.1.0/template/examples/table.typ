= Table Examples

== Basic Tables
// Simple table using the built-in table function
#table(
  columns: (auto, auto, auto),
  align: center,
  inset: 1em,
  [*Name*], [*Age*], [*Role*],
  [Alice], [28], [Designer],
  [Bob], [34], [Developer],
  [Charlie], [45], [Manager],
)

== Table figure
// Table wrapped in a figure with a caption
#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    inset: 1em,
    [*Name*], [*Age*], [*Role*],
    [Alice], [28], [Designer],
    [Bob], [34], [Developer],
    [Charlie], [45], [Manager],
  ),
  caption: "A simple table with a caption",
)

== Table Styling
// Table with custom styling
#table(
  columns: (1fr, auto, auto),
  inset: 1em,
  fill: (_, row) => if row == 0 { rgb("#dfebf6") } else if calc.odd(row) { rgb("#f7f7f7") } else { white },
  stroke: 0.7pt + rgb("#5c8db7"),
  [*Product*], [*Price*], [*Quantity*],
  [Laptop], [\$999], [5],
  [Keyboard], [\$25], [10], 
  [Mouse], [\$85], [7],
  [Monitor], [\$249], [3],
)

== Column Sizing
// Control column widths
#table(
  columns: (20%, 50%, 30%),
  inset: 1em,
  [*Column 1*], [*Column 2*], [*Column 3*],
  [This is some text in the first column],
  [This column is wider and has more space for content],
  [Back to a narrower column],
)
