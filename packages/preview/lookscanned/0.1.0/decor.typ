// Decorative elements: rubber stamp, stain, approximate handwriting.
#import "wasm.typ": random-table, texture
#import "effects/jitter.typ": rnd

// Places `body` at `at` (x, y relative to the container) or returns it inline.
#let _at(at, body) = if at == none { body } else {
  assert(type(at) == dictionary and "x" in at and "y" in at, message: "lookscanned: at must be (x: .., y: ..), got " + repr(at))
  place(top + left, dx: at.x, dy: at.y, body)
}

/// Rubber stamp: framed capitals, unevenly inked, slightly rotated.
#let stamp(body, color: rgb("#c0392b"), angle: -12deg, size: 16pt, seed: 0, at: none) = {
  let label = text(size: size, weight: "bold", tracking: 0.12em, fill: color, upper(body))
  let frame = rect(
    stroke: 2.4pt + color,
    radius: 3pt,
    inset: 3pt,
    rect(stroke: 0.8pt + color, radius: 2pt, inset: (x: 0.7em, y: 0.45em), label),
  )
  let inked = context {
    let s = measure(frame)
    // Paper-coloured holes from the toner texture: patchy rubber ink.
    box(width: s.width, height: s.height, {
      frame
      place(top + left, texture("toner", seed: seed, width: s.width, height: s.height, resolution: 200, amount: 0.9, color: white))
    })
  }
  _at(at, rotate(angle, reflow: false, box(inked)))
}

/// A single stain of `size` centred on `at` (or inline when `at` is none).
#let stain(at: none, color: rgb("#6b4423"), size: 20mm, seed: 0) = {
  let s = size * 1.4
  let img = texture("stains", seed: seed, width: s, height: s, resolution: 120, color: color, count: 1, min: size, max: size)
  if at == none { box(img) } else { _at((x: at.x - s / 2, y: at.y - s / 2), img) }
}

/// Approximate handwriting. With a body: wobbly italic text. Without: a
/// scrawl (signature, crossing out) of the given `width`.
#let scribble(body: none, color: blue, width: 4cm, seed: 0, angle: -3deg, at: none) = {
  let t = random-table(seed)
  assert(body == none or type(body) == str, message: "lookscanned.scribble: body must be a string")
  let out = if body != none {
    let chars = body.clusters().enumerate().map(((i, c)) => {
      box(move(dy: 0.08em * rnd(t, i, 1), rotate(4deg * rnd(t, i, 2), reflow: false, c)))
    })
    text(style: "italic", fill: color, chars.join())
  } else {
    let n = 14
    let h = width / 6
    let step = width / n
    let pts = range(1, n + 1).map(i => (i * step + step * 0.9 * rnd(t, i, 3), h * 0.5 * (1 + rnd(t, i, 4))))
    box(width: width, height: h, curve(
      stroke: (paint: color, thickness: 0.9pt, cap: "round", join: "round"),
      curve.move((0pt, h / 2)),
      ..pts.enumerate().map(((i, p)) => curve.cubic(auto, (p.at(0) - step * 0.6, p.at(1) - h * 0.6 * rnd(t, i, 5)), p)),
    ))
  }
  _at(at, rotate(angle, reflow: false, box(out)))
}
