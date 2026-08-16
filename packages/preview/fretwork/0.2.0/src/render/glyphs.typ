// Music symbols, drawn as vector paths.
//
// Typst packages cannot ship fonts — a font dependency has to be installed by
// hand by every user, which is the well-known pain point of packages that need
// one. Drawing the symbols instead keeps the package self-contained and works
// at any size, and phase 1 needs only a small set: flags, rests, dots, repeat
// signs, articulations and the note value in a tempo mark.
//
// Every glyph returns `(width, height, body)`. The body is a box of exactly
// that size with the drawing inside, so callers position it by its top-left
// corner and know its extent without measuring.

// Closed paths are always closed with `mode: "straight"`. Typst's default is
// "smooth", which joins the last point back to the first with a tangent-matched
// curve — when the two coincide, as they do in every shape here, that produces a
// spike sticking out of the figure.

/// Wrap a drawing in a box of known size.
///
/// Every element inside `body` must be positioned with `_draw` or `_blob`.
/// Content that merely flows would push the box past its declared extent, and
/// callers rely on `width` and `height` being exact.
#let _glyph(w, h, body) = (width: w, height: h, body: box(width: w, height: h, body))

/// Anchor a drawing at the glyph's top-left corner.
#let _draw(el) = place(top + left, dx: 0pt, dy: 0pt, el)

/// Place a filled rectangle by its top-left corner.
#let _slab(x, y, w, h, fill) = place(
  top + left,
  dx: x,
  dy: y,
  rect(width: w, height: h, fill: fill, stroke: none),
)

/// Place a filled circle by its centre.
#let _blob(cx, cy, r, fill) = place(
  top + left,
  dx: cx - r,
  dy: cy - r,
  circle(radius: r, fill: fill, stroke: none),
)

#let _stroke(sp, weight, paint) = (
  paint: paint,
  thickness: weight * sp,
  cap: "round",
  join: "round",
)

// ---------------------------------------------------------------------------
// Rests
// ---------------------------------------------------------------------------

/// Whole and half rest: one block, told apart only by which side of a staff
/// line it lies on.
///
/// The glyph is the block alone; the caller places it against a real line, and
/// which side it goes is the whole of the difference between the two. Nothing
/// else distinguishes them, in this package or in four centuries of engraving.
#let block-rest(sp, fill: black) = _glyph(
  1.15 * sp,
  0.45 * sp,
  _slab(0pt, 0pt, 1.15 * sp, 0.45 * sp, fill),
)

// The rests shorter than a half, traced from the reference drawing the user
// supplied. They are outlines rather than strokes: an engraved rest has a
// thick-to-thin contrast along its length that a constant-weight stroke cannot
// express, and drawn as strokes they read as spindly beside the fret numbers
// even at the right height.
//
// Each is `(w, h, d)` in staff spaces, `d` being a move followed by cubics.
// Generated from the source outlines, so it is data rather than code — the
// shape is the reference's, not a redrawing of it.

#let _REST-OUTLINES = (
  "quarter": (
    w: 0.585, h: 1.56,
    d: (
      (0.168, 0.857),
      (0.168, 0.857, 0.061, 0.732, 0.061, 0.732),
      (0.061, 0.732, 0.039, 0.682, 0.039, 0.682),
      (0.039, 0.661, 0.049, 0.641, 0.07, 0.621),
      (0.157, 0.534, 0.2, 0.446, 0.2, 0.357),
      (0.2, 0.312, 0.19, 0.269, 0.17, 0.227),
      (0.17, 0.227, 0.103, 0.122, 0.103, 0.122),
      (0.079, 0.094, 0.067, 0.079, 0.067, 0.077),
      (0.067, 0.077, 0.059, 0.044, 0.059, 0.044),
      (0.059, 0.015, 0.073, 0, 0.102, 0),
      (0.117, 0, 0.13, 0.006, 0.141, 0.017),
      (0.141, 0.017, 0.5, 0.419, 0.5, 0.419),
      (0.506, 0.432, 0.509, 0.445, 0.509, 0.459),
      (0.509, 0.47, 0.506, 0.48, 0.5, 0.49),
      (0.497, 0.494, 0.488, 0.509, 0.472, 0.533),
      (0.456, 0.557, 0.445, 0.574, 0.439, 0.583),
      (0.434, 0.592, 0.424, 0.607, 0.411, 0.629),
      (0.411, 0.629, 0.384, 0.683, 0.384, 0.683),
      (0.379, 0.698, 0.373, 0.715, 0.368, 0.736),
      (0.368, 0.736, 0.357, 0.797, 0.357, 0.797),
      (0.357, 0.8, 0.356, 0.804, 0.356, 0.81),
      (0.355, 0.816, 0.355, 0.821, 0.355, 0.824),
      (0.355, 0.86, 0.363, 0.896, 0.378, 0.932),
      (0.394, 0.968, 0.41, 0.997, 0.426, 1.019),
      (0.442, 1.04, 0.468, 1.072, 0.505, 1.114),
      (0.558, 1.169, 0.585, 1.209, 0.585, 1.233),
      (0.585, 1.238, 0.581, 1.241, 0.574, 1.241),
      (0.574, 1.241, 0.559, 1.239, 0.559, 1.239),
      (0.559, 1.239, 0.557, 1.237, 0.557, 1.237),
      (0.557, 1.237, 0.552, 1.237, 0.552, 1.237),
      (0.487, 1.213, 0.431, 1.201, 0.383, 1.201),
      (0.367, 1.201, 0.355, 1.202, 0.348, 1.203),
      (0.348, 1.203, 0.272, 1.256, 0.272, 1.256),
      (0.272, 1.256, 0.246, 1.353, 0.246, 1.353),
      (0.246, 1.374, 0.249, 1.392, 0.254, 1.408),
      (0.257, 1.422, 0.264, 1.438, 0.275, 1.456),
      (0.286, 1.474, 0.298, 1.483, 0.311, 1.483),
      (0.334, 1.502, 0.346, 1.519, 0.346, 1.533),
      (0.346, 1.533, 0.341, 1.548, 0.341, 1.548),
      (0.339, 1.556, 0.328, 1.56, 0.309, 1.56),
      (0.309, 1.56, 0.252, 1.541, 0.252, 1.541),
      (0.084, 1.418, 0, 1.31, 0, 1.218),
      (0, 1.164, 0.018, 1.117, 0.053, 1.077),
      (0.089, 1.037, 0.13, 1.018, 0.178, 1.018),
      (0.183, 1.018, 0.188, 1.019, 0.196, 1.021),
      (0.196, 1.021, 0.213, 1.024, 0.213, 1.024),
      (0.231, 1.028, 0.242, 1.03, 0.248, 1.03),
      (0.261, 1.03, 0.269, 1.027, 0.272, 1.02),
      (0.273, 1.018, 0.274, 1.016, 0.274, 1.011),
      (0.274, 1.009, 0.27, 0.999, 0.261, 0.982),
      (0.261, 0.982, 0.168, 0.857, 0.168, 0.857),
    ),
  ),
  "eighth": (
    w: 0.682, h: 1.17,
    d: (
      (0.37, 0.184),
      (0.37, 0.184, 0.37, 0.212, 0.37, 0.212),
      (0.391, 0.212, 0.415, 0.203, 0.445, 0.184),
      (0.474, 0.166, 0.5, 0.147, 0.521, 0.128),
      (0.542, 0.109, 0.564, 0.088, 0.586, 0.066),
      (0.586, 0.066, 0.619, 0.03, 0.619, 0.03),
      (0.619, 0.03, 0.649, 0.019, 0.649, 0.019),
      (0.671, 0.03, 0.682, 0.045, 0.682, 0.063),
      (0.682, 0.067, 0.679, 0.081, 0.671, 0.106),
      (0.671, 0.106, 0.655, 0.171, 0.655, 0.171),
      (0.474, 0.815, 0.381, 1.139, 0.376, 1.143),
      (0.354, 1.161, 0.321, 1.17, 0.279, 1.17),
      (0.226, 1.17, 0.199, 1.158, 0.199, 1.134),
      (0.214, 1.083, 0.242, 0.995, 0.283, 0.871),
      (0.325, 0.747, 0.363, 0.635, 0.399, 0.533),
      (0.435, 0.431, 0.454, 0.374, 0.456, 0.363),
      (0.458, 0.356, 0.459, 0.346, 0.459, 0.333),
      (0.459, 0.317, 0.454, 0.308, 0.445, 0.308),
      (0.445, 0.308, 0.431, 0.311, 0.431, 0.311),
      (0.431, 0.311, 0.332, 0.352, 0.332, 0.352),
      (0.332, 0.352, 0.224, 0.372, 0.224, 0.372),
      (0.205, 0.372, 0.181, 0.368, 0.152, 0.361),
      (0.13, 0.357, 0.104, 0.345, 0.075, 0.325),
      (0.025, 0.285, 0, 0.238, 0, 0.184),
      (0, 0.133, 0.018, 0.09, 0.054, 0.054),
      (0.054, 0.054, 0.185, 0, 0.185, 0),
      (0.237, 0, 0.281, 0.018, 0.316, 0.054),
      (0.352, 0.09, 0.37, 0.133, 0.37, 0.184),
    ),
  ),
  "sixteenth": (
    w: 0.879, h: 1.562,
    d: (
      (0.568, 0.15),
      (0.568, 0.15, 0.568, 0.173, 0.568, 0.173),
      (0.591, 0.172, 0.617, 0.164, 0.646, 0.147),
      (0.676, 0.131, 0.701, 0.114, 0.722, 0.096),
      (0.743, 0.079, 0.765, 0.06, 0.786, 0.039),
      (0.786, 0.039, 0.819, 0.01, 0.819, 0.01),
      (0.819, 0.01, 0.85, 0, 0.85, 0),
      (0.869, 0.007, 0.879, 0.015, 0.879, 0.024),
      (0.879, 0.024, 0.879, 0.026, 0.879, 0.026),
      (0.877, 0.029, 0.876, 0.032, 0.876, 0.033),
      (0.876, 0.033, 0.808, 0.267, 0.808, 0.267),
      (0.808, 0.267, 0.693, 0.62, 0.693, 0.62),
      (0.693, 0.62, 0.395, 1.503, 0.395, 1.503),
      (0.381, 1.539, 0.346, 1.558, 0.29, 1.56),
      (0.231, 1.562, 0.202, 1.549, 0.201, 1.522),
      (0.201, 1.522, 0.201, 1.52, 0.201, 1.52),
      (0.203, 1.518, 0.204, 1.516, 0.204, 1.515),
      (0.204, 1.515, 0.45, 0.858, 0.45, 0.858),
      (0.45, 0.858, 0.45, 0.855, 0.45, 0.855),
      (0.452, 0.854, 0.452, 0.852, 0.452, 0.851),
      (0.452, 0.843, 0.448, 0.839, 0.441, 0.84),
      (0.441, 0.84, 0.349, 0.875, 0.349, 0.875),
      (0.349, 0.875, 0.231, 0.896, 0.231, 0.896),
      (0.231, 0.896, 0.161, 0.891, 0.161, 0.891),
      (0.161, 0.891, 0.084, 0.862, 0.084, 0.862),
      (0.03, 0.832, 0.003, 0.794, 0.001, 0.749),
      (0, 0.704, 0.018, 0.667, 0.054, 0.636),
      (0.091, 0.604, 0.135, 0.588, 0.188, 0.586),
      (0.24, 0.584, 0.286, 0.597, 0.324, 0.627),
      (0.363, 0.656, 0.382, 0.691, 0.384, 0.734),
      (0.384, 0.734, 0.382, 0.757, 0.382, 0.757),
      (0.404, 0.756, 0.43, 0.749, 0.458, 0.734),
      (0.487, 0.719, 0.507, 0.701, 0.517, 0.681),
      (0.528, 0.662, 0.554, 0.598, 0.594, 0.487),
      (0.635, 0.376, 0.656, 0.313, 0.66, 0.298),
      (0.66, 0.298, 0.667, 0.263, 0.667, 0.263),
      (0.667, 0.253, 0.662, 0.247, 0.652, 0.248),
      (0.652, 0.248, 0.633, 0.253, 0.633, 0.253),
      (0.598, 0.27, 0.564, 0.282, 0.533, 0.291),
      (0.533, 0.291, 0.415, 0.312, 0.415, 0.312),
      (0.415, 0.312, 0.347, 0.307, 0.347, 0.307),
      (0.347, 0.307, 0.268, 0.278, 0.268, 0.278),
      (0.214, 0.248, 0.187, 0.21, 0.185, 0.165),
      (0.184, 0.122, 0.201, 0.085, 0.238, 0.053),
      (0.274, 0.021, 0.319, 0.004, 0.371, 0.002),
      (0.424, 0, 0.469, 0.013, 0.508, 0.041),
      (0.546, 0.07, 0.566, 0.106, 0.568, 0.15),
    ),
  ),
  "thirty-second": (
    w: 0.879, h: 1.755,
    d: (
      (0.852, 0.025),
      (0.87, 0.026, 0.879, 0.035, 0.878, 0.053),
      (0.878, 0.053, 0.875, 0.057, 0.875, 0.057),
      (0.875, 0.057, 0.875, 0.062, 0.875, 0.062),
      (0.875, 0.062, 0.803, 0.309, 0.803, 0.309),
      (0.576, 1.22, 0.46, 1.686, 0.454, 1.705),
      (0.454, 1.705, 0.441, 1.731, 0.441, 1.731),
      (0.437, 1.736, 0.428, 1.742, 0.413, 1.747),
      (0.398, 1.753, 0.377, 1.755, 0.351, 1.755),
      (0.3, 1.754, 0.275, 1.74, 0.275, 1.714),
      (0.281, 1.695, 0.303, 1.629, 0.342, 1.514),
      (0.407, 1.29, 0.439, 1.176, 0.439, 1.171),
      (0.439, 1.161, 0.434, 1.156, 0.423, 1.156),
      (0.42, 1.156, 0.417, 1.157, 0.416, 1.158),
      (0.416, 1.158, 0.32, 1.194, 0.32, 1.194),
      (0.283, 1.204, 0.246, 1.209, 0.209, 1.209),
      (0.209, 1.209, 0.146, 1.2, 0.146, 1.2),
      (0.146, 1.2, 0.072, 1.165, 0.072, 1.165),
      (0.024, 1.13, 0, 1.087, 0.001, 1.038),
      (0.002, 0.993, 0.02, 0.954, 0.055, 0.922),
      (0.055, 0.922, 0.183, 0.875, 0.183, 0.875),
      (0.232, 0.876, 0.274, 0.893, 0.309, 0.925),
      (0.343, 0.958, 0.36, 0.997, 0.359, 1.045),
      (0.359, 1.045, 0.356, 1.069, 0.356, 1.069),
      (0.381, 1.068, 0.408, 1.06, 0.439, 1.044),
      (0.469, 1.028, 0.487, 1.009, 0.492, 0.986),
      (0.492, 0.986, 0.565, 0.747, 0.565, 0.747),
      (0.565, 0.726, 0.559, 0.715, 0.547, 0.715),
      (0.544, 0.715, 0.541, 0.715, 0.539, 0.717),
      (0.539, 0.717, 0.446, 0.752, 0.446, 0.752),
      (0.446, 0.752, 0.34, 0.767, 0.34, 0.767),
      (0.34, 0.767, 0.269, 0.756, 0.269, 0.756),
      (0.24, 0.748, 0.216, 0.736, 0.199, 0.721),
      (0.15, 0.686, 0.126, 0.644, 0.127, 0.597),
      (0.128, 0.551, 0.146, 0.512, 0.18, 0.48),
      (0.215, 0.448, 0.258, 0.433, 0.309, 0.433),
      (0.359, 0.434, 0.4, 0.451, 0.435, 0.485),
      (0.47, 0.518, 0.487, 0.558, 0.486, 0.603),
      (0.486, 0.603, 0.483, 0.625, 0.483, 0.625),
      (0.504, 0.626, 0.531, 0.616, 0.565, 0.597),
      (0.599, 0.578, 0.619, 0.559, 0.627, 0.54),
      (0.627, 0.54, 0.673, 0.331, 0.673, 0.331),
      (0.673, 0.329, 0.673, 0.328, 0.674, 0.326),
      (0.674, 0.326, 0.676, 0.321, 0.676, 0.321),
      (0.676, 0.295, 0.667, 0.282, 0.647, 0.281),
      (0.642, 0.281, 0.639, 0.282, 0.637, 0.284),
      (0.637, 0.284, 0.544, 0.319, 0.544, 0.319),
      (0.507, 0.33, 0.471, 0.335, 0.435, 0.334),
      (0.435, 0.334, 0.367, 0.323, 0.367, 0.323),
      (0.336, 0.314, 0.311, 0.302, 0.294, 0.287),
      (0.245, 0.252, 0.221, 0.211, 0.222, 0.164),
      (0.223, 0.118, 0.241, 0.079, 0.277, 0.047),
      (0.277, 0.047, 0.404, 0, 0.404, 0),
      (0.455, 0.001, 0.498, 0.018, 0.531, 0.051),
      (0.565, 0.085, 0.581, 0.124, 0.581, 0.17),
      (0.581, 0.17, 0.58, 0.192, 0.58, 0.192),
      (0.601, 0.192, 0.626, 0.185, 0.655, 0.169),
      (0.683, 0.153, 0.708, 0.136, 0.729, 0.119),
      (0.751, 0.101, 0.771, 0.083, 0.791, 0.065),
      (0.791, 0.065, 0.823, 0.034, 0.823, 0.034),
      (0.823, 0.034, 0.852, 0.025, 0.852, 0.025),
    ),
  ),
)

// A shade larger than the traced size. The tracing puts an eighth rest at 1.17
// staff spaces, which is what the published sheet in `research/TNT_0001.png`
// measures, but at that size it sits a little quiet beside the fret numbers on
// the page. A fifth more carries better without crowding the staff.
#let REST-GROWTH = 1.2

// How many horizontal slices a rest's ink is measured in, and how finely each
// cubic is sampled to fill them. Both are as coarse as they can be without the
// profile disagreeing with the drawn shape at the width of a string line.
#let _INK-SLICES = 48
#let _INK-SAMPLES = 16

/// Where a traced outline's ink actually lies, slice by slice.
///
/// The bounding box is a poor description of that: a quarter rest is a narrow
/// zigzag, so a string line grazing its corner would be broken as widely as one
/// running through its middle, and a fret number — measured type, with no such
/// gap between box and ink — would get a tighter gap than the rest beside it.
///
/// Returns one `(left, right)` pair per slice, in the glyph's own coordinates,
/// top to bottom. `unit` is the scale the outline is drawn at.
#let _ink-profile(d, unit, height) = {
  let slices = range(_INK-SLICES).map(_ => none)
  let (px, py) = d.first()

  for seg in d.slice(1) {
    let (c1x, c1y, c2x, c2y, ex, ey) = seg
    for k in range(_INK-SAMPLES + 1) {
      let t = k / _INK-SAMPLES
      let u = 1 - t
      // The cubic at t. Sampling the boundary is enough: a filled shape spans
      // from its leftmost boundary point at a height to its rightmost.
      let x = u * u * u * px + 3 * u * u * t * c1x + 3 * u * t * t * c2x + t * t * t * ex
      let y = u * u * u * py + 3 * u * u * t * c1y + 3 * u * t * t * c2y + t * t * t * ey
      let i = calc.clamp(int(y * unit / height * _INK-SLICES), 0, _INK-SLICES - 1)
      let cur = slices.at(i)
      slices.at(i) = if cur == none {
        (x, x)
      } else {
        (calc.min(cur.at(0), x), calc.max(cur.at(1), x))
      }
    }
    px = ex
    py = ey
  }

  // A slice the sampling stepped over inherits from its nearest filled
  // neighbours on either side, so no string line can find a hole where the
  // drawn shape has ink.
  let filled = ()
  for i in range(_INK-SLICES) {
    let here = slices.at(i)
    if here == none {
      let before = slices.slice(0, i).rev().find(s => s != none)
      let after = slices.slice(i + 1).find(s => s != none)
      let both = (before, after).filter(s => s != none)
      here = if both.len() == 0 {
        (0.0, 0.0)
      } else {
        (
          both.map(s => s.at(0)).fold(both.first().at(0), calc.min),
          both.map(s => s.at(1)).fold(both.first().at(1), calc.max),
        )
      }
    }
    filled.push((here.at(0) * unit, here.at(1) * unit))
  }
  filled
}

/// Draw one of the traced outlines at the given staff space.
#let _outline-rest(sp, name, fill) = {
  let shape = _REST-OUTLINES.at(name)
  let k = sp * REST-GROWTH
  let pt(x, y) = (x * k, y * k)
  _glyph(
    shape.w * k,
    shape.h * k,
    _draw(curve(
      fill: fill,
      stroke: none,
      curve.move(pt(..shape.d.first())),
      ..shape.d.slice(1).map(c => curve.cubic(pt(c.at(0), c.at(1)), pt(c.at(2), c.at(3)), pt(c.at(4), c.at(5)))),
      curve.close(mode: "straight"),
    )),
  ) + (ink: _ink-profile(shape.d, k, shape.h * k))
}

/// The horizontal extent of a glyph's ink between two heights.
///
/// `y0` and `y1` are measured from the glyph's own top. Returns `none` when the
/// band holds no ink, and the full box for a glyph carrying no profile — which
/// is the right answer for a solid one.
///
/// ```typc
/// let rest = quarter-rest(10pt)
/// let all = ink-span(rest, 0pt, rest.height)
/// let top = ink-span(rest, 0pt, rest.height / 8)
/// // The zigzag's top is narrower than the glyph as a whole.
/// assert(top.end - top.start < all.end - all.start)
/// assert(ink-span(rest, rest.height * 2, rest.height * 3) == none)
/// ```
#let ink-span(glyph, y0, y1) = {
  let profile = glyph.at("ink", default: none)
  if profile == none { return (start: 0pt, end: glyph.width) }
  let slice = glyph.height / profile.len()
  let lo = none
  let hi = none
  for (i, s) in profile.enumerate() {
    if i * slice > y1 or (i + 1) * slice < y0 { continue }
    lo = if lo == none { s.at(0) } else { calc.min(lo, s.at(0)) }
    hi = if hi == none { s.at(1) } else { calc.max(hi, s.at(1)) }
  }
  if lo == none { return none }
  (start: lo, end: hi)
}

/// Quarter rest.
#let quarter-rest(sp, fill: black) = _outline-rest(sp, "quarter", fill)

/// A rest carrying `n` hooks: an eighth for `n = 1`, a sixteenth for 2, a
/// thirty-second for 3.
#let flagged-rest(sp, n, fill: black) = {
  let name = ("eighth", "sixteenth", "thirty-second").at(calc.clamp(n, 1, 3) - 1)
  _outline-rest(sp, name, fill)
}

#let eighth-rest(sp, fill: black) = flagged-rest(sp, 1, fill: fill)
#let sixteenth-rest(sp, fill: black) = flagged-rest(sp, 2, fill: fill)

/// The rest for a given number of flags: 0 is a quarter, -1 a half, -2 a whole.
///
/// Whole and half both give the bare block; the caller decides which side of a
/// line it sits on.
#let rest-for(sp, flags, fill: black) = {
  if flags < 0 {
    block-rest(sp, fill: fill)
  } else if flags == 0 {
    quarter-rest(sp, fill: fill)
  } else {
    flagged-rest(sp, flags, fill: fill)
  }
}

// ---------------------------------------------------------------------------
// Flags
// ---------------------------------------------------------------------------

/// A single stem flag, drawn for a stem that points up.
///
/// The origin is the tip of the stem and the flag falls away to the right. Pass
/// `down: true` to mirror it for a downward stem.
///
/// The rhythm lane does not use this: it draws beam stubs, ornaments included.
/// What is left is the note value in a tempo mark, where the glyph stands on
/// its own rather than beside other values.
#let flag(sp, down: false, fill: black) = {
  let w = 1.0 * sp
  let h = 1.75 * sp
  let shape = curve(
    fill: fill,
    stroke: none,
    // Outer edge: away from the stem, then a long sweep down to the tip.
    curve.move((0pt, 0pt)),
    curve.cubic((0.78 * sp, 0.38 * sp), (0.96 * sp, 1.00 * sp), (0.30 * sp, h)),
    // Inner edge back to the stem, hollowed out so the flag tapers.
    curve.cubic((0.52 * sp, 1.05 * sp), (0.38 * sp, 0.58 * sp), (0pt, 0.48 * sp)),
    curve.close(mode: "straight"),
  )
  _glyph(w, h, _draw(if down { scale(y: -100%, origin: center + horizon, shape) } else { shape }))
}

// ---------------------------------------------------------------------------
// Dots and repeat signs
// ---------------------------------------------------------------------------

/// Augmentation dot.
#let aug-dot(sp, fill: black) = _glyph(
  0.30 * sp,
  0.30 * sp,
  _blob(0.15 * sp, 0.15 * sp, 0.15 * sp, fill),
)

/// The augmentation mark the rhythm lane uses: a square, `size` on a side.
///
/// A round dot belongs beside a notehead, and the lane has none — it draws its
/// values as bars. The reference sets a square beside the stem instead, and
/// square is also what tells it apart from the staccato dots and the repeat
/// dots drawn elsewhere on the page.
///
/// It takes a size rather than a staff space because the size is not a free
/// choice: measured off the reference outlines the square is exactly a beam
/// thick, so it is drawn from `theme.beam-thickness` and follows it.
#let aug-square(size, fill: black) = _glyph(size, size, _slab(0pt, 0pt, size, size, fill))

/// The pair of dots on a repeat barline, centred within `height`.
#let repeat-dots(sp, height, fill: black) = {
  let r = 0.14 * sp
  _glyph(2 * r, height, {
    _blob(r, height / 2 - 0.55 * sp, r, fill)
    _blob(r, height / 2 + 0.55 * sp, r, fill)
  })
}

// ---------------------------------------------------------------------------
// Articulations
// ---------------------------------------------------------------------------

#let accent(sp, fill: black) = _glyph(
  0.85 * sp,
  0.62 * sp,
  _draw(curve(
    stroke: _stroke(sp, 0.13, fill),
    curve.move((0.04 * sp, 0.04 * sp)),
    curve.line((0.81 * sp, 0.31 * sp)),
    curve.line((0.04 * sp, 0.58 * sp)),
  )),
)

#let marcato(sp, fill: black) = _glyph(
  0.70 * sp,
  0.62 * sp,
  _draw(curve(
    stroke: _stroke(sp, 0.14, fill),
    curve.move((0.06 * sp, 0.58 * sp)),
    curve.line((0.35 * sp, 0.05 * sp)),
    curve.line((0.64 * sp, 0.58 * sp)),
  )),
)

#let staccato(sp, fill: black) = _glyph(
  0.26 * sp,
  0.26 * sp,
  _blob(0.13 * sp, 0.13 * sp, 0.13 * sp, fill),
)

#let tenuto(sp, fill: black) = _glyph(
  0.70 * sp,
  0.14 * sp,
  _draw(curve(
    stroke: _stroke(sp, 0.11, fill),
    curve.move((0.04 * sp, 0.07 * sp)),
    curve.line((0.66 * sp, 0.07 * sp)),
  )),
)

/// Fermata: a shallow arc with a dot beneath its apex — "hold this".
///
/// The arc is drawn as a stroke of even weight rather than as a tapered lens,
/// unlike a slur. A fermata is a sign, not a line joining two notes, and at
/// this size a taper reads as a printing fault.
#let fermata(sp, fill: black) = {
  let w = 1.30 * sp
  let h = 0.72 * sp
  _glyph(w, h, {
    _draw(curve(
      stroke: _stroke(sp, 0.11, fill),
      curve.move((0.04 * sp, h)),
      curve.cubic((0.10 * sp, 0.02 * sp), (w - 0.10 * sp, 0.02 * sp), (w - 0.04 * sp, h)),
    ))
    _blob(w / 2, h - 0.15 * sp, 0.11 * sp, fill)
  })
}

/// Downstroke: the square bracket of a down pick.
#let downstroke(sp, fill: black) = _glyph(
  0.55 * sp,
  0.65 * sp,
  _draw(curve(
    stroke: _stroke(sp, 0.13, fill),
    curve.move((0.07 * sp, 0.61 * sp)),
    curve.line((0.07 * sp, 0.06 * sp)),
    curve.line((0.48 * sp, 0.06 * sp)),
    curve.line((0.48 * sp, 0.61 * sp)),
  )),
)

/// Upstroke: the V of an up pick.
#let upstroke(sp, fill: black) = _glyph(
  0.55 * sp,
  0.65 * sp,
  _draw(curve(
    stroke: _stroke(sp, 0.13, fill),
    curve.move((0.07 * sp, 0.06 * sp)),
    curve.line((0.28 * sp, 0.59 * sp)),
    curve.line((0.49 * sp, 0.06 * sp)),
  )),
)

/// The diamond marking a harmonic.
#let harmonic-diamond(sp, fill: black) = _glyph(
  0.66 * sp,
  0.66 * sp,
  _draw(curve(
    stroke: _stroke(sp, 0.10, fill),
    curve.move((0.33 * sp, 0.05 * sp)),
    curve.line((0.61 * sp, 0.33 * sp)),
    curve.line((0.33 * sp, 0.61 * sp)),
    curve.line((0.05 * sp, 0.33 * sp)),
    curve.close(mode: "straight"),
  )),
)

/// A wavy line, used for vibrato, trills, pick scrapes and arpeggios.
///
/// `vertical: true` runs it down the staff instead of along it, which is the
/// form an arpeggio or a rake takes beside a chord.
#let wavy(sp, length, amp: 0.18, vertical: false, fill: black) = {
  let step = 0.42 * sp
  let n = calc.max(2, int(length / step))
  let a = amp * sp
  let along(t) = if vertical { (a, t) } else { (t, a) }
  let across(t, d) = if vertical { (a + d, t) } else { (t, a + d) }

  let parts = (curve.move(along(0pt)),)
  for i in range(n) {
    let t = i * step
    parts.push(curve.cubic(
      across(t + step * 0.3, -a),
      across(t + step * 0.7, a),
      along(t + step),
    ))
  }
  let thickness = 0.09 * sp
  _glyph(
    if vertical { 2 * a + thickness } else { n * step },
    if vertical { n * step } else { 2 * a + thickness },
    _draw(curve(stroke: (paint: fill, thickness: thickness, cap: "round"), ..parts)),
  )
}

// ---------------------------------------------------------------------------
// Note values used outside the staff
// ---------------------------------------------------------------------------

/// A note value for a tempo mark, e.g. the quarter in "Moderately ♩ = 116".
///
/// `flags` counts the flags: 0 is a quarter, 1 an eighth. Drawn rather than set
/// as U+2669 because most sans faces have no coverage for it, and those that do
/// draw it at a weight unrelated to the surrounding text.
#let tempo-note(sp, flags: 0, hollow: false, fill: black) = {
  let head-w = 0.92 * sp
  let head-h = 0.64 * sp
  let h = 2.7 * sp
  let stem-x = head-w - 0.10 * sp
  _glyph(
    if flags > 0 { stem-x + 0.09 * sp + 1.0 * sp } else { head-w },
    h,
    {
      place(
        top + left,
        dx: 0pt,
        dy: h - head-h,
        rotate(
          -20deg,
          ellipse(
            width: head-w,
            height: head-h,
            fill: if hollow { none } else { fill },
            stroke: if hollow { 0.10 * sp + fill } else { none },
          ),
        ),
      )
      place(
        top + left,
        dx: stem-x,
        dy: 0.12 * sp,
        rect(width: 0.09 * sp, height: h - head-h - 0.02 * sp, fill: fill, stroke: none),
      )
      if flags > 0 {
        place(top + left, dx: stem-x + 0.09 * sp, dy: 0.12 * sp, flag(sp, fill: fill).body)
      }
    },
  )
}

// ---------------------------------------------------------------------------
// Navigation marks
// ---------------------------------------------------------------------------

/// Coda: a circle crossed by a vertical and a horizontal bar.
#let coda(sp, fill: black) = {
  let d = 1.5 * sp
  let pad = 0.28 * sp
  let total = d + 2 * pad
  _glyph(total, total, {
    place(top + left, dx: pad, dy: pad, circle(radius: d / 2, fill: none, stroke: 0.11 * sp + fill))
    _draw(curve(
      stroke: _stroke(sp, 0.11, fill),
      curve.move((total / 2, 0.02 * sp)),
      curve.line((total / 2, total - 0.02 * sp)),
    ))
    _draw(curve(
      stroke: _stroke(sp, 0.11, fill),
      curve.move((0.02 * sp, total / 2)),
      curve.line((total - 0.02 * sp, total / 2)),
    ))
  })
}

/// Segno: an S crossed by a slash, with a dot in each of the two open corners.
#let segno(sp, fill: black) = {
  let w = 1.45 * sp
  let h = 1.6 * sp
  _glyph(w, h, {
    _draw(curve(
      stroke: _stroke(sp, 0.15, fill),
      curve.move((1.02 * sp, 0.32 * sp)),
      curve.cubic((0.70 * sp, 0.08 * sp), (0.34 * sp, 0.34 * sp), (0.62 * sp, 0.62 * sp)),
      curve.cubic((0.94 * sp, 0.92 * sp), (0.62 * sp, 1.30 * sp), (0.30 * sp, 1.18 * sp)),
    ))
    _draw(curve(
      stroke: _stroke(sp, 0.09, fill),
      curve.move((1.06 * sp, 0.24 * sp)),
      curve.line((0.28 * sp, 1.32 * sp)),
    ))
    _blob(1.10 * sp, 0.98 * sp, 0.10 * sp, fill)
    _blob(0.28 * sp, 0.56 * sp, 0.10 * sp, fill)
  })
}
