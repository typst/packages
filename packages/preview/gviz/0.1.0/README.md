# GViz
GViz is a typst plugin that can render graphviz graphs.

It uses https://codeberg.org/Sekoia/layout as a backend, which means it can currently only render to SVG, and mostly supports basic features.

Import it like any other plugin: `#import "@preview/gviz:0.1.0": *`.

## Usage
```typst
#import "@preview/gviz:0.1.0": *

#show raw.where(lang: "dot-render"): it => render-image(it.text)

```dot-render
digraph mygraph {
  node [shape=box];
  A -> B;
  B -> C;
  B -> D;
  C -> E;
  D -> E;
  E -> F;
  A -> F [label="one"];
  A -> F [label="two"];
  A -> F [label="three"];
  A -> F [label="four"];
  A -> F [label="five"];
}```

#let my-graph = "digraph {A -> B}"
#render-image(my-graph)

SVG:
#raw(render(my-graph), block: true, lang: "svg")
```

## API

### render
Renders a graph in dot language and returns SVG code for it.

Parameters:
- code (string, bytes): Dot language code to be rendered.

Returns: string
### render-image
Renders a graph in dot language and returns an SVG image of it. Uses the same parameters as image.decode.

Parameters:
- code (string, bytes): Dot language code to be rendered.
- width (auto, relative): The width of the image.
- height (auto, relative): The height of the image.
- alt (none, string): A text describing the image.
- fit (string): How the image should adjust itself to a given area. See image.decode.

Returns: content