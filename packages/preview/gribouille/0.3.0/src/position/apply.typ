// Position adjustment dispatcher. Sits between stat and render in
// `_prepare-layer`. Every position's `apply` declares the same
// `(data, mapping, params:, coord:)` signature so the dispatcher can
// forward without per-position branching; only `stack` and `fill`
// currently read `coord:` to flip cumulation direction under
// `coord-radial`.

#import "identity.typ" as identity-pos
#import "../utils/errors.typ": fail
#import "stack.typ" as stack-pos
#import "dodge.typ" as dodge-pos
#import "fill.typ" as fill-pos
#import "jitter.typ" as jitter-pos
#import "jitterdodge.typ" as jitterdodge-pos
#import "nudge.typ" as nudge-pos

#let _POSITIONS = (
  identity: identity-pos.apply,
  stack: stack-pos.apply,
  dodge: dodge-pos.apply,
  fill: fill-pos.apply,
  jitter: jitter-pos.apply,
  jitterdodge: jitterdodge-pos.apply,
  nudge: nudge-pos.apply,
)

#let apply-position(name, data, mapping, params: (:), coord: none) = {
  let resolved = if name == none { "identity" } else { name }
  let apply = _POSITIONS.at(resolved, default: none)
  if apply == none {
    fail("position", "unknown adjustment " + repr(resolved))
  }
  apply(data, mapping, params: params, coord: coord)
}

/// Normalise a position spec (string or position dict) to its name.
///
/// - spec: Position spec: `none`, a name string, or a position dict from a `position-*()` constructor.
///
/// Returns: Position name string, defaulting to `"identity"` when the spec is `none` or carries no name.
#let position-name-of(spec) = if spec == none {
  "identity"
} else if type(spec) == str { spec } else {
  spec.at("name", default: "identity")
}

/// Read a layer's `position` field and normalise to its name.
///
/// - layer: Layer dictionary as produced by `make-layer`.
///
/// Returns: Position name string for the layer, defaulting to `"identity"`.
#let layer-position-name(layer) = position-name-of(
  layer.at("position", default: "identity"),
)
