#import "@preview/axodendron:0.1.1" as swc

#set page(width: auto, height: auto, margin: 3mm)

// Example: https://neuromorpho.org/api/neuron/id/85226
#let cell = swc.load(read("data/AA0109.CNG.swc", encoding: none), profile: "incf-strict")
#let local-angle = swc.measure(cell, metrics: "local-bifurcation-angle").first()
#let angle-nodes = swc.field-to-nodes(
  cell,
  field: local-angle,
  placement: "bifurcation-branch",
  reducer: "mean",
)

#swc.render(
  cell,
  color-by: angle-nodes,
  colormap: "magma",
  width: 120mm,
  height: 90mm,
  color-bar: swc.color-bar(
    min: calc.min(..angle-nodes.data.value.values),
    max: calc.max(..angle-nodes.data.value.values),
    label: [local bifurcation angle (degrees)],
    position: top + right,
  ),
)

#block(inset: (top: 2mm, bottom: 0.8mm))[
  #set text(size: 7.5pt, fill: luma(38%))
  *Data:* `AA0109.CNG.swc`; NeuroMorpho.Org record 85226; MouseLight; doi:10.1002/jnr.23978 and reconstruction deposit doi:10.25378/janelia.5526706; CC BY 4.0. Cite NeuroMorpho.Org, RRID:SCR_002145.
]
