#import "doc.typ": current, documents
#import "indexer.typ": _lookup

#import "state.typ": _mkstate
#let file_base = _mkstate(
  "c88ae13e-b0cd-4f84-b3e8-759903558a3d",
  "",
)

#let set-base(p) = context {
  (file_base.update)(
    _ => p,
  )
}

// HTML and PDF share the rendered-document sequence.
#let entities() = query(<tysty-rendered-document>).map(item => item.value)

// Validate ancestry before constructing any breadcrumb content.
#let _breadcrumb-path(doc) = {
  let limit = query(<tysty-rendered-document>).len()
  let docs = documents()
  let path = ()
  let node = doc
  while true {
    path.push(node)
    if path.len() > limit {
      panic("Breadcrumb path exceeds rendered document count: " + doc.id)
    }
    if node.parent-id == node.id { break }
    let parent-id = node.parent-id
    let parent = docs.find(doc => doc.id == node.parent-id)
    assert(
      parent != none,
      message: "document " + "\"" + node.id + "\"" + " references undefined parent" + "\"" + node.parent-id + "\"",
    )
    node = parent
  }
  path.rev()
}

// Both renderers attach the caller's document when one has been declared.
// The underlying indexer remains usable without document metadata.
#let lookup(label, content) = context {
  let doc = (current.get)()
  _lookup(label, content, doc_id: doc.at("id", default: auto))
}
