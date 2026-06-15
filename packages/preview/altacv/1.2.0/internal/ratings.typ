// Language / skill fluency rendering — text label on the left, filled
// / half-filled / empty dots on the right.
//
// Half-fill (1.5 → 1 full + 1 half + 3 empty) uses a 50%/50% linear
// gradient — Typst has no native half-circle fill, and a gradient
// produces a sharp boundary where a transparent overlay wouldn't.

#import "state.typ": _body_size_state, _accent_state, _max_rating_state, _empty_dot_colour

// LinkedIn-style fluency strings. Numeric `rating` wins over `fluency`
// when an entry supplies both, so callers can opt into fractional
// precision without rewriting their data. The fluency map is fixed at
// a 0–5 scale (LinkedIn's); callers using `preferences.maxRating` for a
// non-5 scale (e.g. CEFR's 6) must pass numeric `rating` values.
#let _fluency_rating = (
  "Native":               5,
  "Bilingual":            5,
  "Full Professional":    4,
  "Professional Working": 3,
  "Limited Working":      2,
  "Elementary":           1,
)

// Resolves an entry to a rating. Type and bounds validation are
// deferred to `rating()` (which runs inside a `context` block and can
// read the configured `_max_rating_state`); this function only handles
// the numeric-vs-fluency dispatch.
#let _resolve_rating(entry) = {
  let value = entry.at("rating", default: none)  // avoid shadowing `rating()`
  if value != none { return value }
  let fluency = entry.at("fluency", default: none)
  if fluency != none {
    if type(fluency) == str and fluency in _fluency_rating { return _fluency_rating.at(fluency) }
    panic("Unknown fluency level: " + repr(fluency) + ". Provide a numeric `rating` instead, or use one of: " + _fluency_rating.keys().join(", "))
  }
  panic("Language entry needs either a numeric `rating` or a `fluency` string.")
}

#let _half_fill(accent) = gradient.linear(
  (accent, 0%),
  (accent, 50%),
  (_empty_dot_colour, 50%),
  (_empty_dot_colour, 100%),
)

#let rating(label, value) = context {
  let body-size = _body_size_state.get()
  let accent = _accent_state.get()
  let max-rating = _max_rating_state.get()
  if type(value) not in (int, float) {
    panic("Rating must be numeric, got: " + repr(value))
  }
  if value < 0 or value > max-rating {
    panic("Rating out of range: " + repr(value) + ". Expected 0–" + str(max-rating) + ".")
  }
  // Half-dot precision is the only fractional shape the renderer can
  // express (a single `_half_fill` gradient). Reject other fractions
  // up front so `3.1` and `3.9` don't both silently round to a
  // half-dot — callers either ask for a full step or a half step.
  if calc.round(value * 2) / 2 != value {
    panic("Rating must use 0.5 increments, got: " + repr(value))
  }
  let dot-radius = 0.45 * body-size
  let dot-baseline = -0.25 * body-size
  let dot-spacing = 0.4 * body-size

  text(label)
  h(1fr)
  for i in range(1, max-rating + 1) {
    let fill = if value >= i {
      accent
    } else if value > i - 1 {
      _half_fill(accent)
    } else {
      _empty_dot_colour
    }
    box(baseline: dot-baseline, circle(radius: dot-radius, fill: fill))
    if i != max-rating { h(dot-spacing) }
  }
  [\ ]
}
