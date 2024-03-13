#import "@preview/jogs:0.2.2": compile-js, call-js-function

#let pintora-src = read("./pintora.js")
#let pintora-bytecode = compile-js(pintora-src)

#let render(src, ..args) = {
  let svg-output = call-js-function(pintora-bytecode, "PintoraRender", src)

  let named-args = args.named()
  let factor = named-args.at("factor",default:none)

  if (factor != none){
    let svg-width = svg-output.find(regex("width=\"(\d+)")).find(regex("\d+"))

    let new-width = int(svg-width) * factor * 1pt
    named-args.insert("width", new-width) 
    let junk = named-args.remove("factor")
  }

  image.decode(svg-output, ..args.pos(), ..named-args)
}
