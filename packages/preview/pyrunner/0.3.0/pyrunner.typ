#let py = plugin("./typst-pyrunner.wasm")

#let extract(code) = {
  if type(code) == content {
    code.text
  } else {
    code
  }
}

#let block(code, globals: (:)) = {
  let code = extract(code)
  cbor(py.run_py(bytes(code), cbor.encode(globals)))
}

#let compile(code) = {
  let code = extract(code)
  py.compile_py(bytes(code))
}

#let call(compiled, fn_name, ..args) = {
  cbor(py.call_compiled(compiled, bytes(fn_name), cbor.encode(args.pos())))
}

