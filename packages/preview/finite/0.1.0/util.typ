#import "@preview/t4t:0.3.0": get, def, is, assert, math

#import "@preview/cetz:0.0.2": vector, matrix, draw
#import draw: util, styles, cmd, coordinate
#import util.bezier: quadratic-point, quadratic-derivative

// =================================
//  Defaults
// =================================

#let default-style = (
  state: (
    fill: auto,
    stroke: auto,
    radius: .6,

    label: (
      text: auto,
      size: auto
    )
  ),
  transition: (
    curve: 1.0,
    stroke: auto,

    label: (
      text: "",
      size: 1em,
      color: auto,
      pos: .5,
      dist: .33,
      angle: auto
    )
  )
)

// =================================
//  Vectors
// =================================

/// Set the length of a vactor.
#let vector-set-len(v, len) = if vector.len(v) == 0 {
  return v
} else {
  return vector.scale(vector.norm(v), len)
}

/// Compute a normal for a 2d vector. The normal will be pointing to the right
/// of the original vector.
#let vector-normal(v) = vector.norm((-v.at(1), v.at(0), 0))

/// Returns a vector for an alignment.
#let align-to-vec( a ) = {
  let v = (
    ("none": 0, "left": -1, "right": 1).at(repr(get.x-align(a, default:none))),
    ("none": 0, "top": 1, "bottom": -1).at(repr(get.y-align(a, default:none)))
  )
  return vector.norm(v)
}


// =================================
//  Bezier
// =================================

/// Compute a normal vector for a point on a quadratic bezier curve.
#let quadratic-normal(a, b, c, t) = {
  let qd = quadratic-derivative(a, b, c, t)
  if vector.len(qd) == 0 {
    return (0, 1, 0)
  } else {
    return vector-normal(qd)
  }
}

/// Compute the mid point of a quadratic bezier curve.
#let mid-point(a, b, c) = quadratic-point(a, b, c, .5)


// =================================
//  Helpers
// =================================

/// Calculate the controlpoint for a transition.
#let ctrl-pt(a, b, curve:1) = {
  let ab = vector.sub(b, a)
  vector.add(
    vector.add(
      a,
      vector.scale(ab, .5)),
    vector.scale(
      vector-normal(ab),
      curve))
}

/// Calculate the direction vector for a transition mark (arrowhead)
#let mark-dir(a, b, c, scale:1) = vector-set-len(quadratic-derivative(a, b, c, 1), scale)

/// Calculate the location for a transitions label, based
/// on its bezier points.
#let label-pt(a, b, c, style, loop:false) = {
  let pos = style.label.at("pos", default:.5)
  let dist = style.label.at("dist", default:.33)
  let curve = style.label.at("curve", default:1)

  let pt = quadratic-point(a, b, c, pos)
  let n = quadratic-normal(a, b, c, pos)

  if loop == (curve > 0) {
    dist *= -1
  }

  return vector.add(pt,
    vector.scale(n, dist))
}

/// Calculate start, end and ctrl points for a transition.
///
/// - start (vector): Center of the start state.
/// - end (vector): Center of the end state.
/// - start-radius (length): Radius of the start state.
/// - end-radius (length): Radius of the end state.
/// - curve (float): Curvature of the transition.
#let transition-pts(start, end, start-radius, end-radius, curve:1) = {
  // Is it a loop?
  if start == end {
    start = vector.add(
      start,
      vector-set-len(
        (1, 2),
        start-radius))
    end = vector.add(
      end,
      vector-set-len(
        (1, -2),
        -end-radius))

    if curve < 0 {
      (start, end) = (end, start)
    } else if curve == 0 {
      curve = start-radius
    }
    return (
      start,
      end,
      ctrl-pt(start, end, curve: -2*curve)
    )
  } else {
    let ctrl = ctrl-pt(start, end, curve:curve)
    start = vector.add(
      start,
      vector-set-len(
        vector.sub(
          ctrl,
          start),
        start-radius))
    end = vector.add(
      end,
      vector-set-len(
        vector.sub(
          end,
          ctrl),
        -end-radius))
    return (
      start,
      end,
      ctrl
    )
  }
}

/// Fits (text) content inside the available space.
///
/// - ctx (dictionary): The canvas context.
/// - content (string, content): The content to fit.
/// - size (length,auto): The initial text size.
/// - min-size (length): The minimal text size to set.
#let fit-content( ctx, width, height, content, size:auto, min-size:6pt ) = {
  let s = def.if-auto(ctx.length, size)

  let m = (width: 2*width, height: 2*height)
  while (m.height > height or m.width > height) and s > min-size {
    s = s*.88
    m = measure({set text(s); content}, ctx.typst-style)
  }
  s = calc.max(min-size, s)
  {set text(s); content}
}

/// Prepares the CeTZ context for use with finite
#let prepare-ctx(ctx, force:false) = {
  if force or "finite" not in ctx {
    // supposed to store state information at some point
    ctx.insert("finite", (states:()))

    // add default state styles to context
    if "state" not in ctx.style {
      ctx.style.insert("state", default-style.state)
    } else {
      if "label" in ctx.style.state and not is.dict(ctx.style.state.label) {
        ctx.style.state.label = (text: ctx.style.state.label)
      }
      ctx.style.state = styles.resolve(default-style.state, ctx.style.state)
    }

    // add default transition styles to context
    if "transition" not in ctx.style {
      ctx.style.insert("transition", default-style.transition)
    } else {
      if "label" in ctx.style.transition and not is.dict(ctx.style.transition.label) {
        ctx.style.transition.label = (text: ctx.style.transition.label)
      }
      ctx.style.transition = styles.resolve(default-style.transition, ctx.style.transition)
    }
  }

  return ctx
}


// Unused

#let calc-bounds( positions ) = {
  let bounds = (
    x: positions.first().at(0),
    y: positions.first().at(1),
    width: positions.first().at(0),
    height: positions.first().at(1)
  )
  for (x,y) in positions {
    bounds.x = calc.min(bounds.x, x)
    bounds.y = calc.min(bounds.y, y)
    bounds.width = calc.max(bounds.width, x)
    bounds.height = calc.max(bounds.height, y)
  }
  bounds.width = bounds.width - bounds.x
  bounds.height = bounds.height - bounds.y
  return bounds
}

#let calc-shift(anchor, bounds:none) = {
  let shift = (x: -.5, y: -.5)
  if anchor.ends-with("right") {
    shift.x -= .5
  } else if anchor.ends-with("left") {
    shift.x += .5
  }
  if anchor.starts-with("top") {
    shift.y -= .5
  } else if anchor.starts-with("bottom") {
    shift.y += .5
  }
  if bounds != none {
    shift.x *= bounds.width
    shift.y *= bounds.height
  }
  return shift
}

#let shift-by-anchor(positions, anchor) = {
  let bounds = calc-bounds(positions.values())
  let shift = calc-shift(anchor, bounds:bounds)

  for (name, pos) in positions {
    let (x, y) = pos
    positions.at(name) = (x + shift.x, y + shift.y)
  }

  return positions
}

#let resolve-radius(state, style) = if state in style and "radius" in style.at(state) {
  return style.at(state).radius
} else if "state" in style and "radius" in style.state {
  return style.state.radius
} else {
  return default-style.state.radius
}
