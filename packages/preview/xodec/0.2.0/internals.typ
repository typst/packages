#let xodec = plugin("plugin.wasm")

#let codex-version = version(0, 2, 0)

#let get-names(value) = {
  assert.eq(type(value), str)
  let result = xodec.get_names(bytes(value))
  if result.len() == 0 {
    return ()
  }
  array(result).split(0).map(name => str(bytes(name)))
}

#let get-deprecated-names(value) = {
  assert.eq(type(value), str)
  let result = xodec.get_deprecated_names(bytes(value))
  if result.len() == 0 {
    return ()
  }
  array(result).split(0).map(name => str(bytes(name)))
}

#let get-math-names(value) = {
  assert.eq(type(value), str)
  let result = xodec.get_math_names(bytes(value))
  if result.len() == 0 {
    return ()
  }
  array(result).split(0).map(name => str(bytes(name)))
}
