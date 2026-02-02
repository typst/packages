#let blur-to-deviation-factor = 1 / 2.6

/// Converts a value to a string.
///
/// Alternative str constructor that renders negative numbers
/// with a ASCII minus sign.
///
/// - value (str, int, float):
/// -> str
#let to-str(value) = {
  if type(value) == str {
    value
  } else if type(value) == int or type(value) == float {
    if value < 0 {
      "-" + str(-value)
    } else {
      str(value)
    }
  } else {
    panic("to-str: unsupported type " + str(type(value)))
  }
}

/// Convert a radius to a length.
///
/// - radius (length, ratio, relative): The radius to convert.
/// - width (length): The objects width.
/// - height (length): The objects height.
/// -> length
#let convert-radius(radius, width, height) = {
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
/// - radius (length, dictionary): The radius to normalize.
/// - width (length): The length of the shadow.
/// - height (length): The height of the shadow.
/// -> dictionary
#let normalize-radius(radius, width, height) = {
  if (
    type(radius) == length or type(radius) == ratio or type(radius) == relative
  ) {
    let radius = convert-radius(radius, width, height)

    (
      "top-left": radius,
      "top-right": radius,
      "bottom-left": radius,
      "bottom-right": radius,
    )
  } else if type(radius) == dictionary {
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
  } else {
    panic(
      "normalize-radius: radius must be of type length, ratio, relative or dictionary, got "
        + str(type(radius)),
    )
  }
}

/// Interpolates the gradient stops based on the color space.
///
/// - gradient (gradient): The gradient.
/// -> array
#let interpolate-stops(gradient) = {
  let in-stops = gradient.stops()
  let stop-count = in-stops.len()
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
/// - angle (angle): The angle.
/// -> int
#let angle-quadrant(angle) = {
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
/// - angle (angle): The angle.
/// - ratio (int, float): The ratio.
/// -> angle
#let correct-angle(angle, ratio) = {
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
/// - angle (angle): The angle.
/// - width (int, float, length): The width.
/// - height (int, float, length): The height.
/// -> array
#let calculate-gradient-vector(angle, width, height) = {
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
/// - stop (list): The stop in form of (color, ratio).
/// -> str
#let stop-template(stop) = {
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
/// - gradient (gradient): The gradient of kind gradient.linear.
/// - gradient-width (int, float): The width of the gradient.
/// - gradient-height (int, float): The height of the gradient.
/// -> str
#let linear-gradient-template(gradient, gradient-width, gradient-height) = {
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
/// - gradient (gradient): The gradient of kind gradient.radial.
/// -> str
#let radial-gradient-template(gradient, gradient-width, gradient-height) = {
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
/// - gradient (gradient): The gradient of kind gradient.linear or gradient.radial.
/// - gradient-width (int, float): The gradient width.
/// - gradient-height (int, float): The gradient height.
/// -> str
#let gradient-template(gradient, gradient-width, gradient-height) = {
  if gradient.kind() == std.gradient.linear {
    linear-gradient-template(gradient, gradient-width, gradient-height)
  } else if gradient.kind() == std.gradient.radial {
    radial-gradient-template(gradient, gradient-width, gradient-height)
  } else {
    panic("gradient-template: gradient must be of kind linear or radial")
  }
}

/// Renders a SVG box shadow.
///
/// - svg-width (int, float): The SVG width.
/// - svg-height (int, float): The SVG height.
/// - blur-deviation (int, float): The blur deviation.
/// - spread-radius (int, float): The spread radius.
/// - fill (color, gradient): The fill color or gradient.
/// - rect-dx (int, float): The gradient x position.
/// - rect-dy (int, float): The gradient y position.
/// - rect-width (int, float): The gradient width.
/// - rect-height (int, float): The gradient height.
/// - radius-tl (int, float): The top-left radius.
/// - radius-tr (int, float): The top-right radius.
/// - radius-bl (int, float): The bottom-left radius.
/// - radius-br (int, float): The bottom-right radius.
/// -> str
#let shadow-template(
  svg-width: none,
  svg-height: none,
  blur-deviation: none,
  spread-radius: none,
  fill: none,
  rect-dx: none,
  rect-dy: none,
  rect-width: none,
  rect-height: none,
  radius-tl: none,
  radius-tr: none,
  radius-bl: none,
  radius-br: none,
) = {
  let gradient = if type(fill) == gradient {
    gradient-template(fill, svg-width, svg-height)
  } else { "" }
  let fill = if type(fill) == color { fill.to-hex() } else { "url(#gradient)" }
  let spread-operator = if spread-radius >= 0 { "dilate" } else { "erode" }
  let spread-radius = calc.abs(spread-radius)

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
    "\" result=\"blur\" /> <feMorphology operator=\"",
    to-str(spread-operator),
    "\" radius=\"",
    to-str(spread-radius),
    "\" in=\"blur\" result=\"spread\" /> </filter> </defs> <path d=\" M ",
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
    " Z \" fill=\"",
    to-str(fill),
    "\" filter=\"url(#shadow)\" /> </svg>",
  ).join()
  // end templates/shadow.svg.template
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
  /// How far to spread the length of the shadow.
  /// -> length
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
    assert(type(dx) == length, message: "shadow: dx must be of type length")
    assert(type(dy) == length, message: "shadow: dy must be of type length")
    assert(type(blur) == length, message: "shadow: blur must be of type length")
    assert(
      type(spread) == length,
      message: "shadow: spread must be of type length",
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

    // Type-dependent type checks
    if type(radius) == dictionary {
      for r in radius.values() {
        assert(
          type(r) == length or type(r) == ratio or type(r) == relative,
          message: "shadow: radius must be of type length, ratio or relative",
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
      body
    }

    let (width, height) = measure(width: size.width, height: size.height)[
      #body
    ]

    // Return empty block if width or height are zero to avoid issues with dividing by zero
    if (width == 0pt or height == 0pt) {
      return block()
    }

    let outset = calc.max(blur + spread, 0pt)

    let radius = normalize-radius(radius, width, height)

    let svg-height = height + outset * 2
    let svg-width = width + outset * 2
    let blur-deviation = blur * blur-to-deviation-factor

    let svg-source = shadow-template(
      svg-width: svg-width.pt(),
      svg-height: svg-height.pt(),
      blur-deviation: blur-deviation.pt(),
      spread-radius: spread.pt(),
      fill: fill,
      rect-dx: outset.pt(),
      rect-dy: outset.pt(),
      rect-width: width.pt(),
      rect-height: height.pt(),
      radius-tl: radius.at("top-left").pt(),
      radius-tr: radius.at("top-right").pt(),
      radius-bl: radius.at("bottom-left").pt(),
      radius-br: radius.at("bottom-right").pt(),
    )
    let svg = image(
      bytes(svg-source),
      height: svg-height,
      width: svg-width,
      format: "svg",
      alt: "box-shadow",
    )

    block(breakable: false)[
      #place(center + horizon, dx: dx, dy: dy)[
        #svg <shadowed-shadow>
      ]

      #body
    ]
  },
)
