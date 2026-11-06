#import "@preview/tablem:0.2.0": tablem, three-line-table

#set page(width: 35em, height: auto)
#set table(align: center + horizon)

#tablem[
  | *Name* | *Location* | *Height* | *Score* |
  | ------ | ---------- | -------- | ------- |
  | John   | Second St. | 180 cm   |  5      |
  | Wally  | Third Av.  | 160 cm   |  10     |
]

#let three-line-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: none,
      align: center + horizon,
      table.hline(y: 0),
      table.hline(y: 1, stroke: .5pt),
      ..args,
      table.hline(),
    )
  }
)

#three-line-table[
  | *Name* | *Location* | *Height* | *Score* |
  | ------ | ---------- | -------- | ------- |
  | John   | Second St. | 180 cm   |  5      |
  | Wally  | Third Av.  | 160 cm   |  10     |
]

#three-line-table[
  | Substance             | Subcritical °C | Supercritical °C |
  | --------------------- | -------------- | ---------------- |
  | Hydrochloric Acid     | 12.0           | 92.1             |
  | Sodium Myreth Sulfate | 16.6           | 104              |
  | Potassium Hydroxide   | 24.7           | <                |
]

#tablem(ignore-second-row: false)[
  | Soldier | Hero       | <        | Soldier |
  | Guard   | Horizontal | <        | Guard   |
  | ^       | Soldier    | Soldier  | ^       |
  | Soldier | Gate       | <        | Soldier |
]