#import "@preview/jogs:0.2.3": compile-js, call-js-function

#let pintora-src = read("./pintora.js")
#let pintora-bytecode = compile-js(pintora-src)

// Helper function that sets the controls the svg width by minipulating the svg string.
// Can either have the scale factor set or the width of the svg which simply passes the 
// width through.
#let getNewWidth(svg-output, factor, width) = {
  if (factor == none) {
    return width
  }

  if (width != auto) {
    panic("invalid arguments. factor and width cannot both be set.")
  }

  //This method depends on the consitency of the generated svg
  //since it uses simple regexes to get the pre-rendered width 
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
  let named-args = args.named()

  let svg-output = call-js-function(pintora-bytecode, "PintoraRender", src, style, font)

  let newWidth = getNewWidth(svg-output, factor, width)

  image.decode(
    svg-output,
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
  let svg-output = call-js-function(pintora-bytecode, "PintoraRender", src, style, font)

  svg-output
}
