#let qr-plugin = plugin("rustycure.wasm")

#let qr-svg(
    data,
    quiet-zone: true,
    dark-color: black,
    light-color: white
) = {
  quiet-zone = if quiet-zone {(1,)} else {(0,)}

  if type(dark-color) == color {
    dark-color = dark-color.to-hex()
  }

  if type(light-color) == color {
    light-color = light-color.to-hex()
  }

  qr-plugin.qrcode(
    bytes(data),
    bytes(quiet-zone),
    bytes(dark-color),
    bytes(light-color)
  )
}

#let qr-code(
    data,
    quiet-zone: true,
    dark-color: black,
    light-color: white,
    width: auto,
    height: auto,
    alt: auto,
    fit: "cover"
) = {
  if alt == auto {
    alt = str(data)
  }
  image(
    qr-svg(
      data,
      quiet-zone: quiet-zone,
      dark-color: dark-color,
      light-color: light-color
    ),
    width: width,
    height: height,
    alt: alt,
    fit: fit
  )
}
