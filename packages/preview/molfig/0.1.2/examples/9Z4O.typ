// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 9Z4O
// PDB DOI: https://doi.org/10.2210/pdb9Z4O/pdb
// Deposition authors: Ge, Y.; de Almeida Magalhaes, T.; Wu, H.; Yadav, G.P.; Wang, Z.; Salic, A.; Jiang, J.; Huang, P.
// PDB archive data files are available under CC0 1.0.
// Literature status: To be published.

#import "@preview/molfig:0.1.2"
#set page(width: auto, height: auto, margin: 3mm)

#let data = read("data/9Z4O.pdb", encoding: none)
#molfig.render(
    data, 
    format: "pdb", 
    representation: "spacefill",
    mesh-format: "obj", 
    quality: "high", 
    output-format: "svg",
    config: (
        background: ""
    )
)
