///! The guide context: the parameters a guide part is drawn under.
///!
///! One part drawn on four sides is the point of the layer, so a part never
///! branches on the side itself. It reads three injected values instead:
///! `position` (which side, or the radial sweep), `aesthetic` (which decides an
///! axis context from a legend one), and `direction` (which fixes the
///! orientation where the side does not, as on a colour bar). Everything else
///! follows: which theme surfaces apply, which of width and height is the
///! thickness, and which way the part grows away from the panel.
///!
///! `place` maps a position along the guide to a canvas point, and is the only
///! thing a radial guide changes. `(frac, across)` goes in, cetz canvas cm
///! comes out: `frac` runs 0 to 1 along the guide, `across` is the distance
///! away from the panel. A cartesian side, the theta sweep, and the radius each
///! supply their own closure, so a part draws the same way under all three.
///!
///! The scale and the theme both live downstream of `src/guide/`, so this
///! module takes closures rather than reaching forward for either.

#import "../utils/errors.typ": fail, fail-enum, fail-type
#import "../utils/radial.typ": polar-canvas

// Where a guide sits. The four cartesian sides, the two radial positions, and
// the panel overlay.
#let POSITIONS = ("top", "right", "bottom", "left", "theta", "r", "inside")

// The cartesian sides, the only positions with an along/across split.
#let SIDES = ("top", "right", "bottom", "left")

#let DIRECTIONS = ("horizontal", "vertical")

// Axis context or legend context. Derived from the aesthetic, never supplied:
// the positional channels carry an axis, everything else carries a legend.
// This is what selects the theme surfaces a part resolves against.
#let _mode-of(aesthetic) = if (
  aesthetic == "x"
    or aesthetic == "y"
    or aesthetic == "theta"
    or aesthetic == "r"
) { "axis" } else { "legend" }

// The along and across axes of a cartesian side, and the sign that points away
// from the panel. A part reads these instead of branching on the side, so one
// routine serves all four.
//
// `top` and `right` grow in the positive direction, `bottom` and `left` in the
// negative one.
#let _axes-of(position) = {
  if position == "top" or position == "bottom" {
    (
      along: "x",
      across: "y",
      sign: if position == "bottom" { -1 } else { 1 },
    )
  } else if position == "left" or position == "right" {
    (
      along: "y",
      across: "x",
      sign: if position == "left" { -1 } else { 1 },
    )
  } else {
    fail-enum("guide-gctx", "position", position, SIDES)
  }
}

// Order a pair the way the side runs: `(along, across)` on a horizontal side,
// swapped on a vertical one. One horizontal routine then serves every side.
#let side-pt(axes, along, across) = if axes.along == "x" {
  (along, across)
} else {
  (across, along)
}

// The direction a side implies when the guide did not state one: a part on the
// top or bottom reads horizontally, everything else vertically.
#let direction-for(position) = if (
  position == "top" or position == "bottom"
) { "horizontal" } else { "vertical" }

// `place` for a cartesian side. `frac` runs along the panel span in the
// direction the side reads, and `across` grows away from the panel edge the
// side sits on.
#let place-cartesian(position, px-range, py-range) = {
  let axes = _axes-of(position)
  let (px-lo, px-hi) = px-range
  let (py-lo, py-hi) = py-range
  if axes.along == "x" {
    let edge = if position == "bottom" { py-lo } else { py-hi }
    (frac, across) => (
      px-lo + frac * (px-hi - px-lo),
      edge + axes.sign * across,
    )
  } else {
    let edge = if position == "left" { px-lo } else { px-hi }
    (frac, across) => (
      edge + axes.sign * across,
      py-lo + frac * (py-hi - py-lo),
    )
  }
}

// `place` for the angular axis of `coord-radial`. `frac` runs along the sweep
// and `across` grows outward from the outer arc, so a tick still points away
// from the panel.
#let place-theta(radial) = {
  let (theta-lo, theta-hi) = radial.theta-range
  let sweep = theta-hi - theta-lo
  (frac, across) => polar-canvas(
    radial,
    theta-lo + frac * sweep,
    radial.r-max + across,
  )
}

// `place` for the radial axis of `coord-radial`. `frac` runs out along the
// radius from the centre. An r label sits on the radius rather than offset from
// it, so `across` is ignored, which is why the radial composition carries no
// ticks and no line.
#let place-r(radial) = {
  let (theta-lo, _) = radial.theta-range
  (frac, _) => polar-canvas(radial, theta-lo, frac * radial.r-max)
}

// Build the context a guide part is drawn under.
//
// `position` and `aesthetic` are required; everything else has a default so a
// measurement-only caller can build one without a canvas. `direction` resolves
// from the position when left `auto`. `place` is required to draw and may stay
// `none` to measure, since a measurement never asks where a point lands.
#let gctx(
  position,
  aesthetic,
  direction: auto,
  axis: auto,
  axes: auto,
  place: none,
  span: none,
  sweep: none,
  tick-length: none,
  surface-stroke: none,
  text-style: none,
  key-draw: none,
  bar-draw: none,
  tick-gap: 0.1,
) = {
  if type(aesthetic) != str {
    fail-type("guide-gctx", "aesthetic", aesthetic, "an aesthetic name")
  }
  if not POSITIONS.contains(position) {
    fail-enum("guide-gctx", "position", position, POSITIONS)
  }
  let dir = if direction == auto { direction-for(position) } else {
    direction
  }
  if not DIRECTIONS.contains(dir) {
    fail-enum("guide-gctx", "direction", dir, DIRECTIONS)
  }
  if axes != auto {
    if (
      type(axes) != dictionary
        or ("along", "across", "sign").any(k => (
          k not in axes
        ))
    ) {
      fail-type(
        "guide-gctx",
        "axes",
        axes,
        "a dictionary with `along`, `across` and `sign`",
      )
    }
    if not ("x", "y").contains(axes.along) {
      fail-enum("guide-gctx", "axes.along", axes.along, ("x", "y"))
    }
    if axes.across == axes.along or not ("x", "y").contains(axes.across) {
      fail-enum(
        "guide-gctx",
        "axes.across",
        axes.across,
        (if axes.along == "x" { "y" } else { "x" },),
      )
    }
    if not (-1, 1).contains(axes.sign) {
      fail-enum("guide-gctx", "axes.sign", axes.sign, (-1, 1))
    }
  }
  let mode = _mode-of(aesthetic)
  // The axis the guide runs along, which the per-axis tick tiers are keyed on
  // and which picks the side surfaces under a radial coord. A cartesian side
  // derives it; `theta` and `r` cannot, so the caller states it. An axis guide
  // without one would resolve a surface name against `none`, so it fails here
  // rather than at the draw site.
  let ax = if axis != auto { axis } else if SIDES.contains(position) {
    _axes-of(position).along
  } else { none }
  if mode == "axis" and ax == none {
    fail(
      "guide-gctx",
      "an axis guide at " + repr(position) + " has no axis",
      hint: "Pass `axis: \"x\"` or `axis: \"y\"`; only a cartesian side can "
        + "derive it.",
    )
  }
  (
    position: position,
    aesthetic: aesthetic,
    mode: mode,
    direction: dir,
    axis: ax,
    // Which canvas axis `across` runs along, and the sign that points away from
    // the panel. This belongs to the `place` closure, not to the side: a
    // cartesian axis grows away from the edge it sits on, but a legend box
    // stacks its parts downward whichever side it sits on, so a right-side
    // legend still puts its title above its keys. A cartesian side derives it;
    // everything else takes the downward default or states its own.
    // Only an axis takes its orientation from the side it sits on. A legend box
    // stacks downward whichever side it sits on, so a right-side legend still
    // puts its title above its keys.
    axes: if axes != auto { axes } else if (
      mode == "axis" and SIDES.contains(position)
    ) { _axes-of(position) } else { (along: "x", across: "y", sign: -1) },
    place: place,
    // The centimetres a full `frac` covers. A part that runs on fractions never
    // needs it; a part that lays its own contents out in centimetres, as a key
    // grid does with its columns, divides by it to reach `place`. `none` where
    // the caller stated none, which such a part refuses to draw under.
    span: span,
    // The radians a full `frac` covers, on a position that sweeps. A part that
    // runs along the guide is a straight segment where this is `none` and a
    // sampled polyline where it is not, because the samples a curve needs
    // follow the angle it turns through rather than its length.
    sweep: sweep,
    // `(surface) -> cm` for a tick surface, and `(surface) -> stroke | none`
    // for any stroked surface. Both injected because the theme lives downstream
    // of this module.
    tick-length: tick-length,
    surface-stroke: surface-stroke,
    // `(surface) -> (render: (label) -> content)` for a text surface. Text is
    // typeset by the render stage, which owns the theme and the measurement
    // context, so a primitive only asks for the rendered content.
    text-style: text-style,
    // `(key, value, point, radius) -> emits cetz` for one legend key glyph.
    // Injected for the same reason as the text style: a glyph is inked from the
    // aesthetics the value resolves to, and the scales live downstream of this
    // module.
    key-draw: key-draw,
    // `(lo, hi, horizontal) -> emits cetz` for the body of a colour bar, given
    // the two canvas corners of its strip. Injected for the same reason as the
    // key glyph: the gradient, the bins and the frame all read a palette and a
    // trained scale.
    bar-draw: bar-draw,
    // Cm between a tick and its label in an axis context. Mirrors the chrome
    // stage's `_TICK-LABEL-GAP`, passed in rather than imported.
    tick-gap: tick-gap,
  )
}
