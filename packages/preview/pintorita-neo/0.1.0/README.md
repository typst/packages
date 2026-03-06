# Pintorita Neo - Pintora plugin for Typst

[Pintora](https://pintorajs.vercel.app/)

This is a fork of [pintorita](https://typst.app/universe/package/pintorita),
updated to use `@pintora/target-wintercg` and optimized for current Typst
versions.

Typst package for drawing diagrams from markup using Pintora.

## Why this fork?

This project started as a simple attempt to speed up
[pintorita](https://typst.app/universe/package/pintorita) with some
pre-compilation. But as I dug deeper, I realized the engine underneath (`jogs`)
was actually re-parsing the Pintora JS code every time a diagram was rendered.
That’s a lot of unnecessary work!

To fix it properly, I had to give the project a bit of a "structural
makeover"—moving the heavy lifting to the build stage so the code is compiled
once into bytecode. I decided to fork the project to make these fundamental
changes possible, so now you can enjoy much faster and more efficient diagram
rendering in Typst.

## Limitations

Because this plugin runs a JavaScript engine (`quickjs`) inside a WebAssembly
environment, it won’t be quite as snappy as a pure native rendering engine.

## Features

Supports the following diagram types:

- Sequence Diagram
- Entity Relationship Diagram
- Component Diagram
- Activity Diagram
- Mind Map
- Gantt Diagram
- DOT Diagram

## Usage

````typ
#import "@preview/pintorita-neo:0.1.0"

// Basic usage
#pintorita-neo.render("
mindmap
+ Pintora
++ Sequence Diagram
++ Gantt Diagram
")

// Show rule for raw blocks
#show raw.where(lang: "pintora"): it => pintorita-neo.render(it.text)

```pintora
mindmap
+ UML Diagrams
++ Behavior Diagrams
+++ Sequence Diagram
++ Structural Diagrams
+++ Component Diagram
````

## Documentation

### `render`

Render a Pintora string to an image.

#### Arguments

- `src`: `str` - Pintora source string.
- `factor`: `float` - Scale factor for the output SVG. For example,
  `factor: 0.5` will scale the image down by half.
- `style`: `str` - Diagram style. Options: `default`, `larkLight`, `larkDark`,
  `dark`. Default is `larkLight`.
- `font`: `str` - Font family. Default is `Arial`.
- `width`: `auto` or `length` - Width of the image. Default is `auto`.
- `..args`: Other arguments are passed to `image.decode` (e.g., `alt`,
  `caption`).

#### Returns

The image as `content`.

### `render-svg`

Render a Pintora string to an SVG string.

#### Arguments

- `src`: `str` - Pintora source string.
- `style`: `str` - Diagram style. Options: `default`, `larkLight`, `larkDark`,
  `dark`. Default is `larkLight`.
- `font`: `str` - Font family. Default is `Arial`.

#### Returns

The SVG code as a `str`.

## License

MIT

This plugin bundled the `@pintora/target-wintercg` package, which is licensed
under [MIT](https://github.com/hikerpig/pintora/blob/master/LICENSE.txt).

Some code is copied from
[pintorita](https://github.com/taylorh140/typst-pintora), which is licensed
under
[MIT](https://github.com/taylorh140/typst-pintora/blob/main/package/LICENSE).
