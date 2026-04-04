#let plugin = plugin("verovio.wasm")

/// Serialize a Typst dictionary to a JSON options string for Verovio.
/// Merges with default options (adjustPageHeight crops SVG to content).
#let _serialize-options(options) = {
  let defaults = (adjustPageHeight: true, inputFrom: "auto")
  let merged = if options != none { defaults + options } else { defaults }
  let pairs = merged.pairs().map(((k, v)) => {
    let val = if type(v) == str { "\"" + v + "\"" } else if v == true { "true" } else if v == false { "false" } else { str(v) }
    "\"" + k + "\":" + val
  })
  "{" + pairs.join(",") + "}"
}

/// Render music notation to an SVG image.
///
/// - data: Music data as a string (MusicXML, MEI, ABC, Humdrum, etc.)
/// - options: Verovio options as a dictionary (optional)
/// - page: Page number to render (default: 1)
/// - ..args: Additional arguments forwarded to Typst's `image` function
///           (e.g., `width`, `height`, `fit`, `alt`)
#let render-music(data, options: none, page: 1, ..args) = {
  let data-bytes = bytes(data)
  let options-bytes = bytes(_serialize-options(options))

  let svg-bytes = if page == 1 {
    plugin.render(data-bytes, options-bytes)
  } else {
    plugin.render_page(data-bytes, options-bytes, bytes(str(page)))
  }

  image(svg-bytes, format: "svg", ..args.named())
}

/// Get the number of pages for a music document.
///
/// - data: Music data as a string
/// - options: Verovio options as a dictionary (optional)
#let music-page-count(data, options: none) = {
  int(str(plugin.page_count(bytes(data), bytes(_serialize-options(options)))))
}
