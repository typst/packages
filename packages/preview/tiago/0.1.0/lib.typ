#let diago = plugin("tiago.wasm")

/// Render to SVG as bytes
#let render-svg(source, engine: none) = {
  if engine != none {
    diago.render_svg_with_engine(bytes(source), bytes(engine))
  } else {
    diago.render_svg(bytes(source))
  }
}

/// Render to SVG as an image
#let render(source, engine: none, ..args) = image(render-svg(source, engine: engine), ..args)

/// Render to ASCII as a string
#let render-ascii(source) = str(diago.render_ascii(bytes(source)))

/// Render to Unicode as a string
#let render-unicode(source) = str(diago.render_unicode(bytes(source)))
