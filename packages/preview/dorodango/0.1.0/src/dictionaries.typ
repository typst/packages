#import "validation.typ": *

// `Sides`' precedence: the side's own key, then its axis key, then `rest`,
// then the parameter's default (which is what `rect`'s folding fields fall
// back to for any side the caller left out).
#let _sides-from-dict(val, default: none) = {
  let pick(side, axis) = val.at(
    side,
    default: val.at(axis, default: val.at("rest", default: default)),
  )
  (
    top: pick("top", "y"),
    right: pick("right", "x"),
    bottom: pick("bottom", "y"),
    left: pick("left", "x"),
  )
}

#let _resolve-edges(val, default: 0pt) = {
  if type(val) == dictionary { _sides-from-dict(val, default: default) } else {
    (top: val, right: val, bottom: val, left: val)
  }
}

// `Corners`' precedence, which is *not* the same shape as `Sides`': a corner
// takes its own key first, then the vertical side key, then the horizontal
// one -- and `rest` is folded in at the side level, so `rest` outranks
// `left`/`right` whenever the matching `top`/`bottom` key is absent. Hence
// `(left: 3pt, rest: 4pt)` is a uniform 4pt in `rect`, and
// `(top: 20pt, left: 5pt)` puts 20pt on the top-left corner.
#let _resolve-corner-dict(val, default: 0pt) = {
  let rest = val.at("rest", default: none)
  let side(name) = val.at(name, default: rest)
  let top = side("top")
  let bottom = side("bottom")
  let left = side("left")
  let right = side("right")
  let corner(name, vertical, horizontal) = {
    let own = val.at(name, default: none)
    let resolved = if own != none { own } else if vertical != none {
      vertical
    } else { horizontal }
    if resolved == none { default } else { resolved }
  }
  (
    top-left: corner("top-left", top, left),
    top-right: corner("top-right", top, right),
    bottom-right: corner("bottom-right", bottom, right),
    bottom-left: corner("bottom-left", bottom, left),
  )
}

#let _resolve-corners(val, default: 0pt) = {
  if type(val) == dictionary {
    _resolve-corner-dict(val, default: default)
  } else {
    (
      top-left: val,
      top-right: val,
      bottom-right: val,
      bottom-left: val,
    )
  }
}

// Splits a `stroke` argument into the four sides `rect` would stroke.
// A per-side dictionary suppresses the `auto` default on the sides it omits:
// `rect(stroke: (top: red))` strokes only the top edge, and `rect(stroke: (:))`
// strokes nothing. `auto` itself means a 1pt black stroke, but only when
// nothing fills the shape.
#let _stroke-sides(val, has-fill) = {
  if val == auto {
    let s = if has-fill { none } else { 1pt + black }
    (top: s, right: s, bottom: s, left: s)
  } else if _is-side-dict(val) {
    _sides-from-dict(val, default: none)
  } else {
    (top: val, right: val, bottom: val, left: val)
  }
}

// The concrete stroke `rect` ends up drawing with, `auto` fields filled in.
#let _fixed(val) = {
  if val == none { return none }
  let s = stroke(val)
  (
    paint: if s.paint == auto { black } else { s.paint },
    thickness: if s.thickness == auto { 1pt } else { s.thickness },
    cap: if s.cap == auto { "butt" } else { s.cap },
    join: if s.join == auto { "miter" } else { s.join },
    dash: if s.dash == auto { none } else { s.dash },
    miter-limit: if s.miter-limit == auto { 4.0 } else { s.miter-limit },
  )
}

#let _is-solid(fixed) = (
  fixed == none
    or fixed.dash == none
    or (
      type(fixed.dash) == dictionary
        and fixed.dash.at("array", default: ()).len() == 0
    )
)

// A gradient or a tiling never compares equal to itself (`g == g` is `false`),
// so two strokes have to be told apart through their representation.
#let _stroke-eq(a, b) = repr(a) == repr(b)

// Whether the two strokes meeting at a corner may be drawn as one piece.
// Mirrors `ControlPoints::same`: solid strokes are filled, so only the paint
// and the dash pattern have to agree; a dashed stroke is really stroked, so
// its cap and thickness matter too.
#let _same-stroke(a, b) = {
  if a == none and b == none {
    true
  } else if a == none or b == none {
    false
  } else {
    let filled-same = _stroke-eq(a.paint, b.paint) and a.dash == b.dash
    let stroked-same = a.cap == b.cap and a.thickness == b.thickness
    filled-same and (_is-solid(a) or stroked-same)
  }
}
