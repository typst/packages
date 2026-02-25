// citrus - Disambiguation Module
//
// Implements CSL disambiguation according to the specification.
// Disambiguation is applied in order:
// 1. disambiguate-add-givenname: Expand initials to full given names
// 2. disambiguate-add-names: Add more author names
// 3. disambiguate condition: Render with disambiguate="true"
// 4. disambiguate-add-year-suffix: Add a, b, c to years
//
// Key insight: Disambiguation is based on RENDERED citation form, not raw data.
// Two citations are ambiguous if they render identically.

#import "../core/state.typ": get-entry-year, get-first-author-family
#import "variables.typ": get-variable

// Module-level regex patterns (avoid recompilation)
#let _whitespace-pattern = regex("\\s+")
#let _re-non-alpha = regex("[^A-Za-z]")
#let _re-whitespace-dot = regex("[\\s\\.]+")
#let _re-whitespace-or-dot = regex("[\\s\\.]")

// =============================================================================
// Citation Label Detection (for disambiguation)
// =============================================================================

#let _node-uses-citation-label(node, macros) = {
  if type(node) != dictionary { return false }
  let tag = node.at("tag", default: "")

  if tag == "text" {
    let attrs = node.at("attrs", default: (:))
    if attrs.at("variable", default: "") == "citation-label" {
      return true
    }
    let macro-name = attrs.at("macro", default: none)
    if macro-name != none {
      let macro-def = macros.at(macro-name, default: none)
      if macro-def != none {
        for child in macro-def.at("children", default: ()) {
          if _node-uses-citation-label(child, macros) { return true }
        }
      }
    }
  }

  for child in node.at("children", default: ()) {
    if _node-uses-citation-label(child, macros) { return true }
  }

  false
}

#let _citation-uses-label(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return false }
  let layouts = citation.at("layouts", default: ())
  let macros = style.at("macros", default: (:))
  layouts.any(l => _node-uses-citation-label(l, macros))
}

#let _node-uses-date(node, macros) = {
  if type(node) != dictionary { return false }
  let tag = node.at("tag", default: "")

  if tag == "date" {
    let attrs = node.at("attrs", default: (:))
    if attrs.at("variable", default: "") != "" { return true }
  }

  if tag == "text" {
    let attrs = node.at("attrs", default: (:))
    let macro-name = attrs.at("macro", default: none)
    if macro-name != none {
      let macro-def = macros.at(macro-name, default: none)
      if macro-def != none {
        for child in macro-def.at("children", default: ()) {
          if _node-uses-date(child, macros) { return true }
        }
      }
    }
  }

  for child in node.at("children", default: ()) {
    if _node-uses-date(child, macros) { return true }
  }

  false
}

#let _citation-uses-date(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return false }
  let layouts = citation.at("layouts", default: ())
  let macros = style.at("macros", default: (:))
  layouts.any(l => _node-uses-date(l, macros))
}

#let _collect-date-vars(node, macros) = {
  if type(node) != dictionary { return () }
  let vars = ()
  let tag = node.at("tag", default: "")

  if tag == "date" {
    let attrs = node.at("attrs", default: (:))
    let variable = attrs.at("variable", default: "issued")
    vars.push(variable)
  }

  if tag == "text" {
    let attrs = node.at("attrs", default: (:))
    let macro-name = attrs.at("macro", default: none)
    if macro-name != none {
      let macro-def = macros.at(macro-name, default: none)
      if macro-def != none {
        for child in macro-def.at("children", default: ()) {
          vars = vars + _collect-date-vars(child, macros)
        }
      }
    }
  }

  for child in node.at("children", default: ()) {
    vars = vars + _collect-date-vars(child, macros)
  }

  vars
}

#let _collect-name-vars(node, macros) = {
  if type(node) != dictionary { return () }
  let vars = ()
  let tag = node.at("tag", default: "")

  if tag == "names" {
    let attrs = node.at("attrs", default: (:))
    let variable = attrs.at("variable", default: none)
    if variable != none { vars.push(variable) }
  }

  if tag == "text" {
    let attrs = node.at("attrs", default: (:))
    let macro-name = attrs.at("macro", default: none)
    if macro-name != none {
      let macro-def = macros.at(macro-name, default: none)
      if macro-def != none {
        for child in macro-def.at("children", default: ()) {
          vars = vars + _collect-name-vars(child, macros)
        }
      }
    }
  }

  for child in node.at("children", default: ()) {
    vars = vars + _collect-name-vars(child, macros)
  }

  vars
}

#let _collect-disambiguate-vars(node, macros) = {
  if type(node) != dictionary { return () }
  let vars = ()
  let tag = node.at("tag", default: "")

  if tag == "text" {
    let attrs = node.at("attrs", default: (:))
    let variable = attrs.at("variable", default: none)
    if variable != none { vars.push(variable) }
    let macro-name = attrs.at("macro", default: none)
    if macro-name != none {
      let macro-def = macros.at(macro-name, default: none)
      if macro-def != none {
        for child in macro-def.at("children", default: ()) {
          vars = vars + _collect-disambiguate-vars(child, macros)
        }
      }
    }
  }

  if tag == "number" or tag == "label" {
    let attrs = node.at("attrs", default: (:))
    let variable = attrs.at("variable", default: none)
    if variable != none { vars.push(variable) }
  }

  for child in node.at("children", default: ()) {
    vars = vars + _collect-disambiguate-vars(child, macros)
  }

  vars
}

#let _collect-disambiguate-step-vars-from-node(node, macros) = {
  if type(node) != dictionary { return () }
  let steps = ()
  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())

  if (tag == "if" or tag == "else-if") and "disambiguate" in attrs {
    steps.push(_collect-disambiguate-vars(node, macros).dedup())
  }

  for child in children {
    steps = steps + _collect-disambiguate-step-vars-from-node(child, macros)
  }

  steps
}

#let _collect-disambiguate-step-vars(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return () }
  let layouts = citation.at("layouts", default: ())
  let macros = style.at("macros", default: (:))
  let steps = ()

  for layout in layouts {
    steps = steps + _collect-disambiguate-step-vars-from-node(layout, macros)
  }

  steps
}

#let _annotate-disambiguate-node(node, step) = {
  if type(node) != dictionary { return (node, step) }
  let tag = node.at("tag", default: "")
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())
  let current-step = step

  if (tag == "if" or tag == "else-if") and "disambiguate" in attrs {
    current-step = current-step + 1
    attrs = (..attrs, "_disambiguate-step": str(current-step))
  }

  let new-children = ()
  for child in children {
    let (updated, next-step) = _annotate-disambiguate-node(child, current-step)
    current-step = next-step
    new-children.push(updated)
  }

  ((..node, attrs: attrs, children: new-children), current-step)
}

#let annotate-disambiguate-steps(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return style }
  let layouts = citation.at("layouts", default: ())
  let updated-layouts = ()
  let step = 0
  for layout in layouts {
    let (updated, next-step) = _annotate-disambiguate-node(layout, step)
    step = next-step
    updated-layouts.push(updated)
  }
  let new-citation = (..citation, layouts: updated-layouts)
  (..style, citation: new-citation)
}

#let _get-disambiguate-value(entry, var, style) = {
  let ctx = (
    fields: entry.at("fields", default: (:)),
    entry-type: entry.at("type", default: ""),
    style: style,
    names: entry.at("parsed_names", default: (:)),
  )
  let value = get-variable(ctx, var)
  if value == none { "" } else { str(value) }
}

#let _citation-name-vars(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return () }
  let layouts = citation.at("layouts", default: ())
  let macros = style.at("macros", default: (:))
  let vars = ()
  for layout in layouts {
    vars = vars + _collect-name-vars(layout, macros)
  }
  vars.dedup()
}

#let _citation-date-vars(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return () }
  let layouts = citation.at("layouts", default: ())
  let macros = style.at("macros", default: (:))
  let vars = ()
  for layout in layouts {
    vars = vars + _collect-date-vars(layout, macros)
  }
  let allowed = ("issued", "original-date", "event-date")
  vars.filter(v => v in allowed).dedup()
}

#let _find-first-names-node(node, macros) = {
  if type(node) != dictionary { return none }
  let tag = node.at("tag", default: "")
  if tag == "names" { return node }

  if tag == "text" {
    let attrs = node.at("attrs", default: (:))
    let macro-name = attrs.at("macro", default: none)
    if macro-name != none {
      let macro-def = macros.at(macro-name, default: none)
      if macro-def != none {
        for child in macro-def.at("children", default: ()) {
          let found = _find-first-names-node(child, macros)
          if found != none { return found }
        }
      }
    }
  }

  for child in node.at("children", default: ()) {
    let found = _find-first-names-node(child, macros)
    if found != none { return found }
  }
  none
}

#let _citation-names-use-initials(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return false }
  let layouts = citation.at("layouts", default: ())
  let macros = style.at("macros", default: (:))

  for layout in layouts {
    let names-node = _find-first-names-node(layout, macros)
    if names-node == none { continue }
    let attrs = names-node.at("attrs", default: (:))
    let init = attrs.at("initialize", default: none)
    if init == "false" { return false }
    let init-with = attrs.at("initialize-with", default: none)
    if init-with != none { return true }
    for child in names-node.at("children", default: ()) {
      if type(child) == dictionary and child.at("tag", default: "") == "name" {
        let child-attrs = child.at("attrs", default: (:))
        let child-init = child-attrs.at("initialize", default: none)
        if child-init == "false" { return false }
        let child-init-with = child-attrs.at(
          "initialize-with",
          default: none,
        )
        if child-init-with != none { return true }
      }
    }
    return false
  }
  false
}

#let _citation-name-base-level(style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return 0 }
  let layouts = citation.at("layouts", default: ())
  let macros = style.at("macros", default: (:))

  for layout in layouts {
    let names-node = _find-first-names-node(layout, macros)
    if names-node == none { continue }
    let names-attrs = names-node.at("attrs", default: (:))
    let name-form = names-attrs.at("form", default: none)
    let init = names-attrs.at("initialize", default: none)
    let init-with = names-attrs.at("initialize-with", default: none)

    for child in names-node.at("children", default: ()) {
      if type(child) == dictionary and child.at("tag", default: "") == "name" {
        let child-attrs = child.at("attrs", default: (:))
        name-form = child-attrs.at("form", default: name-form)
        init = child-attrs.at("initialize", default: init)
        init-with = child-attrs.at("initialize-with", default: init-with)
        break
      }
    }

    if name-form == "short" { return 0 }
    if init == "false" { return 2 }
    if init-with != none { return 1 }
    return 2
  }

  0
}

#let _date-year-from-field(value) = {
  if value == none { return "" }
  let s = str(value)
  if s == "" { return "" }
  let parts = s.split("-")
  if parts.len() > 0 { parts.first() } else { s }
}

#let _get-entry-date-year(entry, variable) = {
  let fields = entry.at("fields", default: (:))
  if variable == "issued" {
    get-entry-year(entry)
  } else if variable == "original-date" {
    _date-year-from-field(fields.at("origdate", default: ""))
  } else if variable == "event-date" {
    _date-year-from-field(fields.at("eventdate", default: ""))
  } else if variable == "accessed" {
    _date-year-from-field(fields.at("urldate", default: ""))
  } else {
    _date-year-from-field(fields.at(variable, default: ""))
  }
}

#let _build-citation-label(entry) = {
  let fields = entry.at("fields", default: (:))
  let custom = fields.at("citation-label", default: "")
  if custom != "" { return custom }

  let names = entry.at("parsed_names", default: (:))
  let primary = if names.at("author", default: ()).len() > 0 {
    names.at("author", default: ())
  } else if names.at("editor", default: ()).len() > 0 {
    names.at("editor", default: ())
  } else if names.at("translator", default: ()).len() > 0 {
    names.at("translator", default: ())
  } else {
    ()
  }

  let family-list = primary
    .map(n => {
      let literal = n.at("literal", default: "")
      let raw = if literal != "" { literal } else {
        n.at("family", default: "")
      }
      if raw == "" { return "" }
      let parts = raw.split(" ").filter(p => p != "")
      while parts.len() > 1 and parts.first() == lower(parts.first()) {
        parts = parts.slice(1)
      }
      parts.join(" ")
    })
    .filter(x => x != "")

  let label = if family-list.len() > 0 {
    let cleaned = family-list.map(x => x.replace(_re-non-alpha, ""))
    if cleaned.len() == 1 {
      let s = cleaned.first()
      if s.len() >= 4 { s.slice(0, 4) } else { s }
    } else if cleaned.len() == 2 {
      let a = cleaned.at(0)
      let b = cleaned.at(1)
      let a2 = if a.len() >= 2 { a.slice(0, 2) } else { a }
      let b2 = if b.len() >= 2 { b.slice(0, 2) } else { b }
      a2 + b2
    } else {
      cleaned
        .slice(0, 4)
        .map(s => if s.len() > 0 { s.slice(0, 1) } else { "" })
        .join()
    }
  } else {
    ""
  }

  if label == "" { return "" }

  let year = get-entry-year(entry)
  let year-str = str(year)
  let year-suffix = if year-str.len() >= 2 {
    year-str.slice(year-str.len() - 2)
  } else {
    year-str
  }

  label + year-suffix
}

// =============================================================================
// Year Suffix Computation
// =============================================================================

/// Compute year suffixes for entries that need disambiguation
///
/// Groups entries by (first-author, year) and assigns a, b, c, ... suffixes
/// to entries within the same group.
///
/// - entries: Array of entry IRs
/// - style: Parsed CSL style
/// Returns: Dictionary of key -> suffix (e.g., "smith2020" -> "a")
#let compute-year-suffixes(entries, style) = {
  // Check if style uses year-suffix disambiguation
  let citation = style.at("citation", default: none)
  if citation == none { return (:) }

  let use-year-suffix = citation.at(
    "disambiguate-add-year-suffix",
    default: false,
  )
  if not use-year-suffix { return (:) }

  // Group entries by (first-author-family, year)
  // Record original index to preserve bibliography order per CSL spec:
  // "The assignment of year-suffixes follows the order of the bibliographies entries"
  let groups = (:)
  for (idx, e) in entries.enumerate() {
    let entry = e.entry
    let author = get-first-author-family(entry)
    let year = get-entry-year(entry)
    let group-key = lower(author) + "|" + str(year)

    if group-key not in groups {
      groups.insert(group-key, ())
    }
    groups
      .at(group-key)
      .push((
        key: e.key,
        index: idx, // Position in bibliography (already sorted)
      ))
  }

  // Assign suffixes to groups with multiple entries
  let suffixes = (:)
  let suffix-chars = "abcdefghijklmnopqrstuvwxyz"

  for (group-key, items) in groups.pairs() {
    if items.len() > 1 {
      // Sort by bibliography order (index), not by title
      let sorted-items = items.sorted(key: it => it.index)

      for (i, item) in sorted-items.enumerate() {
        if i < suffix-chars.len() {
          suffixes.insert(item.key, suffix-chars.at(i))
        }
      }
    }
  }

  suffixes
}

// =============================================================================
// Name Disambiguation
// =============================================================================

/// Get all authors from an entry as a list of parsed names
///
/// - entry: Entry from citegeist
/// Returns: Array of name dicts with (family, given, literal)
#let _get-entry-names(entry, variable) = {
  // Note: field name is parsed_names (underscore) from citegeist
  // CSL-JSON entries store authors directly in parsed_names, not in fields
  let parsed = entry.at("parsed_names", default: (:))
  parsed.at(variable, default: ())
}

#let get-all-authors(entry) = {
  _get-entry-names(entry, "author")
}

/// Get initials from a given name
///
/// - given: Full given name string (e.g., "John Michael")
/// Returns: Initials string (e.g., "J. M.")
#let get-initials(given) = {
  if given == none or given == "" { return "" }
  let parts = given.split(_re-whitespace-dot)
  parts
    .filter(p => p.len() > 0)
    .map(p => {
      // Handle Unicode - use clusters for first character
      let clusters = p.clusters()
      if clusters.len() > 0 { clusters.at(0) + "." } else { "" }
    })
    .join(" ")
}

#let _normalize-given(given) = {
  if given == none { return "" }
  let lowered = lower(given)
  lowered.replace(_re-whitespace-or-dot, "")
}

#let _name-family-key(name) = {
  let literal = name.at("literal", default: "")
  if literal != "" { return literal }
  let family = name.at("family", default: "")
  let prefix = name.at("prefix", default: "")
  if prefix == "" { return family }
  if family == "" { return prefix }
  if prefix.ends-with("'") or prefix.ends-with("-") {
    prefix + family
  } else {
    prefix + " " + family
  }
}

/// Build author short representation with given disambiguation level
///
/// - names: Array of parsed name dicts
/// - et-al-use-first: Number of names before et al.
/// - expand-names: Number of additional names to show beyond et-al-use-first
/// - givenname-level: 0 = none, 1 = initials, 2 = full given
/// Returns: String representation for comparison
#let build-author-key(
  names,
  et-al-use-first,
  et-al-min: none,
  expand-names: 0,
  givenname-level: 0,
  givenname-levels: none,
) = {
  if names.len() == 0 { return "" }

  let use-et-al = (
    et-al-min != none
      and names.len() >= et-al-min
      and et-al-use-first < names.len()
  )
  let base-count = if use-et-al { et-al-use-first } else { names.len() }
  let show-count = calc.min(names.len(), base-count + expand-names)
  let parts = ()

  for i in range(show-count) {
    let name = names.at(i)
    let family = _name-family-key(name)

    let level = if (
      givenname-levels != none
        and type(givenname-levels) == array
        and i < givenname-levels.len()
    ) {
      givenname-levels.at(i)
    } else {
      givenname-level
    }
    let given-part = if level == 0 {
      ""
    } else if level == 1 {
      get-initials(name.at("given", default: ""))
    } else {
      name.at("given", default: "")
    }

    if given-part != "" {
      parts.push(family + ", " + given-part)
    } else {
      parts.push(family)
    }
  }

  if use-et-al and show-count < names.len() {
    parts.push("et-al")
  }

  lower(parts.join("; "))
}

/// Compute name disambiguation levels for entries
///
/// Implements CSL givenname-disambiguation-rule:
/// - "all-names": Expand all ambiguous names in all cites
/// - "all-names-with-initials": Same but limit to initials (level 1)
/// - "primary-name": Only expand first name of each cite
/// - "primary-name-with-initials": Only first name, only initials
/// - "by-cite" (default): Only expand in ambiguous cites, stop when resolved
///
/// - entries: Array of entry IRs
/// - style: Parsed CSL style
/// Returns: Dictionary of key -> (names-expanded: int, givenname-level: int, needs-disambiguate: bool)
#let compute-name-disambiguation(entries, style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return (:) }

  let add-names = citation.at("disambiguate-add-names", default: false)
  let add-givenname = citation.at("disambiguate-add-givenname", default: false)
  let givenname-rule = citation.at(
    "givenname-disambiguation-rule",
    default: "by-cite",
  )

  if not add-names and not add-givenname { return (:) }

  let et-al-min = citation.at("et-al-min", default: none)
  let et-al-use-first = citation.at("et-al-use-first", default: none)
  let et-al-sub-min = citation.at("et-al-subsequent-min", default: none)
  let et-al-sub-use-first = citation.at(
    "et-al-subsequent-use-first",
    default: none,
  )
  let et-al-sub-min = citation.at("et-al-subsequent-min", default: none)
  let et-al-sub-use-first = citation.at(
    "et-al-subsequent-use-first",
    default: none,
  )
  let et-al-sub-min = citation.at("et-al-subsequent-min", default: none)
  let et-al-sub-use-first = citation.at(
    "et-al-subsequent-use-first",
    default: none,
  )
  // Handle none values (when not specified in citation element)
  if et-al-min == none { et-al-min = 4 }
  if et-al-use-first == none { et-al-use-first = 1 }

  // Convert to integers if needed
  if type(et-al-min) == str { et-al-min = int(et-al-min) }
  if type(et-al-use-first) == str { et-al-use-first = int(et-al-use-first) }
  if type(et-al-sub-min) == str { et-al-sub-min = int(et-al-sub-min) }
  if type(et-al-sub-use-first) == str {
    et-al-sub-use-first = int(et-al-sub-use-first)
  }

  if et-al-sub-min != none {
    et-al-min = calc.min(et-al-min, et-al-sub-min)
  }
  if et-al-sub-use-first != none {
    et-al-use-first = calc.min(et-al-use-first, et-al-sub-use-first)
  }
  if type(et-al-sub-min) == str { et-al-sub-min = int(et-al-sub-min) }
  if type(et-al-sub-use-first) == str {
    et-al-sub-use-first = int(et-al-sub-use-first)
  }

  // Use the most collapsed et-al settings for disambiguation keys
  if et-al-sub-min != none {
    et-al-min = calc.min(et-al-min, et-al-sub-min)
  }
  if et-al-sub-use-first != none {
    et-al-use-first = calc.min(et-al-use-first, et-al-sub-use-first)
  }
  if type(et-al-sub-min) == str { et-al-sub-min = int(et-al-sub-min) }
  if type(et-al-sub-use-first) == str {
    et-al-sub-use-first = int(et-al-sub-use-first)
  }

  // Use the most collapsed et-al settings for disambiguation keys
  if et-al-sub-min != none {
    et-al-min = calc.min(et-al-min, et-al-sub-min)
  }
  if et-al-sub-use-first != none {
    et-al-use-first = calc.min(et-al-use-first, et-al-sub-use-first)
  }

  // Determine max givenname level based on rule
  // Level 0 = none, 1 = initials, 2 = full given name
  let max-givenname-level = if givenname-rule.ends-with("-with-initials") {
    1
  } else { 2 }
  let use-initials = _citation-names-use-initials(style)
  let min-givenname-level = if max-givenname-level == 1 {
    1
  } else if use-initials {
    1
  } else { 2 }

  // Determine if we only target primary (first) name
  let primary-only = givenname-rule.starts-with("primary-name")

  // Check if this is an "all-names" rule (expand ambiguous names even in unambiguous cites)
  let is-all-names-rule = givenname-rule.starts-with("all-names")

  // Build initial representations for all entries
  let disambig-state = (:)
  for e in entries {
    let authors = get-all-authors(e.entry)
    disambig-state.insert(e.key, (
      authors: authors,
      names-expanded: 0,
      givenname-level: 0,
      givenname-levels: (),
      year: get-entry-year(e.entry),
      needs-disambiguate: false, // Method 3 flag
    ))
  }

  // ==========================================================================
  // For "all-names" rule: Disambiguate names that share the same family name
  // across the entire bibliography, even if the citations themselves are not
  // ambiguous (e.g., different years).
  // ==========================================================================
  if add-givenname and is-all-names-rule {
    // Group entries by family name of each rendered author position
    // (considering et-al truncation)
    let family-name-groups = (:)

    for (entry-key, state) in disambig-state.pairs() {
      let authors = state.authors
      let show-count = authors.len()

      for i in range(show-count) {
        let name = authors.at(i)
        let family = lower(_name-family-key(name))
        let raw-given = name.at("given", default: "")
        let given = _normalize-given(raw-given)
        let initials = get-initials(raw-given)

        if family == "" { continue }

        // Group by (family, position) to track which names at which positions conflict
        let group-key = family + "|" + str(i)
        if group-key not in family-name-groups {
          family-name-groups.insert(group-key, ())
        }
        family-name-groups
          .at(group-key)
          .push((
            entry-key: entry-key,
            position: i,
            given: given,
            initials: initials,
          ))
      }
    }

    // For each family name group, check if there are different given names
    // If so, all entries in that group need givenname expansion
    for (group-key, group-entries) in family-name-groups.pairs() {
      if group-entries.len() <= 1 { continue }

      let initials-list = group-entries.map(e => e.initials).dedup()
      let given-names = group-entries.map(e => e.given).dedup()
      let target-level = if max-givenname-level == 1 {
        if initials-list.len() > 1 { 1 } else { none }
      } else if given-names.len() > 1 {
        if use-initials and initials-list.len() > 1 { 1 } else { 2 }
      } else { none }

      if target-level == none { continue }

      // Apply per-position expansion levels
      for entry-info in group-entries {
        let entry-key = entry-info.entry-key
        let state = disambig-state.at(entry-key)
        let levels = state.givenname-levels
        // Ensure levels list is long enough
        if levels.len() <= entry-info.position {
          let extended = levels
          for _ in range(entry-info.position + 1 - levels.len()) {
            extended.push(0)
          }
          levels = extended
        }
        // Update target position
        let updated = ()
        for (idx, val) in levels.enumerate() {
          if idx == entry-info.position and val < target-level {
            updated.push(target-level)
          } else {
            updated.push(val)
          }
        }
        levels = updated
        let max-level = if state.givenname-level > target-level {
          state.givenname-level
        } else { target-level }
        disambig-state.insert(entry-key, (
          ..state,
          givenname-level: max-level,
          givenname-levels: levels,
        ))
      }
    }
  }

  // ==========================================================================
  // For "primary-name" rule: Disambiguate only primary names across entries
  // ==========================================================================
  if add-givenname and primary-only {
    let primary-groups = (:)

    for e in entries {
      let authors = get-all-authors(e.entry)
      if authors.len() == 0 { continue }
      let name = authors.at(0)
      let family = lower(_name-family-key(name))
      let raw-given = name.at("given", default: "")
      let given = _normalize-given(raw-given)
      let initials = get-initials(raw-given)
      if family == "" { continue }
      if family not in primary-groups {
        primary-groups.insert(family, ())
      }
      primary-groups
        .at(family)
        .push((
          entry-key: e.key,
          given: given,
          initials: initials,
        ))
    }

    for (family, group-entries) in primary-groups.pairs() {
      if group-entries.len() <= 1 { continue }
      let initials-list = group-entries.map(e => e.initials).dedup()
      let given-names = group-entries.map(e => e.given).dedup()
      let target-level = if max-givenname-level == 1 {
        if initials-list.len() > 1 { 1 } else { none }
      } else if given-names.len() > 1 {
        if use-initials and initials-list.len() > 1 { 1 } else { 2 }
      } else { none }
      if target-level == none { continue }

      for entry-info in group-entries {
        let entry-key = entry-info.entry-key
        let state = states.at(entry-key)
        let levels = state.givenname-levels
        if levels.len() == 0 {
          levels = ()
          levels.push(0)
        }
        let updated = ()
        for (idx, val) in levels.enumerate() {
          if idx == 0 and val < target-level {
            updated.push(target-level)
          } else {
            updated.push(val)
          }
        }
        levels = updated
        let max-level = state.givenname-level
        states.insert(entry-key, (
          ..state,
          givenname-level: max-level,
          givenname-levels: levels,
        ))
      }
    }
  }

  // ==========================================================================
  // For "primary-name" rule: Disambiguate only primary names across entries
  // ==========================================================================
  if add-givenname and primary-only {
    let primary-groups = (:)

    for (entry-key, state) in disambig-state.pairs() {
      let authors = state.authors
      if authors.len() == 0 { continue }
      let name = authors.at(0)
      let family = lower(_name-family-key(name))
      let raw-given = name.at("given", default: "")
      let given = _normalize-given(raw-given)
      let initials = get-initials(raw-given)
      if family == "" { continue }
      if family not in primary-groups {
        primary-groups.insert(family, ())
      }
      primary-groups
        .at(family)
        .push((
          entry-key: entry-key,
          given: given,
          initials: initials,
        ))
    }

    for (family, group-entries) in primary-groups.pairs() {
      if group-entries.len() <= 1 { continue }
      let initials-list = group-entries.map(e => e.initials).dedup()
      let given-names = group-entries.map(e => e.given).dedup()
      let target-level = if max-givenname-level == 1 {
        if initials-list.len() > 1 { 1 } else { none }
      } else if given-names.len() > 1 {
        if use-initials and initials-list.len() > 1 { 1 } else { 2 }
      } else { none }
      if target-level == none { continue }

      for entry-info in group-entries {
        let entry-key = entry-info.entry-key
        let state = disambig-state.at(entry-key)
        let levels = state.givenname-levels
        if levels.len() == 0 {
          levels = ()
          levels.push(0)
        }
        let updated = ()
        for (idx, val) in levels.enumerate() {
          if idx == 0 and val < target-level {
            updated.push(target-level)
          } else {
            updated.push(val)
          }
        }
        levels = updated
        let max-level = state.givenname-level
        disambig-state.insert(entry-key, (
          ..state,
          givenname-level: max-level,
          givenname-levels: levels,
        ))
      }
    }
  }

  // Iteratively disambiguate (for by-cite rule and add-names)
  // Strategy: Start with minimal representation, expand as needed
  let max-iterations = 10
  let iteration = 0

  while iteration < max-iterations {
    iteration += 1
    let made-change = false

    // Build current keys
    let keys = (:)
    for (entry-key, state) in disambig-state.pairs() {
      let author-key = build-author-key(
        state.authors,
        et-al-use-first,
        et-al-min: et-al-min,
        expand-names: state.names-expanded,
        givenname-level: state.givenname-level,
        givenname-levels: state.givenname-levels,
      )
      let full-key = author-key + "|" + str(state.year)

      if full-key not in keys {
        keys.insert(full-key, ())
      }
      keys.at(full-key).push(entry-key)
    }

    // Find collisions and try to resolve
    for (full-key, colliding-keys) in keys.pairs() {
      if colliding-keys.len() > 1 {
        // Try disambiguation strategies in order:
        // 1. Add givenname (initials first, then full - respecting rule limits)
        // 2. Add more names

        for entry-key in colliding-keys {
          let state = disambig-state.at(entry-key)
          let resolved = false

          // Try expanding givenname first (respecting max level from rule)
          // Skip for all-names rule as it was already handled above
          if (
            add-givenname
              and not is-all-names-rule
              and state.givenname-level < max-givenname-level
          ) {
            let new-level = state.givenname-level + 1
            let new-key = build-author-key(
              state.authors,
              et-al-use-first,
              et-al-min: et-al-min,
              expand-names: state.names-expanded,
              givenname-level: new-level,
              givenname-levels: state.givenname-levels,
            )

            // Check if this would resolve collision
            let would-resolve = true
            for other-key in colliding-keys {
              if other-key != entry-key {
                let other = disambig-state.at(other-key)
                let other-new-key = build-author-key(
                  other.authors,
                  et-al-use-first,
                  et-al-min: et-al-min,
                  expand-names: other.names-expanded,
                  givenname-level: other.givenname-level,
                  givenname-levels: other.givenname-levels,
                )
                if new-key == other-new-key {
                  would-resolve = false
                }
              }
            }

            // Only expand givenname if it would actually resolve the collision
            if would-resolve {
              disambig-state.insert(entry-key, (
                ..state,
                givenname-level: new-level,
              ))
              made-change = true
              resolved = true
            }
          }

          // Try adding more names (skip if primary-only rule)
          if not resolved and add-names and not primary-only {
            let max-names = state.authors.len()
            if state.names-expanded + et-al-use-first < max-names {
              disambig-state.insert(entry-key, (
                ..state,
                names-expanded: state.names-expanded + 1,
              ))
              made-change = true
            }
          }
        }
      }
    }

    if not made-change { break }
  }

  // Final pass: check for remaining collisions and mark for Method 3
  let final-keys = (:)
  for (entry-key, state) in disambig-state.pairs() {
    let author-key = build-author-key(
      state.authors,
      et-al-use-first,
      et-al-min: et-al-min,
      expand-names: state.names-expanded,
      givenname-level: state.givenname-level,
      givenname-levels: state.givenname-levels,
    )
    let full-key = author-key + "|" + str(state.year)

    if full-key not in final-keys {
      final-keys.insert(full-key, ())
    }
    final-keys.at(full-key).push(entry-key)
  }

  // Mark entries that still have collisions as needing Method 3
  for (full-key, colliding-keys) in final-keys.pairs() {
    if colliding-keys.len() > 1 {
      for entry-key in colliding-keys {
        let state = disambig-state.at(entry-key)
        disambig-state.insert(entry-key, (
          ..state,
          needs-disambiguate: true,
        ))
      }
    }
  }

  // Convert to result format
  let result = (:)
  for (entry-key, state) in disambig-state.pairs() {
    result.insert(entry-key, (
      names-expanded: state.names-expanded,
      givenname-level: state.givenname-level,
      needs-disambiguate: state.needs-disambiguate,
    ))
  }

  result
}

// =============================================================================
// Citation Key for Comparison
// =============================================================================

/// Build a citation key string for disambiguation comparison
///
/// This represents what the citation would render as (minus year-suffix).
/// Two entries with the same citation key are ambiguous.
///
/// - entry: Entry from citegeist
/// - state: Current disambiguation state for this entry
/// - style: Parsed CSL style
/// Returns: String key for comparison
#let build-citation-key(entry, state, style, date-vars: (), name-vars: ()) = {
  let citation = style.at("citation", default: none)
  if citation == none { return "" }

  if _citation-uses-label(style) {
    return _build-citation-label(entry)
  }

  let et-al-min = citation.at("et-al-min", default: none)
  let et-al-use-first = citation.at("et-al-use-first", default: none)
  // Handle none values (when not specified in citation element)
  if et-al-min == none { et-al-min = 4 }
  if et-al-use-first == none { et-al-use-first = 1 }
  if type(et-al-min) == str { et-al-min = int(et-al-min) }
  if type(et-al-use-first) == str { et-al-use-first = int(et-al-use-first) }

  // Get names used in citation (author/editor/etc.)
  let authors = if name-vars.len() > 0 {
    let selected = ()
    for var in name-vars {
      let names = _get-entry-names(entry, var)
      if names.len() > 0 {
        selected = names
        break
      }
    }
    selected
  } else { () }

  let base-givenname-level = _citation-name-base-level(style)

  // Apply names-expanded to et-al-use-first
  let effective-use-first = et-al-use-first + state.names-expanded

  // Build author key with current disambiguation state
  let author-key = if authors.len() > 0 {
    let effective-givenname-level = if (
      state.givenname-level == 0
        and (
          state.givenname-levels == none or state.givenname-levels.len() == 0
        )
    ) {
      base-givenname-level
    } else {
      state.givenname-level
    }
    build-author-key(
      authors,
      effective-use-first,
      et-al-min: et-al-min,
      expand-names: 0, // Already included in effective-use-first
      givenname-level: effective-givenname-level,
      givenname-levels: state.givenname-levels,
    )
  } else { "" }

  let date-key = if date-vars.len() > 0 {
    date-vars.map(v => _get-entry-date-year(entry, v)).join("|")
  } else {
    ""
  }
  if date-key != "" and author-key != "" {
    author-key + "|" + date-key
  } else if date-key != "" {
    date-key
  } else {
    author-key
  }
}

/// Group entries by citation key
///
/// - entries: Array of entry IRs
/// - states: Dictionary of key -> disambiguation state
/// - style: Parsed CSL style
/// Returns: Dictionary of citation_key -> [entry_key, ...]
#let group-by-citation-key(
  entries,
  states,
  style,
  date-vars: (),
  name-vars: (),
  cache: none,
) = {
  let groups = (:)
  let new-cache = if cache != none { cache } else { (:) }

  for e in entries {
    let state = states.at(e.key)
    // Check cache: if entry's state hasn't changed, reuse cached key
    let cached = if cache != none { cache.at(e.key, default: none) } else {
      none
    }
    let citation-key = if cached != none and cached.at(0) == state {
      cached.at(1)
    } else {
      let key = build-citation-key(
        e.entry,
        state,
        style,
        date-vars: date-vars,
        name-vars: name-vars,
      )
      new-cache.insert(e.key, (state, key))
      key
    }

    if citation-key not in groups {
      groups.insert(citation-key, ())
    }
    groups.at(citation-key).push(e.key)
  }

  (groups: groups, cache: new-cache)
}

/// Get ambiguous groups (groups with more than one entry)
///
/// - groups: Dictionary of citation_key -> [entry_key, ...]
/// Returns: Array of (citation_key, [entry_key, ...]) where len > 1
#let get-ambiguous-groups(groups) = {
  groups.pairs().filter(((k, v)) => v.len() > 1)
}

// =============================================================================
// Disambiguation Helpers
// =============================================================================

/// Check if expanding givenname would help disambiguate an entry
///
/// Compares the entry's first author given name against other entries
/// in the same ambiguous group.
///
/// - key: The entry key to check
/// - entries: All entries
/// - states: Current disambiguation states
/// - et-al-use-first: Base et-al use-first value
/// - ambiguous: Current ambiguous groups
/// - consider-all: If true, consider full name list
/// Returns: true if expansion would help
#let _givenname-expansion-would-help(
  key,
  entries,
  states,
  et-al-use-first,
  ambiguous,
  consider-all: false,
) = {
  let entry = entries.find(e => e.key == key)
  if entry == none { return false }

  let authors = entry
    .entry
    .at("parsed_names", default: (:))
    .at("author", default: ())

  if authors.len() == 0 { return false }
  let state = states.at(key, default: none)
  let show-count = if consider-all {
    authors.len()
  } else if state != none {
    calc.min(authors.len(), et-al-use-first + state.names-expanded)
  } else {
    calc.min(authors.len(), et-al-use-first)
  }

  // Find other entries in same ambiguous group
  for (group-key, group-keys) in ambiguous {
    if key in group-keys {
      for other-key in group-keys {
        if other-key != key {
          let other-entry = entries.find(e => e.key == other-key)
          if other-entry != none {
            let other-authors = other-entry
              .entry
              .at("parsed_names", default: (:))
              .at("author", default: ())
            let max-idx = calc.min(show-count, other-authors.len())
            for i in range(max-idx) {
              let given = _normalize-given(
                authors.at(i).at("given", default: ""),
              )
              let other-given = _normalize-given(
                other-authors.at(i).at("given", default: ""),
              )
              if given != other-given { return true }
            }
          }
        }
      }
    }
  }
  false
}

/// Try to expand names for an entry if possible
///
/// - key: The entry key
/// - state: Current disambiguation state
/// - entry-map: Map of key -> entry
/// - et-al-use-first: Number of names shown before et al
/// Returns: (can-expand, new-state)
#let _try-expand-names(
  key,
  state,
  entry-map,
  et-al-use-first,
  et-al-min,
  allow-full: true,
) = {
  let e = entry-map.at(key)
  let authors = get-all-authors(e.entry)

  let max-show = if allow-full {
    authors.len()
  } else if et-al-min != none {
    calc.min(authors.len(), et-al-min)
  } else {
    authors.len()
  }
  let next-show = et-al-use-first + state.names-expanded + 1
  if next-show <= max-show {
    (
      can-expand: true,
      new-state: (..state, names-expanded: state.names-expanded + 1),
    )
  } else {
    (can-expand: false, new-state: state)
  }
}

/// Assign year suffixes to ambiguous groups
///
/// - ambiguous: Array of (citation-key, entry-keys) for ambiguous groups
/// - entries: All entries (for ordering)
/// - states: Current states dict (will be mutated)
/// Returns: Updated states dict
#let _assign-year-suffixes(ambiguous, entries, states) = {
  let new-states = states

  for (citation-key, entry-keys) in ambiguous {
    // Sort by bibliography order (entry position in entries array)
    let key-order = (:)
    for (i, e) in entries.enumerate() {
      if e.key in entry-keys {
        key-order.insert(e.key, i)
      }
    }

    let sorted-keys = entry-keys.sorted(key: k => key-order.at(k, default: 999))

    // Store numeric index (0, 1, 2, ...) instead of letter
    // Conversion to letter (a, b, c, ...) happens at render time
    for (i, key) in sorted-keys.enumerate() {
      let state = new-states.at(key)
      new-states.insert(key, (..state, year-suffix: i))
    }
  }

  new-states
}

// =============================================================================
// Main Disambiguation Algorithm
// =============================================================================

/// Apply disambiguation to entry IRs
///
/// Implements CSL disambiguation in order:
/// 1. disambiguate-add-givenname: Expand given names (initials → full)
/// 2. disambiguate-add-names: Add more authors from et-al list
/// 3. disambiguate condition: Set disambiguate=true in context
/// 4. disambiguate-add-year-suffix: Add a, b, c to years
///
/// Key: Each method only applies to entries still ambiguous after previous methods.
///
/// - entries: Array of entry IRs (already sorted by bibliography order)
/// - style: Parsed CSL style
/// Returns: Array of entry IRs with disambig field populated
#let apply-disambiguation(entries, style) = {
  let citation = style.at("citation", default: none)
  if citation == none {
    // No citation element, return entries unchanged
    return entries.map(e => (
      ..e,
      disambig: (
        year-suffix: none,
        names-expanded: 0,
        givenname-level: 0,
        givenname-levels: (),
        needs-disambiguate: false,
      ),
    ))
  }

  // Get disambiguation options
  let add-givenname = citation.at("disambiguate-add-givenname", default: false)
  let add-names = citation.at("disambiguate-add-names", default: false)
  let add-year-suffix = citation.at(
    "disambiguate-add-year-suffix",
    default: false,
  )
  let givenname-rule = citation.at(
    "givenname-disambiguation-rule",
    default: "by-cite",
  )

  // Determine max givenname level based on rule
  let max-givenname-level = if givenname-rule.ends-with("-with-initials") {
    1
  } else { 2 }
  let use-initials = _citation-names-use-initials(style)
  let min-givenname-level = if max-givenname-level == 1 {
    1
  } else if use-initials {
    1
  } else { 2 }
  let primary-only = givenname-rule.starts-with("primary-name")

  // Check if this is an "all-names" rule (expand ambiguous names even in unambiguous cites)
  let is-all-names-rule = givenname-rule.starts-with("all-names")

  // Get et-al settings for names expansion limit
  let et-al-min = citation.at("et-al-min", default: none)
  if et-al-min == none { et-al-min = 4 }
  if type(et-al-min) == str { et-al-min = int(et-al-min) }

  // Get et-al-use-first early (needed for all-names rule)
  let et-al-use-first = citation.at("et-al-use-first", default: none)
  if et-al-use-first == none { et-al-use-first = 1 }
  if type(et-al-use-first) == str { et-al-use-first = int(et-al-use-first) }

  // Initialize disambiguation state for each entry
  let states = (:)
  let entry-map = (:) // key -> entry for quick lookup
  let date-vars = _citation-date-vars(style)
  let name-vars = _citation-name-vars(style)

  for e in entries {
    states.insert(e.key, (
      givenname-level: 0,
      givenname-levels: (),
      names-expanded: 0,
      needs-disambiguate: false,
      year-suffix: none,
    ))
    entry-map.insert(e.key, e)
  }

  // ==========================================================================
  // Pre-Method 1: "all-names" rule processing
  // ==========================================================================
  // For "all-names" rule: Disambiguate names that share the same family name
  // across the entire bibliography, even if the citations themselves are not
  // ambiguous (e.g., different years).
  //
  // CSL Spec: "all-names" expands to full given name (level 2)
  // "all-names-with-initials" limits expansion to initials (level 1)
  if add-givenname and is-all-names-rule {
    // Group entries by family name of each rendered author position
    // (considering et-al truncation)
    let family-name-groups = (:)

    for e in entries {
      let authors = get-all-authors(e.entry)
      let state = states.at(e.key)
      let show-count = authors.len()

      for i in range(show-count) {
        let name = authors.at(i)
        let family = lower(_name-family-key(name))
        let raw-given = name.at("given", default: "")
        let given = _normalize-given(raw-given)
        let initials = get-initials(raw-given)

        if family == "" { continue }

        // Group by (family, position) to track which names at which positions conflict
        let group-key = family + "|" + str(i)
        if group-key not in family-name-groups {
          family-name-groups.insert(group-key, ())
        }
        family-name-groups
          .at(group-key)
          .push((
            entry-key: e.key,
            position: i,
            given: given,
            initials: initials,
          ))
      }
    }

    // For each family name group, check if there are different given names
    // If so, all entries in that group need givenname expansion
    for (group-key, group-entries) in family-name-groups.pairs() {
      if group-entries.len() <= 1 { continue }

      let initials-list = group-entries.map(e => e.initials).dedup()
      let given-names = group-entries.map(e => e.given).dedup()
      let target-level = if (
        max-givenname-level > 1
          and group-entries.first().position == 0
          and given-names.len() > 1
      ) {
        2
      } else if initials-list.len() > 1 {
        1
      } else if max-givenname-level > 1 and given-names.len() > 1 {
        2
      } else { none }

      if target-level == none { continue }

      for entry-info in group-entries {
        let entry-key = entry-info.entry-key
        let state = states.at(entry-key)
        let levels = state.givenname-levels
        if levels.len() <= entry-info.position {
          let extended = levels
          for _ in range(entry-info.position + 1 - levels.len()) {
            extended.push(0)
          }
          levels = extended
        }
        let updated = ()
        for (idx, val) in levels.enumerate() {
          if idx == entry-info.position and val < target-level {
            updated.push(target-level)
          } else {
            updated.push(val)
          }
        }
        levels = updated
        let max-level = if state.givenname-level > target-level {
          state.givenname-level
        } else { target-level }
        states.insert(entry-key, (
          ..state,
          givenname-level: max-level,
          givenname-levels: levels,
        ))
      }
    }
  }

  // ==========================================================================
  // For "primary-name" rule: Disambiguate only primary names across entries
  // ==========================================================================
  if add-givenname and primary-only {
    let primary-groups = (:)

    for e in entries {
      let authors = get-all-authors(e.entry)
      if authors.len() == 0 { continue }
      let name = authors.at(0)
      let family = lower(_name-family-key(name))
      let raw-given = name.at("given", default: "")
      let given = _normalize-given(raw-given)
      let initials = get-initials(raw-given)
      if family == "" { continue }
      if family not in primary-groups {
        primary-groups.insert(family, ())
      }
      primary-groups
        .at(family)
        .push((
          entry-key: e.key,
          given: given,
          initials: initials,
        ))
    }

    for (family, group-entries) in primary-groups.pairs() {
      if group-entries.len() <= 1 { continue }
      let initials-list = group-entries.map(e => e.initials).dedup()
      let given-names = group-entries.map(e => e.given).dedup()
      let target-level = if max-givenname-level == 1 {
        if initials-list.len() > 1 { 1 } else { none }
      } else if given-names.len() > 1 {
        if use-initials and initials-list.len() > 1 { 1 } else { 2 }
      } else { none }
      if target-level == none { continue }

      for entry-info in group-entries {
        let entry-key = entry-info.entry-key
        let state = states.at(entry-key)
        let levels = state.givenname-levels
        if levels.len() == 0 {
          levels = ()
          levels.push(0)
        }
        let updated = ()
        for (idx, val) in levels.enumerate() {
          if idx == 0 and val < target-level {
            updated.push(target-level)
          } else {
            updated.push(val)
          }
        }
        levels = updated
        let max-level = if state.givenname-level > target-level {
          state.givenname-level
        } else { target-level }
        states.insert(entry-key, (
          ..state,
          givenname-level: max-level,
          givenname-levels: levels,
        ))
      }
    }
  }

  // Initial grouping (with citation key cache for performance)
  let _result = group-by-citation-key(
    entries,
    states,
    style,
    date-vars: date-vars,
    name-vars: name-vars,
  )
  let groups = _result.groups
  let _key-cache = _result.cache
  let ambiguous = get-ambiguous-groups(groups)

  // ==========================================================================
  // Method 1: disambiguate-add-givenname (for by-cite rule)
  // ==========================================================================
  // Skip if all-names rule already handled givenname expansion
  if add-givenname and not is-all-names-rule and ambiguous.len() > 0 {
    // Try expanding givenname for ambiguous entries
    for level in range(min-givenname-level, max-givenname-level + 1) {
      let changed = false
      for (gk, gkeys) in ambiguous {
        if gkeys.len() <= 1 { continue }
        let first-key = gkeys.first()
        let first-entry = entry-map.at(first-key)
        let first-authors = get-all-authors(first-entry.entry)
        let first-state = states.at(first-key)
        let show-count = calc.min(
          first-authors.len(),
          et-al-use-first + first-state.names-expanded,
        )

        let positions = ()
        for i in range(show-count) {
          let family-list = ()
          let given-list = ()
          for key in gkeys {
            let entry = entry-map.at(key)
            let authors = get-all-authors(entry.entry)
            if i < authors.len() {
              let name = authors.at(i)
              let family = _name-family-key(name)
              let given = _normalize-given(name.at("given", default: ""))
              family-list.push(family)
              given-list.push(given)
            } else {
              family-list.push("")
              given-list.push("")
            }
          }
          if family-list.dedup().len() == 1 and given-list.dedup().len() > 1 {
            positions.push(i)
          }
        }

        if positions.len() > 0 {
          if primary-only {
            positions = positions.filter(p => p == 0)
          }
          if positions.len() == 0 { continue }
          let max-pos = -1
          for p in positions {
            if p > max-pos { max-pos = p }
          }
          for key in gkeys {
            let state = states.at(key)
            let levels = state.givenname-levels
            if max-pos >= 0 and levels.len() <= max-pos {
              let extended = levels
              for _ in range(max-pos + 1 - levels.len()) {
                extended.push(0)
              }
              levels = extended
            }
            let updated = ()
            for (idx, val) in levels.enumerate() {
              if idx in positions and val < level {
                updated.push(level)
              } else {
                updated.push(val)
              }
            }
            levels = updated
            let max-level = if primary-only {
              state.givenname-level
            } else if state.givenname-level > level {
              state.givenname-level
            } else { level }
            states.insert(key, (
              ..state,
              givenname-level: max-level,
              givenname-levels: levels,
            ))
          }
          changed = true
        }
      }

      // Re-group and check (reuse cache for unchanged entries)
      let _result = group-by-citation-key(
        entries,
        states,
        style,
        date-vars: date-vars,
        name-vars: name-vars,
        cache: _key-cache,
      )
      _key-cache = _result.cache
      ambiguous = get-ambiguous-groups(_result.groups)

      if ambiguous.len() == 0 or not changed { break }
    }
  }

  // ==========================================================================
  // Method 2: disambiguate-add-names
  // ==========================================================================
  if add-names and not primary-only and ambiguous.len() > 0 {
    // et-al-use-first was already retrieved above

    // Try adding more names for still-ambiguous entries
    // Key insight: Only keep expansion if it actually helps disambiguate
    let max-iterations = 10
    let iteration = 0

    while ambiguous.len() > 0 and iteration < max-iterations {
      iteration += 1

      // Save current state before trying expansions
      let prev-states = states
      let prev-ambiguous-total = 0
      for (gk, gkeys) in ambiguous {
        prev-ambiguous-total += gkeys.len()
      }

      // Try to expand names only when additional names can help disambiguate
      let any-expanded = false
      for (gk, gkeys) in ambiguous {
        if gkeys.len() <= 1 { continue }
        let first-key = gkeys.first()
        let first-entry = entry-map.at(first-key)
        let first-state = states.at(first-key)
        let show-count = et-al-use-first + first-state.names-expanded
        let first-authors = get-all-authors(first-entry.entry)
        if first-authors.len() == 0 { continue }
        let first-rest = first-authors.slice(show-count)
        let first-rest-key = first-rest
          .map(n => (
            _name-family-key(n)
              + "|"
              + (
                if add-givenname {
                  _normalize-given(n.at("given", default: ""))
                } else { "" }
              )
          ))
          .join("||")
        let can-help = false
        for key in gkeys.slice(1) {
          let entry = entry-map.at(key)
          let authors = get-all-authors(entry.entry)
          if authors.len() == 0 { continue }
          let rest = authors.slice(show-count)
          let rest-key = rest
            .map(n => (
              _name-family-key(n)
                + "|"
                + (
                  if add-givenname {
                    _normalize-given(n.at("given", default: ""))
                  } else { "" }
                )
            ))
            .join("||")
          if rest-key != first-rest-key {
            can-help = true
            break
          }
        }
        if not can-help { continue }
        for key in gkeys {
          let state = states.at(key)
          let result = _try-expand-names(
            key,
            state,
            entry-map,
            et-al-use-first,
            et-al-min,
            allow-full: false,
          )
          if result.can-expand {
            any-expanded = true
            states.insert(key, result.new-state)
          }
        }
      }

      if not any-expanded {
        break
      }

      // Re-group and check (reuse cache)
      let _result = group-by-citation-key(
        entries,
        states,
        style,
        date-vars: date-vars,
        name-vars: name-vars,
        cache: _key-cache,
      )
      _key-cache = _result.cache
      ambiguous = get-ambiguous-groups(_result.groups)

      // Interleave givenname expansion with add-names when enabled
      if add-givenname and not is-all-names-rule and ambiguous.len() > 0 {
        for level in range(min-givenname-level, max-givenname-level + 1) {
          let changed = false
          for (gk, gkeys) in ambiguous {
            if gkeys.len() <= 1 { continue }
            let first-key = gkeys.first()
            let first-entry = entry-map.at(first-key)
            let first-authors = get-all-authors(first-entry.entry)
            let first-state = states.at(first-key)
            let show-count = calc.min(
              first-authors.len(),
              et-al-use-first + first-state.names-expanded,
            )

            let positions = ()
            for i in range(show-count) {
              let family-list = ()
              let given-list = ()
              for key in gkeys {
                let entry = entry-map.at(key)
                let authors = get-all-authors(entry.entry)
                if i < authors.len() {
                  let name = authors.at(i)
                  let family = _name-family-key(name)
                  let given = _normalize-given(name.at("given", default: ""))
                  family-list.push(family)
                  given-list.push(given)
                } else {
                  family-list.push("")
                  given-list.push("")
                }
              }
              if (
                family-list.dedup().len() == 1 and given-list.dedup().len() > 1
              ) {
                positions.push(i)
              }
            }

            if positions.len() > 0 {
              if primary-only {
                positions = positions.filter(p => p == 0)
              }
              if positions.len() == 0 { continue }
              let max-pos = -1
              for p in positions {
                if p > max-pos { max-pos = p }
              }
              for key in gkeys {
                let state = states.at(key)
                let levels = state.givenname-levels
                if max-pos >= 0 and levels.len() <= max-pos {
                  let extended = levels
                  for _ in range(max-pos + 1 - levels.len()) {
                    extended.push(0)
                  }
                  levels = extended
                }
                let updated = ()
                for (idx, val) in levels.enumerate() {
                  if idx in positions and val < level {
                    updated.push(level)
                  } else {
                    updated.push(val)
                  }
                }
                levels = updated
                let max-level = if primary-only {
                  state.givenname-level
                } else if state.givenname-level > level {
                  state.givenname-level
                } else { level }
                states.insert(key, (
                  ..state,
                  givenname-level: max-level,
                  givenname-levels: levels,
                ))
              }
              changed = true
            }
          }
          let _result = group-by-citation-key(
            entries,
            states,
            style,
            date-vars: date-vars,
            name-vars: name-vars,
            cache: _key-cache,
          )
          _key-cache = _result.cache
          ambiguous = get-ambiguous-groups(_result.groups)
          if ambiguous.len() == 0 or not changed { break }
        }
      }

      // If no progress was made (no reduction in ambiguous entries), check
      // whether further expansion could still help disambiguate.
      let new-ambiguous-total = 0
      for (gk, gkeys) in ambiguous {
        new-ambiguous-total += gkeys.len()
      }
      if new-ambiguous-total >= prev-ambiguous-total {
        // Determine if remaining names differ beyond current show-count
        let can-help = false
        for (gk, gkeys) in ambiguous {
          if gkeys.len() <= 1 { continue }
          let first-key = gkeys.first()
          let first-entry = entry-map.at(first-key)
          let first-authors = get-all-authors(first-entry.entry)
          let first-state = states.at(first-key)
          let show-count = et-al-use-first + first-state.names-expanded
          let first-rest = first-authors.slice(show-count)
          let first-rest-key = first-rest
            .map(n => (
              _name-family-key(n)
                + "|"
                + (
                  if add-givenname {
                    _normalize-given(n.at("given", default: ""))
                  } else { "" }
                )
            ))
            .join("||")
          for key in gkeys.slice(1) {
            let entry = entry-map.at(key)
            let authors = get-all-authors(entry.entry)
            let rest = authors.slice(show-count)
            let rest-key = rest
              .map(n => (
                _name-family-key(n)
                  + "|"
                  + (
                    if add-givenname {
                      _normalize-given(n.at("given", default: ""))
                    } else { "" }
                  )
              ))
              .join("||")
            if rest-key != first-rest-key {
              can-help = true
              break
            }
          }
          if can-help { break }
        }
        if not can-help { break }
      }
    }

    if not add-givenname {
      // Final check: revert expansion for entries that are still ambiguous
      // with the exact same collision partners as before
      // This ensures that if expansion didn't help, we don't show expanded names
      let _result = group-by-citation-key(
        entries,
        states,
        style,
        date-vars: date-vars,
        name-vars: name-vars,
        cache: _key-cache,
      )
      _key-cache = _result.cache
      let final-ambiguous = get-ambiguous-groups(_result.groups)

      // Build initial groups (with no expansion) for comparison
      let initial-states = (:)
      for e in entries {
        initial-states.insert(e.key, (
          givenname-level: states.at(e.key).givenname-level,
          givenname-levels: states.at(e.key).givenname-levels,
          names-expanded: 0,
          needs-disambiguate: false,
          year-suffix: none,
        ))
      }
      // Note: initial-states uses a separate cache (different states)
      let _init-result = group-by-citation-key(
        entries,
        initial-states,
        style,
        date-vars: date-vars,
        name-vars: name-vars,
      )
      let initial-groups = _init-result.groups

      // For each still-ambiguous group, check if expansion actually helped
      for (group-key, group-keys) in final-ambiguous {
        // Check if all these entries were in the same initial group
        let initial-group-keys-set = (:)
        let initial-group-sizes = (:)
        for (init-key, init-entries) in initial-groups.pairs() {
          initial-group-sizes.insert(init-key, init-entries.len())
          for ek in init-entries {
            initial-group-keys-set.insert(ek, init-key)
          }
        }

        // If all current group members were in the same initial group,
        // the expansion didn't help - revert to 0
        let first-initial-group = initial-group-keys-set.at(
          group-keys.first(),
          default: "",
        )
        let all-same-initial = group-keys.all(k => (
          initial-group-keys-set.at(k, default: "") == first-initial-group
        ))

        let initial-group-size = initial-group-sizes.at(
          first-initial-group,
          default: 0,
        )
        let reduced-group = group-keys.len() < initial-group-size

        if all-same-initial and not reduced-group {
          // Expansion didn't help these entries - revert their expansion
          for key in group-keys {
            let state = states.at(key)
            states.insert(key, (..state, names-expanded: 0))
          }
        }
      }

      // Recalculate ambiguous groups after potential reversion
      // Cache may be stale after reversion, so recompute
      let _result = group-by-citation-key(
        entries,
        states,
        style,
        date-vars: date-vars,
        name-vars: name-vars,
        cache: _key-cache,
      )
      _key-cache = _result.cache
      ambiguous = get-ambiguous-groups(_result.groups)
    }
  }

  // ==========================================================================
  // Method 2b: disambiguate-add-givenname after add-names
  // ==========================================================================
  // Adding names can expose new positions for givenname disambiguation.
  if add-givenname and not is-all-names-rule and ambiguous.len() > 0 {
    for level in range(min-givenname-level, max-givenname-level + 1) {
      let changed = false
      for (gk, gkeys) in ambiguous {
        if gkeys.len() <= 1 { continue }
        let first-key = gkeys.first()
        let first-entry = entry-map.at(first-key)
        let first-authors = get-all-authors(first-entry.entry)
        let first-state = states.at(first-key)
        let show-count = calc.min(
          first-authors.len(),
          et-al-use-first + first-state.names-expanded,
        )

        let positions = ()
        for i in range(show-count) {
          let family-list = ()
          let given-list = ()
          for key in gkeys {
            let entry = entry-map.at(key)
            let authors = get-all-authors(entry.entry)
            if i < authors.len() {
              let name = authors.at(i)
              let family = _name-family-key(name)
              let given = _normalize-given(name.at("given", default: ""))
              family-list.push(family)
              given-list.push(given)
            } else {
              family-list.push("")
              given-list.push("")
            }
          }
          if family-list.dedup().len() == 1 and given-list.dedup().len() > 1 {
            positions.push(i)
          }
        }

        if positions.len() > 0 {
          if primary-only {
            positions = positions.filter(p => p == 0)
          }
          if positions.len() == 0 { continue }
          let max-pos = -1
          for p in positions {
            if p > max-pos { max-pos = p }
          }
          for key in gkeys {
            let state = states.at(key)
            let levels = state.givenname-levels
            if max-pos >= 0 and levels.len() <= max-pos {
              let extended = levels
              for _ in range(max-pos + 1 - levels.len()) {
                extended.push(0)
              }
              levels = extended
            }
            let updated = ()
            for (idx, val) in levels.enumerate() {
              if idx in positions and val < level {
                updated.push(level)
              } else {
                updated.push(val)
              }
            }
            levels = updated
            let max-level = if primary-only {
              state.givenname-level
            } else if state.givenname-level > level {
              state.givenname-level
            } else { level }
            states.insert(key, (
              ..state,
              givenname-level: max-level,
              givenname-levels: levels,
            ))
          }
          changed = true
        }
      }
      let _result = group-by-citation-key(
        entries,
        states,
        style,
        date-vars: date-vars,
        name-vars: name-vars,
        cache: _key-cache,
      )
      _key-cache = _result.cache
      ambiguous = get-ambiguous-groups(_result.groups)
      if ambiguous.len() == 0 or not changed { break }
    }
  }

  // ==========================================================================
  // Method 3: disambiguate condition
  // ==========================================================================
  // Mark remaining ambiguous entries for the disambiguate condition
  if ambiguous.len() > 0 {
    let step-vars = _collect-disambiguate-step-vars(style)
    if step-vars.len() == 0 {
      let ambiguous-keys = ambiguous.map(((k, v)) => v).flatten()
      for key in ambiguous-keys {
        let state = states.at(key)
        states.insert(key, (
          ..state,
          needs-disambiguate: true,
        ))
      }
    } else {
      // Build base citation keys (without disambiguate extras)
      let base-keys = (:)
      for e in entries {
        let state = states.at(e.key)
        base-keys.insert(e.key, build-citation-key(
          e.entry,
          state,
          style,
          date-vars: date-vars,
          name-vars: name-vars,
        ))
      }

      let remaining = ambiguous
      let levels = (:)
      let accumulated = ()

      for (idx, vars) in step-vars.enumerate() {
        accumulated = (accumulated + vars).dedup()
        let groups = (:)
        for e in entries {
          let base = base-keys.at(e.key, default: "")
          let extra = accumulated
            .map(v => _get-disambiguate-value(e.entry, v, style))
            .join("|")
          let key = if extra != "" { base + "|" + extra } else { base }
          if key not in groups { groups.insert(key, ()) }
          groups.at(key).push(e.key)
        }

        let new-ambiguous = get-ambiguous-groups(groups)
        let new-ambig-keys = new-ambiguous.map(((k, v)) => v).flatten()
        let remaining-keys = remaining.map(((k, v)) => v).flatten()
        for key in remaining-keys {
          if key not in new-ambig-keys and levels.at(key, default: 0) == 0 {
            levels.insert(key, idx + 1)
          }
        }
        remaining = new-ambiguous
        if remaining.len() == 0 { break }
      }

      // Anything still ambiguous gets the max level
      let remaining-keys = remaining.map(((k, v)) => v).flatten()
      for key in remaining-keys {
        if levels.at(key, default: 0) == 0 {
          levels.insert(key, step-vars.len())
        }
      }

      for (key, level) in levels.pairs() {
        let state = states.at(key)
        states.insert(key, (
          ..state,
          needs-disambiguate: level,
        ))
      }
    }
  }

  // ==========================================================================
  // Method 4: disambiguate-add-year-suffix
  // ==========================================================================
  if add-year-suffix {
    if ambiguous.len() > 0 {
      states = _assign-year-suffixes(ambiguous, entries, states)
    } else {
      let citation = style.at("citation", default: none)
      if citation != none {
        let et-al-sub-min = citation.at("et-al-subsequent-min", default: none)
        let et-al-sub-use-first = citation.at(
          "et-al-subsequent-use-first",
          default: none,
        )
        if et-al-sub-min != none or et-al-sub-use-first != none {
          if et-al-sub-min == none {
            et-al-sub-min = citation.at("et-al-min", default: none)
          }
          if et-al-sub-use-first == none {
            et-al-sub-use-first = citation.at("et-al-use-first", default: none)
          }
          if type(et-al-sub-min) == str { et-al-sub-min = int(et-al-sub-min) }
          if type(et-al-sub-use-first) == str {
            et-al-sub-use-first = int(et-al-sub-use-first)
          }

          let base-givenname-level = _citation-name-base-level(style)
          let alt-groups = (:)
          for e in entries {
            let state = states.at(e.key)
            let authors = if name-vars.len() > 0 {
              let selected = ()
              for var in name-vars {
                let names = _get-entry-names(e.entry, var)
                if names.len() > 0 {
                  selected = names
                  break
                }
              }
              selected
            } else { () }

            let effective-use-first = et-al-sub-use-first + state.names-expanded
            let effective-givenname-level = if (
              state.givenname-level == 0
                and (
                  state.givenname-levels == none
                    or state.givenname-levels.len() == 0
                )
            ) {
              base-givenname-level
            } else {
              state.givenname-level
            }

            let author-key = if authors.len() > 0 {
              build-author-key(
                authors,
                effective-use-first,
                et-al-min: et-al-sub-min,
                expand-names: 0,
                givenname-level: effective-givenname-level,
                givenname-levels: state.givenname-levels,
              )
            } else { "" }

            let date-key = if date-vars.len() > 0 {
              date-vars.map(v => _get-entry-date-year(e.entry, v)).join("|")
            } else { "" }
            let key = if date-key != "" and author-key != "" {
              author-key + "|" + date-key
            } else if date-key != "" {
              date-key
            } else {
              author-key
            }

            if key not in alt-groups { alt-groups.insert(key, ()) }
            alt-groups.at(key).push(e.key)
          }

          let alt-ambiguous = get-ambiguous-groups(alt-groups)
          if alt-ambiguous.len() > 0 {
            states = _assign-year-suffixes(alt-ambiguous, entries, states)
          }
        }
      }
    }
  }

  if add-givenname and primary-only {
    let normalized = (:)
    for (key, state) in states.pairs() {
      normalized.insert(key, (..state, givenname-level: 0))
    }
    states = normalized
  }

  // ==========================================================================
  // Apply states to entries
  // ==========================================================================
  entries.map(e => (
    ..e,
    disambig: states.at(e.key),
  ))
}

/// Check if two entries have the same short author representation
///
/// - entry-a: First entry
/// - entry-b: Second entry
/// Returns: bool
#let same-author-short(entry-a, entry-b) = {
  let author-a = get-first-author-family(entry-a)
  let author-b = get-first-author-family(entry-b)
  lower(author-a) == lower(author-b)
}

/// Check if two entries have the same year
///
/// - entry-a: First entry
/// - entry-b: Second entry
/// Returns: bool
#let same-year(entry-a, entry-b) = {
  let year-a = get-entry-year(entry-a)
  let year-b = get-entry-year(entry-b)
  year-a == year-b
}
