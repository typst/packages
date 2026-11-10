// Local validation for each declaration kind.

#import "validation-core.typ" as core
#import "validation-references.typ" as references
#import "validation-schema.typ" as schema
#import "validation-styles.typ" as styles

#let _value = core.value-representation
#let validate-name = core.validate-name
#let validate-enum = core.validate-enum
#let validate-boolean = core.validate-boolean
#let validate-angle = core.validate-angle
#let validate-positive-number = core.validate-positive-number
#let validate-nonnegative-number = core.validate-nonnegative-number
#let validate-positive-integer = core.validate-positive-integer
#let validate-ratio = core.validate-ratio
#let validate-physical-scalar = core.validate-physical-scalar
#let validate-simple-reference = references.validate-simple-reference
#let validate-attachment = references.validate-attachment
#let validate-style-dictionary = styles.validate-style-dictionary
#let validate-element-style = styles.validate-element-style
#let _named-kind = schema.named-kind

#let validate-friction(friction, source-description) = {
  if friction == none { return }
  assert(
    type(friction) == dictionary,
    message: (
      "typed-physics: "
        + source-description
        + " has malformed friction data "
        + _value(friction)
        + "; use `mu: 0.3` or `mu: (s: 0.4, k: 0.3)`"
    ),
  )
  assert(
    friction.keys().sorted() == ("kinetic", "static"),
    message: (
      "typed-physics: "
        + source-description
        + " has malformed friction fields; constructors must produce `static:` and `kinetic:`"
    ),
  )
  validate-physical-scalar(
    friction.static,
    source-description,
    "mu.static",
    allow-zero: true,
  )
  validate-physical-scalar(
    friction.kinetic,
    source-description,
    "mu.kinetic",
    allow-zero: true,
  )
  if (
    type(friction.static) in (int, float)
      and type(friction.kinetic) in (int, float)
  ) {
    assert(
      friction.static >= friction.kinetic,
      message: (
        "typed-physics: "
          + source-description
          + " has static friction "
          + _value(friction.static)
          + " below kinetic friction "
          + _value(friction.kinetic)
          + "; use coefficients with static >= kinetic"
      ),
    )
  }
}

#let validate-declaration-local(declaration, declaration-index) = {
  let kind = declaration.kind
  let source-description = if _named-kind(kind) {
    kind + " \"" + declaration.name + "\""
  } else {
    kind + "() declaration " + str(declaration-index + 1)
  }

  if _named-kind(kind) { validate-name(declaration.name, source-description: kind + "()") }
  if "style" in declaration {
    validate-style-dictionary(declaration.style, source-description)
    let allowed-style-keys = if kind in (
      "ground", "wall", "ceiling", "ramp", "arc",
    ) {
      ("fill", "stroke", "hatch-stroke", "hatch-spacing", "hatch-length")
    } else if kind in ("pivot", "support", "rope", "spring") {
      ("stroke", "fill")
    } else if kind in (
      "force", "torque", "velocity", "angular-velocity",
    ) {
      ("color", "stroke", "length", "text")
    } else {
      ("fill", "stroke", "label-text")
    }
    validate-element-style(
      declaration.style,
      allowed-style-keys,
      source-description,
    )
  }
  if "friction" in declaration {
    validate-friction(declaration.friction, source-description)
  }

  if kind == "ground" {
    validate-positive-number(declaration.length, source-description, "length")
    validate-attachment(declaration.from, source-description, "from", allow-none: true)
  } else if kind == "wall" {
    validate-positive-number(declaration.height, source-description, "height")
    validate-enum(declaration.side, ("left", "right"), source-description, "side")
    validate-attachment(declaration.from, source-description, "from", allow-none: true)
  } else if kind == "ceiling" {
    validate-positive-number(declaration.length, source-description, "length")
    validate-positive-number(declaration.height, source-description, "height")
    validate-attachment(declaration.from, source-description, "from", allow-none: true)
  } else if kind == "ramp" {
    validate-positive-number(declaration.length, source-description, "length")
    validate-angle(declaration.angle, source-description, "angle")
    assert(
      declaration.angle > 0deg and declaration.angle < 90deg,
      message: (
        "typed-physics: "
          + source-description
          + " has `angle:` "
          + _value(declaration.angle)
          + "; use an incline strictly between 0deg and 90deg"
      ),
    )
    validate-enum(declaration.facing, ("left", "right"), source-description, "facing")
    validate-attachment(declaration.from, source-description, "from", allow-none: true)
  } else if kind == "arc" {
    validate-positive-number(declaration.radius, source-description, "radius")
    validate-angle(declaration.start-angle, source-description, "start-angle")
    validate-angle(declaration.end-angle, source-description, "end-angle")
    assert(
      declaration.end-angle != declaration.start-angle
        and calc.abs((declaration.end-angle - declaration.start-angle).deg()) <= 360,
      message: (
        "typed-physics: "
          + source-description
          + " needs distinct arc angles spanning at most 360deg; adjust `start-angle:` or `end-angle:`"
      ),
    )
    validate-enum(declaration.side, ("inside", "outside"), source-description, "side")
    validate-attachment(declaration.from, source-description, "from", allow-none: true)
  } else if kind == "body" {
    validate-enum(
      declaration.shape,
      ("block", "ball", "point", "disk", "ring"),
      source-description,
      "shape",
    )
    validate-physical-scalar(
      declaration.mass,
      source-description,
      "mass",
      allow-none: true,
    )
    validate-ratio(declaration.at, source-description, "at")
    validate-positive-number(
      declaration.half-extent-along,
      source-description,
      "size",
    )
    validate-positive-number(
      declaration.half-extent-normal,
      source-description,
      "size",
    )
    validate-nonnegative-number(declaration.drop, source-description, "drop")
    validate-angle(declaration.orientation, source-description, "orientation")
    validate-boolean(declaration.radius-mark, source-description, "radius-mark")
    assert(
      (
        (
          declaration.hanging != none
            and declaration.on == none
            and declaration.touching == none
        )
          or (
            declaration.hanging == none
              and (
                declaration.on != none
                  or declaration.touching != none
              )
          )
      ),
      message: (
        "typed-physics: "
          + source-description
          + " needs `on:` or `touching:`, or it may use `hanging:` by itself; remove placement arguments that conflict with `hanging:`"
      ),
    )
    assert(
      declaration.touching == none or declaration.at == 50%,
      message: (
        "typed-physics: "
          + source-description
          + " uses `touching:`, so `at:` would be ignored; remove `at:` and use `side:` to choose the neighbour"
      ),
    )
    assert(
      declaration.hanging == none or declaration.at == 50%,
      message: (
        "typed-physics: "
          + source-description
          + " uses `hanging:`, so `at:` would be ignored; remove `at:` and select the attachment point through `hanging:`"
      ),
    )
    assert(
      declaration.touching != none
        or declaration.side == "right",
      message: (
        "typed-physics: "
          + source-description
          + " has `side:` "
          + _value(declaration.side)
          + " without `touching:`; remove `side:` or add a neighbouring body"
      ),
    )
    assert(
      declaration.hanging != none
        or declaration.drop == 1.5,
      message: (
        "typed-physics: "
          + source-description
          + " has `drop:` "
          + _value(declaration.drop)
          + " without `hanging:`; remove `drop:` or place the body from an attachment"
      ),
    )
    assert(
      declaration.hanging == none or declaration.friction == none,
      message: (
        "typed-physics: "
          + source-description
          + " is hanging and cannot use `mu:` because it has no surface contact; remove the friction coefficient"
      ),
    )
    if declaration.on != none {
      validate-simple-reference(declaration.on, source-description, "on")
    }
    if declaration.touching != none {
      validate-simple-reference(declaration.touching, source-description, "touching")
    }
    if declaration.hanging != none {
      validate-attachment(declaration.hanging, source-description, "hanging")
      assert(
        declaration.drop > 0,
        message: (
          "typed-physics: "
            + source-description
            + " is hanging but has `drop:` "
            + _value(declaration.drop)
            + "; use a positive drop so the body is below its attachment"
        ),
      )
    }
  } else if kind == "rod" {
    validate-positive-number(declaration.length, source-description, "length")
    validate-positive-number(declaration.thickness, source-description, "thickness")
    validate-angle(declaration.angle, source-description, "angle")
    validate-ratio(declaration.center-of-mass, source-description, "center-of-mass")
    validate-physical-scalar(
      declaration.mass,
      source-description,
      "mass",
      allow-none: true,
    )
    validate-attachment(declaration.from, source-description, "from", allow-none: true)
    validate-attachment(declaration.to, source-description, "to", allow-none: true)
  } else if kind in ("pivot", "pulley") {
    validate-attachment(declaration.at, source-description, "at")
    validate-positive-number(declaration.radius, source-description, "radius")
  } else if kind == "support" {
    validate-attachment(declaration.at, source-description, "at")
    validate-enum(
      declaration.support-kind,
      ("pin", "roller", "fixed"),
      source-description,
      "kind",
    )
    validate-angle(declaration.angle, source-description, "angle")
    validate-positive-number(declaration.size, source-description, "size")
  } else if kind == "pendulum" {
    validate-attachment(declaration.from, source-description, "from")
    validate-positive-number(declaration.length, source-description, "length")
    validate-positive-number(declaration.radius, source-description, "radius")
    assert(
      declaration.radius < declaration.length,
      message: "typed-physics: " + source-description + " needs `radius:` smaller than `length:` so the bob does not cover its pivot",
    )
    validate-angle(declaration.angle, source-description, "angle")
    validate-physical-scalar(
      declaration.mass,
      source-description,
      "mass",
      allow-none: true,
    )
  } else if kind in ("rope", "spring") {
    validate-attachment(declaration.from, source-description, "from")
    validate-attachment(declaration.to, source-description, "to")
    if kind == "spring" {
      validate-positive-integer(declaration.coils, source-description, "coils")
      validate-positive-number(declaration.width, source-description, "width")
    } else if declaration.over != none {
      validate-simple-reference(declaration.over, source-description, "over")
    }
  } else if kind == "force" {
    validate-simple-reference(declaration.on, source-description, "on")
    validate-physical-scalar(declaration.magnitude, source-description, "magnitude")
    validate-angle(declaration.angle, source-description, "angle")
    validate-attachment(
      declaration.at,
      source-description,
      "at",
      allow-auto: true,
      allow-ratio: true,
    )
  } else if kind == "torque" {
    validate-simple-reference(declaration.on, source-description, "on")
    validate-physical-scalar(
      declaration.magnitude,
      source-description,
      "magnitude",
      allow-none: true,
    )
    validate-attachment(
      declaration.at,
      source-description,
      "at",
      allow-auto: true,
      allow-ratio: true,
    )
    validate-enum(
      declaration.direction,
      ("clockwise", "counterclockwise"),
      source-description,
      "direction",
    )
    validate-positive-number(declaration.radius, source-description, "radius")
  } else if kind == "velocity" {
    validate-simple-reference(declaration.on, source-description, "on")
    validate-physical-scalar(
      declaration.magnitude,
      source-description,
      "magnitude",
      allow-none: true,
      allow-zero: true,
    )
    validate-angle(declaration.angle, source-description, "angle")
  } else if kind == "angular-velocity" {
    validate-simple-reference(declaration.on, source-description, "on")
    validate-physical-scalar(
      declaration.magnitude,
      source-description,
      "magnitude",
      allow-none: true,
      allow-zero: true,
    )
    validate-enum(
      declaration.direction,
      ("clockwise", "counterclockwise"),
      source-description,
      "direction",
    )
    if declaration.radius != auto {
      validate-positive-number(declaration.radius, source-description, "radius")
    }
    validate-angle(
      declaration.start-angle,
      source-description,
      "start-angle",
      allow-auto: true,
    )
    validate-angle(
      declaration.end-angle,
      source-description,
      "end-angle",
      allow-auto: true,
    )
  }
}
