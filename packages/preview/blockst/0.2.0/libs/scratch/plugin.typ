#import "options.typ": get-options, get-theme, get-scale, get-font

#let scratchblocks-renderer = plugin("plugins/scratchblocks_wasm.wasm")

#let _to-scale-number(scale) = {
  if type(scale) == ratio {
    scale / 100%
  } else if type(scale) == int or type(scale) == float {
    scale
  } else {
    1
  }
}

#let render-document(spec, width: auto, alt: "Scratch blocks") = context {
  let options = get-options()
  let payload = spec
  payload.insert("theme", get-theme(options))
  payload.insert("scale", _to-scale-number(get-scale(options)))
  image(
    scratchblocks-renderer.render_json(bytes(json.encode(payload))),
    format: "svg",
    width: width,
    alt: alt,
  )
}

/// Font-aware render: extract text tokens, measure them with Typst's actual
/// font, then pass measured widths + font name to the WASM renderer.
/// Falls back to the plugin's hardcoded Helvetica Neue metrics when
/// measurement is not possible.
#let render-scratch-font-aware(
  code,
  language: "en",
  inline: false,
) = context {
  let options = get-options()
  let theme = get-theme(options)
  let scale = _to-scale-number(get-scale(options))
  let font-family = get-font(options)

  // Build the base payload
  let payload = (
    code: code,
    language: language,
    inline: inline,
    theme: theme,
    scale: scale,
  )

  // Try to extract texts, measure, and use measured widths
  let result = {
    // Step 1: Extract all text strings from the parser
    let texts-raw = scratchblocks-renderer.extract_texts(bytes(json.encode(payload)))
    let texts = json(texts-raw)

    // Step 2: Measure each text with Typst's actual font
    let widths = (:)

    for t in texts {
      let m = measure(text(font: font-family, size: 12pt, weight: 500)[#t])
      // Convert Typst pt to SVG user units (CSS px at 96dpi: 1pt = 96/72 px)
      widths.insert(t, m.width / 1pt * 96.0 / 72.0)
    }

    // Step 3: Render with measured widths and font
    let render-payload = payload
    render-payload.insert("widths", widths)
    render-payload.insert("font", font-family)

    image(
      scratchblocks-renderer.render_code_json(bytes(json.encode(render-payload))),
      format: "svg",
      alt: "Scratch blocks",
    )
  }

  result
}
