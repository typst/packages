// Linear data-structure domain facade.
//
// Shared cell primitives are separated from linked lists, stack/queue
// containers, and the skip-list algorithm subsystem.

#import "common.typ": _null as _null-impl
#import "lists.typ": (
  linked-list as _linked-list, doubly-linked-list as _doubly-linked-list,
  _render-linked-list as _render-linked-list-impl,
)
#import "containers.typ": stack as _stack, queue as _queue
#import "skip-list.typ": (
  skip-list as _skip-list, default-decision-fn as _default-decision-fn,
)

#let linked-list = _linked-list
#let doubly-linked-list = _doubly-linked-list
#let stack = _stack
#let queue = _queue
#let skip-list = _skip-list
#let default-decision-fn = _default-decision-fn

// Internal compatibility exports used by chained hash-table rendering.
#let _render-linked-list = _render-linked-list-impl
#let _null = _null-impl
