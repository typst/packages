#let blur-to-deviation-factor = 1 / 2.6

/// Converts a value to a string.
///
/// Alternative str constructor that renders negative numbers
/// with a ASCII minus sign.
///
/// -> str
#let to-str(
  /// The value to convert.
  /// -> str | int | float
  value,
) = {
  if type(value) == str {
    value
  } else {
    if value < 0 {
      "-" + str(-value)
    } else {
      str(value)
    }
  }
}

/// Convert a radius to a length.
///
/// -> length
#let convert-radius(
  /// The radius to convert.
  /// -> length | ratio | relative
  radius,
  /// The objects width.
  /// -> length
  width,
  /// The objects height.
  /// -> length
  height,
) = {
  let radius = if type(radius) == length {
    radius
  } else if type(radius) == ratio {
    calc.min(width, height) * radius
  } else if type(radius) == relative {
    calc.min(width, height) * radius.ratio + radius.length
  }

  // Prevent negative values
  calc.max(radius, 0pt)
}

/// Normalize a radius.
///
/// Returns a dictionary that contains the radius of each corner at
/// "top-left", "top-right", "bottom-left", and "bottom-right".
///
/// -> dictionary
#let normalize-radius(
  /// The radius to normalize.
  /// -> length | ratio | relative | dictionary
  radius,
  /// The length of the shadow.
  /// -> length
  width,
  /// The height of the shadow.
  /// -> length
  height,
) = {
  if type(radius) != dictionary {
    let radius = convert-radius(radius, width, height)

    (
      "top-left": radius,
      "top-right": radius,
      "bottom-left": radius,
      "bottom-right": radius,
    )
  } else {
    let top-left = radius.at("rest", default: 0pt)
    let top-right = radius.at("rest", default: 0pt)
    let bottom-left = radius.at("rest", default: 0pt)
    let bottom-right = radius.at("rest", default: 0pt)

    bottom-left = radius.at("bottom", default: bottom-left)
    bottom-right = radius.at("bottom", default: bottom-right)

    top-right = radius.at("right", default: top-right)
    bottom-right = radius.at("right", default: bottom-right)

    top-left = radius.at("top", default: top-left)
    top-right = radius.at("top", default: top-right)

    top-left = radius.at("left", default: top-left)
    bottom-left = radius.at("left", default: bottom-left)

    bottom-left = radius.at("bottom-left", default: bottom-left)

    bottom-right = radius.at("bottom-right", default: bottom-right)

    top-right = radius.at("top-right", default: top-right)

    top-left = radius.at("top-left", default: top-left)

    (
      "top-left": convert-radius(top-left, width, height),
      "top-right": convert-radius(top-right, width, height),
      "bottom-left": convert-radius(bottom-left, width, height),
      "bottom-right": convert-radius(bottom-right, width, height),
    )
  }
}

/// Normalize a spread.
///
/// Returns a dictionary that contains the spread of each side at
/// "top", "right", "bottom", and "left".
///
/// If a dictionary is passed, the spread of each side can be set
/// individually using the following keys in order of precedence:
/// - top: The spread of the top side.
/// - right: The spread of the right side.
/// - bottom: The spread of the bottom side.
/// - left: The spread of the left side.
/// - x: The spread of the left and right sides.
/// - y: The spread of the top and bottom sides.
/// - rest: The spread for all sides except those for which the dictionary
///   explicitly sets a size.
///
/// For outset shadows the spreads are clamped so that the shadow is never
/// contracted more than the size of the box itself. For inset shadows they
/// are clamped so that the inner boundary never collapses past the box.
///
/// -> dictionary
#let normalize-spread(
  /// The spread to normalize.
  /// -> length | dictionary
  spread,
  /// The width of the shadow.
  /// -> length
  width,
  /// The height of the shadow.
  /// -> length
  height,
  /// Whether the spread is for an inset shadow.
  /// -> bool
  inset: false,
) = {
  let (top, right, bottom, left) = if type(spread) != dictionary {
    (spread, spread, spread, spread)
  } else {
    let top = spread.at("rest", default: 0pt)
    let right = spread.at("rest", default: 0pt)
    let bottom = spread.at("rest", default: 0pt)
    let left = spread.at("rest", default: 0pt)

    bottom = spread.at("bottom", default: bottom)
    right = spread.at("right", default: right)
    top = spread.at("top", default: top)
    left = spread.at("left", default: left)

    left = spread.at("x", default: left)
    right = spread.at("x", default: right)

    top = spread.at("y", default: top)
    bottom = spread.at("y", default: bottom)

    (top, right, bottom, left)
  }

  if not inset {
    // Clamp the spreads so the shadow never contracts past the box itself
    let shrink-x = -(left + right)
    if shrink-x > width {
      let factor = width / shrink-x
      left *= factor
      right *= factor
    }

    let shrink-y = -(top + bottom)
    if shrink-y > height {
      let factor = height / shrink-y
      top *= factor
      bottom *= factor
    }
  } else {
    // Clamp the spreads so the inner boundary never inverts past the box
    let expand-x = left + right
    if expand-x > width {
      let factor = width / expand-x
      left *= factor
      right *= factor
    }

    let expand-y = top + bottom
    if expand-y > height {
      let factor = height / expand-y
      top *= factor
      bottom *= factor
    }
  }

  (
    top: top,
    right: right,
    bottom: bottom,
    left: left,
  )
}

/// Interpolates the gradient stops based on the color space.
///
/// -> array
#let interpolate-stops(
  /// The gradient.
  /// -> gradient
  gradient,
) = {
  let in-stops = gradient.stops()
  let stop-count = in-stops.len()

  // Avoid `windows(2)` returning nothing for degenerate gradients
  if stop-count < 2 {
    return in-stops
  }

  let default-len = calc.max(int(256 / stop-count), 2)
  let stops = ()

  for (from, to) in in-stops.windows(2) {
    let from-color = from.at(0)
    let to-color = to.at(0)
    let from-offset = from.at(1)
    let to-offset = to.at(1)
    let delta = to-offset - from-offset

    // No interpolation needed for identical colors
    let len = if from-color == to-color { 1 } else { default-len }

    stops.push((from-color, from-offset))

    for i in range(1, len - 1) {
      let t0 = i / (len - 1)
      let offset = from-offset + delta * t0
      let color = gradient.sample(offset)

      stops.push((color, offset))
    }

    stops.push((to-color, to-offset))
  }

  stops
}

/// Get the quadrant of the Cartesian plane that this angle lies in.
///
/// The angle is automatically normalized to the range `0deg..=360deg`.
///
/// The quadrants are defined as follows:
/// - 1: `0deg..=90deg` (top-right)
/// - 2: `90deg..=180deg` (top-left)
/// - 3: `180deg..=270deg` (bottom-left)
/// - 4: `270deg..=360deg` (bottom-right)
///
/// -> int
#let angle-quadrant(
  /// The angle.
  /// -> angle
  angle,
) = {
  let normalized-angle = calc.rem-euclid(angle.deg(), 360) * 1deg

  if normalized-angle <= 90deg {
    1
  } else if normalized-angle <= 180deg {
    2
  } else if normalized-angle <= 270deg {
    3
  } else {
    4
  }
}

/// Corrects the angle for gradient vector calculation based on the aspect ratio.
///
/// -> angle
#let correct-angle(
  /// The angle.
  /// -> angle
  angle,
  /// The ratio.
  /// -> int | float
  ratio,
) = {
  let rad = calc
    .atan(calc.tan(calc.rem-euclid(angle.rad(), calc.tau)) / ratio)
    .rad()
  let quadrant = angle-quadrant(angle)

  // rad stays the same in quadrant 1
  if quadrant == 2 or quadrant == 3 {
    rad += calc.pi
  } else {
    rad += calc.tau
  }

  calc.rem-euclid(rad, calc.tau) * 1rad
}

/// Calculate the gradient vector for a linear gradient.
///
/// Returns the vector coordinates in form of (x1, y1, x2, y2).
///
/// -> array
#let calculate-gradient-vector(
  /// The angle.
  /// -> angle
  angle,
  /// The width.
  /// -> int | float | length
  width,
  /// The height.
  /// -> int | float | length
  height,
) = {
  let ratio = width / height
  let angle = correct-angle(angle, ratio)

  let (sin, cos) = (calc.sin(angle), calc.cos(angle))
  let length = calc.abs(sin) + calc.abs(cos)
  let quadrant = angle-quadrant(angle)

  if quadrant == 1 {
    (0, 0, cos * length, sin * length)
  } else if quadrant == 2 {
    (1, 0, cos * length + 1, sin * length)
  } else if quadrant == 3 {
    (1, 1, cos * length + 1, sin * length + 1)
  } else {
    (0, 1, cos * length, sin * length + 1)
  }
}

/// Renders a gradient stop.
///
/// -> str
#let stop-template(
  /// The stop in the form of (color, ratio).
  /// -> list
  stop,
) = {
  let stop-color = stop.at(0).to-hex()
  let offset = stop.at(1) / 1%

  // begin templates/stop.svg.template
  (
    "<stop offset=\"",
    to-str(offset),
    "%\" stop-color=\"",
    to-str(stop-color),
    "\" />",
  ).join()
  // end templates/stop.svg.template
}

/// Renders a linear gradient.
///
/// -> str
#let linear-gradient-template(
  /// The gradient of kind gradient.linear.
  /// -> gradient
  gradient,
  /// The width of the gradient.
  /// -> int | float
  gradient-width,
  /// The height of the gradient.
  /// -> int | float
  gradient-height,
) = {
  let interpolated-stops = interpolate-stops(gradient)
  let stops = interpolated-stops.map(stop => stop-template(stop)).join()

  let (x1, y1, x2, y2) = calculate-gradient-vector(
    gradient.angle(),
    gradient-width,
    gradient-height,
  )

  // begin templates/linear-gradient.svg.template
  (
    "<linearGradient id=\"gradient\" gradientUnits=\"userSpaceOnUse\" x1=\"",
    to-str(x1),
    "\" y1=\"",
    to-str(y1),
    "\" x2=\"",
    to-str(x2),
    "\" y2=\"",
    to-str(y2),
    "\" gradientTransform=\"matrix(",
    to-str(gradient-width),
    " 0 0 ",
    to-str(gradient-height),
    " 0 0)\"> ",
    to-str(stops),
    " </linearGradient>",
  ).join()
  // end templates/linear-gradient.svg.template
}

/// Renders a radial gradient.
///
/// -> str
#let radial-gradient-template(
  /// The gradient of kind gradient.radial.
  /// -> gradient
  gradient,
  /// The width of the gradient.
  /// -> int | float
  gradient-width,
  /// The height of the gradient.
  /// -> int | float
  gradient-height,
) = {
  let center-x = gradient.center().at(0) / 100%
  let center-y = gradient.center().at(1) / 100%
  let focal-center-x = gradient.focal-center().at(0) / 100%
  let focal-center-y = gradient.focal-center().at(1) / 100%
  let radius = gradient.radius() / 100%
  let focal-radius = gradient.focal-radius() / 100%
  let stops = gradient.stops().map(stop => stop-template(stop)).join()

  // begin templates/radial-gradient.svg.template
  (
    "<radialGradient id=\"gradient\" gradientUnits=\"userSpaceOnUse\" cx=\"",
    to-str(center-x),
    "\" cy=\"",
    to-str(center-y),
    "\" fx=\"",
    to-str(focal-center-x),
    "\" fy=\"",
    to-str(focal-center-y),
    "\" r=\"",
    to-str(radius),
    "\" fr=\"",
    to-str(focal-radius),
    "\" gradientTransform=\"matrix(",
    to-str(gradient-width),
    " 0 0 ",
    to-str(gradient-height),
    " 0 0)\"> ",
    to-str(stops),
    " </radialGradient>",
  ).join()
  // end templates/radial-gradient.svg.template
}

/// Renders a gradient based on its kind.
///
/// -> str
#let gradient-template(
  /// The gradient of kind gradient.linear or gradient.radial.
  /// -> gradient
  gradient,
  /// The gradient width.
  /// -> int | float
  gradient-width,
  /// The gradient height.
  /// -> int | float
  gradient-height,
) = {
  if gradient.kind() == std.gradient.linear {
    linear-gradient-template(gradient, gradient-width, gradient-height)
  } else if gradient.kind() == std.gradient.radial {
    radial-gradient-template(gradient, gradient-width, gradient-height)
  } else {
    panic("gradient-template: gradient must be of kind linear or radial")
  }
}

/// Resolves a fill to its string representation and optional gradient definition.
///
/// -> array
#let resolve-fill(
  /// The fill to resolve.
  /// -> color | gradient
  fill,
  /// The SVG width.
  /// -> int | float
  svg-width,
  /// The SVG height.
  /// -> int | float
  svg-height,
) = {
  let gradient = if type(fill) == gradient {
    gradient-template(fill, svg-width, svg-height)
  } else {
    ""
  }
  let fill = if type(fill) == color { fill.to-hex() } else { "url(#gradient)" }

  (fill, gradient)
}

/// Renders the path of a rounded rectangle.
///
/// -> str
#let box-path(
  /// The x position of the rectangle.
  /// -> int | float
  rect-dx: none,
  /// The y position of the rectangle.
  /// -> int | float
  rect-dy: none,
  /// The width of the rectangle.
  /// -> int | float
  rect-width: none,
  /// The height of the rectangle.
  /// -> int | float
  rect-height: none,
  /// The top-left radius.
  /// -> int | float
  radius-tl: none,
  /// The top-right radius.
  /// -> int | float
  radius-tr: none,
  /// The bottom-left radius.
  /// -> int | float
  radius-bl: none,
  /// The bottom-right radius.
  /// -> int | float
  radius-br: none,
) = {
  // begin templates/box-path.svg.template
  (
    "M ",
    to-str(rect-dx + radius-tl),
    ", ",
    to-str(rect-dy),
    " H ",
    to-str(rect-dx + rect-width - radius-tr),
    " A ",
    to-str(radius-tr),
    " ",
    to-str(radius-tr),
    " 0 0 1 ",
    to-str(rect-dx + rect-width),
    ", ",
    to-str(rect-dy + radius-tr),
    " V ",
    to-str(rect-dy + rect-height - radius-br),
    " A ",
    to-str(radius-br),
    " ",
    to-str(radius-br),
    " 0 0 1 ",
    to-str(rect-dx + rect-width - radius-br),
    ", ",
    to-str(rect-dy + rect-height),
    " H ",
    to-str(rect-dx + radius-bl),
    " A ",
    to-str(radius-bl),
    " ",
    to-str(radius-bl),
    " 0 0 1 ",
    to-str(rect-dx),
    ", ",
    to-str(rect-dy + rect-height - radius-bl),
    " V ",
    to-str(rect-dy + radius-tl),
    " A ",
    to-str(radius-tl),
    " ",
    to-str(radius-tl),
    " 0 0 1 ",
    to-str(rect-dx + radius-tl),
    ", ",
    to-str(rect-dy),
    " Z",
  ).join()
  // end templates/box-path.svg.template
}

/// Renders a SVG box shadow.
///
/// -> str
#let shadow-template(
  /// The SVG width.
  /// -> int | float
  svg-width: none,
  /// The SVG height.
  /// -> int | float
  svg-height: none,
  /// The blur deviation.
  /// -> int | float
  blur-deviation: none,
  /// The fill color or gradient.
  /// -> color | gradient
  fill: none,
  /// The gradient x position.
  /// -> int | float
  rect-dx: none,
  /// The gradient y position.
  /// -> int | float
  rect-dy: none,
  /// The gradient width.
  /// -> int | float
  rect-width: none,
  /// The gradient height.
  /// -> int | float
  rect-height: none,
  /// The top-left radius.
  /// -> int | float
  radius-tl: none,
  /// The top-right radius.
  /// -> int | float
  radius-tr: none,
  /// The bottom-left radius.
  /// -> int | float
  radius-bl: none,
  /// The bottom-right radius.
  /// -> int | float
  radius-br: none,
) = {
  let (fill, gradient) = resolve-fill(fill, svg-width, svg-height)

  // begin templates/shadow.svg.template
  (
    "<svg viewBox=\"0 0 ",
    to-str(svg-width),
    " ",
    to-str(svg-height),
    "\" height=\"",
    to-str(svg-height),
    "pt\" width=\"",
    to-str(svg-width),
    "pt\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"> <defs> ",
    to-str(gradient),
    " <filter id=\"shadow\" filterUnits=\"userSpaceOnUse\" primitiveUnits=\"userSpaceOnUse\" x=\"-10%\" y=\"-10%\" width=\"120%\" height=\"120%\"> <feGaussianBlur in=\"SourceGraphic\" stdDeviation=\"",
    to-str(blur-deviation),
    "\" result=\"blur\" /> </filter> </defs> <path d=\"",
    to-str(box-path(
      rect-dx: rect-dx,
      rect-dy: rect-dy,
      rect-width: rect-width,
      rect-height: rect-height,
      radius-tl: radius-tl,
      radius-tr: radius-tr,
      radius-bl: radius-bl,
      radius-br: radius-br,
    )),
    "\" fill=\"",
    to-str(fill),
    "\" filter=\"url(#shadow)\" /> </svg>",
  ).join()
  // end templates/shadow.svg.template
}

/// Renders a SVG inner box shadow.
///
/// -> str
#let inset-shadow-template(
  /// The SVG width.
  /// -> int | float
  svg-width: none,
  /// The SVG height.
  /// -> int | float
  svg-height: none,
  /// The blur deviation.
  /// -> int | float
  blur-deviation: none,
  /// The fill color or gradient.
  /// -> color | gradient
  fill: none,
  /// The x position of the box boundary.
  /// -> int | float
  rect-dx: none,
  /// The y position of the box boundary.
  /// -> int | float
  rect-dy: none,
  /// The width of the box boundary.
  /// -> int | float
  rect-width: none,
  /// The height of the box boundary.
  /// -> int | float
  rect-height: none,
  /// The x position of the inner hole.
  /// -> int | float
  inner-dx: none,
  /// The y position of the inner hole.
  /// -> int | float
  inner-dy: none,
  /// The width of the inner hole.
  /// -> int | float
  inner-width: none,
  /// The height of the inner hole.
  /// -> int | float
  inner-height: none,
  /// The top-left radius.
  /// -> int | float
  radius-tl: none,
  /// The top-right radius.
  /// -> int | float
  radius-tr: none,
  /// The bottom-left radius.
  /// -> int | float
  radius-bl: none,
  /// The bottom-right radius.
  /// -> int | float
  radius-br: none,
) = {
  let (fill, gradient) = resolve-fill(fill, svg-width, svg-height)

  // begin templates/inset-shadow.svg.template
  (
    "<svg viewBox=\"0 0 ",
    to-str(svg-width),
    " ",
    to-str(svg-height),
    "\" height=\"",
    to-str(svg-height),
    "pt\" width=\"",
    to-str(svg-width),
    "pt\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"> <defs> ",
    to-str(gradient),
    " <path id=\"box-boundary\" d=\"",
    to-str(box-path(
      rect-dx: rect-dx,
      rect-dy: rect-dy,
      rect-width: rect-width,
      rect-height: rect-height,
      radius-tl: radius-tl,
      radius-tr: radius-tr,
      radius-bl: radius-bl,
      radius-br: radius-br,
    )),
    "\" /> <path id=\"inset-shape\" fill-rule=\"evenodd\" d=\"",
    to-str(
      box-path(
        rect-dx: 0,
        rect-dy: 0,
        rect-width: svg-width,
        rect-height: svg-height,
        radius-tl: 0,
        radius-tr: 0,
        radius-bl: 0,
        radius-br: 0,
      )
        + box-path(
          rect-dx: inner-dx,
          rect-dy: inner-dy,
          rect-width: inner-width,
          rect-height: inner-height,
          radius-tl: radius-tl,
          radius-tr: radius-tr,
          radius-bl: radius-bl,
          radius-br: radius-br,
        ),
    ),
    "\" /> <filter id=\"inset-blur\" filterUnits=\"userSpaceOnUse\" primitiveUnits=\"userSpaceOnUse\" x=\"0\" y=\"0\" width=\"",
    to-str(svg-width),
    "\" height=\"",
    to-str(svg-height),
    "\"> <feGaussianBlur in=\"SourceGraphic\" stdDeviation=\"",
    to-str(blur-deviation),
    "\" /> </filter> <mask id=\"inset-mask\" maskUnits=\"userSpaceOnUse\" x=\"0\" y=\"0\" width=\"",
    to-str(svg-width),
    "\" height=\"",
    to-str(svg-height),
    "\"> <use href=\"#inset-shape\" fill=\"white\" filter=\"url(#inset-blur)\" /> </mask> <clipPath id=\"box-clip\"> <use href=\"#box-boundary\" /> </clipPath> </defs> <g clip-path=\"url(#box-clip)\"> <rect x=\"0\" y=\"0\" width=\"",
    to-str(svg-width),
    "\" height=\"",
    to-str(svg-height),
    "\" fill=\"",
    to-str(fill),
    "\" mask=\"url(#inset-mask)\" /> </g> </svg>",
  ).join()
  // end templates/inset-shadow.svg.template
}

/// A box shadow.
///
/// ```example
/// #shadow(blur: 6pt, spread: 2pt)[
///   #block(inset: 4pt, fill: white)[
///    #text("This block has a shadow!")
///  ]
/// ]
/// ```
///
/// -> content
#let shadow(
  /// Whether to draw the shadow inside the box instead of outside.
  ///
  /// -> bool
  inset: false,
  /// The horizontal offset.
  /// -> length
  dx: 0pt,
  /// The vertical offset.
  /// -> length
  dy: 0pt,
  /// How strong to blur the shadow.
  ///
  /// Must be equal to or greater than 0pt.
  ///
  /// -> length
  blur: 0pt,
  /// How far to spread the shadow.
  ///
  /// Can be either:
  /// - A length for a uniform spread.
  ///
  /// - A dictionary: With a dictionary, the spread for each side can be set
  ///   individually.
  ///   The dictionary can contain the following keys in order of precedence:
  ///   - top: The spread of the top side.
  ///   - right: The spread of the right side.
  ///   - bottom: The spread of the bottom side.
  ///   - left: The spread of the left side.
  ///   - x: The spread of the left and right sides.
  ///   - y: The spread of the top and bottom sides.
  ///   - rest: The spread for all sides except those for which the dictionary
  ///     explicitly sets a size.
  ///
  /// Negative values contract the shadow on the respective side.
  ///
  /// -> length | dictionary
  spread: 0pt,
  /// How to fill the shadow.
  ///
  /// Currently only supports linear or radial gradients.
  ///
  /// -> color | gradient | none
  fill: black,
  /// How much to round the shadow's corners.
  ///
  /// Can be either:
  /// - A relative length for a uniform corner radius,
  ///   relative to the minimum of the width and height divided by two.
  ///
  /// - A dictionary: With a dictionary, the stroke for each side can be set
  ///   individually.
  ///   The dictionary can contain the following keys in order of precedence:
  ///   - top-left: The top-left corner radius.
  ///   - top-right: The top-right corner radius.
  ///   - bottom-right: The bottom-right corner radius.
  ///   - bottom-left: The bottom-left corner radius.
  ///   - left: The top-left and bottom-left corner radii.
  ///   - top: The top-left and top-right corner radii.
  ///   - right: The top-right and bottom-right corner radii.
  ///   - bottom: The bottom-left and bottom-right corner radii.
  ///   - rest: The radii for all corners except those for which the dictionary
  ///     explicitly sets a size.
  ///
  /// -> relative | dictionary
  radius: 0pt,
  /// The content to place in front of the shadow.
  /// -> content
  body,
) = layout(
  size => {
    // Type checks
    assert(type(inset) == bool, message: "shadow: inset must be of type bool")
    assert(type(dx) == length, message: "shadow: dx must be of type length")
    assert(type(dy) == length, message: "shadow: dy must be of type length")
    assert(type(blur) == length, message: "shadow: blur must be of type length")
    assert(
      type(spread) == length or type(spread) == dictionary,
      message: "shadow: spread must be of type length or dictionary",
    )
    assert(
      type(fill) == color or type(fill) == gradient or fill == none,
      message: "shadow: fill must be of type color or gradient or none",
    )
    assert(
      type(radius) == length
        or type(radius) == ratio
        or type(radius) == relative
        or type(radius) == dictionary,
      message: "shadow: radius must be of type length, ratio, relative or dictionary",
    )
    assert(
      type(body) == content,
      message: "shadow: body must be of type content",
    )

    // Type-dependent type checks
    if type(radius) == dictionary {
      let radius-keys = (
        "top-left",
        "top-right",
        "bottom-left",
        "bottom-right",
        "left",
        "top",
        "right",
        "bottom",
        "rest",
      )
      for key in radius.keys() {
        assert(
          key in radius-keys,
          message: "shadow: radius has unsupported key " + str(key),
        )
      }

      for r in radius.values() {
        assert(
          type(r) == length or type(r) == ratio or type(r) == relative,
          message: "shadow: radius must be of type length, ratio or relative",
        )
      }
    }

    if type(fill) == gradient {
      assert(
        fill.kind() == std.gradient.linear
          or fill.kind() == std.gradient.radial,
        message: "shadow: fill must be of kind linear or radial",
      )
    }

    if type(spread) == dictionary {
      let spread-keys = ("top", "right", "bottom", "left", "x", "y", "rest")
      for key in spread.keys() {
        assert(
          key in spread-keys,
          message: "shadow: spread has unsupported key " + str(key),
        )
      }

      for s in spread.values() {
        assert(
          type(s) == length,
          message: "shadow: spread values must be of type length",
        )
      }
    }

    // Value checks
    assert(
      blur >= 0pt,
      message: "shadow: blur must be greater or equal to zero",
    )

    // Return only the body if no fill is specified
    if (fill == none) {
      return body
    }

    let (width, height) = measure(width: size.width, height: size.height)[
      #body
    ]

    // Return empty block if width or height are zero to avoid issues with dividing by zero
    if (width == 0pt or height == 0pt) {
      return block()
    }

    let radius = normalize-radius(radius, width, height)
    let spread = normalize-spread(spread, width, height, inset: inset)

    // Fold the offset into the spread to translate the shadow. Since the
    // offset is applied after the spread is clamped, it never contracts the
    // shadow past the box itself. For inset shadows the hole is shifted
    // instead, so the shadow band thickens on the side opposite to the
    // offset (see below).
    if not inset {
      spread.left -= dx
      spread.right += dx
      spread.top -= dy
      spread.bottom += dy
    }

    // Grow the SVG size by the spread and blur to ensure that the shadow is not clipped
    let grow-x = calc.max(blur + spread.left, blur + spread.right, 0pt)
    let grow-y = calc.max(blur + spread.top, blur + spread.bottom, 0pt)

    let svg-height = height + grow-y * 2
    let svg-width = width + grow-x * 2

    let blur-deviation = blur * blur-to-deviation-factor

    let svg-source = if inset {
      // The hole of an inset shadow is the box contracted by the spread on
      // each side. Its position shifts with the offset, thickening the
      // shadow band on the side opposite to the offset, and is clamped so
      // it never moves past the box itself. The padding around the box
      // (grow-x/grow-y) gives the blur room to build up full opacity before
      // it reaches the box edge, instead of fading out right at the edge.
      let clamped-dx = calc.min(
        calc.max(spread.left + dx, 0pt),
        width - spread.left - spread.right,
      )
      let clamped-dy = calc.min(
        calc.max(spread.top + dy, 0pt),
        height - spread.top - spread.bottom,
      )
      let inner-dx = grow-x + clamped-dx
      let inner-dy = grow-y + clamped-dy
      let inner-width = width - spread.left - spread.right
      let inner-height = height - spread.top - spread.bottom

      inset-shadow-template(
        svg-width: svg-width.pt(),
        svg-height: svg-height.pt(),
        blur-deviation: blur-deviation.pt(),
        fill: fill,
        rect-dx: grow-x.pt(),
        rect-dy: grow-y.pt(),
        rect-width: width.pt(),
        rect-height: height.pt(),
        inner-dx: inner-dx.pt(),
        inner-dy: inner-dy.pt(),
        inner-width: inner-width.pt(),
        inner-height: inner-height.pt(),
        radius-tl: radius.top-left.pt(),
        radius-tr: radius.top-right.pt(),
        radius-bl: radius.bottom-left.pt(),
        radius-br: radius.bottom-right.pt(),
      )
    } else {
      shadow-template(
        svg-width: svg-width.pt(),
        svg-height: svg-height.pt(),
        blur-deviation: blur-deviation.pt(),
        fill: fill,
        rect-dx: (grow-x - spread.left).pt(),
        rect-dy: (grow-y - spread.top).pt(),
        rect-width: (width + spread.left + spread.right).pt(),
        rect-height: (height + spread.top + spread.bottom).pt(),
        radius-tl: radius.top-left.pt(),
        radius-tr: radius.top-right.pt(),
        radius-bl: radius.bottom-left.pt(),
        radius-br: radius.bottom-right.pt(),
      )
    }
    let svg = image(
      bytes(svg-source),
      height: svg-height,
      width: svg-width,
      format: "svg",
      alt: "box-shadow",
    )

    block(breakable: false)[
      // For inset shadows, draw the body first so the shadow is placed on top of it
      #if inset [
        #body
      ]

      #place(center + horizon)[
        #svg <shadowed-shadow>
      ]

      // For outset shadows, draw the body after so it stays on top of the shadow
      #if not inset [
        #body
      ]
    ]
  },
)
