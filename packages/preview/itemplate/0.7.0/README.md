# itemplate

`itemplate` is a Typst template for generating interactive HTML documents. It compiles Typst markup into a self-contained HTML file with a responsive layout, featuring a sidebar table of contents.

The template comes with built-in support for:
- **Three.js** for embedding 3D scenes (e.g. the orbital cube demo).

> This is an amateur project, please use with caution.

# Usage

```typst
// test.typ
#import "@preview/itemplate:0.7.0": *
#show: itemplate.with(doc-title: "test")

= #lorem(3)

#lorem(20)

== #lorem(3)

#lorem(20)

= #lorem(3)

#lorem(20)

== #lorem(3)

#lorem(20)

#context if (target() == "html") {
  html.elem("div", attrs: (
    style: "background: white; margin-top: 50px; width: 100%; height: 30vh",
    id: "three-orbital-cube",
  ))[]

  html.script(
    type: "module",
    src: "https://unpkg.com/@hexiongwu1995/itemplate/examples/itemplate/three-orbital-cube.js",
  )
}
```

# Compile to HTML

## use Tinymist Typst plugin in VS Code

- install Tinymist Typst plugin in VS Code
- append the following settings to your `.vscode/settings.json` file:

```
"tinymist.typstExtraArgs": ["--features=html", "--features=bundle"],
```
- The exported HTML file will be placed in the same directory as the test.typ file

## use typst cli

- install typst cli on your computer
- compile the test.typ to html in the command line:

```powershell
cd path/to/your/test.typ
typst compile test.typ --features html --format html
```

- or watch test.typ and auto-compile it to HTML in the command line:

```powershell
cd path/to/your/test.typ
typst watch test.typ --features html --format html
```

- The exported HTML file will be placed in the same directory as the test.typ file

<img src="./assets/test.png" alt="output of the above code" width="900" />
