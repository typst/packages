// ============================================================
// clari-slides — Color Palettes
// ============================================================
// Each palette is a dictionary with:
//   primary   — dominant UI color (header, accents, bullets)
//   accent    — secondary highlight color
//   text      — default body text color (usually black/dark)
//   muted     — light tint used for backgrounds in components

#let _palettes = (
  // Blues
  ocean: (
    primary: rgb("#1A6DB5"),
    accent:  rgb("#5BC0EB"),
    text:    rgb("#1A1A2E"),
    muted:   rgb("#EAF4FB"),
  ),
  midnight: (
    primary: rgb("#1A237E"),
    accent:  rgb("#3949AB"),
    text:    rgb("#0D0D1A"),
    muted:   rgb("#E8EAF6"),
  ),
  // Greens
  forest: (
    primary: rgb("#2D6A4F"),
    accent:  rgb("#74C69D"),
    text:    rgb("#1A2E1E"),
    muted:   rgb("#E8F5EE"),
  ),
  teal: (
    primary: rgb("#00695C"),
    accent:  rgb("#26A69A"),
    text:    rgb("#0A1F1C"),
    muted:   rgb("#E0F2F1"),
  ),
  // Reds / Warm
  sunset: (
    primary: rgb("#f54e12ff"),
    accent:  rgb("#FF8F00"),
    text:    rgb("#1A0A0A"),
    muted:   rgb("#FDECEA"),
  ),
  amber: (
    primary: rgb("#E65100"),
    accent:  rgb("#FFA000"),
    text:    rgb("#1C1200"),
    muted:   rgb("#FFF3E0"),
  ),
  rose: (
    primary: rgb("#C2185B"),
    accent:  rgb("#E91E63"),
    text:    rgb("#1A0014"),
    muted:   rgb("#FCE4EC"),
  ),
  // Purples
  lavender: (
    primary: rgb("#5E35B1"),
    accent:  rgb("#AB47BC"),
    text:    rgb("#120A1C"),
    muted:   rgb("#EDE7F6"),
  ),
  // Neutrals
  slate: (
    primary: rgb("#37474F"),
    accent:  rgb("#546E7A"),
    text:    rgb("#0A0D0F"),
    muted:   rgb("#ECEFF1"),
  ),
  charcoal: (
    primary: rgb("#212121"),
    accent:  rgb("#424242"),
    text:    rgb("#050505"),
    muted:   rgb("#F5F5F5"),
  ),
)

/// Returns the palette dictionary for a given theme name string.
/// If `theme` is already a color, wraps it into a synthetic palette.
#let _resolve-palette(theme) = {
  if type(theme) == str {
    if theme in _palettes { _palettes.at(theme) }
    else { _palettes.at("ocean") } // fallback
  } else {
    // User passed a raw color — use it as primary, derive accent/muted
    (
      primary: theme,
      accent:  theme.lighten(30%),
      text:    black,
      muted:   theme.lighten(85%),
    )
  }
}

/// Sensible default theme per category.
#let _category-defaults = (
  simple:       "ocean",
  math:         "slate",
  professional: "midnight",
  allrounder:   "teal",
)
