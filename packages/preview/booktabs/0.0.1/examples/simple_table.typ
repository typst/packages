#import "@local/booktabs:0.0.1": *

#set page(width: auto, height: auto, margin: 15pt)

#set table(stroke: none)

#table(
  columns: 3,
  align: (left, center, center),
  toprule(), // added by this package
  table.header(
    [Substance],
    [Subcritical \ °C],
    [Supercritical \ °C],
  ),
  midrule(), // added by this package
  [Hydrochloric Acid],
  [12.0],
  [92.1],
  [Potassium Hydroxide],
  table.cell(colspan: 2)[24.7],
  cmidrule(start: 1, end: -1), // added by this package
  [Sodium Myreth Sulfate],
  [16.6],
  [104],
  bottomrule() // added by this package
)