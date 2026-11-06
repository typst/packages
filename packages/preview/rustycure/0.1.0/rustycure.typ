#let qr-plugin = plugin("rustycure.wasm")

#let qr-svg(
    data,
    quiet-zone: true,
    dark-color: "#000000",
    light-color: "#ffffff"
) = {
  quiet-zone = if quiet-zone {(1,)} else {(0,)}
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
    dark-color: "#000000",
    light-color: "#ffffff",
    width: auto,
    height: auto,
    alt: auto,
    fit: "cover"
) = {
  if type(alt) == "auto" {
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
