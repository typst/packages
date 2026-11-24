/// Checks whether the parameter can be used as a bibliography:
/// - either a `bibliography()` element
/// - or a `path
/// And returns a `bibliography()`.
/// Othr values, particularly strings, ar rejected.
///
/// -> content
#let coerce-bibliography(
  /// the potential bibliography
  /// -> path | content
  bib
) = {
  assert.ne(type(bib), str, message: "To specify a file path as bibliography, use the `path()` constructor")
  assert((
    type(bib) == path or
    (type(bib) == content and bib.func() == bibliography)
  ), message: "Bibliography must be specified as a path or a `bibliography()` element")

  if type(bib) == path {
    bib = bibliography(bib)
  }
  // by the previous asserts, we now have a bibliography element
  bib
}
