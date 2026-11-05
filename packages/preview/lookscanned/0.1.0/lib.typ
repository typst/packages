// Public API: everything defined at the top level of this file. Imports are
// aliased with `_` to stay private.
#import "presets.typ": presets
#import "wasm.typ": texture
#import "decor.typ": scribble, stain, stamp
#import "validate.typ": parse-args as _parse-args, resolve as _resolve
#import "effects/page.typ" as _page
#import "effects/jitter.typ" as _jitter

// Elements rotated as a unit. Only one level is listed, to avoid rotating a
// paragraph inside an already rotated element.
#let _blocks = selector.or(
  par,
  heading,
  list,
  enum,
  terms,
  figure,
  math.equation.where(block: true),
  raw.where(block: true),
)

/// Global show rule: `#show: lookscanned.scan.with(..)`.
///
/// - preset: preset name (see `presets`) or a dictionary of themes. Default "office-scan".
/// - intensity: 0 = no effect, 1 = preset as is, > 1 = exaggerated.
/// - seed: same seed, same rendering.
/// - ..themes: `paper`, `stains`, `ink`, `skew`, `edges`, `scanner`, `quality`
///   dictionaries; omitted keys are inherited from the preset.
#let scan(..args, body) = {
  let cfg = _resolve(_parse-args(args, "lookscanned.scan"))
  let cfg-at = p => _page.cfg-at(cfg, p)
  set page(background: _page.background(cfg), foreground: _page.foreground(cfg))
  show _blocks: it => _jitter.block-skew(it, cfg-at)
  show text: it => _jitter.text-effect(it, cfg)
  show math.equation: it => _jitter.math-effect(it, cfg)
  body
}

// Shadows the built-in `page`: must stay defined after `scan`, whose set rule
// needs the original.

/// Overrides the settings for the page(s) spanned by `body`: paper, stains,
/// edges, scanner and page rotation. Text effects (ink, char/word jitter)
/// stay those of `scan`. Same arguments as `scan`.
#let page(..args, body) = {
  let opts = _parse-args(args, "lookscanned.page")
  [#metadata(opts)#_page.start-label]
  body
  [#metadata(none)#_page.end-label]
}

/// Applies text effects to `body` on a paper-coloured, grainy block, slightly
/// rotated. Same arguments as `scan`; works without the global rule.
#let region(..args, body) = {
  let cfg = _resolve(_parse-args(args, "lookscanned.region"))
  let grain = if cfg.paper.grain > 0 or cfg.paper.fibers > 0 {
    texture("grain", seed: cfg.seed + 1, width: 40mm, height: 40mm, resolution: cfg.quality.resolution, amount: cfg.paper.grain, fibers: cfg.paper.fibers)
  }
  let fill = tiling(size: (40mm, 40mm), {
    place(rect(width: 100%, height: 100%, fill: cfg.paper.color))
    grain
  })
  let angle = cfg.skew.page-rotation * _jitter.rnd(cfg.table, cfg.seed, 7)
  show text: it => _jitter.text-effect(it, cfg)
  show math.equation: it => _jitter.math-effect(it, cfg)
  block(width: 100%, rotate(angle, reflow: false, block(width: 100%, fill: fill, inset: 0.8em, body)))
}
