// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 9R1O
// PDB DOI: https://doi.org/10.2210/pdb9R1O/pdb
// Deposition authors: Petrenas, R.; Ozga, K.; Chubb, J.J.; Woolfson, D.N.
// PDB archive data files are available under CC0 1.0.
// Literature status: To be published.

#import "@preview/molfig:0.1.2"

#set page(width: 105mm, height: auto, margin: 8mm)
#set text(font: "New Computer Modern", size: 9pt)

#let meta = molfig.info(
  read("data/9R1O.pdb", encoding: none),
  format: "pdb",
  representation: "cartoon",
  assembly: "1",
  alt-loc: "highest-occupancy",
)

#table(
  columns: (1fr, 1fr),
  inset: 5pt,
  stroke: 0.4pt + luma(75%),
  table.header([*Property*], [*Value*]),
  [Atoms], [#meta.atom_count],
  [Bonds], [#meta.bond_count],
  [Assembly], [#meta.assembly.id],
  [Units], [#meta.structure.unit_count],
  [Realized visuals], [#meta.representation.realized_visuals.join(", ")],
)
