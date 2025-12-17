#import plugin("../mana.wasm"): mana_svg

/// Render mana symbols
#let mana(s, size: 1em, shadow: true, sort: true, normalize_hybrid: true) = {
  if type(s) == content {
    s = s.text
  }
  let encoded = cbor.encode((s: bytes(s), shadow: shadow, sort: sort, normalize_hybrid: normalize_hybrid))
  let svg_bytes = mana_svg(encoded)
  box(image(svg_bytes, format: "svg"), height: size, baseline: 20%, clip: false)
}
