#import "/lib.typ": structure, molecule, crystal, prototypes

#set page(width: auto, height: auto, margin: 0.6cm)
#set text(font: "New Computer Modern", size: 10pt)

// Benzene, constructed exactly: carbon hexagon of circumradius 1.39 Å (equal
// to the C-C bond length), hydrogens radially outward at 2.48 Å (C-H 1.09 Å).
#let ring(el, r) = range(6).map(k =>
  (el, (r * calc.cos(k * 60deg), r * calc.sin(k * 60deg), 0.0)))
#let benzene = structure(atoms: ring("C", 1.39) + ring("H", 2.48))
#let tilt = (azimuth: 20deg, elevation: 60deg)

#let panel(fig, caption) = align(center)[
  #fig
  #v(0.2cm)
  #caption
]

#grid(
  columns: 3,
  column-gutter: 0.9cm,
  row-gutter: 0.8cm,
  panel(
    molecule(benzene, view: tilt, legend: false, width: 4.6cm),
    [`ball-and-stick` (default)],
  ),
  panel(
    molecule(benzene, view: tilt, mode: "licorice", legend: false, width: 4.6cm),
    [`licorice`],
  ),
  panel(
    molecule(benzene, view: tilt, mode: "space-filling", legend: false, width: 4.6cm),
    [`space-filling` / `cpk`],
  ),
  panel(
    crystal(prototypes.rocksalt("Na", "Cl", a: 5.64), legend: false, width: 4.6cm),
    [NaCl, `ball-and-stick`],
  ),
  panel(
    crystal(prototypes.rocksalt("Na", "Cl", a: 5.64), mode: "space-filling",
      legend: false, width: 4.6cm),
    [NaCl, `space-filling`],
  ),
  panel(
    molecule(benzene, view: tilt, bond-color: luma(110), legend: false, width: 4.6cm),
    [`bond-color: luma(110)`],
  ),
)
