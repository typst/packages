// The measure↔render font contract (TYPST_PLUGIN_PLAN.md §4.1).
//
// PreFigure emits generic font names — "serif", "sans-serif", "monospace" — but
// Typst's SVG font resolver does not support generic families: it renders
// `font-family="sans-serif"` as serif. Worse, if Typst *measured* one family and
// *rendered* another, the injected metrics would not match the drawn glyphs. So
// both sides use this map: Pass B measures the concrete family, and the plugin
// writes that same concrete family into the SVG's `font-family`. Because Typst's
// `measure()` and its embedded-SVG renderer share one font book, a family Typst
// can measure is a family it can render.
//
// Override per document via `prefigure(..., fonts: (sans-serif: "Fira Sans"))`.

#let default-font-map = (
  "serif": "New Computer Modern",
  "sans-serif": "DejaVu Sans",
  "monospace": "DejaVu Sans Mono",
)

// Merge author overrides onto the defaults. Keys are PreFigure's generic names.
#let resolve-font-map(overrides) = {
  if overrides == none { default-font-map } else {
    default-font-map + overrides
  }
}
