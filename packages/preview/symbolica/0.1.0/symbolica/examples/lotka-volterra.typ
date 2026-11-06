// Inspired by TimeTravelPenguin/symbolic-eval:
// https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/examples/solve_ode_system.typ
// Parameters: https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/rust/examples/ode.rs
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#import "@preview/symbolica:0.1.0": init

#set document(title: "A Lotka–Volterra trajectory")
#set page(paper: "a4", margin: 18mm)
#set text(size: 10pt)
#set par(justify: true)

= Predator and prey

Consider the dimensionless Lotka–Volterra system

$
  (dif x)/(dif t) &= 2/3 x - 4/3 x y, \
  (dif y)/(dif t) &= x y - y,
$

with $x(0)=y(0)=1$. Symbolica evaluates the two right-hand sides together at
each stage. A short fourth-order Runge–Kutta loop local to this example then
advances both populations; it is ordinary Typst code rather than a new ODE API.

#let sym = init(namespace: "symbolica")
#let parse = sym.math
#let symbol = sym.symbol
#let evaluate-many = sym.evaluate-many

#let t = symbol("t")
#let x = symbol("x")
#let y = symbol("y")
#let right-hand-sides = (
  parse($(2 x) / 3 - (4 x y) / 3$),
  parse($x y - y$),
)

#let rhs(time, state) = {
  evaluate-many(
    right-hand-sides,
    (t, x, y),
    ((time, state.at(0), state.at(1)),),
  ).first().map(value => value.re)
}

#let shifted(state, slope, scale) = range(state.len()).map(index => (
  state.at(index) + scale * slope.at(index)
))

#let rk4-step(time, state, step) = {
  let k1 = rhs(time, state)
  let k2 = rhs(time + step / 2, shifted(state, k1, step / 2))
  let k3 = rhs(time + step / 2, shifted(state, k2, step / 2))
  let k4 = rhs(time + step, shifted(state, k3, step))
  range(state.len()).map(index => state.at(index) + step / 6 * (
    k1.at(index) + 2 * k2.at(index) + 2 * k3.at(index) + k4.at(index)
  ))
}

#let step = 0.1
#let steps = 100
#let trajectory = {
  let time = 0.0
  let state = (1.0, 1.0)
  let rows = ((time, state.at(0), state.at(1)),)
  for _ in range(steps) {
    state = rk4-step(time, state, step)
    time += step
    rows.push((time, state.at(0), state.at(1)))
  }
  rows
}

#let prey = trajectory.map(row => (row.at(0), row.at(1)))
#let predators = trajectory.map(row => (row.at(0), row.at(2)))
#let phase = trajectory.map(row => (row.at(1), row.at(2)))

#figure(
  canvas({
    import draw: *
    set-style(
      axes: (stroke: 0.5pt, tick: (stroke: 0.5pt)),
      legend: (stroke: none, orientation: ttb, item: (spacing: 0.3), scale: 80%),
    )
    plot.plot(
      size: (12, 7),
      x-min: 0,
      x-max: 10,
      y-min: 0,
      x-label: [time $t$],
      y-label: [population],
      legend: "east",
      {
        plot.add(prey, label: $x(t)$, style: (stroke: blue))
        plot.add(predators, label: $y(t)$, style: (stroke: red))
      },
    )
  }),
  caption: [The two populations oscillate as they feed back on one another.],
)

#figure(
  canvas({
    import draw: *
    set-style(
      axes: (stroke: 0.5pt, tick: (stroke: 0.5pt)),
      legend: (stroke: none, orientation: ttb, item: (spacing: 0.3), scale: 80%),
    )
    plot.plot(
      size: (12, 7),
      x-min: 0,
      y-min: 0,
      y-max: 1.05,
      x-label: [prey $x$],
      y-label: [predators $y$],
      legend: "east",
      {
        plot.add(phase, label: $(x(t), y(t))$, style: (stroke: purple))
      },
    )
  }),
  caption: [The same solution in the population phase plane.],
)

#text(size: 8pt, fill: luma(40%))[
  Independently adapted for Symbolica from the predator–prey example in
  #link("https://github.com/TimeTravelPenguin/symbolic-eval")[`symbolic-eval`].
]
