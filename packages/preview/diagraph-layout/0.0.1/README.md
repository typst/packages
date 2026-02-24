# diagraph-layout

A layout engine for directed graphs that uses graphviz algorithms.

> [!NOTE] 
> This project only exposes the layout engines and provides no means of rendering the graphs itself. You must use a separate library for rendering the graphs. If you are looking for a complete solution for rendering graphs, you might want to check out [diagraph](https://github.com/Robotechnic/diagraph).

> [!CAUTION]
> This is still a work in progress. The API is not stable yet and might change in the future. Any feedback is welcome!

## API Reference

The api beeing quite simple, there is no need for a separate documentation. Everithing is documented in the following. For more detailed resources on graphviz check their [official documentation](https://graphviz.org/documentation/).

### layout-graph

```typ
#let layout-graph(engine: "dot", directed: false, ..graph)
```

Layouts a graph using the specified layout engine. The default engine is `dot`. Other supported engines are listed by the function `engine-list`. The graph can be either directed or undirected. The default is undirected. The rest of the arguments are element functions. See the following for more details.

### engine-list

```typ
#let engine-list()
```

Returns a list of supported layout engines. The list can change in the future and this is hence the most reliable way to get the supported engines. But as of now, the supported engines are:

- `circo`
- `dot`
- `fdp`
- `neato`
- `nop`
- `nop1`
- `nop2`
- `osage`
- `patchwork`
- `sfdp`
- `twopi`

### node

```typ
#let node(name, width: 0.75 * 75pt, height: 0.5 * 75pt, xlabel: none)
```

Defines a new node with the given name. `width` and `height` define the size of the node in points. The default size is the graphviz default size of `0.75in` x `0.5in`. The `xlabel` argument is the size of the xlabel of the node. This argument takes a `dict` with the keys `width` and `height` in points.

### edge

```typ
#let edge(head, tail, label: none, xlabel: none, taillabel: none, headlabel: none, ..args)
```

Defines a new edge between the nodes `head` and `tail`. The `label`, `xlabel`, `taillabel` and `headlabel` arguments are optional labels for the edge. They take a `dict` with the keys `width` and `height` in points. The rest of the arguments are the edge attributes in the form of named arguments. See [here](https://graphviz.org/docs/edges/) for a list of supported attributes.

> [!NOTE]
> Only the arguments that have an influence on the layout are supported. For example, the `color` won't have any effect as it does not influence the layout.

### graph-attribute

```typ
#let graph-attribute(type, key, value)
```

This function lets you set global graph attributes. The `type` argument can be either `"GRAPH"`, `"NODE"` or `"EDGE"`. The `key` and `value` arguments are the attribute key and value. See [here](https://graphviz.org/doc/info/attrs.html) for a list of supported attributes.

### subgraph

```typ
#let subgraph(...args)
```

Defines a new subgraph. The positional arguments are nodes names. The rest of the named arguments are the subgraph attributes. See [here](https://graphviz.org/docs/graph/) for a list of supported attributes.
This function is made to be used as a separated context for attributes. For instance, you can use it to add `rank=same` to a group of nodes.

## Output format

```typ
#(
    "errored": bool,
    "scale": length,
    "width": length,
    "height": length,
    "nodes": (
        (
            "name": str,
            "x": length,
            "y": length,
            "width": length,
            "height": length,
            "xlabel": (
                "x": length,
                "y": length,
                "width": length,
                "height": length
            )
        ),
    ),
    "edges": (
        (
            "head": str,
            "tail": str,
            "points": (
                ("x": length, "y": length),
            ),
            "label": (
                "x": length,
                "y": length,
                "width": length,
                "height": length
            ),
            "xlabel": (
                "x": length,
                "y": length,
                "width": length,
                "height": length
            ),
            "headlabel": (
                "x": length,
                "y": length,
                "width": length,
                "height": length
            ),
            "taillabel": (
                "x": length,
                "y": length,
                "width": length,
                "height": length,
            )
        )
    )
)
```

Coordinates are given in graphviz coordinates, meaning that they represent the center of the object. If you want to see how it translates in cetz coordinates, look at the [renderer used in tests](src/renderer.typ).

The `errored` field indicates if the layouting was successful or not. If it is `true`, the rest of the fields are not valid. The `scale` field indicates the scale used by graphviz to convert points to inches, usually `1`. Except for very advanced things, you can just ignore it completely. The `width` and `height` fields indicate the size of the whole graph.

> [!WARNING]
> The outputting order of nodes and edges is not guaranteed to be the same as the inputting order, this can change because of graphviz internals.

## Change Log

### 0.0.1

- Initial release
