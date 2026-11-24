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
//           coerce's panic, with `shown`, the value as the panic names
//           it, when its type is not what is wrong
//
// Only the public entry points panic on a result, and they check the
// whole schema before the walk (structure.typ's _require-schema), so the
// walk never meets a node it cannot read.

#import "core/ctx.typ": _absent
#import "core/error.typ": _bail, _coerce-message, _panic-report
#import "kinds/registry.typ": _kinds

// A kind's walk that hands the whole value on to one sub-schema returns
// `(tail: sub-schema)`, and the loop walks that here, in this frame: a
// nullable or a conditional then costs no call depth of its own.
#let _walk(schema, value, ctx) = {
  if _absent(value, ctx) { return (errors: (), value: none, fatal: none) }
  let r = (_kinds.at(schema.kind).walk)(schema, value, ctx, _walk)
  while "tail" in r {
    r = (_kinds.at(r.tail.kind).walk)(r.tail, value, ctx, _walk)
  }
  r
}

// The entry points, each over a finished walk result, so run.typ can
// call `_walk` itself and spend no extra call frame on the way in.

/// The model from a walk result. Panics only where the value left no
/// sound model; every other error is the caller's to have checked.
#let _coerce-result(r) = {
  if r.fatal != none {
    _bail(none, _coerce-message(
      r.fatal.path,
      r.fatal.expected,
      r.fatal.got,
      shown: r.fatal.at("shown", default: none),
    ))
  }
  r.value
}

/// The model from a walk result, or a panic listing every error.
#let _parse-result(r) = {
  if r.errors != () { _panic-report(r.errors) }
  r.value
}
