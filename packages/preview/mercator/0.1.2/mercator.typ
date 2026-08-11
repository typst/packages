/// Mercator: Rendering GeoJSon in typst.
/// Author: Bernstein
/// Tip: make geo-json codeblocks render an image: `#show raw.where(lang: "geojson"): it => render-image(it.text)`

#let mercator = plugin("./mercator.wasm")

/// Renders a GeoJSON and returns SVG code for it.
///
/// - code (string, bytes): GeoJSON to be rendered.
/// -> string
#let render(code, config) = {
  return str(mercator.geo(bytes(code), bytes(config)))
}

/// Renders a GeoJSON and returns an image for it. Uses the same parameters as image.
///
/// - code (string, bytes): GeoJSON to be rendered.
/// - config (string): JSON-encoded configuration string. Optional, defaults to `"{}"`.
/// - all remaining arguments: see image
/// -> content
#let render-map(code, ..args) = {
  let config = args.pos().at(0, default: "{}")
  image(bytes(render(code, config)), format: "svg", ..args.named())
}
