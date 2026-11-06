// Public preset dicts, re-exported from `lib.typ`. Constants only.

// Each dark enough to stay legible beside the grey body text and to
// survive a B&W photocopy as a distinct mid-tone. `teal` is the
// default.
#let palettes = (
  teal: rgb("#00796B"),
  navy: rgb("#1A3A6C"),
  crimson: rgb("#9E2A2B"),
  forest: rgb("#2E5E3A"),
  plum: rgb("#5F2A6E"),
  charcoal: rgb("#3B3B3B"),
)

// `{q}` becomes the URL-encoded `basics.location`.
#let maps-providers = (
  google: "https://www.google.com/maps?q={q}",
  apple: "https://maps.apple.com/?q={q}",
  bing: "https://www.bing.com/maps?q={q}",
  duckduckgo: "https://duckduckgo.com/?q={q}&iaxm=maps",
  osm: "https://www.openstreetmap.org/search?query={q}",
)
