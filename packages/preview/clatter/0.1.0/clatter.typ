#let clatter-wasm = plugin("./clatter.wasm")

#let pdf417(text, width: auto, height: auto, direction: auto) = {
  let args = arguments(bytes("0"), bytes("0")) // horizontal by default
  if direction != auto or (width != auto and height != auto) {
    if direction == "vertical" or (direction != "horizontal" and width < height) {
      args = arguments(bytes("0"), bytes("1")) // vertical: w < h
    }
    else {
      args = arguments(bytes("1"), bytes("0")) // horizontal: w > h
    } 
  }
  image.decode(clatter-wasm.pdf417(bytes(text), ..args), format: "svg", width: width, height: height, fit: "contain")
}
