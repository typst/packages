// The drawing API (API 2): one `draw` function that dispatches on `view`.
//
// A view = a renderer kind + a default mask (+ a fixed face or camera). All
// appearance options live here, with one default each, so they mean the same
// thing in every view. Options that only make sense for one kind of picture
// are ignored by the others. Each puzzle lists which views it supports;
// asking for another one is an error.

#import "../geom.typ" as g
#import "../state.typ": assert-puzzle, keep-colors, hide-pieces, mask as mask-with
#import "../puzzles/registry.typ" as registry
#import "common.typ": default-palette
#import "2d.typ": draw-face
#import "net.typ": draw-net
#import "3d.typ": draw-3d
#import "layers.typ": draw-layers

// The generic views, one per renderer kind. Every other view is one of these
// with something fixed: `ll` is `face` looking at U with its side strips,
// `oll` is `ll` plus a mask, `f2l` is `full` plus a mask, `tip` is a 3D view
// from a pyraminx tip, `obl` and `cs` are `layers` (the Square-1's two layers
// side by side) plus a mask.
//
// `face: auto` means "take the `face:` option"; `sides` is the view's default
// for the `sides:` option, which the caller can still override.
#let face-view = (kind: "face", face: auto, sides: false, mask: none)
#let full-view = (kind: "3d", camera: "full", mask: none)
#let net-view = (kind: "net", slices: true, mask: none)
#let layers-view = (kind: "layers", sides: true, slices: true, mask: none)

#let views = (
  face: face-view,
  ll: (..face-view, face: "U", sides: true),
  oll: (..face-view, face: "U", sides: true, mask: c => keep-colors(c, c.scheme.U)),
  full: full-view,
  f2l: (..full-view, mask: c => hide-pieces(c, containing: c.scheme.U)),
  tip: (..full-view, camera: "tip"),
  net: net-view,
  layers: layers-view,
  obl: (..layers-view, sides: false, mask: c => keep-colors(c, (c.scheme.U, c.scheme.D))),
  cs: (..layers-view, sides: false, mask: c => mask-with(c, info => false)),
)

#let renderers = (
  face: (c, o) => draw-face(
    c,
    face: o.face,
    sides: o.sides,
    sticker: o.sticker,
    gap: o.gap,
    stroke: o.stroke,
    radius: o.radius,
    body: o.body,
    palette: o.palette,
    hidden: o.hidden,
    side-length: o.side-length,
    arrows: o.arrows,
    arrow-color: o.arrow-color,
    arrow-thickness: o.arrow-thickness,
    arrow-head: o.arrow-head,
    labels: o.labels,
    slices: o.slices,
    turn: if o.turn { auto } else { 0deg },
  ),
  "3d": (c, o) => draw-3d(
    c,
    camera: o.camera,
    sticker: o.sticker,
    gap: o.gap,
    stroke: o.stroke,
    body: o.body,
    palette: o.palette,
    hidden: o.hidden,
  ),
  net: (c, o) => if "layers" in registry.of(c) {
    // a layered puzzle's net: its layers stacked, with the equator unrolled between them
    draw-layers(
      c,
      sides: true,
      slices: o.slices,
      band: true,
      direction: "vertical",
      sticker: o.sticker,
      gap: o.gap,
      spacing: o.spacing,
      stroke: o.stroke,
      radius: o.radius,
      body: o.body,
      palette: o.palette,
      hidden: o.hidden,
      side-length: o.side-length,
      labels: o.labels,
    )
  } else {
    draw-net(
      c,
      sticker: o.sticker,
      gap: o.gap,
      stroke: o.stroke,
      radius: o.radius,
      body: o.body,
      palette: o.palette,
      hidden: o.hidden,
      spacing: o.spacing,
      labels: o.labels,
    )
  },
  layers: (c, o) => draw-layers(
    c,
    sides: o.sides,
    slices: o.slices,
    direction: o.direction,
    turn: o.turn,
    sticker: o.sticker,
    gap: o.gap,
    spacing: o.spacing,
    stroke: o.stroke,
    radius: o.radius,
    body: o.body,
    palette: o.palette,
    hidden: o.hidden,
    side-length: o.side-length,
    labels: o.labels,
  ),
)

/// The camera of the `full` view with `face` in front and `top` on top.
///
/// A puzzle defines its `full` camera for its default pair, `front-top`
/// (F in front, U on top). Any other pair gets the same camera moved by
/// the rotation that carries the default pair onto it, so the pair must
/// sit like the default one: adjacent faces, or on the pyraminx a face and
/// one of its vertices. The direction of a name comes from the puzzle's
/// `direction(params, name, role)` hook when it has one (the pyraminx, whose
/// tops are vertices), else it is the face normal. `top: auto` is the
/// default top when that fits `face`, else the first fitting name.
#let full-camera(p, c, face, top) = {
  let cams = (p.cameras)(c.params)
  if "front-top" not in p {
    assert(
      face == auto and top == auto,
      message: "cubst: the full view of a " + c.event + " has a fixed camera and takes no face: or top:",
    )
    return cams.full
  }
  let model = registry.model(c)
  let (f0, t0) = p.front-top
  let direction(name, role) = if "direction" in p { (p.direction)(c.params, name, role) } else {
    if name in model.faces { model.faces.at(name).normal } else { none }
  }
  let face = if face == auto { f0 } else { face }
  let f = direction(face, "face")
  assert(f != none, message: "cubst: unknown face " + repr(face) + " for a " + c.event + "; faces are " + (p.faces)(c.params).join(", "))
  let (f0v, t0v) = (direction(f0, "face"), direction(t0, "top"))
  let fits(t) = t != none and calc.abs(g.dot(f, t) - g.dot(f0v, t0v)) < 1e-6
  let tops = p.at("tops", default: (p.faces)(c.params))
  let top = if top != auto { top } else {
    (t0, ..tops).find(name => fits(direction(name, "top")))
  }
  let t = direction(top, "top")
  assert(t != none, message: "cubst: unknown top " + repr(top) + " for a " + c.event + "; tops are " + tops.join(", "))
  assert(
    fits(t),
    message: "cubst: " + top + " cannot be on top with " + face + " in front; the two must sit like " + t0 + " and " + f0,
  )
  // orthonormal frames spanned by the pair; map one onto the other
  let frame(a, b) = {
    let e1 = g.unit(a)
    let e2 = g.unit(g.sub(b, g.scale(e1, g.dot(b, e1))))
    (e1, e2, g.cross(e1, e2))
  }
  let (from, to) = (frame(f0v, t0v), frame(f, t))
  let rot(v) = range(3).fold((0, 0, 0), (acc, i) => g.add(acc, g.scale(to.at(i), g.dot(v, from.at(i)))))
  (dir: rot(cams.full.dir), up: rot(cams.full.up))
}

/// Draw a puzzle.
///
/// - `view`: `"face"`, `"ll"`, `"oll"`, `"full"`, `"f2l"`, `"tip"`, `"net"`,
///   `"layers"`, `"obl"` or `"cs"`; each puzzle supports a subset. `auto` is
///   the puzzle's `default-view` (`"full"` unless it says otherwise; the
///   Square-1 says `"layers"`). A view already decides which stickers are
///   hidden (its default mask).
/// - `mask`: `auto` keeps the view's default mask; `none` shows every sticker;
///   a function `state => state` (e.g. `c => keep-colors(c, "yellow")`) replaces it.
///
/// Appearance, identical for every view:
/// - `sticker`: length of one unit, i.e. one cube sticker edge (absolute length).
/// - `gap`: space between stickers; `body` shows through it.
/// - `stroke`, `radius`: sticker outline and corner radius (radius only on square stickers).
/// - `body`: color behind the stickers (`none` = transparent).
/// - `palette`: color name → color. `hidden`: color of masked stickers
///   (`auto` = the palette's `hidden` entry).
///
/// - `face`: which face the `"face"` view looks at (`oll`/`ll` always use `U`);
///   `auto` = the puzzle's first face (`U`, or `F` on the pyraminx). On the
///   `"full"` view, the face in front (`auto` = `F`), see `full-camera`.
/// - `top`: on the `"full"` view, the face on top (`auto` = `U`, or the
///   first face that fits `face`); on the pyraminx a vertex.
/// - `tip`: which vertex the pyraminx `"tip"` view looks down (`auto` = the
///   puzzle's first tip, `U`).
/// The Square-1 takes neither `face` nor `top`.
///
/// Only used by the straight-on views:
/// - `sides`: whether to draw the neighbouring stickers as strips around it.
///   `auto` = the view's default: off for `face`, on for `ll` and `oll`.
/// - `side-length`: thickness of the side strips as a fraction of a unit.
/// - `arrows`, `arrow-color`, `arrow-thickness`, `arrow-head`: arrows between
///   sticker positions on the shown face.
/// - `labels`: `true` writes each sticker's index on it; `"faces"` writes the
///   name of each face at its centre instead.
///
/// Only used by the net view: `spacing`, the distance between faces.
///
/// Settings that exist for one puzzle only go in `options`, declared by the
/// puzzle as `draw-options` with their defaults (like `cube(options:)`):
/// - Square-1 `slices`: mark the slice with a thin line; `auto` = the view's
///   default: on for `layers`, `obl`, `cs` and `net`, off for `face`.
/// - Square-1 `direction`: `"horizontal"` or `"vertical"` for the layers views.
/// - Square-1 `turn`: turn each layer so that its slice is vertical, as the
///   net always does (`false`).
/// A key the puzzle does not declare is an error.
#let draw(
  c,
  view: auto,
  mask: auto,
  face: auto,
  top: auto,
  tip: auto,
  sides: auto,
  options: (:),
  sticker: 6mm,
  gap: 0pt,
  stroke: 0.5pt + black,
  radius: 0pt,
  body: none,
  palette: default-palette,
  hidden: auto,
  side-length: 0.35,
  arrows: (),
  arrow-color: black,
  arrow-thickness: 1.6pt,
  arrow-head: 0.3,
  labels: false,
  spacing: auto,
) = {
  assert-puzzle(c, who: "draw")
  let p = registry.of(c)
  let view = if view == auto { p.at("default-view", default: "full") } else { view }
  assert(
    view in views,
    message: "cubst: unknown view " + repr(view) + "; expected one of " + views.keys().map(repr).join(", "),
  )
  assert(
    view in p.views,
    message: "cubst: view " + repr(view) + " is not available for a " + c.event + "; it supports " + p.views.map(repr).join(", "),
  )
  let v = views.at(view)
  let m = if mask == auto { v.mask } else { mask }
  assert(
    m == none or type(m) == function,
    message: "cubst: mask must be auto, none or a function state => state, got " + repr(mask),
  )
  let shown = if m == none { c } else { m(c) }
  if "fixed-face" in p {
    assert(face == auto and top == auto, message: "cubst: the " + c.event + " takes no face: or top:")
  }
  assert(
    labels in (true, false, "faces"),
    message: "cubst: labels must be true, false or \"faces\", got " + repr(labels),
  )

  // puzzle-specific drawing options, validated against the puzzle's list
  assert(type(options) == dictionary, message: "cubst: options must be a dictionary, got " + repr(options))
  let defaults = p.at("draw-options", default: (:))
  for key in options.keys() {
    assert(
      key in defaults,
      message: "cubst: " + c.event + " has no drawing option " + repr(key) + if defaults.len() == 0 {
        " (it has none)"
      } else { "; options are " + defaults.keys().join(", ") },
    )
  }
  let opts = defaults + options
  let slices = opts.at("slices", default: auto)
  let direction = opts.at("direction", default: "horizontal")
  let turn = opts.at("turn", default: false)

  let fixed-face = v.at("face", default: auto)
  let camera = if v.kind != "3d" { none } else {
    let cams = (p.cameras)(c.params)
    if v.camera == "full" { full-camera(p, c, face, top) } else {
      let tip = if tip == auto { cams.tips.keys().first() } else { tip }
      assert(
        tip in cams.tips,
        message: "cubst: unknown tip " + repr(tip) + " for a " + c.event + "; tips are " + cams.tips.keys().join(", "),
      )
      cams.tips.at(tip)
    }
  }
  let options = (
    face: if fixed-face == auto { face } else { fixed-face },
    sides: if sides == auto { v.at("sides", default: true) } else { sides },
    slices: if slices == auto { v.at("slices", default: false) } else { slices },
    direction: direction,
    turn: turn,
    camera: camera,
    sticker: sticker,
    gap: gap,
    stroke: stroke,
    radius: radius,
    body: body,
    palette: palette,
    hidden: hidden,
    side-length: side-length,
    arrows: arrows,
    arrow-color: arrow-color,
    arrow-thickness: arrow-thickness,
    arrow-head: arrow-head,
    labels: labels,
    spacing: spacing,
  )
  (renderers.at(v.kind))(shown, options)
}
