///! Legend key constants.
///!
///! A legend key stands for a layer's mark, so it draws with what the mark
///! draws with when no scale supplies a value: the constants pinned on the
///! layer, and the geom defaults. The legend merges these under the values of
///! the trained scales, so a mapped aesthetic always wins.

#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-fill, resolve-geom-linewidth,
)

// Mark fallbacks the geoms use when neither the layer nor the theme sets a
// value.
#let _POINT-SIZE = 1.5pt
#let _LINE-THICKNESS = 0.8pt
#let _POINTRANGE-SIZE = 2.5pt

// A pinned param is any value but the `auto` and `none` sentinels.
#let _pinned(params, name) = {
  let v = params.at(name, default: auto)
  if v == auto or v == none { none } else { v }
}

// Keep the fields that carry a value.
#let _present(fields) = {
  let out = (:)
  for (name, v) in fields {
    if v != none { out.insert(name, v) }
  }
  out
}

// Pointrange paints its point solid in the colour, sized by the layer, with no
// outline of its own.
#let _pointrange-constants(layer) = {
  let params = layer.params
  _present((
    size: if type(_pinned(params, "size")) == length {
      params.size
    } else { _POINTRANGE-SIZE },
    solid: true,
    alpha: _pinned(params, "alpha"),
    colour: _pinned(params, "colour"),
    fill: _pinned(params, "fill"),
  ))
}

#let _point-constants(layer, mapping, defaults) = {
  if layer.name == "pointrange" { return _pointrange-constants(layer) }
  let params = layer.params
  let (colour, fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(defaults),
    resolve-geom-fill(defaults, role: "paper"),
  )
  let pinned-stroke = _pinned(params, "stroke")
  // A fill that the layer maps is another guide's, not this one's. The key
  // gets a neutral ink fill, unless its guide maps the outline colour, which
  // is a ring (`_key-bundle` decides).
  let fill-is-mapped = (
    _pinned(params, "fill") == none
      and mapping != none
      and mapping.at("fill", default: none) != none
  )
  _present((
    shape: _pinned(params, "shape"),
    size: if type(_pinned(params, "size")) == length {
      params.size
    } else { _POINT-SIZE },
    stroke: if type(pinned-stroke) == length {
      pinned-stroke
    } else { resolve-geom-linewidth(defaults) },
    alpha: _pinned(params, "alpha"),
    colour: if _pinned(params, "colour") != none {
      params.colour
    } else { colour },
    fill: if _pinned(params, "fill") != none {
      params.fill
    } else if fill-is-mapped { none } else { fill },
    neutral-fill: if fill-is-mapped { resolve-geom-colour(defaults) } else {
      none
    },
  ))
}

#let _line-constants(layer, defaults) = {
  let params = layer.params
  let pinned-width = if type(_pinned(params, "linewidth")) == length {
    params.linewidth
  } else if type(_pinned(params, "stroke")) == length {
    params.stroke
  } else { none }
  _present((
    linetype: _pinned(params, "linetype"),
    linewidth: if pinned-width != none { pinned-width } else {
      resolve-geom-linewidth(defaults, fallback: _LINE-THICKNESS)
    },
    alpha: _pinned(params, "alpha"),
    colour: _pinned(params, "colour"),
  ))
}

/// The values a layer's mark draws with when no scale supplies them, for the legend key of kind `kind`.
///
/// - layer: The layer dictionary providing `params`.
/// - mapping: The layer's mapping merged with the plot mapping, or `none`.
/// - defaults: Element-geom record from `resolve-geom-defaults`.
/// - kind: The key kind: `"point"` or `"line"`. Any other kind has no constants.
///
/// Returns: A dictionary of key constants, empty for other kinds.
#let key-constants(layer, mapping, defaults, kind) = {
  if kind == "point" { _point-constants(layer, mapping, defaults) } else if (
    kind == "line"
  ) { _line-constants(layer, defaults) } else { (:) }
}
