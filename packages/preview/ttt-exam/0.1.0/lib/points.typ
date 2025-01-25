#import "@preview/ttt-utils:0.1.0": grading
#import "i18n.typ": *

#let total_points = context grading.get_points().sum()

// Show a box with the total_points
#let point-sum-box = {
  box(stroke: 1pt, inset: 0.8em, radius: 3pt)[
    #set align(bottom)
    #stack(
      dir:ltr,
      spacing: 0.5em,
      box[#text(1.4em, sym.sum) :],
      line(stroke: 0.5pt), "/",
      [#total_points #smallcaps[PTs]]
    )
  ]
}

// Show a table with point distribution
#let point-table = {
  context {
    let points = grading.get_points()
    box(radius: 5pt, clip: true, stroke: 1pt,
      table(
        align: (col, _) => if (col == 0) { end } else { center },
        inset: (x: 1em, y:0.6em),
        fill: (x,y) =>  if (x == 0 or y == 0) { luma(230) },
        rows: (auto, auto, 1cm),
        columns: (auto, ..((1cm,) * points.len()), auto),
        linguify("assignment", from: ling_db), ..points.enumerate().map(((i,_)) => [#{i+1}]), linguify("total", from: ling_db),
        linguify("points", from: ling_db), ..points.map(str), total_points,
        linguify("awarded", from: ling_db),
      )
    )
  }
}
