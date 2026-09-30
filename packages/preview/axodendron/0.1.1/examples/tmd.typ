#import "@preview/axodendron:0.1.1" as swc

#set page(width: auto, height: auto, margin: 3mm)

// Example: https://neuromorpho.org/api/neuron/id/62495
#let cell = swc.load(
  read("data/Sst-IRES-Cre_Ai14-188740-03-02-01_491119369_m.kp12.swc", encoding: none),
  profile: "incf-strict",
)
#let descriptor = swc.tmd(cell, filtration: "root-path-length")
#let scale = swc.persistence-scale(descriptor)

#grid(
  columns: (auto, auto),
  gutter: 5mm,
  swc.persistence-barcode(descriptor, width: 90mm, height: 70mm, scale: scale),
  swc.persistence-diagram(descriptor, size: 70mm, scale: scale),
)

#block(width: 165mm, inset: (top: 2mm))[#align(center, swc.persistence-legend())]

#block(inset: (top: 2mm, bottom: 0.8mm))[
  #set text(size: 7.5pt, fill: luma(38%))
  *Data:* `Sst-IRES-Cre_Ai14-188740-03-02-01_491119369_m.kp12.swc`; NeuroMorpho.Org record 62495; Allen Cell Types; doi:10.1016/j.neuron.2015.02.022; CC BY 4.0. Cite NeuroMorpho.Org, RRID:SCR_002145.
]
