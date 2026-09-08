// Pass B: measure one text run with Typst's layout engine
// (TYPST_PLUGIN_PLAN.md §4 Pass B).
//
// PreFigure's cairo path returns the ink-extent triple
//   [advance-width, height-above-baseline, depth-below-baseline].
// `measure()` only yields {width, height}, with no baseline, so the
// above/below split is recovered with the top-edge/bottom-edge idiom (the same
// one CeTZ uses): measuring "bounds→baseline" gives the ink height above the
// baseline, and "baseline→bounds" the depth below. Verified exact (error ~0) for
// a single line of pure text — which is why runs are measured one at a time and
// never as a composed multi-run line.
//
// Typst has no px unit; PreFigure's sizes are px numbers. Measuring at
// `size * 1pt` and reading `.pt()` gives numerically identical values because
// glyph metrics scale linearly. Points only meet SVG user units at embed time.
//
// MUST be called inside a `context` block (measure requires it).
//
// `inherit-font: true` (native-label mode) measures in the *ambient* document
// font instead of the run's mapped family, so the metrics match text that will
// later be rendered as native Typst content under the same `#set text`. The
// returned `family` field is left unchanged — it is only a lookup key, and must
// still agree with what the plugin's build asks for.

// `.abs.pt()` (not `.pt()`) — a plain `.pt()` panics on a length carrying an
// `em` component, and text metrics can.
#let _pt(len) = len.abs.pt()

#let measure-run(run, inherit-font: false) = {
  let base = (
    size: run.size * 1pt,
    style: if run.italic { "italic" } else { "normal" },
    weight: if run.bold { "bold" } else { "regular" },
  )
  // Omit `font:` to inherit the ambient font; otherwise pin the mapped family.
  let font-arg = if inherit-font { (:) } else { (font: run.family) }
  let styled(top, bottom) = text(
    ..base,
    ..font-arg,
    top-edge: top,
    bottom-edge: bottom,
  )[#run.text]

  // One layout pass yields both the advance width and the height above the
  // baseline; a second gives the depth below it.
  let up = measure(styled("bounds", "baseline"))
  let width = _pt(up.width)
  let above = _pt(up.height)
  let below = _pt(measure(styled("baseline", "bounds")).height)

  (
    text: run.text,
    family: run.family,
    size: run.size,
    italic: run.italic,
    bold: run.bold,
    width: width,
    above: above,
    below: below,
  )
}

// Measure one math equation (native-math mode) into the same
// [width, above, below] triple, at nominal size `size` px. MUST run inside a
// `context`.
//
// `above`/`below` must be the equation's *tight visual ink* split at its glyph
// baseline — the legend centres its key on the box they define, so getting them
// wrong slides the key off the equation's optical centre (parentheses and other
// delimiters overshoot the baseline by a few px, and that overshoot is exactly
// what must be counted).
//
// Two traps to avoid:
//   * `measure(box($eq$))` does NOT include the delimiter overshoot — it returns
//     the formula's nominal box, several px shorter than the rendered ink, with
//     the baseline at its bottom (descent reads as 0). Centring on that box puts
//     the key too high.
//   * measuring the descent *directly* (`top-edge: "baseline"`, `bottom-edge:
//     "bounds"`) over-reports it — Typst hands back the font's line descent, not
//     the ink's — which is what once made the `clear-background` box too tall.
//
// So take the full visual height (`bounds`→`bounds`, which DOES include the
// overshoot) and the ascent (`bounds`→`baseline`), and recover the descent as
// the remainder. native.typ draws the equation the mirror image of this: glyph
// baseline on the target point, descent overflowing below.
#let measure-math(eq, size: 14) = {
  let full = measure(text(
    size: size * 1pt,
    top-edge: "bounds",
    bottom-edge: "bounds",
  )[#eq])
  let up = measure(text(
    size: size * 1pt,
    top-edge: "bounds",
    bottom-edge: "baseline",
  )[#eq])
  let above = _pt(up.height)
  (
    width: _pt(full.width),
    above: above,
    below: _pt(full.height) - above,
  )
}
