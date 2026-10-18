// breather — adaptive line spacing around tall inline math.
//
// Typst's default text edges are `cap-height` / `baseline`, so inline
// equations that extend past them (display fractions, big operators,
// matrices, nested roots, ...) overlap neighbouring lines. Switching the
// text edges to `bounds` fixes the overlap, but doing it for *every*
// equation makes ordinary lines uneven (a mere descender in $y_p$ pushes
// lines apart). `breathe` measures each inline equation and switches to
// bounds edges only when the equation is actually tall.

// Runtime settings, so the rule can be flipped or tuned mid-document.
#let _settings = state("breather-settings", (
  enabled: true,
  threshold: 1.1em,
  only: none,
))

// Accept a single element function or name as well as an array.
#let _normalize-only(only) = {
  if only == none or type(only) == array { only } else { (only,) }
}

// Does `body` contain (at any depth) an element from `targets`?
// Targets may be element functions (math.frac) or names ("frac").
#let _matches(func, targets) = targets.any(t => {
  if type(t) == str { repr(func) == t } else { func == t }
})
#let _contains(body, targets) = {
  if _matches(body.func(), targets) { return true }
  for (_, value) in body.fields() {
    if type(value) == content and _contains(value, targets) { return true }
    if type(value) == array {
      for item in value {
        if type(item) == content and _contains(item, targets) { return true }
      }
    }
  }
  false
}

/// Give tall inline math room to breathe, document-wide.
///
/// Usage (once, at the top of the document):
/// ```typ
/// #import "@preview/breather:0.1.0": breathe, breathe-on, breathe-off
/// #show: breathe
/// ```
///
/// - threshold (length): inline equations taller than this get their line
///   spacing corrected; shorter ones are left untouched so regular lines
///   keep perfectly even leading. Em values resolve against the text size
///   at the equation. Default `1.1em` sits just above the height of plain
///   inline math with ascenders and descenders.
/// - only (none, array, function, str): which equations are checked.
///   Targets are element functions or their names.
///   `none` checks every inline equation. Pass element functions or names
///   (a single one or an array) to restrict the check to equations
///   containing at least one of them, e.g. `only: math.frac` or
///   `only: ("frac", "mat", "binom")`.
/// - enabled (bool): initial state of the rule, handy as a template flag:
///   `#show: breathe.with(enabled: breath)`. When off the rule
///   short-circuits and costs nothing.
/// - body (content): the rest of the document (provided by `#show:`).
#let breathe(threshold: 1.1em, only: none, enabled: true, body) = {
  _settings.update((
    enabled: enabled,
    threshold: threshold,
    only: _normalize-only(only),
  ))
  show math.equation.where(block: false): it => context {
    let s = _settings.get()
    // Measure with bounds edges: a plain `measure(it)` reports the frame
    // height derived from the font's text edges, not the actual ink —
    // a two-row matrix measures ~0.9em while drawing ~1.8em of ink.
    let bounded = {
      set text(top-edge: "bounds", bottom-edge: "bounds")
      it
    }
    if (
      s.enabled
        and (s.only == none or _contains(it.body, s.only))
        and measure(bounded).height > s.threshold.to-absolute()
    ) {
      bounded
    } else {
      it
    }
  }
  body
}

/// Re-enable the rule from this point on. `threshold` and `only` default
/// to `auto`, meaning "keep the current value"; pass explicit values to
/// change them: `#breathe-on(threshold: 1.4em, only: math.frac)`,
/// `#breathe-on(only: none)` to go back to checking every equation.
#let breathe-on(threshold: auto, only: auto) = _settings.update(s => (
  enabled: true,
  threshold: if threshold == auto { s.threshold } else { threshold },
  only: if only == auto { s.only } else { _normalize-only(only) },
))

/// Disable the rule from this point on (until the next `breathe-on()`).
#let breathe-off() = _settings.update(s => (
  enabled: false,
  threshold: s.threshold,
  only: s.only,
))
