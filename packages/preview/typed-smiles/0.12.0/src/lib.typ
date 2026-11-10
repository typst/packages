// Typst SMILES Package
// Renders SMILES strings as 2D molecular structure diagrams via a WASM plugin.

#import "chemistry.typ": ce, mol-formula, mol-weight, substructure-matches
#import "substructure.typ": functional-groups
#import "mechanism/references.typ": atom, bond, lp, species
#import "mechanism/annotations.typ": arrow, highlight
#import "molecule/api.typ": smiles, smiles-inline, smiles-cetz
#import "reaction/schemes.typ": rxn-arrow, mol, reaction, brackets
#import "reaction/cycles.typ": step, cycle
#import "molecule/library.typ": molecules
