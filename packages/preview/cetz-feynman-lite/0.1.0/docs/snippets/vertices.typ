#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "v", (particle: "fermion")),
    ("v", "o", (particle: "fermion")),
    ("v", "g", (particle: "photon")),
    vertices: (
      (id: "i", role: "incoming", label: $e^-$,
        label-offset: (-0.4, 0)),
      (id: "v", marker: "blob", size: 0.25,
        fill: blue.lighten(85%),
          stroke: 1pt + blue,
        label: $Gamma$, label-offset: (0, 0.5)),
      (id: "o", role: "outgoing", label: $e^-$,
        label-offset: (0.4, 0)),
      (id: "g", role: "outgoing", label: $gamma$,
        label-offset: (0.4, 0)),
    ),
  )
})
