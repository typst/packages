// Ink effects: glyphs stay real text.
#import "../wasm.typ": texture

#let _tile = 8mm
// Few levels, few tilings in the PDF.
#let _levels = 3

#let _paint(mode, colour, cfg, ..args) = tiling(
  size: (_tile, _tile),
  texture("ink", width: _tile, height: _tile, resolution: cfg.quality.resolution * 4, seed: cfg.seed + 11, mode: mode, color: colour, ..args),
)

// Inking values. `r` in [-1, 1] varies them.
#let _params(cfg, r) = {
  let ink = cfg.ink
  let blur = 1 - ink.legibility
  (
    blur: blur,
    fade: calc.clamp(ink.fade * 0.55 * (1 + r) + blur * 0.2, 0, 0.9),
    w: ink.bleed * 0.06em * (1 + 0.35 * r) + blur * 0.03em,
    holes: calc.min(1.5, ink.wear + blur * 0.6),
  )
}

// Mixes with the paper: stroke and fill overlap.
#let _faded(paint, cfg, fade) = {
  let f = calc.round(fade * _levels) / _levels * 60%
  color.mix((paint.opacify(100%), 100% - f), (cfg.paper.color, f))
}

// Inks a text run. Gradients and tilings are left alone.
#let ink(body, cfg, r) = context {
  let ink = cfg.ink
  let fill = text.fill
  if type(fill) != color { return body }
  let (blur, fade, w, holes) = _params(cfg, r)
  if fade == 0 and blur == 0 and ink.bleed == 0 and ink.wear == 0 { return body }

  let inked = if ink.bleed > 0 or ink.wear > 0 or blur > 0 {
    let colour = _faded(fill, cfg, fade)
    set text(
      fill: _paint("fill", colour, cfg, amount: holes),
      stroke: if w > 0em { (paint: _paint("edge", colour, cfg, amount: holes, soft: blur), thickness: w, join: "round") },
    )
    body
  } else {
    text(fill: fill.transparentize(fade * 100%), body)
  }
  if not ink.ghosting { return inked }

  let o = 0.008em + blur * 0.03em + ink.bleed * 0.006em
  let ghost = fill.transparentize(calc.min(96, 88 + fade * 8 - blur * 6) * 1%)
  box({
    for (dx, dy) in ((o, 0em), (-o * 0.6, o * 0.5), (o * 0.3, -o * 0.8)) {
      place(top + left, dx: dx, dy: dy, pdf.artifact(text(fill: ghost, stroke: none, body)))
    }
    inked
  })
}

// Inks a stroke in any form. More holes than glyphs, to roughen its edges.
#let ink-stroke(s, cfg) = {
  if s == none or s == auto { return s }
  if type(s) == function { return (..args) => ink-stroke(s(..args), cfg) }
  if type(s) == array { return s.map(v => ink-stroke(v, cfg)) }
  if type(s) == dictionary and s.keys().any(k => k in ("top", "right", "bottom", "left", "x", "y", "rest")) {
    return s.pairs().map(((k, v)) => (k, ink-stroke(v, cfg))).to-dict()
  }
  let s = stroke(s)
  let paint = if s.paint == auto { black } else { s.paint }
  if type(paint) != color { return s }
  let (fade, w, holes) = _params(cfg, 0)
  if fade == 0 and w == 0em and holes == 0 { return s }
  let thickness = if s.thickness == auto { 1pt } else { s.thickness }
  stroke(
    paint: _paint("fill", _faded(paint, cfg, fade), cfg, amount: calc.min(1.3, holes * 4)),
    thickness: thickness + w / 2,
    cap: s.cap,
    join: s.join,
    dash: s.dash,
    miter-limit: s.miter-limit,
  )
}
