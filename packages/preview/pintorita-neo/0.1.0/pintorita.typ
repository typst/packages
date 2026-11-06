#let pintora-wasm = plugin("pintora.wasm")

// Helper function that controls the svg width by manipulating the svg string.
// Can either have the scale factor set or the width of the svg which simply passes the
// width through.
#let getNewWidth(svg-output, factor, width) = {
  if (factor == none) {
    return width
  }

  if (width != auto) {
    panic("invalid arguments. factor and width cannot both be set.")
  }

  // This method depends on the consistency of the generated svg
  // since it uses simple regexes to get the pre-rendered width
  let svg-width = svg-output.find(regex("width=\"(\d+)")).find(regex("\d+"))
  return int(svg-width) * factor * 1pt
}

// Renders image based on the source pintora string.
#let render(
  src,
  factor: none,
  style: "larkLight",
  font: "Arial",
  width: auto,
  ..args,
) = {
  let svg-output = str(pintora-wasm.render(bytes(src), bytes(style), bytes(font)))

  let newWidth = getNewWidth(svg-output, factor, width)

  image(
    bytes(svg-output),
    width: newWidth,
    ..args,
  )
}

// Produces svg from the pintora source using the requested style and font.
#let render-svg(
  src,
  style: "larkLight",
  font: "Arial",
) = {
  // style: ["default", "larkLight", "larkDark", "dark"]
  let svg-output = str(pintora-wasm.render(bytes(src), bytes(style), bytes(font)))

  svg-output
}
