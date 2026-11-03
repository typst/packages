// Languages: rating dots when `_resolve_rating` gives a number, else
// the `fluency` text alone (one not in `_fluency_rating`).

#import "../internal/text.typ": _field, _string_at
#import "../internal/primitives.typ": _section, _small
#import "../internal/ratings.typ": _label_row, _resolve_rating, rating

#let _languages(items, (labels, prefs, ..)) = _section(
  labels.languages,
  // Nameless entries are dropped, not a panic.
  items.filter(l => _field(l, "language") != none),
  lang => {
    let value = _resolve_rating(lang, prefs.maxRating)
    if value != none {
      rating(lang.language, value, max: prefs.maxRating)
    } else {
      _label_row(lang.language, _small(_string_at(lang, "fluency")))
    }
  },
)
