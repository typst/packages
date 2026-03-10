#import "@preview/cetz:0.4.0": canvas, draw
#import "/src/lib.typ": smartart

#set page(width: auto, height: auto, margin: .5cm)
#set text(fill: white)
#let steps = ([A], [B], [C], [D], [E])

#let defaults() = draw.set-style(
  cycle-basic: (
    steps: (
      fill: rgb("#156082"),
      stroke: none
    ),
    arrows: (
      fill: rgb("#156082"),
      stroke: rgb("#156082")
    )
  )
)

#canvas({
  defaults()
  smartart.cycle.basic(
    steps,
    arrows: (
      thickness: none
    ),
    step-style: none
  )
})

#canvas({
  defaults()
  smartart.cycle.basic(
    steps.map(text.with(fill: black)),
    step-style: none,
    steps: (shape: none)
  )
})

#canvas({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none
    )
  )
})

#canvas({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    steps: (
      shape: "circle"
    ),
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none,
      curved: false
    )
  )
})

#canvas({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none,
      curved: false,
      double: true
    )
  )
})

#canvas({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none,
      curved: true,
      double: true
    )
  )
})
