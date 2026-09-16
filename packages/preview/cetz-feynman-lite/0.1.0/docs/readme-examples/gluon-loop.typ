#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman
#set page(width: auto, height: auto, margin: 8mm)

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "a", (particle: "gluon")),
    ("a", "b", (particle: "gluon",
      route: (side: "above", level: 1))),
    ("a", "b", (particle: "gluon",
      route: (side: "below", level: 1))),
    ("b", "o", (particle: "gluon")),
    incoming: ("i",), outgoing: ("o",),
    layout: (main-lines: (("i", "a", "b", "o"),)),
  )
})
