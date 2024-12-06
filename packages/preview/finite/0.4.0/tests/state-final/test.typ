#import "../../src/finite.typ"

#set page(width: auto, height: auto, margin: 1cm)

#finite.cetz.canvas({
  import finite.draw: state

  state((0, 0), "q0", final: true)
  state((2, 2), "q1", final: true, stroke: red)
})
