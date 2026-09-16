// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 9M1U
// PDB DOI: https://doi.org/10.2210/pdb9M1U/pdb
// PDB archive data files are available under CC0 1.0.
// Structure authors: Liu, H.; Zhang, X.; Xu, H.E.
// Primary citation: Zhang, X. et al. (2026), EMBO J.
// Article DOI: https://doi.org/10.1038/s44318-026-00823-y

#import "@preview/molfig:0.1.2"
#set page(width: auto, height: auto, margin: 0mm)

#let data = read("data/9M1U.pdb", encoding: none)
#molfig.render(
    data, 
    format: "pdb", 
    representation: "cartoon",
    mesh-format: "obj", 
    quality: "auto",
    output-format: "png",
    config: (
        background: "",
        elevation: 45
    )
)
