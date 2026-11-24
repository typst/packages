#import "@preview/axodendron:0.1.0" as swc

#set page(margin: 16mm)
#set text(font: "New Computer Modern", size: 9pt)

// Example: https://neuromorpho.org/api/neuron/id/85226
#let cell = swc.load(read("data/AA0109.CNG.swc", encoding: none), profile: "incf-strict")
#let metrics = swc.analyze(cell)
#let sholl = swc.sholl(cell, radii: range(50, 651, step: 50))

= Axodendron

#grid(
  columns: (1fr, 1fr),
  gutter: 8mm,
  swc.render(
    cell,
    width: 82mm,
    height: 68mm,
    canvas-width: 820,
    canvas-height: 680,
    labels: (
      swc.label(node: 116, [distal dendrite]),
      swc.label(node: 551, offset: (x: 4pt, y: 4pt), [distal axon]),
    ),
    scale-bar: swc.scale-bar(value: 100),
  ),
  swc.render(
    cell,
    projection: "xz",
    color-by: metrics.strahler_order,
    width: 82mm,
    height: 68mm,
    canvas-width: 820,
    canvas-height: 680,
    scale-bar: swc.scale-bar(value: 100),
  ),
)

#block(inset: (top: 3mm))[
  #set text(size: 7.5pt, fill: luma(38%))
  *Data:* `AA0109.CNG.swc`; NeuroMorpho.Org record 85226; MouseLight; doi:10.1002/jnr.23978 and reconstruction deposit doi:10.25378/janelia.5526706; CC BY 4.0. Cite NeuroMorpho.Org, RRID:SCR_002145.
]

#table(
  columns: 2,
  [Nodes], [#metrics.summary.node_count],
  [Cable length], [#calc.round(metrics.summary.total_cable_length, digits: 2) µm],
  [Branch points], [#metrics.summary.branch_point_count],
  [Terminals], [#metrics.summary.terminal_count],
  [Sholl bins], [#sholl.bins.len()],
)
