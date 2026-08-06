// The classic textbook figure: the fcc Brillouin zone — a truncated octahedron —
// with the Γ–X–W–K–Γ–L high-symmetry path traced on it and its k-points labelled.
// Parameters in, figure out: `bravais: "cF"` selects the SC-2010 cF k-points and
// the correct primitive (face-centered) cell, so the zone reads as a truncated
// octahedron and every k-point lands on its boundary.
#import "/lib.typ": bz-figure

#set page(width: auto, height: auto, margin: 0.4cm)
#set text(font: "New Computer Modern", size: 9pt)

#bz-figure(
  (a: 3.61), // copper, in Å
  bravais: "cF",
  path: ("Γ", "X", "W", "K", "Γ", "L"),
  view: (azimuth: 30deg, elevation: 20deg),
  width: 8cm,
)
