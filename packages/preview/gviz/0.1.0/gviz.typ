/// GViz: a graph layouting package for Typst
/// Author: Sekoia
/// Tip: make dot-render codeblocks render an image: `#show raw.where(lang: "dot-render"): it => render-image(it.text)`

#let _graph-layout-wasm = plugin("./gviz_typst.wasm")

/// Renders a graph in dot language and returns SVG code for it.
///
/// - code (string, bytes): Dot language code to be rendered.
/// -> string
#let render(code) = {
  return str(_graph-layout-wasm.graph(bytes(code)))
}

/// Renders a graph in dot language and returns an SVG image of it. Uses the same parameters as image.decode.
///
/// - code (string, bytes): Dot language code to be rendered.
/// - width (auto, relative): The width of the image.
/// - height (auto, relative): The height of the image.
/// - alt (none, string): A text describing the image.
/// - fit (string): How the image should adjust itself to a given area. See image.decode.
/// -> content
#let render-image(code, ..args) = {
  image.decode(render(code), format: "svg", ..args)
}
