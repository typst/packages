#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "v", (particle: "fermion")),
    ("v", "o", (particle: "fermion")),
    ("v", "g", (particle: "photon")),
    incoming: ("i",),
    outgoing: ("o", "g"),
  )
})
