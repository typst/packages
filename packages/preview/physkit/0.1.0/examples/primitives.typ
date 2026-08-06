#import "@preview/physkit:0.1.0": primitives as p

#set page(width: auto, height: auto, margin: 8mm)

#p.canvas({
  p.surface((0, 0), (5, 0))
  p.rectangle((1.2, 0.55), width: 1.2, height: 0.8)
  p.circle((3.5, 1.2), radius: 0.55, fill: white)
  p.arrow((1.2, 0.55), (1.2, 2.1), label: [$F$])
})
