# Typst-Handy-Dora

Handy Dora is a wrapper of [riichi-hand-rs](https://github.com/m4tx/riichi-hand-rs) in Typst, powered by wasm.

## Usage

Start with `#import "@preview/handy-dora:0.1.0": mahjong`.

Parameters:

- `hand`: A string of tiles in the hand.
- `tile-set`: The tile set to use. Default is `"yellow-fluffy-stuff"`. `"red-fluffy-stuff"`, `"black-fluffy-stuff"`, `"martin-persson"` are also available.
- `tile-gap`: The gap between tiles. Default is `0.0`.
- `group-gap`: The gap between groups. Default is `1.0 / 3.0`.
- `..args`: Other arguments to pass to the `image.decode()` fuction.

## Credits

- [riichi-hand-rs](https://github.com/m4tx/riichi-hand-rs)
