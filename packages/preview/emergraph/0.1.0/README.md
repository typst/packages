# emergraph

Draw H.T. Odum's Energy Systems Language (ESL) blocks and diagrams.

`emergraph` provides ready-to-use [Energy Systems Language](https://en.wikipedia.org/wiki/Energy_systems_language)
symbols for [Fletcher](https://typst.app/universe/package/fletcher/), the Typst
package for drawing graphs and diagrams. The shapes can be combined with
Fletcher's `diagram`, `node`, and `edge` functions to model energy, material,
and information flows, including emergy and life-cycle assessment diagrams.

## Getting started/

The package requires Typst 0.13.0 or newer and depends on Fletcher 0.5.8, which
is re-exported for convenience:

```typ
#import "@preview/emergraph:0.1.0": ALL-ESL-SHAPES as esl, fletcher
#import fletcher: diagram, edge, node
```

When testing a local copy, import it from the local namespace instead:

```typ
#import "@local/emergraph:0.1.0": ALL-ESL-SHAPES as esl, fletcher
```

## Usage

Every symbol is a shape function compatible with Fletcher's `node`:

```typ
#import "@preview/emergraph:0.1.0": ALL-ESL-SHAPES as esl, fletcher
#import fletcher: diagram, edge, node

#diagram(
  node-stroke: 1pt,
  edge-stroke: 1pt,
  cell-size: (10em, 6em),
  debug: 0,
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
```

## Shapes

All shapes are available through `ALL-ESL-SHAPES`:

| Name | ESL symbol | Description |
| --- | --- | --- |
| `amp` | Amplifier | Triangle amplifier with an adjustable direction, angle, aspect, and fit. |
| `box` | Box | Generic rectangular unit. |
| `consumer` | Consumer | Hexagon representing a consumer or final use. |
| `interaction` | Interaction | Chevron representing an interaction between flows. |
| `limit` | Limiting factor | Circle representing a limiting factor or control. |
| `producer` | Producer | Rectangle with one rounded corner. |
| `sink` | Sink | Ground-like symbol representing a sink or heat loss. |
| `source` | Source | Circle representing an external source. |
| `switch` | Switch | Four-arc symbol representing a switch or control. |
| `tank` | Tank | Domed symbol representing storage. |
| `transaction` | Transaction | Diamond representing a market or transaction. |

Shapes can also be imported individually:

```typ
#import "@preview/emergraph:0.1.0": source, consumer, tank
```

## Acknowledgements

The symbols follow the Energy Systems Language developed by Howard T. Odum.
Diagram rendering is powered by [Fletcher](https://github.com/Jollywatt/typst-fletcher)
by Jasper W. “Jollywatt”.

## License

Licensed under the [Apache License, Version 2.0](https://opensource.org/license/apache-2.0).
