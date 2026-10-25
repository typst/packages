// Ink effects. Glyphs stay real text; only their paint changes: the fill
// becomes a tiling of mottled ink, the stroke a tiling of patchy ink so that
// `bleed` grows each glyph unevenly. Fading is quantised to `_levels` so only
// a few distinct tilings end up in the PDF.
#import "../wasm.typ": texture

#let _tile = 8mm
#let _levels = 3

#let _paint(mode, colour, cfg, ..args) = tiling(
  size: (_tile, _tile),
  texture("ink", width: _tile, height: _tile, resolution: cfg.quality.resolution * 4, seed: cfg.seed + 11, mode: mode, color: colour, ..args),
)

// `r` in [-1, 1] varies the inking of this run.
#let ink(body, cfg, r) = context {
  let ink = cfg.ink
  let fill = text.fill
  // Gradients and tilings are left alone.
  if type(fill) != color { return body }
  let blur = 1 - ink.legibility
  let fade = calc.clamp(ink.fade * 0.55 * (1 + r) + blur * 0.2, 0, 0.9)
  if fade == 0 and blur == 0 and ink.bleed == 0 and ink.wear == 0 { return body }

  let inked = if ink.bleed > 0 or ink.wear > 0 or blur > 0 {
    // Fade by mixing with the paper, not transparency: stroke and fill overlap.
    let f = calc.round(fade * _levels) / _levels * 60%
    let colour = color.mix((fill.opacify(100%), 100% - f), (cfg.paper.color, f))
    let w = ink.bleed * 0.06em * (1 + 0.35 * r) + blur * 0.03em
    let holes = calc.min(1.5, ink.wear + blur * 0.6)
    set text(
      fill: _paint("fill", colour, cfg, amount: holes),
      stroke: if w > 0em { (paint: _paint("edge", colour, cfg, amount: holes, soft: blur), thickness: w, join: "round") },
    )
    body
  } else {
    text(fill: fill.transparentize(fade * 100%), body)
  }
  if not ink.ghosting { return inked }

  // Ghosts are PDF artifacts (kept out of the tag tree), but simple text
  // extractors still see them: hence opt-in.
  let o = 0.008em + blur * 0.03em + ink.bleed * 0.006em
  let ghost = fill.transparentize(calc.min(96, 88 + fade * 8 - blur * 6) * 1%)
  box({
    for (dx, dy) in ((o, 0em), (-o * 0.6, o * 0.5), (o * 0.3, -o * 0.8)) {
      place(top + left, dx: dx, dy: dy, pdf.artifact(text(fill: ghost, stroke: none, body)))
    }
    inked
  })
}
