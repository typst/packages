# jxl-loader for Typst

`jxl-loader` is a [Typst](https://typst.app/) WASM plugin for loading [JPEG XL](https://jpeg.org/jpegxl/) images in Typst documents.

jxl-loader uses [jxl-rs](https://github.com/libjxl/jxl-rs) to decode JPEG XL images and [wasm-minimal-protocol](https://github.com/astrale-sharp/wasm-minimal-protocol) to expose the decoder to Typst.

## Usage

Import `image-jxl` from the jxl-loader package:

```typst
#import "@preview/jxl-loader:0.3.0": image-jxl
```

`image-jxl()` is a wrapper to the native [`image()`](https://typst.app/docs/reference/visualize/image/) function in Typst. It accepts the same arguments (i.e., `width`, `alt`, `fit`, etc.).

### Load from a path

With Typst 0.15.0 or later, you can pass a `path` directly to `image-jxl`:

```typst
#import "@preview/jxl-loader:0.3.0": image-jxl

#image-jxl(path("path/to/image.jxl"))
```

### Load from binary data

You can also read the image as binary data and pass it to `image-jxl`:

```typst
#import "@preview/jxl-loader:0.3.0": image-jxl

#let image-data = read("path/to/image.jxl", encoding: none)

#image-jxl(image-data)
```

## Compatibility

### Supported

- JPEG XL images.
- Animated JPEG XL images, with only the first frame rendered due to a Typst limitation.

### Limitations

- CMYK JPEG XL images are not currently supported.
- Animated JPEG XL images are limited to their first frame.

## Building

A working [Rust toolchain](https://www.rust-lang.org/) is required to build the plugin.

First, install the WebAssembly target:

```sh
rustup target add wasm32-unknown-unknown
```

Build the plugin in release mode:

```sh
cargo build --release --target wasm32-unknown-unknown
```

The resulting WASM binary will be located at:

```text
target/wasm32-unknown-unknown/release/jxl_loader.wasm
```

### Optimizing the WASM binary

jxl-loader can be optimized with [`wasm-opt`](https://github.com/WebAssembly/binaryen) from [Binaryen](https://github.com/WebAssembly/binaryen):

```sh
wasm-opt \
  ./target/wasm32-unknown-unknown/release/jxl_loader.wasm \
  --enable-simd \
  --enable-bulk-memory \
  --all-features \
  -O4 \
  -o typst/jxl_loader_opt.wasm
```

### Using `just`

If you have [`just`](https://github.com/casey/just) installed, you can use the provided recipe:

```sh
just makeopt
```

## How It Works

jxl-loader runs the JPEG XL decoder as a WebAssembly plugin inside Typst.

The plugin receives JPEG XL image data, decodes it using `jxl-rs`, and returns the decoded image data to Typst.

The main components are.

- **jxl-rs** for JPEG XL decoding.
- **wasm-minimal-protocol** for communication between the WASM plugin and Typst.

## Credits

- [`jxl-rs`](https://github.com/libjxl/jxl-rs): JPEG XL decoder and test images.
- [`wasm-minimal-protocol`](https://github.com/astrale-sharp/wasm-minimal-protocol)
- [`grayness`](https://github.com/nineff/grayness) for inspiration and Typst utility functions.

## License

See the [LICENSE](LICENSE) file for license information.
