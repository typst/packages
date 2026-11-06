# Tiago

[Tiago](https://github.com/OverflowCat/tiago) is a Typst package for rendering diagrams with [Diago](https://github.com/moonbit-community/diago), a D2-compatible diagram engine implemented in [MoonBit](https://www.moonbitlang.com/). It can render a D2 diagram to SVG, ASCII or Unicode text. 

The typst package removed embedded fonts and font metrics data from the WASM, and uses release build with `--strip` tag compared to diago's WASM demo, which reduces its binary size from ~21 MiB to ~5 MiB unzipped.

## Examples

<table>
  <tr>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/architecture.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/architecture.svg" alt="Architecture diagram" height="300px"></a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/c4.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/c4.svg" alt="C4 diagram" height="280px"></a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/containers.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/containers.svg" alt="Containers diagram" height="300px"></a></td>
  </tr>
  <tr>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/architecture.typ">architecture.typ</a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/c4.typ">c4.typ</a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/containers.typ">containers.typ</a></td>
  </tr>
  <tr>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/isomorphic.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/isomorphic.svg" alt="Isomorphic build pipeline diagram" height="280px"></a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/sequence.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/sequence.svg" alt="Sequence diagram" height="300px"></a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/sql_tables.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/sql_tables.svg" alt="SQL tables diagram" height="280px"></a></td>
  </tr>
  <tr>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/isomorphic.typ">isomorphic.typ</a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/sequence.typ">sequence.typ</a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/sql_tables.typ">sql_tables.typ</a></td>
  </tr>
  <tr>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/styles.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/styles.svg" alt="Styles diagram" height="280px"></a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/markdown.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/markdown.svg" alt="Markdown diagram" height="260px"></a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/security.typ"><img src="https://github.com/OverflowCat/tiago/raw/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/security.svg" alt="Security diagram" height="260px"></a></td>
  </tr>
  <tr>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/styles.typ">styles.typ</a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/markdown.typ">markdown.typ</a></td>
    <td><a href="https://github.com/OverflowCat/tiago/blob/9439932454e3b5283ca403679fa8ab84999460ee/typst-package/demo/security.typ">security.typ</a></td>
  </tr>
</table>

## Installation

```typst
#import "@preview/tiago:0.1.0": *
```

## API

### `render(source, engine: none, ..args)`

Renders diagram source to an SVG-backed Typst image. Extra arguments are forwarded to Typst's `image(...)`, so you can pass values like `width`, `height`, or `alt`.

```typst
#render(
  "a -> b: hello",
  // engine: "elk",
  // width: 220pt,
  // height: ...
)
```

### `render-svg(source, engine: none)`

Renders diagram source to raw SVG bytes.

```typst
#let svg = render-svg("a -> b")
```

### `render-ascii(source)`

Renders diagram source to ASCII text.

```typst
#raw(render-ascii("a -> b"))
```

### `render-unicode(source)`

Renders diagram source to Unicode box-drawing text.

```typst
#raw(render-unicode("a -> b"))
```

## Layout Engines

`engine` is optional. When omitted, the package uses Diago's default layout engine.

Supported engine names:

- `dagre`
- `elk`
- `railway`

## Example

```typst
#import "@preview/tiago:0.1.0": *

= Tiago Example

#let source = ```
server: Web Server
database: Database {
  shape: cylinder
}
cache: Cache

server -> database: queries
server -> cache: reads
cache -> database: fallback
```.text

== SVG

#render(
  source,
  engine: "elk",
  width: 300pt,
)

== ASCII

#raw(render-ascii(source))

== Unicode

#raw(render-unicode(source))
```

For a sample document, see `example.typ`.

## Limitations

* Image paths in D2 diagrams are linked images. Path to linked images are relative to the `--root` directory. Linked SVG images are not supported yet.
* Some features are not properly supported. Switching rendering engines may help.

## License

Apache-2.0. See `LICENSE`.
