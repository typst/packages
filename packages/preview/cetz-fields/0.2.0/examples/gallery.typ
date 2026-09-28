#import "../main.typ": vectorfield, graph, coulomb

= Electric charge diagrams

== Dipole streamlines
#coulomb.charge-diagram(
  ((position: (-1.2, 0), charge: 1), (position: (1.2, 0), charge: -1)),
  domain: ((-4, -3), (4, 3)),
)

== Unequal charges
#coulomb.charge-diagram(
  ((position: (-1.1, 0), charge: 2, content: [+2]), (position: (1.1, 0), charge: -0.7, content: [−0.7])),
  domain: ((-4, -3), (4, 3)),
)

== Vectors and streamlines together
#coulomb.charge-diagram(
  ((position: (-1, 0), charge: 1), (position: (1, 0), charge: -1)),
  domain: ((-3, -2), (3, 2)),
  vectors: (
    samples: (13, 9),
    gradient: gradient.linear(rgb("440154"), rgb("21918c"), rgb("fde725")),
    color-min: 0.05,
    color-max: 2.5,
  ),
)

== Generic flow and trajectory
#let flow = vectorfield.new((x, y) => (0, -0.5))
#graph.field-graph(flow, domain: ((-2, -2), (2, 2)),
  trajectories: (origins: ((position: (-1, 1), vx: 1.5, name: "flight"),)),
  vectors: (grid: ((position: (0, 0), name: "sample"),)),
)
