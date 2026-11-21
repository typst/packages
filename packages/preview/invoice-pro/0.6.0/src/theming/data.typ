// `theme.custom.from-data`: a parsed json/yaml/toml dict -> a theme patch.
// Pure data, no `eval` (eval is not file-sandboxed). Strings are coerced:
//   "#0b3d91" -> rgb, "10.5pt"/"25mm"/"0.4em"/"1in"/"2cm" -> length, "66%" -> ratio,
//   "none" -> none, "auto" -> reset() (back to the schema default),
//   anything else stays a string (font names, enum values).
// No expression language: derived values stay derivations of the schema defaults
// (a file cannot write `t => ..`). Absence means inherit. Allowed groups: tokens,
// options, checks, and the scalar layout keys (paper, margin, body-top, body-gap,
// footer-clearance).
// Unknown keys are reported by the strict merge with the full `::` path.

#import "../utils/patch.typ": reset

#let _len-re = regex("^(-?\d+(?:\.\d+)?)(pt|mm|cm|in|em)$")
#let _pct-re = regex("^(-?\d+(?:\.\d+)?)%$")
#let _units = (pt: 1pt, mm: 1mm, cm: 1cm, "in": 1in, em: 1em)

#let _coerce(v) = {
  if type(v) == str {
    if v == "none" { return none }
    if v.starts-with("#") and v.len() in (4, 7, 9) { return rgb(v) }
    if v == "auto" { return reset() }
    let m = v.match(_len-re)
    if m != none {
      return float(m.captures.at(0)) * _units.at(m.captures.at(1))
    }
    let m = v.match(_pct-re)
    if m != none { return float(m.captures.at(0)) * 1% }
    return v
  }
  if type(v) == array { return v.map(_coerce) }
  if type(v) == dictionary {
    let out = (:)
    for (k, x) in v { out.insert(k, _coerce(x)) }
    return out
  }
  v
}

/// -> array
#let from-data(
  /// Parsed brand data, e.g. `toml("brand.toml").theme`.
  /// -> dictionary
  data,
  /// Resolves path strings RELATIVE TO YOUR FILE: `assets: p => image(p, alt: ..)`.
  /// Needed for `options.logo.image` (packages cannot open user paths on 0.14).
  /// -> none | function
  assets: none,
) = {
  assert(
    type(data) == dictionary,
    message: "variable `theme::custom::from-data::data`("
      + repr(data)
      + ") must be of dictionary",
  )
  let allowed = ("tokens", "options", "checks", "layout")
  let out = (:)
  for (g, v) in data {
    if g not in allowed {
      panic(
        "theme::custom::from-data: unknown group `"
          + g
          + "`. Allowed groups: "
          + allowed.join(", "),
      )
    }
    if g == "layout" {
      for k in v.keys() {
        if (
          k
            not in (
              "paper",
              "margin",
              "body-top",
              "body-gap",
              "footer-clearance",
            )
        ) {
          panic(
            "theme::custom::from-data: `layout::"
              + k
              + "` cannot come from a data file (layouts, areas and stationery are code). Allowed: paper, margin, body-top, body-gap, footer-clearance",
          )
        }
      }
    }
    out.insert(g, _coerce(v))
  }
  let logo = out
    .at("options", default: (:))
    .at("logo", default: (:))
    .at("image", default: none)
  if type(logo) == str {
    if assets == none {
      panic(
        "theme::custom::from-data: `options::logo::image` is the path \""
          + logo
          + "\"; packages cannot open files by path. Pass `assets: p => image(p, alt: ..)` from your document.",
      )
    }
    out.options.logo.image = assets(logo)
  }
  (out,)
}
