#import "@preview/axodendron:0.1.0" as swc
#import "@preview/cetz:0.5.2"

#set page(width: auto, height: auto, margin: 3mm)

// Example: https://neuromorpho.org/api/neuron/id/85226
#let cell = swc.load(
  read("data/AA0109.CNG.swc", encoding: none),
  profile: "incf-strict",
)

#swc.render(
  cell,
  width: 120mm,
  height: 90mm,
  cetz: cetz,
  cetz-labels: (swc.cetz-label(
    node: 447,
    offset: (x: 17mm, y: -9mm),
    controls: (
      (x: 12mm, y: -10mm),
      (x: 5mm, y: -5mm),
    ),
    text(size: 8pt)[basal dendrite terminal],
  ),),
)
