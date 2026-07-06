// text/parser.typ — Rust-backed scratchblocks parser bridge for Blockst
// All actual parsing logic now lives in the scratchblocks-wasm Rust plugin.

#import "../plugin.typ": scratchblocks-renderer, _to-scale-number, render-scratch-font-aware
#import "../options.typ": get-options, get-theme, get-scale

// Delegate to Rust WASM plugin for parsing
#let _parse-via-plugin(text, lang-code, inline: false) = {
  let payload = (code: text, language: lang-code, inline: inline)
  let raw = str(scratchblocks-renderer.parse_json(bytes(json.encode(payload))))
  json(bytes(raw))
}

#let parse-scratch-text(
  text,
  lang-code: "en",
  end-marker: "end",
  else-marker: "else",
  line-comment-prefix: "//",
  statement-defs-raw: (),
  expression-defs-raw: (),
) = _parse-via-plugin(text, lang-code)

#let render-scratch-text(
  text,
  lang-code: "en",
  end-marker: "end",
  else-marker: "else",
  line-comment-prefix: "//",
  statement-defs-raw: (),
  expression-defs-raw: (),
) = context {
  // Font-aware rendering — measures text with Typst's actual font
  render-scratch-font-aware(text, language: lang-code)
}
