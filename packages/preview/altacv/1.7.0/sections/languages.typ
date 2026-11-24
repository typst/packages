// Languages — one row per entry. Dots when `_resolve_rating` returns
// a number; label-only annotation when it returns `none` (free-text
// fluency outside the LinkedIn enum — canonical JSON Resume shape).

#import "../internal/text.typ": _present
#import "../internal/primitives.typ": _section
#import "../internal/ratings.typ": _resolve_rating, rating
#import "../internal/state.typ": _body_colour, _body_size_state

// Keep row shape in sync with `rating()` — mixed-mode rows must align.
#let _label_only(label, fluency) = context {
  let body-size = _body_size_state.get()
  text(label)
  h(1fr)
  if type(fluency) == str and fluency.len() > 0 {
    text(0.85 * body-size, fill: _body_colour, fluency)
  }
  [\ ]
}

// `prefs` is unused (the dot scale reads `maxRating` from state); it's
// accepted so every renderer shares the dispatch signature.
#let _languages(items, labels, prefs) = _section(
  labels.languages,
  // Nameless entries are dropped, not a panic — the filter-first
  // convention of the other sections.
  items.filter(l => _present(l.at("language", default: none))),
  lang => {
    let value = _resolve_rating(lang)
    if value != none {
      rating(lang.language, value)
    } else {
      _label_only(lang.language, lang.at("fluency", default: none))
    }
  },
)
