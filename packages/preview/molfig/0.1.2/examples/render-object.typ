// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 1FYY
// PDB DOI: https://doi.org/10.2210/pdb1FYY/pdb
// Deposition authors: Volk, D.E.; Rice, J.S.; Luxon, B.A.; Yeh, H.J.C.;
// Liang, C.; Xie, G.; Sayer, J.M.; Jerina, D.M.; Gorenstein, D.G.
// PDB archive data files are available under CC0 1.0.
// Primary citation: Volk, D.E. et al. (2000) Biochemistry 39: 14040-14053.
// Article DOI: https://doi.org/10.1021/bi001669l

#import "@preview/molfig:0.1.2"

#set page(width: 100mm, height: auto, margin: 4mm)
#set text(font: "New Computer Modern", size: 9pt)

#let object = molfig.render-object(
  read("data/1FYY.cif", encoding: none),
  format: "cif",
  representation: "cartoon",
  mesh-format: "obj",
  assembly: "1",
  config: (azimuth: 30, elevation: 18, background: ""),
  width: 92mm,
  height: 64mm,
  output-format: "svg",
)

#object.content
#align(center)[
  #text(size: 8pt)[Atoms: #object.info.atom_count \ 
    Mesh format: #object.mesh_format]
]
