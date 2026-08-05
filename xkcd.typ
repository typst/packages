// ============================================================================
//  xkcd.typ — Typst 0.15.1 + CeTZ 0.5.2 port of
//  https://tex.stackexchange.com/a/445690  (Frunobulax, CC BY-SA 4.0)
//  retrieved 2026-07-27.
//
//  The PGF `sketch` decoration is reimplemented in Rust and loaded as a
//  WASM plugin (see plugin/src/lib.rs) — including a bit-exact clone of
//  PGF's own PRNG, so `\pgfmathsetseed{1}` means the same thing here.
//
//  Build:  typst compile xkcd.typ --font-path fonts
// ============================================================================

#import "@preview/cetz:0.5.2"
#import cetz.draw: *
#import "xkcd-lib.typ": *

// The original asks for "Humor Sans"; the freely redistributable xkcd Script
// is the same design lineage and is bundled in ./fonts.
#set page(width: 17cm, height: auto, margin: 1.2cm, fill: white)
#set text(font: ("xkcd Script", "xkcd", "DejaVu Sans"), size: 11pt)
#set par(leading: 0.5em)

// fixed-point with zero fill, 2 decimals (\pgfmathprintnumber)
#let fixed2(x) = {
  let neg = x < 0
  let v = calc.round(calc.abs(x) * 100) / 100
  let i = calc.floor(v)
  let f = calc.round((v - i) * 100)
  let s = str(i) + "." + if f < 10 { "0" + str(f) } else { str(f) }
  if neg and v != 0 { "\u{2212}" + s } else { s }
}

#let thick = 1.2pt      // TikZ "very thick"
#let uthick = 1.6pt     // TikZ "ultra thick"

#align(center)[

  // ======================================================================
  //  1. Claims of supernatural powers   [xscale=4, yscale=0.05]
  // ======================================================================
  #cetz.canvas(length: 1cm, {
    let SX = 4.0
    let SY = 0.05
    let sc = (SX, SY)
    // work in TikZ's data coordinates, map to canvas by (x*SX, y*SY)
    let P(x, y) = (x * SX, y * SY)
    let opts = (:)

    // the filled bar: (0.875,1) -- ++(0,99) -- ++(0.25,0) -- +(0,-99)
    let bar = ((0.875, 1), (0.875, 100), (1.125, 100), (1.125, 1))
    let barc = bar.map(p => P(p.at(0), p.at(1)))
    // fill first (decorated outline, no stroke) ...
    xkcd-line(barc, seed: 11, closed: true, opts: opts,
      fill: pltblue, stroke: none)
    // ... then the visible outline, exactly as the original does
    xkcd-line(barc, seed: 12, opts: opts,
      stroke: (paint: black, thickness: thick))

    // axes ticks with labels
    xkcd-line((P(0, 3), P(0, 0)), seed: 13,
      stroke: (paint: black, thickness: uthick))
    content(P(0, 0), anchor: "north", padding: 0.18,
      box(width: 3cm)[#align(center)[confirmed by\ experiment]])

    xkcd-line((P(1, 3), P(1, 0)), seed: 14,
      stroke: (paint: black, thickness: uthick))
    content(P(1, 0), anchor: "north", padding: 0.18,
      box(width: 3cm)[#align(center)[refuted by\ experiment]])

    // the two axes
    xkcd-line((P(-0.5, 0), P(1.5, 0)), seed: 15,
      stroke: (paint: black, thickness: thick))
    xkcd-line((P(-0.5, 0), P(-0.5, 110)), seed: 16,
      stroke: (paint: black, thickness: thick))

    content(P(0.5, 115), text(size: 1.2em)[Claims of supernatural powers])
  })

  #v(1.4cm)

  // ======================================================================
  //  2. Stove ownership   [xscale=0.08, yscale=0.15]
  // ======================================================================
  #cetz.canvas(length: 1cm, {
    let SX = 0.08
    let SY = 0.15
    let sc = (SX, SY)
    let P(x, y) = (x * SX, y * SY)

    // axes
    xkcd-line((P(0, -30), P(100, -30)), seed: 21,
      stroke: (paint: black, thickness: thick))
    content(P(50, -30), anchor: "north", padding: 0.2)[Time]
    xkcd-line((P(0, -30), P(0, 10)), seed: 22,
      stroke: (paint: black, thickness: thick))

    // the curve
    xkcd-line((P(1, 1), P(70, 1), P(100, -28)), seed: 23,
      stroke: (paint: pltblue, thickness: thick))

    content(P(35, 12), text(size: 1.2em)[Stove ownership])
    content(P(-3, -12), angle: 90deg)[My overall health]

    // the annotation node N at (40,-8), text width 4cm
    let n-pos = P(40, -8)
    content(n-pos, box(width: 4cm)[The day I realized\ I could cook bacon\ whenever I wanted])

    // \draw[->] ($(N.north)+(5cm,0)$) -- (69.5,0.5);
    let n-north = (n-pos.at(0), n-pos.at(1) + 0.42)
    let start = (n-north.at(0) + 1.6, n-north.at(1))
    let target = P(69.5, 0.5)
    xkcd-line((start, target), seed: 24,
      stroke: (paint: black, thickness: thick),
      mark: (end: "stealth", fill: black, scale: 0.6))
  })
]

#pagebreak()

#align(center)[

  // ======================================================================
  //  3. the penciline test picture, redone in xkcd style
  // ======================================================================
  #cetz.canvas(length: 1cm, {
    // grid
    xkcd-grid((-2, -2), (4, 4), step: 1, seed: 300,
      stroke: (paint: luma(160), thickness: 0.4pt))

    // thick polyline
    xkcd-line(((0, 0), (0, 3), (3, 3)), seed: 31,
      stroke: (paint: black, thickness: 1.2pt))

    // the arc — here it really is an arc, because the sketch decoration
    // follows the path instead of replacing it with one Bezier
    xkcd-arc((1, 3), 2, 0, -90, seed: 32,
      stroke: (paint: blue, thickness: uthick))

    // hatched rectangle
    xkcd-rect((-0.4, -0.8), (1.2, -2), seed: 33,
      stroke: (paint: black, thickness: 1.2pt),
      fill: tiling(size: (4pt, 4pt))[
        #std.place(std.line(start: (0pt, 4pt), end: (4pt, 0pt), stroke: 0.4pt))
      ])

    // yellow circle node: r = sqrt(2)*inner sep, as PGF computes it
    let a-c = (2, 0)
    let a-r = calc.sqrt(2) * 0.5
    xkcd-circle(a-c, a-r, seed: 34,
      stroke: (paint: black, thickness: 0.5pt), fill: rgb(255, 255, 0))

    // red rectangle node
    let b-c = (2, -2)
    let b-h = 0.3
    xkcd-rect(
      (b-c.at(0) - b-h, b-c.at(1) - b-h),
      (b-c.at(0) + b-h, b-c.at(1) + b-h),
      seed: 35,
      stroke: (paint: black, thickness: 0.5pt), fill: rgb(255, 0, 0))

    // the b -> a edge, to[in=-45,out=45]
    {
      let s = (b-c.at(0) + b-h, b-c.at(1) + b-h)
      let e = (a-c.at(0) + a-r * calc.cos(-45deg), a-c.at(1) + a-r * calc.sin(-45deg))
      let d = 0.3915 * calc.sqrt(calc.pow(e.at(0) - s.at(0), 2) + calc.pow(e.at(1) - s.at(1), 2))
      let c1 = (s.at(0) + d * calc.cos(45deg), s.at(1) + d * calc.sin(45deg))
      let c2 = (e.at(0) + d * calc.cos(-45deg), e.at(1) + d * calc.sin(-45deg))
      xkcd-line(flatten-bezier(s, c1, c2, e), seed: 36,
        stroke: (paint: black, thickness: 0.5pt))
    }

    // empty node c
    let c-c = (-1.5, 0)
    xkcd-rect((c-c.at(0) - 0.5, c-c.at(1) - 1), (c-c.at(0) + 0.5, c-c.at(1) + 1),
      seed: 37, stroke: (paint: black, thickness: 0.5pt))

    // dashed arrow with post=lineto, post length=5mm:
    // the last 5mm run straight into the arrow head
    {
      let n = (c-c.at(0), c-c.at(1) + 1)
      let pre = ((-0.5, -0.5), (-0.5, 3.5), (n.at(0), 3.5), (n.at(0), n.at(1) + 0.5))
      xkcd-line(pre, seed: 38,
        stroke: (paint: black, thickness: 0.5pt, dash: "dashed"))
      line((n.at(0), n.at(1) + 0.5), n,
        stroke: (paint: black, thickness: 0.5pt, dash: "dashed"),
        mark: (end: "stealth", fill: black, scale: 0.5))
    }
  })

  #v(1.2cm)

  // ======================================================================
  //  4. sin(x) plot with ticks   [very thick, yscale=2]
  // ======================================================================
  #cetz.canvas(length: 1cm, {
    let SY = 2.0
    let sc = (1.0, SY)
    let P(x, y) = (x, y * SY)

    xkcd-rect(P(-0.3, -1.2), P(7.3, 1.2), seed: 41,
      stroke: (paint: black, thickness: thick))

    // y ticks: -1.00, -0.75, ... 1.00
    let k = 50
    for i in range(9) {
      let y = -1.0 + 0.25 * i
      xkcd-line((P(-0.3, y), P(-0.4, y)), seed: k,
        stroke: (paint: black, thickness: uthick))
      // \pgfmathprintnumber[fixed,fixed zerofill,precision=2]
      content(P(-0.42, y), anchor: "east",
        text(size: 0.8em)[#fixed2(y)])
      k += 1
    }

    // x ticks: 0 .. 7
    for x in range(8) {
      xkcd-line((P(x, -1.2), P(x, -1.25)), seed: k,
        stroke: (paint: black, thickness: uthick))
      content(P(x, -1.28), anchor: "north", text(size: 0.8em)[#x])
      k += 1
    }

    // \draw[domain=0:7, pltblue, samples=100] plot (\x, {sin(\x r)});
    xkcd-plot(
      x => calc.sin(x * 1rad) * SY, 0, 7, samples: 100,
      seed: 70,
      stroke: (paint: pltblue, thickness: thick))
  })
]
