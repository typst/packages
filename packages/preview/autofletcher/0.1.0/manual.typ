#import "@preview/tidy:0.2.0"
#import "@preview/fletcher:0.4.3" as fletcher: diagram, node, edge, shapes
#import "@preview/autofletcher:0.1.0": placer, place-nodes, edges, tree-placer, circle-placer, arc-placer

#let scope = (
  diagram: diagram,
  node: node,
  edge: edge,
  placer: placer,
  place-nodes: place-nodes,
  edges: edges,
  tree-placer: tree-placer,
  circle-placer: circle-placer,
  arc-placer: arc-placer,
  shapes: shapes,
)

#let version = "0.1.0"

#let example(code) = {
  {
    set text(7pt)
    box(code)
  }
  {eval(code.text, mode: "markup", scope: scope)}
}

#set heading(numbering: "1.1")

#align(center)[#text(2.0em, `autofletcher`)]
#align(center)[#text(1.0em, [_version #version _])]

#v(1cm)

This module provides functions to (sort of) abstract away manual placement of
coordinates by leveraging typst's partial function application.

#outline(depth: 3, indent: auto)

= Introduction

The main entry-point is `place-nodes()`, which returns a list of indices and a
list of partially applied `node()` functions, with the pre-calculated positions.

All coordinates here are elastic, as defined in the fletcher manual. Fractional
coordinates don't work that well, from what I've seen.

== About placers

A placer is a function that takes the index of current child, and the total
number of children, and returns the coordinates for that child relative to the
parent.

Some built-in placers are provided:

- `placer()` which allows easily creating placers from a list of positions.
  This should be good enough for most uses. See #link(label("flowchart"))[this
  example]
- `arc-placer()` and its special instance `circle-placer` are built-in placers
  for circular structures. See #link(label("arc"))[these examples]
- `tree-placer`, which places nodes as children in a tree. See
  #link(label("tree"))[this example]

It's relatively easy to create custom placers if needed. See #link(label("custom"))[here]

== About spread

It appears that fletcher "squeezes" large distances along the left-right axis, as
long as the coordinates in-between are empty. This is why it's useful to spread
out the first generation of children, even by a large factor. Their children
would then occupy the spaces in-between instead of overlapping.

This, however, does not appear to be true for the up-down axis.

= Examples

Import the module with:

#raw(lang: "typst", "#import \"@preview/autofletcher:" + version + "\": *")

== Flowchart <flowchart>

#example(```typst
#diagram(
  spacing: (0.2cm, 1.5cm),
  node-stroke: 1pt,
  {
    let r = (0, 0)
    let flowchart-placer = placer((0, 1), (1, 0))

    node(r, [start], shape: shapes.circle)
    // question is a node function with the position pre-applied
    let ((iquestion, ), (question, )) = place-nodes(r, 1, flowchart-placer, spread: 20)

    question([Is this true?], shape: shapes.diamond)
    edge(r, iquestion, "-|>")

    let ((iend, ino), (end, no)) = place-nodes(iquestion, 2, flowchart-placer, spread: 10)

    end([End], shape: shapes.circle)
    no([OK, is this true?], shape: shapes.diamond)

    edge(iquestion, iend, "-|>", label: [yes])
    edge(iquestion, ino, "-|>", label: [no])

    edge(ino, iend, "-|>", label: [yes], corner: right)

    edge(ino, r, "-|>", label: [no], corner: left)

  })
```)

== Tree diagram <tree>

#example(```typst
#diagram(
spacing: (0.0cm, 0.5cm),
{
  let r = (0, 0)
  node(r, [13])

  let (idxs0, (c1, c2, c3)) = place-nodes(r, 3, tree-placer, spread: 10)

  c1([10])
  c2([11])
  c3([12])

  edges(r, idxs0, "->")

  for (i, parent) in idxs0.enumerate() {
    let (idxs, (c1, c2, c3)) = place-nodes(parent, 3, tree-placer, spread: 2)

    c1([#(i * 3 + 1)])
    c2([#(i * 3 + 2)])
    c3([#(i * 3 + 3)])

    edges(parent, idxs, "->")
  }
})
```)

== Arc placer <arc>

with `circle-placer`:

#example(```typst
#diagram(
spacing: (1.5cm, 1.5cm),
node-stroke: 1pt,
{
  let r = (0, 0)

  let (idxs, nodes) = place-nodes(r, 12, circle-placer)

  for (i, ch) in nodes.enumerate() {
    ch([#{i + 1}], shape: shapes.circle)
  }

  edge(idxs.at(0), idxs.at(7), "-|>")
  edge(idxs.at(3), idxs.at(8), "-|>")
  edge(idxs.at(4), idxs.at(1), "-|>")
  edge(idxs.at(10), idxs.at(1), "-|>")
  edge(idxs.at(6), idxs.at(11), "-|>")
})
```)

With `arc-placer`:

#example(```typst
#diagram(
spacing: (1.5cm, 1.5cm),
{
  let placer = arc-placer(-30deg, length: calc.pi, radius: 1.2)
  let r = (0, 0)
  node(r, [root])

  let (idxs, nodes) = place-nodes(r, 5, placer, spread: 1)

  for (i, ch) in nodes.enumerate() {
    ch([#{i + 1}])
  }

  edges(r, idxs, "->")
})
```)


== Custom placers <custom>

If the built-in placers don't fit your needs, you can create a custom placer;
that is, a function that calculates the relative positions for each child.
It should accept, in order:
+ (`int`) the index of the child
+ (`int`) the total number of children
and it should return a pair of coordinates, `(x, y)`.

#example(```typst
#let custom-placer(i, num-total) = {
  // custom logic here
  let x = i - num-total/2
  let y = calc.min(- x, + x) + 1
  return (x, y)
}

#diagram({
  let r = (0, 0)
  node(r, [root])

  let (idxs, nodes) = place-nodes(r, 7, custom-placer, spread: 1)
  for (i, ch) in nodes.enumerate() {
    ch([#i])
  }
  edges(r, idxs, "-|>")
})
```)


#pagebreak(weak: true)
= API reference

#set heading(numbering: none)
#let docs = tidy.parse-module(read("autofletcher.typ"))
#tidy.show-module(docs, style: tidy.styles.default)

