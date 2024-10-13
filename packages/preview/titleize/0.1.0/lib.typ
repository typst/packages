#let _plugin = plugin("titleize.wasm")

#let titlecase(data) = {
  str(_plugin.titlecase(bytes(data)))
}