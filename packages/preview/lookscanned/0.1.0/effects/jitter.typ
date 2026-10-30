// Seeded geometric irregularities. Randomness comes from the plugin's table,
// indexed by cheap hashes, so no plugin call happens per glyph.
#import "ink.typ": ink

#let _P = 2147483647

#let hash(..vals) = vals.pos().fold(17, (h, v) => calc.rem-euclid(h * 31 + v, _P))

#let str-hash(s) = array(bytes(s)).fold(7, (h, b) => calc.rem(h * 31 + b, _P))

// Random value in [-1, 1] for the given integers.
#let rnd(table, ..vals) = table.at(calc.rem(hash(..vals), table.len())) / 127.5 - 1

// Rotation of page `p`. `drift` blends an independent draw with a value that
// wanders slowly from page to page.
#let page-angle(cfg, p) = {
  let (t, s) = (cfg.table, cfg.seed)
  let k = (p - 1) / 4
  let (i, f) = (calc.floor(k), calc.fract(k))
  let walk = rnd(t, s, 101, i) * (1 - f) + rnd(t, s, 101, i + 1) * f
  let d = cfg.skew.drift
  cfg.skew.page-rotation * ((1 - d) * rnd(t, s, 102, p) + d * walk)
}

// Moves and rotates a block so that, together with all other blocks of the
// page, it looks like the whole page was rotated around its centre. The flow
// is untouched: `move` and `rotate(reflow: false)` do not affect layout.
// Typst has no per-line hook, so "line" granularity jitters per block; with
// "word", `line-jitter` rotates each word instead.
#let block-skew(it, cfg-at) = context {
  let pos = here().position()
  let cfg = cfg-at(pos.page)
  let pa = page-angle(cfg, pos.page)
  let a = pa
  if cfg.quality.granularity == "line" {
    a += cfg.skew.line-jitter * rnd(cfg.table, cfg.seed, pos.page, int(pos.y.pt() * 8), 103)
  }
  if a == 0deg and pa == 0deg { return it }
  let xc = page.width / 2
  let yc = if page.height == auto { pos.y } else { page.height / 2 }
  let (x, y) = (pos.x - xc, pos.y - yc)
  // Whole page also shifts a little, proportionally to its rotation.
  let shift = (pa / 1deg) * 1.2mm
  let dx = x * (calc.cos(pa) - 1) - y * calc.sin(pa) + shift * rnd(cfg.table, cfg.seed, pos.page, 104)
  let dy = x * calc.sin(pa) + y * (calc.cos(pa) - 1) + shift * rnd(cfg.table, cfg.seed, pos.page, 105)
  move(dx: dx, dy: dy, rotate(a, origin: top + left, reflow: false, it))
}

// Marks characters produced by the char split (a style, read back with
// context), so the text show rule does not split them again. Unknown
// OpenType features are ignored by shaping.
#let _mark = (lsc1: 1)

#let _shift(cfg, r1, r2, r3, body) = {
  let cj = cfg.skew.char-jitter
  let lj = cfg.skew.line-jitter
  if cj == 0pt and lj == 0deg { return body }
  box(move(dx: cj * 0.35 * r1, dy: cj * r2, rotate(lj * r3, reflow: false, body)))
}

// Typewriter: each key has its own bias (`k`), each strike its own variation.
// No box: a boxed char or word gets its own ink tilings (PDF pattern objects
// per box), and spacing would add line-break opportunities inside words. A
// baseline shift is only a style, so it moves the char without either.
#let _char(cfg, k, word, i, body) = {
  let (t, s) = (cfg.table, cfg.seed)
  let r(n) = 0.6 * rnd(t, s, k, n) + 0.4 * rnd(t, s, word, i, n)
  let cj = cfg.skew.char-jitter
  let body = ink(body, cfg, rnd(t, s, word, i, 4))
  if cj == 0pt { return body }
  text(baseline: cj * r(2), body)
}

// Math letters and symbols are not `text` elements, so the ink is set on the
// whole equation. Digits and upright runs still reach `text-effect`, which
// finds a tiling fill and leaves their paint alone.
#let math-effect(it, cfg) = ink(it, cfg, rnd(cfg.table, cfg.seed, str-hash(repr(it.body)), 4))

// The `show text` rule: ink on every run, plus word or char jitter.
#let text-effect(it, cfg) = {
  if it.text.trim() == "" { return it }
  // Strings from code (`#lorem`, `#"a b"`) arrive as one run: split into
  // words so boxes never prevent line breaks. Each word re-enters this rule.
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
