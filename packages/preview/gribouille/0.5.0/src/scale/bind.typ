///! Dispatch for aesthetic-agnostic scale constructors.
///!
///! The public `scale-*` constructors return a deferred stub carrying a
///! `family` name and the captured arguments; `scales()` calls `bind-scale`
///! to dispatch on `(aesthetic, family)` to the matching internal builder,
///! which bakes the aesthetic and produces the concrete scale dict.

#import "../utils/errors.typ": fail, fail-enum, quote-each
#import "continuous.typ": _binned-scale, _continuous-scale, _transform-scale
#import "discrete.typ": _discrete-scale
#import "date.typ": _temporal-scale
#import "colour.typ": (
  _alpha-binned, _alpha-continuous, _alpha-identity, _alpha-manual,
  _scale-brewer, _scale-continuous, _scale-discrete, _scale-distiller,
  _scale-fermenter, _scale-gradient, _scale-gradient2, _scale-gradientn,
  _scale-grey, _scale-hue, _scale-identity, _scale-manual, _scale-okabe-ito,
  _scale-steps, _scale-steps2, _scale-stepsn, _scale-viridis-b,
  _scale-viridis-c, _scale-viridis-d,
)
#import "size.typ": (
  _size-area, _size-binned, _size-binned-area, _size-continuous, _size-identity,
  _size-manual,
)
#import "linewidth.typ": (
  _linewidth-binned, _linewidth-continuous, _linewidth-identity,
  _linewidth-manual,
)
#import "stroke.typ": (
  _stroke-binned, _stroke-continuous, _stroke-identity, _stroke-manual,
)
#import "shape.typ": (
  _shape-binned, _shape-discrete, _shape-identity, _shape-manual,
)
#import "linetype.typ": (
  _linetype-binned, _linetype-discrete, _linetype-identity, _linetype-manual,
)

// Named-argument set per builder, used by `bind-scale` to reject a
// misspelled `scale-*` argument with the valid keys instead of letting the
// spread below raise Typst's native error. The adapter-injected leading
// positionals (`aesthetic`, `transform`, `temporal`) are not user keys.
// `tools/typstdoc/scale_keys.lua` (run by the typstdoc test suite inside
// `tools/check.sh`) cross-checks every tuple against the builder
// signatures; keep them in sync.
#let _POS-CONTINUOUS-KEYS = (
  "name",
  "limits",
  "oob",
  "breaks",
  "minor-breaks",
  "n-minor",
  "labels",
  "transform",
  "expand",
  "secondary",
)
#let _POS-TRANSFORM-KEYS = (
  "name",
  "limits",
  "oob",
  "breaks",
  "minor-breaks",
  "n-minor",
  "labels",
)
#let _POS-BINNED-KEYS = (
  "name",
  "limits",
  "oob",
  "n-breaks",
  "breaks",
  "labels",
)
#let _POS-DISCRETE-KEYS = ("name", "limits", "oob", "labels", "expand")
#let _TEMPORAL-KEYS = (
  "name",
  "limits",
  "oob",
  "breaks",
  "labels",
  "expand",
  "date-format",
)
#let _COLOUR-CONTINUOUS-KEYS = (
  "name",
  "palette",
  "limits",
  "oob",
  "breaks",
  "labels",
)
#let _PALETTE-DISCRETE-KEYS = ("name", "palette", "limits", "oob", "labels")
#let _PALETTE-BINNED-KEYS = (
  "n-breaks",
  "breaks",
  "palette",
  "name",
  "limits",
  "oob",
  "labels",
)
#let _MANUAL-KEYS = ("values", "name", "limits", "oob", "labels")
#let _IDENTITY-KEYS = ("name",)
#let _VIRIDIS-D-KEYS = ("option", "name", "limits", "oob", "labels")
#let _VIRIDIS-C-KEYS = ("option", "name", "limits", "oob", "breaks", "labels")
#let _VIRIDIS-B-KEYS = (
  "option",
  "n-breaks",
  "breaks",
  "name",
  "limits",
  "oob",
  "labels",
)
#let _BREWER-KEYS = ("palette", "name", "limits", "oob", "labels")
#let _OKABE-ITO-KEYS = ("name", "limits", "oob", "labels")
#let _GRADIENT-KEYS = (
  "low",
  "high",
  "name",
  "limits",
  "oob",
  "breaks",
  "labels",
)
#let _GRADIENT2-KEYS = (
  "low",
  "mid",
  "high",
  "midpoint",
  "name",
  "limits",
  "oob",
  "breaks",
  "labels",
)
#let _GRADIENTN-KEYS = (
  "colours",
  "name",
  "limits",
  "oob",
  "breaks",
  "labels",
)
#let _GREY-KEYS = ("start", "end", "name", "limits", "oob", "labels")
#let _HUE-KEYS = (
  "hue",
  "chroma",
  "luminance",
  "name",
  "limits",
  "oob",
  "labels",
)
#let _DISTILLER-KEYS = (
  "palette",
  "direction",
  "name",
  "limits",
  "oob",
  "breaks",
  "labels",
)
#let _STEPS-KEYS = (
  "low",
  "high",
  "n-breaks",
  "breaks",
  "name",
  "limits",
  "oob",
  "labels",
)
#let _STEPS2-KEYS = (
  "low",
  "mid",
  "high",
  "midpoint",
  "n-breaks",
  "breaks",
  "name",
  "limits",
  "oob",
  "labels",
)
#let _STEPSN-KEYS = (
  "colours",
  "n-breaks",
  "breaks",
  "name",
  "limits",
  "oob",
  "labels",
)
#let _FERMENTER-KEYS = (
  "palette",
  "n-breaks",
  "breaks",
  "direction",
  "name",
  "limits",
  "oob",
  "labels",
)
#let _RANGE-CONTINUOUS-KEYS = (
  "name",
  "range",
  "limits",
  "oob",
  "breaks",
  "labels",
)
#let _RANGE-BINNED-KEYS = (
  "n-breaks",
  "breaks",
  "range",
  "name",
  "limits",
  "oob",
  "labels",
)

// Wrap a builder that takes the aesthetic as its first positional argument.
#let _aes(builder, keys) = (
  call: (aesthetic, ..args) => builder(aesthetic, ..args),
  keys: keys,
)

// Wrap a builder that binds a single aesthetic and ignores the key.
#let _solo(builder, keys) = (
  call: (aesthetic, ..args) => builder(..args),
  keys: keys,
)

// A colour/fill family shares one aesthetic-taking builder across both.
#let _cf(builder, keys) = {
  let entry = _aes(builder, keys)
  (colour: entry, fill: entry)
}

// A position family shares one builder across the x and y axes.
#let _xy(entry) = (x: entry, y: entry)

// Position transform families pass the transform name as the builder's second
// positional; shared across the x and y axes.
#let _trans(name) = _xy((
  call: (aesthetic, ..args) => _transform-scale(aesthetic, name, ..args),
  keys: _POS-TRANSFORM-KEYS,
))

// Temporal families inject their per-family `date-format` default when the
// caller left it unset, matching the retired `scale-date` wrappers.
#let _temporal(temporal, fmt) = _xy((
  call: (aesthetic, ..args) => {
    let named = args.named()
    if "date-format" not in named { named.insert("date-format", fmt) }
    _temporal-scale(aesthetic, temporal, ..named)
  },
  keys: _TEMPORAL-KEYS,
))

// family -> (aesthetic -> (call: builder(aesthetic, ..args), keys: (...)))
#let _SCALE-DISPATCH = (
  continuous: (
    x: _aes(_continuous-scale, _POS-CONTINUOUS-KEYS),
    y: _aes(_continuous-scale, _POS-CONTINUOUS-KEYS),
    colour: _aes(_scale-continuous, _COLOUR-CONTINUOUS-KEYS),
    fill: _aes(_scale-continuous, _COLOUR-CONTINUOUS-KEYS),
    size: _solo(_size-continuous, _RANGE-CONTINUOUS-KEYS),
    alpha: _solo(_alpha-continuous, _RANGE-CONTINUOUS-KEYS),
    linewidth: _solo(_linewidth-continuous, _RANGE-CONTINUOUS-KEYS),
    stroke: _solo(_stroke-continuous, _RANGE-CONTINUOUS-KEYS),
    linetype: _solo(_linetype-binned, _PALETTE-BINNED-KEYS),
  ),
  discrete: (
    x: _aes(_discrete-scale, _POS-DISCRETE-KEYS),
    y: _aes(_discrete-scale, _POS-DISCRETE-KEYS),
    colour: _aes(_scale-discrete, _PALETTE-DISCRETE-KEYS),
    fill: _aes(_scale-discrete, _PALETTE-DISCRETE-KEYS),
    shape: _solo(_shape-discrete, _PALETTE-DISCRETE-KEYS),
    linetype: _solo(_linetype-discrete, _PALETTE-DISCRETE-KEYS),
  ),
  binned: (
    x: _aes(_binned-scale, _POS-BINNED-KEYS),
    y: _aes(_binned-scale, _POS-BINNED-KEYS),
    size: _solo(_size-binned, _RANGE-BINNED-KEYS),
    alpha: _solo(_alpha-binned, _RANGE-BINNED-KEYS),
    linewidth: _solo(_linewidth-binned, _RANGE-BINNED-KEYS),
    stroke: _solo(_stroke-binned, _RANGE-BINNED-KEYS),
    shape: _solo(_shape-binned, _PALETTE-BINNED-KEYS),
    linetype: _solo(_linetype-binned, _PALETTE-BINNED-KEYS),
  ),
  manual: (
    colour: _aes(_scale-manual, _MANUAL-KEYS),
    fill: _aes(_scale-manual, _MANUAL-KEYS),
    alpha: _solo(_alpha-manual, _MANUAL-KEYS),
    size: _solo(_size-manual, _MANUAL-KEYS),
    linewidth: _solo(_linewidth-manual, _MANUAL-KEYS),
    stroke: _solo(_stroke-manual, _MANUAL-KEYS),
    shape: _solo(_shape-manual, _MANUAL-KEYS),
    linetype: _solo(_linetype-manual, _MANUAL-KEYS),
  ),
  identity: (
    colour: _aes(_scale-identity, _IDENTITY-KEYS),
    fill: _aes(_scale-identity, _IDENTITY-KEYS),
    alpha: _solo(_alpha-identity, _IDENTITY-KEYS),
    size: _solo(_size-identity, _IDENTITY-KEYS),
    linewidth: _solo(_linewidth-identity, _IDENTITY-KEYS),
    stroke: _solo(_stroke-identity, _IDENTITY-KEYS),
    shape: _solo(_shape-identity, _IDENTITY-KEYS),
    linetype: _solo(_linetype-identity, _IDENTITY-KEYS),
  ),
  viridis-d: _cf(_scale-viridis-d, _VIRIDIS-D-KEYS),
  viridis-c: _cf(_scale-viridis-c, _VIRIDIS-C-KEYS),
  viridis-b: _cf(_scale-viridis-b, _VIRIDIS-B-KEYS),
  brewer: _cf(_scale-brewer, _BREWER-KEYS),
  okabe-ito: _cf(_scale-okabe-ito, _OKABE-ITO-KEYS),
  gradient: _cf(_scale-gradient, _GRADIENT-KEYS),
  gradient2: _cf(_scale-gradient2, _GRADIENT2-KEYS),
  gradientn: _cf(_scale-gradientn, _GRADIENTN-KEYS),
  grey: _cf(_scale-grey, _GREY-KEYS),
  hue: _cf(_scale-hue, _HUE-KEYS),
  distiller: _cf(_scale-distiller, _DISTILLER-KEYS),
  steps: _cf(_scale-steps, _STEPS-KEYS),
  steps2: _cf(_scale-steps2, _STEPS2-KEYS),
  stepsn: _cf(_scale-stepsn, _STEPSN-KEYS),
  fermenter: _cf(_scale-fermenter, _FERMENTER-KEYS),
  log10: _trans("log10"),
  sqrt: _trans("sqrt"),
  reverse: _trans("reverse"),
  date: _temporal("date", "[year]-[month repr:numerical]-[day]"),
  datetime: _temporal(
    "datetime",
    "[year]-[month repr:numerical]-[day] [hour]:[minute]",
  ),
  time: _temporal("time", "[hour]:[minute]"),
  area: (size: _solo(_size-area, _RANGE-CONTINUOUS-KEYS)),
  binned-area: (size: _solo(_size-binned-area, _RANGE-BINNED-KEYS)),
  radius: (size: _solo(_size-continuous, _RANGE-CONTINUOUS-KEYS)),
)

// Dispatch a deferred scale stub onto `aesthetic`, failing loudly when the
// family is not available for that aesthetic.
#let bind-scale(aesthetic, stub) = {
  let family = stub.name
  let by-aesthetic = _SCALE-DISPATCH.at(family, default: none)
  if by-aesthetic == none {
    fail("scales", "unknown scale family " + repr(family))
  }
  if aesthetic not in by-aesthetic {
    fail(
      "scales",
      "scale `"
        + family
        + "` is not available for the `"
        + aesthetic
        + "` aesthetic",
      hint: "`"
        + family
        + "` applies to "
        + quote-each(by-aesthetic.keys())
        + ".",
    )
  }
  let entry = by-aesthetic.at(aesthetic)
  if stub.args.pos().len() != 0 {
    fail(
      "scales",
      "scale-" + family + " takes no positional arguments",
      hint: "Pass options as named arguments.",
    )
  }
  for key in stub.args.named().keys() {
    if key not in entry.keys {
      fail-enum(
        "scales",
        "scale-" + family + " argument for " + aesthetic,
        key,
        entry.keys,
      )
    }
  }
  (entry.call)(aesthetic, ..stub.args)
}
