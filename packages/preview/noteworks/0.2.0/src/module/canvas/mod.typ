// =====================================================
// CANVAS MODULE - Main entrypoint for canvas system
// =====================================================
// Re-exports all canvas types with theme binding. Canvas wrappers
// resolve the document theme from the configuration state at render
// time. The raw draw-* helpers return CeTZ elements (not content),
// so they cannot read the state themselves - pass `theme:` explicitly
// if you use them directly inside a canvas; they fall back to neutral
// colors otherwise.

#import "../../core/setup.typ": nw-theme

// Drawing utilities (no theme binding needed)
#import "draw.typ": draw-geo

// Import raw implementations
#import "cartesian.typ": (
  cartesian-canvas as cartesian-canvas-impl, graph-canvas as graph-canvas-impl, trig-canvas as trig-canvas-impl,
)
#import "polar.typ": polar-canvas as polar-canvas-impl
#import "space.typ": (
  draw-point-3d, draw-vec-3d, space-canvas as space-canvas-impl,
)
#import "blank.typ": blank-canvas as blank-canvas-impl, simple-canvas as simple-canvas-impl
#import "vector.typ": (
  draw-vector, draw-vector-addition, draw-vector-components, draw-vector-projection,
)
#import "combi.typ": draw-boxes, draw-circular, draw-linear

// Note: Data series functionality has moved to ../data/mod.typ

// =====================================================
// THEMED CANVAS WRAPPERS
// =====================================================

// Canvas types (theme-bound and centered)
#let cartesian-canvas(..args) = {
  align(center)[#context cartesian-canvas-impl(..args, theme: nw-theme())]
}
#let graph-canvas(..args) = {
  align(center)[#context graph-canvas-impl(..args, theme: nw-theme())]
}
#let trig-canvas(..args) = {
  align(center)[#context trig-canvas-impl(..args, theme: nw-theme())]
}
#let polar-canvas(..args) = {
  align(center)[#context polar-canvas-impl(..args, theme: nw-theme())]
}
#let space-canvas(..args) = {
  align(center)[#context space-canvas-impl(..args, theme: nw-theme())]
}
#let blank-canvas(..args) = {
  align(center)[#context blank-canvas-impl(..args, theme: nw-theme())]
}
#let simple-canvas(..args) = context simple-canvas-impl(theme: nw-theme(), ..args)
