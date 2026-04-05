#import "@preview/jogs:0.2.0": compile-js, call-js-function

#let qrcode-src = read("./qrcode.js")
#let qrcode-bytecode = compile-js(qrcode-src)

#let qr-code(
  content, 
  width: auto, 
  height: auto, 
  color: black, 
  background: white,
  error-correction: "M",
) = {
  assert(
    error-correction == "L" or 
    error-correction == "M" or 
    error-correction == "Q" or 
    error-correction == "H", 
    message: "Error correction code must be one of 'L', 'M', 'Q', 'H'")
  let result = call-js-function(qrcode-bytecode, "qrcode", content, color.to-hex(), background.to-hex(), error-correction)
  return image.decode(result, width: width, height: height)
}