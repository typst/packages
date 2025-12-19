
// Package dependencies
#import "@preview/t4t:0.4.3": *
#import "@preview/cetz:0.3.4"

// TODO: (jneug) implement scheme validation with valkyrie
// #import "@preview/valkyrie:0.2.1" as t

// TODO: (jneug) don't import into global scope
#import cetz.util.bezier: cubic-point, cubic-derivative, cubic-through-3points


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
#let call-or-get(value, ..args) = {
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


// =================================
//  Vectors
// =================================

/// Set the length of a cetz.vector.
#let vector-set-len(v, len) = if cetz.vector.len(v) == 0 {
  return v
} else {
  return cetz.vector.scale(cetz.vector.norm(v), len)
}

/// Compute a normal for a 2d cetz.vector. The normal will be pointing to the right
/// of the original cetz.vector.
#let vector-normal(v) = cetz.vector.norm((-v.at(1), v.at(0), 0))

/// Rotates a vector by #arg[angle] degree around the origin.
#let vector-rotate(vec, angle) = {
  let (x, y, ..) = vec
  return (
    calc.cos(angle) * x - calc.sin(angle) * y,
    calc.sin(angle) * x + calc.cos(angle) * y,
  )
}

/// Returns a vector for an alignment.
#let align-to-vec(a) = {
  let v = (
    ("none": 0, "center": 0, "left": -1, "right": 1).at(repr(a.x)),
    ("none": 0, "horizon": 0, "top": 1, "bottom": -1).at(repr(a.y)),
  )

  return cetz.vector.norm(v)
}

#let vec-to-align(vec) = {
  let angle = cetz.vector.angle2((0, 0), vec) / 1deg
  if angle < 0 { angle = angle + 360 }
  let idx = calc.round((angle - 22.5) / 45 + .5)

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
#let cubic-normal(a, b, c, d, t) = {
  let qd = cubic-derivative(a, b, c, d, t)
  if cetz.vector.len(qd) == 0 {
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

/// Calculate the direction vector for a transition mark (arrowhead)
#let mark-dir(a, b, c, d, scale: 1) = vector-set-len(cubic-derivative(a, b, c, d, 1), scale)

/// Calculate the location for a transitions label, based
/// on its bezier points.
#let label-pt(a, b, c, d, style, loop: false) = {
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
/// - start (vector): Center of the state.
/// - start-radius (length): Radius of the state.
/// - curve (float): Curvature of the transition.
/// - anchor (alignment): Anchorpoint on the state
#let loop-pts(start, start-radius, anchor: top, curve: 1) = {
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
/// - ctx (dictionary): The canvas context.
/// - content (string, content): The content to fit.
/// - size (length,auto): The initial text size.
/// - min-size (length): The minimal text size to set.
#let fit-content(ctx, width, height, content, size: auto, min-size: 6pt) = {
  let s = def.if-auto(ctx.length, size)

  let m = (width: 2 * width, height: 2 * height)
  while (m.height > height or m.width > height) and s > min-size {
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
///
#let get-inputs(
  /// A transition table.
  /// -> transition-table
  table,
  /// If #arg[table] needs to be transposed first. Set this to #typ.v.false if the table already is in the format (`input`: `states`).
  /// -> bool
  transpose: true,
) = {
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


// deprecated!!!
#let to-spec(spec, states: auto, initial: auto, final: auto, inputs: auto, labels: auto) = {
  // TODO: (jneug) add asserts to react to malicious specs
  // TODO: (jneug) check for duplicate names
  if "transitions" not in spec {
    spec = (transitions: spec)
  }
  if "states" not in spec {
    if is-auto(states) {
      states = spec.transitions.keys()
    }
    spec.insert("states", states)
  }
  if "initial" not in spec {
    if is-auto(initial) {
      initial = spec.states.first()
    }
    spec.insert("initial", initial)
  }
  if "final" not in spec {
    if is-auto(final) {
      final = (spec.states.last(),)
    } else if is-none(final) {
      final = ()
    }
    spec.insert("final", final)
  }
  if "inputs" not in spec {
    if is-auto(inputs) {
      inputs = get-inputs(spec.transitions)
    }
    spec.insert("inputs", inputs)
  } else {
    spec.inputs = spec.inputs.map(str).sorted()
  }

  return spec + (finite-spec: true, type: "DEA")
}


/// Return anchor name for an #dtype(alignment).
#let align-to-anchor(align) = {
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


#let is-state(element) = {
  return "finite" in element and element.finite.state
}

#let is-transition(element) = {
  return "finite" in element and element.finite.transition
}

#let resolve-one(ctx, element) = {
  element = (element)(ctx)
  ctx = element.ctx

  if "name" in element and element.name != none {
    if "nodes" not in ctx {
      ctx.insert("nodes", (:))
    }
    ctx.nodes.insert(element.name, element)
  }

  return (ctx, element)
}

#let resolve-many(ctx, body) = {
  let elements = ()
  let (_ctx, element) = (ctx, none)
  for element in body {
    (_ctx, element) = resolve-one(_ctx, element)
    elements.push(element)
  }
  return (_ctx, elements)
}

#let resolve-zipped(ctx, body) = {
  let (_ctx, elements) = resolve-many(ctx, body)
  return (_ctx, body.zip(elements))
}

#let resolve-states(ctx, body) = {
  let (_, elements) = resolve-many(ctx, body)
  return elements.filter(is-state)
}

#let get-radii(elements) = {
  return elements
    .filter(is-state)
    .fold(
      (:),
      (radii, element) => {
        radii.insert(element.name, element.finite.radius)
        return radii
      },
    )
}

// Resolve radii for states by applying styles from other elements.
#let resolve-radii(ctx, body) = {
  let (_, elements) = resolve-many(ctx, body)
  return get-radii(elements)
}

#let state-wrapper(group) = {
  return (
    ctx => {
      let g = (group.first())(ctx)
      g.insert(
        "finite",
        (
          state: true,
          transition: false,
          radius: (g.anchors)("state.east").at(0) - (g.anchors)("state.center").at(0),
        ),
      )
      return g
    },
  )
}

#let get-radii(spec, style: (:)) = spec.states.fold(
  (:),
  (d, name) => {
    let r = style.at(name, default: (:)).at("radius", default: none)
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
