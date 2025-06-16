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

### Advanced usage

Check the [manual](https://raw.githubusercontent.com/Robotechnic/diagraph/main/doc/manual.pdf) for more information about the plugin.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Changelog

### 0.3.4

- Added an `alt` parameter to the `render` and `raw-render` functions to specify an alternative text for the image
- Fixed a bug with landscape mode not being applied correctly


### 0.3.3

- Fixed a bug with math-mode in xlabel being ignored and set to the label math mode
- Added a global math mode

### 0.3.2

- Fixed a bug in math detection
- Added a math mode to change the math detection behavior
- Upgraded the typst version to 0.13.0
- Added a stretch mode to change the graph stretching behavior from `stretch` to `contain`

### 0.3.1

- Updated graphviz version to 12.2.1
- Fixed a bug with the font being incorrectly set
- Added adjacency lists to the graph rendering possibilities

### 0.3.0

- Added support for edge labels
- Added a manual generated with Typst
- Updated graphviz version
- Fix an error in math mode detection

### 0.2.5

- If the shape is point, the label isn't displayed
- Now a minimum size is not enforced if the node label is empty
- Added support for font alternatives

### 0.2.4

- Added support for xlabels which are now rendered by Typst
- Added support for cluster labels which are now rendered by Typst
- Fix a margin problem with the clusters

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
