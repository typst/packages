#import "@preview/cetz:0.5.2"
#import "@preview/cetz-feynman-lite:0.1.0": feynman

#cetz.canvas(length: 10mm, {
  feynman(
    ("i", "v", (particle: "fermion",
      style: (paint: blue, thickness: 1.2pt))),
    ("v", "o", (particle: "fermion")),
    ("v", "g", (particle: "gluon",
      style: (paint: red, amplitude: 0.16,
        wavelength: 0.45, gluon-aspect: 1.1))),
    incoming: ("i",),
    outgoing: ("o", "g"),
  )
})
