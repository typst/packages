// engraved.typ — one-call engraved solid.
#import "picture.typ": draw
#import "surface.typ": surface
#import "solids.typ": silhouette
#import "pens.typ": linewidth

/// Hatched surface + silhouette (+ optional wireframe edges) of a solid, for `picture(style: "engraving", ...)`.
/// - `m`: number of samples of the silhouette.
/// - `rim`: pen of the contour (default `linewidth(0.8)`; `none` to omit it).
/// - `edges`: pen for the edges of the solid (box edges, cone base…); `none` = nothing.
/// - `color`: colour of the surface (passed to `surface`).
#let engraved(shape, m: 48, rim: auto, edges: none, color: none) = {
  let out = (draw(surface(shape), ..(if color == none { () } else { (color,) })),)
  if rim != none { out.push(draw(silhouette(shape, m: m), if rim == auto { linewidth(0.8) } else { rim })) }
  if edges != none { out.push(draw(shape, edges)) }
  out
}
