// A label and a row of dots on a scale, or the label with a text in
// their place: the public `rating`, and `_rating-row` over it.
//
// A half dot is a hard-stop gradient: Typst has no half-circle fill,
// and a gradient gives a sharper edge than a transparent overlay.

#import "../design/styles.typ": _inline, _part
#import "../context.typ": _max-rating-state, _theme
#import "../util/checks.typ": (
  _check, _check-rating, _check-type, _positive-int-rule,
)

#let _half-fill(accent, border) = gradient.linear(
  (accent, 0%),
  (accent, 50%),
  (border, 50%),
  (border, 100%),
)

// A label with `trailing` pushed to the right edge, then a line
// break: the row every language renders, dots or not. A strut of
// `rating.row-height`, centred as the dots are, gives every row the
// same height, so mixed rows align. `theme` is the one the caller
// read in context.
#let _label-row(theme, label, trailing) = {
  _inline(box(height: theme.rating.row-height * 1em))
  _part("rating-label", label)
  h(1fr)
  trailing
  [\ ]
}

// `value` as `max` dots: filled, half-filled, then empty. Each dot is
// centred on its own (`_inline`), so a long row can still break
// between dots. Each is a `_part` by its state (see `_glyph`).
// Unchecked: `rating` checks its arguments, and `_read-cv` the CV's
// ratings.
#let _rating-dots(value, max) = context {
  let theme = _theme()
  let (accent, border, ..) = theme.colours
  let (radius, gap, ..) = theme.rating
  let fills = (
    full: accent,
    half: _half-fill(accent, border),
    empty: border,
  )
  // A show rule may replace a dot with a glyph, which takes the text
  // fill: the dot's colour, the accent for a half (the glyph draws its
  // own half).
  let dot(state) = _inline(box({
    set circle(fill: fills.at(state))
    set text(fill: if state == "empty" { border } else { accent })
    _part("rating-" + state, circle(radius: radius * text.size))
  }))
  range(1, max + 1)
    .map(i => dot(
      if value >= i { "full" } else if value > i - 1 { "half" } else {
        "empty"
      },
    ))
    .join(h(gap * text.size))
}

/// A label with a row of rating dots at the right edge: filled,
/// half-filled, then empty. A text value takes the dots' place, the row
/// as tall as the dots'; `none` leaves the label alone on its row.
///
/// - label (content, str): The row's label.
/// - value (int, float, str, content, none): The rating, from 0 to
///   `max`, in steps of 0.5; or a text (`"Conversational"`) shown as
///   written.
/// - max (auto, int): The dots in the row; `auto` is the
///   `max-rating` of the last `alta()` before it, else 5.
/// -> content
#let rating(label, value, max: auto) = {
  // An explicit `max` is checked whatever the value; `auto` reads the
  // state, validated as `max-rating`.
  if max != auto { _check("rating() max", max, _positive-int-rule) }
  _check-type(
    "rating value",
    value,
    (int, float, str, content, type(none)),
    "a number, a string, content or none",
  )
  context if type(value) in (int, float) {
    let max-rating = if max == auto { _max-rating-state.get() } else { max }
    _check-rating("rating value", value, max-rating)
    _label-row(_theme(), label, _rating-dots(value, max-rating))
  } else {
    _label-row(_theme(), label, value)
  }
}

// `value` as dots on a scale of `max` or, with no `value`, the
// `fallback` text in their place: a skill level's mark.
#let _rating-mark(value, max, fallback: none) = if value != none {
  _rating-dots(value, max)
} else { fallback }

// The label's rating as dots on a scale of `max` or, with no `value`,
// the `fallback` text in their place.
#let _rating-row(label, value, max, fallback: none) = rating(
  label,
  if value != none { value } else { fallback },
  max: max,
)
