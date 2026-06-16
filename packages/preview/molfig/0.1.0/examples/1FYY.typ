// Uses structural data from RCSB PDB / wwPDB.
// PDB ID: 1FYY
// PDB DOI: https://doi.org/10.2210/pdb1FYY/pdb
// Deposition authors: Volk, D.E.; Rice, J.S.; Luxon, B.A.; Yeh, H.J.C.; Liang, C.; Xie, G.; Sayer, J.M.; Jerina, D.M.; Gorenstein, D.G.
// PDB archive data files are available under CC0 1.0.
// Primary citation: Volk, D.E.; Rice, J.S.; Luxon, B.A.; Yeh, H.J.; Liang, C.; Xie, G.; Sayer, J.M.; Jerina, D.M.; Gorenstein, D.G. (2000) Biochemistry 39: 14040-14053.
// Article DOI: https://doi.org/10.1021/bi001669l

#import "../lib.typ" as molfig
#set page(width: auto, height: auto, margin: 3mm)

#let data = read("data/1FYY.cif", encoding: none)
#molfig.render(
    data, 
    format: "cif", 
    representation: "molstar", 
    mesh-format: "obj", 
    quality: "high", 
    output-format: "svg",
    config: (
        background: ""
    )
)
