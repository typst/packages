// Public API.
#import "presets.typ": presets
#import "wasm.typ": texture
#import "decor.typ": highlighter, scribble, stain, stamp
#import "validate.typ": derive as _derive, parse-args as _parse-args, resolve as _resolve
#import "effects/page.typ" as _page
#import "effects/jitter.typ" as _jitter

// Rotated as a unit, one level only.
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

#let _rules = selector.or(line, rect, table)

/// Makes a whole document look scanned. The text stays selectable.
/// With the "page" and "line" granularities, the layout does not change.
///
/// ```typ
/// // Default preset, "office-scan".
/// #show: lookscanned.scan
///
/// // Another preset, with a fixed rendering.
/// #show: lookscanned.scan.with(preset: "photocopy", seed: 9)
///
/// // The same preset at half strength.
/// #show: lookscanned.scan.with(preset: "photocopy", intensity: 0.5)
///
/// // A preset with a few settings changed. Other settings keep the preset's value.
/// #show: lookscanned.scan.with(
///   preset: "old-paper",
///   seed: 12,
///   edges: (binding: true),
///   skew: (page-rotation: 0.6deg),
/// )
///
/// // The preset without stains, and without ink bleed.
/// #show: lookscanned.scan.with(preset: "old-paper", stains: none, ink: (bleed: none))
///
/// // A preset of your own.
/// #let mine = lookscanned.derive("fax", ink: (bleed: 0.2, ghosting: true))
/// #show: lookscanned.scan.with(preset: mine)
/// ```
///
/// - preset: name or dictionary of themes. Default "office-scan". Names are
///   "clean-scan", "office-scan", "photocopy", "fax", "typewriter", "old-paper"
///   and "phone-scan".
/// - intensity: 0 for no effect, 1 for the preset as is, more to exaggerate.
///   Default 1.
/// - seed: integer. Same seed, same rendering. Default 0.
/// - ..themes: dictionaries of settings, by theme. `none`, for a theme or a
///   key, resets it to the neutral values (no effect):
///   - paper: `color`, `grain`, `aging`, `fibers`
///   - stains: `color`, `amount`, `size`, `dust`, `scratches`
///   - ink: `bleed`, `fade`, `legibility`, `wear`, `ghosting`
///   - skew: `page-rotation`, `line-jitter`, `char-jitter`, `drift`
///   - edges: `shadow`, `vignette`, `uneven`, `binding`, `punch-holes`, `folds`,
///     `dog-ear`, `staple`, `paperclip`, `torn`
///   - scanner: `lines`, `bands`
///   - quality: `resolution`, `tile`, `granularity`
///
/// To change a few pages, use `page`. For a single block, use `region`.
#let scan(..args, body) = {
  let cfg = _resolve(_parse-args(args, "lookscanned.scan"))
  let cfg-at = p => _page.cfg-at(cfg, p)
  set page(background: _page.background(cfg), foreground: _page.foreground(cfg))
  show _blocks: it => _jitter.block-skew(it, cfg-at)
  show text: it => _jitter.text-effect(it, cfg)
  show _rules: it => _jitter.stroke-effect(it, cfg)
  show math.equation: it => _jitter.math-effect(it, cfg)
  _page.active.update(true)
  body
}

/// Returns a new preset: `preset` with some themes changed. Within a theme,
/// keys you omit keep the preset's value, unlike the dictionary `+`.
///
/// ```typ
/// #let soft-fax = lookscanned.derive("fax", ink: (bleed: 0.2))
/// #show: lookscanned.scan.with(preset: soft-fax)
/// ```
///
/// - preset: name or dictionary of themes.
/// - ..themes: dictionaries of settings, by theme, as in `scan`. `none`, for a
///   theme or a key, resets it to the neutral values.
#let derive(preset, ..themes) = _derive(preset, themes)

// Shadows the built-in `page`: keep after `scan`.

/// Overrides page effects on the pages of `body`. Same arguments as `scan`.
#let page(..args, body) = {
  let opts = _parse-args(args, "lookscanned.page")
  [#metadata(opts)#_page.start-label]
  body
  [#metadata(none)#_page.end-label]
}

/// Text effects on a single block. Same arguments as `scan`.
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
  show _rules: it => _jitter.stroke-effect(it, cfg)
  show math.equation: it => _jitter.math-effect(it, cfg)
  block(width: 100%, rotate(angle, reflow: false, block(width: 100%, fill: fill, inset: 0.8em, body)))
}
