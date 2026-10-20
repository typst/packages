/// Cite without the brackets — `Author Year` not `(Author, Year)`.
///
/// `@key` gives you "(Author, Year)". `citepre` drops the brackets.
/// Add `pre` if you want "see Author Year".
///
/// - key (label): your bib key (e.g. `<smith2020>`)
/// - pre (none, content): put this before the cite, e.g. `[see ]`
#let citepre(key, pre: none) = {
  let c = [#cite(key, form: "author"), #cite(key, form: "year")]
  if pre != none {
    [#pre #c]
  } else {
    c
  }
}
