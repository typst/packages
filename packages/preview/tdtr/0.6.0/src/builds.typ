/// build functions for automatically building a tree
#import "attrs.typ": *

// move back to the parent node
#let up() = (
  metadata((
    class: "builds-up",
  )),
)

// set content of the edge from current node to next node
#let edge(body) = (
  metadata((
    class: "builds-edge",
    body: body,
  )),
)

// create a new child node and move to this node
#let node(body, attr: node-attr()) = (
  metadata((
    class: "builds-node",
    body: body,
    attr: attr,
  )),
)

// for leaf nodes, after creation, immediately move back to parent
#let leaf(body, attr: node-attr()) = (
  node(body, attr: attr),
  up(),
)
