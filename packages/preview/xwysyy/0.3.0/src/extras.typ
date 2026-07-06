// Optional cetz / fletcher / theorion integrations.
//
// Drawing with #pause:
//   #cetz-canvas(
//     { import cetz.draw: *; rect(...) },
//     pause,
//     { import cetz.draw: *; line(...) },
//   )
//
//   #fletcher-diagram(
//     node((0,0), [A]),
//     pause,
//     edge((0,0), (1,0), "->"),
//     node((1,0), [B]),
//   )
//
// Theorion environments:
//   #definition(title: "name")[...]
//   #theorem[...]
//   #lemma[...]
//   #corollary[...]
//   #example[...]

#import "@preview/touying:0.7.4": touying-reducer
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8" as fletcher: node, edge
// theorion star-import 会导出 cosmos 子模块；clouds 提供装饰性视觉元素
#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)
