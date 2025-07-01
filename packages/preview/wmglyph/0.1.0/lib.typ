#let plugin = plugin("wmglyph.wasm")

#let wmf-image(raw, ..args) = {
  if type(raw) != bytes {
    panic("wmf-image expects a bytes input. Use read(path, encoding: none) to read a WMF file.")
  }
  let content = plugin.read_wmf(raw)
  image(content, format: "svg", ..args)
}

#let wmf(raw) = {
  if type(raw) != bytes {
    panic("wmf expects a bytes input. Use read(path, encoding: none) to read a WMF file.")
  }
  let content = plugin.read_wmf(raw)
  content
}
