// Languages — one row per entry, label on the left and rating dots on
// the right (or a fluency string mapped to numeric via the LinkedIn
// scale in `_resolve_rating`).

#import "../internal/primitives.typ": _join_with_dividers
#import "../internal/ratings.typ": rating, _resolve_rating

#let _languages(items, labels) = if items.len() > 0 [
  == #labels.languages

  #_join_with_dividers(items, lang => block(
    breakable: false,
    rating(lang.language, _resolve_rating(lang)),
  ))
]
