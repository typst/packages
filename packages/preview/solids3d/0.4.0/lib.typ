// solids3d — an independent Typst reimplementation inspired by Asymptote's
// `solids` module and the related 3D conventions.
//
// Version 0.3: simple API fig(); nibart integration (engraving style, knot3, brace3, plate).
//
// Usage:  #import "@local/solids3d:0.4.0": *   or   #import "lib.typ": *

#import "src/vec.typ": *
#import "src/path3.typ": *
#import "src/projection.typ": *
#import "src/pens.typ": *
#import "src/surface.typ": *
#import "src/solids.typ": *
#import "src/picture.typ": *
#import "src/vintage.typ": *
#import "src/engrave.typ": engraving, engraving-paper, engraving-ink
#import "src/engraved.typ": engraved
#import "src/plate.typ": plate
#import "src/easy.typ": fig, paint, cube, brick, view-projection
#import "src/braces.typ": brace3
#import "src/knots.typ": knot3, trefoil, figure-eight, torus-knot, hopf-link, borromean
#import "src/sketch.typ": *
#import "src/plot.typ": *
#import "src/obj.typ": obj
#import "src/education.typ": *
#import "src/college.typ": *
#import "graph3.typ": graph3-plot, parametric-plot3

// Public module facades. The aliases avoid collisions with the direct
// functions (`graph3`, `solids`, etc.) while keeping grouped APIs available.
#import "three.typ" as three
#import "three-surface.typ" as three_surface
#import "three-light.typ" as three_light
#import "graph3.typ" as graph3mod
#import "solids.typ" as solidsmod
#import "college.typ" as college
#import "vintage.typ" as vintage
#import "obj3.typ" as obj3
