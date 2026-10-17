// ===========================================================================
//  faboxyst/antique.typ — the "antique" vintage effect.
//
//  Vintage scientific illustration: aged paper, dark sepia ink, a Garamond
//  serif, and true engraved strokes — the ink is drawn by an elliptical
//  nib (the calligrapher's pen), so the line thickens and thins as the
//  pen is carried along the path, like a steel engraving.
//
//    #show: plate-page.with(number: [Plate I], title: [...], subtitle: [...])
//    #engraved-frame[An engraved double rule around this text]
//    #engraved-rule(from: (0pt, 0pt), to: (12cm, 0pt))
//
//  The elliptical-nib engine is nibart (`@preview/nibart`, MIT). The palette,
//  the plate / patent page styles and `engraved()` are inspired by the
//  scientific-illustration vocabulary of the `premetadated` package; no code
//  of that package is included.
// ===========================================================================

#import "@preview/cetz:0.5.2"
#import cetz.draw

// ---------------------------------------------------------------------------
//  palette & fonts
// ---------------------------------------------------------------------------

/// The aged-paper palette: cream paper, near-black sepia ink and a paler
/// secondary ink for rules, captions and faded marks.
#let antique-palette = (
  paper: rgb("#F3EAD9"),
  ink: rgb("#272119"),
  pale-ink: rgb("#786A58"),
  patent-paper: rgb("#F5EDDF"),
  patent-ink: rgb("#221E1A"),
)

/// A Garamond-first serif stack with graceful fallbacks (Typst picks the
/// first family installed on the system, per script).
#let _antique-serif = (
  "Adobe Garamond Pro", "EB Garamond", "Garamond", "Georgia",
  "Liberation Serif", "DejaVu Serif",
)

#let antique-fonts = (
  body: _antique-serif,
  heading: _antique-serif,
  bubble: _antique-serif,
  mono: ("DejaVu Sans Mono",),
  emoji: ("Noto Color Emoji", "DejaVu Sans"),
)

// ---------------------------------------------------------------------------
//  the elliptical-nib engine — computed by nibart
// ---------------------------------------------------------------------------
//  The envelope of an elliptical nib carried along a path of cubic segments is
//  computed by nibart (`nib.stroke-items`); the contours it returns are
//  flattened to polygons (canvas units, cm).

#import "@preview/nibart:0.3.0" as nib

#let _PT = 28.3465   // points per canvas unit (cm)
#let _angle(value) = if type(value) == angle { value } else { value * 1deg }
// a canvas number (cm); lengths are converted
#let _n(v) = if type(v) == length { v / 1cm } else { float(v) }

// cubic segments ((P0, P1, P2, P3), …) in cm  →  nibart path (pt)
#let _to-nib(path, closed) = (
  segs: path.map(s => (
    s.at(0).at(0) * _PT, s.at(0).at(1) * _PT, s.at(1).at(0) * _PT, s.at(1).at(1) * _PT,
    s.at(2).at(0) * _PT, s.at(2).at(1) * _PT, s.at(3).at(0) * _PT, s.at(3).at(1) * _PT)),
  cycle: closed,
)

// contour commands of a nibart shape ((0 x y) move, (1 x y) line, (2 c1 c2 p) cubic) → polygon (cm)
#let _flatten(cmds) = {
  let pts = ()
  let cur = (0.0, 0.0)
  for c in cmds {
    if c.at(0) == 0 or c.at(0) == 1 {
      cur = (c.at(1), c.at(2))
      pts.push((cur.at(0) / _PT, cur.at(1) / _PT))
    } else {
      let (x0, y0) = cur
      let (x1, y1, x2, y2, x3, y3) = (c.at(1), c.at(2), c.at(3), c.at(4), c.at(5), c.at(6))
      let n = 4
      for k in range(1, n + 1) {
        let t = k / n
        let u = 1 - t
        pts.push(((u * u * u * x0 + 3 * u * u * t * x1 + 3 * u * t * t * x2 + t * t * t * x3) / _PT,
                  (u * u * u * y0 + 3 * u * u * t * y1 + 3 * u * t * t * y2 + t * t * t * y3) / _PT))
      }
      cur = (x3, y3)
    }
  }
  if pts.len() > 2 {
    let f = pts.first()
    let l = pts.last()
    if calc.abs(f.at(0) - l.at(0)) < 1e-9 and calc.abs(f.at(1) - l.at(1)) < 1e-9 { pts = pts.slice(0, -1) }
  }
  pts
}

#let _envelope(path, pen: none, closed: false, dash: none, pressure: none, epsilon: 0.01) = {
  assert(pen != none, message: "pen is required")
  if path.len() == 0 { return () }
  let tol = calc.max(epsilon * _PT, 0.004) * 1pt
  let dashes = if dash == none { none } else {
    let lengths = dash.at("lengths", default: dash.at("pattern", default: ()))
    nib.dashes(..lengths.map(x => _n(x) * _PT * 1pt), offset: _n(dash.at("offset", default: 0.0)) * _PT * 1pt,
      jitter: _n(dash.at("jitter", default: 0.0)) * _PT * 1pt, seed: dash.at("seed", default: 0))
  }
  let press = if pressure == none { none } else {
    nib.pressure(minimum-width: 2 * _n(pressure.minimum-axis) * _PT * 1pt, period: _n(pressure.period) * _PT * 1pt,
      seed: pressure.at("seed", default: 0))
  }
  let stops = if type(pen) == dictionary { pen.samples } else { none }
  let nibpen = if stops != none {
    nib.nibpen(..stops.map(s => {
      let (arc, sa, sb, ang) = if type(s) == dictionary { (s.at("arclength", default: 0.0), s.a, s.b, s.at("angle", default: 0deg)) } else { (s.at(0), s.at(1), s.at(2), s.at(3)) }
      (at: _n(arc) * _PT * 1pt, width: 2 * _n(sa) * _PT * 1pt, minor-width: 2 * _n(sb) * _PT * 1pt, angle: _angle(ang))
    }))
  } else {
    assert.eq(pen.len(), 3, message: "a constant pen must be (a, b, angle)")
    nib.penellipse(2 * _n(pen.at(0)) * _PT * 1pt, 2 * _n(pen.at(1)) * _PT * 1pt, angle: _angle(pen.at(2)))
  }
  let items = nib.stroke-items(_to-nib(path, closed), pen: nibpen, dash: dashes, pressure: press, tol: tol)
  let out = ()
  for it in items {
    if type(it) == dictionary and it.at("kind", default: none) == "shape" {
      for c in it.contours { if c.len() > 2 { out.push(_flatten(c)) } }
    }
  }
  out
}

/// The raw nib envelope, no CeTZ involved: cubic `path` segments
/// (canvas units) carried by `pen`, returned as a list of polygon
/// point lists. Feed it to #nib-stroke (CeTZ) or #nib-curve (native).
#let nib-envelope(path, pen: none, closed: false, dash: none, pressure: none,
                  epsilon: 0.01) = _envelope(path, pen: pen, closed: closed, dash: dash, pressure: pressure, epsilon: epsilon)

#let nib-curve(polygons, fill: black, stroke: none, fill-rule: "non-zero", ..style) = {
  let segs = ()
  for polygon in polygons {
    if polygon.len() < 3 { continue }
    let p0 = polygon.first()
    segs.push(curve.move((p0.at(0) * 1cm, p0.at(1) * 1cm)))
    for p in polygon.slice(1) {
      segs.push(curve.line((p.at(0) * 1cm, p.at(1) * 1cm)))
    }
    segs.push(curve.close(mode: "straight"))
  }
  if segs.len() == 0 { return none }
  curve(fill: fill, stroke: stroke, fill-rule: fill-rule, ..style, ..segs)
}

#let nib-line-path(start, end) = {
  let (x0, y0) = start
  let (x1, y1) = end
  (((x0, y0),
    (x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3),
    (x0 + 2 * (x1 - x0) / 3, y0 + 2 * (y1 - y0) / 3),
    (x1, y1)),)
}

/// Cubic Bézier segments for a closed axis-aligned rectangle.
#let nib-rect-path(x0, y0, x1, y1) = (
  ((x0, y0), (x0, y0), (x1, y0), (x1, y0)),
  ((x1, y0), (x1, y0), (x1, y1), (x1, y1)),
  ((x1, y1), (x1, y1), (x0, y1), (x0, y1)),
  ((x0, y1), (x0, y1), (x0, y0), (x0, y0)),
)

/// Cubic Bézier segments through a polyline.
#let polyline-path(points) = {
  let segments = ()
  for pair in points.windows(2) {
    let p0 = pair.at(0)
    let p3 = pair.at(1)
    let delta = (p3.at(0) - p0.at(0), p3.at(1) - p0.at(1))
    segments.push((
      p0,
      (p0.at(0) + delta.at(0) / 3, p0.at(1) + delta.at(1) / 3),
      (p0.at(0) + 2 * delta.at(0) / 3, p0.at(1) + 2 * delta.at(1) / 3),
      p3,
    ))
  }
  segments
}

/// A constant elliptical nib: `a` the major axis, `b` the minor axis
/// (both in canvas units, typically cm), `angle` the nib orientation
/// relative to the path tangent.
///
/// ```typ
/// #let pen = nib-pen(a: 0.030, b: 0.009)
/// ```
/// A nib outline for point lists in NATIVE Typst space (lengths, y down,
/// origin at the top-left of the local box) — the convention of the
/// `polygon`/`circle`-based families (ogeebox, numbox, ...). The result is
/// content to be placed with `place(top + left, ..)`, standing in for
/// `polygon(stroke: thickness + paint, ..pts)`.
///
/// `paint` is the stroke's own colour, so the box keeps its native palette;
/// the pen is derived from `thickness` (`thickness * 1.7` major axis)
/// unless `vintage-pen` overrides it.
#let vintage-pts(pts, paint, thickness, closed: true, vintage-pen: none) = context {
  if paint == none { return none }
  // lengths may mix units (pt + em); resolve them to plain pt via a
  // measurement, then to cm for the nib pipeline
  let c = l => (measure(box(width: l + 25cm, height: 0pt)).width - 25cm) / 1cm
  let q = pts.map(p => (c(p.at(0)), c(p.at(1))))
  let th = c(thickness)
  let pen = if vintage-pen == none { (th * 1.7, th * 0.55, 24deg) } else { vintage-pen }
  nib-curve(nib-envelope(polyline-path(q), pen: pen, closed: closed), fill: paint)
}

/// The same in the engine/mapdraw convention: points in cm, y UP, `flip`
/// the drawing height. Stands in for `polylines((pts,), flip: flip,
/// stroke: (paint: paint, thickness: thickness))`.
#let vintage-outline(pts, flip, paint, thickness: 1pt, closed: true,
                     vintage-pen: none) = context {
  if paint == none { return none }
  // lengths may mix units (pt + em); resolve them to plain pt via a
  // measurement, then to cm for the nib pipeline
  let c = l => (measure(box(width: l + 25cm, height: 0pt)).width - 25cm) / 1cm
  let Hc = c(flip)
  let q = pts.map(p => (p.at(0), Hc - p.at(1)))
  let th = c(thickness)
  let pen = if vintage-pen == none { (th * 1.7, th * 0.55, 24deg) } else { vintage-pen }
  nib-curve(nib-envelope(polyline-path(q), pen: pen, closed: closed), fill: paint)
}

/// Pre-computed nib polygons (see #nib-envelope) as a native Typst
/// `curve`. Unlike a `cetz.canvas`, the curve keeps its absolute
/// coordinates, so placing it with `place(top + left, ..)` lands it where
/// the canvas coordinates say — essential for small strokes inside a
/// bigger box (a canvas holding a single path gets re-flowed to its own
/// top-left corner).

/// Cubic Bézier segments for a straight line between two points.
#let nib-pen(a: 0.030, b: 0.009, angle: 24deg) = (a, b, angle)

/// Draw a calligraphic stroke: the envelope of an elliptical nib carried
/// along a path of cubic segments. To be used inside `cetz.canvas`.
///
/// ```typ
/// #cetz.canvas({
///   nib-stroke(nib-line-path((0, 0), (3, 0)), pen: nib-pen())
/// })
/// ```
#let nib-stroke(
  path,
  pen: none,
  closed: false,
  dash: none,
  pressure: none,
  epsilon: 0.01,
  fill: black,
  stroke: none,
) = {
  assert(pen != none, message: "pen is required")
  let polygons = _envelope(path, pen: pen, closed: closed, dash: dash, pressure: pressure, epsilon: epsilon)
  if polygons.len() == 0 {
    return ()
  }
  cetz.draw.compound-path({
    for polygon in polygons {
      cetz.draw.line(..polygon, close: true, stroke: none)
    }
  }, fill: fill, stroke: stroke, fill-rule: "non-zero")
}

/// Calligraphic strokes through one or more polylines, in `cetz.canvas`.
#let nib-polylines(
  polylines,
  pen: none,
  dash: none,
  pressure: none,
  epsilon: 0.01,
  fill: black,
  stroke: none,
) = {
  assert(pen != none, message: "pen is required")
  for points in polylines {
    if points.len() >= 2 {
      nib-stroke(
        polyline-path(points),
        pen: pen,
        dash: dash,
        pressure: pressure,
        epsilon: epsilon,
        fill: fill,
        stroke: stroke,
      )
    }
  }
}

// ---------------------------------------------------------------------------
//  engraved — the engraving shorthand
// ---------------------------------------------------------------------------

/// An engraved stroke: a nib `pen` of `(width * 1.7, width * 0.55, angle)`
/// carried along `path` (cubic segments, canvas units). Inside
/// `cetz.canvas`. The engraving shorthand.
///
/// ```typ
/// #cetz.canvas({
///   engraved(nib-line-path((0, 0), (3, 0)))
/// })
/// ```
#let engraved(
  path,
  width: 0.018,
  angle: 24deg,
  dash: none,
  pressure: none,
  epsilon: 0.004,
  ink: antique-palette.ink,
) = nib-stroke(
  path,
  pen: (width * 1.7, width * 0.55, angle),
  dash: dash,
  pressure: pressure,
  epsilon: epsilon,
  fill: ink,
)

// ---------------------------------------------------------------------------
//  page-level engraving
// ---------------------------------------------------------------------------

#let _cm(x) = x / 1cm

/// An engraved rule between two points, as page content (no canvas
/// context needed). `from` and `to` are `(x, y)` pairs in page units.
///
/// ```typ
/// #engraved-rule(from: (0pt, 0pt), to: (12cm, 0pt))
/// ```
#let engraved-rule(
  from: (0pt, 0pt),
  to: (10cm, 0pt),
  weight: 0.018,
  angle: 24deg,
  ink: antique-palette.ink,
  dash: none,
  pressure: none,
  epsilon: 0.004,
) = {
  let x0 = from.at(0)
  let y0 = from.at(1)
  let x1 = to.at(0)
  let y1 = to.at(1)
  let ox = calc.min(x0, x1)
  let oy = calc.min(y0, y1)
  block(width: calc.abs(x1 - x0), height: calc.abs(y1 - y0), {
    place(top + left, cetz.canvas(length: 1cm, {
      engraved(
        nib-line-path((_cm(x0 - ox), _cm(y0 - oy)), (_cm(x1 - ox), _cm(y1 - oy))),
        width: weight,
        angle: angle,
        dash: dash,
        pressure: pressure,
        epsilon: epsilon,
        ink: ink,
      )
    }))
  })
}

/// An engraved double-rule frame around content, with a small diamond at
/// each outer corner. The frame is one canvas, so the block does not
/// break across pages.
///
/// ```typ
/// #engraved-frame[All the text is kept on aged paper, in Garamond.]
/// ```
#let engraved-frame(
  body,
  width: 100%,
  pad: (x: 1.3em, y: 0.85em),
  gap: 3.2pt,
  weight: 0.018,
  angle: 24deg,
  ink: antique-palette.ink,
  corners: true,
  corner-size: 0.075,
) = layout(avail => {
  let W = if type(width) == ratio { avail.width * width } else { width }
  let px = measure(box(width: pad.at("x", default: 1.3em), height: 1pt)).width
  let py = measure(box(width: 1pt, height: pad.at("y", default: 0.85em))).height
  let inner-w = W - 2 * px
  let bm = measure(block(width: inner-w, body))
  let H = bm.height + 2 * py
  let o = 0.045
  let g = _cm(gap)
  let cs = corner-size
  let Wc = _cm(W)
  let Hc = _cm(H)
  block(width: W, height: H, {
    place(top + left, cetz.canvas(length: 1cm, {
      engraved(nib-rect-path(o, o, Wc - o, Hc - o), width: weight, angle: angle, ink: ink)
      engraved(
        nib-rect-path(o + g, o + g, Wc - o - g, Hc - o - g),
        width: weight * 0.72,
        angle: angle,
        ink: ink,
      )
      if corners {
        for c in ((o, o), (Wc - o, o), (Wc - o, Hc - o), (o, Hc - o)) {
          draw.line(
            (c.at(0), c.at(1) - cs),
            (c.at(0) + cs, c.at(1)),
            (c.at(0), c.at(1) + cs),
            (c.at(0) - cs, c.at(1)),
            close: true,
            fill: ink,
            stroke: none,
          )
        }
      }
    }))
    place(top + left, dx: px, dy: py, block(width: inner-w, body))
  })
})

// ---------------------------------------------------------------------------
//  plates & patents
// ---------------------------------------------------------------------------

/// A vintage plate: a full page of aged paper with a centred
/// smallcaps number, a large title and an italic subtitle, set in a
/// Garamond serif. A *show* rule:
///
/// ```typ
/// #show: plate-page.with(number: [Plate I], title: [Elementary Solids], subtitle: [surface lines])
/// ```
#let plate-page(
  body,
  title: none,
  subtitle: none,
  number: none,
  paper: antique-palette.paper,
  ink: antique-palette.ink,
  margin: (x: 20mm, y: 18mm),
  title-gap: 8mm,
  width: 210mm,
  height: 297mm,
) = {
  assert(title != none, message: "plate-page: a title is required")
  set page(width: width, height: height, margin: margin, fill: paper)
  set text(font: antique-fonts.body, size: 10pt, fill: ink)
  set par(justify: true, leading: 0.62em)
  align(center)[
    #if number != none {
      text(size: 8.5pt, tracking: 1.5pt, smallcaps(number))
      v(2pt)
    }
    #text(size: 17pt)[#title]
    #if subtitle != none {
      v(1pt)
      text(size: 9pt, style: "italic", subtitle)
    }
  ]
  v(title-gap)
  body
}

/// A vintage patent page: the office name in smallcaps against the title,
/// a number and a date on the right, an engraved full-width rule below.
/// A *show* rule:
///
/// ```typ
/// #show: patent-page.with(title: [Improvement in Pens], number: [N° 12345], date: [14 mars 1902])
/// ```
#let patent-page(
  body,
  title: none,
  subtitle: none,
  office: [United States Patent Office],
  number: none,
  date: none,
  paper: antique-palette.patent-paper,
  ink: antique-palette.patent-ink,
  margin: (top: 17mm, bottom: 18mm, left: 21mm, right: 21mm),
  width: 210mm,
  height: 297mm,
) = {
  assert(title != none, message: "patent-page: a title is required")
  set page(width: width, height: height, margin: margin, fill: paper)
  set text(font: antique-fonts.body, size: 10pt, fill: ink)
  set par(justify: true, leading: 0.62em)
  grid(
    columns: (1fr, 1fr),
    align: (left, right),
    [
      #text(size: 8pt, tracking: 1.2pt, smallcaps(office))
      #v(3pt)
      #text(size: 16pt)[#title]
      #if subtitle != none {
        v(2pt)
        text(size: 9pt, style: "italic", subtitle)
      }
    ],
    align(right)[
      #if number != none { text(size: 8pt, smallcaps(number)) }
      #if number != none and date != none { linebreak() }
      #if date != none { text(size: 8pt, date) }
    ],
  )
  v(5mm)
  line(length: 100%, stroke: (paint: ink, thickness: 0.35pt))
  v(10mm)
  body
}

/// A centred italic figure caption, in the engraved register.
#let figure-caption(body) = align(center, text(size: 8.5pt, style: "italic", body))

/// An italic canvas label on a paper-backed disc — for labelling points
/// of a drawing inside `cetz.canvas` (a label).
#let antique-label(point, body, paper: antique-palette.paper, ink: antique-palette.ink) = cetz.draw.content(
  point,
  text(size: 9pt, style: "italic", fill: ink, body),
  padding: 1pt,
  fill: paper,
)

/// A row of notes in the engraved register: smallcaps heading + text.
#let antique-notes(..items, gutter: 12mm) = grid(
  columns: (1fr,) * items.pos().len(),
  gutter: gutter,
  ..items.pos(),
)

/// One note: smallcaps heading, then the body text.
#let antique-note(heading, body) = [
  #text(size: 9pt, smallcaps(heading))
  #h(0.3em)
  #body
]
