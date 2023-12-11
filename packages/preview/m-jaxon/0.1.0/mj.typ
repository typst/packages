#import "@preview/jogs:0.2.1": compile-js, call-js-function

#let mj-src = read("./mj.js")
#let mj-bytecode = compile-js(mj-src)

#let natural-image(..args) = style(styles => {
  let (width, height) = measure(image.decode(..args), styles)
  image.decode(..args, width: width, height: height)
})

#let get-text(src) = {
  if type(src) == "str" {
    src
  } else if type(src) == "content" {
    src.text
  }
}

#let render(src, inline: false, size: 11pt) = {
  let src = get-text(src)
  let passed-size = size - 2pt // for some reason, it looks like -2pt is the right amount to make the size match the size of the text
  let result = call-js-function(mj-bytecode, "mj", src, inline, passed-size.pt())
  let img = natural-image(result.svg, format: "svg")
  let ex = result.vertical_align
  if inline {
    box(move(box(img), dy: -ex * 0.5em))
  } else {
    align(center, img)
  }
}
