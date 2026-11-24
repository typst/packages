// WASM loading and conversions at the Typst/plugin boundary.
#let mol-plugin = plugin("../molchemist_plugin.wasm")
#let smiles-plugin = plugin("../molchemist_smiles_plugin.wasm")

#let _config-source(value) = {
  if type(value) == dictionary {
    if value.len() == 0 { "(:)" }
    else { "(" + value.pairs().sorted(key: p => repr(p.first())).map(p => repr(p.first()) + ": " + _config-source(p.last())).join(", ") + ",)" }
  } else if type(value) == array {
    if value.len() == 0 { "()" } else { "(" + value.map(_config-source).join(", ") + ",)" }
  } else if type(value) in (int, float) {
    str(value)
  } else {
    assert(type(value) != function, message: "dump cannot serialize a configuration callback")
    repr(value)
  }
}

#let _mol-data-to-bytes(data) = {
  if repr(type(data)) == "path" {
    read(data, encoding: none)
  } else if type(data) == bytes {
    data
  } else {
    bytes(data)
  }
}
