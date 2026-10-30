// ilkman — color palettes
//
// Every palette has five roles:
//   ink      darkest tone: body text and headings
//   primary  main color: H1, cover, table header, solid backgrounds
//   accent   highlights: links, emphasized lines, cover details
//   tint     light tone: first zebra row, borders
//   wash     lightest tone: second zebra row, code background, boxes

#let palettes = (
  okyanus:  (ink: rgb("#0B2545"), primary: rgb("#13508A"), accent: rgb("#2E86DE"), tint: rgb("#BBDDF7"), wash: rgb("#EAF4FC")),
  fiyort:   (ink: rgb("#0F3B47"), primary: rgb("#1B6F80"), accent: rgb("#2BA7B8"), tint: rgb("#BFE6EA"), wash: rgb("#EBF7F8")),
  gece:     (ink: rgb("#10172E"), primary: rgb("#1F2A55"), accent: rgb("#D4A23C"), tint: rgb("#C9CEE3"), wash: rgb("#F1F2F8")),
  çelik:    (ink: rgb("#1F2933"), primary: rgb("#3E5468"), accent: rgb("#6C8EAD"), tint: rgb("#CED8E2"), wash: rgb("#F0F3F6")),
  okabe:    (ink: rgb("#00293D"), primary: rgb("#0072B2"), accent: rgb("#E69F00"), tint: rgb("#A6D3EF"), wash: rgb("#EAF5FC")),
  orman:    (ink: rgb("#10301F"), primary: rgb("#1F5C3A"), accent: rgb("#3E9E64"), tint: rgb("#C7E6D2"), wash: rgb("#EDF7F0")),
  nane:     (ink: rgb("#0E3B33"), primary: rgb("#1A7A68"), accent: rgb("#3CC4A6"), tint: rgb("#C2EEE3"), wash: rgb("#ECFAF6")),
  zeytin:   (ink: rgb("#2B2E12"), primary: rgb("#5A6223"), accent: rgb("#9AA544"), tint: rgb("#DDE2BC"), wash: rgb("#F4F6E8")),
  kiremit:  (ink: rgb("#3A1A12"), primary: rgb("#9A3F26"), accent: rgb("#D9734E"), tint: rgb("#F4CDBF"), wash: rgb("#FCF0EB")),
  kehribar: (ink: rgb("#3D2606"), primary: rgb("#8F5B0A"), accent: rgb("#E09B22"), tint: rgb("#F7DDB0"), wash: rgb("#FDF5E6")),
  gül:      (ink: rgb("#42142A"), primary: rgb("#A33A64"), accent: rgb("#E07AA0"), tint: rgb("#F6CFDE"), wash: rgb("#FDF0F5")),
  bordo:    (ink: rgb("#33090F"), primary: rgb("#7A1B28"), accent: rgb("#B8475A"), tint: rgb("#EDC6CD"), wash: rgb("#FAEEF0")),
  lavanta:  (ink: rgb("#241C47"), primary: rgb("#4B3D99"), accent: rgb("#8B7FE0"), tint: rgb("#D7D2F5"), wash: rgb("#F2F0FC")),
  mürdüm:   (ink: rgb("#2E1030"), primary: rgb("#6B2A6E"), accent: rgb("#A65CA9"), tint: rgb("#E6CCE7"), wash: rgb("#F8EFF8")),
  grafit:   (ink: rgb("#1C1C1E"), primary: rgb("#3A3A3E"), accent: rgb("#E4572E"), tint: rgb("#D6D6D9"), wash: rgb("#F3F3F4")),
)

// ASCII aliases so `colors: "celik"` etc. also work.
#let palette-aliases = (
  celik: "çelik", gul: "gül", murdum: "mürdüm",
  ocean: "okyanus", forest: "orman", graphite: "grafit",
)

// Base hues for named fills ("blue", "green", ...). Each palette bends
// them slightly toward its own primary so tones stay in harmony.
#let base-hues = (
  blue:   rgb("#2F6FD0"),
  green:  rgb("#2E9A5A"),
  red:    rgb("#D0443A"),
  yellow: rgb("#E2B21C"),
  orange: rgb("#E07B24"),
  purple: rgb("#7B52C8"),
  teal:   rgb("#1E9E9A"),
  pink:   rgb("#D6508A"),
  gray:   rgb("#7A7A80"),
)

// Semantic kinds for im-note
#let note-hues = (info: "blue", tip: "green", warn: "orange", danger: "red")

/// Resolve a palette name (or a custom dictionary) to a palette dictionary.
#let resolve-palette(p) = {
  if type(p) == dictionary {
    let base = palettes.okyanus
    for (k, v) in p { base.insert(k, v) }
    return base
  }
  let name = palette-aliases.at(p, default: p)
  assert(
    name in palettes,
    message: "ilkman: unknown palette \"" + p + "\". Available: " + palettes.keys().join(", "),
  )
  palettes.at(name)
}

/// Light tone pair (z1, z2) + a stroke tone for a named hue within a palette.
/// Light tones are always light, so text on them stays readable.
#let hue-tones(pal, name) = {
  let base = if name == "primary" { pal.primary } else if name == "accent" { pal.accent } else {
    let h = base-hues.at(name, default: none)
    assert(h != none, message: "ilkman: unknown color name \"" + name + "\". Use one of: primary, accent, " + base-hues.keys().join(", "))
    color.mix((h, 85%), (pal.primary, 15%))
  }
  let mixw(p) = color.mix((base, p), (white, 100% - p), space: rgb)
  (
    z1: mixw(22%),
    z2: mixw(10%),
    strong: base.darken(10%),
    stroke: mixw(55%),
    text: base.darken(45%),
  )
}

/// Resolve any user color spec to a guaranteed-light fill.
///   none        -> none
///   "green"     -> palette's lightest green
///   rgb(...)    -> auto-lightened so text stays readable
#let light-fill(pal, c, level: "z2") = {
  if c == none or c == false { return none }
  if type(c) == str { return hue-tones(pal, c).at(level) }
  if type(c) == color { return color.mix((c, if level == "z1" { 22% } else { 10% }), (white, if level == "z1" { 78% } else { 90% }), space: rgb) }
  c
}

/// Resolve a stroke spec: none | true | "green" | color.
#let soft-stroke(pal, s) = {
  if s == none or s == false { return none }
  if s == true { return 0.6pt + pal.tint.darken(12%) }
  if type(s) == str { return 0.6pt + hue-tones(pal, s).stroke }
  if type(s) == color { return 0.6pt + s }
  s
}

/// Resolve a strong (non-light) color: "primary", "accent", hue name or color.
#let strong-color(pal, c) = {
  if c == auto or c == none { return pal.primary }
  if type(c) == color { return c }
  if c in pal { return pal.at(c) }
  hue-tones(pal, c).strong
}
