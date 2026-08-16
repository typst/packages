// Colour resolver factory for the render pipeline. Produces the
// `ctx.resolve-colour` closure consumed by the per-row resolvers in
// `utils/colour-resolve.typ`.

#import "../utils/palette.typ": palette-at, spec-palette
#import "../utils/colour.typ": resolve-continuous-colour

// Build a colour resolver curried over the (trained, palette) pair so per-row
// callers resolve the palette once outside the row loop and call the returned
// closure with bare values. One-shot callers can still chain immediately:
// `(ctx.resolve-colour)(trained, palette)(value)`.
#let _make-resolve-colour(ink) = (trained, palette) => {
  if trained == none {
    return _ => ink
  }
  if trained.type == "identity" {
    return value => {
      if value == none or value == "" { return ink }
      if type(value) == color { return value }
      if type(value) == str { return rgb(value) }
      ink
    }
  }
  let pal = spec-palette(trained, palette)
  if trained.type == "discrete" {
    let lookup = trained.at("level-index", default: none)
    return value => {
      if value == none or value == "" { return ink }
      let s = str(value)
      let idx = if lookup == none {
        trained.domain.position(v => v == s)
      } else { lookup.at(s, default: none) }
      if idx == none { return ink }
      palette-at(pal, idx)
    }
  }
  value => {
    if value == none or value == "" { return ink }
    let v = if type(value) == str { float(value.trim()) } else { float(value) }
    resolve-continuous-colour(trained, v, pal, ink)
  }
}
