#import "@preview/jogs:0.2.3": compile-js, call-js-function

#let pintora-src = read("./pintora.js")
#let pintora-bytecode = compile-js(pintora-src)

#let render(src, ..args) = {
  let named-args = args.named()
  let factor = named-args.at("factor",default:none)
  let style = named-args.at("style",default:"larkLight")
  let font = named-args.at("font",default:"Arial")
  let svg-output = call-js-function(pintora-bytecode, "PintoraRender", src, style, font)

  if (factor != none){
    let svg-width = svg-output.find(regex("width=\"(\d+)")).find(regex("\d+"))

    let new-width = int(svg-width) * factor * 1pt
    named-args.insert("width", new-width) 
    let junk = named-args.remove("factor")
  }
  image.decode(svg-output, ..args.pos(), ..named-args)
}

#let render-svg(src, ..args) = {
  // style: ["default", "larkLight", "larkDark", "dark"]
  let named-args = args.named()
  let factor = named-args.at("factor",default:none)
  let style = named-args.at("style",default:"larkLight")
  let font = named-args.at("font",default:"Arial")
  let svg-output = call-js-function(pintora-bytecode, "PintoraRender", src, style, font)

  if (factor != none){
    let svg-width = svg-output.find(regex("width=\"(\d+)")).find(regex("\d+"))

    let new-width = int(svg-width) * factor * 1pt
    named-args.insert("width", new-width) 
    let junk = named-args.remove("factor")
  }
  svg-output
}

