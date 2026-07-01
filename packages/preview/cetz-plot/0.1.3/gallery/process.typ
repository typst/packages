#import "@preview/cetz:0.4.2" as cetz: draw
#import "/src/lib.typ": smartart

#set page(width: auto, height: auto, margin: .5cm)

#let steps = (
  [Improvise],
  [Adapt],
  [Overcome]
)

#let colors = (
  red, orange, green
).map(c => c.lighten(40%))

#cetz.canvas({
  smartart.process.basic(
    steps,
    step-style: colors,
    equal-width: true,
    dir: ltr,
    name: "chart",
  )
})

#cetz.canvas({
  smartart.process.chevron(
    steps,
    step-style: colors,
    equal-length: true,
    dir: ltr,
    name: "chart",
  )
})
