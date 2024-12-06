//#import "@preview/finite:0.3.0": automaton, layout
#import "../src/finite.typ" as f
#import "@preview/cetz:0.3.0"

#let dot(pos) = cetz.draw.circle(pos, radius: .1, fill: red, stroke: none)


#cetz.canvas({
  import cetz.draw: *
  import f.draw: *

  set-style(
    line: (
      stroke: 2pt + red,
      mark: (symbol: "|", scale: 3),
    ),
    state: (
      radius: 1,
    ),
  )

  group(
    name: "l",
    {
      circle((0, 0), name: "c1")
      circle((4, 0), name: "c2")

      state((0, -4), "q1")
      state((4, -4), "q2")

      line("c1", "c2")
      // transition("q1", "q2")
      line("c2.south", "q2.north")
    },
  )

  line("l.c1.north", "l.c2.north")
  line("l.q1.north", "l.q2.north")
  line("l.c1.south", "l.q1.north")

  // transition("l.q2", "l.q1")
})


#set text(font: "Arial")
#cetz.canvas({
  import cetz.draw: *
  import f.draw: *

  state((0, 0), "q0", label: "S1", initial: (anchor: top + left, label: "Init"), stroke: red)
  state((4, 1), "q1", fill: red.lighten(90%), final: true, anchor: "south-west", extrude: .8, stroke: .5pt + green)

  set-style(state: (radius: .8, fill: yellow.lighten(80%)))
  state((2, -2), "q2")

  // transition("q0", "q1", inputs: "1,2")
  // transition("q1", "q2", inputs: (0, 1, 2))
})

#pagebreak()
== Layouts

#let test-aut(layouter) = {
  cetz.canvas({
    import cetz.draw: *
    import f.draw: *

    circle((0, 0))

    layouter(
      name: "l1",
      {
        set-style(
          state: (fill: green.lighten(80%)),
          transition: (curve: -1, stroke: 2pt + blue),
        )
        state((), "q0")
        state((), "q1")
        state((), "q2")

        set-style(state: (radius: .8))
        state((), "q5")

        set-style(state: (radius: .4, fill: yellow.lighten(80%)))
        state((), "q6")


        transition("q0", "q1", inputs: "1,2")
      },
    )

    transition("l1.q1", "l1.q0", inputs: "1,2", curve: -1)

    set-style(
      state: (fill: red.lighten(80%)),
      transition: (curve: 2, stroke: 2pt + blue),
    )
    state((2, -4), "q5")

    transition("l1.q1", "l1.q2", inputs: (0, 1, 2))

    line("l1.q0", "l1.q6", stroke: red, mark: (end: "|", start: "|"))
  })
}

#let layouts = (
  "Linear": f.layout.linear.with((2, -1), dir: (1, -.5)),
  "Circular": f.layout.circular.with((4, 0)),
  "Grid": f.layout.grid.with((2, -1), columns: 3),
  "Snake": f.layout.snake.with((2, -1), columns: 3),
)

#for (name, layouter) in layouts {
  heading(level: 2, name + " layout")
  test-aut(layouter)
}


#pagebreak()
== Custom layout
#cetz.canvas({
  import cetz.draw: *
  import f.draw: *

  circle((0, 0))

  layout.custom(
    name: "l1",
    (5, -1),
    positions: (
      "q0": (1, 1),
      "q6": (rel: (2, 2)),
      rest: (rel: (0, -2)),
    ),
    {
      set-style(
        state: (fill: green.lighten(80%)),
        transition: (curve: -1, stroke: 2pt + blue),
      )
      state((), "q0")
      state((), "q1")
      state((), "q2")

      set-style(state: (radius: .8))
      state((), "q5")

      set-style(state: (radius: .4, fill: yellow.lighten(80%)))
      state((), "q6")
    },
  )
  dot((5, -1))

  transition("l1.q0", "l1.q1", inputs: "1,2")

  set-style(
    state: (fill: red.lighten(80%)),
    transition: (curve: 2, stroke: 2pt + blue),
  )
  state((12, 0), "q5")

  transition("l1.q1", "l1.q2", inputs: (0, 1, 2))


  line("l1.q0", "l1.q6", stroke: red, mark: (end: "|", start: "|"))
})


#pagebreak()
= Commands
== `#automaton`
#let aut = (
  q0: (q1: "b", q3: "a", q10: "x"),
  q1: (q1: "b", q2: "a"),
  q2: (q1: "b"),
  q3: (q3: "a,b"),
  q10: (),
)

#{
  let spec = f.to-spec(aut)
  spec
}

#let style = (
  q0-q1: (curve: 0),
  q0-q10: (curve: 0),
  q0-q3: (curve: 0),
  q3-q3: (anchor: bottom),
  q0: (
    stroke: 1pt + red,
    fill: red.lighten(80%),
    initial: (
      //anchor: top + right,
      label: "XXX",
      stroke: 1pt + blue,
      scale: 1.2,
    ),
  ),
  q10: (
    fill: green,
    stroke: green.darken(30%),
    label: (
      fill: white,
    ),
  ),
)

#f.automaton(
  aut,
  // layout: layout.grid.with(columns: 3, spacing: (2, -4)),
  layout: f.layout.circular.with(spacing:2, offset:30deg),
  style: style,
)



// #automaton(
//   (
//     "Active": ("Done": "Cancel", "Active": ""),
//     "Done": (),
//   ),
//   layout: layout.linear.with(spacing: 3),
//   style: (
//     "transition": (curve: .5),
//     "Active-Active": (curve: 1),
//     "Active": (
//       stroke: green,
//       initial: (
//         stroke: black,
//       ),
//     ),
//   ),
// )

// #automaton(
//   (
//     "Locked": ("Unlockable": "StartTimer"),
//     "Unlockable": ("Unlocked": "CancelTimer"),
//     "Unlocked": (),
//   ),
//   layout: layout.linear.with(spacing: 3),
//   style: (
//     "transition": (curve: .5),
//     "Locked": (
//       initial: (
//         stroke: green,
//       ),
//     ),
//   ),
// )
