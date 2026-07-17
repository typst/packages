#import "/lib.typ": prototypes, crystal
#set page(width: auto, height: auto, margin: 0.6cm)
#set text(font: "New Computer Modern", size: 10pt)

#let cell(fig, caption) = align(center)[
  #fig
  #v(0.2cm)
  #caption
]

#grid(
  columns: 2,
  column-gutter: 1cm,
  row-gutter: 0.8cm,
  cell(
    crystal(prototypes.rocksalt("Na", "Cl", a: 5.64), width: 6.5cm),
    [NaCl (rocksalt, $F m overline(3) m$)],
  ),
  cell(
    crystal(
      prototypes.perovskite("Sr", "Ti", "O", a: 3.905),
      bonds: ((elements: ("Ti", "O"), max: 2.2),),
      polyhedra: ("Ti",),
      width: 6.5cm,
    ),
    [SrTiO#sub[3] (perovskite, $P m overline(3) m$)],
  ),
  cell(
    crystal(prototypes.diamond("C", a: 3.567), width: 6.5cm),
    [Diamond ($F d overline(3) m$, origin choice 2)],
  ),
  cell(
    crystal(
      prototypes.tmd("Mo", "S", a: 3.16, z: 1.56),
      view: (azimuth: 20deg, elevation: 35deg),
      bonds: ((elements: ("Mo", "S"), max: 2.6),),
      supercell: (4, 4, 1),
      width: 6.5cm,
    ),
    [MoS#sub[2] monolayer (layer group $p overline(6) m 2$)],
  ),
)
