#let plugin = plugin("wmglyph.wasm")

#let wmf-image(path, ..args) = {
  let content = plugin.read_wmf(read(path, encoding: none))
  image(content, format: "svg", ..args)
}

#let wmf(path) = {
  let content = plugin.read_wmf(read(path, encoding: none))
  content
}
