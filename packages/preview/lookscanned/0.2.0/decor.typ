// Decorations: stamp, stain, scribble and highlight.
#import "wasm.typ": random-table, texture
#import "effects/jitter.typ": rnd
#import "effects/page.typ": active, over-label

// Places `body` at (x, y), or inline.
#let _at(at, body) = if at == none { body } else {
  assert(type(at) == dictionary and "x" in at and "y" in at, message: "lookscanned: at must be (x: .., y: ..), got " + repr(at))
  place(top + left, dx: at.x, dy: at.y, body)
}

/// Rubber stamp.
#let stamp(body, color: rgb("#c0392b"), angle: -12deg, size: 16pt, seed: 0, at: none) = {
  let paint = tiling(size: (8mm, 8mm), texture("ink", seed: seed + 11, width: 8mm, height: 8mm, resolution: 600, mode: "fill", color: color, amount: 1.3))
  let label = text(size: size, weight: "bold", tracking: 0.12em, fill: paint, upper(body))
  let frame = rect(
    stroke: 2.4pt + paint,
    radius: 3pt,
    inset: 3pt,
    rect(stroke: 0.8pt + paint, radius: 2pt, inset: (x: 0.7em, y: 0.45em), label),
  )
  _at(at, rotate(angle, reflow: false, box(frame)))
}

/// A stain centred on `at`. `over` paints it above the text; without `scan`, under it.
#let stain(at: none, color: rgb("#6b4423"), size: 20mm, seed: 0, over: false) = {
  let s = size * 1.4
  let img = texture("stains", seed: seed, width: s, height: s, resolution: 120, color: color, count: 1, min: size, max: size)
  let out = if over { context if active.get() { box(width: s, height: s, [#metadata(img)#over-label]) } else { img } } else { img }
  if at == none { 
    box(out) 
  } else { 
    _at((x: at.x - s / 2, y: at.y - s / 2), out) 
  }
}

/// Fake handwriting, or a scrawl without `body`.
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

#let _hl-count = counter("lookscanned-highlight")

#let _hl-key(p) = str(p.page) + ":" + str(p.x.pt()) + ":" + str(p.y.pt())

// Right edge of each line, keyed by its first word. Memoised by Typst.
#let _hl-lines(words) = {
  let out = (:)
  let (key, prev) = (none, none)
  for m in words {
    let p = m.location().position()
    let (w, h) = (m.value.width, m.value.height)
    let apart = prev == none or p.page != prev.page or p.x < prev.x - 0.1pt or p.y >= prev.bottom or p.y + h <= prev.top
    if apart { key = _hl-key(p) }
    prev = (page: p.page, x: p.x + w, top: p.y, bottom: p.y + h)
    out.insert(key, prev.x)
  }
  out
}

// One stroke per line, drawn from its first word.
#let _hl-stroke(id, t, seed, color, opacity, words) = context {
  let me = here().position()
  let right = _hl-lines(query(words)).at(_hl-key(me), default: none)
  if right == none { return }
  let k = int(me.y.pt()) + 1000 * me.page
  let r(n) = rnd(t, id, k, n)
  let em = 1em.to-absolute()
  let thick = (1.05 + 0.08 * r(1)) * em
  let h = thick / 0.8
  let centre = (0.3 + 0.05 * r(2)) * em
  let (before, after) = ((0.12 + 0.18 * r(3)) * em, (0.12 + 0.2 * r(4)) * em)
  let width = right - me.x + before + after
  let img = texture("marker", seed: seed * 7919 + id * 101 + k, width: width, height: h, resolution: 200, color: color, opacity: opacity)
  place(top + left, dx: -before, dy: measure[H].height - centre - h / 2, rotate(0.6deg * r(5), reflow: false, img))
}

/// Highlighter strokes under `body`, one per line; the text stays text.
#let highlighter(body, color: rgb("#ffe94d"), opacity: 0.55, seed: 0) = {
  _hl-count.step()
  context {
    let id = _hl-count.get().first()
    let t = random-table(seed)
    let words = label("lookscanned-hl-" + str(id))
    show regex("\\S+"): w => box({
      _hl-stroke(id, t, seed, color, opacity, words)
      context [#metadata(measure(w))#words]
      w
    })
    body
  }
}
