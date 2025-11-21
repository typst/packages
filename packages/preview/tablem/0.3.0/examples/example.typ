#import "@preview/tablem:0.3.0": tablem, three-line-table

#set page(width: 35em, height: auto)
#set table(align: center + horizon)

// 1. simple usage

#tablem[
  | *Name* | *Location* | *Height* | *Score* |
  | ------ | ---------- | -------- | ------- |
  | John   | Second St. | 180 cm   |  5      |
  | Wally  | Third Av.  | 160 cm   |  10     |
]

// 2. three-line table with left/center/right alignments

#three-line-table[
  | *Name* | *Location* | *Height* | *Score* |
  | :----: | :--------: | :------: | :-----: |
  | John   | Second St. | 180 cm   |  5      |
  | Wally  | Third Av.  | 160 cm   |  10     |
]

// 3. custom render function

#let three-line-table = tablem.with(render: (columns: auto, align: auto, ..args) => {
  table(
    columns: columns,
    stroke: none,
    align: center + horizon,
    table.hline(y: 0),
    table.hline(y: 1, stroke: .5pt),
    ..args,
    table.hline(),
  )
})

// 4. table with merged cells

#three-line-table[
  | Substance             | Subcritical °C | Supercritical °C |
  | --------------------- | -------------- | ---------------- |
  | Hydrochloric Acid     | 12.0           | 92.1             |
  | Sodium Myreth Sulfate | 16.6           | 104              |
  | Potassium Hydroxide   | 24.7           | <                |
]

// 5. a table without table header

#tablem[
  | Guard   | Hero       | <        | Soldier |
  | ^       | Horizontal | <        | Guard   |
  | Soldier | Soldier    | Soldier  | ^       |
  | Soldier | Gate       | <        | Soldier |
]

// 6. a table with complex arguments

#let frame(stroke) = (x, y) => (
  left: if x > 0 { 0pt } else { stroke },
  right: stroke,
  top: if y < 2 { stroke } else { 0pt },
  bottom: stroke,
)

#figure(
  tablem(
    columns: (0.4fr, 1fr, 1fr),
    align: left,
    fill: (_, y) => if calc.odd(y) { rgb("EAF2F5") },
    stroke: frame(rgb("21222C")),
  )[
    | *Month*   | *Title*                  | *Author*             |
    | --------- | ------------------------ | -------------------- |
    | January   | The Great Gatsby         | F. Scott Fitzgerald  |
    | February  | To Kill a Mockingbird    | Harper Lee           |
    | March     | 1984                     | George Orwell        |
    | April     | The Catcher in the Rye   | J.D. Salinger        |
  ],
  caption: "A table with complex arguments",
)
