// Public preset dicts re-exported from `lib.typ` as part of the
// documented API. Constants only — no logic, no state, no
// dependencies. Compile-time values that callers reference as
// `accent: palettes.navy` or `mapsProvider: maps-providers.osm`.

// Curated accent presets — each dark enough to remain legible against
// the grey body text and to survive a B&W photocopy as a distinct
// mid-tone. `teal` is the default.
#let palettes = (
  teal:     rgb("#00796B"),
  navy:     rgb("#1A3A6C"),
  crimson:  rgb("#9E2A2B"),
  forest:   rgb("#2E5E3A"),
  plum:     rgb("#5F2A6E"),
  charcoal: rgb("#3B3B3B"),
)

// Maps deep-link URL templates. `{q}` is substituted with the
// URL-encoded `basics.location` at render time.
#let maps-providers = (
  google: "https://www.google.com/maps?q={q}",
  apple: "https://maps.apple.com/?q={q}",
  bing: "https://www.bing.com/maps?q={q}",
  duckduckgo: "https://duckduckgo.com/?q={q}&iaxm=maps",
  osm: "https://www.openstreetmap.org/search?query={q}",
)
