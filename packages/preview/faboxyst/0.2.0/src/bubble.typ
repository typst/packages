// Comic speech bubble: ONE closed contour (ellipse + tail), no inner chord.
//
//   tail          "sw" | "se" | "nw" | "ne" | "start" | "end" | "none"
//   tail-width    base of the pointer, along the ellipse
//   tail-length   how far the tip sticks out
//   tail-at       0–1 along the bottom (or top) edge

#import "fabox.typ": is-rtl

#let _ellipse-pts(cx, cy, rx, ry, n: 48) = range(n).map(i => {
  let a = 360deg * i / n
  (cx + rx * calc.cos(a), cy + ry * calc.sin(a))
})

#let speech-bubble(
  body,
  fill: rgb("#FF8A1F"),
  ink: black,
  stroke: 2.4pt,
  width: 100%,
  height: auto,
  tail: "sw",
  tail-width: 0.85cm,
  tail-length: 0.55cm,
  tail-at: 0.22,
  gloss: true,
  size: 1.35em,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let inner = box(width: W * 0.82, inset: (x: 0.22cm, y: 0.16cm),
      align(center + horizon,
        text(size: size, weight: "bold", fill: ink, body)))
    let mh = measure(inner).height
    let bh = if height == auto { calc.max(mh + 0.28cm, 1.65cm) } else { height }
    let tw = tail-width
    let tl = tail-length
    let side = if tail == "start" { if rtl { "se" } else { "sw" } }
               else if tail == "end" { if rtl { "sw" } else { "se" } }
               else { tail }
    let down = if side == "sw" or side == "se" { tl } else { 0cm }
    let up = if side == "nw" or side == "ne" { tl } else { 0cm }
    let pad = 0.10cm
    let bw = W - 2 * pad
    let ox = pad + bw / 2
    let oy = pad + up + bh / 2
    let rx = bw / 2
    let ry = bh / 2
    let n = 56
    let raw = _ellipse-pts(ox, oy, rx, ry, n: n)
    // Angles: 0° = east, 90° = south (y down in page coords of cos/sin
    // as used above: cos(a) x, sin(a) y with a from 0, so 90deg is south).
    let (a0, a1, tip) = if side == "none" {
      (none, none, none)
    } else if side == "sw" {
      let mid = 90deg + (0.5 - tail-at) * 50deg
      (mid - 18deg, mid + 18deg,
        (ox - rx * (1.05 - tail-at * 0.4), oy + ry + tl))
    } else if side == "se" {
      let mid = 90deg - (0.5 - tail-at) * 50deg
      (mid - 18deg, mid + 18deg,
        (ox + rx * (1.05 - tail-at * 0.4), oy + ry + tl))
    } else if side == "nw" {
      let mid = -90deg - (0.5 - tail-at) * 50deg
      (mid - 18deg, mid + 18deg,
        (ox - rx * (1.05 - tail-at * 0.4), oy - ry - tl))
    } else {
      let mid = -90deg + (0.5 - tail-at) * 50deg
      (mid - 18deg, mid + 18deg,
        (ox + rx * (1.05 - tail-at * 0.4), oy - ry - tl))
    }

    let pts = if side == "none" { raw } else {
      // Widen the skipped arc to match tail-width.
      let span = (tw / (2 * rx)) * 180deg
      let mid = (a0 + a1) / 2
      let lo = mid - span
      let hi = mid + span
      let out = ()
      let inserted = false
      for i in range(n) {
        let a = 360deg * i / n
        let in-gap = {
          let x = a
          if lo < 0deg and x > 180deg { x -= 360deg }
          x >= lo and x <= hi
        }
        if in-gap {
          if not inserted {
            // enter at lo, go to tip, come back at hi
            out.push((ox + rx * calc.cos(lo), oy + ry * calc.sin(lo)))
            out.push(tip)
            out.push((ox + rx * calc.cos(hi), oy + ry * calc.sin(hi)))
            inserted = true
          }
        } else {
          out.push(raw.at(i))
        }
      }
      out
    }

    block(width: W, height: bh + down + up + 2 * pad, {
      place(top + left, polygon(fill: fill, stroke: stroke + black, ..pts))
      if gloss {
        place(top + left, dx: ox - rx * 0.55, dy: oy - ry * 0.55,
          ellipse(width: rx * 0.55, height: ry * 0.28,
            fill: white.transparentize(22%)))
        place(top + left, dx: ox - rx * 0.72, dy: oy - ry * 0.18,
          ellipse(width: 0.16cm, height: 0.16cm,
            fill: white.transparentize(28%)))
      }
      place(top + left, dx: (W - measure(inner).width) / 2,
        dy: pad + up + (bh - mh) / 2, inner)
    })
  })
}

#let joined-bubbles(
  a: [Qui ?],
  b: [Pourquoi ?],
  fill-a: rgb("#FF8A1F"),
  fill-b: rgb("#B56BFF"),
  ..rest,
) = {
  stack(spacing: 8pt,
    speech-bubble(a, fill: fill-a, tail: "sw", ..rest),
    speech-bubble(b, fill: fill-b, tail: "sw", ..rest),
  )
}

#let five-w(
  colours: (
    rgb("#7EC8E3"), rgb("#F4C430"), rgb("#7CB342"),
    rgb("#EF6C00"), rgb("#E53935"),
  ),
  labels: ([Who?], [What?], [Where?], [When?], [Why?]),
  ..rest,
) = {
  grid(columns: (1fr, 1fr), gutter: 8pt,
    speech-bubble(labels.at(0), fill: colours.at(0), tail: "sw", size: 1.1em, ..rest),
    speech-bubble(labels.at(1), fill: colours.at(1), tail: "se", size: 1.1em, ..rest),
    speech-bubble(labels.at(2), fill: colours.at(2), tail: "sw", size: 1.1em, ..rest),
    speech-bubble(labels.at(3), fill: colours.at(3), tail: "se", size: 1.1em, ..rest),
  )
  v(6pt)
  speech-bubble(labels.at(4), fill: colours.at(4), tail: "sw", size: 1.2em, ..rest)
}
