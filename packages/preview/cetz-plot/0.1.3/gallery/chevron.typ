#import "@preview/cetz:0.4.2" as cetz: draw
#import "/src/lib.typ": smartart

#set page(width: auto, height: auto, margin: .5cm)

#let steps = (
  [Improvise],
  [Adapt],
  [Overcome]
)

#let steps2 = (
  text(fill: white)[Text here],
  [Text here],
  [Text here],
  [Text here]
).enumerate().map(((i, step)) => {
  grid(
    columns: 2,
    column-gutter: 0.4em,
    align: center + horizon,
    box(
      width: 2em,
      height: 2em,
      radius: 1em,
      fill: white,
      stroke: gray,
      align(center + horizon)[*0#{i + 1}*]
    ),
    step
  )
})

#cetz.canvas({
  smartart.process.chevron(
    steps2,
    step-style: (
      rgb("#352C6D"),
      rgb("#FE7275"),
      rgb("#8285E6"),
      rgb("#8CDFFD")
    ),
    //equal-length: true,
    dir: ltr,
    start-cap: "(",
    name: "chart",
    steps: (max-width: 8em),
    start-in-cap: true,
  )
})

#align(
  center + horizon,
  stack(
    dir: ltr,
    spacing: 1em,
    cetz.canvas({
      smartart.process.chevron(
        steps,
        step-style: cetz.palette.light-green,
        dir: rtl,
        start-cap: "(",
        end-cap: ")",
        spacing: 4pt
      )
    }),
    cetz.canvas({
      smartart.process.chevron(
        steps,
        step-style: cetz.palette.orange,
        dir: btt,
        start-cap: "|",
        end-cap: ")",
        spacing: 0,
      )
    }),
    cetz.canvas({
      smartart.process.chevron(
        steps,
        step-style: cetz.palette.red,
        dir: ttb,
        start-cap: "<",
        middle-cap: "|",
        end-cap: ">",
        spacing: 1em,
      )
    })
  )
)
