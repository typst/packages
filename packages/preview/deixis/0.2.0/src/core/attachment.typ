// id declares/names; of attaches/reuses. Opaque locations are private wrapper IDs.
#let _deixis-check-identities(id, of) = {
  assert(id == none or (type(id) in (str, label) and str(id).len() > 0),
    message: "deixis: A note ID must be a nonempty string or label.")
  assert(of == none or type(of) == location or (type(of) in (str, label) and str(of).len() > 0),
    message: "deixis: of must be a nonempty existing annotation ID or label.")
  assert(id == none or of == none, message: "deixis: Use id or of, not both.")
}

// Annotation data belongs to creation, never to an attachment or occurrence.
// Keep it nested rather than merging custom keys into runtime records.
#let _deixis-check-note-data(data, of: none) = {
  assert(type(data) == dictionary, message: "deixis: Annotation data must be a dictionary.")
  assert(of == none or data.len() == 0,
    message: "deixis: Attached bodies and reused marks inherit annotation data. Configure data on the original declaration.")
}

#let _deixis-check-attached-wrapper(of, positional, mark-options: (:)) = {
  assert(of == none or positional.len() <= 1,
    message: "deixis: An attached wrapper accepts only [body]. Declare or reuse the mark separately; [mark][body] would discard the mark.")
  if of == none { return }
  let conflicts = mark-options.pairs().filter(pair => pair.last() != auto).map(pair => pair.first())
  assert(conflicts.len() == 0,
    message: "deixis: Attached wrappers render only a body; original-mark option(s) " + repr(conflicts) +
      " cannot be configured with of. Set numbering/series/marker on the original; use deixis-mark(of: ...) for another decorated occurrence.")
}

// A body's series organizes a standalone collection. An attachment inherits
// its original's series; a local argument cannot redefine that identity.
#let _deixis-body-series(of, series, fallback: "default") = {
  assert(of == none or series == auto,
    message: "deixis: Attached bodies inherit their original's series. Omit series with of and configure it on the original mark.")
  assert(series == auto or type(series) == str,
    message: "deixis: Body series must be auto or a string.")
  if series == auto { fallback } else { series }
}
