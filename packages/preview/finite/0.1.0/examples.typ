#import "@preview/cetz:0.0.2"
#import cetz: vector

#import "finite.typ"
#import "finite.typ": automaton, circular-layout, snake-layout
#import "util.typ"

#lorem(50)

#cetz.canvas(length:1cm, {
  import cetz.draw: *
  import finite.draw: state, transition, transitions

  set-style(
    state: (
      radius:.5,
      fill:luma(242),
      stroke:2pt + luma(120),
    ),
    transition: (
      label: (text:$F$, size:1em)
    )
  )

  state((0,0), "q0", label:[q#sub("0")], start:true)
  for i in range(4) {
    //state((i*4,0), "q" + str(i), label:[q#sub(str(i))], start:i==0, stop:i==3)
    state((rel:(4,0), to:"q" + str(i)), "q" + str(i+1), label:[q#sub(str(i+1))], start:i==0, stop:i==3)
  }

  state((0,2), "qx", label:[{$q_a$,$q_b$}], start:true)

  state((0, -2), "q10", label:(text: [q#sub("10")], size: 16pt))
  state((2, -5), "q11", label:[q#sub("11")])
  state((7, 4), "q12", label:(text:[q#sub("12")], size:10pt), stop:true)

  transition("q0", "q1")
  transition("q1", "q2", curve:1, label:(
    size: 10pt,
    text: $x$
  ))
  transition("q1", "q11", curve:2, label:"a,b")
  transition("q11", "q4", curve:-2, label:(text:"x"))
  transition("q10", "q4", curve:-2.4)
  transition("q10", "q2", curve:-1, label:(pos:.8, dist:1))
  transition("q2", "q3", stroke:(thickness:4pt, paint:blue, dash:"dashed"), label:(dist:.5))
  transition("q2", "q12", label:(pos: .2, dist: .5))
  transition("q12", "q12", curve:-1)
  transition("q3", "q3", label:"")

  transition("q0", "q12", label:(text:$gamma$, angle:0deg), stroke:2pt + red)
  transition("q12", "q0")

  // circle("q11-q4.ctrl", fill:red, radius:.1, stroke:none)
  // circle("q11-q4.label", fill:red, radius:.1, stroke:none)

  transitions("qx", "q12", "q3", ("q4", "xx"))
})


#lorem(50)

#cetz.canvas({
  import cetz.draw: *
  import finite.draw: state, transition

  state((0,0), "q0", start:true)
  state((6,2), "q1")
  state((9,-1), "q2", stop:true)

  transition("q0", "q1", label:"0")
  transition("q0", "q0", label:"0,1")
  transition("q1", "q0", label:(text:"0,1"))
  transition("q1", "q2", label:(text:"0"))

  for-each-anchor("q0", (a) => {
    circle((), fill:red, stroke:none, radius:.1)
  })
  for-each-anchor("q0-q1", (a) => {
    circle((), fill:red, stroke:none, radius:.1)
  })

  bezier-through("q0.top-right", "q1-q0.label", "q2.bottom-left")
})

#automaton((
  q0: ((q1:0), (q0:"0,1")),
  q1: (("q0", "0,1"), ("q2", "0")),
  q2: (),
))

#let n = 12
#let aut = (:)
#for i in range(n) {
  let t = ()
  if i < n - 1 {
    t.push("q" + str(i + 1))
  }
  aut.insert("q" + str(i), t)
}
#automaton(
  aut,
  layout:circular-layout.with(offset:4, dir:left),
  style: (
    transition: (curve: 0),
    q0: (start:top+left)
  )
)

#let path = ("q0", "q1", "q2", "q3", "q4")
#let last-state = ()
#for current-state in path {
  let style = (
    transition: (curve: 0)
  )
  style.insert(current-state, (
    stroke: red + 2pt,
    fill: red.lighten(90%)
  ))
  if last-state != () {
    for ls in last-state {
      style.insert(ls, (
        stroke: green + 2pt,
        fill: green.lighten(90%)
      ))
    }
    style.insert(
      last-state.last() + "-" + current-state,
      (
        stroke: red + 2pt,
        curve:1
      )
    )
  }

  automaton(
    aut,
    layout:snake-layout,
    style: style
  )

  last-state.push(current-state)
}
