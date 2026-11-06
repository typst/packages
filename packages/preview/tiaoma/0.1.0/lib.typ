#let zint-wasm = plugin("./zint_typst_plugin.wasm")

#let ean(data, ..args) = image.decode(zint-wasm.ean_gen(bytes(data)), format: "svg", ..args)

#let code128(data, ..args) = image.decode(zint-wasm.code128_gen(bytes(data)), format: "svg", ..args)

#let code39(data, ..args) = image.decode(zint-wasm.code39_gen(bytes(data)), format: "svg", ..args)

#let upca(data, ..args) = image.decode(zint-wasm.upca_gen(bytes(data)), format: "svg", ..args)

#let data-matrix(data, ..args) = image.decode(zint-wasm.data_matrix_gen(bytes(data)), format: "svg", ..args)

#let qrcode(data, ..args) = image.decode(zint-wasm.qrcode_gen(bytes(data)), format: "svg", ..args)

#let channel(data, ..args) = image.decode(zint-wasm.channel_gen(bytes(data)), format: "svg", ..args)

#let msi-plessey(data, ..args) = image.decode(zint-wasm.msi_plessey_gen(bytes(data)), format: "svg", ..args)

#let micro-pdf417(data, ..args) = image.decode(zint-wasm.micro_pdf417_gen(bytes(data)), format: "svg", ..args)

#let aztec(data, ..args) = image.decode(zint-wasm.aztec_gen(bytes(data)), format: "svg", ..args)

#let code16k(data, ..args) = image.decode(zint-wasm.code16k_gen(bytes(data)), format: "svg", ..args)

#let maxicode(data, ..args) = image.decode(zint-wasm.maxicode_gen(bytes(data)), format: "svg", ..args)

#let planet(data, ..args) = image.decode(zint-wasm.planet_gen(bytes(data)), format: "svg", ..args)

#let barcode(data, type, ..args) = image.decode(
  zint-wasm.gen_with_options(
    cbor.encode(
      (symbology: (type: type),)
    ), bytes(data)
  ),
  format: "svg",
..args)
