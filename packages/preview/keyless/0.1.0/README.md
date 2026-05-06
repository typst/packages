# Keyless

Keyless is a Typst package for keying colors out of raster images and converting them into transparent pixels.

It provides a simple interface for common tasks such as removing a white background, cutting out a green screen, or making a scanned image blend cleanly into the page. Keyless is designed for reproducible documents: every threshold, softness value, color space, and output option can be written directly in Typst source.

## Usage

For the local Tyler install:

```typst
#import "@local/keyless:0.1.0": key-out, key-out-bytes
```

After publishing to Typst Universe:

```typst
#import "@preview/keyless:0.1.0": key-out, key-out-bytes
```

Remove a white background and place the result like a normal Typst image:

```typst
#import "@local/keyless:0.1.0": key-out

#let logo = read("logo.png", encoding: none)

#key-out(
  logo,
  color: white,
  tolerance: 10%,
  softness: 2%,
  width: 5cm,
  alt: "Logo with white background removed",
)
```

Use `key-out-bytes` when you want the transformed PNG bytes instead of image content:

```typst
#let keyed = key-out-bytes(
  logo,
  color: rgb("#ffffff"),
  tolerance: 12%,
  softness: 3%,
)

#image(keyed, width: 80%)
```

## API

```typst
#key-out(
  source,
  color: white,
  tolerance: 0%,
  softness: 0%,
  space: "srgb",
  premultiply: false,
  format: auto,
  ..args,
)
```

`source` is image bytes, usually from `read("image.png", encoding: none)`. Extra arguments are forwarded to Typst's built-in `image`, including `width`, `height`, `alt`, `fit`, and `scaling`.

`key-out-bytes` accepts the same image-processing parameters and returns PNG bytes.

## Behavior

Keyless currently computes normalized Euclidean distance in sRGB:

```text
distance <= tolerance
  alpha = 0

distance >= tolerance + softness
  alpha = original alpha

otherwise
  alpha fades smoothly between 0 and original alpha
```

The first release supports PNG, JPEG, GIF, and WebP input and always emits PNG output with an alpha channel.

## Compatibility

Keyless requires Typst 0.8.0 or newer. This is the first Typst release with WASM plugin support.

## Building

```sh
rustup target add wasm32-unknown-unknown
cargo build --release --target wasm32-unknown-unknown
cp target/wasm32-unknown-unknown/release/keyless_plugin.wasm src/plugin.wasm
```
