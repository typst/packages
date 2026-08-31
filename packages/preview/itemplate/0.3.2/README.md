# itemplate

This package automatically adds an HTML template when exporting Typst documents to HTML. The exported HTML uses CSS and JS resources from a package of the same name on npm, with support for Three.js.

# Usage

```typst
#import "@preview/itemplate: 0.3.2": *
#show: contents => itemplate(title: "itemplate", contents)

= #lorem(3)

#lorem(10)

== #lorem(3)

#lorem(10)

= #lorem(3)

#lorem(10)

== #lorem(3)

#lorem(10)

#html.elem("div", attrs: (
  style: "background: white; margin-top: 50px; width: 100%; height: 30vh",
  id: "three-orbital-cube",
))[]
#html.script(
  type: "module",
  src: "https://unpkg.com/@hexiongwu1995/itemplate@0.3.2/examples/itemplate/three-orbital-cube.js",
)

```

<img src="./assets/image.png" alt="itemplate" width="900" />