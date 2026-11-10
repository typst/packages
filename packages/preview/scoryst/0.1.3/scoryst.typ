#let plugin = plugin("scoryst.wasm")

/// Convert kebab-case to camelCase. Keys already in camelCase pass through unchanged.
#let _to-camel(s) = {
  let parts = s.split("-")
  parts.at(0) + parts.slice(1).map(p => upper(p.at(0)) + p.slice(1)).join()
}

// Verovio enum options: string→int mapping.
// Passing these as integers avoids a WASM hang in OptionIntMap::SetValue(string).
#let _enum-options = (
  breaks: ("none": 0, "auto": 1, "line": 2, "smart": 3, "encoded": 4),
  condense: ("none": 0, "auto": 1, "encoded": 2),
  footer: ("none": 0, "auto": 1, "always": 2, "encoded": 3),
  header: ("none": 0, "auto": 1, "encoded": 2),
  smuflTextFont: ("embedded": 0, "linked": 1, "none": 2),
  mensuralResponsiveView: ("none": 0, "auto": 1, "selection": 2),
  pedalStyle: ("auto": 0, "line": 1, "pedstar": 3, "altpedstar": 4),
  fontFallback: ("Leipzig": 0, "Bravura": 1),
  lyricElision: ("regular": 58705, "narrow": 58704, "wide": 58706, "unicode": 8255),
  multiRestStyle: ("auto": 0, "default": 1, "block": 2, "symbols": 3),
  systemDivider: ("none": 0, "auto": 1, "left": 2, "left-right": 3),
  durationEquivalence: ("brevis": 0, "semibrevis": 1, "minima": 2),
  ligatureOblique: ("auto": 0, "straight": 1, "curved": 2),
)

/// Serialize a Typst dictionary to a JSON options string for Verovio.
/// Merges with default options (adjustPageHeight crops SVG to content).
/// Accepts both kebab-case and camelCase option keys.
#let _serialize-options(options) = {
  let defaults = (adjust-page-height: true, input-from: "auto")
  let merged = if options != none { defaults + options } else { defaults }
  let pairs = merged.pairs().map(((k, v)) => {
    let key = _to-camel(k)
    let val = if type(v) == str and key in _enum-options {
      let mapping = _enum-options.at(key)
      assert(v in mapping, message: "invalid value \"" + v + "\" for option " + k + ", expected: " + mapping.keys().join(", "))
      str(mapping.at(v))
    } else if type(v) == str {
      "\"" + v + "\""
    } else if v == true { "true" } else if v == false { "false" } else { str(v) }
    "\"" + key + "\":" + val
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
#let score(data, options: none, page: 1, ..args) = {
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
#let pages(data, options: none) = {
  int(str(plugin.page_count(bytes(data), bytes(_serialize-options(options)))))
}

// Deprecated aliases for backward compatibility
#let render-music(data, options: none, page: 1, ..args) = score(data, options: options, page: page, ..args)
#let music-page-count(data, options: none) = pages(data, options: options)
