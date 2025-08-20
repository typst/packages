#import "@preview/t4t:0.3.2": get, def, is, assert, math

#import "@preview/cetz:0.1.1": vector, matrix, draw
#import draw: util, styles, cmd, coordinate
#import util.bezier: cubic-point, cubic-derivative, cubic-through-3points

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
      size: auto,
    ),
  ),
  transition: (
    curve: .75,
    stroke: auto,
    label: (
      text: "",
      size: 1em,
      color: auto,
      pos: .5,
      dist: .33,
      angle: auto,
    ),
  ),
)

// =================================
//  Vectors
// =================================

/// Set the length of a vector.
#let vector-set-len(v, len) = if vector.len(v) == 0 {
  return v
} else {
  return vector.scale(vector.norm(v), len)
}

/// Compute a normal for a 2d vector. The normal will be pointing to the right
/// of the original vector.
#let vector-normal(v) = vector.norm((-v.at(1), v.at(0), 0))

/// Returns a vector for an alignment.
#let align-to-vec(a) = {
  let v = (
    ("none": 0, "left": -1, "right": 1).at(repr(get.x-align(a, default: none))),
    ("none": 0, "top": 1, "bottom": -1).at(repr(get.y-align(a, default: none))),
  )
  return vector.norm(v)
}

/// Rotates a vector by #arg[angle] degree around the origin.
#let vector-rotate(vec, angle) = {
  let (x, y, ..) = vec
  return (
    calc.cos(angle) * x - calc.sin(angle) * y,
    calc.sin(angle) * x + calc.cos(angle) * y,
  )
}


// =================================
//  Bezier
// =================================

/// Compute a normal vector for a point on a cubic bezier curve.
#let cubic-normal(a, b, c, d, t) = {
  let qd = cubic-derivative(a, b, c, d, t)
  if vector.len(qd) == 0 {
    return (0, 1, 0)
  } else {
    return vector-normal(qd)
  }
}

/// Compute the mid point of a quadratic bezier curve.
#let mid-point(a, b, c, d) = cubic-point(a, b, c, d, .5)


// =================================
//  Helpers
// =================================

/// Calculate the control point for a transition.
#let cubic-pts(a, b, curve: 1) = {
  if curve == 0 {
    return (a, b, b, a)
  }
  let ab = vector.sub(b, a)
  let X = vector.add(
    vector.add(
      a,
      vector.scale(ab, .5),
    ),
    vector.scale(
      vector-normal(ab),
      curve,
    ),
  )
  return cubic-through-3points(a, X, b)
}

/// Calculate the direction vector for a transition mark (arrowhead)
#let mark-dir(a, b, c, d, scale: 1) = vector-set-len(cubic-derivative(a, b, c, d, 1), scale)

/// Calculate the location for a transitions label, based
/// on its bezier points.
#let label-pt(a, b, c, d, style, loop: false) = {
  let pos = style.label.at("pos", default: default-style.transition.label.pos)
  let dist = style.label.at("dist", default: default-style.transition.label.dist)
  let curve = style.at("curve", default: default-style.transition.curve)

  let pt = cubic-point(a, b, c, d, pos)
  let n = cubic-normal(a, b, c, d, pos)

  if loop and curve < 0 {
    dist *= -1
  }

  return vector.add(
    pt,
    vector.scale(n, dist),
  )
}


/// Calculate start, end and ctrl points for a transition loop.
///
/// - start (vector): Center of the state.
/// - start-radius (length): Radius of the state.
/// - curve (float): Curvature of the transition.
/// - anchor (alignment): Anchorpoint on the state
#let loop-pts(start, start-radius, anchor: top, curve: 1) = {
  anchor = vector-set-len(align-to-vec(anchor), start-radius)

  let end = vector.add(
    start,
    vector-rotate(anchor, -22.5deg),
  )
  let start = vector.add(
    start,
    vector-rotate(anchor, 22.5deg),
  )

  if curve < 0 {
    (start, end) = (end, start)
  } else if curve == 0 {
    curve = start-radius
  }

  let (start, end, c1, c2) = cubic-pts(start, end, curve: curve)

  if curve < 0 {
    (c1, c2) = (c2, c1)
  }

  let d = vector.scale(vector.sub(c2, c1), curve * 4)
  c1 = vector.sub(c1, d)
  c2 = vector.add(c2, d)

  return (start, end, c1, c2)
}


/// Calculate start, end and ctrl points for a transition.
///
/// - start (vector): Center of the start state.
/// - end (vector): Center of the end state.
/// - start-radius (length): Radius of the start state.
/// - end-radius (length): Radius of the end state.
/// - curve (float): Curvature of the transition.
#let transition-pts(start, end, start-radius, end-radius, curve: 1, anchor: top) = {
  // Is it a loop?
  if start == end {
    return loop-pts(start, start-radius, curve: curve, anchor: anchor)
  } else {
    let (start, end, ctrl1, ctrl2) = cubic-pts(start, end, curve: curve)

    start = vector.add(
      start,
      vector-set-len(
        vector.sub(
          ctrl1,
          start,
        ),
        start-radius,
      ),
    )
    end = vector.add(
      end,
      vector-set-len(
        vector.sub(
          end,
          ctrl2,
        ),
        -end-radius,
      ),
    )
    return (
      start,
      end,
      ctrl1,
      ctrl2,
    )
  }
}

/// Fits (text) content inside the available space.
///
/// - ctx (dictionary): The canvas context.
/// - content (string, content): The content to fit.
/// - size (length,auto): The initial text size.
/// - min-size (length): The minimal text size to set.
#let fit-content(ctx, width, height, content, size: auto, min-size: 6pt) = {
  let s = def.if-auto(ctx.length, size)

  let m = (width: 2 * width, height: 2 * height)
  while (m.height > height or m.width > height) and s > min-size {
    s = s * .88
    m = measure(
      {
        set text(s)
        content
      },
      ctx.typst-style,
    )
  }
  s = calc.max(min-size, s)
  {
    set text(s)
    content
  }
}

/// Prepares the CeTZ context for use with finite
#let prepare-ctx(ctx, force: false) = {
  if force or "finite" not in ctx {
    // supposed to store state information at some point
    ctx.insert("finite", (states: ()))

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


// Changes a transition table from the format (`state`: `inputs`) to (`input`: `states`) or vice versa.
#let transpose-table(table) = {
  let ttable = (:)
  for (key, values) in table {
    let new-values = (:)

    if is.not-none(values) {
      for (kk, vv) in values {
        for i in def.as-arr(vv) {
          if is.not-none(i) {
            i = str(i)
            if i not in new-values {
              new-values.insert(i, (kk,))
            } else {
              new-values.at(i).push(kk)
            }
          }
        }
      }
    }

    ttable.insert(key, new-values)
  }

  return ttable
}

/// Gets a list of all inputs from a transition table.
#let get-inputs(table, transpose: true) = {
  if transpose {
    table = transpose-table(table)
  }

  let inputs = ()
  for (_, values) in table {
    for (inp, _) in values {
      if inp not in inputs {
        inputs.push(str(inp))
      }
    }
  }

  return inputs.sorted()
}

/// Creates a full specification for a finite automaton.
#let to-spec(spec, states: auto, initial: auto, final: auto, inputs: auto) = {
  if "transitions" not in spec {
    spec = (transitions: spec)
  }
  if "states" not in spec {
    if is.a(states) {
      states = spec.transitions.keys()
    }
    spec.insert("states", states)
  }
  if "initial" not in spec {
    if is.a(initial) {
      initial = spec.states.first()
    }
    spec.insert("initial", initial)
  }
  if "final" not in spec {
    if is.a(final) {
      final = (spec.states.last(),)
    } else if is.n(final) {
      final = ()
    }
    spec.insert("final", final)
  }
  if "inputs" not in spec {
    if is.a(inputs) {
      inputs = get-inputs(spec.transitions)
    }
    spec.insert("inputs", inputs)
  } else {
    spec.inputs = spec.inputs.map(str).sorted()
  }
  return spec
}



// Unused

#let calc-bounds(positions) = {
  let bounds = (
    x: positions.first().at(0),
    y: positions.first().at(1),
    width: positions.first().at(0),
    height: positions.first().at(1),
  )
  for (x, y) in positions {
    bounds.x = calc.min(bounds.x, x)
    bounds.y = calc.min(bounds.y, y)
    bounds.width = calc.max(bounds.width, x)
    bounds.height = calc.max(bounds.height, y)
  }
  bounds.width = bounds.width - bounds.x
  bounds.height = bounds.height - bounds.y
  return bounds
}

#let calc-shift(anchor, bounds: none) = {
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
  let shift = calc-shift(anchor, bounds: bounds)

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
