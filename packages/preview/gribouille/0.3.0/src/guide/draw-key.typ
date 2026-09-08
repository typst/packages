///! Legend key glyphs.
///!
///! Each geom contributes a small drawing to the legend. The default glyph
///! depends on the geom kind: points draw circles, lines draw short strokes,
///! filled shapes draw small rectangles. Override per layer with `key:`.

#import "../deps.typ": cetz
#import "../utils/colour-resolve.typ": apply-alpha
#import "./draw-marker.typ": draw-marker

/// Draw-key returning a small filled circle.
///
/// Used by point and jitter geoms.
///
/// Returns: Draw-key dictionary consumed by the legend renderer.
///
/// See also: `draw-key-line`, `draw-key-rect`, `draw-key-path`, `draw-key-blank`.
///
/// Force the point glyph in the legend (the default for points).
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt, key: draw-key-point()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// Use the point glyph on a layer that would otherwise default to a different shape, like a line layered over points.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"), (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-line(key: draw-key-point()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
#let draw-key-point() = (kind: "draw-key", key: "point")

/// Draw-key returning a short horizontal line.
///
/// Used by line, path, step, smooth, segment, hline, vline, and abline geoms.
///
/// Returns: Draw-key dictionary consumed by the legend renderer.
///
/// See also: `draw-key-point`, `draw-key-rect`, `draw-key-path`, `draw-key-blank`.
///
/// Short stroke glyph (the default for line layers).
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"),
///   (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-line(key: draw-key-line()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// Override a column layer's default rectangle glyph with a line stroke.
///
/// ```typst
/// #let d = (
///   (g: "a", n: 3),
///   (g: "b", n: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "g", y: "n", fill: "g"),
///   layers: (geom-col(key: draw-key-line()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
#let draw-key-line() = (kind: "draw-key", key: "line")

/// Draw-key returning a small filled rectangle.
///
/// Used by bar, col, rect, tile, polygon, area, ribbon, and histogram geoms.
///
/// Returns: Draw-key dictionary consumed by the legend renderer.
///
/// See also: `draw-key-point`, `draw-key-line`, `draw-key-path`, `draw-key-blank`.
///
/// Filled rectangle glyph (the default for column layers).
///
/// ```typst
/// #let d = (
///   (g: "a", n: 3),
///   (g: "b", n: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "g", y: "n", fill: "g"),
///   layers: (geom-col(key: draw-key-rect()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// Use the rectangle glyph on a point layer when the legend reads more naturally as colour swatches.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt, key: draw-key-rect()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
#let draw-key-rect() = (kind: "draw-key", key: "rect")

/// Draw-key returning a short polyline.
///
/// Useful for path-like geoms where a single straight stroke is misleading.
///
/// Returns: Draw-key dictionary consumed by the legend renderer.
///
/// See also: `draw-key-point`, `draw-key-line`, `draw-key-rect`, `draw-key-blank`.
///
/// Short polyline glyph that hints at a non-monotonic path.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"),
///   (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-path(key: draw-key-path()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// Use the path glyph for trajectory-style line layers to make the legend visually consistent with the data.
///
/// ```typst
/// #let d = range(0, 24).map(t => (
///   x: calc.cos(t * 0.4), y: calc.sin(t * 0.4) * (t / 24 + 0.5), g: "trajectory",
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-path(stroke: 1pt, key: draw-key-path()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
#let draw-key-path() = (kind: "draw-key", key: "path")

/// Draw-key that draws nothing.
///
/// Used by `geom-blank` and as a way to suppress a layer's legend glyph without removing the legend entirely.
///
/// Returns: Draw-key dictionary consumed by the legend renderer.
///
/// See also: `draw-key-point`, `draw-key-line`, `draw-key-rect`, `draw-key-path`.
///
/// Suppress just the layer's glyph in the legend, keeping the label slot.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-point(size: 3pt, key: draw-key-blank()),),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
///
/// Useful when one layer in a stack should not appear in the legend; here a `geom-line` carries the legend, a `geom-point` is silenced.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "a"),
///   (x: 1, y: 3, g: "b"), (x: 2, y: 1, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g", fill: "g"),
///   layers: (
///     geom-line(stroke: 1pt),
///     geom-point(size: 3pt, key: draw-key-blank()),
///   ),
///   width: 8cm,
///   height: 5cm,
/// )
/// ```
#let draw-key-blank() = (kind: "draw-key", key: "blank")

// Default key kind for a geom name. Returns one of "point", "line", "rect",
// or "blank" so the legend can pick a glyph automatically.
#let default-key-for(geom) = {
  if (
    "point",
    "jitter",
    "pointrange",
    "dotplot",
  ).contains(geom) {
    return "point"
  }
  if (
    "line",
    "path",
    "step",
    "smooth",
    "segment",
    "curve",
    "spoke",
    "abline",
    "hline",
    "vline",
    "rug",
    "freqpoly",
    "function",
    "qq",
    "qq-line",
    "errorbar",
    "errorbarh",
    "linerange",
  ).contains(geom) {
    return "line"
  }
  if (
    "col",
    "bar",
    "histogram",
    "rect",
    "tile",
    "area",
    "ribbon",
    "polygon",
    "boxplot",
    "crossbar",
    "label",
    "ellipse",
    "mark",
  ).contains(geom) {
    return "rect"
  }
  if (
    "blank",
    "text",
    "typst",
  ).contains(geom) {
    return "blank"
  }
  "rect"
}

// Draw a small key glyph centred at (cx, cy) of the given half-extent `r`.
//
// `bundle` is a dictionary of resolved aesthetic values for the level being
// drawn. Recognised fields (any may be missing):
//
//   colour    : a colour for stroke (line/path) or ring (point) or outline (rect).
//   fill      : a colour for the filled body of point/rect glyphs.
//   shape     : a marker keyword (only consumed when `key == "point"`).
//   linetype  : a CeTZ dash keyword (only consumed when `key` ∈ {"line","path"}).
//   linewidth : a stroke thickness length for line/path glyphs.
//   stroke    : a marker outline thickness length (only consumed when `key == "point"`); falls back to `linewidth` when absent.
//   size      : a marker radius length (only consumed when `key == "point"`).
//   alpha     : opacity in [0, 1] applied to whichever paints the glyph carries.
//
// `ink` is the fallback colour when neither `colour` nor `fill` is supplied.
//
// When `key == "point"` and only `colour` is supplied (no `fill`), the marker
// renders as a stroked ring so colour-only and fill-only swatches stay
// visually distinct, matching the convention from the previous single-paint
// API.
#let draw-glyph(key, cx, cy, r, bundle, ink: black) = {
  if key == "blank" { return }
  let alpha = bundle.at("alpha", default: 1)
  let colour = bundle.at("colour", default: none)
  let fill = bundle.at("fill", default: none)
  let lw = bundle.at("linewidth", default: 1pt)
  let dash = bundle.at("linetype", default: "solid")

  let stroke-paint = if colour != none { apply-alpha(colour, alpha) } else {
    none
  }
  let fill-paint = if fill != none { apply-alpha(fill, alpha) } else { none }
  // Alpha-only ladders carry no colour/fill. Without this, every glyph
  // renders identically opaque because the ink fallback skips apply-alpha.
  let ink-paint = apply-alpha(ink, alpha)

  if key == "point" {
    let kind = bundle.at("shape", default: "circle")
    let size = bundle.at("size", default: r)
    let outline-w = bundle.at("stroke", default: lw)
    if fill-paint != none {
      let stroke = if stroke-paint != none {
        (paint: stroke-paint, thickness: outline-w)
      } else { none }
      draw-marker((cx, cy), kind, size, fill-paint, stroke)
    } else if stroke-paint != none {
      draw-marker(
        (cx, cy),
        kind,
        size,
        none,
        (paint: stroke-paint, thickness: outline-w),
      )
    } else {
      draw-marker((cx, cy), kind, size, ink-paint, none)
    }
    return
  }

  if key == "rect" {
    let body = if fill-paint != none {
      fill-paint
    } else if stroke-paint != none {
      stroke-paint
    } else { ink-paint }
    let outline = if (
      fill-paint != none and stroke-paint != none and stroke-paint != fill-paint
    ) {
      (paint: stroke-paint, thickness: lw)
    } else { none }
    cetz.draw.rect(
      (cx - r, cy - r),
      (cx + r, cy + r),
      fill: body,
      stroke: outline,
    )
    return
  }

  if key == "line" {
    let paint = if stroke-paint != none {
      stroke-paint
    } else if fill-paint != none {
      fill-paint
    } else { ink-paint }
    cetz.draw.line(
      (cx - r * 1.4, cy),
      (cx + r * 1.4, cy),
      stroke: (paint: paint, thickness: lw, dash: dash),
    )
    return
  }

  if key == "path" {
    let paint = if stroke-paint != none {
      stroke-paint
    } else if fill-paint != none {
      fill-paint
    } else { ink-paint }
    cetz.draw.line(
      (cx - r * 1.4, cy - r * 0.6),
      (cx - r * 0.4, cy + r * 0.6),
      (cx + r * 0.4, cy - r * 0.4),
      (cx + r * 1.4, cy + r * 0.5),
      stroke: (paint: paint, thickness: lw, dash: dash),
    )
    return
  }

  let body = if fill-paint != none {
    fill-paint
  } else if stroke-paint != none {
    stroke-paint
  } else { ink-paint }
  cetz.draw.rect(
    (cx - r, cy - r),
    (cx + r, cy + r),
    fill: body,
    stroke: none,
  )
}
