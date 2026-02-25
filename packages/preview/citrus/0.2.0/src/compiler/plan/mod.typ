// compiler plan phase
//
// Static AST-to-plan transforms for compile-time caching.

/// Build plan for <text variable=...>
#let build-text-var-plan(attrs) = {
  let var-name = attrs.at("variable", default: "")
  let form = attrs.at("form", default: "long")
  let quotes-attr = attrs.at("quotes", default: "false")
  let has-quotes = (
    "quotes" in attrs
      and (
        quotes-attr == "true" or quotes-attr == true
      )
  )
  let has-text-case = "text-case" in attrs
  let has-affixes = (
    attrs.at("prefix", default: "") != ""
      or attrs.at("suffix", default: "") != ""
  )
  let has-strip-periods = attrs.at("strip-periods", default: "false") == "true"
  let has-formatting = (
    "font-style" in attrs
      or "font-weight" in attrs
      or "font-variant" in attrs
      or "text-decoration" in attrs
      or "vertical-align" in attrs
      or "display" in attrs
  )
  let is-page-like = var-name in ("page", "page-first", "locator")
  (
    kind: "text-var",
    var: var-name,
    form: form,
    is-page-like: is-page-like,
    has-quotes: has-quotes,
    has-text-case: has-text-case,
    has-affixes: has-affixes,
    has-strip-periods: has-strip-periods,
    has-formatting: has-formatting,
  )
}

/// Build plan for <text term=...>
#let build-term-plan(attrs) = {
  let term-name = attrs.at("term", default: "")
  let form = attrs.at("form", default: "long")
  let plural = attrs.at("plural", default: "false") == "true"
  let quotes-attr = attrs.at("quotes", default: "false")
  let has-quotes = (
    "quotes" in attrs
      and (
        quotes-attr == "true" or quotes-attr == true
      )
  )
  let has-text-case = "text-case" in attrs
  let has-affixes = (
    attrs.at("prefix", default: "") != ""
      or attrs.at("suffix", default: "") != ""
  )
  let has-strip-periods = attrs.at("strip-periods", default: "false") == "true"
  let has-formatting = (
    "font-style" in attrs
      or "font-weight" in attrs
      or "font-variant" in attrs
      or "text-decoration" in attrs
      or "vertical-align" in attrs
      or "display" in attrs
  )
  (
    kind: "term",
    term: term-name,
    form: form,
    plural: plural,
    has-quotes: has-quotes,
    has-text-case: has-text-case,
    has-affixes: has-affixes,
    has-strip-periods: has-strip-periods,
    has-formatting: has-formatting,
  )
}

/// Build plan for <group>
#let build-group-plan(attrs, children) = {
  let delimiter = attrs.at("delimiter", default: "")
  let has-prefix = attrs.at("prefix", default: "") != ""
  let has-suffix = attrs.at("suffix", default: "") != ""
  let has-strip-periods = attrs.at("strip-periods", default: "false") == "true"
  let has-formatting = (
    "font-style" in attrs
      or "font-weight" in attrs
      or "font-variant" in attrs
      or "text-decoration" in attrs
      or "vertical-align" in attrs
      or "display" in attrs
  )
  let allowed-children-only = children.all(c => (
    type(c) == dictionary and c.at("tag", default: "") != ""
  ))
  (
    kind: "group",
    delimiter: delimiter,
    has-prefix: has-prefix,
    has-suffix: has-suffix,
    has-strip-periods: has-strip-periods,
    has-formatting: has-formatting,
    allowed-children-only: allowed-children-only,
  )
}

/// Build plan for <choose>
#let build-choose-plan(children) = {
  let branches = children.filter(c => type(c) == dictionary)
  (
    kind: "choose",
    branch-count: branches.len(),
  )
}
