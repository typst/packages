#import "../main.typ": vectorfield, graph, coulomb
#import "@preview/cetz:0.5.2"
#let uniform = vectorfield.new((x, y) => (1, 0))
#assert(vectorfield.sample(uniform, 0, 0) == (1, 0))
#let stream = vectorfield.streamline(uniform, 0, 0, step: 0.1, max-steps: 10)
#assert(stream.points.len() == 11 and stream.reason == "max-steps")
#let flight = vectorfield.trajectory(uniform, 0, 0, step: 0.1, max-steps: 10)
#assert(calc.abs(flight.points.last().at(0) - 0.5) < 1e-6)
#let flight-hit = vectorfield.trajectory(uniform, 0, 0, vx: 1, step: 1, terminate: vectorfield.circle-terminator((0.5, 0), 0.1, name: "collision"))
#assert(flight-hit.reason == "terminated" and flight-hit.hit == "collision")
#let hit = vectorfield.circle-terminator((0.5, 0), 0.1, name: "target")
#let stopped = vectorfield.streamline(uniform, 0, 0, step: 0.6, terminate: hit)
#assert(stopped.reason == "terminated" and stopped.hit == "target")
#assert(calc.abs(stopped.points.last().at(0) - 0.4) < 1e-6)
#let nearer = vectorfield.combine-terminators(vectorfield.circle-terminator((0.8, 0), 0.1, name: "far"), hit)
#let combined = vectorfield.streamline(uniform, 0, 0, step: 1, terminate: nearer)
#assert(combined.hit == "target")
#let edge-first = vectorfield.streamline(uniform, 0, 0, step: 1, domain: ((-1, -1), (0.2, 1)), terminate: hit)
#assert(edge-first.reason == "boundary" and edge-first.hit == none and calc.abs(edge-first.points.last().at(0) - 0.2) < 1e-6)
#let target-first = vectorfield.streamline(uniform, 0, 0, step: 1, domain: ((-1, -1), (0.8, 1)), terminate: hit)
#assert(target-first.reason == "terminated" and target-first.hit == "target")
#let e = coulomb.electric-field((2, 0), ((position: (0, 0), charge: 1),))
#assert(calc.abs(e.at(0) - 0.25) < 1e-8)
#graph.field-graph(uniform, vectors: (grid: ((position: (0, 0), name: "arrow"),)), lines: (origins: ((position: (-1, 0), name: "line"),)), trajectories: (origins: ((position: (0, -1), name: "flight"),)))
#coulomb.charge-diagram(((position: (-1, 0), charge: 1, name: "plus"), (position: (1, 0), charge: -1, name: "minus")), lines-per-charge: 4, vectors: (samples: (4, 4)), anchors: ((particle: "plus", field-line: 0deg, name: "selected"),))
#coulomb.charge-diagram(((position: "seed.center", charge: 1, lines: 2),), setup: {
  import cetz.draw: *
  circle((0, 0), name: "seed")
}, domain: ((-2, -2), (2, 2)))
#cetz.canvas({
  import cetz.draw: *
  circle((0, 0), name: "source")
  graph.draw-field-graph(uniform, domain: ((-2, -2), (2, 2)),
    vectors: (grid: graph.vector-grid(((-2, -2), (2, 2)), samples: (3, 3), exclude: ((position: "source.center", radius: 0.3),))),
    lines: (origins: ((position: "source.center", name: "named-line", terminate: graph.cetz-combine-terminators(graph.cetz-circle-terminator((1, 0), 0.1, name: "stop"))),)),
  )
  content("named-line.mid", [path anchor])
})
