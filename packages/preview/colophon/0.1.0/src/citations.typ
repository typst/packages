/// Extracts every entry key from a `.bib` file's raw text -- a
/// deliberately minimal parser: matches `@type{key,` at the start of
/// each entry (or `@type(key,`, the other bibtex delimiter Typst also
/// accepts), skipping `@comment`/`@string`/`@preamble` blocks, which
/// aren't real, citable entries. Doesn't need to parse the rest of a
/// `.bib` file's structure (fields, nested braces, multi-line values,
/// ...) since only the key matters for deciding which entries were
/// never cited.
#let bib-keys(path) = {
  let content = read(path)
  let entry-re = regex("(?i)@(\w+)\s*[\{\(]\s*([^,\s\}\)]+)\s*,")
  content
    .matches(entry-re)
    .filter(m => lower(m.captures.at(0)) not in ("comment", "string", "preamble"))
    .map(m => m.captures.at(1))
}

/// Every key in the `.bib` at `path` that no `@key`/`cite(<key>)`
/// anywhere in the manuscript span `start`..`end` (see
/// `instrument.typ`) actually cites.
///
/// `path` must be root-relative (a leading `/`, resolved against
/// `--root`), not relative to the manuscript file that names it in its
/// own `#bibliography(...)` call: Typst resolves a path string against
/// the file that calls the path-consuming builtin -- `read`, here,
/// inside this package's own source -- not the file that wrote the
/// string literal. The same gotcha `@preview/palimpsest`'s
/// `letter-bibliography` already documents, for the same underlying
/// reason.
#let uncited-references(path, start, end) = {
  let keys = bib-keys(path)
  let cited = query(selector(cite).after(start).before(end)).map(c => str(c.key))
  keys.filter(k => k not in cited)
}
