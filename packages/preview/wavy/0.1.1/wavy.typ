#import "@preview/jogs:0.2.1": compile-js, call-js-function

#let wavy-src = read("./wavy.js")
#let wavy-bytecode = compile-js(wavy-src)

#let render(src, ..args) = {
  let result = call-js-function(wavy-bytecode, "wavy", src)
  image.decode(result, ..args)
}
