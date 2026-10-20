#import "/lib.typ": crystal, prototypes

#set page(width: auto, height: auto, margin: 0.6cm)
#set text(font: "New Computer Modern", size: 10pt)

// The same 2x2x1 NaCl supercell through both cameras. Under perspective the
// near corner's atoms are visibly larger and the cell edges converge.
#let nacl = prototypes.rocksalt("Na", "Cl", a: 5.64)

#grid(
  columns: 2,
  column-gutter: 1cm,
  align(center)[
    #crystal(nacl, supercell: (2, 2, 1), legend: false, width: 6.5cm)
    Orthographic (default)
  ],
  align(center)[
    #crystal(nacl, supercell: (2, 2, 1),
      view: (azimuth: 25deg, elevation: 15deg, mode: "perspective", distance: 18),
      legend: false, width: 6.5cm)
    Perspective (`distance: 18`)
  ],
)
