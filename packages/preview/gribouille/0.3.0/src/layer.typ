///! Layer record helpers and default stat and position wiring.
///!
///! Every `geom-*` constructor returns the dict shape this module builds.
///! Centralising it here keeps the record's keys discoverable in one place
///! and stops drift between geoms when fields are added or renamed.

/// Build a layer record consumed by `plot()`.
///
/// - geom: Renderer dispatch key (e.g., `"point"`, `"col"`, `"line"`).
/// - mapping: Layer-specific aesthetic mapping, or `none` to inherit.
/// - data: Layer-specific data array, or `none` to inherit.
/// - params: Geom-specific parameter dict (fixed aesthetics, knobs).
/// - stat: Stat name or stat-object selecting the pre-render transform.
/// - position: Position-adjustment name or position-object.
/// - key: Legend-glyph override; `auto` falls back to the geom's default.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer.
/// - clip: Whether the layer's marks are clipped to the panel area. `true` (default) follows the usual panel clip; `false` lets the marks overflow the panel, set by `annotate` for deliberate out-of-panel marks.
///
/// Returns: Layer dictionary consumed by `plot()`.
#let make-layer(
  geom,
  mapping: none,
  data: none,
  params: (:),
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
  clip: true,
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
  clip: clip,
)
