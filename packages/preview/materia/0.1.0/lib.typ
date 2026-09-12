/// The installed materia package version.
#let materia-version = version(0, 1, 0)

// Domain namespaces for readers who prefer explicit specialist APIs.
#import "src/core.typ" as core
#import "src/real.typ" as real
#import "src/reciprocal.typ" as reciprocal
#import "src/electronic.typ" as electronic

#import "src/core/structure.typ": structure
#import "src/real/crystal.typ": crystal, molecule
#import "src/real/figure.typ": crystal-scene
#import "src/io.typ": import-xyz, import-poscar, import-cif
#import "src/prototypes.typ"

#import "src/reciprocal/reciprocal.typ": reciprocal-vectors, params-to-vectors
#import "src/reciprocal/wigner-seitz.typ": bz-cell, bz-volume
#import "src/reciprocal/kpath.typ": kpoints, kpath, kpath-data
#import "src/reciprocal/figure.typ": bz-scene, bz-figure, band-panel, band-axis, pretty-klabel

#import "src/electronic/model.typ": energy-level, orbital-column, correlate, mo-model, bond-order
#import "src/electronic/figure.typ": mo-scene, mo-diagram
