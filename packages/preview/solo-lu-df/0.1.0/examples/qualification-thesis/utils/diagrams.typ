#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: cylinder, diamond, ellipse

#let default-node-stroke = 1pt
#let default-edge-stroke = 1pt

/// Read https://github.com/typst/packages/raw/main/packages/preview/fletcher/0.5.8/docs/manual.pdf for more information

#let data-store(pos, text) = {
  node(
    pos,
    text,
    inset: 20pt,
    stroke: default-node-stroke,
  )
}

#let process(..args) = {
  node(
    inset: 10pt,
    shape: ellipse,
    stroke: default-node-stroke,
    ..args,
  )
}

#let dpd-edge(..args) = {
  edge(
    label-pos: 0.5,
    stroke: default-edge-stroke,
    label-anchor: "center",
    label-fill: white,
    corner-radius: 4pt,
    label-size: 10pt,
    ..args,
    "-|>",
  )
}

#let dpd-database(..args) = {
  node(
    shape: cylinder,
    height: 6em,
    width: 10em,
    stroke: default-node-stroke,
    ..args,
  )
}
