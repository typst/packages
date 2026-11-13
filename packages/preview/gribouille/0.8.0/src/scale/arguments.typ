// Checks of the arguments a deferred `scale-*` stub captured.
//
// The public `scale-*` constructors defer, so `bind-scale` runs these checks
// when `scales()` binds the stub to an aesthetic. A typo or a wrong type then
// fails there, under the name of the constructor the user called, rather than
// as a raw Typst error or a silent fallback downstream.
//
// `check-arguments` reads the named arguments before the builder runs, because
// some builders consume an argument at once (a palette name, a hue pair).
// `check-limits` and `check-breaks` read the built scale, because the rule for
// `limits` and `breaks` depends on its type and its transform.

#import "../utils/errors.typ": fail-enum, fail-range, fail-type
#import "../utils/types.typ": check-number, is-native-numeric, parse-number
#import "../utils/viridis.typ" as viridis-mod
#import "../utils/palette.typ": brewer-palettes
#import "expansion.typ": normalise-expansion

// Accepted `transform` names, mirrored by `transform-fwd`/`transform-inv` in
// train.typ, and accepted `oob` modes, mirrored by `_checker` in oob.typ.
#let _TRANSFORMS = ("identity", "reverse", "log10", "sqrt")
#let _OOB-MODES = ("drop", "squish")

// The families whose `palette` is a ColorBrewer name, not a gradient or an
// array of colours.
#let _BREWER-FAMILIES = ("brewer", "distiller", "fermenter")

// The aesthetics whose `range` holds lengths; `alpha` holds numbers.
#let _LENGTH-RANGE-AES = ("size", "linewidth", "stroke")

#let _check-in(scope, name, value, lo, hi) = {
  if value < lo or value > hi {
    fail-range(scope, name, value, lo, hi, lo-open: false, hi-open: false)
  }
}

#let _check-number-in(scope, name, value, lo, hi) = {
  check-number(scope, name, value)
  _check-in(scope, name, value, lo, hi)
}

#let _check-non-empty(scope, name, value, expected) = {
  if type(value) != array or value.len() == 0 {
    fail-type(scope, name, value, expected)
  }
}

#let _check-range(scope, aesthetic, value) = {
  let lengths = aesthetic in _LENGTH-RANGE-AES
  let expected = if lengths { "a (lo, hi) pair of lengths" } else {
    "a (lo, hi) pair of numbers in [0, 1]"
  }
  if type(value) != array or value.len() != 2 {
    fail-type(scope, "range", value, expected)
  }
  for side in value {
    if lengths and type(side) != length {
      fail-type(scope, "range", value, expected)
    }
    if not lengths {
      if not is-native-numeric(side) {
        fail-type(scope, "range", value, expected)
      }
      _check-in(scope, "range", side, 0, 1)
    }
  }
}

// Check the named arguments of a stub of `family` bound to `aesthetic`. Each
// check runs only when the user passed the argument, because every default
// passes, except `values` and `colours`, which have no usable default.
#let check-arguments(family, aesthetic, named) = {
  let scope = "scale-" + family
  if "oob" in named and named.oob not in _OOB-MODES {
    fail-enum(scope, "oob", named.oob, _OOB-MODES)
  }
  if "transform" in named and named.transform not in _TRANSFORMS {
    fail-enum(scope, "transform", named.transform, _TRANSFORMS)
  }
  if "n-breaks" in named {
    let n = named.at("n-breaks")
    if type(n) != int or n < 1 {
      fail-type(scope, "n-breaks", n, "a positive integer")
    }
  }
  if "option" in named {
    let option = named.option
    if type(option) != str {
      fail-type(scope, "option", option, "a viridis variant name as a string")
    }
    if option not in viridis-mod.palettes {
      fail-enum(scope, "option", option, viridis-mod.palettes.keys())
    }
  }
  if "palette" in named {
    let palette = named.palette
    if family in _BREWER-FAMILIES {
      if type(palette) != str {
        fail-type(scope, "palette", palette, "a palette name as a string")
      }
      if palette not in brewer-palettes {
        fail-enum(scope, "palette", palette, brewer-palettes.keys())
      }
    } else if palette != auto {
      // Only `scale-continuous` interpolates, so only it takes a gradient.
      let gradient = family == "continuous"
      let expected = if gradient { "a gradient, an array, or `auto`" } else {
        "an array or `auto`"
      }
      let ok = (
        type(palette) == array or (gradient and type(palette) == gradient)
      )
      if not ok { fail-type(scope, "palette", palette, expected) }
      if type(palette) == array and palette.len() == 0 {
        fail-type(scope, "palette", palette, "a non-empty array")
      }
    }
  }
  if family == "manual" {
    _check-non-empty(
      scope,
      "values",
      named.at("values", default: ()),
      "a non-empty array",
    )
  }
  if family in ("gradientn", "stepsn") {
    _check-non-empty(
      scope,
      "colours",
      named.at("colours", default: ()),
      "a non-empty array of colours",
    )
  }
  for key in ("direction", "midpoint") {
    if key in named { check-number(scope, key, named.at(key)) }
  }
  for key in ("start", "end") {
    if key in named { _check-number-in(scope, key, named.at(key), 0, 1) }
  }
  for key in ("chroma", "luminance") {
    if key in named { _check-number-in(scope, key, named.at(key), 0, 100) }
  }
  if "hue" in named {
    let hue = named.hue
    if (
      type(hue) != array or hue.len() != 2 or hue.any(h => type(h) != angle)
    ) {
      fail-type(scope, "hue", hue, "a (start, end) pair of angles")
    }
  }
  if "range" in named { _check-range(scope, aesthetic, named.range) }
  if "expand" in named {
    // The call only checks the value, so its result is dropped.
    let _ = normalise-expansion(named.expand, "continuous", scope: scope)
  }
}

// Fail when `v`, the parsed form of the user value `raw`, lies outside the
// domain of `transform`. The message prints `raw`, as the user wrote it.
#let check-transform-domain(scope, name, raw, v, transform) = {
  if transform == "log10" and v <= 0 {
    fail-type(scope, name, raw, "positive on a log10 scale")
  }
  if transform == "sqrt" and v < 0 {
    fail-type(scope, name, raw, "non-negative on a sqrt scale")
  }
}

// Check one side of a continuous `limits` pair, and the domain of `transform`.
// The message prints the value the user wrote, not the parsed number.
#let _check-limit(scope, side, value, transform) = {
  if value == auto { return }
  let v = parse-number(value)
  if v == none {
    fail-type(
      scope,
      side + " limit",
      value,
      "a number, an ISO date string, or `auto`",
    )
  }
  check-transform-domain(scope, side + " limit", value, v, transform)
}

// Check `limits` on the built scale: a `(lo, hi)` pair on a continuous scale,
// an array of level names on a discrete one.
#let check-limits(family, scale) = {
  let limits = scale.at("limits", default: none)
  if limits == none { return }
  let scope = "scale-" + family
  if scale.type == "continuous" {
    if type(limits) != array or limits.len() != 2 {
      fail-type(scope, "limits", limits, "a (lo, hi) pair")
    }
    let transform = scale.at("transform", default: "identity")
    _check-limit(scope, "lower", limits.at(0), transform)
    _check-limit(scope, "upper", limits.at(1), transform)
    return
  }
  if scale.type != "discrete" { return }
  if type(limits) != array {
    fail-type(scope, "limits", limits, "an array of level names")
  }
  // A discrete scale reads a bare number as a 1-indexed position rather than a
  // level name (`map-discrete`), so a numeric level would be ambiguous: the
  // pre-pass could not censor against it, and a position and a level of the
  // same value would disagree.
  for level in limits {
    if type(level) != str {
      fail-type(
        scope,
        "limits",
        level,
        "a level name as a string",
        hint: "A discrete scale reads a bare number as a position, not as "
          + "a level. Quote the levels, as in `limits: (\"1\", \"2\")`.",
      )
    }
  }
}

// Check an explicit `breaks` or `minor-breaks` array (or a bare break) on a
// continuous scale, and `n-minor`. A break is a user argument, not a data cell,
// so an unparsable break, or one outside the domain of the transform, fails as
// a limit does.
#let check-breaks(family, scale) = {
  if scale.type != "continuous" { return }
  let scope = "scale-" + family
  let transform = scale.at("transform", default: "identity")
  for key in ("breaks", "minor-breaks") {
    let breaks = scale.at(key, default: auto)
    if breaks == auto or breaks == none or type(breaks) == function {
      continue
    }
    let values = if type(breaks) == array { breaks } else { (breaks,) }
    for b in values {
      let v = parse-number(b)
      if v == none {
        fail-type(scope, key, b, "a number or an ISO date string")
      }
      check-transform-domain(scope, key, b, v, transform)
    }
  }
  let n-minor = scale.at("n-minor", default: auto)
  if n-minor != auto and (type(n-minor) != int or n-minor < 0) {
    fail-type(
      scope,
      "n-minor",
      n-minor,
      "a non-negative integer or `auto`",
    )
  }
}
