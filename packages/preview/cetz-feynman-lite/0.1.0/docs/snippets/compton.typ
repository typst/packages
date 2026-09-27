#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "a", (particle: "fermion")),
    ("j", "a", (particle: "photon")),
    ("a", "b", (particle: "fermion",
      momentum: (label: $p_1 + k_1$,
        label-offset: 0.35,
        span: 0.5))),
    ("b", "o", (particle: "fermion")),
    ("b", "g", (particle: "photon")),
    vertices: (
      (id: "i", role: "incoming",
        label: $e^-(p_1)$,
        label-offset: (-0.8, 0)),
      (id: "j", role: "incoming",
        label: $gamma(k_1)$,
        label-offset: (-0.8, 0)),
      (id: "a"), (id: "b"),
      (id: "o", role: "outgoing",
        label: $e^-(p_2)$,
        label-offset: (0.8, 0)),
      (id: "g", role: "outgoing",
        label: $gamma(k_2)$,
        label-offset: (0.8, 0)),
    ),
    layout: (main-lines: (("a", "b"),),
      incoming-order: ("i", "j"),
      outgoing-order: ("o", "g")),
  )
})
