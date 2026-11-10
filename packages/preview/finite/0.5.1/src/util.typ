#import "_deps.typ": cetz, t4t
#import t4t: *


// TODO: (jneug) implement scheme validation with valkyrie
// #import "@preview/valkyrie:0.2.1" as t

// TODO: (jneug) don't import into global scope
#import cetz.util.bezier: cubic-derivative, cubic-point, cubic-through-3points


// TODO (jneug) refactor module and cleanup

// =================================
//  Defaults
// =================================

#let default-style = (
  state: (
    fill: white,
    stroke: auto,
    radius: .6,
    extrude: .88,
    label: (
      text: auto,
      size: 1em,
      fill: none,
      padding: auto,
    ),
    initial: (
      anchor: left,
      label: (
        text: "Start",
        size: .88em,
        dist: .1,
      ),
      stroke: auto,
      scale: .8,
    ),
  ),
  transition: (
    curve: 1,
    stroke: auto,
    label: (
      text: "",
      size: 1em,
      fill: none,
      pos: .5,
      dist: .33,
      angle: auto,
    ),
  ),
  loop: (:),
)

// =================================
//  Helpers
// =================================

/// Calls #arg[value] with #sarg[args], if it is a #dtype("function") and returns the result or #arg[value] otherwise.
/// -> any
#let call-or-get(
  /// Value to call or return.
  /// -> any
  value,
  /// Arguments to pass if #arg[value] is a function.
  /// -> arguments
  ..args,
) = {
  if is-func(value) {
    return value(..args)
  } else {
    return value
  }
}

#let assert-dict = assert.new(
  is-dict,
  message: v => "dictionary expected. got " + repr(v),
)

#let assert-spec = assert.new(
  value => is-dict(value) and "finite-spec" in value,
  message: v => "automaton specification expected. got " + repr(v),
)

#let assert-full-spec = assert.new(
  value => is-dict(value) and ("finite-spec", "type", "transitions", "states", "initial", "final").all(k => k in value),
  message: v => "full automaton specification expected. got " + repr(v),
)

#let round-coord(coord, digits: 10) = coord.map(calc.round.with(digits: digits))

// =================================
//  Vectors
// =================================

/// Set the length of a cetz.vector.
/// -> vector
#let vector-set-len(
  /// The vector.
  /// -> vector
  v,
  /// The new length.
  /// -> float
  len,
) = if cetz.vector.len(v) == 0 {
  return v
} else {
  return cetz.vector.scale(cetz.vector.norm(v), len)
}

/// Compute a normal for a 2D cetz.vector. The normal will be pointing to the right
/// of the original cetz.vector.
/// -> vector
#let vector-normal(
  /// The vector to compute the normal for.
  /// -> vector
  v,
) = cetz.vector.norm((-v.at(1), v.at(0), 0))

/// Rotates a vector by #arg[angle] degrees around the origin.
/// -> vector
#let vector-rotate(
  /// The vector to rotate.
  /// -> vector
  vec,
  /// The angle to rotate by.
  /// -> angle
  angle,
) = {
  let (x, y, ..) = vec
  return (
    calc.cos(angle) * x - calc.sin(angle) * y,
    calc.sin(angle) * x + calc.cos(angle) * y,
  )
}

/// Returns a vector for an alignment.
/// -> vector
#let align-to-vec(
  /// The alignment to convert.
  /// -> alignment
  a,
) = {
  let v = (
    ("none": 0, "center": 0, "left": -1, "right": 1).at(repr(a.x)),
    ("none": 0, "horizon": 0, "top": 1, "bottom": -1).at(repr(a.y)),
  )
  if v != (0, 0) {
    v = cetz.vector.norm(v)
  }
  return v
}

#let vec-to-align(vec) = {
  if vec == (0, 0) { return top }

  let angle = cetz.vector.angle2((0, 0), vec) / 1deg
  if angle < 0 { angle = angle + 360 }
  let idx = calc.rem(calc.round((angle - 22.5) / 45 + .5), 8)

  return (
    right,
    top + right,
    top,
    top + left,
    left,
    bottom + left,
    bottom,
    bottom + right,
  ).at(int(idx))
}


// =================================
//  Bezier
// =================================

/// Compute a normal vector for a point on a cubic bezier curve.
/// -> vector
#let cubic-normal(
  /// Start point.
  /// -> vector
  a,
  /// End point.
  /// -> vector
  b,
  /// First control point.
  /// -> vector
  c,
  /// Second control point.
  /// -> vector
  d,
  /// Parameter value between #value(0) and #value(1).
  /// -> float
  t,
) = {
  let qd = cubic-derivative(a, b, c, d, t)
  if cetz.vector.len(qd) == 0 {
    return (0, 1, 0)
  } else {
    return vector-normal(qd)
  }
}

/// Compute the midpoint of a cubic bezier curve.
/// -> vector
#let mid-point(
  /// Start point.
  /// -> vector
  a,
  /// End point.
  /// -> vector
  b,
  /// First control point.
  /// -> vector
  c,
  /// Second control point.
  /// -> vector
  d,
) = cubic-point(a, b, c, d, .5)


// =================================
//  Helpers
// =================================

/// Calculate the control points for a transition bezier curve.
/// -> array
#let cubic-pts(
  /// Start point.
  /// -> vector
  a,
  /// End point.
  /// -> vector
  b,
  /// Curvature factor.
  /// -> float
  curve: 1,
) = {
  if curve == 0 {
    return (a, b, b, a)
  }
  let ab = cetz.vector.sub(b, a)
  let X = cetz.vector.add(
    cetz.vector.add(
      a,
      cetz.vector.scale(ab, .5),
    ),
    cetz.vector.scale(
      vector-normal(ab),
      curve,
    ),
  )
  return cubic-through-3points(a, X, b)
}

/// Calculate the direction vector for a transition mark (arrowhead).
/// -> vector
#let mark-dir(
  /// Start point.
  /// -> vector
  a,
  /// End point.
  /// -> vector
  b,
  /// First control point.
  /// -> vector
  c,
  /// Second control point.
  /// -> vector
  d,
  /// Scale for the resulting direction vector.
  /// -> float
  scale: 1,
) = vector-set-len(cubic-derivative(a, b, c, d, 1), scale)

/// Calculate the location for a transition's label, based
/// on its bezier points.
/// -> vector
#let label-pt(
  /// Start point.
  /// -> vector
  a,
  /// End point.
  /// -> vector
  b,
  /// First control point.
  /// -> vector
  c,
  /// Second control point.
  /// -> vector
  d,
  /// Resolved style dictionary with `label` and `curve` keys.
  /// -> dictionary
  style,
  /// Whether the transition is a loop.
  /// -> bool
  loop: false,
) = {
  let pos = style.label.pos // style.label.at("pos", default: default-style.transition.label.pos)
  let dist = style.label.dist // style.label.at("dist", default: default-style.transition.label.dist)
  let curve = style.curve // style.at("curve", default: default-style.transition.curve)

  let pt = cubic-point(a, b, c, d, pos)
  let n = cubic-normal(a, b, c, d, pos)

  if loop and curve < 0 {
    dist *= -1
  }

  return cetz.vector.add(
    pt,
    cetz.vector.scale(n, dist),
  )
}


/// Calculate start, end and ctrl points for a transition loop.
///
/// -> array
#let loop-pts(
  /// Center of the state.
  /// -> vector
  start,
  /// Radius of the state.
  /// -> float
  start-radius,
  /// Anchor point on the state.
  /// -> alignment
  anchor: top,
  /// Curvature of the transition.
  /// -> float
  curve: 1,
) = {
  anchor = vector-set-len(align-to-vec(anchor), start-radius)

  let end = cetz.vector.add(
    start,
    vector-rotate(anchor, -22.5deg),
  )
  let start = cetz.vector.add(
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

  let d = cetz.vector.scale(cetz.vector.sub(c2, c1), curve * 4)
  c1 = cetz.vector.sub(c1, d)
  c2 = cetz.vector.add(c2, d)

  return (start, end, c1, c2)
}


/// Calculate start, end and ctrl points for a transition.
///
/// -> array
#let transition-pts(
  /// Center of the start state.
  /// -> vector
  start,
  /// Center of the end state.
  /// -> vector
  end,
  /// Radius of the start state.
  /// -> float
  start-radius,
  /// Radius of the end state.
  /// -> float
  end-radius,
  /// Curvature of the transition.
  /// -> float
  curve: 1,
  /// Anchor point for loops.
  /// -> alignment
  anchor: top,
) = {
  // Is it a loop?
  if start == end {
    return loop-pts(start, start-radius, curve: curve, anchor: anchor)
  } else {
    let (start, end, ctrl1, ctrl2) = cubic-pts(start, end, curve: curve)

    start = cetz.vector.add(
      start,
      vector-set-len(
        cetz.vector.sub(
          ctrl1,
          start,
        ),
        start-radius,
      ),
    )
    end = cetz.vector.add(
      end,
      vector-set-len(
        cetz.vector.sub(
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
/// -> content
#let fit-content(
  /// The canvas context.
  /// -> dictionary
  ctx,
  /// Available width.
  /// -> float
  width,
  /// Available height.
  /// -> float
  height,
  /// The content to fit.
  /// -> str | content
  content,
  /// The initial text size.
  /// -> length | auto
  size: auto,
  /// The minimal text size to use.
  /// -> length
  min-size: 6pt,
) = {
  let s = def.if-auto(ctx.length, size)

  let m = (width: 2 * width, height: 2 * height)
  while (m.height > height or m.width > width) and s > min-size {
    s = s * .88
    m = cetz.util.measure(
      ctx,
      {
        set text(s)
        content
      },
    )
  }
  s = calc.max(min-size, s)
  {
    set text(s)
    content
  }
}

/// Changes a @type:transition-table from the format (`state`: `inputs`) to (`input`: `states`) or vice versa.
/// -> dict
#let transpose-table(
  /// A transition table in any format.
  /// -> transition-table
  table,
) = {
  let ttable = (:)
  for (key, values) in table {
    let new-values = (:)

    if not-none(values) {
      for (kk, vv) in values {
        for i in def.as-arr(vv) {
          if not-none(i) {
            i = get.text(i)
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


/// Returns a list of unique states referenced in a transition table.
/// States are either keys in #arg[table]
/// or referenced in a transition.
/// -> array
#let get-states(
  /// A transition table.
  /// -> transition-table
  table,
) = {
  let states = table.keys() + table.values().filter(not-none).map(d => d.keys()).flatten()
  return states.dedup()
}

#let get-input-str(input) = {
  return get.text(input)
}

/// Creates a tuple of (#typ.t.arr, #typ.t.dict).
/// The array is the set of unique input strings for
/// an automaton and the dictionary is a mapping of
/// input strings to labels.
/// -> array
#let get-inputs(
  /// A transition table.
  /// -> transition-table
  table,
  input-labels: (:),
) = {
  let label-transform = if is-func(input-labels) {
    (i, l) => input-labels(i)
  } else if is-dict(input-labels) {
    (i, l) => input-labels.at(i, default: l)
  } else {
    (i, l) => none
  }

  let (inputs, labels) = ((), (:))
  for transitions in table.values() {
    if is-dict(transitions) {
      for input in transitions.values().filter(not-none).flatten() {
        let input-str = get-input-str(input)
        let input-label = none

        if is-content(input) {
          input-label = input
        }

        input-label = label-transform(input-str, input-label)

        inputs.push(input-str)
        if not-none(input-label) and input-str not in labels {
          labels.insert(input-str, input-label)
        }
      }
    }
  }
  inputs = inputs.dedup().sorted()

  return (inputs, labels)
}


/// Checks if a given @type:spec represents
/// a deterministic automaton.
///
/// ```example
/// #util.is-dea((
///   q0: (q1: 1, q2: 1),
/// ))
/// #util.is-dea((
///   q0: (q1: 1, q2: 0),
/// ))
/// ```
///
/// -> bool
#let is-dea(
  /// A transition table.
  /// -> transition-table
  table,
) = {
  for (_, transitions) in table {
    let inp = ()
    for (state, inputs) in transitions {
      for i in def.as-arr(inputs) {
        if i in inp {
          return false
        } else {
          inp.push(i)
        }
      }
    }
  }

  return true
}


/// Return anchor name for an #dtype(alignment).
/// -> str
#let align-to-anchor(
  /// The alignment to convert.
  /// -> alignment
  align,
) = {
  let anchor = ()
  if align.y == top {
    anchor.push("north")
  } else if align.y == bottom {
    anchor.push("south")
  }
  if align.x == left {
    anchor.push("west")
  } else if align.x == right {
    anchor.push("east")
  }
  if anchor == () {
    return "center"
  } else {
    return anchor.join("-")
  }
}

#let to-anchor(align) = {
  if type(align) == alignment {
    return align-to-anchor(align)
  } else {
    align
  }
}

#let label-angle(vec, a) = if a in (top, top + right, right, bottom + right) {
  cetz.vector.angle2((0, 0), vec)
} else {
  cetz.vector.angle2(vec, (0, 0))
}

#let abs-angle-between(vec1, vec2, lower, upper) = {
  let ang = calc.abs(cetz.vector.angle2(vec1, vec2))
  return ang >= lower and ang <= upper
}

#let get-radii(spec, style: (:)) = spec.states.fold(
  (:),
  (d, name) => {
    d.insert(
      name,
      style
        .at(
          name,
          default: style.at(
            "state",
            default: (:),
          ),
        )
        .at(
          "radius",
          default: default-style.state.radius,
        ),
    )
    d
  },
)

#let transition-wrapper(from, to, group) = {
  return (
    ctx => {
      let g = (group.first())(ctx)
      g.insert(
        "finite",
        (
          state: false,
          transition: true,
          from: from,
          to: to,
        ),
      )
      return g
    },
  )
}
