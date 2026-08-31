# iTemplate

This package automatically adds an HTML template when exporting Typst documents to HTML. The exported HTML uses CSS and JS resources from a package of the same name on npm, with support for Three.js.

# Usage

```typst
#import "@preview/iTemplate: 0.3.0": *
#show: contents => itemplate(title: "iTemplate", contents)

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
  src: "https://unpkg.com/@hexiongwu1995/itemplate@0.3.0/examples/theoframe/three-orbital-cube.js",
)

```

<img src="./images/image.png" alt="iTemplate" width="900" />