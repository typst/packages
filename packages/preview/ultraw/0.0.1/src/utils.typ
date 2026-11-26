// ====================
// Collections manipulation
// ====================

/// Update the keys of `d1` with values from `d2`.
#let filter-add-dict(d1, d2) = {
  for k in d2.keys() {
    if not k in d1 {
      let _ = d2.remove(k)
    }
  }

  return d1 + d2
}

/// Keep the known keys of a dictionary of settings (the unknown ones being ignored).
///
/// - d (dictionary): The settings.
/// - allowed (array): The known keys.
/// -> dictionary
#let known-keys(d, allowed) = (
  d.pairs().filter(((k, _)) => k in allowed).to-dict()
)

/// Wrap a single element given without a trailing comma (a dictionary, or a pair whose first value is an integer) into an array.
#let single-to-list(a) = if (
  type(a) == dictionary or (a.len() == 2 and type(a.first()) in (int, alignment))
) {
  (a,)
} else {
  a
}

#let single-to-list-map(a, f) = {
  let first-try = f(a)
  if first-try != none { (first-try,) } else { a.map(f) }
}

/// Return a new dictionary containing the same keys as `d` but with values the ones of `d` with `f` applied on them.
#let map-dict(d, f) = {
  let new-d = (:)
  for (k, v) in d.pairs() {
    new-d.insert(k, f(v))
  }
  return new-d
}

/// Create a dictionary from a list of pairs `(keys, value)` where all the keys in `keys` map to `value`.
#let keys-value-to-dict(a) = {
  let d = (:)
  for (ks, v) in a {
    for k in ks {
      d.insert(k, v)
    }
  }
  return d
}

// ====================
// Insets
// ====================

/// Create an inset with only left and right fields from a normal inset.
#let left-right-inset(inset) = if type(inset) == dictionary {
  (
    left: if "left" in inset { inset.left } else if "x" in inset {
      inset.x
    } else if "rest" in inset { inset.rest } else { 0mm },
    right: if "right" in inset { inset.right } else if "x" in inset {
      inset.x
    } else if "rest" in inset { inset.rest } else { 0mm },
  )
} else {
  (left: inset, right: inset)
}

/// Create an inset with only left and right fields inherited from the given `inset`, top and bottom fields are computed with the `line-spacing`.
#let line-inset(inset, line-spacing) = (
  left-right-inset(inset) + (top: line-spacing / 2, bottom: line-spacing / 2)
)

/// The top and bottom fields of an inset.
#let vertical-inset(inset) = if type(inset) == dictionary {
  (
    top: if "top" in inset { inset.top } else if "y" in inset {
      inset.y
    } else if "rest" in inset { inset.rest } else { 0pt },
    bottom: if "bottom" in inset { inset.bottom } else if "y" in inset {
      inset.y
    } else if "rest" in inset { inset.rest } else { 0pt },
  )
} else {
  (top: inset, bottom: inset)
}

/// Add some space at the top and the bottom of an inset with top and bottom fields.
#let grow-inset(inset, extra) = (
  inset + (top: inset.top + extra.top, bottom: inset.bottom + extra.bottom)
)

/// Format an inset to have left, right, top, and bottom fields.
#let full-inset(inset) = (
  if type(inset) == dictionary { inset } else { (top: inset, bottom: inset) }
    + left-right-inset(inset)
)

// ====================
// Radius
// ====================

/// Format a radius corner.
#let radius-corner(v, h, radius) = radius.at(v + "-" + h, default: radius.at(
  v,
  default: radius.at(
    h,
    default: 0mm,
  ),
))

/// Format a radius to have top-left, top-right, bottom-left, and bottom-right fields.
#let full-radius(radius) = (
  if type(radius) == dictionary {
    (
      top-left: radius-corner("top", "left", radius),
      top-right: radius-corner("top", "right", radius),
      bottom-left: radius-corner("bottom", "left", radius),
      bottom-right: radius-corner("bottom", "right", radius),
    )
  } else {
    (
      top-left: radius,
      top-right: radius,
      bottom-left: radius,
      bottom-right: radius,
    )
  }
)

// ====================
// Stroke
// ====================

/// Format a stroke to have left, right, top, and bottom fields.
#let full-stroke(stroke) = (
  if type(stroke) == dictionary {
    (top: none, left: none, right: none, bottom: none) + stroke
  } else {
    (
      top: stroke,
      left: stroke,
      right: stroke,
      bottom: stroke,
    )
  }
)

/// The fields of a stroke given as a dictionary.
#let stroke-fields = (
  "paint",
  "thickness",
  "cap",
  "join",
  "dash",
  "miter-limit",
)

/// Give a length to a stroke without one: a paint (color, gradient or tiling) or a stroke whose thickness is not specified. Dictionaries of strokes by side are handled side by side.
///
/// - s (any): The stroke.
/// - length (length): The default length.
/// -> any
#let with-default-thickness(s, length) = if s == none or s == auto {
  s
} else if type(s) in (color, gradient, tiling) {
  length + s
} else if (
  type(s) == dictionary
    and s.len() > 0
    and s.keys().all(k => k in stroke-fields)
) {
  with-default-thickness(stroke(s), length)
} else if type(s) == dictionary {
  // A stroke per side
  s.pairs().map(((k, v)) => (k, with-default-thickness(v, length))).to-dict()
} else if type(s) == stroke and s.thickness == auto {
  let fields = (
    paint: s.paint,
    thickness: length,
    cap: s.cap,
    join: s.join,
    dash: s.dash,
    miter-limit: s.miter-limit,
  )
  stroke(fields.pairs().filter(((k, v)) => v != auto).to-dict())
} else {
  s
}


/// Some content in a color (`none` for the color of the text).
#let colored(color, it) = if color == none or it == none { it } else {
  text(fill: color, it)
}

/// The outset of a cell with a fill on its inner sides (the ones absent from its stroke, the sides of the grid being present even without stroke): its fill covers the seam with the next cells (drawn over it: the next row below and the next column on the right).
///
/// - stroke (none, dictionary): The sides of the stroke.
/// - fill (none, color, gradient, tiling):
/// -> dictionary
#let seam-outset(stroke, fill) = if fill == none { (:) } else {
  let stroke = if stroke == none { (:) } else { stroke }
  ("bottom", "right")
    .filter(side => type(stroke) == dictionary and side not in stroke)
    .map(side => (side, .5pt))
    .to-dict()
}
