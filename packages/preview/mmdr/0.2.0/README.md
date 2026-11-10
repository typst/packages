# typst-mmdr

A [Typst](https://typst.app) plugin to render [Mermaid](https://mermaid.js.org)
diagrams using
[mermaid-rs-renderer](https://github.com/1jehuang/mermaid-rs-renderer).

## Limitation

This doesn't guarantee to support all features of
[Mermaid JS](https://mermaid.js.org/), as
[mermaid-rs-renderer](https://github.com/1jehuang/mermaid-rs-renderer) currently
does not support all of the features.

Any problem with the render of the diagram must be reported to
[mermaid-rs-renderer](https://github.com/1jehuang/mermaid-rs-renderer) instead
of here.

## Usage

Import the package and use the `mermaid` function:

```typst
#import "@preview/mmdr:0.2.0": mermaid

#mermaid("graph TD; A-->B;")
```

More examples can be found
[here](https://github.com/HSGamer/typst-mmdr/blob/master/test.typ)

### Options

You can customize the appearance using `base-theme`, `theme`, and `layout`
parameters.

- **`base-theme`**: Wraps the base styling. Can be `"modern"` (default) or
  `"default"`.
- **`theme`**: A dictionary of theme overrides. Check
  [here](https://github.com/1jehuang/mermaid-rs-renderer/blob/6e75a10eeaf61a83d267e9ea021bac257411f0d8/src/theme.rs#L36-L78)
  for the list of possible options.
- **`layout`**: A dictionary of layout configuration overrides. Check
  [here](https://github.com/1jehuang/mermaid-rs-renderer/blob/6e75a10eeaf61a83d267e9ea021bac257411f0d8/src/config.rs#L739-L753)
  for the list of possible options.

```typst
#mermaid(
  "graph TD; A-->B;",
  base-theme: "default",
  theme: (
    background: "#f4f4f4",
    primary_color: "#ff0000",
  ),
  layout: (
    node_spacing: 50,
  ),
)
```

### Raw SVG

If you need the raw SVG string instead of a Typst image, use `mermaid-svg`:

```typst
#import "@preview/mmdr:0.2.0": mermaid-svg

#let svg-code = mermaid-svg("graph TD; A-->B;")
```

## Build from Source

To build the plugin and prepare it for distribution:

1. Install Rust and Cargo.
2. Install the `wasm32-unknown-unknown` target:
   ```sh
   rustup target add wasm32-unknown-unknown
   ```
3. Run the build script:
   ```sh
   ./build.sh
   ```

The build artifacts will be available in `dist/`.

## License

MIT

The distribution contains the WASM build of
[mermaid-rs-renderer](https://github.com/1jehuang/mermaid-rs-renderer), which is
licensed under the
[MIT license](https://github.com/1jehuang/mermaid-rs-renderer/blob/master/LICENSE).
