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

#let panel-width = 55mm
#let panel-height = 42mm
#let data = read("data/1crn.bcif", encoding: none)

#let panel(name, representation, strength, zoom) = [
  #align(center)[
    #strong(name)\
    #text(size: 8pt)[decimate: #strength]
  ]
  #block(width: panel-width, height: panel-height, clip: true)[
    #align(
      center + horizon,
      scale(
        x: zoom,
        y: zoom,
        origin: center + horizon,
        molfig.render(
          data,
          format: "bcif",
          representation: representation,
          mesh-format: "obj",
          quality: "high",
          center: true,
          output-format: "svg",
          config: (azimuth: 35, elevation: 24, background: "", decimate: strength),
          width: panel-width,
          height: panel-height,
        ),
      ),
    )
  ]
]

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 2mm,
  row-gutter: 3mm,
  panel([Cartoon], "cartoon", 0, 165%),
  panel([Cartoon], "cartoon", 0.35, 165%),
  panel([Cartoon], "cartoon", 0.65, 165%),
  panel([Surface], "surface", 0, 145%),
  panel([Surface], "surface", 0.35, 145%),
  panel([Surface], "surface", 0.65, 145%),
  panel([Spacefill], "spacefill", 0, 145%),
  panel([Spacefill], "spacefill", 0.35, 145%),
  panel([Spacefill], "spacefill", 0.65, 145%),
)
