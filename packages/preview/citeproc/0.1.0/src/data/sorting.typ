// citeproc-typst - Sorting Module
//
// Extracts sort keys from CSL <sort> element and sorts entries.

#import "variables.typ": get-variable  // Same directory
#import "../interpreter/mod.typ": create-context
#import "../interpreter/stack.typ": interpret-children-stack
#import "../output/helpers.typ": content-to-string

// =============================================================================
// Sort Key Extraction
// =============================================================================

/// Extract a single sort key value from an entry
///
/// - key-spec: Sort key specification from CSL (variable, macro, sort order)
/// - entry: Entry from citegeist
/// - style: Parsed CSL style
/// Returns: (order, value) tuple
#let extract-sort-key(key-spec, entry, style) = {
  let ctx = create-context(style, entry)
  let order = key-spec.at("sort", default: "ascending")

  // CSL spec: names-min/use-first/use-last override et-al settings for sort keys
  // Pass these to the context for names rendering within macros
  let names-min = key-spec.at("names-min", default: none)
  let names-use-first = key-spec.at("names-use-first", default: none)
  let names-use-last = key-spec.at("names-use-last", default: none)

  // Add sort key name settings to context (they override et-al settings)
  let ctx = (
    ..ctx,
    sort-names-min: names-min,
    sort-names-use-first: names-use-first,
    sort-names-use-last: names-use-last,
  )

  let value = if key-spec.at("macro", default: none) != none {
    // Render macro and use result as sort key
    let macro-name = key-spec.macro
    let macro-def = style.macros.at(macro-name, default: none)
    if macro-def != none {
      let rendered = interpret-children-stack(macro-def.children, ctx)
      // Convert to string for sorting
      content-to-string(rendered)
    } else { "" }
  } else if key-spec.at("variable", default: "") != "" {
    // Get variable value directly
    get-variable(ctx, key-spec.variable)
  } else {
    ""
  }

  // Normalize for case-insensitive sorting
  let normalized = if type(value) == str { lower(value) } else { "" }

  (order: order, value: normalized)
}

/// Extract all sort keys for an entry
///
/// - entry: Entry from citegeist
/// - sort-spec: Array of sort key specifications from CSL
/// - style: Parsed CSL style
/// Returns: Array of (order, value) tuples
#let extract-sort-keys(entry, sort-spec, style) = {
  if sort-spec == none or sort-spec.len() == 0 {
    return ()
  }

  sort-spec.map(key-spec => extract-sort-key(key-spec, entry, style))
}

// =============================================================================
// Entry Sorting
// =============================================================================

/// Compare two entries by their sort keys
///
/// - a: First entry IR (with sort-keys)
/// - b: Second entry IR (with sort-keys)
/// Returns: -1, 0, or 1
#let compare-entries(a, b) = {
  let keys-a = a.sort-keys
  let keys-b = b.sort-keys

  let len = calc.min(keys-a.len(), keys-b.len())

  for i in range(len) {
    let ka = keys-a.at(i)
    let kb = keys-b.at(i)

    let va = ka.value
    let vb = kb.value

    if va != vb {
      let cmp = if va < vb { -1 } else { 1 }
      // Reverse for descending order
      if ka.order == "descending" { return -cmp }
      return cmp
    }
  }

  0
}

/// Sort entries by extracted sort keys
///
/// - entries: Array of entry IRs with sort-keys populated
/// Returns: Sorted array of entry IRs
#let sort-entries(entries) = {
  if entries.len() <= 1 { return entries }

  // Typst's sorted() with a key function
  // For multi-key sorting, we create a compound key
  entries.sorted(key: e => {
    e
      .sort-keys
      .map(k => {
        // Prefix with order indicator for proper comparison
        let prefix = if k.order == "descending" { "1" } else { "0" }
        prefix + k.value
      })
      .join("\x00") // Use null byte as separator (won't appear in text)
  })
}

/// Sort entries for bibliography output
///
/// For numeric styles: sort by citation order
/// For author-date styles: sort by CSL <sort> element
///
/// - entries: Array of entry IRs
/// - style: Parsed CSL style
/// - by-order: If true, sort by citation order (for numeric styles)
/// Returns: Sorted array of entry IRs
#let sort-bibliography-entries(entries, style, by-order: false) = {
  if by-order {
    // Sort by citation order (numeric styles)
    entries.sorted(key: e => e.order)
  } else {
    // Sort by CSL sort keys (with null-safety for citation-only styles)
    let bib = style.at("bibliography", default: none)
    let sort-spec = if bib != none { bib.at("sort", default: ()) } else { () }

    if sort-spec.len() == 0 {
      // No sort specified, keep original order
      return entries
    }

    // Extract sort keys for each entry
    let with-keys = entries.map(e => {
      let keys = extract-sort-keys(e.entry, sort-spec, style)
      (..e, sort-keys: keys)
    })

    sort-entries(with-keys)
  }
}
