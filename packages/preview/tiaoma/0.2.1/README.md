# tiaoma

[tiaoma(条码)](https://github.com/enter-tainer/zint-wasi) is a barcode generator for typst. It compiles [zint](https://github.com/zint/zint) to wasm and use it to generate barcode. It support nearly all common barcode types. For a complete list of supported barcode types, see [zint's documentation](https://zint.org.uk/):

- Australia Post
  - Standard Customer
  - Reply Paid
  - Routing
  - Redirection
- Aztec Code
- Aztec Runes
- Channel Code
- Codabar
- Codablock F
- Code 11
- Code 128 with automatic subset switching
- Code 16k
- Code 2 of 5 variants:
  - Matrix 2 of 5
  - Industrial 2 of 5
  - IATA 2 of 5
  - Datalogic 2 of 5
  - Interleaved 2 of 5
  - ITF-14
- Deutsche Post Leitcode
- Deutsche Post Identcode
- Code 32 (Italian pharmacode)
- Code 3 of 9 (Code 39)
- Code 3 of 9 Extended (Code 39 Extended)
- Code 49
- Code 93
- Code One
- Data Matrix ECC200
- DotCode
- Dutch Post KIX Code
- EAN variants:
  - EAN-13
  - EAN-8
- Grid Matrix
- GS1 DataBar variants:
  - GS1 DataBar
  - GS1 DataBar Stacked
  - GS1 DataBar Stacked Omnidirectional
  - GS1 DataBar Expanded
  - GS1 DataBar Expanded Stacked
  - GS1 DataBar Limited
- Han Xin
- Japan Post
- Korea Post
- LOGMARS
- MaxiCode
- MSI (Modified Plessey)
- PDF417 variants:
  - PDF417 Truncated
  - PDF417
  - Micro PDF417
- Pharmacode
- Pharmacode Two-Track
- Pharmazentralnummer
- POSTNET / PLANET
- QR Code
- rMQR
- Royal Mail 4-State (RM4SCC)
- Royal Mail 4-State Mailmark
- Telepen
- UPC variants:
  - UPC-A
  - UPC-E
- UPNQR
- USPS OneCode (Intelligent Mail)

## Example

```typ
#import "@preview/tiaoma:0.2.1"
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
