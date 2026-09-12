#let _authors = state("thesis-authors")
#let _current = state("thesis-current-authors", ())

/// Checks the `current-authors` setting and either panics or does nothing
///
/// -> none
#let check-current-authors(
  /// the mode
  /// -> string
  mode
) = {
  assert(
    mode in ("highlight", "only"),
    message: "current author mode must be 'highlight' or 'only'",
  )
}

/// Sets the thesis authors. Each array entry is a `dict` of the form
/// `(name: ..., class: ..., subtitle: ...)` stating their name, class, and the title of their part
/// of the whole thesis project. The names must be regular strings, for the PDF metadata.
///
/// -> content
#let set-authors(
  /// the thesis authors
  /// -> array
  authors
) = _authors.update(authors)

#let get-authors() = _authors.get()

/// Set the authors writing the current part of the thesis. The footer will highlight the names of
/// the given authors until a new list of authors is given with this function.
///
/// -> content
#let set-current-authors(
  /// the names of the authors to highlight
  /// -> arguments
  ..authors,
) = {
  assert(authors.named().len() == 0, message: "named arguments not allowed")
  let authors = authors.pos()

  context {
    let names = get-authors().map(author => author.name)
    for author in authors {
      assert(author in names, message: "invalid author: " + author)
    }
  }

  _current.update(authors)
}

/// Returns an array of dicts of the form `(author: ..., is-current: ...)` containing the name
/// (string/content) and whether they are an active author on the current page (boolean).
///
/// This function is contextual.
///
/// -> array
#let get-names-and-current() = {
  let authors = _authors.get()
  let current = _current.get()
  authors.map(author => (author: author.name, is-current: author.name in current))
}
