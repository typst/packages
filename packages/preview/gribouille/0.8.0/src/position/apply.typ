// Position adjustment dispatcher. Sits between stat and render in
// `_prepare-layer`. Every position's `apply` declares the same
// `(data, mapping, params:, coord:)` signature so the dispatcher can
// forward without per-position branching; only `stack` and `fill`
// currently read `coord:` to flip cumulation direction under
// `coord-radial`.

#import "identity.typ" as identity-pos
#import "../utils/errors.typ": fail-enum
#import "stack.typ" as stack-pos
#import "dodge.typ" as dodge-pos
#import "fill.typ" as fill-pos
#import "jitter.typ" as jitter-pos
#import "jitterdodge.typ" as jitterdodge-pos
#import "beeswarm.typ" as beeswarm-pos
#import "nudge.typ" as nudge-pos
#import "../utils/group.typ": group-aesthetics

#let _POSITIONS = (
  identity: identity-pos.apply,
  stack: stack-pos.apply,
  dodge: dodge-pos.apply,
  fill: fill-pos.apply,
  jitter: jitter-pos.apply,
  jitterdodge: jitterdodge-pos.apply,
  beeswarm: beeswarm-pos.apply,
  nudge: nudge-pos.apply,
)

// Mapping keys each position reads. `stack`, `fill`, `dodge`, and `jitterdodge`
// (through dodge) group rows with `group-plan`, so they also read the grouping
// aesthetics.
#let POSITION-READS = (
  identity: (),
  stack: ("x", "y") + group-aesthetics,
  dodge: ("x",) + group-aesthetics,
  fill: ("x", "y") + group-aesthetics,
  jitter: ("x", "y"),
  jitterdodge: ("x", "y") + group-aesthetics,
  beeswarm: ("x", "y"),
  nudge: ("x", "y"),
)

// Panic unless `position` is `none`, a position dict from a `position-*()`
// constructor, or the name of a known adjustment.
#let assert-position(scope, position) = {
  if type(position) == str and position not in _POSITIONS {
    fail-enum(scope, "position", position, _POSITIONS.keys())
  }
}

#let apply-position(name, data, mapping, params: (:), coord: none) = {
  let resolved = if name == none { "identity" } else { name }
  let apply = _POSITIONS.at(resolved, default: none)
  if apply == none {
    fail-enum("position", "adjustment", resolved, _POSITIONS.keys())
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

/// Whether a layer's position piles its marks against each other.
///
/// `stack` and `fill` are the only adjustments that put one mark's edge on the next, which is what seam sealing needs to know: everywhere else the marks stand apart and a seal would only eat the gap between them.
///
/// - layer: Layer dictionary as produced by `make-layer`.
///
/// Returns: `true` under `stack` or `fill`, `false` otherwise.
#let layer-marks-abut(layer) = {
  let name = layer-position-name(layer)
  name == "stack" or name == "fill"
}
