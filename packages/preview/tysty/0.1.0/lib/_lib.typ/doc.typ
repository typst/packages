// typst-mode: doc.typ
// Document metadata system.
//
// `meta(...)` in art.typ declares a document: it builds a `_core_doc` record from the
// given metadata, attaches it to any
// tags, emits queryable metadata, and makes it the `current`
// document. Documents are referenced by id elsewhere (e.g. by tag.typ and
// by a future bibliography/record layer).

#import "types.typ": category, img
#import "record.typ": record
#import "state.typ": _mkstate

// Query complete document records in document order.
#let documents() = query(<tysty-document>).map(item => item.value)

#let _current_stack = _mkstate(
  "4425dff9-79cf-48e7-8868-1a99688d1635",
  ((:),),
)

// Embedding saves/restores the stack with functional updates. Capturing a
// contextual current.get() for each sibling requires one layout pass per
// sibling and does not converge for a large collection of notes.
#let current = (
  get: () => (_current_stack.get)().last(),
  final: () => (_current_stack.final)().last(),
  at: loc => (_current_stack.at)(loc).last(),
  update: value => (_current_stack.update)(stack => {
    let old = stack.pop()
    stack.push(if type(value) == function { value(old) } else { value })
    stack
  }),
  enter: () => (_current_stack.update)(stack => stack + (stack.last(),)),
  leave: () => (_current_stack.update)(stack => {
    assert(stack.len() > 1, message: "Cannot leave the root document scope")
    let _ = stack.pop()
    stack
  }),
)

// The metadata schema: the core fields a `meta` document carries.
#let _core_doc = record(
  "Metadata: [Core]",
  id: str,
  parent-id: str,
  file-path: str,

  title: content,
  authors: array, // string names or author records; always an array

  date: datetime,
  lang: str,
  version: str,
  doi: str,
  abstract: str,
  keywords: array,
  license: str,

  description: str,
  cover_image: img,

  category: category,

  tags: array,

  tlb: dictionary,
)

