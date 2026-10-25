#import "presets.typ": base, presets
#import "wasm.typ": random-table

#let _num = (int, float)
#let _granularities = ("page", "line", "word", "char")
// Not multiplied by `intensity`.
#let _fixed = ("color", "ghosting", "size", "drift", "resolution", "tile", "granularity", "binding", "punch-holes")

#let _same-type(v, d) = type(v) == type(d) or (type(v) in _num and type(d) in _num)

// Checks a dictionary of themes (as passed by the user or a preset) against `base`.
#let check-themes(themes, where: "lookscanned") = {
  for (theme, values) in themes {
    assert(theme in base, message: where + ": unknown theme " + repr(theme) + ", expected one of " + base.keys().join(", "))
    assert(type(values) == dictionary, message: where + ": " + theme + " must be a dictionary, got " + repr(values))
    for (key, v) in values {
      let path = where + ": " + theme + "." + key
      assert(key in base.at(theme), message: path + " is unknown, expected one of " + base.at(theme).keys().join(", "))
      let d = base.at(theme).at(key)
      assert(_same-type(v, d), message: path + " must be of type " + str(type(d)) + ", got " + repr(v))
      if type(v) in _num {
        assert(v >= 0, message: path + " must be non-negative, got " + repr(v))
      }
      if key == "size" {
        assert(
          v.keys().sorted() == ("max", "min") and v.values().all(l => type(l) == length and l > 0pt),
          message: path + " must be (min: <length>, max: <length>), got " + repr(v),
        )
      }
    }
  }
  let q = themes.at("quality", default: (:))
  if "granularity" in q {
    assert(q.granularity in _granularities, message: where + ": quality.granularity must be one of " + _granularities.map(repr).join(", ") + ", got " + repr(q.granularity))
  }
  if "resolution" in q {
    assert(q.resolution > 0, message: where + ": quality.resolution must be positive")
  }
  if "legibility" in themes.at("ink", default: (:)) {
    assert(themes.ink.legibility <= 1, message: where + ": ink.legibility must be in [0, 1]")
  }
}

// Theme-wise merge: `b` overrides `a`, one level deep.
#let merge(a, b) = {
  for (theme, values) in b {
    a.insert(theme, a.at(theme, default: (:)) + values)
  }
  a
}

// Preset name or dictionary → full set of themes, merged on `base`.
#let preset-themes(preset) = {
  if type(preset) == str {
    assert(preset in presets, message: "lookscanned: unknown preset " + repr(preset) + ", expected one of " + presets.keys().map(repr).join(", ") + " or a dictionary")
    merge(base, presets.at(preset))
  } else {
    assert(type(preset) == dictionary, message: "lookscanned: preset must be a name or a dictionary, got " + repr(preset))
    check-themes(preset, where: "lookscanned (preset)")
    merge(base, preset)
  }
}

// Multiplies amounts, angles and lengths by `intensity`. Legibility degrades
// proportionally instead.
#let scale(themes, intensity) = {
  assert(type(intensity) in _num and intensity >= 0, message: "lookscanned: intensity must be a non-negative number, got " + repr(intensity))
  for (theme, values) in themes {
    for (key, v) in values {
      if key == "legibility" {
        values.insert(key, calc.max(0, 1 - (1 - v) * intensity))
      } else if key not in _fixed and type(v) in (int, float, length, angle) {
        values.insert(key, v * intensity)
      }
    }
    themes.insert(theme, values)
  }
  themes
}

// Splits user arguments into `(preset, intensity, seed, themes)` and validates them.
#let parse-args(args, where) = {
  assert(args.pos().len() == 0, message: where + ": unexpected positional arguments " + repr(args.pos()))
  let named = args.named()
  let opts = (preset: none, intensity: none, seed: none)
  for k in opts.keys() {
    if k in named { opts.insert(k, named.remove(k)) }
  }
  if opts.seed != none {
    assert(type(opts.seed) == int, message: where + ": seed must be an integer, got " + repr(opts.seed))
  }
  check-themes(named, where: where)
  opts + (themes: named)
}

// Parsed arguments → resolved configuration: themes scaled by intensity, plus
// what effects need (`seed`, random `table`) and what overrides inherit
// (`raw` themes, `intensity`). Unset options come from `parent`.
#let resolve(opts, parent: none) = {
  let pick(k, fallback) = if opts.at(k) != none { opts.at(k) } else if parent != none { parent.at(k) } else { fallback }
  let raw = if opts.preset != none { preset-themes(opts.preset) } else if parent != none { parent.raw } else { preset-themes("office-scan") }
  let raw = merge(raw, opts.themes)
  let intensity = pick("intensity", 1)
  let seed = pick("seed", 0)
  scale(raw, intensity) + (raw: raw, intensity: intensity, seed: seed, table: random-table(seed))
}
