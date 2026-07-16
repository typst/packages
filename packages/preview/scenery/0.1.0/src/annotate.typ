// Publication furniture for scenes: an axes triad, a color-swatch legend and a
// scalar colorbar, emitted as cetz draw commands for composition inside a
// `cetz.canvas`. Generalised from the validated crystal-renderer triad
// and legend code (which drew a fixed a/b/c triad bottom-left and element
// swatch rows on the right); here the geometry is parameterised and the swatch
// look reuses the renderer's shaded-ball gradient.
//
// The crystal-renderer CeTZ gotcha is honoured throughout: every projection/direction is
// computed by a pure helper (`triad-dirs`, `legend-rows`, `colorbar-gradient`)
// BEFORE `import cetz.draw: *`, so the drawing block cannot be tripped by cetz
// re-exporting `project`/`scale`. Those pure helpers are also the test surface —
// directions, row counts and swatch validation are checkable without cetz.
//
// The `_sphere-gradient` reuse creates a one-way dependency annotate -> render.
// The reverse reference (render-scene taking `axes:`/`legend:`/`colorbar:`
// options) is a *deferred* import inside `render.typ`'s functions, so there is
// no load-time import cycle.

#import "@preview/cetz:0.5.2"
#import "camera.typ": project
#import "linalg.typ": vnorm
#import "render.typ": _sphere-gradient

// --- axes triad -------------------------------------------------------------

/// The projected, screen-space directions of `vectors` under `camera`.
///
/// Pure — no CeTZ. Each vector is normalised in 3D and then
/// projected; only the screen components `(sx, sy)` are kept, so the result is
/// an array of 2-vectors giving each axis's on-screen direction. For the 2D
/// identity camera `camera-2d()`, `x=(1,0,0)` maps to `(1, 0)` (screen right),
/// `y=(0,1,0)` to `(0, 1)` (screen up) and `z=(0,0,1)` to `(0, 0)`.
///
/// - camera (camera): The camera to project through.
/// - vectors (array): The 3D direction vectors (each a 2- or 3-vector).
/// -> array
#let triad-dirs(camera, vectors) = vectors.map(v => {
  let v3 = if v.len() == 2 { (v.at(0), v.at(1), 0) } else { v }
  let q = project(camera, vnorm(v3))
  (q.sx, q.sy)
})

/// A small labelled arrow triad showing the projected directions of `vectors`.
///
/// Follows the material-figure triad look: each vector's normalised projected direction
/// (see `triad-dirs`) is drawn as a fixed-length arrow from `origin` with an
/// italic name at the tip. Supports fewer than three axes (layer groups pass two
/// vectors + two names). Returns cetz draw commands for use inside a canvas.
///
/// - camera (camera): The camera to project through.
/// - vectors (array): Direction vectors (e.g. lattice vectors); n may be < 3.
/// - names (array): One label per vector; defaults to `("x", "y", "z")`.
/// - origin (array): Canvas-space arrow tail `(x, y)`.
/// - size (float): Arrow length in canvas units.
/// - label-at (float): Distance from origin at which the name is placed.
/// - text-size (length): Name font size.
/// - color (color): Arrow and label colour.
/// - stroke-width (length): Arrow stroke thickness.
/// -> content
#let axes-triad(
  camera,
  vectors,
  names: ("x", "y", "z"),
  origin: (0, 0),
  size: 0.7,
  label-at: 0.95,
  text-size: 8pt,
  color: black,
  stroke-width: 0.7pt,
) = {
  let n = vectors.len()
  assert(
    n <= names.len(),
    message: "axes-triad: need a name per vector; got " + str(n)
      + " vectors and " + str(names.len()) + " names",
  )
  let dirs = triad-dirs(camera, vectors)
  let (ox, oy) = origin
  import cetz.draw: *
  for i in range(n) {
    let (dx, dy) = dirs.at(i)
    line(
      (ox, oy),
      (ox + dx * size, oy + dy * size),
      mark: (end: ">", fill: color),
      stroke: (paint: color, thickness: stroke-width),
    )
    content(
      (ox + dx * label-at, oy + dy * label-at),
      text(size: text-size, style: "italic", fill: color, names.at(i)),
    )
  }
}

// --- legend -----------------------------------------------------------------

/// Whether `v` is a valid legend swatch value (i.e. a colour). The constructor
/// asserts on this; exposed so the negative control can test the predicate
/// (Typst cannot catch the panic itself).
///
/// - v (any): A candidate swatch value.
/// -> bool
#let is-color-swatch(v) = type(v) == color

/// The laid-out rows of a legend: one row per entry, top-to-bottom.
///
/// Pure — no cetz. Each entry must be a `(label, color)` pair; a non-colour
/// swatch raises a clear assert (see `is-color-swatch`). Row `i` sits at
/// `origin.y - i * row-height`, so the returned array has exactly one row per
/// entry (the count is the tested invariant).
///
/// - entries (array): `(label, color)` pairs.
/// - row-height (float): Vertical spacing between rows, canvas units.
/// - origin (array): Canvas-space anchor `(x, y)` of the first swatch.
/// -> array
#let legend-rows(entries, row-height: 0.55, origin: (0, 0)) = {
  for e in entries {
    assert(
      type(e) == array and e.len() == 2,
      message: "legend entry must be a (label, color) pair, got " + repr(e),
    )
    assert(
      is-color-swatch(e.at(1)),
      message: "legend swatch must be a color, got " + repr(e.at(1))
        + " of type " + repr(type(e.at(1))),
    )
  }
  entries
    .enumerate()
    .map(((i, e)) => (
      label: e.at(0),
      color: e.at(1),
      pos: (origin.at(0), origin.at(1) - i * row-height),
    ))
}

/// A legend: a shaded swatch and label per `(label, color)` entry, stacked top
/// to bottom. The swatch reuses the renderer's ball gradient (`ball: true`, the
/// material-figure look) or a flat fill (`ball: false`). Returns CeTZ draw commands.
///
/// - entries (array): `(label, color)` pairs.
/// - origin (array): Canvas-space anchor `(x, y)` of the first swatch.
/// - row-height (float): Vertical spacing between rows.
/// - swatch-radius (float): Swatch circle radius, canvas units.
/// - gap (float): Horizontal gap between swatch and label.
/// - text-size (length): Label font size.
/// - stroke-darken (ratio): How much to darken the swatch's outline.
/// - ball (bool): Use the shaded-ball gradient (`true`) or a flat fill.
/// -> content
#let legend(
  entries,
  origin: (0, 0),
  row-height: 0.55,
  swatch-radius: 0.16,
  gap: 0.18,
  text-size: 9pt,
  stroke-darken: 45%,
  ball: true,
) = {
  let rows = legend-rows(entries, row-height: row-height, origin: origin)
  import cetz.draw: *
  for r in rows {
    let fill = if ball { _sphere-gradient(r.color) } else { r.color }
    circle(
      r.pos,
      radius: swatch-radius,
      fill: fill,
      stroke: (paint: r.color.darken(stroke-darken), thickness: 0.4pt),
    )
    content(
      (r.pos.at(0) + swatch-radius + gap, r.pos.at(1)),
      anchor: "west",
      text(size: text-size, r.label),
    )
  }
}

// --- colorbar ---------------------------------------------------------------

/// The gradient a colorbar samples. A gradient passes through unchanged; an
/// array of (>= 2) colours becomes a bottom-to-top linear gradient (first colour
/// at the bar's foot, matching `range`'s low end). Pure — no cetz.
///
/// - colormap (gradient, array): A gradient or an array of colours.
/// -> gradient
#let colorbar-gradient(colormap) = {
  if type(colormap) == gradient { return colormap }
  assert(
    type(colormap) == array and colormap.len() >= 2,
    message: "colorbar colormap must be a gradient or an array of >= 2 colors, got " + repr(colormap),
  )
  for c in colormap {
    assert(type(c) == color, message: "colormap entries must be colors, got " + repr(c))
  }
  gradient.linear(..colormap, dir: btt)
}

/// Default tick formatter: rounds to two decimals.
#let _fmt(x) = str(calc.round(x, digits: 2))

/// A vertical colorbar sampling `colormap`, with min/max (and optionally mid)
/// tick labels drawn from `range: (lo, hi)`. The bar's foot is `lo`, its top
/// `hi`. Returns cetz draw commands.
///
/// - colormap (gradient, array): A gradient or an array of colours (see
///   `colorbar-gradient`).
/// - range (array): `(lo, hi)` scalar bounds mapped to the bar's foot and top.
/// - origin (array): Canvas-space bottom-left corner `(x, y)` of the bar.
/// - width (float): Bar width, canvas units.
/// - height (float): Bar height, canvas units.
/// - mid (none, bool, float): `true` labels the midpoint `(lo+hi)/2`; a number
///   labels that value; `none` omits the mid tick.
/// - text-size (length): Tick-label font size.
/// - tick-gap (float): Horizontal gap between the bar and its tick labels.
/// - format (function): `value -> str` tick formatter.
/// - stroke-color (color): Bar outline colour.
/// -> content
#let colorbar(
  colormap,
  range,
  origin: (0, 0),
  width: 0.4,
  height: 3.0,
  mid: none,
  text-size: 8pt,
  tick-gap: 0.15,
  format: _fmt,
  stroke-color: luma(80),
) = {
  let (lo, hi) = range
  let grad = colorbar-gradient(colormap)
  let (ox, oy) = origin
  let ticks = ((lo, oy), (hi, oy + height))
  if mid != none {
    let mv = if mid == true { (lo + hi) / 2 } else { mid }
    let frac = if hi == lo { 0.0 } else { (mv - lo) / (hi - lo) }
    ticks.push((mv, oy + height * frac))
  }
  import cetz.draw: *
  rect(
    (ox, oy),
    (ox + width, oy + height),
    fill: grad,
    stroke: (paint: stroke-color, thickness: 0.5pt),
  )
  for (val, ty) in ticks {
    content(
      (ox + width + tick-gap, ty),
      anchor: "west",
      text(size: text-size, format(val)),
    )
  }
}
