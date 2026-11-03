// A simple (primitive) hexagonal Brillouin zone — a hexagonal prism — with the
// recommended hP path (Γ–M–K–Γ–A–L–H–A, plus L–M and H–K) drawn on it. For hP
// the primitive cell equals the conventional cell, so only the hexagonal setting
// (γ = 120°) is needed.
#import "/lib.typ": bz-figure

#set page(width: auto, height: auto, margin: 0.4cm)
#set text(font: "New Computer Modern", size: 9pt)

#bz-figure(
  (a: 2.46, c: 6.70, gamma: 120deg), // graphite-like, in Å
  bravais: "hP",
  view: (azimuth: 90deg, elevation: 24deg),
  width: 8cm,
)
