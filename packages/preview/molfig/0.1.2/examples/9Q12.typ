// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 9Q12
// PDB DOI: https://doi.org/10.2210/pdb9Q12/pdb
// PDB archive data files are available under CC0 1.0.
// Structure authors: Wang, Y.; Liu, B.; He, Y.; Feigon, J.
// Literature status: To be published.

#import "@preview/molfig:0.1.2"
#set page(width: auto, height: auto, margin: 0mm)

#let data = read("data/9q12.pdb", encoding: none)
#molfig.render(
    data, 
    format: "pdb", 
    representation: "cartoon",
    mesh-format: "obj", 
    quality: "high", 
    output-format: "svg",
    config: (
        background: ""
    )
)
