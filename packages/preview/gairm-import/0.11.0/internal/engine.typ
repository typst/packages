// The one walk over schema and value. validate, coerce and parse all
// derive from it, so they cannot disagree about a kind: each kind's
// behaviour is its descriptor in kinds/registry.typ, and this file
// holds no per-kind logic.
//
// _walk(schema, value, ctx) -> (errors, value, fatal):
//   errors  every validation error, in walk order
//   value   the model: absent keys and items dropped, unknown keys
//           dropped, leaves through their kind's model
//   fatal   none, or the first place in walk order where the value
//           leaves no sound model, as (path, expected, got) for
//           coerce's panic
//
// Only the public entry points panic on a result; the walk itself
// panics only on a schema it cannot read (an unknown kind, which only
// a hand-built node can carry).

#import "core/ctx.typ": _absent
#import "core/error.typ": _bail, _coerce-message, _format-report
#import "kinds/registry.typ": _kinds, _node

#let _walk(schema, value, ctx) = {
  if _absent(value, ctx) { return (errors: (), value: none, fatal: none) }
  // An old kind name reaches its walk as the node it stands for.
  let schema = _node(schema)
  let d = _kinds.at(schema.kind, default: none)
  if d == none {
    _bail(
      none,
      "unknown schema kind "
        + repr(schema.kind)
        + "; build schemas with the constructors.",
    )
  }
  (d.walk)(schema, value, ctx, _walk)
}

// The entry points, each over a finished walk result, so lib.typ can
// call `_walk` itself and spend no extra call frame on the way in.

/// The model from a walk result. Panics only where the value left no
/// sound model; every other error is the caller's to have checked.
#let _coerce-result(r) = {
  if r.fatal != none {
    _bail(none, _coerce-message(r.fatal.path, r.fatal.expected, r.fatal.got))
  }
  r.value
}

/// The model from a walk result, or a panic listing every error.
#let _parse-result(r) = {
  if r.errors != () { panic(_format-report(r.errors)) }
  r.value
}
