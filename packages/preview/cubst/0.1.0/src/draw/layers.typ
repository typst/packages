// Layers renderer: the layers of a layered puzzle (the Square-1) drawn
// straight on with `draw-face`, side by side or top to bottom. With
// `band: true` the equator's front stickers are shown between them (they
// tell whether the equator is flipped: two reds of different lengths when it
// is not, a red and an orange of the same length when it is), the layers are
// turned so that the slice is vertical, and one slice line runs through the
// whole picture; stacked, that is the net.

#import "../geom.typ" as g
#import "../state.typ": assert-puzzle
#import "../puzzles/registry.typ" as registry
#import "common.typ": default-palette, fill-of, abs-pt, shape
#import "2d.typ": draw-face

/// Draw the layers of a puzzle that lists them in `layers` (Square-1: U, D).
///
/// - `sides`: draw each layer's side stickers as strips around it.
/// - `slices`: mark the slice on each layer with a thin line.
/// - `band`: add the front of the equator between the layers.
/// - `direction`: `"horizontal"` (side by side) or `"vertical"` (top to bottom).
/// - `turn`: turn each layer so that its slice is vertical (always on with `band`).
/// - `spacing`: distance between the pictures (`auto` = half a unit).
#let draw-layers(
  c,
  sides: true,
  slices: true,
  band: false,
  direction: "horizontal",
  turn: false,
  sticker: 6mm,
  gap: 0pt,
  spacing: auto,
  stroke: 0.5pt + black,
  radius: 0pt,
  palette: default-palette,
  hidden: auto,
  body: none,
  side-length: 0.35,
  labels: false,
) = {
  assert-puzzle(c, who: "draw-layers")
  let p = registry.of(c)
  assert("layers" in p, message: "cubst: the " + c.event + " has no layers view")
  assert(
    direction in ("horizontal", "vertical"),
    message: "cubst: direction must be \"horizontal\" or \"vertical\", got " + repr(direction),
  )
  let s = abs-pt(sticker, "sticker")
  let gp = abs-pt(gap, "gap") / s
  let sp = if spacing == auto { 0.5 } else { abs-pt(spacing, "spacing") / s }

  let pics = p.layers.map(f => draw-face(
    c,
    face: f,
    sides: sides,
    slices: if band and slices { "through" } else { slices },
    turn: if band or turn { auto } else { 0deg },
    sticker: sticker,
    gap: gap,
    stroke: stroke,
    radius: radius,
    palette: palette,
    hidden: hidden,
    body: body,
    side-length: side-length,
    labels: labels,
  ))

  if band {
    // the equator stickers facing the front, left to right
    let model = registry.model(c)
    let front = model.stickers.filter(st => st.at("band", default: false) and st.normal.at(2) > calc.abs(st.normal.at(0)))
    let strip = front.map(st => {
      let ys = st.poly.map(q => q.at(1))
      let top = st.poly.filter(q => q.at(1) == calc.max(..ys))
      (
        width: g.norm(g.sub(top.at(0), top.at(1))),
        height: calc.max(..ys) - calc.min(..ys),
        x: g.centroid(st.poly).at(0),
        name: c.faces.at(st.face).at(st.index),
      )
    }).sorted(key: st => st.x)
    // the two stickers meet at the slice, which is put in the middle of a box
    // that also holds the spacing above and below, so the slice line can run
    // through gaps and band alike
    let half = calc.max(..strip.map(st => st.width))
    let height = strip.first().height
    let x = half - strip.first().width
    let shapes = ()
    for st in strip {
      shapes.push((poly: g.inset(((x, sp), (x + st.width, sp), (x + st.width, sp + height), (x, sp + height)), gp), name: st.name))
      x += st.width
    }
    let total = (sp * 2 + height) * s
    pics.insert(1, box(width: 2 * half * s * 1pt, height: total * 1pt, {
      if body != none { shape(((half - strip.first().width, sp), (x, sp), (x, sp + height), (half - strip.first().width, sp + height)).map(q => (q.at(0) * s, q.at(1) * s)), body, none, 0pt) }
      for sh in shapes { shape(sh.poly.map(q => (q.at(0) * s, q.at(1) * s)), fill-of(sh.name, palette, hidden), stroke, radius) }
      if slices {
        place(top + left, line(start: (half * s * 1pt, 0pt), end: (half * s * 1pt, total * 1pt), stroke: 0.6pt + luma(120)))
      }
    }))
  }

  box(if direction == "vertical" {
    grid(columns: 1, row-gutter: if band { 0pt } else { sp * s * 1pt }, align: center, ..pics)
  } else {
    grid(columns: pics.len(), column-gutter: sp * s * 1pt, align: horizon, ..pics)
  })
}
