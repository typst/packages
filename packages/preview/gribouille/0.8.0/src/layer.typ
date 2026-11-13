///! Layer record helpers and default stat and position wiring.
///!
///! Every `geom-*` constructor returns the dict shape this module builds.
///! Centralising it here keeps the record's keys discoverable in one place
///! and stops drift between geoms when fields are added or renamed.

#import "utils/errors.typ": fail, fail-enum
#import "utils/types.typ": split-stroke-shorthand

/// Collect a geom's trailing `..args` into a constant-aesthetic param dict.
///
/// Geoms forward their `..args` here so an aesthetic the geom reads can be pinned as a constant directly on the geom (e.g. `geom-label(nudge-x: 0.5)`), matching the param-first precedence the scale channels already enjoy. A declared parameter binds before `..args`, so this only ever captures keys the geom does not name. A positional arg, or a key the geom does not read, is a user error.
///
/// - scope: Geom name used in error messages (e.g. `"geom-label"`). A `_scope` named argument in `args` replaces it, so a wrapper such as `annotate` reports under its own name.
/// - args: The geom's captured `arguments` value.
/// - keys: The mapping keys the geom reads: `spec.reads` of the draw module that renders the layer.
///
/// Returns: Dict of aesthetic key to constant value, to merge into `params`.
#let split-aes-params(scope, args, keys) = {
  let named = args.named()
  let scope = named.remove("_scope", default: scope)
  if args.pos().len() != 0 {
    fail(
      scope,
      "positional arguments are not supported",
      hint: "Pass aesthetic constants as named arguments.",
    )
  }
  let aes-params = (:)
  for (key, value) in named.pairs() {
    if key in keys {
      aes-params.insert(key, value)
    } else if keys.len() == 0 {
      fail(
        scope,
        "takes no aesthetic constants; got " + repr(key),
        hint: "Remove the argument, or map the key in aes() if it is an aesthetic.",
      )
    } else {
      fail-enum(
        scope,
        "argument",
        key,
        keys,
        hint: "Pass geom knobs as declared parameters; only the aesthetics this geom draws may be set as constants.",
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
) = {
  // Desugar a native `1.3pt + accent` stroke into the split `stroke`/`colour`
  // params the resolvers expect; other stroke forms pass through untouched.
  let params = if type(params.at("stroke", default: none)) == stroke {
    let split = split-stroke-shorthand(
      params.stroke,
      params.at("colour", default: auto),
      auto,
    )
    params + (stroke: split.stroke, colour: split.colour)
  } else { params }
  (
    kind: "layer",
    name: geom,
    mapping: mapping,
    data: data,
    params: params,
    key: key,
    stat: stat,
    position: position,
    inherit-aes: inherit-aes,
    clip: clip,
  )
}
