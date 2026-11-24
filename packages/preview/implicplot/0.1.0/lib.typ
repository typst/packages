// Implicit relation plotting for Typst, backed by the Zig plugin.
//
// A relation is one string, written the way it is written on paper:
//
//   #import "lib.typ" as ip
//   #let pixels = ip.plot("sin(x^2 + y^2) = cos(x*y)",
//     size: (64, 64), x: (-6, 6), y: (-6, 6))
//   #let chains = ip.contour("sin(x^2 + y^2) = cos(x*y)", n: 60)
//
// Both entry points take that same string, and the comparison lives inside it,
// so `"f(x, y) > 1"` and `"f(x, y) - 1 > 0"` are two spellings of one relation
// rather than two ways of calling this module.
//
// The plugin parses the text itself, so this module encodes nothing but the
// view: no opcode table, no operator numbers, and nothing here that has to be
// kept in step with the Zig enums.
//
// Doc comments follow the conventions of the `tidy` package; the API reference
// in manual.typ is generated from them.

#let _plugin = plugin("./implicit_plot.wasm")

// -- the options header -------------------------------------------------------

// IEEE-754 binary64, little-endian, as eight integers.
//
// Note `cbor.encode` is *not* an alternative here: it emits the shortest
// lossless form, so a float comes back as two, four or eight bytes depending on
// its value.
#let _f64-bytes(value) = {
  let v = float(value)
  // False for NaN as well as for the infinities, so one test covers both.
  assert(calc.abs(v) < 1.7976931348623157e308, message: "a bound must be finite, got " + repr(v))
  array(float.to-bytes(v, endian: "little"))
}

#let _int-bytes(v, size) = array(int.to-bytes(int(v), endian: "little", size: size))

// The 42-byte options header. Both plugin calls take the same one, so it is
// built in one place rather than once per entry point. The final byte is
// `contour`'s uncertain-cell policy; `plot` ignores it.
//
// This mirrors `Options.parse` in src/wire.zig, which owns the layout and
// pins it with golden-byte tests; any change starts there.
#let _options(width, height, x, y, depth, join) = {
  assert(width > 0 and height > 0, message: "the grid must be at least 1 by 1")
  assert(x.at(0) < x.at(1), message: "the x range must be increasing")
  assert(y.at(0) < y.at(1), message: "the y range must be increasing")
  assert(
    type(depth) == int and depth >= 0 and depth <= 255,
    message: "the refinement depth must be an integer in 0..255, got " + repr(depth),
  )
  let out = _int-bytes(width, 4)
  out += _int-bytes(height, 4)
  out += _f64-bytes(x.at(0))
  out += _f64-bytes(x.at(1))
  out += _f64-bytes(y.at(0))
  out += _f64-bytes(y.at(1))
  out.push(depth)
  out.push(join)
  bytes(out)
}

// The plugin reports a bad relation itself, with a caret under the offending
// character, so the only thing worth checking here is that it was handed text
// at all - which is also what tells anyone still building expressions out of
// `ip.sub(ip.sin(...))` what became of that API.
#let _source(relation) = {
  assert(
    type(relation) == str,
    message: "the relation is written as a string, e.g. \"x^2 + y^2 = 1\", got " + repr(relation),
  )
  bytes(relation)
}

// -- plotting -----------------------------------------------------------------

/// Plot the region satisfying a relation and return one byte per pixel,
/// row-major from the top - not an image; the document decides what to draw.
///
/// The plotter subdivides adaptively with interval arithmetic, so a lit pixel
/// means the relation provably or plausibly holds there and an unlit pixel
/// means it provably does not: coverage errs outward, never inward.
///
/// ```example
/// #raw(rows(plot("x < 0", size: (6, 6), x: (-1, 1), y: (-1, 1)), 6)
///   .map(row => row.map(str).join(" ")).join("\n"))
/// ```
/// -> bytes
#let plot(
  /// The relation, written as text: `"sin(x^2 + y^2) = cos(x*y)"`.
  ///
  /// The language is $x$, $y$, the constants `pi`, `tau` and `e`, decimal
  /// numbers (`1.5e3` included), `+ - * / %`, parentheses, `^` with an
  /// integer literal exponent, the functions `neg abs sin cos tan exp sqrt
  /// log asin acos atan floor ceil` --- with `ln`, `arcsin`, `arccos` and
  /// `arctan` as alternative spellings --- and `min(a, b)` and `max(a, b)`.
  /// `%` is floored modulo, taking the sign of its divisor as Python's does.
  /// The comparison is one of `= < <= > >=`, written between the two sides;
  /// `==` is accepted for `=`. Whitespace is insignificant, but
  /// multiplication is never implicit: `2x` is an error, and `x^y` is one
  /// too.
  ///
  /// `floor`, `ceil` and `%` are the only discontinuous operations. @contour
  /// refuses to trace across a step and counts those cells in `uncertain`;
  /// `plot` needs no continuity and handles them exactly.
  ///
  /// Everything is reduced to $f space.thin op space.thin 0$ before it is
  /// plotted, so `"f > 1"` and `"f - 1 > 0"` are the same relation and cost
  /// the same.
  ///
  /// Prefer `x^2` to `x*x`: the plotter encloses $[-1,1]^2$ as $[0,1]$, where
  /// a product of two intervals can only manage $[-1,1]$, so the power
  /// converges in fewer subdivisions.
  /// -> str
  relation,
  /// Width and height in pixels.
  /// -> array
  size: (64, 64),
  /// The horizontal extent of the plane to cover.
  /// -> array
  x: (-10, 10),
  /// The vertical extent of the plane to cover.
  /// -> array
  y: (-10, 10),
  /// How many times a single undecided pixel may be subdivided before giving
  /// up on proving it.
  /// -> int
  depth: 8,
) = _plugin.plot(
  _source(relation),
  _options(size.at(0), size.at(1), x, y, depth, 0),
)

/// Split a flat plot into rows, top first.
/// -> array
#let rows(
  /// The result of @plot (or any flat sequence).
  /// -> bytes | array
  pixels,
  /// The row width, i.e. the first element of the `size` the plot was made at.
  /// -> int
  width,
) = {
  let all = array(pixels)
  range(0, calc.div-euclid(all.len(), width)).map(r => all.slice(r * width, (r + 1) * width))
}

/// Trace the curve of a relation as polylines, by subdivision with a
/// guaranteed topology (Plantinga & Vegter, SGP 2004; Lin & Yap, DCG 2011).
///
/// Returns a dictionary `(chains, uncertain)`. Each chain is an array of
/// $(x, y)$ pairs in the relation's own coordinates; closed curves repeat
/// their first point, so a chain can be stroked without special-casing.
///
/// `uncertain` counts cells where the curve is singular - a self-intersection,
/// where the gradient vanishes and no subdivision can settle the topology.
/// Zero means the shape is guaranteed correct, not merely plausible.
///
/// @plot answers a different question - which pixels the curve may touch - and
/// tracing that raster is not a substitute: it follows the outline of the band
/// of lit pixels, giving staircase fragments where this gives one path.
///
/// ```example
/// #let c = contour("x^2 + y^2 = 1", n: 24, x: (-1.5, 1.5), y: (-1.5, 1.5))
/// The unit circle: #c.chains.len() chain of #c.chains.at(0).len() points,
/// #c.uncertain uncertain cells.
/// ```
/// -> dictionary
#let contour(
  /// The relation whose curve to trace, in the same language @plot takes.
  /// Only the two sides are read: the curve is where they are equal, so
  /// `"f <= 1"` traces the boundary `"f = 1"` and the comparison written is
  /// not consulted.
  /// -> str
  relation,
  /// How finely to resolve the curve. The tree is adaptive: this is the
  /// resolution the curve is resolved *to*, not a grid walked everywhere -
  /// empty regions cost one evaluation each.
  /// -> int
  n: 60,
  /// The horizontal extent of the plane to trace.
  /// -> array
  x: (-10, 10),
  /// The vertical extent of the plane to trace.
  /// -> array
  y: (-10, 10),
  /// How far below `n`'s resolution an unresolved cell may be split before it
  /// is given up as `uncertain`. Each level costs about four times the last,
  /// for shrinking returns: a genuine singularity never resolves however deep
  /// this goes, so raising it mainly tightens the region around singular
  /// points and resolves features finer than `n`.
  /// -> int
  refine: 2,
  /// What to draw inside the cells counted by `uncertain`. The curve has
  /// values there; what cannot be computed is how the arcs connect, so the
  /// choice is the caller's. `"avoid"` keeps the arcs apart - right when a
  /// "crossing" is a near miss. `"join"` contracts each cluster of uncertain
  /// cells to a single junction, giving a true X - right whenever the
  /// relation visibly factors, as `sin(x^2+y^2) = cos(x*y)` does into two
  /// ellipse families.
  /// -> str
  uncertain: "avoid",
) = {
  assert(type(n) == int, message: "n must be an integer")
  // 10 is `max_contour_refine` in src/wire.zig; the plugin clamps to it too.
  assert(type(refine) == int and refine >= 0 and refine <= 10, message: "refine must be 0..10")
  assert(uncertain in ("avoid", "join"), message: "uncertain must be \"avoid\" or \"join\"")

  let raw = _plugin.contour(
    _source(relation),
    _options(n, n, x, y, refine, if uncertain == "join" { 1 } else { 0 }),
  )
  let count = int.from-bytes(raw.slice(0, 4), endian: "little", signed: false)
  let uncertain = int.from-bytes(raw.slice(4, 8), endian: "little", signed: false)
  let lengths = range(count).map(k => int.from-bytes(
    raw.slice(8 + k * 4, 12 + k * 4),
    endian: "little",
    signed: false,
  ))

  let base = 8 + count * 4
  let point(k) = (
    float.from-bytes(raw.slice(base + k * 16, base + k * 16 + 8), endian: "little"),
    float.from-bytes(raw.slice(base + k * 16 + 8, base + k * 16 + 16), endian: "little"),
  )

  let chains = ()
  let at = 0
  for length in lengths {
    chains.push(range(at, at + length).map(point))
    at += length
  }
  (chains: chains, uncertain: uncertain)
}
