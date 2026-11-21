// typst-mode: decorate.typ
// Function decoration: wrap a function with hooks that run before/around it
// and observe its result, without editing the function itself.

// `decorate(fn, prev, before, after, fwd)` returns a wrapped version of
// `fn`. When the wrapper is called, the hooks run in this order:
//   prev(..rest)                 — runs first, sees the raw arguments
//   args  = before(.._b, ..rest) — pre-process the arguments
//   res   = after(fn(..args, .._f), .._a) — post-process the result
//   fwd(res)                     — observe the final result (side effects)
//   → returns `res`
//
// The reserved named arguments `_b`, `_a`, `_f` passed to the wrapper feed
// the `before`, `after`, and wrapped function hooks respectively; with the defaults,
// `before` is the identity (arguments unchanged), `after` the identity
// (result unchanged), and `prev`/`fwd` do nothing.
#let decorate(
  fn,
  prev: (..rest) => none,
  before: (..rest) => rest,
  after: (a, ..rest) => a,
  fwd: (..rest) => none,
) = {
  (_b: (:), _a: (:), _f: (:), ..rest) => {
    prev(..rest)
    let result = after(fn(..before(.._b, ..rest), .._f), .._a)
    fwd(result)

    return result
  }
}


// Continuation-passing-style variant: the hooks are composed as a triple
// `(mid, before, after)` and the wrapped call threads a continuation
// through them. `mid` is the middle hook that receives `fn(..rest)`.
#let decorate-cps = fn => {
  let _after = (next, a, ..rest) => next(a)
  let _before = (next, after, ..rest) => next(after, ..rest)
  let _mid = (next, ..rest) => next(v => v, fn(..rest), ..rest)
  (
    mid: _mid,
    before: _before,
    after: _after,
  ) => {
    (..rest) => {
      before(mid, after, ..rest)
    }
  }
}
