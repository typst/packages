// ilkman — font palettes
//
// Each role is (font: <family or array>, stretch: <ratio>, weight: <int or str>).
// All default families are SIL OFL licensed. Typst's embedded fonts are
// appended as fallbacks so documents always compile.

#let serif-fallback = ("Libertinus Serif",)
#let mono-fallback = ("DejaVu Sans Mono",)

#let font-palettes = (
  mulish: (
    body:    (font: ("Mulish",) + serif-fallback, stretch: 100%, weight: 400),
    heading: (font: ("Mulish",) + serif-fallback, stretch: 100%, weight: 800),
    table:   (font: ("Mulish",) + serif-fallback, stretch: 100%, weight: 400),
    code:    (font: ("JetBrains Mono",) + mono-fallback, stretch: 100%, weight: 400),
  ),
  plex: (
    body:    (font: ("IBM Plex Sans",) + serif-fallback, stretch: 100%, weight: 400),
    heading: (font: ("IBM Plex Sans",) + serif-fallback, stretch: 100%, weight: 600),
    table:   (font: ("IBM Plex Sans",) + serif-fallback, stretch: 75%, weight: 400),
    code:    (font: ("IBM Plex Mono",) + mono-fallback, stretch: 100%, weight: 400),
  ),
  source: (
    body:    (font: ("Source Serif 4",) + serif-fallback, stretch: 100%, weight: 400),
    heading: (font: ("Source Sans 3",) + serif-fallback, stretch: 100%, weight: 700),
    table:   (font: ("Source Sans 3",) + serif-fallback, stretch: 100%, weight: 400),
    code:    (font: ("Source Code Pro",) + mono-fallback, stretch: 100%, weight: 400),
  ),
  fira: (
    body:    (font: ("Fira Sans",) + serif-fallback, stretch: 100%, weight: 400),
    heading: (font: ("Fira Sans",) + serif-fallback, stretch: 100%, weight: 600),
    table:   (font: ("Fira Sans",) + serif-fallback, stretch: 75%, weight: 400),
    code:    (font: ("Fira Mono",) + mono-fallback, stretch: 100%, weight: 400),
  ),
)

#let _role(v, base) = {
  if type(v) == str or type(v) == array {
    let fam = if type(v) == str { (v,) } else { v }
    (font: fam + base.font.slice(1), stretch: 100%, weight: base.weight)
  } else if type(v) == dictionary {
    let r = base
    for (k, x) in v { r.insert(k, if k == "font" and type(x) == str { (x,) } else { x }) }
    r
  } else { base }
}

/// Resolve `fonts:` — a palette name, or a dictionary overriding roles of
/// "mulish" (or of `base:` when given), e.g. (body: "Avenir Next").
#let resolve-fonts(f) = {
  if type(f) == str {
    assert(f in font-palettes, message: "ilkman: unknown font palette \"" + f + "\". Available: " + font-palettes.keys().join(", "))
    return font-palettes.at(f)
  }
  let base = font-palettes.at(f.at("base", default: "mulish"))
  let out = base
  for role in ("body", "heading", "table", "code") {
    if role in f { out.insert(role, _role(f.at(role), base.at(role))) }
  }
  out
}

/// text() arguments for a role
#let font-args(fonts, role) = {
  let r = fonts.at(role)
  (font: r.font, stretch: r.stretch)
}
