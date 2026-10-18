// Bridge to the NEPO (Open Roberta) WASM renderer.
//
// The dialects are separate all the way down to the plugin, but the two things
// that are genuinely shared stay shared: the option state in
// `libs/scratch/options.typ`, and the font-measurement pass below, which is
// the same idea as `libs/scratch/plugin.typ` at NEPO's own font size.

#import "../scratch/options.typ": get-options, get-theme, get-scale, get-font

#let nepo-renderer = plugin("plugins/nepo_wasm.wasm")

// Open Roberta's `.blocklyText` is `font-size: 11pt`, and its rulers are
// `Courier New`. Measuring at the wrong size would put every label in the
// wrong place, so these are not free choices.
#let nepo-font-size = 11pt
#let nepo-mono-font = ("Courier New", "Courier", "DejaVu Sans Mono")

#let _to-scale-number(scale) = {
  if type(scale) == ratio {
    scale / 100%
  } else if type(scale) == int or type(scale) == float {
    scale
  } else {
    1
  }
}

// The plugin asks for widths under keys of the form `<font>\u{1}<text>`,
// because the image block prints the same digits in two different fonts and a
// single lookup table would otherwise give one of them the wrong width.
#let _measure-widths(keys, font-family) = {
  let widths = (:)
  for key in keys {
    let parts = key.split("\u{1}")
    let family = if parts.at(0) == "mono" { nepo-mono-font } else { font-family }
    let value = parts.slice(1).join("\u{1}")
    let m = measure(text(font: family, size: nepo-font-size)[#value])
    // Typst points to SVG user units (CSS px at 96dpi).
    widths.insert(key, m.width / 1pt * 96.0 / 72.0)
  }
  widths
}

#let render-nepo(
  code,
  language: "de",
  platform: "calliope",
  width: auto,
  alt: "NEPO-Blöcke",
) = context {
  let options = get-options()
  let font-family = get-font(options)

  let payload = (
    code: code,
    language: language,
    platform: platform,
    theme: get-theme(options),
    scale: _to-scale-number(get-scale(options)),
  )

  let keys = json(nepo-renderer.extract_texts_json(bytes(json.encode(payload))))

  let render-payload = payload
  render-payload.insert("widths", _measure-widths(keys, font-family))
  render-payload.insert("font", font-family)

  // The SVG names the label font itself, but an unresolvable family falls back
  // to the ambient Typst font — monospace inside a raw block — which would not
  // match the widths that were just measured.
  set text(font: font-family)
  image(
    nepo-renderer.render_code_json(bytes(json.encode(render-payload))),
    format: "svg",
    width: width,
    alt: alt,
  )
}

// The parsed block tree, for tests and for callers that want the structure.
#let parse-nepo(code, language: "de", platform: "calliope") = {
  let payload = (code: code, language: language, platform: platform)
  json(nepo-renderer.parse_json(bytes(json.encode(payload))))
}
