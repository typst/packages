// Languages: rating dots when `_entry-rating` gives a number (a
// `custom.altacv.rating`, or a `fluency` in `_fluency-terms`), else
// the `fluency` text alone.

#import "../internal/util/fields.typ": _string-at
#import "../internal/data/cv.typ": _entry-rating, _fluency-terms
#import "../internal/primitives.typ": _divider-space
#import "../internal/components/frame.typ": _section
#import "../internal/components/ratings.typ": _rating-row

#let _languages(items, (labels, prefs, ..)) = _section(
  labels.languages,
  items,
  lang => _rating-row(
    lang.language,
    _entry-rating(lang, "fluency", _fluency-terms, prefs.max-rating),
    prefs.max-rating,
    fallback: _string-at(lang, "fluency"),
  ),
  // Short, uniform rows: the spacing without the rule.
  separator: _divider-space(),
)
