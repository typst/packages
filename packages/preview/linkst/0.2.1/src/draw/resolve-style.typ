#import "../utils/lib.typ": match-dict, match-dict-bool, resolve-stroke
#import "std-style.typ": knot-bool-style, edge-bool-style, node-bool-style
#import "resolve-debug.typ": resolve-debug, false-debug

//
// About this would be the typical style data for every item (every node, edge and knot):
// 
// style: (
//   stroke: (paint: rgb("#ff4136")),
//   scale: 1,
//   debug: (
//     knots: false,
//     edges: false,
//     nodes: false,
//     connections: false,
//     bezier: false,
//     arc: false,
//     bend: false,
//     grid: false,
//   ),
//   connection-size: 0.3,
//   bezier-connection: 0.7,
//   bridge-space: 0.4,
//   bridge-offset: 0,
//   bridge-type: none,
//   transform: (),
//   background: none,
//   padding: 0pt,
//   canvas-stroke: none,
// ),
// 

#let reduce-style(style, type) = {
  if type == "knot" {
    style = match-dict-bool(style, knot-bool-style)
  } else if type == "edge" {
    style = match-dict-bool(style, edge-bool-style)
  } else if type == "node" {
    style = match-dict-bool(style, node-bool-style)
  }

  style
}

/// 
/// Returns the style with all needed entries for a normalized style
/// Includes the parent style
/// Reduces the style data for certain styles
///
#let resolve-style(style, type, parent-style) = {
  if style.keys().any(k => k == "stroke") { style.stroke = resolve-stroke(style.stroke) } // resolve strokes to dictionaries
  if style.keys().any(k => k == "transform") { style.transform = parent-style.transform + style.transform } // add the transformation of the parent style
  if style.keys().any(k => k == "scale") { style.scale *= parent-style.scale } // attach the parent scale
  
  style = match-dict(style, parent-style) // standardize style
  style = reduce-style(style, type) // reduce the data of the style
  style
}
