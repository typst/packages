#import "../../src/finite.typ"

#set page(width: auto, height: auto, margin: 1cm)

#finite.cetz.canvas({
  import finite.draw: state

  state((0, 0), "q0")
  state((2, 2), "q1", stroke: red)
  state((4, 0), "q2", stroke: red, fill: red.lighten(80%))
  state((2, -2), "q3", stroke: red, fill: red.lighten(80%), label: "T")
})

#pagebreak()

