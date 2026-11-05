#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman
#set page(width: auto, height: auto, margin: 8mm)

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "a", (particle: "fermion", momentum: (label: $p$,))),
    ("a", "b", (particle: "fermion")),
    ("b", "o", (particle: "fermion")),
    ("a", "b", (particle: "photon",
      route: (side: "above", level: 1))),
    incoming: ("i",), outgoing: ("o",),
    layout: (main-lines: (("i", "a", "b", "o"),)),
  )
})
