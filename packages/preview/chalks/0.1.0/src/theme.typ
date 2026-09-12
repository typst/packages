// Document-wide style presets. The default look IS pencil, so the pencil
// theme is the empty overlay; ink and chalk override on top of defaults.
/// Default graphite-gray theme overlay.
#let pencil = (:)

/// Crisp, dark, low-roughness ink theme overlay.
#let ink = (
  color: rgb("#20222a"),
  width: 1.0,
  roughness: 0.6,
  taper: 0.15,
  passes: 1,
)

/// Wide, light-on-dark chalk theme overlay.
#let chalk = (
  color: rgb("#f2f0e9"),
  width: 2.0,
  roughness: 1.3,
  taper: 0.3,
  opacity: 92%,
)

#let theme-state = state("chalks:theme", pencil)
