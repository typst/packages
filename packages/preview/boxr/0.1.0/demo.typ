#import "@preview/boxr:0.1.0": *

#set page(
  "a3",
  margin: 0mm
)
#set align(center + horizon)
#render-structure(
  "box",
  width: 100pt,
  height: 100pt,
  depth: 100pt,
  tab-size: 20pt
)
// #let size = get-structure-size(
//   "box",
//   width: 100pt,
//   height: 100pt,
//   depth: 100pt,
//   tab-size: 20pt
// )
// #render-structure(
//   "ramp",
//   width: 100pt,
//   height: 50pt,
//   depth: 200pt,
//   tab-size: 20pt
// )
// #render-structure(
//   "step",
//   width: 100pt,
//   height-1: 50pt,
//   height-2: 30pt,
//   depth-1: 100pt,
//   depth-2: 80pt,
//   tab-size: 20pt
// )