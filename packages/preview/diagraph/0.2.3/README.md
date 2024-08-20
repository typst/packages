# diagraph

A simple Graphviz binding for Typst using the WebAssembly plugin system.

## Usage

### Basic usage


You can render a Graphviz Dot string to a SVG image using the `render` function:

```typ
#render("digraph { a -> b }")
```

Alternatively, you can use `raw-render` to pass a `raw` instead of a string:

<!--EXAMPLE(raw-render)-->
````typ
#raw-render(
  ```dot
  digraph {
    a -> b
  }
  ```
)
````
![raw-render](https://raw.githubusercontent.com/Robotechnic/diagraph/main/images/raw-render1.png)

For more information about the Graphviz Dot language, you can check the [official documentation](https://graphviz.org/documentation/).

### Arguments

`render` and `raw-render` accept multiple arguments that help you customize your graphs.

- `engine` (`str`) is the name of the engine to generate the graph with. Available engines are circo, dot, fdp, neato, nop, nop1, nop2, osage, patchwork, sfdp, and twopi. Defaults to `"dot"`.

- `width` and `height` (`length` or `auto`) are the dimensions of the image to display. If set to `auto` (the default), will be the dimensions of the generated SVG. If a `length`, cannot be expressed in `em`.

- `clip` (`bool`) determines whether to hide parts of the graph that extend beyond its frame. Defaults to `true`.

- `background` (`none` or `color` or `gradient`) describes how to fill the background. If set to `none` (the default), the background will be transparent.

- `labels` (`dict`) is a list of labels to use to override the defaults labels. This is discussed in depth in the next section. Defaults to `(:)`.

### Labels

By default, all node labels are rendered by Typst. If a node has no explicitly set label (using the `[label="..."]` syntax), its name is used as its label, and interpreted as math if possible. This means a node named `n_0` will render as 𝑛<sub>0</sub>.

If you want a node label to contain a more complex mathematical equation, or more complex markup, you can use the `labels` argument: pass a dictionary that maps node names to Typst `content`. Each node with a name within the dictionary will have its label overridden by the corresponding content.

<!--EXAMPLE(labels)-->
````typ
#raw-render(
  ```
  digraph {
    rankdir=LR
    node[shape=circle]
    Hmm -> a_0
    Hmm -> big
    a_0 -> "a'" -> big [style="dashed"]
    big -> sum
  }
  ```,
  labels: (:
    big: [_some_#text(2em)[ big ]*text*],
    sum: $ sum_(i=0)^n 1/i $,
  ),
)
````
![labels](https://raw.githubusercontent.com/Robotechnic/diagraph/main/images/labels1.png)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Changelog

### 0.2.3

- Updated to typst 0.11.0
- Added support for `fontcolor`, `fontsize` and `fontname` nodes attributes
- Diagraph now uses a protocol generator to generate the wasm interface

### 0.2.2

- Fix an alignment issue
- Added a better mathematic formula recognition for node labels

### 0.2.1

- Added support for relative lenghts in the `width` and `height` arguments
- Fix various bugs

### 0.2.0

- Node labels are now handled by Typst

### 0.1.2

- Graphs are now scaled to make the graph text size match the document text size

### 0.1.1

- Remove the `raw-render-rule` show rule because it doesn't allow use of custom font and the `render` / `raw-render` functions are more flexible
- Add the `background` parameter to the `render` and `raw-render` typst functions and default it to `transparent` instead of `white`
- Add center attribute to draw graph in the center of the svg in the `render` c function

### 0.1.0

Initial working version
