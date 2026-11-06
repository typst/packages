#import "@local/emergraph:0.1.0": ALL-ESL-SHAPES as esl, fletcher
#import fletcher: diagram, edge, node

#diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  cell-size: (10em, 6em),
  debug: 3,
  {
    node(
      name: <source>,
      pos: (0, 0),
      shape: esl.source,
      label: [Input],
      height: 3em,
      fill: rgb("#fbff0050"),
    )
    node(
      name: <producer>,
      pos: (1, 0),
      label: [Production],
      height: 3em,
      fill: rgb("#cccccc"),
    )
    node(
      name: <tank>,
      pos: (2, 1),
      label: [Storage],
      shape: esl.tank,
      fill: rgb("#cccccc"),
    )
    node(
      name: <consumer>,
      pos: (2, 0),
      shape: esl.consumer,
      label: [Consumption],
      height: 3em,
      fill: rgb("#ffbb0050"),
    )
    node(
        enclose: (<producer>, <tank>, <consumer>),
        stroke: (dash: "dashed", thickness: 1.5pt),
        inset: 25pt,
        snap: false,
        name: <boundary>,
        label: align(top)[#text(
          weight: "bold",
          size: 9pt,
        )[#v(-1cm) System]],
      )

    edge(<source>, <producer>, marks: "-|>")
    edge(<producer>, <consumer>, marks: "-|>")
    edge(<producer>, <tank>, marks: "-|>")
  },
)