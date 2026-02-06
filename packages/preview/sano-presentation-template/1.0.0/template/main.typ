#import "@preview/sano-presentation-template:1.0.0": *

#show: sano.with(
  config-info(
    title: [Title for your awesome presentation in Typst],
    author: [Your Name],
  ),
)

#title-slide[
Write a small and descriptive description for your presentation. You can have more than a sentence and it still looks awesome.
]

= Show your heading text for new sections in big and coloured format.

== Grids to split your content

#grid(columns: 2, gutter: 2em, [
  - This slide type is ideal for comparing content.
  - For example, a column can contain an image or chart.
  - Thanks to Touying's package integration, we can, for example, reveal Fletcher diagrams piece by piece.
  - Just like in this graph, node "d" has now been revealed.
], [
  #{
    import "@preview/fletcher:0.5.7" as fletcher: node, edge
    let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

    let nodes = ("a", "e", "f", "g")
    let coords = ((1, 0), (2, 1), (0, 2), (3, 2))
    let edges = (
      ("a", "e"),
      ("a", "f"),
      ("f", "e"),
      ("f", "g"),
      ("e", "g"),
    )

    fletcher-diagram({
      for (i, n) in nodes.enumerate() {
        node(coords.at(i), n, name: n, stroke: 0.5pt, shape: "circle")
      }
      for (from, to) in edges {
        edge(label(from), label(to), "-")
      }}, {
      node((1, 1), "d", name: "d", stroke: 0.5pt, shape: "circle" , fill: sano-colors.white)
      edge(label("a"), label("d"), "-")
      edge(label("d"), label("e"), "-")
    })
  }
])

== Hello, template user

You can use `#only("num-")[...]` to create slides that flows better.

- #lorem(20)
#only("2-")[- #lorem(20)]
#only("3-")[- #lorem(20)]