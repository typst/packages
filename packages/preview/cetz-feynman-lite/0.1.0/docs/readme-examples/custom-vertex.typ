#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman
#set page(width: auto, height: auto, margin: 8mm)

#cetz.canvas(length: 12mm, {
  feynman(
    ("i", "v", (particle: "fermion")),
    ("v", "o", (particle: "fermion")),
    ("v", "g", (particle: "photon", style: (paint: blue))),
    vertices: (
      (id: "i", role: "incoming"),
      (id: "v", marker: "blob", size: 0.25,
        fill: blue.lighten(85%), stroke: 1pt + blue,
        label: $Gamma$, label-offset: (0, 0.5)),
      (id: "o", role: "outgoing"),
      (id: "g", role: "outgoing"),
    ),
  )
})
