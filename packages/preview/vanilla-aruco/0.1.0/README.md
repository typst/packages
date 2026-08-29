# vanilla-aruco

Generate compact, printable ArUco markers as native Typst vector graphics.
The package ships a Rust/WASM backend for dictionary lookup and boundary-path
optimization, while the public Typst API stays deliberately small:

> Development note: This project was developed with substantial assistance
> from LLMs. Please review and validate the implementation before relying on
> it in production or safety-critical workflows.

```typst
#import "@preview/vanilla-aruco:0.1.0": aruco

#aruco(23, size: 4cm)
#aruco(42, dictionary: "DICT_6X6_250", size: 4cm, rotation: 90)
```

![A black-and-white vanilla-aruco showcase](https://raw.githubusercontent.com/Enter-tainer/vanilla-aruco/main/examples/showcase.svg)

## Features

- Native vector output through `curve`, with no raster intermediate.
- Rust/WASM implementation of the exposed-edge graph and Euler-tour path optimizer.
- CBOR communication between Typst and Rust.
- One public entry point: `aruco`.
- Configurable size, quiet zone, rotation, foreground, and background.

## Predefined dictionaries

The built-in codewords follow OpenCV's predefined ArUco dictionaries.

```typst
#import "@preview/vanilla-aruco:0.1.0": aruco

#aruco(7, dictionary: "DICT_4X4_50")
#aruco(7, dictionary: "DICT_5X5_100")
#aruco(7, dictionary: "DICT_6X6_250")
#aruco(7, dictionary: "DICT_7X7_1000")
#aruco(7, dictionary: "DICT_ARUCO_ORIGINAL")
#aruco(7, dictionary: "DICT_ARUCO_MIP_36h12")
```

Supported families are `DICT_4X4_{50,100,250,1000}`,
`DICT_5X5_{50,100,250,1000}`, `DICT_6X6_{50,100,250,1000}`,
`DICT_7X7_{50,100,250,1000}`, `DICT_ARUCO_ORIGINAL`, and
`DICT_ARUCO_MIP_36h12`.

## More demos

The [basic example](examples/basic.typ) shows the API and rotation. The
[showcase](examples/showcase.typ) uses the same generator in a clean,
black-and-white layout. For print and camera detection, keep the default black
foreground.

## How it works

The Rust backend turns exposed sides of black modules into an undirected edge
graph. It follows edges with a straight/left/right preference, splices branch
walks using Hierholzer's algorithm, and compresses collinear runs into
`Horizontal` and `Vertical` segments. Typst converts those segments to a single
even-odd-filled `curve`.

The package uses `curve`, introduced in Typst 0.13, and passes CBOR bytes
directly to the top-level `cbor` function. Typst 0.13 added byte input for data
loading functions; Typst 0.15 removed the older `.decode` variants. This
package requires Typst 0.13.0 or newer.

## Development

```sh
cargo run --locked --manifest-path xtask/Cargo.toml -- build-wasm
cargo fmt --all -- --check
cargo test --locked
cargo clippy --locked --all-targets --all-features -- -D warnings
typst compile --root . examples/basic.typ /tmp/vanilla-aruco-basic.pdf
typst compile --root . examples/showcase.typ /tmp/vanilla-aruco-showcase.pdf
```

The CI workflow runs these checks on pushes and pull requests. Release and
registry publishing are intentionally manual.

The build task lives in the dependency-free Rust `xtask` binary. It performs
the file and process operations through Rust's standard library, keeping the
development command consistent across Windows, macOS, and Linux.

## License

MIT. The predefined dictionary data is attributed in [NOTICE](NOTICE).
