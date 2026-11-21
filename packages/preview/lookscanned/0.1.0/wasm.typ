#let _plugin = plugin("lookscanned.wasm")

#let _kinds = ("paper", "grain", "toner", "ink", "stains", "dust", "lines", "edges")

// Resolution factor per kind: smooth textures are rendered coarser.
#let _factor = (paper: 1 / 8, stains: 1 / 3, edges: 1 / 10)

// `TABLE_LEN` random bytes, read through `rnd` in effects/jitter.typ.
#let random-table(seed) = _plugin.random(cbor.encode(seed))

// Raw PNG bytes of a texture. `w`/`h` in pixels; colours and pixel lengths
// are converted here, everything else is passed as is (see src/params.rs).
#let texture-bytes(kind, ..args) = {
  let p = args.named()
  for (k, v) in p {
    if type(v) == color {
      p.insert(k, rgb(v).components().map(c => int(calc.round(c / 100% * 255))))
    }
  }
  _plugin.texture(bytes(kind), cbor.encode(p))
}

/// Generates a texture as an image sized to `width` × `height` (the page by default).
///
/// - kind: "paper", "grain", "toner", "ink", "stains", "dust", "lines" or "edges".
/// - seed: same seed, same texture.
/// - resolution: dpi of the generated image (smooth kinds use a fraction of it).
/// - ..args: texture parameters (`color`, `amount`, `grain`, `aging`, `min`, `max`…).
///   Lengths are converted to pixels.
#let texture(kind, seed: 0, width: auto, height: auto, resolution: 150, ..args) = {
  assert(kind in _kinds, message: "lookscanned.texture: unknown kind " + repr(kind) + ", expected one of " + _kinds.map(repr).join(", "))
  assert(type(seed) == int, message: "lookscanned.texture: seed must be an integer")
  assert(args.pos().len() == 0, message: "lookscanned.texture: unexpected positional arguments")
  context {
    let w = if width == auto { page.width } else { width }
    let h = if height == auto { page.height } else { height }
    assert(type(w) == length and type(h) == length, message: "lookscanned.texture: width and height must be lengths (page height is auto?)")
    let w = w.to-absolute()
    let h = h.to-absolute()
    let ppmm = resolution / 25.4 * _factor.at(kind, default: 1)
    let px(l) = calc.max(1, int(calc.round(l.mm() * ppmm)))
    let p = args.named()
    for (k, v) in p {
      if type(v) == length { p.insert(k, px(v.to-absolute())) }
    }
    let data = texture-bytes(kind, w: px(w), h: px(h), ppmm: ppmm, seed: seed, ..p)
    let scaling = if kind == "lines" { "pixelated" } else { "smooth" }
    image(data, width: w, height: h, fit: "stretch", scaling: scaling)
  }
}
