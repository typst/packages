// Internal rendering façade.
//
// Focused renderers own geometry, surfaces, bodies, structures, connectors,
// loads and motion, dimensions, and final scene assembly. FBD and public view
// assembly retain this stable internal boundary.

#import "render-geometry.typ" as geometry
#import "render-bodies.typ" as bodies
#import "render-loads.typ" as loads
#import "render-scene.typ" as scene

#let render-label = geometry.render-label
#let render-force-arrow = geometry.render-force-arrow
#let stroke-thickness = geometry.stroke-thickness
#let stroke-outset = geometry.stroke-outset
#let render-angle-marker = geometry.render-angle-marker
#let render-right-angle-marker = geometry.render-right-angle-marker

#let body-corners = geometry.body-corners
#let body-boundary-distance = geometry.body-boundary-distance
#let body-visible-boundary-distance = geometry.body-visible-boundary-distance
#let render-body-outline = bodies.render-body-outline

#let bodies-named-by = loads.bodies-named-by
#let render-scene = scene.render-scene
