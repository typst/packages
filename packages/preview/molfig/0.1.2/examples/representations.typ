// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 1CRN
// PDB DOI: https://doi.org/10.2210/pdb1CRN/pdb
// Deposition authors: Hendrickson, W.A.; Teeter, M.M.
// PDB archive data files are available under CC0 1.0.
// Primary citation: Teeter, M.M. (1984) Proc Natl Acad Sci U S A 81: 6014-6018.
// Article DOI: https://doi.org/10.1073/pnas.81.19.6014

#import "@preview/molfig:0.1.2"

#set page(width: 180mm, height: auto, margin: 4mm)
#set text(font: "New Computer Modern", size: 9pt)

#let data = read("data/1crn.bcif", encoding: none)
#let view(representation) = molfig.render(
  data,
  format: "bcif",
  representation: representation,
  mesh-format: "obj",
  quality: "high",
  center: true,
  output-format: "svg",
  config: (azimuth: 35, elevation: 24, background: ""),
  width: 55mm,
  height: 50mm,
)

#let panel(label, representation) = [
  #align(center, strong(label))
  #block(
    width: 55mm,
    height: 50mm,
    clip: true,
    align(
      center + horizon,
      scale(
        x: 165%,
        y: 165%,
        origin: center + horizon,
        view(representation),
      ),
    ),
  )
]

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 2mm,
  panel([Cartoon], "cartoon"),
  panel([Spacefill], "spacefill"),
  panel([Surface], "surface"),
)
