// Seeded irregularities, with no plugin call per glyph.
#import "ink.typ": ink, ink-stroke

#let _P = 2147483647

#let hash(..vals) = vals.pos().fold(17, (h, v) => calc.rem-euclid(h * 31 + v, _P))

#let str-hash(s) = array(bytes(s)).fold(7, (h, b) => calc.rem(h * 31 + b, _P))

// Random value in [-1, 1].
#let rnd(table, ..vals) = table.at(calc.rem(hash(..vals), table.len())) / 127.5 - 1

// Rotation of page `p`.
#let page-angle(cfg, p) = {
  let (t, s) = (cfg.table, cfg.seed)
  let k = (p - 1) / 4
  let (i, f) = (calc.floor(k), calc.fract(k))
  let walk = rnd(t, s, 101, i) * (1 - f) + rnd(t, s, 101, i + 1) * f
  let d = cfg.skew.drift
  cfg.skew.page-rotation * ((1 - d) * rnd(t, s, 102, p) + d * walk)
}

// Moves and rotates a block so the whole page looks rotated.
#let block-skew(it, cfg-at) = context {
  let pos = here().position()
  let cfg = cfg-at(pos.page)
  let pa = page-angle(cfg, pos.page)
  let a = pa
  if cfg.quality.granularity == "line" {
    a += cfg.skew.line-jitter * rnd(cfg.table, cfg.seed, pos.page, int(pos.y.pt() * 8), 103)
  }
  if a == 0deg and pa == 0deg { return it }
  let (pw, ph) = if page.flipped { (page.height, page.width) } else { (page.width, page.height) }
  let xc = if pw == auto { pos.x } else { pw / 2 }
  let yc = if ph == auto { pos.y } else { ph / 2 }
  let (x, y) = (pos.x - xc, pos.y - yc)
  let shift = (pa / 1deg) * 1.2mm
  let dx = x * (calc.cos(pa) - 1) - y * calc.sin(pa) + shift * rnd(cfg.table, cfg.seed, pos.page, 104)
  let dy = x * calc.sin(pa) + y * (calc.cos(pa) - 1) + shift * rnd(cfg.table, cfg.seed, pos.page, 105)
  move(dx: dx, dy: dy, rotate(a, origin: top + left, reflow: false, it))
}

// Marks split characters so they are not split again.
#let _mark = (lsc1: 1)

#let _shift(cfg, r1, r2, r3, body) = {
  let cj = cfg.skew.char-jitter
  let lj = cfg.skew.line-jitter
  if cj == 0pt and lj == 0deg { return body }
  box(move(dx: cj * 0.35 * r1, dy: cj * r2, rotate(lj * r3, reflow: false, body)))
}

// One typewriter strike. No box: it would add tilings and line breaks.
#let _char(cfg, k, word, i, body) = {
  let (t, s) = (cfg.table, cfg.seed)
  let r(n) = 0.6 * rnd(t, s, k, n) + 0.4 * rnd(t, s, word, i, n)
  let cj = cfg.skew.char-jitter
  let body = ink(body, cfg, rnd(t, s, word, i, 4))
  if cj == 0pt { return body }
  text(baseline: cj * r(2), body)
}

// Math glyphs are not `text`, so the whole equation is inked.
#let math-effect(it, cfg) = ink(it, cfg, rnd(cfg.table, cfg.seed, str-hash(repr(it.body)), 4))

// `show text` rule. Code strings are split into words to keep line breaks.
#let text-effect(it, cfg) = {
  if it.text.trim() == "" { return it }
  if " " in it.text.trim() { return it.text.split(" ").map(w => [#w]).join([ ]) }
  let (t, s) = (cfg.table, cfg.seed)
  let g = cfg.quality.granularity
  let h = str-hash(it.text)
  if g == "char" {
    let clusters = it.text.clusters()
    if clusters.len() == 1 {
      return context if "lsc1" in text.features { it } else { _char(cfg, h, h, 0, it) }
    }
    clusters.enumerate().map(((i, c)) => _char(cfg, str-hash(c), h, i, text(features: _mark, c))).join()
  } else if g == "word" {
    _shift(cfg, rnd(t, s, h, 1), rnd(t, s, h, 2), rnd(t, s, h, 3), ink(it, cfg, rnd(t, s, h, 4)))
  } else {
    ink(it, cfg, rnd(t, s, h, 4))
  }
}

// Inks the rules and cells of a table.
#let _table-child(c, cfg) = {
  let (f, fields) = (c.func(), c.fields())
  if f == table.header or f == table.footer {
    let children = fields.remove("children").map(x => _table-child(x, cfg))
    return f(..fields, ..children)
  }
  if f == table.hline or f == table.vline {
    return f(..fields, stroke: ink-stroke(c.at("stroke", default: 1pt + black), cfg))
  }
  if f == table.cell and c.has("stroke") {
    let body = fields.remove("body")
    return f(..fields, stroke: ink-stroke(c.stroke, cfg), body)
  }
  c
}

// `show` rule for strokes. Rebuilt, as an explicit `stroke` beats `set`.
// Our label stops re-entry. User show rules run again on the copy.
#let stroke-effect(it, cfg) = {
  let (f, fields) = (it.func(), it.fields())
  if it.at("label", default: none) == <lookscanned-inked> or (it.stroke == none and f != table) { return it }
  let _ = fields.remove("label", default: none)
  let args = if f == table { fields.remove("children").map(c => _table-child(c, cfg)) } else if f == rect { (fields.remove("body", default: none),) } else { () }
  let s = if it.stroke == auto and it.fill == none { 1pt + black } else { it.stroke }
  [#f(..fields, stroke: ink-stroke(s, cfg), ..args)<lookscanned-inked>]
}
