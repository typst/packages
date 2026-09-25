// Marker drawing for points and legend keys.
//
// Renders a single marker at `(cx, cy)` from a shape keyword. Used by
// geom-point during plotting and by the legend renderer when composing key
// glyphs. Lives in `guide/` so the legend layer doesn't pull `geom/point.typ`
// just to reach the drawing primitives.

#import "../deps.typ": cetz

// Convert a Typst length to canvas units (1 unit = 1 cm). Polygonal shapes
// build their geometry in canvas units; circles can take a length directly
// because CeTZ accepts pt for `radius:`.
#let size-to-units(size) = {
  if type(size) == length { size / 1cm } else { float(size) }
}

#let draw-marker(pos, kind, size, paint, stroke-spec, font: none) = {
  if kind == none { return }
  let (cx, cy) = pos
  if kind == "circle" {
    cetz.draw.circle((cx, cy), radius: size, fill: paint, stroke: stroke-spec)
    return
  }
  let r = size-to-units(size)
  if kind == "square" {
    cetz.draw.rect(
      (cx - r, cy - r),
      (cx + r, cy + r),
      fill: paint,
      stroke: stroke-spec,
    )
  } else if kind == "triangle" {
    cetz.draw.line(
      (cx - r, cy - r),
      (cx + r, cy - r),
      (cx, cy + r),
      close: true,
      fill: paint,
      stroke: stroke-spec,
    )
  } else if kind == "triangle-down" {
    cetz.draw.line(
      (cx - r, cy + r),
      (cx + r, cy + r),
      (cx, cy - r),
      close: true,
      fill: paint,
      stroke: stroke-spec,
    )
  } else if kind == "diamond" {
    cetz.draw.line(
      (cx, cy + r),
      (cx + r, cy),
      (cx, cy - r),
      (cx - r, cy),
      close: true,
      fill: paint,
      stroke: stroke-spec,
    )
  } else if kind == "cross" {
    let s = if stroke-spec == none {
      (paint: paint, thickness: r / 2 * 1cm)
    } else { stroke-spec }
    cetz.draw.line((cx - r, cy), (cx + r, cy), stroke: s)
    cetz.draw.line((cx, cy - r), (cx, cy + r), stroke: s)
  } else if kind == "x" {
    let s = if stroke-spec == none {
      (paint: paint, thickness: r / 2 * 1cm)
    } else { stroke-spec }
    cetz.draw.line((cx - r, cy - r), (cx + r, cy + r), stroke: s)
    cetz.draw.line((cx - r, cy + r), (cx + r, cy - r), stroke: s)
  } else if kind == "star" {
    let s = if stroke-spec == none {
      (paint: paint, thickness: r / 2.5 * 1cm)
    } else { stroke-spec }
    cetz.draw.line((cx - r, cy), (cx + r, cy), stroke: s)
    cetz.draw.line((cx, cy - r), (cx, cy + r), stroke: s)
    cetz.draw.line((cx - r, cy - r), (cx + r, cy + r), stroke: s)
    cetz.draw.line((cx - r, cy + r), (cx + r, cy - r), stroke: s)
  } else {
    // Any other value renders as a literal glyph (character or emoji). The
    // glyph takes its colour from the outline (stroke) paint, falling back to
    // the body fill, so a default marker adopts the geom colour like the
    // stroke-driven cross/x/star shapes; it has no separate outline. `size` is
    // a radius, so the diameter is used as the font size to match a marker's
    // footprint.
    let stroke-paint = if type(stroke-spec) == dictionary {
      stroke-spec.at("paint", default: none)
    } else { none }
    let glyph-paint = if stroke-paint != none { stroke-paint } else { paint }
    // `none` font keeps the document font; only pass `text(font: ...)` when set.
    let font-args = if font != none { (font: font) } else { (:) }
    cetz.draw.content(
      (cx, cy),
      text(size: r * 2 * 1cm, fill: glyph-paint, ..font-args)[#kind],
      anchor: "center",
    )
  }
}
