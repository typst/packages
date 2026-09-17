// Private state cells + colour constants. `alta()` sets the state at
// render time; helpers throughout the package read it inside every
// `context { }` block. Public presets (the `palettes` dict for the
// `_accent_state` default, plus `maps-providers`) live separately in
// `presets.typ`.

#import "presets.typ": palettes

// State cells consulted by helpers throughout the package — set once
// by `alta()` and read inside every `context { }` block downstream.
#let _body_size_state = state("alta-body-size", 10pt)
#let _accent_state = state("alta-accent", palettes.teal)
#let _max_rating_state = state("alta-max-rating", 5)

// Accent is configurable via `alta(preferences: (accent: ...))`; the
// rest are opinionated visual constants.
#let _body_colour = rgb("#666666")
#let _emphasis_colour = rgb("#2E2E2E")
#let _empty_dot_colour = rgb("#c0c0c0")
#let _divider_colour = rgb("#D1D1D1")
