/// Cite without brackets — `Author Year`, not `(Author, Year)`.
///
/// `@key` produces the bracketed form. `citepre` uses only the author and year
/// parts, optionally preceded by custom content. A `bibliography()` must exist in
/// the document for the citation to resolve.
///
/// ```example
/// #citepre(<smith2020>, pre: [see ])
/// ```
///
/// - key (label, str): bibliography key, e.g. `<smith2020>` or `"smith2020"`
/// - pre (none, content): optional content before the citation, e.g. `[see ]`
#let citepre(key, pre: none) = {
  let c = [#cite(key, form: "author"), #cite(key, form: "year")]
  if pre != none {
    [#pre #c]
  } else {
    c
  }
}
