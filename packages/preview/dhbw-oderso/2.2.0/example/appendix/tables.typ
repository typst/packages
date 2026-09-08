#import "@preview/dhbw-oderso:2.2.0": (
  styled-table, table-hline-spaced, tablefigure, tablefigure-raw,
)

This appendix shows example tables. Sourced from #link("https://ieeexplore.ieee.org/document/7165621").

#tablefigure(
  caption: [Research Question],
  columns: 3,
  table-content: (
    table.header([RQ], [Research Question], [Motivation]),
    [1],
    [Are there FPA problems being reported in terms of accuracy?],
    [Identify and summarize potential FPA problems, pointed out by researchers.],
    [2],
    [Are there proposals to improve the FPA’s accuracy? Which improvements are being proposed?],
    [Identify and summarize the approaches proposed to improve the FPA accuracy.],
    [3],
    [Are the proposed improvements effective?],
    [Verify if the proposed improvements are more effective when compared to the standard FPA.],
    [4],
    [What are the limitations for the proposed improvements?],
    [Identify potential problems or weaknesses for the proposed improvements.],
  ),
)

#{
  // Put inside brackets to restrict show rules to this specific context
  tablefigure(
    caption: [Data Function Complexity],
    columns: 5,
    align: (x, y) => {
      if x == 0 {
        return left
      } else {
        return center
      }
    },
    table-content: (
      table.header(table.cell(colspan: 2, {}), table.cell(
        align: center,
        colspan: 3,
        "DET",
      )),
      ..table-hline-spaced(.2em, 5, start: 2),
      table.header(table.cell(colspan: 2, {}), [1-19], [20-50], [>50]),
      table.cell(align: left)[Record],
      [1],
      [Low],
      [Low],
      [Average],
      [Element],
      [2-5],
      [Low],
      [Average],
      [High],
      [Types (RET)],
      [>5],
      [Average],
      [High],
      [High],
    ),
  )
}

#tablefigure-raw(caption: "Custom Table", table(
  columns: 2,
  [A], [custom],
  [table], [style],
))

#styled-table(
  columns: 2,
  table-content: (
    table.header([A], [fixed]),
    [styled],
    [table],
    [without],
    [figure-wrapper],
  ),
)
