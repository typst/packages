// Core drawing works independently; CeTZ integration is available as michem.cetz.
#import "typst/molecule.typ" as chemical
#import "typst/cetz.typ" as cetz

#let smiles = chemical.smiles
#let smiles-input = chemical.smiles-input
#let atom = chemical.atom
#let bond = chemical.bond
#let molecule = chemical.molecule
#let style = chemical.style
#let layout = chemical.layout
#let diagram = chemical.diagram
#let svg = chemical.svg

#import "typst/compound.typ": compound, compound-grid
#import "typst/route.typ": (
  paint-reaction-route, reaction-route, reaction-route-data, reaction-stage,
  reaction-step,
)

#import "typst/mechanism.typ": (
  atom-ref, bond-ref, edge, electron-arrow, electron-dot, formation-ref,
  highlight, lone-pair, mechanism, mechanism-data, mechanism-label,
  mechanism-panels, mol, near, paint-mechanism, pair-ref, radical-ref,
  reaction-arrow,
)
