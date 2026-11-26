#import "@preview/reshikist:0.3.2": chem-image

= ReShiki Typst Plugin Test

== Pyrrole — file path as string (auto-detected RSK)
#chem-image("pyrrole.rsk", width: 30%)

== Polycyclic structure RSK — explicit format with bytes
#chem-image(read("molecule.rsk", encoding: none), format: "rsk", width: 40%)

== Transparent background
#chem-image("pyrrole.rsk", width: 30%, background: "transparent")

== Blue background
#chem-image("pyrrole.rsk", width: 30%, background: rgb(240, 248, 255))

== ChemDraw (CDXML)
#chem-image("indole.cdxml", width: 30%)

== Pyrrole with outlined text
#chem-image("pyrrole.rsk", width: 30%, outline-text: true)

== MOL file (benzene)
#chem-image("benzene.mol", width: 25%)

== SMILES input: benzene
#chem-image("c1ccccc1", width: 25%)

== SMILES input: branched alkane
#chem-image("CC(C)C(C)(C)C", width: 25%)

== SMILES input: strychnine
#chem-image("C1CN2CC3=CCO[C@H]4CC(=O)N5[C@H]6[C@H]4[C@H]3C[C@H]2[C@@]61C7=CC=CC=C75", width: 30%)

== RSMI input: reaction SMILES
#chem-image("CCO.O=C=O>>CCOC(=O)O", format: "rsmi", width: 40%)

== Configuration example — set defaults once with .with()
#let my-chem = chem-image.with(outline-text: true)
#my-chem("pyrrole.rsk", width: 30%)
