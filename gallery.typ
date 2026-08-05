// ---------------------------------------------------------------------------
//  gallery.typ — proof that the sketch engine is general purpose.
//  None of these are "supported shapes"; they are all just point lists.
//  Compile:  typst compile gallery.typ --font-path fonts
// ---------------------------------------------------------------------------

#import "@preview/cetz:0.5.2"
#import cetz.draw: *
#import "xkcd-lib.typ": *

#set page(width: 21cm, height: auto, margin: 1cm, fill: white)
#set text(font: ("xkcd Script", "xkcd", "DejaVu Sans"), size: 10pt)

#let title(t) = text(size: 1.15em, weight: "bold", t)

#align(center)[#title[The engine draws anything you can describe as points]]
#v(0.4cm)

// ===========================================================================
//  1. A flowchart — boxes, rounded boxes, a diamond, connectors
// ===========================================================================
#title[1. Flowchart / boxes-and-arrows diagram]
#v(2mm)
#cetz.canvas(length: 1cm, {
  let arrow = (paint: black, thickness: 1pt)

  xkcd-rounded-rect((0, 2.2), (2.6, 3.2), radius: 0.35, seed: 1,
    stroke: 1pt, fill: rgb("#e8f0fb"))
  content((1.3, 2.7))[start]

  // a diamond is just a 4-gon
  xkcd-polygon((5, 2.7), 1.15, n: 4, start: 90, seed: 2,
    stroke: 1pt, fill: rgb("#fff6d5"))
  content((5, 2.7), text(size: 0.85em)[works?])

  xkcd-rect((7.6, 2.2), (10.2, 3.2), seed: 3, stroke: 1pt, fill: rgb("#e6f7e9"))
  content((8.9, 2.7))[ship it]

  xkcd-rect((3.7, 0.1), (6.3, 1.1), seed: 4, stroke: 1pt, fill: rgb("#fde8e8"))
  content((5, 0.6))[fix it]

  xkcd-line(((2.6, 2.7), (3.85, 2.7)), seed: 5, stroke: arrow,
    mark: (end: "stealth", fill: black, scale: 0.7))
  xkcd-line(((6.15, 2.7), (7.6, 2.7)), seed: 6, stroke: arrow,
    mark: (end: "stealth", fill: black, scale: 0.7))
  content((6.9, 2.95), text(size: 0.8em)[yes])

  xkcd-line(((5, 1.55), (5, 1.1)), seed: 7, stroke: arrow,
    mark: (end: "stealth", fill: black, scale: 0.7))
  content((5.35, 1.35), text(size: 0.8em)[no])

  // feedback loop, routed by hand
  xkcd-line(((3.7, 0.6), (1.3, 0.6), (1.3, 2.2)), seed: 8, stroke: arrow,
    mark: (end: "stealth", fill: black, scale: 0.7))
})

#v(0.7cm)

// ===========================================================================
//  2. Data charts — bars, pie, scatter
// ===========================================================================
#title[2. Charts you build from your own data]
#v(2mm)
#cetz.canvas(length: 1cm, {
  // ---- bar chart -------------------------------------------------------
  let data = (2.1, 3.4, 1.5, 4.0, 2.8)
  let labels = ("a", "b", "c", "d", "e")
  for (i, v) in data.enumerate() {
    let x = i * 0.85
    xkcd-rect((x, 0), (x + 0.6, v), seed: 10 + i,
      stroke: 1pt, fill: pltblue.lighten(30%))
    content((x + 0.3, -0.3), text(size: 0.8em, labels.at(i)))
  }
  xkcd-line(((-0.2, 0), (4.5, 0)), seed: 20, stroke: 1.2pt)

  // ---- pie chart (wedges) ----------------------------------------------
  let cx = 7.2
  let parts = (35%, 25%, 22%, 18%)
  let cols = (pltblue, rgb("#e5a3a3"), rgb("#f2d472"), rgb("#a8d5b5"))
  let a = 90
  for (i, p) in parts.enumerate() {
    let sweep = 360 * (p / 100%)
    xkcd-wedge((cx, 2.0), 1.3, a, a + sweep, seed: 30 + i,
      stroke: 0.9pt, fill: cols.at(i))
    a += sweep
  }

  // ---- scatter ---------------------------------------------------------
  let ox = 10.2
  xkcd-line(((ox, 0), (ox, 4)), seed: 40, stroke: 1.2pt)
  xkcd-line(((ox, 0), (ox + 4.2, 0)), seed: 41, stroke: 1.2pt)
  let pts = ((0.6, 0.8), (1.1, 1.4), (1.7, 1.2), (2.2, 2.1), (2.6, 2.6),
             (3.1, 2.4), (3.5, 3.2), (1.4, 0.6), (2.9, 1.8), (3.8, 2.9))
  for (i, p) in pts.enumerate() {
    xkcd-circle((ox + p.at(0), p.at(1)), 0.13, seed: 50 + i,
      stroke: 0.7pt, fill: pltblue)
  }
  // trend line
  xkcd-line(((ox + 0.4, 0.6), (ox + 4.0, 3.1)), seed: 60,
    stroke: (paint: red.darken(10%), thickness: 1pt, dash: "dashed"))
})

#v(0.7cm)

// ===========================================================================
//  3. Freeform art — a little landscape, all hand-specified points
// ===========================================================================
#title[3. Freeform illustration]
#v(2mm)
#cetz.canvas(length: 1cm, {
  // sky/ground
  xkcd-line(((0, 0), (16, 0)), seed: 70, stroke: 1.2pt)

  // mountains: a jagged polyline
  xkcd-line(((0.5, 0), (2.4, 3.1), (3.6, 1.7), (4.9, 3.6), (6.8, 0)),
    seed: 71, stroke: 1.1pt, fill: rgb("#eef1f4"))
  xkcd-line(((2.4, 3.1), (2.0, 2.4), (2.75, 2.35)), seed: 72, stroke: 0.8pt)

  // sun
  xkcd-circle((13.6, 3.4), 0.75, seed: 73, stroke: 1pt, fill: rgb("#ffe680"))
  for i in range(8) {
    let a = i * 45deg
    xkcd-line((
      (13.6 + 1.0 * calc.cos(a), 3.4 + 1.0 * calc.sin(a)),
      (13.6 + 1.4 * calc.cos(a), 3.4 + 1.4 * calc.sin(a)),
    ), seed: 74 + i, stroke: 0.8pt)
  }

  // a cloud: overlapping ellipses
  for (i, c) in ((8.4, 3.2, 0.75, 0.45), (9.2, 3.45, 0.62, 0.42),
                 (9.9, 3.2, 0.7, 0.4)).enumerate() {
    xkcd-ellipse((c.at(0), c.at(1)), c.at(2), c.at(3), seed: 90 + i,
      stroke: 0.9pt, fill: white)
  }

  // rolling hills via a smooth spline through control points
  xkcd-smooth(((6.5, 0.05), (8.2, 1.2), (10.0, 0.5), (11.8, 1.5), (13.4, 0.4),
               (15.6, 1.0)), samples: 14, seed: 100, stroke: 1.1pt)

  // a tree: trunk + blob canopy
  xkcd-line(((7.4, 0), (7.4, 1.1)), seed: 101, stroke: 1.4pt)
  xkcd-circle((7.4, 1.7), 0.62, seed: 102, stroke: 1pt, fill: rgb("#bfe0c4"))

  // a bird or two (little arcs)
  xkcd-arc((11.2, 3.9), 0.28, 20, 160, seed: 103, stroke: 0.8pt)
  xkcd-arc((11.75, 3.9), 0.28, 20, 160, seed: 104, stroke: 0.8pt)
})

#v(0.7cm)

// ===========================================================================
//  4. Anything parametric — maths straight to a point list
// ===========================================================================
#title[4. Parametric curves and generated geometry]
#v(2mm)
#cetz.canvas(length: 1cm, {
  // spiral
  let spiral = range(220).map(i => {
    let t = i / 18
    (1.7 + t * 0.16 * calc.cos(t * 1rad), 1.7 + t * 0.16 * calc.sin(t * 1rad))
  })
  xkcd-line(spiral, seed: 110, stroke: (paint: pltblue, thickness: 1pt))

  // lissajous
  let liss = range(240).map(i => {
    let t = i / 239 * 2 * calc.pi
    (5.6 + 1.5 * calc.sin(3 * t * 1rad), 1.7 + 1.5 * calc.sin(4 * t * 1rad))
  })
  xkcd-line(liss, seed: 111, closed: true,
    stroke: (paint: rgb("#c0504d"), thickness: 1pt))

  // heart, r(theta)
  let heart = range(200).map(i => {
    let t = i / 199 * 2 * calc.pi
    let x = 16 * calc.pow(calc.sin(t * 1rad), 3)
    let y = (13 * calc.cos(t * 1rad) - 5 * calc.cos(2 * t * 1rad)
      - 2 * calc.cos(3 * t * 1rad) - calc.cos(4 * t * 1rad))
    (9.6 + x * 0.085, 1.75 + y * 0.085)
  })
  xkcd-line(heart, seed: 112, closed: true,
    stroke: (paint: red.darken(5%), thickness: 1pt), fill: red.lighten(75%))

  // polygons of increasing order
  for (i, n) in (3, 5, 8).enumerate() {
    xkcd-polygon((13.2 + i * 1.6, 1.7), 0.7, n: n, seed: 120 + i, stroke: 1pt)
  }
})
