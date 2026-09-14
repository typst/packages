# typst-aasvg

A Typst package for converting ASCII art diagrams into SVG, powered by [aasvg-rs](https://github.com/bearcove/aasvg-rs).

## Usage

### `aasvg(str, ...)`

**Parameters:**

- `str` (string, required) — The ASCII art diagram as a string
- `backdrop` (boolean, default: `false`) — Enable backdrop
- `disable-text` (boolean, default: `false`) — Disable text rendering
- `spaces` (integer, default: `2`) — Number of spaces for tab replacement
- `stretch` (boolean, default: `false`) — Stretch to fit
- `..args` — Additional arguments passed to `image()`

```typst
#import "@preview/aa-draw:0.1.0": aasvg

#aasvg("A --> B")
```

## Example

See [example.typ](https://github.com/chillcicada/typst-aasvg/blob/v0.1.0/package/example.typ) and [example.pdf](https://github.com/chillcicada/typst-aasvg/blob/v0.1.0/package/example.pdf).

## Build

```bash
cargo build --release --target wasm32-unknown-unknown
```

The WASM artifact will be output to `target/wasm32-unknown-unknown/release/typst_aasvg.wasm`.

## License

[MIT](LICENSE)
