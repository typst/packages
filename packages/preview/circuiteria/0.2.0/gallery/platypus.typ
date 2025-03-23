#import "../src/lib.typ": *

#set page(width: auto, height: auto, margin: .5cm)

#let teal = rgb(37, 155, 166)
#let orange = rgb(254, 160, 93)
#let brown = rgb(97, 54, 60)

#circuit({
  element.group(id: "platypus", name: "A platypus", {
    element.block(
      x: 0, y: 0, w: 2, h: 3, id: "body",
      fill: teal,
      ports: (
        east: (
          (id: "out"),
        )
      ),
      ports-margins: (
        east: (50%, 10%)
      )
    )

    element.block(
      x: 2.5, y: 1.5, w: 1.5, h: 1, id: "beak",
      fill: orange,
      ports: (
        south: (
          (id: "in"),
        )
      )
    )

    wire.wire("w1", ("body-port-out", "beak-port-in"), style: "zigzag", zigzag-ratio: 100%)
  })

  let O = (rel: (2, 0), to: "platypus.south-east")
  
  element.group(id: "perry", name: "Perry the platypus", {
    element.block(
      x: (rel: 0, to: O), y: 0, w: 2, h: 3, id: "body",
      fill: teal,
      ports: (
        east: (
          (id: "out"),
        )
      ),
      ports-margins: (
        east: (50%, 10%)
      )
    )

    element.block(
      x: (rel: 2.5, to: O), y: 1.5, w: 1.5, h: 1, id: "beak",
      fill: orange,
      ports: (
        south: (
          (id: "in"),
        )
      )
    )

    element.block(
      x: (rel: 0.25, to: O), y: 3.2, w: 1.5, h: 0.5, id: "hat",
      fill: brown
    )

    wire.wire("w2", ("body-port-out", "beak-port-in"), style: "zigzag", zigzag-ratio: 100%)
  })

  wire.wire(
    "w3",
    ("platypus.east", (horizontal: "perry.west", vertical: ())),
    directed: true,
    bus: true
  )
})