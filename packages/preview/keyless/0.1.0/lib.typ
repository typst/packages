#let plugin = plugin("plugin.wasm")

#let _as-bytes(value) = bytes(repr(value))

#let _color-bytes(color) = bytes(color.to-hex())

#let key-out-bytes(
  source,
  color: white,
  tolerance: 0%,
  softness: 0%,
  space: "srgb",
  premultiply: false,
  format: auto,
) = {
  plugin.key_out(
    source,
    _color-bytes(color),
    _as-bytes(tolerance),
    _as-bytes(softness),
    bytes(space),
    _as-bytes(premultiply),
    _as-bytes(format),
  )
}

#let key-out(
  source,
  color: white,
  tolerance: 0%,
  softness: 0%,
  space: "srgb",
  premultiply: false,
  format: auto,
  ..args,
) = {
  image(
    key-out-bytes(
      source,
      color: color,
      tolerance: tolerance,
      softness: softness,
      space: space,
      premultiply: premultiply,
      format: format,
    ),
    ..args,
  )
}
