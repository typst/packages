///! Layer record helpers and default stat and position wiring.
///!
///! Every `geom-*` constructor returns the dict shape this module builds.
///! Centralising it here keeps the record's keys discoverable in one place
///! and stops drift between geoms when fields are added or renamed.

#import "aes-keys.typ": AES-KEYS
#import "utils/errors.typ": fail, fail-enum

/// Collect a geom's trailing `..args` into a constant-aesthetic param dict.
///
/// Geoms forward their `..args` here so any aesthetic key can be pinned as a constant directly on the geom (e.g. `geom-label(nudge-x: 0.5)`), matching the param-first precedence the scale channels already enjoy. A declared parameter binds before `..args`, so this only ever captures keys the geom does not name. A positional or unknown-named arg is a user error.
///
/// - scope: Geom name used in error messages (e.g. `"geom-label"`).
/// - args: The geom's captured `arguments` value.
///
/// Returns: Dict of aesthetic key to constant value, to merge into `params`.
#let split-aes-params(scope, args) = {
  if args.pos().len() != 0 {
    fail(
      scope,
      "positional arguments are not supported",
      hint: "Pass aesthetic constants as named arguments.",
    )
  }
  let aes-params = (:)
  for (key, value) in args.named().pairs() {
    if key in AES-KEYS {
      aes-params.insert(key, value)
    } else {
      fail-enum(
        scope,
        "argument",
        key,
        AES-KEYS,
        hint: "Pass geom knobs as declared parameters; only aesthetic keys may be set as ad-hoc constants.",
      )
    }
  }
  aes-params
}

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
