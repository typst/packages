// Private state cells and colour constants. `alta()` sets the state
// once; helpers read it inside `context { }`.

#import "presets.typ": palettes

#let _body_size_state = state("alta-body-size", 10pt)
#let _accent_state = state("alta-accent", palettes.teal)
// Read only by the public `rating()` helper's default `max`; the
// languages section passes `prefs.maxRating` explicitly.
#let _max_rating_state = state("alta-max-rating", 5)

// Accent is configurable via `alta(preferences: (accent: ...))`; the
// rest are opinionated visual constants.
#let _body_colour = rgb("#666666")
#let _emphasis_colour = rgb("#2E2E2E")
#let _empty_dot_colour = rgb("#c0c0c0")
#let _divider_colour = rgb("#D1D1D1")
