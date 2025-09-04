#import "@preview/jogs:0.2.4": compile-js, call-js-function

#let mj-src = read("./mj.js")
#let mj-bytecode = compile-js(mj-src)

#let natural-image(..args) = context {
  let (width, height) = measure(image(..args))
  image(..args, width: width, height: height)
}

#let get-text(src) = {
  if type(src) == str {
    src
  } else if type(src) == content {
    src.text
  }
}

#let render(src, inline: false) = context {
  let src = get-text(src)
  let (width, height) = measure(h(1em))
  let size = width
  let passed-size = size / 1.21 // katex is 1.21x larger, I dont find things about mathjax but it seems to be the same
  // https://katex.org/docs/font
  let result = call-js-function(mj-bytecode, "mj", src, inline, passed-size.pt())
  let img = natural-image(bytes(result.svg), format: "svg")
  let ex = result.vertical_align
  if inline {
    box(move(box(img), dy: -ex * 0.5em))
  } else {
    align(center, img)
  }
}
