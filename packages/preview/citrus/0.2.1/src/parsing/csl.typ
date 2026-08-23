// citrus - CSL XML Parser
//
// Parses CSL XML into a structured Typst object

#import "locales/mod.typ": create-fallback-locale
#import "../core/utils.typ": safe-int

// Module-level regex pattern (avoid recompilation)
#let _re-basic-ws = regex("^[ \t\n\r]+|[ \t\n\r]+$")

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

/// Extract inheritable name formatting attributes from an element's attrs
/// These attributes can appear on style, citation, bibliography, or name elements
/// and follow a cascade: name -> citation/bib -> style -> defaults
///
/// When is-style-level is true, applies CSL spec defaults for style-level fallbacks.
/// Otherwise returns none for unset attributes (allowing inheritance).
#let extract-name-attrs(attrs, is-style-level: false) = {
  (
    "and": attrs.at("and", default: none), // "text" or "symbol"
    name-form: if is-style-level {
      attrs.at("name-form", default: "long")
    } else {
      attrs.at("name-form", default: none)
    },
    name-delimiter: if is-style-level {
      attrs.at("name-delimiter", default: ", ")
    } else {
      attrs.at("name-delimiter", default: none)
    },
    names-delimiter: if is-style-level {
      attrs.at("names-delimiter", default: ", ")
    } else {
      attrs.at("names-delimiter", default: none)
    },
    name-as-sort-order: attrs.at("name-as-sort-order", default: none),
    sort-separator: if is-style-level {
      attrs.at("sort-separator", default: ", ")
    } else {
      attrs.at("sort-separator", default: none)
    },
    initialize-with: attrs.at("initialize-with", default: none),
    initialize-with-hyphen: if attrs.at("initialize-with-hyphen", default: none)
      != none {
      attrs.at("initialize-with-hyphen") == "true"
    } else if is-style-level {
      true // CSL spec default is true
    } else {
      none
    },
    delimiter-precedes-et-al: attrs.at(
      "delimiter-precedes-et-al",
      default: none,
    ),
    delimiter-precedes-last: attrs.at("delimiter-precedes-last", default: none),
    et-al-min: safe-int(attrs.at("et-al-min", default: none), default: none),
    et-al-use-first: safe-int(
      attrs.at("et-al-use-first", default: none),
      default: none,
    ),
    et-al-use-last: if attrs.at("et-al-use-last", default: none) != none {
      attrs.at("et-al-use-last").trim() == "true"
    } else { none },
    et-al-subsequent-min: safe-int(
      attrs.at("et-al-subsequent-min", default: none),
      default: none,
    ),
    et-al-subsequent-use-first: safe-int(
      attrs.at("et-al-subsequent-use-first", default: none),
      default: none,
    ),
  )
}

/// Get text content from a node (handles nested text)
/// Trims only XML formatting whitespace (regular spaces, tabs, newlines) but preserves
/// intentional Unicode whitespace (like punctuation space \u{2008}) that may be part of term values
#let get-text-content(node) = {
  // Helper to trim only basic whitespace, preserving Unicode spaces
  let trim-basic-ws = text => {
    // Only trim regular space, tab, newline, carriage return
    text.replace(_re-basic-ws, "")
  }

  if type(node) == str { return trim-basic-ws(node) }
  if type(node) != dictionary { return "" }
  let children = node.at("children", default: ())
  if children.len() == 0 { return "" }
  let text = children
    .map(c => {
      if type(c) == str { c } else { "" }
    })
    .join("")
  if text == none { return "" }
  trim-basic-ws(text)
}

/// Recursively check if a node tree contains <text variable="year-suffix"/>
/// This is used to determine whether year-suffix should be auto-appended to dates
/// CSL spec: "By default, the year-suffix is appended the first year rendered through
/// cs:date... but its location can be controlled by explicitly rendering the
/// 'year-suffix' variable using cs:text"
///
/// - node: XML node to check
/// - macros: Dictionary of macro name -> macro node (for following macro references)
/// - visited: Set of already-visited macro names (to prevent infinite loops)
#let _has-explicit-year-suffix(node, macros: (:), visited: ()) = {
  if type(node) != dictionary { return false }

  let tag = node.at("tag", default: "")

  // Check if this node is <text variable="year-suffix"/>
  if tag == "text" {
    let attrs = node.at("attrs", default: (:))
    if attrs.at("variable", default: "") == "year-suffix" {
      return true
    }
    // Check if this is a macro call and follow it
    let macro-name = attrs.at("macro", default: "")
    if macro-name != "" and macro-name not in visited {
      let macro-node = macros.at(macro-name, default: none)
      if macro-node != none {
        if _has-explicit-year-suffix(
          macro-node,
          macros: macros,
          visited: visited + (macro-name,),
        ) {
          return true
        }
      }
    }
  }

  // Recursively check children
  let children = node.at("children", default: ())
  for child in children {
    if _has-explicit-year-suffix(child, macros: macros, visited: visited) {
      return true
    }
  }
  false
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
    if term-node.attrs.at("gender-form", default: none) != none {
      continue
    }
    let parsed = parse-term(term-node)
    if parsed.name == "" { continue }

    let key = if parsed.form == "long" { parsed.name } else {
      parsed.name + "-" + parsed.form
    }
    terms.insert(key, parsed.value)
  }

  terms
}

#let parse-locale-ordinal-genders(locale-node) = {
  let forms = (:)
  let terms-node = find-child(locale-node, "terms")
  if terms-node == none { return forms }

  for term-node in find-children(terms-node, "term") {
    let name = term-node.attrs.at("name", default: "")
    let gender = term-node.attrs.at("gender-form", default: none)
    if name != "" and gender != none and name.starts-with("ordinal-") {
      forms.insert(name + ":" + gender, get-text-content(term-node))
    }
  }

  forms
}

/// Parse date format from locale
#let parse-locale-dates(locale-node) = {
  let dates = (:)

  for date-node in find-children(locale-node, "date") {
    let form = date-node.attrs.at("form", default: "numeric")
    let delimiter = date-node.attrs.at("delimiter", default: "")
    let parts = find-children(date-node, "date-part").map(p => (
      name: p.attrs.at("name", default: ""),
      form: p.attrs.at("form", default: ""),
      prefix: p.attrs.at("prefix", default: ""),
      suffix: p.attrs.at("suffix", default: ""),
      text-case: p.attrs.at("text-case", default: ""),
      range-delimiter: p.attrs.at("range-delimiter", default: "–"),
    ))
    dates.insert(form, (parts: parts, delimiter: delimiter))
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
    limit-day-ordinals-to-day-1: attrs.at(
      "limit-day-ordinals-to-day-1",
      default: "false",
    )
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
    ordinal-gender-forms: parse-locale-ordinal-genders(locale-node),
    term-genders: (:),
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

  let merged-term-genders = base.at("term-genders", default: (:))
  for (k, v) in override.at("term-genders", default: (:)).pairs() {
    merged-term-genders.insert(k, v)
  }

  let merged-ordinal-gender-forms = base.at(
    "ordinal-gender-forms",
    default: (:),
  )
  for (k, v) in override.at("ordinal-gender-forms", default: (:)).pairs() {
    merged-ordinal-gender-forms.insert(k, v)
  }

  (
    lang: override.lang,
    terms: merged-terms,
    dates: merged-dates,
    options: merged-options,
    term-genders: merged-term-genders,
    ordinal-gender-forms: merged-ordinal-gender-forms,
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
#let parse-citation(citation-node, macros: (:)) = {
  if citation-node == none { return none }

  let layouts = find-children(citation-node, "layout")
  let sort = find-child(citation-node, "sort")

  // Extract inheritable name attributes using the unified helper
  let name-attrs = extract-name-attrs(citation-node.attrs)

  (
    // Citation-specific attributes
    collapse: citation-node.attrs.at("collapse", default: none),
    cite-group-delimiter: citation-node.attrs.at(
      "cite-group-delimiter",
      default: none,
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
    // CSL spec: check if year-suffix is explicitly rendered via <text variable="year-suffix"/>
    // Also check in referenced macros
    has-explicit-year-suffix: _has-explicit-year-suffix(
      citation-node,
      macros: macros,
    ),
    // Inheritable name attributes (from unified helper)
    ..name-attrs,
    // Layouts (CSL-M: may have locale-specific variants)
    layouts: layouts.map(l => (
      locale: l.attrs.at("locale", default: none),
      delimiter: l.attrs.at("delimiter", default: ""),
      prefix: l.attrs.at("prefix", default: ""),
      suffix: l.attrs.at("suffix", default: ""),
      vertical-align: l.attrs.at("vertical-align", default: none),
      // Font formatting
      font-weight: l.attrs.at("font-weight", default: none),
      font-style: l.attrs.at("font-style", default: none),
      font-variant: l.attrs.at("font-variant", default: none),
      text-decoration: l.attrs.at("text-decoration", default: none),
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
#let parse-bibliography(bib-node, macros: (:)) = {
  if bib-node == none { return none }

  let layouts = find-children(bib-node, "layout")
  let sort = find-child(bib-node, "sort")

  // Extract inheritable name attributes using the unified helper
  let name-attrs = extract-name-attrs(bib-node.attrs)

  (
    // Bibliography-specific attributes
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
    // CSL spec: check if year-suffix is explicitly rendered via <text variable="year-suffix"/>
    // Also check in referenced macros
    has-explicit-year-suffix: _has-explicit-year-suffix(
      bib-node,
      macros: macros,
    ),
    // Inheritable name attributes (from unified helper)
    ..name-attrs,
    // Layouts (may have locale-specific variants)
    // Note: suffix defaults to empty - CSL puts suffix on child elements, not layout
    layouts: layouts.map(l => (
      locale: l.attrs.at("locale", default: none),
      prefix: l.attrs.at("prefix", default: ""),
      suffix: l.attrs.at("suffix", default: ""),
      delimiter: l.attrs.at("delimiter", default: ""),
      // Font formatting
      font-weight: l.attrs.at("font-weight", default: none),
      font-style: l.attrs.at("font-style", default: none),
      font-variant: l.attrs.at("font-variant", default: none),
      text-decoration: l.attrs.at("text-decoration", default: none),
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

  let langless-locales = ()
  let lang-locales = ()
  for loc-node in inline-locale-nodes {
    // XML parser converts xml:lang to lang
    let lang = loc-node.attrs.at("lang", default: none)
    if lang != none {
      lang-locales.push((lang: lang, node: loc-node))
    } else {
      langless-locales.push(loc-node)
    }
  }

  for loc-node in langless-locales {
    let parsed = parse-locale(loc-node)
    // Locale without lang applies to all (merge into default)
    merged-locale = merge-locales(merged-locale, parsed)
  }

  for lang-entry in lang-locales {
    let lang = lang-entry.lang
    let parsed = parse-locale(lang-entry.node)
    // Store language-specific locale (merge with built-in for that language)
    let lang-base = create-fallback-locale(lang)
    let lang-locale = merge-locales(lang-base, parsed)
    locales.insert(lang, lang-locale)

    // Only merge into default locale if lang matches default-locale prefix
    // e.g., "en" matches "en-US", "es" matches "es-ES"
    let default-prefix = default-locale.split("-").first()
    let lang-prefix = lang.split("-").first()
    if lang-prefix == default-prefix {
      merged-locale = merge-locales(merged-locale, parsed)
    }
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

  // Parse citation and bibliography (pass macros for has-explicit-year-suffix check)
  let citation = parse-citation(find-child(root, "citation"), macros: macros)
  let bibliography = parse-bibliography(
    find-child(root, "bibliography"),
    macros: macros,
  )

  // Extract inheritable name attributes at style level (with defaults)
  let name-attrs = extract-name-attrs(attrs, is-style-level: true)

  (
    // Style-specific attributes
    class: attrs.at("class", default: "in-text"),
    version: attrs.at("version", default: "1.0"),
    default-locale: default-locale,
    demote-non-dropping-particle: attrs.at(
      "demote-non-dropping-particle",
      default: "display-and-sort",
    ),
    page-range-format: attrs.at("page-range-format", default: none),
    names-delimiter: attrs.at("names-delimiter", default: ", "),
    // Inheritable name attributes (from unified helper)
    ..name-attrs,
    // Parsed components
    title: title,
    locale: merged-locale,
    locales: locales, // CSL-M: language-specific locales for layout switching
    macros: macros,
    citation: citation,
    bibliography: bibliography,
  )
}
