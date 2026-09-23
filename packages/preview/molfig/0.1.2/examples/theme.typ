// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 1CRN
// PDB DOI: https://doi.org/10.2210/pdb1CRN/pdb
// Deposition authors: Hendrickson, W.A.; Teeter, M.M.
// PDB archive data files are available under CC0 1.0.
// Primary citation: Teeter, M.M. (1984) Proc Natl Acad Sci U S A 81: 6014-6018.
// Article DOI: https://doi.org/10.1073/pnas.81.19.6014

#import "@preview/molfig:0.1.2"

#set page(width: 100mm, height: auto, margin: 4mm)

#molfig.render(
  read("data/1crn.bcif", encoding: none),
  format: "bcif",
  representation: "cartoon",
  theme: (
    globalName: "element-symbol",
    carbonColor: "chain-id",
    symmetryColor: "operator-name",
  ),
  mesh-format: "obj",
  quality: "high",
  center: true,
  output-format: "svg",
  config: (azimuth: 35, elevation: 24, background: ""),
  width: 92mm,
  height: 68mm,
)
