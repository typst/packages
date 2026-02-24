#import "@preview/jogs:0.2.4": call-js-function, compile-js


#let mj-src = read("./mino.js")
#let mj-bytecode = compile-js(mj-src)

#let get-text(src) = {
  if type(src) == str {
    src
  } else if type(src) == content {
    src.text
  }
}

#let decode-fumen(fumen) = call-js-function(mj-bytecode, "mino", fumen)
