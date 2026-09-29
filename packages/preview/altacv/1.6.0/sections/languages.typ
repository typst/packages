// Languages — one row per entry. Dots when `_resolve_rating` returns
// a number; label-only annotation when it returns `none` (free-text
// fluency outside the LinkedIn enum — canonical JSON Resume shape).

#import "../internal/text.typ": _present
#import "../internal/primitives.typ": _join_with_dividers
#import "../internal/ratings.typ": rating, _resolve_rating
#import "../internal/state.typ": _body_size_state, _body_colour

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

#let _languages(items, labels) = {
  // Nameless entries are dropped, not a panic — the filter-first
  // convention of the other sections.
  let valid = items.filter(l => _present(l.at("language", default: none)))
  if valid.len() == 0 { return }
  [
    == #labels.languages

    #_join_with_dividers(valid, lang => block(
      breakable: false,
      {
        let value = _resolve_rating(lang)
        if value != none {
          rating(lang.language, value)
        } else {
          _label_only(lang.language, lang.at("fluency", default: none))
        }
      },
    ))
  ]
}
