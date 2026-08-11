#let aasvg-wasm = plugin("./typst_aasvg.wasm")

#let aasvg(
  str,
  backdrop: false,
  disable-text: false,
  spaces: 2,
  stretch: false,
  ..args,
) = {
  image(
    aasvg-wasm.render_with_options(
      bytes(str),
      cbor.encode((backdrop: backdrop, disable_text: disable-text, spaces: spaces, stretch: stretch)),
    ),
    format: "svg",
    ..args,
  )
}
