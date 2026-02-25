// citrus - CSL XML Parser
//
// Parses CSL XML into a structured Typst object

#import "locales.typ": create-fallback-locale

/// Find a child element by tag name
#let find-child(node, tag) = {
  if type(node) != dictionary { return none }
  let children = node.at("children", default: ())
  children.find(c => type(c) == dictionary and c.at("tag", default: "") == tag)
}

/// Find all children with a specific tag
#let find-children(node, tag) = {
  if type(node) != dictionary { return () }
  let children = node.at("children", default: ())
  children.filter(c => (
    type(c) == dictionary and c.at("tag", default: "") == tag
  ))
}

/// Filter valid CSL element children (exclude whitespace text nodes and comment nodes)
#let filter-element-children(children) = {
  children.filter(c => (
    type(c) == dictionary and c.at("tag", default: "") != ""
  ))
}

/// Get text content from a node (handles nested text)
#let get-text-content(node) = {
  if type(node) == str { return node }
  if type(node) != dictionary { return "" }
  node
    .at("children", default: ())
    .map(c => {
      if type(c) == str { c } else { "" }
    })
    .join("")
}

/// Parse a single term element
/// Terms can be simple text or have single/multiple sub-elements
#let parse-term(term-node) = {
  let name = term-node.attrs.at("name", default: "")
  let form = term-node.attrs.at("form", default: "long")

  // Check for single/multiple sub-elements
  let single-node = find-child(term-node, "single")
  let multiple-node = find-child(term-node, "multiple")

  let value = if single-node != none or multiple-node != none {
    // Complex term with singular/plural forms
    (
      single: if single-node != none { get-text-content(single-node) } else {
        ""
      },
      multiple: if multiple-node != none {
        get-text-content(multiple-node)
      } else { "" },
    )
  } else {
    // Simple text term
    get-text-content(term-node)
  }

  (name: name, form: form, value: value)
}

/// Parse locale terms into a structured dictionary
/// Key format: "name" for long form, "name-form" for other forms
/// Value: string or (single: string, multiple: string)
#let parse-locale-terms(locale-node) = {
  let terms = (:)
  let terms-node = find-child(locale-node, "terms")
  if terms-node == none { return terms }

  for term-node in find-children(terms-node, "term") {
    let parsed = parse-term(term-node)
    if parsed.name == "" { continue }

    let key = if parsed.form == "long" { parsed.name } else {
      parsed.name + "-" + parsed.form
    }
    terms.insert(key, parsed.value)
  }

  terms
}

/// Parse date format from locale
#let parse-locale-dates(locale-node) = {
  let dates = (:)

  for date-node in find-children(locale-node, "date") {
    let form = date-node.attrs.at("form", default: "numeric")
    let parts = find-children(date-node, "date-part").map(p => (
      name: p.attrs.at("name", default: ""),
      form: p.attrs.at("form", default: ""),
      prefix: p.attrs.at("prefix", default: ""),
      suffix: p.attrs.at("suffix", default: ""),
      range-delimiter: p.attrs.at("range-delimiter", default: "–"),
    ))
    dates.insert(form, (parts: parts))
  }

  dates
}

/// Parse style-options from locale
#let parse-locale-options(locale-node) = {
  let options-node = find-child(locale-node, "style-options")
  if options-node == none { return (:) }

  let attrs = options-node.at("attrs", default: (:))
  (
    punctuation-in-quote: attrs.at("punctuation-in-quote", default: "false")
      == "true",
    leading-noise-words: attrs
      .at("leading-noise-words", default: "")
      .split(",")
      .map(s => s.trim()),
    name-as-sort-order: attrs
      .at("name-as-sort-order", default: "")
      .split(" ")
      .filter(s => s != ""),
    name-never-short: attrs
      .at("name-never-short", default: "")
      .split(" ")
      .filter(s => s != ""),
  )
}

/// Parse a complete locale (inline or external)
#let parse-locale(locale-node) = {
  if locale-node == none { return none }

  let lang = locale-node.attrs.at("xml:lang", default: none)

  (
    lang: lang,
    terms: parse-locale-terms(locale-node),
    dates: parse-locale-dates(locale-node),
    options: parse-locale-options(locale-node),
  )
}

/// Merge two locale objects (second overrides first)
#let merge-locales(base, override) = {
  if override == none { return base }
  if base == none { return override }

  let merged-terms = base.terms
  for (k, v) in override.terms.pairs() {
    merged-terms.insert(k, v)
  }

  let merged-dates = base.dates
  for (k, v) in override.dates.pairs() {
    merged-dates.insert(k, v)
  }

  let merged-options = base.options
  for (k, v) in override.options.pairs() {
    merged-options.insert(k, v)
  }

  (
    lang: override.lang,
    terms: merged-terms,
    dates: merged-dates,
    options: merged-options,
  )
}

/// Parse a macro definition
#let parse-macro(macro-node) = {
  (
    name: macro-node.attrs.at("name", default: ""),
    children: macro-node.at("children", default: ()),
  )
}

/// Parse citation element
#let parse-citation(citation-node) = {
  if citation-node == none { return none }

  let layouts = find-children(citation-node, "layout")
  let sort = find-child(citation-node, "sort")

  (
    // Citation attributes
    collapse: citation-node.attrs.at("collapse", default: none),
    cite-group-delimiter: citation-node.attrs.at(
      "cite-group-delimiter",
      default: ", ",
    ),
    after-collapse-delimiter: citation-node.attrs.at(
      "after-collapse-delimiter",
      default: none,
    ),
    year-suffix-delimiter: citation-node.attrs.at(
      "year-suffix-delimiter",
      default: none,
    ),
    disambiguate-add-names: citation-node.attrs.at(
      "disambiguate-add-names",
      default: "false",
    )
      == "true",
    disambiguate-add-givenname: citation-node.attrs.at(
      "disambiguate-add-givenname",
      default: "false",
    )
      == "true",
    givenname-disambiguation-rule: citation-node.attrs.at(
      "givenname-disambiguation-rule",
      default: "by-cite",
    ),
    disambiguate-add-year-suffix: citation-node.attrs.at(
      "disambiguate-add-year-suffix",
      default: "false",
    )
      == "true",
    // Et-al settings (inheritable name options)
    et-al-min: if citation-node.attrs.at("et-al-min", default: none) != none {
      int(citation-node.attrs.at("et-al-min"))
    } else { none },
    et-al-use-first: if citation-node.attrs.at("et-al-use-first", default: none)
      != none {
      int(citation-node.attrs.at("et-al-use-first"))
    } else { none },
    et-al-subsequent-min: if citation-node.attrs.at(
      "et-al-subsequent-min",
      default: none,
    )
      != none {
      int(citation-node.attrs.at("et-al-subsequent-min"))
    } else { none },
    et-al-subsequent-use-first: if citation-node.attrs.at(
      "et-al-subsequent-use-first",
      default: none,
    )
      != none {
      int(citation-node.attrs.at("et-al-subsequent-use-first"))
    } else { none },
    // Layouts (CSL-M: may have locale-specific variants)
    layouts: layouts.map(l => (
      locale: l.attrs.at("locale", default: none),
      delimiter: l.attrs.at("delimiter", default: ", "),
      prefix: l.attrs.at("prefix", default: ""),
      suffix: l.attrs.at("suffix", default: ""),
      vertical-align: l.attrs.at("vertical-align", default: none),
      children: filter-element-children(l.at("children", default: ())),
    )),
    // Sort
    sort: if sort != none {
      find-children(sort, "key").map(k => (
        variable: k.attrs.at("variable", default: ""),
        macro: k.attrs.at("macro", default: none),
        sort: k.attrs.at("sort", default: "ascending"),
        // Names sorting attributes (CSL spec: override et-al settings for sort keys)
        names-min: if k.attrs.at("names-min", default: none) != none {
          int(k.attrs.at("names-min"))
        } else { none },
        names-use-first: if k.attrs.at("names-use-first", default: none)
          != none {
          int(k.attrs.at("names-use-first"))
        } else { none },
        names-use-last: if k.attrs.at("names-use-last", default: none) != none {
          k.attrs.at("names-use-last") == "true"
        } else { none },
      ))
    } else { () },
  )
}

/// Parse bibliography element
#let parse-bibliography(bib-node) = {
  if bib-node == none { return none }

  let layouts = find-children(bib-node, "layout")
  let sort = find-child(bib-node, "sort")

  (
    // Bibliography attributes
    hanging-indent: bib-node.attrs.at("hanging-indent", default: "false")
      == "true",
    second-field-align: bib-node.attrs.at("second-field-align", default: none),
    line-spacing: int(bib-node.attrs.at("line-spacing", default: "1")),
    entry-spacing: int(bib-node.attrs.at("entry-spacing", default: "1")),
    subsequent-author-substitute: bib-node.attrs.at(
      "subsequent-author-substitute",
      default: none,
    ),
    subsequent-author-substitute-rule: bib-node.attrs.at(
      "subsequent-author-substitute-rule",
      default: "complete-all",
    ),
    // Et-al settings
    et-al-min: int(bib-node.attrs.at("et-al-min", default: "4")),
    et-al-use-first: int(bib-node.attrs.at("et-al-use-first", default: "3")),
    et-al-use-last: bib-node.attrs.at("et-al-use-last", default: "false")
      == "true",
    // Layouts (may have locale-specific variants)
    // Note: suffix defaults to empty - CSL puts suffix on child elements, not layout
    layouts: layouts.map(l => (
      locale: l.attrs.at("locale", default: none),
      prefix: l.attrs.at("prefix", default: ""),
      suffix: l.attrs.at("suffix", default: ""),
      delimiter: l.attrs.at("delimiter", default: ""),
      children: l.at("children", default: ()),
    )),
    // Sort
    sort: if sort != none {
      find-children(sort, "key").map(k => (
        variable: k.attrs.at("variable", default: ""),
        macro: k.attrs.at("macro", default: none),
        sort: k.attrs.at("sort", default: "ascending"),
        // Names sorting attributes (CSL spec: override et-al settings for sort keys)
        names-min: if k.attrs.at("names-min", default: none) != none {
          int(k.attrs.at("names-min"))
        } else { none },
        names-use-first: if k.attrs.at("names-use-first", default: none)
          != none {
          int(k.attrs.at("names-use-first"))
        } else { none },
        names-use-last: if k.attrs.at("names-use-last", default: none) != none {
          k.attrs.at("names-use-last") == "true"
        } else { none },
      ))
    } else { () },
  )
}

/// Load and parse an external locale file
///
/// - locale-content: Locale XML content (use `read("locales-en-US.xml")`)
/// Returns: Parsed locale object
#let parse-locale-file(locale-content) = {
  let xml-tree = xml(bytes(locale-content))
  let root = if type(xml-tree) == array {
    xml-tree.find(n => (
      type(n) == dictionary and n.at("tag", default: "") == "locale"
    ))
  } else {
    xml-tree
  }

  if root == none {
    panic("Invalid locale file: no <locale> element found")
  }

  parse-locale(root)
}

/// Main CSL parser
///
/// - xml-tree: Result of xml() on CSL content
/// - external-locales: Optional dict of lang -> locale object for external locales
/// Returns: Structured CSL style object
#let parse-csl(xml-tree, external-locales: (:)) = {
  // xml() returns an array, get the root element
  let root = if type(xml-tree) == array {
    xml-tree.find(n => (
      type(n) == dictionary and n.at("tag", default: "") == "style"
    ))
  } else {
    xml-tree
  }

  if root == none {
    panic("Invalid CSL: no <style> element found")
  }

  let attrs = root.at("attrs", default: (:))

  // Parse info
  let info = find-child(root, "info")
  let title = if info != none {
    let title-node = find-child(info, "title")
    if title-node != none { get-text-content(title-node) } else { "" }
  } else { "" }

  // Determine default locale
  let default-locale = attrs.at("default-locale", default: "en-US")

  // Start with external locale if available, otherwise use built-in fallback
  let base-locale = external-locales.at(default-locale, default: none)
  if base-locale == none {
    base-locale = create-fallback-locale(default-locale)
  }

  // Parse inline locales and organize by language
  // CSL-M: locales dict stores language-specific locales for layout-based switching
  let inline-locale-nodes = find-children(root, "locale")
  let locales = (:)
  let merged-locale = base-locale

  for loc-node in inline-locale-nodes {
    let parsed = parse-locale(loc-node)
    // XML parser converts xml:lang to lang
    let lang = loc-node.attrs.at("lang", default: none)

    if lang != none {
      // Store language-specific locale (merge with built-in for that language)
      let lang-base = create-fallback-locale(lang)
      let lang-locale = merge-locales(lang-base, parsed)
      locales.insert(lang, lang-locale)
    }

    // Also merge into default locale (CSL fallback behavior)
    merged-locale = merge-locales(merged-locale, parsed)
  }

  // Ensure default locale is in the locales dict
  locales.insert(default-locale, merged-locale)

  // Parse macros
  let macro-nodes = find-children(root, "macro")
  let macros = (:)
  for m in macro-nodes {
    let parsed = parse-macro(m)
    macros.insert(parsed.name, parsed)
  }

  // Parse citation and bibliography
  let citation = parse-citation(find-child(root, "citation"))
  let bibliography = parse-bibliography(find-child(root, "bibliography"))

  (
    // Style attributes
    class: attrs.at("class", default: "in-text"),
    version: attrs.at("version", default: "1.0"),
    default-locale: default-locale,
    name-as-sort-order: attrs.at("name-as-sort-order", default: none),
    sort-separator: attrs.at("sort-separator", default: ", "),
    demote-non-dropping-particle: attrs.at(
      "demote-non-dropping-particle",
      default: "display-and-sort",
    ),
    initialize-with: attrs.at("initialize-with", default: none),
    initialize-with-hyphen: attrs.at("initialize-with-hyphen", default: "true")
      == "true",
    page-range-format: attrs.at("page-range-format", default: none),
    name-delimiter: attrs.at("name-delimiter", default: ", "),
    names-delimiter: attrs.at("names-delimiter", default: ", "),
    and-term: attrs.at("and", default: none), // "text" or "symbol"
    // Parsed components
    title: title,
    locale: merged-locale,
    locales: locales, // CSL-M: language-specific locales for layout switching
    macros: macros,
    citation: citation,
    bibliography: bibliography,
  )
}
