#import "@preview/cetz:0.5.2" as cetz
#import "../theme.typ" as theme-mod
#import "model.typ": model
#import "layout.typ": layout

// timeline: events along an axis, in one of three orientations:
//   "horizontal" — a rule, markers spaced left-to-right, labels above/below.
//   "vertical"   — a rule top-to-bottom, labels left/right.
//   "snaked"     — horizontal rows that wrap and reverse direction (boustrophedon),
//                  joined by orthogonal turns; pick it for long timelines (`wrap`
//                  events per row).
// Each event is a shaped marker with its time / title / description as plain text
// (no boxes), joined by a short stem. Colour is opt-in: a marker with a `fill:` is
// a light fill ringed by a same-hue rim, otherwise a hollow outline — so shape and
// colour can together encode a stage. Returns content.
#let timeline(
  ..events,
  orientation: "horizontal",
  wrap: 5,
  theme: theme-mod.default,
) = context {
  assert(
    orientation in ("horizontal", "vertical", "snaked"),
    message: "timeline: orientation must be \"horizontal\", \"vertical\", or \"snaked\", got "
      + repr(orientation),
  )
  let evs = layout(model(events.pos()))

  // Capture tokens before `import cetz.draw: *` shadows names like `line`/`fill`.
  let margin = theme.timeline-margin
  let axis-stroke = theme.timeline-axis-stroke
  let pitch = theme.timeline-pitch / 1cm
  let row-h = theme.timeline-row-height / 1cm
  let turn-bulge = theme.timeline-turn-bulge / 1cm
  let edge-nudge = theme.timeline-edge-nudge / 1cm
  let m = theme.timeline-marker-size / 1cm
  let edge-width = theme.timeline-marker-edge-width
  let edge-darken = theme.timeline-marker-edge-darken
  let stem = theme.timeline-stem / 1cm
  let text-w = theme.timeline-text-width / 1cm
  let text-gap = theme.timeline-text-gap / 1cm
  let marker-outline = theme.timeline-marker-outline
  let marker-fill = theme.timeline-marker-fill
  let time-size = theme.timeline-time-size
  let title-size = theme.timeline-title-size
  let desc-size = theme.timeline-desc-size
  let time-fill = theme.timeline-time-color
  let text-fill = theme.timeline-text-color

  // An event's label: time / title / description, centred and wrapped to a width
  // (no drawn box). Justification off so a wrapped description isn't stretched.
  let label-of = e => {
    let parts = ()
    if e.time != none {
      parts.push(text(size: time-size, fill: time-fill, e.time))
    }
    parts.push(text(
      size: title-size,
      fill: text-fill,
      weight: "medium",
      e.title,
    ))
    if e.description != none {
      parts.push(text(size: desc-size, fill: text-fill, e.description))
    }
    box(width: text-w * 1cm, {
      set par(justify: false)
      align(center, parts.join(linebreak()))
    })
  }

  let n = evs.len()

  // Pad the finished canvas top and bottom so the diagram doesn't crowd whatever
  // sits above and below it in a document.
  pad(y: margin, cetz.canvas({
    import cetz.draw: *

    // A marker of event `e` at (x, y). Colour is opt-in, like the field diagrams:
    // given a `fill:` it's a light fill ringed by a deeper same-hue rim (the rim
    // carries the WCAG non-text contrast a light fill can't); with no fill it's a
    // hollow outline, so a default timeline stays monochrome line-art. A solid
    // colour can be darkened for the rim; any other paint (gradient/tiling) has no
    // `.darken`, so fall back to the fill itself rather than panic.
    let marker = (x, y, e) => {
      let edge = (
        edge-width
          + if e.fill == none {
            marker-outline
          } else if type(e.fill) == color {
            e.fill.darken(edge-darken)
          } else {
            e.fill
          }
      )
      // A hollow marker's interior is opaque, not transparent, so it knocks out the
      // axis line passing beneath it rather than letting it strike through.
      let mfill = if e.fill == none { marker-fill } else { e.fill }
      if e.shape == "circle" {
        circle((x, y), radius: m, fill: mfill, stroke: edge)
      } else if e.shape == "square" {
        rect((x - m, y - m), (x + m, y + m), fill: mfill, stroke: edge)
      } else if e.shape == "diamond" {
        line(
          (x, y + m),
          (x + m, y),
          (x, y - m),
          (x - m, y),
          close: true,
          fill: mfill,
          stroke: edge,
        )
      } else if e.shape == "triangle" {
        line(
          (x, y + m),
          (x + m, y - m),
          (x - m, y - m),
          close: true,
          fill: mfill,
          stroke: edge,
        )
      }
    }

    if orientation == "vertical" {
      line((0, 0), (0, -calc.max((n - 1) * pitch, 0)), stroke: axis-stroke)
      for e in evs {
        let y = -e.slot * pitch
        marker(0, y, e)
        let end-x = e.side * (m + stem)
        line((e.side * m, y), (end-x, y), stroke: axis-stroke)
        content(
          (end-x + e.side * text-gap, y),
          label-of(e),
          anchor: if e.side > 0 { "west" } else { "east" },
        )
      }
    } else if orientation == "snaked" {
      let rows = calc.ceil(n / wrap)
      let full-w = (wrap - 1) * pitch
      // A symmetric cubic U-bend peaks at 3/4 of its control offset beyond its
      // endpoints — that's how far the curve actually reaches. Inset the turns by
      // this (not the full offset) so the bend meets the diagram edge and the
      // flush start/end markers line up with the curve, not poke past it.
      let bulge-depth = 3 / 4 * turn-bulge
      let right-edge = full-w + 2 * bulge-depth // left edge is 0
      let cnt-of = r => calc.min((r + 1) * wrap, n) - r * wrap

      // A row's x-span [lx, rx]. An end is flush with a diagram edge (0 or
      // `right-edge`) only when it carries the timeline's first or last marker;
      // otherwise it insets by the bulge so its turn curves out *to* the edge, not
      // past it. The markers then fill that span — so the start sits flush at the
      // left edge (and a full final row at the right) instead of the U-bends
      // pushing the box out and leaving the start indented.
      let span-of = r => {
        let even = calc.rem(r, 2) == 0
        let start-flush = r == 0
        let end-flush = r == rows - 1
        let left-flush = if even { start-flush } else { end-flush }
        let right-flush = if even { end-flush } else { start-flush }
        (
          if left-flush { 0.0 } else { bulge-depth },
          if right-flush { right-edge } else { right-edge - bulge-depth },
        )
      }

      // x of slot `s`: a row fills its span evenly; a partial final row keeps the
      // nominal pitch from its start and just ends where it ends (half-way is fine).
      let x-of = s => {
        let r = calc.quo(s, wrap)
        let c = calc.rem(s, wrap)
        let even = calc.rem(r, 2) == 0
        let cnt = cnt-of(r)
        let (lx, rx) = span-of(r)
        let x = if r == rows - 1 and cnt < wrap {
          if even { lx + c * pitch } else { rx - c * pitch }
        } else {
          let step = if cnt > 1 { (rx - lx) / (cnt - 1) } else { 0.0 }
          if even { lx + c * step } else { rx - c * step }
        }
        // Optical nudge: the first marker sits flush at the left edge, where its
        // disc overshoots the curve's tangent — ease it a hair inward so it reads
        // as on the edge. Only the start; the end runs into the next row's turn or
        // just stops, so it has no edge to overshoot.
        if s == 0 {
          x + edge-nudge
        } else {
          x
        }
      }
      // Row rules, drawn to each row's actual event extent.
      for r in range(0, rows) {
        let xs = range(r * wrap, calc.min((r + 1) * wrap, n)).map(x-of)
        line(
          (calc.min(..xs), -r * row-h),
          (calc.max(..xs), -r * row-h),
          stroke: axis-stroke,
        )
      }
      // Turns: a smooth U-bend from a row's inset end out to the edge and down to
      // the next row's inset start. Even rows bend right (to `right-edge`), odd
      // rows left (to 0); both bezier handles point straight out, so the curve
      // leaves and rejoins the horizontal rows tangentially.
      for r in range(0, rows - 1) {
        let even = calc.rem(r, 2) == 0
        let x-turn = if even { right-edge - bulge-depth } else { bulge-depth }
        let out = if even { turn-bulge } else { -turn-bulge }
        let y0 = -r * row-h
        let y1 = -(r + 1) * row-h
        bezier(
          (x-turn, y0),
          (x-turn, y1),
          (x-turn + out, y0),
          (x-turn + out, y1),
          stroke: axis-stroke,
        )
      }
      // Label side: anchor each row's last marker above the rule (and alternate
      // back from there). A turn joins one row's last marker to the next row's
      // first, both at the same x in the gap between the rows; if both pointed in
      // they'd overlap. Anchoring the last marker out (above) keeps that gap clear
      // regardless of `wrap` parity — the global +/- alternation can't.
      let side-of = e => {
        let p = calc.rem(e.slot, wrap)
        let cnt = cnt-of(calc.quo(e.slot, wrap))
        if calc.rem(cnt - 1 - p, 2) == 0 { 1 } else { -1 }
      }
      for e in evs {
        let x = x-of(e.slot)
        let y = -calc.quo(e.slot, wrap) * row-h
        let side = side-of(e)
        marker(x, y, e)
        let end-y = y + side * (m + stem)
        line((x, y + side * m), (x, end-y), stroke: axis-stroke)
        content(
          (x, end-y + side * text-gap),
          label-of(e),
          anchor: if side > 0 { "south" } else { "north" },
        )
      }
    } else {
      // horizontal (default)
      line((0, 0), (calc.max((n - 1) * pitch, 0), 0), stroke: axis-stroke)
      for e in evs {
        let x = e.slot * pitch
        marker(x, 0, e)
        let end-y = e.side * (m + stem)
        line((x, e.side * m), (x, end-y), stroke: axis-stroke)
        content(
          (x, end-y + e.side * text-gap),
          label-of(e),
          anchor: if e.side > 0 { "south" } else { "north" },
        )
      }
    }
  }))
}
