#import "specs/mod.typ": mitex-scope
#import "@preview/xarrow:0.2.0": xarrow
#let mitex-wasm = plugin("./mitex.wasm")

#let get-elem-text(it) = {
  {
    if type(it) == str {
      it
    } else if type(it) == content and it.has("text") {
      it.text
    } else {
      panic("Unsupported type: " + str(type(it)))
    }
  }
}

#let mitex-convert(it, mode: "math", spec: bytes(())) = {
  if mode == "math" {
    str(mitex-wasm.convert_math(bytes(get-elem-text(it)), spec))
  } else {
    str(mitex-wasm.convert_text(bytes(get-elem-text(it)), spec))
  }
}

// Math Mode
#let mimath(it, block: true, ..args) = {
  let res = mitex-convert(mode: "math", it)
  let eval-res = eval("$" + res + "$", scope: mitex-scope)
  math.equation(block: block, eval-res, ..args)
}

// Text Mode
#let mitext(it) = {
  let res = mitex-convert(mode: "text", it)
  eval(res, mode: "markup", scope: mitex-scope)
}

#let mitex(it, mode: "math", ..args) = {
  if mode == "math" {
    mimath(it, ..args)
  } else {
    mitext(it, ..args)
  }
}

#let mi = mimath.with(block: false)
