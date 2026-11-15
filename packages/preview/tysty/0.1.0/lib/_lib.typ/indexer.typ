// typst-mode: indexer.typ
// Index / lookup: `mkindex` records a label at the current location in the
// document; `lookup` turns that label back into a clickable link to the
// spot. This powers things like an index or cross-references.

#import "record.typ": impl_record, record
#import "enum.typ": enumerator

// Namespace labels for selective queries independent of ordinary document labels.
#let _index-selector(name) = std.label("typst-mode-index:" + name)
#let _backlink-selector(name) = std.label("typst-mode-backlink:" + name)

#let _ctx = enumerator(
  doc: str,
  null: record(),
)
#let _ctx = (
  _ctx
    + (
      null: (_ctx.null)(),
    )
)

#let _backlink = record(
  loc: location,
  content: content,
  ctx: _ctx,
)

// An index entry: the label text, the location it points at, and the
// content to display for the link.
#let _indexer = record(
  label: str,
  loc: location,
  content: content,
)

#let _indexer = impl_record(
  _indexer,
  // Build a link to the recorded location, shown as `content`.
  lookup: (self, content) => context {
    link(self.loc, content)
  },
)

// Register a label at the current location. Duplicate labels are rejected —
// this fails compilation instead of silently shadowing.
#let mkindex(label, content) = {
  context {
    let loc = here()
    let index = (_indexer.new)(
      label: label,
      loc: loc,
      content: content,
    )

    // The shared marker enumerates entries; the named marker supports targeted
    // queries without collecting and filtering every index entry.
    [#metadata(index) <typst-mode-index-label>]
    [#metadata(index)#_index-selector(label)]
    content
  }
  // Keep validation separate from registration so a failed validation cannot
  // remove the metadata and oscillate between layout passes.
  context {
    let matches = query(_index-selector(label))
    assert(matches.len() <= 1, message: "ERROR: duplicate label: `" + label + "`")
  }
}

// Look up a previously registered label and render a link to it.
#let _lookup(label, content, doc_id: auto) = context {
  let loc = here()
  let matches = query(_index-selector(label))
  assert(matches.len() > 0, message: "ERROR: unknown label: `" + label + "`")
  let cont = matches.first().value

  let backlink = (_backlink.new)(
    loc: loc,
    content: content,
    ctx: if doc_id == auto { _ctx.null } else { (_ctx.doc)(doc_id) },
  )
  [#metadata(backlink)#_backlink-selector(label)]

  (cont.lookup)(content)
}

#let backlinks(label) = {
  query(_backlink-selector(label)).map(item => item.value)
}

// Return index records in document order.
#let indexers() = {
  query(<typst-mode-index-label>).map(item => item.value)
}
