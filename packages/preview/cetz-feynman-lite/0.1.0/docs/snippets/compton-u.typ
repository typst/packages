#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "a", (particle: "fermion")),
    ("j", "b", (particle: "photon",
      route: (side: "below", level: 1))),
    ("a", "b", (particle: "fermion",
      momentum: (label: $p_1 - k_2$,
        label-offset: 0.35,
      span: 0.5))),
    ("b", "o", (particle: "fermion")),
    ("a", "g", (particle: "photon",
      route: (side: "below", level: 1))),
    vertices: (
      (id: "i", role: "incoming",
        label: $e^-(p_1)$, label-offset: (-0.8,
        0)),
      (id: "j", role: "incoming",
        label: $gamma(k_1)$, label-offset: (-0.8,
        0)),
      (id: "a"),
      (id: "b"),
      (id: "o", role: "outgoing",
        label: $e^-(p_2)$, label-offset: (0.8,
        0)),
      (id: "g", role: "outgoing",
        label: $gamma(k_2)$, label-offset: (0.8,
        0)),
    ),
    layout: (main-lines: (("i", "a", "b", "o"),),
      incoming-order: ("i", "j"),
      outgoing-order: ("o", "g")),
    crossing-gap: 0.12,
  )
})
