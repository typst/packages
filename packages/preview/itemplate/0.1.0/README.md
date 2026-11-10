# itemplate

`itemplate` is a Typst template for generating interactive HTML documents. It compiles Typst markup into a self-contained HTML bundle with a responsive layout, featuring a sidebar table of contents, a header with navigation actions, and a main article area.

The template comes with built-in support for:

- **MathJax** for rendering mathematical formulas (AsciiMath / MathML).
- **Three.js** for embedding 3D scenes (e.g. the orbital cube demo).
- **Interactive UI** such as title numbering, expand/collapse of sections, and home / GitHub / print / paintbrush shortcuts.
- **Custom assets** via the bundled `style.css` and `script.js`.

> This is an amateur project, please use with caution.

# Usage

```typst
// example.typ
#import "@preview/itemplate:0.1.0": *
#show: contents => itemplate(doc-title: "example", doc-author: "Author", contents)

= #lorem(3)

#lorem(20)

== #lorem(3)

#lorem(20)

= #lorem(3)

#lorem(20)

== #lorem(3)

#lorem(20)

#html.elem("div", attrs: (
  style: "background: white; margin-top: 50px; width: 100%; height: 30vh",
  id: "three-orbital-cube",
))[]

#html.script(
  type: "module",
  src: "https://unpkg.com/@hexiongwu1995/itemplate/examples/itemplate/three-orbital-cube.js",
)

```

# Compile to Bundle

- use tinymist to convert the document to bundle in VS Code.

- or compile the example.typ to bundle in the command line:

```powershell
cd path/to/your/example.typ
typst compile example.typ --format bundle
```
- or watch example.typ and auto-compile it to bundle in the command line:

```powershell
cd path/to/your/example.typ
typst watch example.typ --format bundle
```


<img src="./assets/example.png" alt="output of the above code" width="900" />