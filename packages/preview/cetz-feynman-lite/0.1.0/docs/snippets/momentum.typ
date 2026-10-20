#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "v", (particle: "photon")),
    ("v", "o", (particle: "fermion",
      momentum: (label: $p_1$, side: "left"))),
    ("v", "j", (particle: "fermion",
      arrow: "backward",
      momentum: (label: $p_2$,
        direction: "forward",
        side: "right", span: 0.4))),
    vertices: (
      (id: "i", role: "incoming", label: $Z$,
        label-offset: (-0.4, 0)),
      (id: "v"),
      (id: "o", role: "outgoing", label: $e^-$,
        label-offset: (0.4, 0)),
      (id: "j", role: "outgoing", label: $e^+$,
        label-offset: (0.4, 0)),
    ),
  )
})
