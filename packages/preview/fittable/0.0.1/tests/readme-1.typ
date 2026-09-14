#import "../src/lib.typ": fit

#let data = (
  [Item], [Description], [Price],
  [Notebook], [A notebook with a long description], [12.00],
)

#fit(
  columns: (auto, auto, 5em),
  table.header([*Item*], [*Description*], [*Price*]),
  ..data,
)
