// ===========================================================================
//  faboxyst/tornpage.typ — a paper note with a fractal-torn bottom edge,
//  after the tcolorbox `tcbnote` of Ignasi (TeX.SE 586474, CC BY-SA 4.0).
//
//    #tornpage(title: [Note Title])[…]
//
//  A clean sheet — straight top and sides, sharp corners, hairline rule —
//  whose BOTTOM edge alone is hand-torn: a ragged base line (7 mm steps,
//  2 mm amplitude) refined by four passes of recursive midpoint
//  displacement (the `irregular fractal line` decoration), a soft blurred
//  shadow under the sheet, a faint papyrus mottle on the paper and a
//  bold title seated at the top centre.
// ===========================================================================

#import "fabox.typ": is-rtl
#import "antique.typ": vintage-pts
#import "engine.typ": randoms
#import "plankbox.typ": _mottle

// The torn bottom edge, from (x0, y) to (x1, y): ragged base segments
// subdivided `depth` times, each midpoint raised a random fraction of its
// segment (amplitude `amp`), Koch-style. Seeded, so stable.
#import "theme.typ": theme-state

#let _fractal-bottom(x0, x1, y, seed, amp: 0.2, seg: 0.7cm, rag: 2pt, depth: 4) = {
  let nbase = calc.max(2, int((x1 - x0) / seg) + 1)
  let per = int(calc.pow(2, depth)) + 1   // 1 rag + 2^depth - 1 midpoints
  let r = randoms(seed, nbase * per)
  let pts = ()
  for b in range(nbase) {
    let xa = x0 + (x1 - x0) * b / nbase
    let xb = x0 + (x1 - x0) * (b + 1) / nbase
    let pa = (xa, y + r.at(b * per) * rag)
    let pb = (xb, y + r.at(calc.min((b + 1) * per, nbase * per - 1)) * rag)
    let segs = ((pa, pb),)
    for l in range(depth) {
      let next = ()
      for (s, (p, q)) in segs.enumerate() {
        let k = b * per + 1 + (int(calc.pow(2, l)) - 1) + s
        let mx = (p.at(0) + q.at(0)) / 2
        let my = (p.at(1) + q.at(1)) / 2 + (r.at(k) * amp - 0.02) * (q.at(0) - p.at(0))
        next.push((p, (mx, my)))
        next.push(((mx, my), q))
      }
      segs = next
    }
    for sgm in segs { pts.push(sgm.at(0)) }
    if b < nbase - 1 { pts.push(segs.last().at(1)) }
  }
  pts
}

/// A paper note on a sheet with straight top and sides and a fractal
/// torn bottom edge, soft shadow, papyrus mottle and a centred title.
///
/// ```typ
/// #tornpage(title: [Note Title])[A paragraph or two.]
/// ```
#let tornpage(
  body,
  title: none,
  fill: auto,
  ink: auto,
  rule: auto,
  weight: 0.4pt,         // outline thickness (default 0.4pt)
  title-size: 1.4em,
  amp: 0.2,            // fractal raise, as a fraction of the segment
  seg: 0.7cm,          // ragged base step
  rag: 2pt,            // ragged base amplitude
  depth: 4,            // recursion passes of the fractal decoration
  inset: (x: 5pt, y: 5pt),
  bottom: 1em,
  width: 100%,
  height: auto,        // force the sheet's height (page frames)
  seed: auto,
  shadow: true,
  mottle: 4%,
  direction: auto,
  vintage: false,      // the sheet outline engraved with a nib
  vintage-pen: none,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let fill = if print-mode { white } else { fill }
  let ink = if print-mode { black } else { ink }
  let rule = if print-mode { black } else { rule }
  let mottle = if print-mode { 0% } else { mottle }
  if print-mode { set text(fill: black) }

  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let paper = if fill == auto { rgb("#FAF5E6") } else { fill }
  let ink-c = if ink == auto { rgb("#1A1A1A") } else { ink }
  let rule-c = if rule == auto { black } else { rule }
  let stroke-w = if weight == auto { 0.4pt } else { weight }
  let sd = if seed == auto { 23 } else { seed }
  let ix = inset.at("x", default: 5pt)
  let iy = inset.at("y", default: 5pt)

  let title-body = if title == none { none } else {
    text(fill: ink-c, weight: "bold", size: title-size, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let title-h = if title == none { 0pt } else { tm.height + iy }
  // resolve a possible em-based bottom pad to an absolute length
  let bottom-l = measure(box(width: 1pt, height: bottom)).height

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let main = block(width: W - 2 * ix, {
      set text(dir: body-dir, fill: ink-c)
      set align(start)
      body
    })
    let mh = measure(main).height
    let H = 1pt + title-h + mh + 2 * iy + bottom-l   // sheet height at the tear line

    // torn edge + shadow headroom below the tear line
    let tear = 8pt
    if height != auto {
      let Ht = if type(height) == ratio { avail.height * height } else { height }
      H = calc.max(H, Ht - tear - 8pt)
    }
    let Hb = H + tear + 8pt

    let edge = _fractal-bottom(0.5pt, W - 0.5pt, H, sd + 7,
      amp: amp, seg: seg, rag: rag, depth: depth)
    let sheet = ((0.5pt, 0.5pt), (W - 0.5pt, 0.5pt), (W - 0.5pt, H),
      ..edge.rev(), (0.5pt, H))

    block(width: W, height: Hb, {
      set text(dir: body-dir)
      if shadow {
        // ONE shadow: the sheet's silhouette, lowered, filled with a grey
        // gradient that is darkest right under the torn edge and fades out
        // towards the bottom (clear above, so the sheet itself hides it).
        let drop = 6pt
        let f0 = calc.max(0.0, calc.min(1.0, (H - 3pt) / (H + drop)))
        place(top + left, dy: drop,
          polygon(
            fill: gradient.linear(
              (black.transparentize(84%), 0%),
              (black.transparentize(84%), f0 * 100%),
              (black.transparentize(99%), 100%),
              angle: 90deg),
            ..sheet))
      }
      place(top + left,
        polygon(fill: paper, stroke: if vintage { none } else { stroke-w + rule-c }, ..sheet))
      if vintage {
        place(top + left,
          vintage-pts(sheet, rule-c, stroke-w, closed: false,
            vintage-pen: vintage-pen))
      }
      _mottle(W, H - 14pt, sd + 31, mottle)
      if title != none {
        place(top + left, dx: ix, dy: iy,
          block(width: W - 2 * ix, align(center, title-body)))
      }
      place(top + left, dx: ix, dy: iy + title-h, main)
    })
  })
}

/// French alias.
#let page-dechiree(..a) = tornpage(..a)

