// Gallery of Molfig example renders.
// Structural data source: RCSB PDB / wwPDB.
// PDB IDs: 1CRN, 1FYY, 9M1U, 9Q12, 9R1O, and 9Z4O.
// PDB archive data files are available under CC0 1.0.

#import "@preview/molfig:0.1.2"

#set page(
  paper: "a4",
  flipped: true,
  margin: 4mm,
)
#set text(font: "New Computer Modern", size: 10pt)

#let entry(data, format, magnification) = block(
  width: 93mm,
  height: 99mm,
  clip: true,
  align(
    center + horizon,
    scale(
      x: magnification,
      y: magnification,
      origin: center + horizon,
      molfig.render(
        data,
        format: format,
        representation: "cartoon",
        mesh-format: "obj",
        quality: "high",
        center: true,
        output-format: "svg",
        config: (
          elevation: 45,
          background: "",
        ),
        width: 93mm,
        height: 99mm,
      ),
    ),
  ),
)

#align(
  center + horizon,
  grid(
    columns: (93mm, 93mm, 93mm),
    rows: (99mm, 99mm),
    column-gutter: 5mm,
    row-gutter: 4mm,
    entry(read("data/1crn.bcif", encoding: none), "bcif", 180%),
    entry(read("data/1FYY.cif", encoding: none), "cif", 180%),
    entry(read("data/9M1U.pdb", encoding: none), "pdb", 165%),
    entry(read("data/9q12.pdb", encoding: none), "pdb", 175%),
    entry(read("data/9R1O.pdb", encoding: none), "pdb", 155%),
    entry(read("data/9Z4O.pdb", encoding: none), "pdb", 168%),
  ),
)
