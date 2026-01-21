#import "specs/mod.typ": mitex-scope
#import "@preview/xarrow:0.2.0": xarrow
#let mitex-wasm = plugin("./mitex.wasm")

#let mitex-convert(it, spec: bytes(())) = {
  str(mitex-wasm.convert_math(bytes({
    if type(it) == str {
      it
    } else if type(it) == content and it.has("text") {
      it.text
    } else {
      panic("Unsupported type: " + str(type(it)))
    }
  }), spec))
}

#let mitex(it, block: true) = {
  let res = mitex-convert(it)
  math.equation(block: block, eval("$" + res + "$", scope: mitex-scope))
}

#let mi = mitex.with(block: false)
