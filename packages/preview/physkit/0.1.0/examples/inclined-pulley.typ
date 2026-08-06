#import "@preview/physkit:0.1.0": mechanics

#let ramp = mechanics.inclined-plane(
  "ramp",
  origin: (0, 0),
  length: 5,
  angle: 30deg,
)

#let ceiling = mechanics.ceiling(
  "ceiling",
  y: 5,
  from: 3.5,
  to: 7,
)

#let block = mechanics.box(
  "block",
  width: 1.2,
  height: 0.8,
  label: [$m_1$],
  label-offset: (0, 0.08),
)

#let pulley = mechanics.pulley("pulley", radius: 0.55)
#let mass = mechanics.box(
  "mass",
  width: 0.85,
  height: 0.85,
  label: [$m_2$],
  label-offset: (0, 0.08),
)

#let block-support = mechanics.on-surface(block, ramp, distance: 2.8)
#let pulley-alignment = mechanics.align-rope-parallel(
  from: mechanics.connect(block, "right"),
  pulley: pulley,
  parallel-to: ramp,
  support: ceiling,
  support-position: 72%,
  support-distance: 0.8,
  wrap-side: "upper",
)
#let mass-suspension = mechanics.suspended-from(
  mass,
  pulley,
  side: "right",
  length: 1.6,
)

#let rope = mechanics.rope(
  "rope",
  (
    mechanics.connect(block, "right"),
    mechanics.wrap(pulley, side: "upper"),
    mechanics.connect(mass, "top"),
  ),
  label: [$T$],
  label-position: 48%,
  label-offset: (0.28, 0),
)

#mechanics.diagram(
  objects: (ramp, ceiling, block, pulley, mass),
  constraints: (block-support, pulley-alignment, mass-suspension),
  connections: (rope,),
  forces: (
    mechanics.weight("weight-1", block,
      label: [$P_1$], label-offset: (0.28, 0)),
    mechanics.weight("weight-2", mass,
      label: [$P_2$], label-offset: (0.28, 0)),
  ),
)
