
#import "@local/mantys:0.0.3": *

#import "@preview/cetz:0.1.0"
#import "finite.typ"

#let module-scope = (
  cetz: cetz,
  finite: finite
)


#show: mantys.with(
  ..toml("typst.toml"),
  title: align(center, finite.automaton((
      q0: (q1:none),
      q1: (q2:none),
      q2: (q3:none),
      q3: (q4:none),
      q4: (q5:none),
      q5: none,
    ), style: (
      q0: (label: "F"),
      q1: (label: "I"),
      q2: (label: "N"),
      q3: (label: "I"),
      q4: (label: "T"),
      q5: (label: "E")
  ))),

  date: datetime.today(),
  abstract: [
    FINITE is a Typst package to draw transition diagrams for finite automata (state machines) with the power of CetZ.

    The package provides new elements for manually drawing states and transitions on any CetZ canvas, but also comes with commands to quickly create automata from a transition table.
  ],

  usage: (
    namespace: "preview",
    imports: "automaton"
  ),
  examples-scope: (
    cetz: cetz,
    finite:finite,
    automaton: finite.automaton
  )
)

#show "CETZ": a => package[CetZ]

== Dependencies

FINITE loads #link("https://github.com/johannes-wolf/typst-canvas")[CETZ] and the utility package #link("https://github.com/jneug/typst-tools4typst")[#package[t4t]] from the `preview` package repository. The dependencies will be downloaded by Typst automatically on first compilation.

== Quick start

FINITE helps you draw transition diagrams for finite automata in your Typst douments, using the power of CETZ.

To draw an automaton, import #cmd[automaton] from FINITE and use it like this:
#codesnippet[```typ
#automaton((
  q0: (q1:0, q0:"0,1"),
  q1: (q0:(0,1), q2:"0"),
  q2: (),
))
```]

The output looks like this:
#finite.automaton((
  q0: (q1:0, q0:"0,1"),
  q1: (q0:(0,1), q2:"0"),
  q2: (),
))

As you can see, an automaton ist defined by a dictionary of dictionaries. The keys of the top-level dictionary are the names of the states to draw. The second-level dictionaries have the names of connected states as keys and transition labels as values.

In the example above, the states `q0`, `q1` and `q2` are defined. `q0` is connected to `q1` nad has a loop to itself. `q1` transitions to `q2` and back to `q0`. #cmd-[automaton] selected the first state in the dictionary (in this case `q0`) to be the initiat state and the last (`q2`) to be a final state.

To modify the defaults, #cmd-[automaton] accepts a set of options:
#example[```typ
#automaton(
  (
    q0: (q1:0, q0:"0,1"),
    q1: (q0:(0,1), q2:"0"),
    q2: (),
  ),
  start: "q1",
  stop: ("q0", "q2"),
  style:(
    state: (fill: luma(248), stroke:luma(120)),
    transition: (stroke: (dash:"dashed")),
    q1: (start:top),
    q1-q2: (stroke: 2pt + red)
  )
)
```]

For larger automatons, the states can be arranged in different ways:
#example[```typ
#let aut = (:)
#for i in range(10) {
  let name = "q"+str(i)
  aut.insert(name, (:))
  if i < 9 {
    aut.at(name).insert("q" + str(i + 1), none)
  }
}
#automaton(
  aut,
  layout: finite.layout.circular.with(offset: 2),
  style: (
    transition: (curve: 0),
    q0: (start: top+left)
  )
)
```]

See @using-layout for more details about layouts.

== Command reference
#tidy-module(
  read("cmd.typ"),
  name: "cmd",
  show-outline: false,
  scope: module-scope
)

== Drawing automata

The above commands use custom #package[CetZ] elements, to draw states and transitions. For complex automata, the functions in the #module[draw] module can be used directly.
#example[```
#cetz.canvas({
  import cetz.draw: set-style
  import finite.draw: state, transition

  state((0,0), "q0", start:true)
  state((2,1), "q1")
  state((4,-1), "q2", stop:true)
  state((3,-3), "trap", label:"TRAP")

  transition("q0", "q1", label:(0,1))
  transition("q1", "q2", label:(0))
  transition("q1", "trap", label:(1), curve:-1)
  transition("q2", "trap", label:(0,1))
  transition("trap", "trap", label:(0,1))
})
```]

#tidy-module(
  read("draw.typ"),
  name: "draw",
  show-outline: false,
  scope: module-scope
)

States have the common anchors (like `top`, `top-left` ...), transitions have a `start`, `end`, `center` and `label` anchors. These can be used to draw additional elements:
#example[```
#cetz.canvas({
  import cetz.draw: circle, line, place-marks, content
  import finite.draw: state, transition

  state((0,0), "q0")
  state((4,0), "q1", stop:true)
  transition("q0", "q1", label:$epsilon$)

  circle("q0.top-right", radius:.4em, stroke:none, fill:black)

  let magenta-stroke = 2pt+rgb("#dc41f1")
  circle("q0-q1.label", radius:.5em, stroke:magenta-stroke)
  place-marks(
    line(
      name: "q0-arrow",
      (rel:(.6,.6), to:"q1.top-right"),
      (rel:(.15,.15), to:"q1.top-right"),
      stroke:magenta-stroke
    ),
    (mark:">", pos:1, stroke:magenta-stroke)
  )
  content(
    (rel:(0,.25), to:"q0-arrow.start"),
    text(fill:rgb("#dc41f1"), [*very important state*])
  )
})
```]

== Using layouts <using-layout>

Layouts calculate coordinates for every state in a transition table and return a dictionary with all computed locations.

FINITE ships with a bunch of layouts, to accomodate different scenarios.

#wbox[Layouts currently are very simple. They will most likely see improvements in the future. At the moment, layouts don't know about the context and can't resolve coordinates other than absolute coordinate pairs.]

=== Available layouts
#tidy-module(
  read("layout.typ"),
  name: "layout",
  scope: module-scope
)


=== Creating custom layouts

A layout is a function, that, provided with information about the automaton, returns a dictionary with the state names as keys and valid coordinates as values.

#cmd[linear-layout] is a simple example:
#sourcecode[```typc
let linear-layout(states, start, stop, x:2.2, y:0) = {
  let positions = (:)
  for (i, name) in states.keys().enumerate() {
    positions.insert(name, (i * x, i * y))
  }
  return positions
}
```]

A layout function always gets passed the #arg[states] dictionary (the same dictionary that is passed to #cmd[automaton]), the #arg[start] state and the list of end states #arg[stop].

Additional named arguments may be used to configure the layout via #symbol[with]:
#codesnippet[```typc
linear-layout.with(x:-1, y:2.2)
```]

This example arranges the states in a wave:
#example[```
#let wave-layout(
  states, start, stop,
  x: 1.6, amp: 1,
  generator: calc.sin
) = {
  let positions = (:)

  for (i, state) in states.keys().enumerate() {
    positions.insert(state, (
      i * x, generator(i * amp)
    ))
  }

  return positions
}

#let aut = (:)
#for i in range(8) {
  aut.insert("q"+str(i), none)
}

#grid(
  columns:(1fr,1fr),
  automaton(
    aut,
    layout: wave-layout.with(generator: calc.sin, x:.8),
    style: (state: (radius: .4))
  ),
  automaton(
    aut,
    layout: wave-layout.with(generator: calc.cos, x:.8, amp:1.4),
    style: (state: (radius: .4))
  )
)
```]

/*
#let aut = (:)
#for i in range(15) {
  let name = "q"+str(i)
  aut.insert(name, (:))
  if i < 14 {
    aut.at(name).insert("q" + str(i + 1), none)
  }
}
#finite.automaton(
  aut,
  layout: finite.layout.group.with(
    x: 1.6, y: -.4,
    grouping: (
      ("q0", "q2", "q4", "q6"),
      ("q1", "q3", "q5", "q7"),
      ("q8", "q10", "q12", "q14"),
      ("q9", "q11", "q13", "q15")
    ),
    layout: (
      finite.layout.linear.with(x:0, y:-1.4),
      finite.layout.fixed.with(pos: (
        q1: (-2.8, 0),
        q3: (-2.8, -1.4),
        q5: (-2.8, -2.8),
        q7: (0, -2),
      )),
      finite.layout.linear.with(x:.1, y:-1.6),
    )
  ),
  style: (
    state:(radius: .5),
    transition:(curve:0),
    q0:(start:top+left)
  )
)

#finite.automaton(
  aut,
  layout: finite.layout.start-stop,
  style: (
    state:(radius: .5),
    transition:(curve:0),
    q0:(start:top+left)
  )
)
*/

== Utility functions
#tidy-module(
  read("util.typ"),
  name: "util",
  scope: module-scope
)

== Doing other stuff with FINITE

Since transition diagrams are effectvely graphs, FINITE could also be used to draw graph structures:
#example[```
#cetz.canvas({
  import cetz.draw: set-style
  import finite.draw: state, transitions

  state((0,0), "A")
  state((3,1), "B")
  state((4,-2), "C")
  state((1,-3), "D")
  state((6,1), "E")

  transitions((
      A: (B: 1.2),
      B: (C: .5, E: 2.3),
      C: (B: .8, D: 1.4, E: 4.5),
      D: (A: 1.8),
      E: (:)
    ),
    C-E: (curve: -1.2))
})
```]
