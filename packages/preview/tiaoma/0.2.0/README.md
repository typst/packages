# tiaoma

[tiaoma(条码)](https://github.com/enter-tainer/zint-wasi) is a barcode generator for typst. It compiles [zint](https://github.com/zint/zint) to wasm and use it to generate barcode. It support nearly all common barcode types. For a complete list of supported barcode types, see [zint's documentation](https://zint.org.uk/).

## Example

```typ
#import "@preview/tiaoma:0.2.0"
#set page(width: auto, height: auto)

= tiáo mǎ

#tiaoma.ean("1234567890128")
```

![example](./example.svg)

## Manual

Please refer to [manual](./manual.pdf) for more details.

## Comparison

There are multiple barcode/qrcode libraries for typst such as

1. https://github.com/jneug/typst-codetastic
2. https://github.com/Midbin/cades

Here is a comparison of them.

Pros of this package:

1. Support more barcode types
2. Might be faster because the zint is written in C and compiled to wasm. These libraries are written in typst and javascript.

Cons of this package:

1. Doesn't provide enough customization options although it can be improved in the future. 
