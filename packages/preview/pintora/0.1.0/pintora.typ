#import "@preview/jogs:0.2.1": compile-js, call-js-function

#let pintora-src = read("./pintora.js")
#let pintora-bytecode = compile-js(pintora-src)

#let render(src, ..args) = {
  let result = call-js-function(pintora-bytecode, "PintoraRender", src)
  image.decode(result, ..args)
}
