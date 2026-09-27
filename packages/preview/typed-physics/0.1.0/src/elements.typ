// The declarative vocabulary. Every constructor returns a plain dictionary
// describing one piece of the situation; `situation` is what turns those
// dictionaries into placed geometry, forces, and equations.
//
// Nothing here takes a coordinate. A surface says which surface it continues
// from, a body says what holds it up and where along it, and a connector says
// which two things it joins, so changing one declaration moves everything
// declared in terms of it.

#import "style.typ": (
  validate-block-style, validate-connector-style, validate-force-style,
  validate-surface-style,
)
#import "validation.typ"

#let _resolve-element-name(arguments, default-name) = {
  let positional-names = arguments.pos()
  assert(
    positional-names.len() <= 1,
    message: "typed-physics: an element takes at most one positional argument, its name",
  )
  let resolved-name = if positional-names.len() == 1 {
    positional-names.first()
  } else {
    default-name
  }
  validation.validate-name(resolved-name)
  resolved-name
}

// Accepts `mu: 0.3`, `mu: (s: 0.4, k: 0.3)`, `mu: (static: .., kinetic: ..)`,
// or a symbol such as `mu: $mu$` for a coefficient to be solved for.
#let _resolve-friction-coefficients(mu) = {
  if mu == none { return none }
  if type(mu) == dictionary {
    for key in mu.keys() {
      assert(
        key in ("s", "static", "k", "kinetic"),
        message: (
          "typed-physics: `mu:` has unknown field \""
            + key
            + "\"; use `s:`/`static:` and `k:`/`kinetic:`"
        ),
      )
    }
    assert(
      not ("s" in mu and "static" in mu),
      message: "typed-physics: `mu:` gives static friction twice; use either `s:` or `static:`",
    )
    assert(
      not ("k" in mu and "kinetic" in mu),
      message: "typed-physics: `mu:` gives kinetic friction twice; use either `k:` or `kinetic:`",
    )
    let declared-static-coefficient = mu.at(
      "s",
      default: mu.at("static", default: none),
    )
    let declared-kinetic-coefficient = mu.at(
      "k",
      default: mu.at("kinetic", default: none),
    )
    assert(
      declared-static-coefficient != none
        or declared-kinetic-coefficient != none,
      message: "typed-physics: mu given as a dictionary needs an `s:`/`static:` or `k:`/`kinetic:` entry",
    )
    let resolved-coefficients = (
      static: if declared-static-coefficient == none {
        declared-kinetic-coefficient
      } else {
        declared-static-coefficient
      },
      kinetic: if declared-kinetic-coefficient == none {
        declared-static-coefficient
      } else {
        declared-kinetic-coefficient
      },
    )
    validation.validate-physical-scalar(
      resolved-coefficients.static,
      "mu",
      "static",
      allow-zero: true,
    )
    validation.validate-physical-scalar(
      resolved-coefficients.kinetic,
      "mu",
      "kinetic",
      allow-zero: true,
    )
    if (
      type(resolved-coefficients.static) in (int, float)
        and type(resolved-coefficients.kinetic) in (int, float)
    ) {
      assert(
        resolved-coefficients.static >= resolved-coefficients.kinetic,
        message: "typed-physics: `mu:` needs static friction greater than or equal to kinetic friction",
      )
    }
    return resolved-coefficients
  }
  validation.validate-physical-scalar(mu, "mu", "coefficient", allow-zero: true)
  (static: mu, kinetic: mu)
}

#let _resolve-horizontal-side(side) = {
  let resolved-side = if type(side) == alignment { repr(side) } else { side }
  assert(
    resolved-side in ("left", "right"),
    message: "typed-physics: side must be `left` or `right`, got " + repr(side),
  )
  resolved-side
}

// ── Environment ──────────────────────────────────────────────────────────────
//
// `from:` is what lets surfaces meet: a ramp whose foot sits at the end of a
// ground, a ground that begins at a ramp's apex. It names a surface, optionally
// with one of that surface's anchors — "ground", "ground.start", "incline.apex"
// — and defaults to the named surface's far end.

#let ground(..name, length: 8, from: none, mu: none, style: (:)) = {
  let surface-name = _resolve-element-name(name, "ground")
  validation.validate-positive-number(length, "ground \"" + surface-name + "\"", "length")
  validation.validate-attachment(from, "ground \"" + surface-name + "\"", "from", allow-none: true)
  (
    kind: "ground",
    name: surface-name,
    length: length,
    from: from,
    friction: _resolve-friction-coefficients(mu),
    style: validate-surface-style(style, surface-name),
  )
}

#let wall(..name, side: left, height: 4, from: none, mu: none, style: (:)) = {
  let surface-name = _resolve-element-name(name, "wall")
  validation.validate-positive-number(height, "wall \"" + surface-name + "\"", "height")
  validation.validate-attachment(from, "wall \"" + surface-name + "\"", "from", allow-none: true)
  (
    kind: "wall",
    name: surface-name,
    side: _resolve-horizontal-side(side),
    height: height,
    from: from,
    friction: _resolve-friction-coefficients(mu),
    style: validate-surface-style(style, surface-name),
  )
}

#let ceiling(..name, length: 8, height: 4, from: none, mu: none, style: (:)) = {
  let surface-name = _resolve-element-name(name, "ceiling")
  validation.validate-positive-number(length, "ceiling \"" + surface-name + "\"", "length")
  validation.validate-positive-number(height, "ceiling \"" + surface-name + "\"", "height")
  validation.validate-attachment(from, "ceiling \"" + surface-name + "\"", "from", allow-none: true)
  (
    kind: "ceiling",
    name: surface-name,
    length: length,
    height: height,
    from: from,
    friction: _resolve-friction-coefficients(mu),
    style: validate-surface-style(style, surface-name),
  )
}

// An inclined surface rising from its foot, with the ground under it. `length`
// is measured along the incline, not along its base, and `facing:` says which
// way the slope runs: `right` climbs to the right, `left` to the left.
#let ramp(
  name,
  angle: 30deg,
  length: 6,
  facing: right,
  from: none,
  mu: none,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "ramp()")
  assert(
    type(angle) == std.angle,
    message: "typed-physics: ramp \"" + name + "\" needs `angle:` as an angle, e.g. 30deg",
  )
  assert(
    angle > 0deg and angle < 90deg,
    message: "typed-physics: ramp \"" + name + "\" has angle " + repr(angle) + ", which must be between 0deg and 90deg",
  )
  validation.validate-positive-number(length, "ramp \"" + name + "\"", "length")
  validation.validate-attachment(from, "ramp \"" + name + "\"", "from", allow-none: true)
  (
    kind: "ramp",
    name: name,
    angle: angle,
    length: length,
    facing: _resolve-horizontal-side(facing),
    from: from,
    friction: _resolve-friction-coefficients(mu),
    symbol: symbol,
    style: validate-surface-style(style, name),
  )
}

// A curved support begins at `from:` and follows the declared polar-angle
// sweep. Bodies may occupy either the outside of the curve or its inside.
#let arc(
  name,
  radius: 3,
  start-angle: -90deg,
  end-angle: 90deg,
  side: "outside",
  from: none,
  mu: none,
  style: (:),
) = {
  validation.validate-name(name, source-description: "arc()")
  validation.validate-positive-number(radius, "arc \"" + name + "\"", "radius")
  assert(
    type(start-angle) == std.angle and type(end-angle) == std.angle,
    message: "typed-physics: arc \"" + name + "\" needs start-angle: and end-angle: as angles",
  )
  validation.validate-attachment(from, "arc \"" + name + "\"", "from", allow-none: true)
  assert(
    end-angle != start-angle,
    message: "typed-physics: arc \"" + name + "\" needs different start-angle: and end-angle:",
  )
  assert(
    calc.abs((end-angle - start-angle).deg()) <= 360,
    message: "typed-physics: arc \"" + name + "\" cannot sweep more than 360deg",
  )
  assert(
    side in ("outside", "inside"),
    message: "typed-physics: arc \"" + name + "\" side: must be \"outside\" or \"inside\"",
  )
  (
    kind: "arc",
    name: name,
    radius: radius,
    start-angle: start-angle,
    end-angle: end-angle,
    side: side,
    from: from,
    friction: _resolve-friction-coefficients(mu),
    style: validate-surface-style(style, name),
  )
}

// ── Bodies ───────────────────────────────────────────────────────────────────

// Every body is placed the same three ways: resting somewhere along a surface,
// resting against a body already declared, or hanging below an attachment
// point. The shapes differ only in what gets drawn and how far the outline
// reaches.
#let _declared-body(
  shape,
  name,
  mass,
  on,
  at,
  touching,
  side,
  hanging,
  drop,
  half-extent-along,
  half-extent-normal,
  mu,
  label,
  symbol,
  style,
) = {
  validation.validate-name(name, source-description: shape + "()")
  assert(
    (
      (hanging != none and on == none and touching == none)
        or (hanging == none and (on != none or touching != none))
    ),
    message: (
      "typed-physics: "
        + shape
        + " \""
        + name
        + "\" needs `on:` or `touching:`, or it may use `hanging:` by itself; remove placement arguments that conflict with `hanging:`"
    ),
  )
  assert(
    touching == none or at == 50%,
    message: "typed-physics: " + shape + " \"" + name + "\" uses `touching:`, so `at:` would be ignored; remove `at:` and use `side:` to choose the neighbour",
  )
  assert(
    hanging == none or at == 50%,
    message: "typed-physics: " + shape + " \"" + name + "\" uses `hanging:`, so `at:` would be ignored; remove `at:` and select the attachment point through `hanging:`",
  )
  assert(
    touching != none or _resolve-horizontal-side(side) == "right",
    message: "typed-physics: " + shape + " \"" + name + "\" has `side:` " + repr(side) + " without `touching:`; remove `side:` or add a neighbouring body",
  )
  assert(
    hanging != none or drop == 1.5,
    message: "typed-physics: " + shape + " \"" + name + "\" has `drop:` " + repr(drop) + " without `hanging:`; remove `drop:` or place the body from an attachment",
  )
  assert(
    hanging == none or mu == none,
    message: "typed-physics: " + shape + " \"" + name + "\" is hanging and cannot use `mu:` because it has no surface contact; remove the friction coefficient",
  )
  validation.validate-ratio(at, shape + " \"" + name + "\"", "at")
  validation.validate-positive-number(
    half-extent-along,
    shape + " \"" + name + "\"",
    "size",
  )
  validation.validate-positive-number(
    half-extent-normal,
    shape + " \"" + name + "\"",
    "size",
  )
  validation.validate-physical-scalar(
    mass,
    shape + " \"" + name + "\"",
    "mass",
    allow-none: true,
  )
  validation.validate-nonnegative-number(
    drop,
    shape + " \"" + name + "\"",
    "drop",
  )
  if on != none {
    validation.validate-simple-reference(
      on,
      shape + " \"" + name + "\"",
      "on",
    )
  }
  if touching != none {
    validation.validate-simple-reference(
      touching,
      shape + " \"" + name + "\"",
      "touching",
    )
  }
  if hanging != none {
    validation.validate-attachment(
      hanging,
      shape + " \"" + name + "\"",
      "hanging",
    )
    assert(
      drop > 0,
      message: "typed-physics: " + shape + " \"" + name + "\" is hanging and needs a positive `drop:`",
    )
  }
  (
    kind: "body",
    shape: shape,
    name: name,
    mass: mass,
    on: on,
    at: at,
    touching: touching,
    side: _resolve-horizontal-side(side),
    hanging: hanging,
    drop: drop,
    half-extent-along: half-extent-along,
    half-extent-normal: half-extent-normal,
    friction: _resolve-friction-coefficients(mu),
    label: label,
    symbol: symbol,
    style: validate-block-style(style, name),
    radius-mark: false,
    orientation: 0deg,
    solver-supported: true,
  )
}

// `size:` is the edge of a square, or a `(width, height)` pair measured along
// the surface and out of it.
#let _block-half-extents(name, size) = {
  if type(size) in (int, float) { return (size / 2, size / 2) }
  assert(
    type(size) == array
      and size.len() == 2
      and size.all(dimension => type(dimension) in (int, float)),
    message: "typed-physics: block \"" + name + "\" needs `size:` as a number or a (width, height) pair",
  )
  (size.at(0) / 2, size.at(1) / 2)
}

#let block(
  name,
  mass: none,
  on: none,
  at: 50%,
  touching: none,
  side: right,
  hanging: none,
  drop: 1.5,
  size: 1,
  mu: none,
  label: auto,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "block()")
  let (half-width, half-height) = _block-half-extents(name, size)
  _declared-body(
    "block",
    name,
    mass,
    on,
    at,
    touching,
    side,
    hanging,
    drop,
    half-width,
    half-height,
    mu,
    label,
    symbol,
    style,
  )
}

#let ball(
  name,
  mass: none,
  on: none,
  at: 50%,
  touching: none,
  side: right,
  hanging: none,
  drop: 1.5,
  radius: 0.5,
  mu: none,
  label: auto,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "ball()")
  validation.validate-positive-number(radius, "ball \"" + name + "\"", "radius")
  _declared-body(
    "ball",
    name,
    mass,
    on,
    at,
    touching,
    side,
    hanging,
    drop,
    radius,
    radius,
    mu,
    label,
    symbol,
    style,
  )
}

// A body drawn as the point it is idealised to. Its label sits beside the dot,
// since there is no inside to write in.
#let point-mass(
  name,
  mass: none,
  on: none,
  at: 50%,
  touching: none,
  side: right,
  hanging: none,
  drop: 1.5,
  radius: 0.09,
  label: auto,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "point-mass()")
  validation.validate-positive-number(
    radius,
    "point-mass \"" + name + "\"",
    "radius",
  )
  _declared-body(
    "point",
    name,
    mass,
    on,
    at,
    touching,
    side,
    hanging,
    drop,
    radius,
    radius,
    none,
    label,
    symbol,
    style,
  )
}

// A disk and a ring use the same relational placement as the other bodies.
// Their optional radial mark can make a declared orientation visible.
#let disk(
  name,
  mass: none,
  on: none,
  at: 50%,
  touching: none,
  side: right,
  hanging: none,
  drop: 1.5,
  radius: 0.5,
  radius-mark: true,
  orientation: 0deg,
  mu: none,
  label: auto,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "disk()")
  validation.validate-positive-number(radius, "disk \"" + name + "\"", "radius")
  assert(
    type(radius-mark) == bool,
    message: "typed-physics: disk \"" + name + "\" needs `radius-mark:` as true or false",
  )
  assert(
    type(orientation) == std.angle,
    message: "typed-physics: disk \"" + name + "\" needs `orientation:` as an angle",
  )
  _declared-body(
    "disk",
    name,
    mass,
    on,
    at,
    touching,
    side,
    hanging,
    drop,
    radius,
    radius,
    mu,
    label,
    symbol,
    style,
  ) + (
    radius-mark: radius-mark,
    orientation: orientation,
    solver-supported: false,
  )
}

#let ring(
  name,
  mass: none,
  on: none,
  at: 50%,
  touching: none,
  side: right,
  hanging: none,
  drop: 1.5,
  radius: 0.5,
  radius-mark: false,
  orientation: 0deg,
  mu: none,
  label: auto,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "ring()")
  validation.validate-positive-number(radius, "ring \"" + name + "\"", "radius")
  assert(
    type(radius-mark) == bool,
    message: "typed-physics: ring \"" + name + "\" needs `radius-mark:` as true or false",
  )
  assert(
    type(orientation) == std.angle,
    message: "typed-physics: ring \"" + name + "\" needs `orientation:` as an angle",
  )
  _declared-body(
    "ring",
    name,
    mass,
    on,
    at,
    touching,
    side,
    hanging,
    drop,
    radius,
    radius,
    mu,
    label,
    symbol,
    style,
  ) + (
    radius-mark: radius-mark,
    orientation: orientation,
    solver-supported: false,
  )
}

// ── Rigid structures and constraints ─────────────────────────────────────────

#let rod(
  name,
  from: none,
  to: none,
  length: 4,
  angle: 0deg,
  thickness: 0.16,
  mass: none,
  center-of-mass: 50%,
  label: auto,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "rod()")
  validation.validate-positive-number(length, "rod \"" + name + "\"", "length")
  validation.validate-attachment(from, "rod \"" + name + "\"", "from", allow-none: true)
  validation.validate-attachment(to, "rod \"" + name + "\"", "to", allow-none: true)
  assert(
    type(angle) == std.angle,
    message: "typed-physics: rod \"" + name + "\" needs `angle:` as an angle",
  )
  validation.validate-positive-number(
    thickness,
    "rod \"" + name + "\"",
    "thickness",
  )
  validation.validate-ratio(
    center-of-mass,
    "rod \"" + name + "\"",
    "center-of-mass",
  )
  validation.validate-physical-scalar(
    mass,
    "rod \"" + name + "\"",
    "mass",
    allow-none: true,
  )
  (
    kind: "rod",
    name: name,
    from: from,
    to: to,
    length: length,
    angle: angle,
    thickness: thickness,
    mass: mass,
    center-of-mass: center-of-mass,
    label: label,
    symbol: symbol,
    style: validate-block-style(style, name),
  )
}

#let pivot(name, at: none, radius: 0.12, style: (:)) = {
  validation.validate-name(name, source-description: "pivot()")
  assert(
    at != none,
    message: "typed-physics: pivot \"" + name + "\" needs `at:` an attachment point",
  )
  validation.validate-attachment(at, "pivot \"" + name + "\"", "at")
  validation.validate-positive-number(radius, "pivot \"" + name + "\"", "radius")
  (
    kind: "pivot",
    name: name,
    at: at,
    radius: radius,
    style: validate-connector-style(style, name),
  )
}

#let support(
  name,
  at: none,
  kind: "pin",
  angle: 0deg,
  size: 0.5,
  style: (:),
) = {
  validation.validate-name(name, source-description: "support()")
  assert(
    at != none,
    message: "typed-physics: support \"" + name + "\" needs `at:` an attachment point",
  )
  validation.validate-attachment(at, "support \"" + name + "\"", "at")
  assert(
    kind in ("pin", "roller", "fixed"),
    message: "typed-physics: support \"" + name + "\" kind: must be \"pin\", \"roller\", or \"fixed\"",
  )
  assert(
    type(angle) == std.angle,
    message: "typed-physics: support \"" + name + "\" needs `angle:` as an angle",
  )
  validation.validate-positive-number(size, "support \"" + name + "\"", "size")
  (
    kind: "support",
    name: name,
    at: at,
    support-kind: kind,
    angle: angle,
    size: size,
    style: validate-connector-style(style, name),
  )
}

#let torque(
  on: none,
  at: auto,
  magnitude: none,
  direction: "counterclockwise",
  radius: 0.65,
  label: auto,
  style: (:),
) = {
  validation.validate-simple-reference(on, "torque()", "on")
  assert(
    on != none,
    message: "typed-physics: torque() needs `on:` the element it turns",
  )
  assert(
    direction in ("clockwise", "counterclockwise"),
    message: "typed-physics: torque() direction: must be \"clockwise\" or \"counterclockwise\"",
  )
  validation.validate-attachment(
    at,
    "torque() on \"" + on + "\"",
    "at",
    allow-auto: true,
    allow-ratio: true,
  )
  validation.validate-physical-scalar(
    magnitude,
    "torque() on \"" + on + "\"",
    "magnitude",
    allow-none: true,
  )
  validation.validate-positive-number(
    radius,
    "torque() on \"" + on + "\"",
    "radius",
  )
  (
    kind: "torque",
    on: on,
    at: at,
    magnitude: magnitude,
    direction: direction,
    radius: radius,
    label: label,
    style: validate-force-style(style, on),
  )
}

#let pendulum(
  name,
  from: none,
  length: 3,
  angle: 20deg,
  mass: none,
  radius: 0.24,
  angle-label: auto,
  label: auto,
  symbol: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "pendulum()")
  assert(
    from != none,
    message: "typed-physics: pendulum \"" + name + "\" needs `from:` an attachment point",
  )
  validation.validate-attachment(from, "pendulum \"" + name + "\"", "from")
  validation.validate-positive-number(
    length,
    "pendulum \"" + name + "\"",
    "length",
  )
  assert(
    type(angle) == std.angle,
    message: "typed-physics: pendulum \"" + name + "\" needs `angle:` as an angle",
  )
  validation.validate-positive-number(
    radius,
    "pendulum \"" + name + "\"",
    "radius",
  )
  assert(
    radius < length,
    message: "typed-physics: pendulum \"" + name + "\" needs `radius:` smaller than `length:` so the bob does not cover its pivot",
  )
  validation.validate-physical-scalar(
    mass,
    "pendulum \"" + name + "\"",
    "mass",
    allow-none: true,
  )
  (
    kind: "pendulum",
    name: name,
    from: from,
    length: length,
    angle: angle,
    mass: mass,
    radius: radius,
    angle-label: angle-label,
    label: label,
    symbol: symbol,
    style: validate-block-style(style, name),
  )
}

// ── Connectors ───────────────────────────────────────────────────────────────

// A wheel a rope runs over. `at:` is an attachment point, so a pulley hangs
// from a ceiling anchor or sits at a ramp's apex.
#let pulley(name, at: none, radius: 0.4, style: (:)) = {
  validation.validate-name(name, source-description: "pulley()")
  assert(
    at != none,
    message: "typed-physics: pulley \"" + name + "\" needs `at:` an attachment point, such as \"ceiling.end\"",
  )
  validation.validate-attachment(at, "pulley \"" + name + "\"", "at")
  validation.validate-positive-number(radius, "pulley \"" + name + "\"", "radius")
  (
    kind: "pulley",
    name: name,
    at: at,
    radius: radius,
    style: validate-block-style(style, name),
  )
}

#let rope(..name, from: none, to: none, over: none, style: (:)) = {
  let connector-name = _resolve-element-name(name, "rope")
  assert(
    from != none and to != none,
    message: "typed-physics: rope \"" + connector-name + "\" needs `from:` and `to:` attachment points",
  )
  validation.validate-attachment(from, "rope \"" + connector-name + "\"", "from")
  validation.validate-attachment(to, "rope \"" + connector-name + "\"", "to")
  if over != none {
    validation.validate-simple-reference(
      over,
      "rope \"" + connector-name + "\"",
      "over",
    )
  }
  (
    kind: "rope",
    name: connector-name,
    from: from,
    to: to,
    over: over,
    style: validate-connector-style(style, connector-name),
  )
}

#let spring(..name, from: none, to: none, coils: 6, width: 0.28, style: (:)) = {
  let connector-name = _resolve-element-name(name, "spring")
  assert(
    from != none and to != none,
    message: "typed-physics: spring \"" + connector-name + "\" needs `from:` and `to:` attachment points",
  )
  validation.validate-attachment(from, "spring \"" + connector-name + "\"", "from")
  validation.validate-attachment(to, "spring \"" + connector-name + "\"", "to")
  validation.validate-positive-integer(
    coils,
    "spring \"" + connector-name + "\"",
    "coils",
  )
  validation.validate-positive-number(
    width,
    "spring \"" + connector-name + "\"",
    "width",
  )
  (
    kind: "spring",
    name: connector-name,
    from: from,
    to: to,
    coils: coils,
    width: width,
    style: validate-connector-style(style, connector-name),
  )
}

// ── Applied loads and motion ─────────────────────────────────────────────────

// A force the problem statement applies to a body, measured from the
// horizontal like every other angle in the package.
#let force(
  on: none,
  magnitude: none,
  angle: 0deg,
  at: auto,
  label: auto,
  style: (:),
) = {
  validation.validate-simple-reference(on, "force()", "on")
  assert(
    on != none,
    message: "typed-physics: force() needs `on:` the name of the body it acts on",
  )
  assert(
    magnitude != none,
    message: "typed-physics: force() on \"" + on + "\" needs a `magnitude:`",
  )
  validation.validate-physical-scalar(
    magnitude,
    "force() on \"" + on + "\"",
    "magnitude",
  )
  assert(
    type(angle) == std.angle,
    message: "typed-physics: force() on \"" + on + "\" needs `angle:` as an angle",
  )
  validation.validate-attachment(
    at,
    "force() on \"" + on + "\"",
    "at",
    allow-auto: true,
    allow-ratio: true,
  )
  (
    kind: "force",
    on: on,
    magnitude: magnitude,
    angle: angle,
    at: at,
    label: label,
    style: validate-force-style(style, on),
  )
}

// How fast a body is already moving. A velocity is stated by the author rather
// than derived, and is drawn as an annotation rather than as a force, so it
// never appears in a free-body diagram.
#let velocity(on: none, magnitude: none, angle: 0deg, label: auto, style: (:)) = {
  validation.validate-simple-reference(on, "velocity()", "on")
  assert(
    on != none,
    message: "typed-physics: velocity() needs `on:` the name of the body it belongs to",
  )
  validation.validate-physical-scalar(
    magnitude,
    "velocity() on \"" + on + "\"",
    "magnitude",
    allow-none: true,
    allow-zero: true,
  )
  assert(
    type(angle) == std.angle,
    message: "typed-physics: velocity() on \"" + on + "\" needs `angle:` as an angle",
  )
  (
    kind: "velocity",
    on: on,
    magnitude: magnitude,
    angle: angle,
    label: label,
    style: validate-force-style(style, on),
  )
}

// Angular velocity is a motion annotation that follows a round body's outline.
// The direction chooses the arrow's travel; optional angles choose which free
// part of the outline carries it.
#let angular-velocity(
  on: none,
  magnitude: none,
  direction: "clockwise",
  radius: auto,
  start-angle: auto,
  end-angle: auto,
  label: auto,
  style: (:),
) = {
  validation.validate-simple-reference(on, "angular-velocity()", "on")
  assert(
    on != none,
    message: "typed-physics: angular-velocity() needs `on:` the round body it belongs to",
  )
  validation.validate-physical-scalar(
    magnitude,
    "angular-velocity() on \"" + on + "\"",
    "magnitude",
    allow-none: true,
    allow-zero: true,
  )
  assert(
    direction in ("clockwise", "counterclockwise"),
    message: "typed-physics: angular-velocity() direction: must be \"clockwise\" or \"counterclockwise\"",
  )
  assert(
    radius == auto or radius > 0,
    message: "typed-physics: angular-velocity() needs radius: auto or a positive number",
  )
  assert(
    start-angle == auto or type(start-angle) == std.angle,
    message: "typed-physics: angular-velocity() start-angle: must be auto or an angle",
  )
  assert(
    end-angle == auto or type(end-angle) == std.angle,
    message: "typed-physics: angular-velocity() end-angle: must be auto or an angle",
  )
  (
    kind: "angular-velocity",
    on: on,
    magnitude: magnitude,
    direction: direction,
    radius: radius,
    start-angle: start-angle,
    end-angle: end-angle,
    label: label,
    style: validate-force-style(style, on),
  )
}
