#import "../../src/finite.typ"

#set page(width: auto, height: auto, margin: 1cm)

#finite.cetz.canvas({
  import finite.draw: state

  state((0, 0), "q0", initial: true)
  state((2, 2), "q1", initial: "Initial")
  state((4, 0), "q2", initial: bottom + right)
  state((2, -2), "q2", initial: (label: "Foo", anchor: bottom + left))
})

#pagebreak()


#finite.cetz.canvas({
  import finite.draw: state

  state(
    (0, 0),
    "A",
    initial: (
      label: (
        text: "Init",
        size: 16pt,
      ),
      anchor: bottom,
    ),
    stroke: red,
  )
})
