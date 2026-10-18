///! Layer record helpers and default stat and position wiring.
///!
///! Every `geom-*` constructor returns the dict shape this module builds.
///! Centralising it here keeps the record's keys discoverable in one place
///! and stops drift between geoms when fields are added or renamed.

/// Build a layer record consumed by `plot()`.
///
/// \@internal
/// \@param geom Renderer dispatch key (e.g., `"point"`, `"col"`, `"line"`).
///
/// \@param mapping Layer-specific aesthetic mapping, or `none` to inherit.
///
/// \@param data Layer-specific data array, or `none` to inherit.
///
/// \@param params Geom-specific parameter dict (fixed aesthetics, knobs).
///
/// \@param stat Stat name or stat-object selecting the pre-render transform.
///
/// \@param position Position-adjustment name or position-object.
///
/// \@param key Legend-glyph override; `auto` falls back to the geom's default.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer.
///
/// \@returns Layer dictionary consumed by `plot()`.
#let make-layer(
  geom,
  mapping: none,
  data: none,
  params: (:),
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
) = (
  kind: "layer",
  geom: geom,
  mapping: mapping,
  data: data,
  params: params,
  key: key,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)
