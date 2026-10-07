#import "options.typ": get-options, get-theme, get-scale, get-font, get-line-numbers, get-line-number-start, get-line-number-first-block, get-line-number-gutter, get-inset-scale, get-colors

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

#let _to-inset-scale-number(scale) = {
  if type(scale) == ratio {
    scale / 100%
  } else if type(scale) == int or type(scale) == float {
    if scale > 8 {
      scale / 100
    } else {
      scale
    }
  } else {
    1
  }
}

#let render-document(spec, width: auto, alt: "Scratch blocks") = context {
  let options = get-options()
  let payload = spec
  payload.insert("theme", get-theme(options))
  payload.insert("scale", _to-scale-number(get-scale(options)))
  payload.insert("line_numbers", get-line-numbers(options))
  payload.insert("line_number_start", get-line-number-start(options))
  payload.insert("line_number_first_block", get-line-number-first-block(options))
  payload.insert("line_number_gutter", get-line-number-gutter(options))
  payload.insert("inset_scale", _to-inset-scale-number(get-inset-scale(options)))
  set text(font: get-font(options))
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
  profile: "scratch",
) = context {
  let options = get-options()
  let theme = get-theme(options)
  let scale = _to-scale-number(get-scale(options))
  let font-family = get-font(options)
  // MakeCode draws its labels in a monospace face; unless the document
  // chose a font, measure and draw with the editor's stack.
  let font-family = if profile.starts-with("makecode") and font-family == "Helvetica Neue" {
    ("Menlo", "Consolas", "DejaVu Sans Mono")
  } else { font-family }

  // Build the base payload
  let payload = (
    code: code,
    language: language,
    inline: inline,
    theme: theme,
    scale: scale,
    line_numbers: get-line-numbers(options),
    line_number_start: get-line-number-start(options),
    line_number_first_block: get-line-number-first-block(options),
    line_number_gutter: get-line-number-gutter(options),
    inset_scale: _to-inset-scale-number(get-inset-scale(options)),
    profile: profile,
    colors: get-colors(options),
  )

  // Try to extract texts, measure, and use measured widths
  let result = {
    // Step 1: Extract all text strings from the parser
    let texts-raw = scratchblocks-renderer.extract_texts(bytes(json.encode(payload)))
    let texts = json(texts-raw)

    // Step 2: Measure each text with Typst's actual font
    let widths = (:)

    // Blockly labels are 11pt regular, Scratch's 12pt medium, MakeCode's
    // 12pt semibold in a monospace face; the widths have to be measured the
    // way the SVG will draw them.
    let blockly = profile.starts-with("blockly") or profile.starts-with("jwinf")
    let makecode = profile.starts-with("makecode")
    let (label-size, label-weight) = if blockly { (11pt, 400) } else if makecode { (12pt, 600) } else { (12pt, 500) }
    for t in texts {
      let m = measure(text(font: font-family, size: label-size, weight: label-weight)[#t])
      // Convert Typst pt to SVG user units (CSS px at 96dpi: 1pt = 96/72 px)
      widths.insert(t, m.width / 1pt * 96.0 / 72.0)
    }

    // Step 3: Render with measured widths and font
    let render-payload = payload
    render-payload.insert("widths", widths)
    render-payload.insert("font", if type(font-family) == array { font-family.map(f => "\"" + f + "\"").join(", ") + ", monospace" } else { font-family })

    // The SVG names the block font itself, but an unresolvable family falls
    // back to the ambient Typst font — monospace inside a raw block, which is
    // how #show: raw-scratch() ended up with clipped labels. Pin the ambient
    // font to the family the widths were measured with.
    // Only the family: the ambient size would change the line box the
    // image sits in, and the SVG carries its own font size anyway.
    set text(font: font-family)
    image(
      scratchblocks-renderer.render_code_json(bytes(json.encode(render-payload))),
      format: "svg",
      alt: "Scratch blocks",
    )
  }

  result
}
