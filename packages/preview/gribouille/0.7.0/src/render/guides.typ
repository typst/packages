// Axis and theta guide readers: normalise `guide-axis*` / `guide-axis-theta`
// specs off the plot spec into the flat shapes the render submodules consume.

#import "../utils/margin.typ": length-to-cm
#import "../theme/theme.typ": _text-style
#import "../utils/errors.typ": fail, fail-enum, fail-range

// Normalise a single `guide-axis*` spec to the flat shape consumers expect.
// Always carries a `stack` flag so callers can branch on the same field
// regardless of whether the guide originated from a stack or stand-alone.
// `default-angle` (degrees, from the axis-text theme element) applies when the
// guide leaves `angle` at its `0` default, so `guide-axis(angle:)` overrides
// the theme but the theme still drives rotation on its own.
// Tick labels hang off the axis they label, and the anchor that hangs them
// there, plus the depth reserved for them, are both quarter-turn geometry.
// Past a quarter turn the text also reads upside down, so the rotation is
// bounded rather than silently mis-hung.
#let _check-axis-angle(angle, scope: "guide-axis") = {
  if angle < -90 or angle > 90 {
    fail-range(
      scope,
      "angle",
      angle,
      -90,
      90,
      lo-open: false,
      hi-open: false,
      hint: (
        "tick labels read upside down past a quarter turn; the same bound "
          + "applies to the `angle` of an `axis-text` theme element"
      ),
    )
  }
  angle
}

#let _normalise-axis-guide(g, default-angle) = {
  let angle = g.at("angle", default: 0)
  (
    angle: _check-axis-angle(if angle != 0 { angle } else { default-angle }),
    n-dodge: calc.max(1, g.at("n-dodge", default: 1)),
    logticks: g.at("logticks", default: false),
    stack: false,
  )
}

// Read a `guide-axis(...)` or `guide-axis-stack(...)` configuration off the
// plot spec. Single guides flatten to `(angle, n-dodge, logticks, stack)`;
// stacks add `(guides, spacing)` plus aggregate fields so flat (non-stack)
// callers (label-anchor, log-minors) still see a sensible single-row view.
#let _read-axis-guide(spec, aes, default-angle: 0) = {
  let g = spec.at("guides", default: (:)).at(aes, default: none)
  let flat = (
    angle: _check-axis-angle(default-angle),
    n-dodge: 1,
    logticks: false,
    stack: false,
  )
  if g == none {
    return (..flat, suppress: false)
  }
  // `guides(x: none)` binds the suppress marker: hide this axis's ticks and
  // labels while keeping the flat shape consumers expect.
  if g.at("suppress", default: false) {
    return (..flat, suppress: true)
  }
  if not g.at("stack", default: false) {
    return (.._normalise-axis-guide(g, default-angle), suppress: false)
  }
  let subs = g.guides.map(s => _normalise-axis-guide(s, default-angle))
  if subs.len() == 0 {
    fail(
      "guide-axis-stack",
      "requires at least one sub-guide; got an empty list",
    )
  }
  (
    angle: subs.first().angle,
    n-dodge: subs.map(s => s.n-dodge).sum(),
    logticks: subs.any(s => s.logticks),
    stack: true,
    guides: subs,
    spacing: length-to-cm(g.at("spacing", default: 4pt), 0),
    suppress: false,
  )
}

// Tick-label rotation in degrees read off the `axis-text` theme element for
// the given aesthetic, used as the `guide-axis(angle:)` default so a theme can
// rotate tick labels on its own.
#let _axis-text-angle(theme, aes) = {
  let a = _text-style(theme, "axis-text-" + aes).angle
  if a == none { 0 } else { a.deg() }
}

// Cap trim is a small wedge at the named axis-arc end, capped at 2° so it
// stays a visible-but-modest "fade" no matter how wide the theta sweep is.
#let _THETA-CAP-FRAC = 0.02
#let _THETA-CAP-MAX-RAD = calc.pi / 90
#let _THETA-CAP-VALUES = ("none", "both", "upper", "lower")

// Read a `guide-axis-theta(...)` configuration off the plot spec. Returns
// `none` when no theta guide is bound so the radial renderer keeps its
// spoke-only path (no theta guide).
#let _read-theta-guide(spec) = {
  let g = spec.at("guides", default: (:)).at("theta", default: none)
  if g == none { return none }
  // `guides(theta: none)` binds the suppress marker: hide the theta axis (arc,
  // minor ticks, and tick labels) while the spokes stay.
  if g.at("suppress", default: false) {
    return (angle: 0, minor-ticks: false, cap: "none", suppress: true)
  }
  let cap = g.at("cap", default: "none")
  if not _THETA-CAP-VALUES.contains(cap) {
    fail-enum("guide-axis-theta", "cap", cap, _THETA-CAP-VALUES)
  }
  (
    // An angular tick label hangs off the arc the way a cartesian one hangs
    // off its edge, so it takes the same quarter-turn bound: past it the text
    // reads upside down whichever axis it labels.
    angle: _check-axis-angle(
      g.at("angle", default: 0),
      scope: "guide-axis-theta",
    ),
    minor-ticks: g.at("minor-ticks", default: false),
    cap: cap,
    suppress: false,
  )
}

// Whether `guides(r: none)` suppresses the radial axis. There is no
// `guide-axis-r`, so `r` only meaningfully takes `none`; any other value reads
// as not suppressed.
#let _read-r-guide(spec) = {
  let g = spec.at("guides", default: (:)).at("r", default: none)
  (suppress: g != none and g.at("suppress", default: false))
}
