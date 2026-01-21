#import "@preview/jogs:0.2.0": compile-js, call-js-function

#let qrcode-src = read("./qrcode.js")
#let qrcode-bytecode = compile-js(qrcode-src)

#let qr-code(
  content, 
  width: auto, 
  height: auto, 
  color: black, 
  background: white,
) = {
  let result = call-js-function(qrcode-bytecode, "qrcode", content, color.to-hex(), background.to-hex())
  return image.decode(result, width: width, height: height)
}