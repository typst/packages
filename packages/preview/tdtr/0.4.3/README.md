# tdtr

A Typst package for drawing beautiful tidy tree easily

This package uses [fletcher](https://typst.app/universe/package/fletcher) to render and customize nodes and edges

- [tdtr](#tdtr)
  - [Getting Started](#getting-started)
    - [From list](#from-list)
      - [Nodes only](#nodes-only)
      - [Nodes with Edges](#nodes-with-edges)
      - [(extra) Horizontal Compression](#extra-horizontal-compression)
    - [From file](#from-file)
      - [JSON](#json)
      - [YAML](#yaml)
      - [(extra) Forbidden Structure](#extra-forbidden-structure)
  - [Customization](#customization)
    - [Pre-defined graph drawing functions](#pre-defined-graph-drawing-functions)
      - [Binary/B-/Red-Black Tree](#binaryb-red-black-tree)
      - [Fibonacci Heap](#fibonacci-heap)
      - [Content Tree](#content-tree)
    - [(extra) Concept of node/edge drawing functions](#extra-concept-of-nodeedge-drawing-functions)
    - [Pre-defined node/edge drawing functions](#pre-defined-nodeedge-drawing-functions)
      - [Default node/edge drawing functions](#default-nodeedge-drawing-functions)
      - [Label Match node/edge drawing functions](#label-match-nodeedge-drawing-functions)
      - [Metadata Match node/edge drawing functions](#metadata-match-nodeedge-drawing-functions)
      - [Other Pre-defined node/edge drawing functions](#other-pre-defined-nodeedge-drawing-functions)
    - [Custom node/edge drawing functions](#custom-nodeedge-drawing-functions)
    - [Shortcut node/edge drawing functions](#shortcut-nodeedge-drawing-functions)
    - [Additional drawing functions](#additional-drawing-functions)
    - [(extra) Examples of Customization](#extra-examples-of-customization)
  - [API Reference](#api-reference)

## Getting Started

Import the package using:

```typ
#import "@preview/tdtr:0.4.3" : *
```

### From list

#### Nodes only

The most common case is to draw a tree directly from a bullet list.

Typical structure of the bullet list is:

```typ
- Parent node
  - Child node 1
    - Grandchild node 1
    - Grandchild node 2
  - Child node 2
```

where there must be only one root node (the top-level bullet list item), and each bullet list item represents a node in the tree, and the indentation level represents the parent-child relationship between nodes.

Here is an example:

![basic](docs/1-basic-tree.svg)

```typ
#tidy-tree-graph(compact: true)[
  - $integral_0^infinity e^(-x) dif x = 1$
    - `int main() { return 0; }`
      - Hello
        - This
        - Continue
        - Hello World
      - This
    - _literally_
      - Like
    - *day*
      - tomorrow $1$
]
```

where `compact: true` option will try its best to make the tree more compact by reducing the space between nodes, however, it may cause overlapping nodes in some cases.

#### Nodes with Edges

Another common case is that you may want to specify the labels of some edges, and then you can add a numbered list item before the child bullet list item (the item pointed by the edge) to specify the label of the edge.

Typical structure of the bullet list with edge labels is:

```typ
- Parent node
  + Edge label 1
  - Child node 1
    + Edge label 2
    - Grandchild node 1
//    + Edge label 3
    - Grandchild node 2
  + Edge label 4
  - Child node 2
```

where each numbered list item represents an edge label, and it's optional if you don't want to label the edge.

Here is an example:

![SLR](docs/2-SLR-analysis.svg)

```typ
#tidy-tree-graph(
  spacing: (20pt, 20pt),
  node-inset: 4pt
)[
  - $I_0$
    + $E$
    - $I_1$
      + $+$
      - $I_6$
        + $T$
        - $I_9$
          + $F$
          - $I_7$
        + $F$
        - $I_3$
        + $a$
        - $I_4$
        + $b$
        - $I_5$
    + $T$
    - $I_2$
      + $F$
      - $I_7$
        + $*$
        - $I_8$
      + $a$
      - $I_4$
      + $b$
      - $I_5$
    + $F$
    - $I_3$
      + $*$
      - $I_8$
    + $a$
    - $I_4$
    + $b$
    - $I_5$
]
```

where `spacing: (20pt, 20pt)` option specifies the horizontal and vertical spacing between nodes, and `node-inset: 4pt` option specifies the padding inside each node. They are passed to `fletcher.diagram` internally.

#### (extra) Horizontal Compression

During the drawing of the tidy tree, the package compresses nodes horizontally by default to make the tree more compact.

Here is an extreme example:

(you might think it's too crowded, and thus ugly somehow, but it's just to show the capability of this package)

![large](docs/3-large-tree.svg)

```typ
#tidy-tree-graph(
  draw-edge: tidy-tree-draws.horizontal-vertical-draw-edge,
)[
  - Hello
    - World
      - How
        - Whats
          - Day
        - the
          - Nest
        - Time
            - World
              - Whats
                - Day
              - the
              - Time
                - Hello
              - Today
              - Something
                - Interesting
      - This
      - Day
        - Hello
      - People
    - Things
    - Become
    - Somehow
    - are
      - People
      - Hello
        - World
        - Day
          - Hello
          - World
          - Fine
          - I'm
          - Very
            - Happy
            - That
            - They
            - have
            - what
        - you
        - Byte
        - integer
        - Today
      - you
      - Among
]
```

where `draw-edge: tidy-tree-draws.horizontal-vertical-draw-edge` option specifies a pre-defined edge drawing function to draw edges in a horizontal-vertical manner.

### From file

You can also draw import a tree from a file, supporting JSON and YAML formats, where every key and every value in the file represents a node in the tree.

Edge labels are not supported when importing from a file.

#### JSON

Here is an example of importing a tree from a JSON file:

`test.json`:

```json
{
    "Hello": {
        "World": {
            "How": {
                "Whats": [
                    "Day",
                    "the",
                    1
                ],
                "the": {},
                "Time": {
                    "Hello": [
                        1, 2, 3, 4, 5
                    ]
                }
            }
        },
        "This": {
            "Hello": {}
        },
        "Day": {},
        "People": {}
    }
}
```

![json](docs/4-json.svg)

```typ
#tidy-tree-graph(json("test.json"))
```

#### YAML

Here is an example of importing a tree from a YAML file:

`test.yaml`:

```yaml
app:
  server:
    host: localhost
    port: 8080
  database:
    user: 
      admin: admin
    password: 
      secret: kdi90gs78a7fgasad123gf70aa7ds0
```

![yaml](docs/5-yaml.svg)

```typ
#tidy-tree-graph(yaml("test.yaml"))
```

#### (extra) Forbidden Structure

- The json and yaml files should not contain any structure that an dictionary is included in an array, e.g.

    ```jsonc
    {
        "A": [
            {"B": "C"}  // this structure is not supported
        ],
        "B": [
            "D"  // this structure is supported
        ]
    }
    ```

    ```yaml
    A:
      - B: C  # this structure is not supported
    B:
      - D  # this structure is supported
    ```

## Customization

You might think the default drawing style is not suitable for your case, and you can customize it by either

- using pre-defined graph drawing functions
- passing pre-defined/custom node/edge drawing functions
- or add additional nodes and edges for specially customized graphs

when creating the tidy tree.

### Pre-defined graph drawing functions

This package provides several pre-defined graph drawing functions as variants of `tidy-tree-graph`.

They are all defined in `src/presets.typ`.

#### Binary/B-/Red-Black Tree

This package provides some graph drawing functions for common tree types as the variants of `tidy-tree-graph`:

- `binary-tree-graph`: suitable for the trees whose nodes and edges have simple and short content, e.g., a binary tree
- `red-black-tree-graph`: specialized for red-black trees, with color-coded nodes and hidden nil edges
- `b-tree-graph`: suitable for the trees whose node are relatively not short, e.g., B-trees

Here is an example of drawing a red-black tree:

![red-black](docs/6-red-black-tree.svg)

```typ
#red-black-tree-graph[
  - M
    - E
      - N <red>
      - P <red>
    - Q <red>
      - O
        - N <red>
        - P <nil>
      - Y
        - X <red>
        - Z <red>
]
```

where nodes labeled with `<red>` are drawn in red color, and nodes labeled with `<nil>` are hidden.

note: To follow Typst syntax, even nodes labeled with `<nil>` will not be shown, you should place a placeholder there, in this example, we use `P` as the placeholder

#### Fibonacci Heap

This package is also able to draw a tree constructed from multiple subtrees, e.g., a Fibonacci heap.

Here is an example of drawing a Fibonacci heap:

![fibonacci-heap](docs/8-fibonacci-heap.svg)

```typ
#fibonacci-heap-graph[
  - R <root>
    - 10
      - 11
    - 20
      - 34
        - 35
      - 23
    - 3
      - 14
      - 21
        - 25
      - 5 <mark>
        - 32
        - 7 <mark>
          - 13
    - 9
]

```

where nodes labeled with `<root>` will be hidden while drawing, same as those edges pointing from them, and nodes labeled with `<mark>` will be drawn in black and their text in white.

note: Also to follow Typst syntax, we place a placeholder `R` for the hidden root node

#### Content Tree

Sometimes, for the need of debugging, you may want to visualize the content tree of a Typst document. Then you can use `content-tree-graph` function to draw the content tree of the given content.

Here is an example:

![content-tree](docs/7-content-tree.svg)

```typ
#content-tree-graph[
  = Heading 1

  `int main() {}` <code>
  
  $
    integral_0^infinity e^(-x) dif x
  $
]
```

### (extra) Concept of node/edge drawing functions

Before introducing node/edge drawing functions, let's first understand the concept of node/edge drawing functions.

- First, all node/edge drawing functions are ended with `-draw-node` and `-draw-edge` respectively.

- Second, all `draw-node` and `draw-edge` functions have the following signature:

  ```typ
  (
    // ...
  ) -> arguments | dictionary | array
  ```

  namely, their return type must be either `arguments`, `dictionary` or `array`.

- Third, when drawing a tidy tree, for each node and edge in the tree, the package will call the provided `draw-node` and `draw-edge` functions respectively to get the **arguments** for drawing these nodes and edges using `fletcher.node` and `fletcher.edge`, i.e.,

  ```typ
  #{
    let node = fletcher.node(..draw-node(node-info))
    let edge = fletcher.edge(..draw-edge(from-node-info, to-node-info, edge-label))
  }
  ```

- Fourth, in `tidy-tree-graph` and its variants, you can specify the node and edge drawing functions using `draw-node` and `draw-edge` parameters respectively, for example:

  ```typ
  #tidy-tree-graph(
    draw-node: custom-draw-node,
    draw-edge: custom-draw-edge,
  )[
    // tree body
  ]
  ```

- Finally, if you have multiple drawing functions to apply to nodes/edges, you can pass an array of drawing functions instead of a single one to `draw-node` and `draw-edge`, then the package will call these drawing functions in order, and merge the returned arguments to get the final arguments for drawing the node/edge. In this way, you can combine multiple drawing functions together to achieve more complex drawing effects, i.e.

  ```typ
  #tidy-tree-graph(
    draw-node: (
      custom-1-draw-node,
      custom-2-draw-node,
      // ...
    ),
    draw-edge: (
      custom-1-draw-edge,
      custom-2-draw-edge,
      // ...
    )
  )[
    // tree body
  ]
  ```

  If `custom-2-draw-node` returns an argument that conflicts with the argument returned by `custom-1-draw-node`, the argument returned by `custom-2-draw-node` will override the previous one.

### Pre-defined node/edge drawing functions

This package provides several pre-defined drawing functions for nodes and edges.

They are defined in `src/draws.typ` as functions of module `tidy-tree-draws`.

#### Default node/edge drawing functions

Default node and edge drawing functions are defined as follows:

```typ
/// default function for drawing a node
#let default-draw-node = ((name, label, pos)) => {
  (
    pos: (pos.x, pos.i), 
    label: [#label], 
    name: name, 
    shape: rect
  )
}

/// default function for drawing an edge
#let default-draw-edge = (from-node, to-node, edge-label) => {
  (
    vertices: (from-node.name, to-node.name), 
    marks: "-|>"
  )
  if edge-label != none {
    (
      label: box(fill: white, inset: 2pt)[#edge-label], 
      label-sep: 0pt, 
      label-anchor: "center"
    )
  }
}
```

where `default-draw-node` draws every node as a rectangle, and `default-draw-edge` draws every edge with an arrowhead, and if the edge has a label, it will be drawn inside a white box to avoid overlapping with the edge.

note: `default-draw-node` and `default-draw-edge` are always applied first before other drawing functions when drawing nodes and edges respectively, so you don't need to specify them explicitly.

#### Label Match node/edge drawing functions

As you have seen in [Red Black Tree](#binaryb-red-black-tree) and [Fibonacci Heap](#fibonacci-heap) examples, this package provides some drawing functions that can conveniently label some nodes/edges and customize these labeled nodes/edges using `#label`.

To make understanding easier, we use the [Red Black Tree](#binaryb-red-black-tree) example.

Here is the source code of the pre-defined red-black tree graph drawing function (leaving out not related parts):

```typ
#let red-black-tree-graph = tidy-tree-graph.with(
  // ...
  draw-node: (
    // ...
    tidy-tree-draws.label-match-draw-node.with(
      matches: (
        red: (fill: color.rgb("#bb3e03")),
        nil: (post: x => none)
      ),
      default: (fill: color.rgb("#001219"))
    ),
    // ...
  ),
  draw-edge: (
    // ...
    tidy-tree-draws.label-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none),
      )
    ),
    // ...
  )
)
```

where `label-match-draw-node` and `label-match-draw-edge` are pre-defined label match node/edge drawing functions talked about before.

For `label-match-draw-node`, it has the following signature:

```typ
(
  // ...
  matches: dictionary, 
  default: dictionary
) -> arguments | dictionary | array
```

where `matches` tells the appended arguments to `fletcher.node` for nodes with specific label, and `default` tells the appended arguments to `fletcher.node` for nodes without any matched label.

For example,

- `- N <red>` node is labeled with `<red>`, so `label-match-draw-node` will append `(fill: color.rgb("#bb3e03"))` to the arguments of `fletcher.node` when drawing this node, making it drawn in red color.

- `- P <nil>` node is labeled with `<nil>`, so `label-match-draw-node` will append `(post: x => none)` to the arguments of `fletcher.node` when drawing this node, making it hidden.

- `- E` node is not labeled with any label, so `label-match-draw-node` will append `(fill: color.rgb("#001219"))` to the arguments of `fletcher.node` when drawing this node, making it drawn in black color.
Similarly, for `label-match-draw-edge`, it has the following signature:

```typ
(
  // ...
  from-matches: dictionary, 
  to-matches: dictionary, 
  matches: dictionary,
  default: dictionary
) -> arguments | dictionary | array
```

where `from-matches` tells the appended arguments to `fletcher.edge` for edges whose starting node has specific label, `to-matches` tells the appended arguments to `fletcher.edge` for edges whose ending node has specific label, `matches` tells the appended arguments to `fletcher.edge` for edges themselves with specific label, and `default` tells the appended arguments to `fletcher.edge` for edges themselves, the starting and ending nodes all without any matched label.

#### Metadata Match node/edge drawing functions

However, labels in Typst have some limitations, e.g., you cannot label one node/edge with different labels at the same time, and you must place a placeholder for syntax reasons even if you want to hide a node/edge.

Therefore, we provide a more flexible but slightly complex way to label nodes/edges using `#metadata(...)`, which can label one node/edge with multiple metadata at the same time, and nodes/edges can be hidden without any placeholder.

To make understanding easier, we still use the [Red Black Tree](#binaryb-red-black-tree) example.

If you would like to only use metadata to label nodes/edges, you can modify the previous example as follows:

```typ
#let red = metadata("red")
#let nil = metadata("nil")
#red-black-tree-graph[
  - M
    - E
      - N #red
      - P #red
    - Q #red
      - O
        - N #red
        - #nil
      - Y
        - X #red
        - Z #red
]
```

And here is the source code of the pre-defined red-black tree graph drawing function (leaving out not related parts):

```typ
#let red = metadata("red")
#let nil = metadata("nil")
#let red-black-tree-graph = tidy-tree-graph.with(
  // ...
  draw-node: (
    // ...
    tidy-tree-draws.metadata-match-draw-node.with(
      matches: (
        red: (fill: color.rgb("#bb3e03")),
        nil: (post: x => none)
      ),
      default: (fill: color.rgb("#001219"))
    ),
    // ...
  ),
  draw-edge: (
    // ...
    tidy-tree-draws.metadata-match-draw-edge.with(
      to-matches: (
        nil: (post: x => none),
      )
    ),
    // ...
  )
)
```

where `metadata-match-draw-node` and `metadata-match-draw-edge` are pre-defined metadata match node/edge drawing functions talked about before.

Same as `label-match-draw-node` and `label-match-draw-edge`, `metadata-match-draw-node` and `metadata-match-draw-edge` have the same signatures respectively, but they match nodes/edges using metadata instead of labels, so details are omitted here.

#### Other Pre-defined node/edge drawing functions

There are also some other pre-defined node/edge drawing functions for specific drawing effects.

For nodes:

- `circle-draw-node`: draw every node as a circle
- `horizontal-draw-node`: draw the tree in horizontal direction
- `hidden-draw-node`: draw a hidden node but affecting the layout

For edges:

- `reversed-draw-edge`: draw every edge in reversed direction
- `horizontal-vertical-draw-edge`: draw every edge in a horizontal-vertical manner
- `hidden-draw-edge`: draw a hidden edge

### Custom node/edge drawing functions

You can also define your own node/edge drawing functions from scratch.

For `draw-node`, the function should have the following signature:

```typ
(
  // positional arguments
  node: (
    name: label, 
    label: any, 
    pos: (
      i: int, 
      j: int, 
      k: int, 
      x: int | float
    ),
  )
  // other optional named arguments
) -> arguments | dictionary | array
```

where

- `name`: the unique label of the node, used for drawing edge, should not be changed, and should be used only by `fletcher.node(..., name: name, ...)`
- `label`: the content of the node, if the tree is from list, it's `content` type; if the tree is from file, it's `str` type, default used by `fletcher.node(..., label: [#label], ...)`
- `pos`: a tuple representing the position of the node in the tree, where `i` is the depth of the node, `j` is the index of the parent node in `i - 1` level, `k` is the index of the node among its siblings, and `x` is the x-coordinate of the node after horizontal compression, used for positioning the node, default used by `fletcher.node(..., pos: (x, i), ...)`. Specially, the `(i, j, k)` of the root node is `(0, 0, 0)`.

For `draw-edge`, the function should have the following signature:

```typ
(
  // positional arguments
  from-node: (
    name: label, 
    label: any, 
    pos: (
      i: int, 
      j: int, 
      k: int, 
      x: int | float
    )
  ), 
  to-node: (
    name: label, 
    label: any, 
    pos: (
      i: int, 
      j: int, 
      k: int, 
      x: int | float
    )
  ), 
  edge-label: any,
  // other optional named arguments
) -> arguments | dictionary | array
```

where

- `from-node`: a tuple representing the starting node of the edge, with the same structure as the parameters of `draw-node`
- `to-node`: a tuple representing the ending node of the edge, with the same structure as the parameters of `draw-node`
- `edge-label`: the label of the edge, if the edge has no label, it's `none`.

### Shortcut node/edge drawing functions

For convenience, if your node/edge drawing functions do not use any arguments provided, you can abbreviate your custom node/edge drawing functions to only the return value, e.g.,

```typ
#tidy-tree-graph(
  // ...
  draw-node: (
    ((label, )) => (label: text(blue)[#label]),
    tidy-tree-draws.metadata-match-draw-node.with(
      matches: (
        root: (..) => (shape: circle, fill: color.red)
      )
    )
  ),
  draw-edge: (
    (..) => (marks: "-o", stroke: color.red),
    tidy-tree-draws.metadata-match-draw-edge.with(
      to-matches: (
        leaf: (..) => (marks: "->", stroke: color.green)
      )
    ),
  )
)
```

abbreviates to

```typ
#tidy-tree-graph(
  // ...
  draw-node: (
    ((label, )) => (label: text(blue)[#label]),
    tidy-tree-draws.metadata-match-draw-node.with(
      matches: (
        root: (shape: circle, fill: color.red)
      )
    )
  ),
  draw-edge: (
    (marks: "-o", stroke: color.red),
    tidy-tree-draws.metadata-match-draw-edge.with(
      to-matches: (
        leaf: (marks: "->", stroke: color.green)
      )
    ),
  )
)
```

### Additional drawing functions

If you would like to add some other nodes/edges to the final diagram, you can pass an additional drawing function to `additional-draw` parameter of `tidy-tree-graph`, and similar to `draw-node` and `draw-edge`, array of drawing functions and shortcut drawing functions are also supported.

The function should have the following signature:

```typ
(
  nodes: array,
  element-func: (
    node: function,
    edge: function
  )
) -> array
```

where

- `nodes`: all the nodes in the tree, whose structure is the same as the parameter of `draw-node`
- `element-func`: a tuple of two functions, where
  - `node` is just `fletcher.node`, used to create additional nodes
  - `edge` is just `fletcher.edge`, used to create additional edges

And the return value should be an array of additional nodes and edges created using `element-func.node` and `element-func.edge`.

For example, in the pre-defined fibonacci heap graph drawing function, we use an additional drawing function to draw the dash line between the root nodes:

```typ
#let fibonacci-heap-graph = tidy-tree-graph.with(
  // ...
  additional-draw: (nodes, (node, edge)) => {
    // add connections between root nodes
    let tops = nodes.filter(n => n.pos.i == 1);
    let conns = tops.slice(0, tops.len() - 1).zip(tops.slice(1))
      .map(((f, t)) => edge(
        vertices: (f.name, t.name),
        marks: "--"
      ));
    conns
  }
)
```

where the additional drawing function first finds all root nodes, namely nodes in level 1, then connects every two adjacent root nodes using a dashed edge.

### (extra) Examples of Customization

A quite simple example:

```typ
#tidy-tree-graph(
  draw-node: (stroke: .5pt + red),
  draw-edge: (stroke: .5pt + blue, marks: "-")
)[
  // ...
]
```

which draws all nodes with red border and all edges with blue solid lines without arrowheads.

A little complex example:

```typ
#tidy-tree-graph(
  draw-node: (
    ((label, )) => (label: text(blue)[#label]),
    (shape: circle, fill: yellow)
  ),
  draw-edge: (
    (.., edge-label) => if edge-label != none { (label: text(green)[#edge-label]) },
    (marks: "-o", stroke: color.red),
  )
)[
  // ...
]
```

which draws all nodes as yellow circles with blue text, and all edges with red lines and circle marks, and if the edge has a label, it will be drawn in green text.

For more complex examples, you can see the implementations of pre-defined graph drawing functions in `src/presets.typ`, such as `red-black-tree-graph` and `fibonacci-heap-graph`.

## API Reference

The main function provided by this package is `tidy-tree-graph`, which has the following signature:

```typ
(
  // main body of the diagram
  body,

  // for customization of drawing functions
  draw-node: ..., // see above
  draw-edge: ..., // see above
  additional-draw: ..., // see above

  // make the tree more compact by reducing gaps between nodes
  // might cause overlapping nodes in some cases
  compact: false,

  // the minimum relative gap while calculating the horizontal axis of nodes
  // do NOT use it unless you know what you are doing
  min-gap: 1,

  // levels of subtrees that should NOT be compressed horizontally
  // sometimes, you may not want some subtrees to be compressed for better readability
  // e.g. forest, pass `subtree-levels: (1, )`
  // because the subtrees in level 1 are roots of the trees in the forest
  // and you may want them to be drawn like individual trees
  subtree-levels: array,

  // set text(size: text-size)
  text-size: 8pt,

  // specify fixed width/height for all nodes
  // they are NOT the arguments of `fletcher.diagram`,
  // but passed to `fletcher.node` when drawing each node
  node-width: auto,
  node-height: auto,

  // passed to `fletcher.diagram`
  node-stroke: 0.25pt,
  node-inset: 3pt,
  spacing: (6pt, 15pt),
  edge-corner-radius: none,
  ..args,
) -> fletcher.diagram
```
