// theme.typ - Theme system for primaviz
//
// Golden-ratio proportional scaling: two seed values (base-size, base-gap)
// drive all font sizes and spacing through φ-powers. Users can override
// any individual property, or change the seeds to scale everything at once.

// Global theme state — set via with-theme(), read by chart functions
#let _primaviz-theme = state("primaviz-theme", none)

// Golden ratio constant
#let _phi = 1.618
#let _sqrt-phi = calc.sqrt(_phi)

/// Derives a complete theme from two seed values using golden-ratio scaling.
///
/// Font scale (base-size × φ^power):
///   φ^0    = 1.00×  axis-label-size, value-label-size
///   φ^0.5  = 1.27×  axis-title-size, legend-size
///   φ^1    = 1.62×  title-size
///
/// Spacing scale (base-gap × φ^power):
///   φ^-1   = 0.62×  bar-gap, cell-gap
///   φ^-0.5 = 0.79×  tick-length, label-offset
///   φ^0    = 1.00×  axis-label-gap, axis-title-gap, element-size
///   φ^0.5  = 1.27×  title-gap, container-inset
///   φ^1    = 1.62×  legend-gap
///   φ^1.5  = 2.06×  legend-swatch-size
///   φ^2    = 2.62×  axis-padding-top, axis-padding-right
///   φ^3    = 4.24×  axis-padding-bottom
///   φ^4    = 6.85×  axis-padding-left
///
/// Stroke scale (base-size × ratio):
///   ×0.0625  stroke-thin  (0.5pt @ 8pt) — axes, grid, markers
///   ×0.125   stroke-mid   (1.0pt @ 8pt) — separators, annotations
///   ×0.1875  stroke-thick (1.5pt @ 8pt) — lines, stems, arms
///   ×0.3125  stroke-heavy (2.5pt @ 8pt) — bump lines, emphasis
#let _derive-theme(base-size, base-gap) = {
  let phi2 = _phi * _phi
  let phi3 = phi2 * _phi
  let phi4 = phi3 * _phi
  let inv-phi = 1.0 / _phi
  let inv-sqrt-phi = 1.0 / _sqrt-phi
  (
    // Seeds
    base-size: base-size,
    base-gap: base-gap,

    // Palette
    palette: (
      rgb("#4e79a7"), rgb("#f28e2b"), rgb("#e15759"), rgb("#76b7b2"),
      rgb("#59a14f"), rgb("#edc948"), rgb("#b07aa1"), rgb("#ff9da7"),
      rgb("#9c755f"), rgb("#bab0ac"),
    ),

    // Font scale — golden ratio from base-size
    axis-label-size: base-size,
    axis-title-size: base-size * _sqrt-phi,
    value-label-size: base-size * _sqrt-phi,
    legend-size: base-size * _sqrt-phi,
    title-size: base-size * _phi,
    title-weight: "bold",

    // Spacing scale — golden ratio from base-gap
    bar-gap: base-gap * inv-phi,               // gap between grouped bars
    cell-gap: base-gap * inv-phi,               // heatmap/waffle cell gap
    cell-size: base-gap * phi3,                 // heatmap cell size (≈25pt @ 6pt)
    tick-length: base-gap * inv-sqrt-phi,       // axis tick mark length
    label-offset: base-gap * inv-sqrt-phi,      // label-to-element spacing
    axis-label-gap: base-gap,                   // gap between axis and tick labels
    axis-title-gap: base-gap,                   // gap between tick labels and axis title
    element-size: base-gap,                     // base dot/marker size
    container-inset: base-gap * _sqrt-phi,      // chart container padding
    title-gap: base-gap * _sqrt-phi,
    legend-gap: base-gap * _phi,
    legend-swatch-size: base-gap * _phi * _sqrt-phi,
    axis-padding-top: base-gap * phi2,
    axis-padding-right: base-gap * phi2,
    axis-padding-bottom: base-gap * phi3,
    axis-padding-left: base-gap * phi4,

    // Stroke scale — proportional to base-size
    stroke-thin: base-size * 0.0625,            // 0.5pt @ 8pt
    stroke-mid: base-size * 0.125,              // 1.0pt @ 8pt
    stroke-thick: base-size * 0.1875,           // 1.5pt @ 8pt
    stroke-heavy: base-size * 0.3125,           // 2.5pt @ 8pt

    // Non-scaled properties
    tick-count: 5,
    tick-digits: auto,  // auto-detect from step size, or set to int for explicit control
    number-format: "auto",
    axis-stroke: 0.5pt + black,
    grid-stroke: 0.5pt + luma(230),
    show-grid: false,
    legend-position: "bottom",
    marker-stroke: 0.5pt + white,
    text-color: black,
    text-color-light: luma(130),
    text-color-inverse: white,
    background: none,
    border: none,
    border-radius: base-gap,
    rotated-threshold: 8,  // number of x-axis labels before auto-rotating to save space
  )
}

// Default theme — derived from base seeds
#let default-theme = _derive-theme(8pt, 6pt)

// Keys whose values are derived from seeds — used to detect explicit overrides
#let _seed-derived-keys = (
  "axis-label-size", "axis-title-size", "value-label-size", "legend-size", "title-size",
  "axis-label-gap", "axis-title-gap", "title-gap", "legend-gap", "legend-swatch-size",
  "axis-padding-top", "axis-padding-right", "axis-padding-bottom", "axis-padding-left",
  "bar-gap", "cell-gap", "cell-size", "tick-length", "label-offset", "element-size", "container-inset",
  "stroke-thin", "stroke-mid", "stroke-thick", "stroke-heavy",
  "border-radius",
)

/// Merges a user's partial theme dictionary onto the default theme.
/// Custom keys not in default-theme are preserved (passthrough).
/// An optional `overrides` dictionary is applied after the user theme,
/// useful for per-chart parameter overrides (e.g., `show-grid: true`).
///
/// - user-theme (none, dictionary): Partial theme overrides; `none` returns the default theme
/// - overrides (none, dictionary): Additional per-call overrides applied last
/// -> dictionary
#let resolve-theme(user-theme, overrides: none) = {
  let result = (:)
  for (key, val) in default-theme {
    if user-theme != none and key in user-theme {
      result.insert(key, user-theme.at(key))
    } else {
      result.insert(key, val)
    }
  }
  // Passthrough: preserve custom keys not in default-theme
  if user-theme != none {
    for (key, val) in user-theme {
      if key not in result { result.insert(key, val) }
    }
  }
  if overrides != none {
    for (key, val) in overrides {
      result.insert(key, val)
    }
  }
  result
}

/// Builds a primaviz theme dictionary from a JSON tokens object.
/// Expects keys: `palette` (array of hex strings), `text-color`, `text-color-light`,
/// `text-color-inverse`, `background` (hex or null), `border-color`, `border-radius` (number in pt).
/// Unknown keys are preserved as custom passthrough keys.
///
/// - tokens (dictionary): Parsed JSON tokens object
/// -> dictionary
#let theme-from-json(tokens) = {
  let pal = tokens.at("palette", default: ()).map(c => rgb(c))
  let bg = tokens.at("background", default: none)
  let bg = if bg != none and type(bg) == str { rgb(bg) } else { none }
  let border-hex = tokens.at("border-color", default: "#ddd")
  let radius = tokens.at("border-radius", default: 4)

  let theme = (
    palette: if pal.len() > 0 { pal } else { default-theme.palette },
    text-color: if "text-color" in tokens { rgb(tokens.text-color) } else { default-theme.text-color },
    text-color-light: if "text-color-light" in tokens { rgb(tokens.at("text-color-light")) } else { default-theme.text-color-light },
    text-color-inverse: if "text-color-inverse" in tokens { rgb(tokens.at("text-color-inverse")) } else { default-theme.text-color-inverse },
    background: bg,
    border: 0.75pt + rgb(border-hex),
    axis-stroke: 0.5pt + rgb(border-hex),
    grid-stroke: 0.3pt + rgb(border-hex),
    show-grid: true,
    border-radius: radius * 1pt,
  )

  // Passthrough: preserve any extra keys from tokens
  for (key, val) in tokens {
    if key not in theme and key != "palette" and key != "border-color" and key != "border-radius" {
      theme.insert(key, val)
    }
  }

  resolve-theme(theme)
}

/// Context-aware theme resolver — reads from state when user-theme is none.
/// When user-theme is provided, it merges onto the global state (set via
/// `with-theme`) rather than replacing it, so partial overrides like
/// `theme: (show-grid: true)` inside a `with-theme` block work correctly.
///
/// If `base-size` or `base-gap` are set, all φ-derived properties are
/// recomputed from the new seeds — unless individually overridden.
///
/// Custom keys not in default-theme are preserved (passthrough).
/// Must be called inside a `context` block.
///
/// - user-theme (none, dictionary): Explicit theme overrides (merged onto global state)
/// - overrides (none, dictionary): Additional per-call overrides
/// -> dictionary
#let _resolve-ctx(user-theme, overrides: none) = {
  let global = _primaviz-theme.get()  // may be none

  // Step 1: Determine seed values from highest-priority source
  let bs = default-theme.base-size
  let bg = default-theme.base-gap
  for source in (global, user-theme, overrides) {
    if source != none {
      if "base-size" in source { bs = source.at("base-size") }
      if "base-gap" in source { bg = source.at("base-gap") }
    }
  }

  // Step 2: Compute seed-derived defaults
  let result = _derive-theme(bs, bg)

  // Step 3: Apply explicit overrides from each source layer.
  // For seed-derived keys, only apply if the value differs from the
  // default-theme value (meaning it was explicitly set, not inherited).
  for source in (global, user-theme, overrides) {
    if source != none {
      for (key, val) in source {
        if key == "base-size" or key == "base-gap" { continue }
        if key in _seed-derived-keys {
          // Only apply if explicitly different from default
          if key not in default-theme or val != default-theme.at(key) {
            result.insert(key, val)
          }
        } else {
          result.insert(key, val)
        }
      }
    }
  }

  result
}

/// Sets a default theme for all charts in `body`.
///
/// Charts inside `body` that don't pass an explicit `theme:` parameter
/// will use this theme instead of `themes.default`.
///
/// ```typst
/// #with-theme(themes.dark)[
///   #bar-chart(data)       // uses dark theme
///   #pie-chart(data2)      // uses dark theme
///   #line-chart(data3, theme: themes.minimal) // explicit override wins
/// ]
/// ```
///
/// Can also be used as a show rule for the entire document:
/// ```typst
/// #show: with-theme.with(themes.dark)
/// ```
///
/// - theme (dictionary): Theme to use as default
/// - body (content): Content whose charts inherit this theme
/// -> content
#let with-theme(theme, body) = {
  _primaviz-theme.update(theme)
  body
  _primaviz-theme.update(none)
}

/// Returns a color from the theme palette, cycling if the index exceeds palette length.
///
/// - theme (dictionary): Resolved theme dictionary
/// - index (int): Color index (wraps around via modulo)
/// -> color
#let get-color(theme, index) = {
  let pal = theme.palette
  pal.at(calc.rem(index, pal.len()))
}

// --- Named preset themes ---

// Preset themes — each is a partial override dict resolved against default-theme.
// Usage: `chart(data, theme: themes.minimal)` or `chart(data, theme: themes.dark)`

#let minimal-theme = resolve-theme((
  palette: (
    rgb("#7a9ec2"), rgb("#d4a76a"), rgb("#c27a7c"), rgb("#8ebdb9"),
    rgb("#7fb07a"), rgb("#d4c36e"), rgb("#b99cb2"), rgb("#e0b3b8"),
    rgb("#b09a89"), rgb("#c5beb9"),
  ),
  axis-stroke: 0.3pt + luma(150),
  grid-stroke: 0.3pt + luma(240),
  show-grid: true,
  title-weight: "regular",
  border: none,
))

#let dark-theme = resolve-theme((
  background: rgb("#1a1a2e"),
  palette: (
    rgb("#00d2ff"), rgb("#ff6b6b"), rgb("#c56cf0"), rgb("#ffdd59"), rgb("#0be881"),
    rgb("#ff9f43"), rgb("#48dbfb"), rgb("#ff6348"), rgb("#1dd1a1"), rgb("#f368e0"),
  ),
  axis-stroke: 0.5pt + rgb("#cccccc"),
  grid-stroke: 0.5pt + rgb("#333355"),
  marker-stroke: 0.5pt + rgb("#1a1a2e"),
  text-color: rgb("#e0e0e0"),
  text-color-light: rgb("#888899"),
  text-color-inverse: rgb("#1a1a2e"),
))

#let presentation-theme = resolve-theme((
  base-size: 10pt,
  base-gap: 5pt,
))

#let print-theme = resolve-theme((
  palette: (
    luma(40), luma(90), luma(140), luma(180), luma(60),
    luma(110), luma(160), luma(200), luma(80), luma(130),
  ),
  show-grid: true,
  grid-stroke: 0.4pt + luma(200),
))

#let accessible-theme = resolve-theme((
  palette: (
    rgb("#E69F00"), rgb("#56B4E9"), rgb("#009E73"), rgb("#F0E442"),
    rgb("#0072B2"), rgb("#D55E00"), rgb("#CC79A7"), rgb("#000000"),
  ),
))

#let compact-theme = resolve-theme((
  base-size: 5pt,
  base-gap: 3pt,
  show-grid: true,
  grid-stroke: 0.3pt + luma(230),
))

#let themes = (
  default: default-theme,
  minimal: minimal-theme,
  dark: dark-theme,
  presentation: presentation-theme,
  print: print-theme,
  accessible: accessible-theme,
  compact: compact-theme,
)
