#let _plugin = plugin("../cooklang.wasm")

/// Parse a Cooklang recipe into a dictionary.
///
/// - content (str, bytes): The recipe source, e.g. `read("recipe.cook")`.
/// -> dictionary
#let parse(content) = {
  json(_plugin.parse(bytes(content)))
}
