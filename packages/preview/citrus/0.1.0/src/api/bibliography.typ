// citrus - Bibliography API Module
//
// Provides csl-bibliography() and get-cited-entries() functions.

#import "../core/mod.typ": _abbreviations, _bib-data, _csl-style
#import "../output/mod.typ": get-rendered-entries
#import "../parsing/locales.typ": detect-language
#import "../init/core.typ": _get-precomputed

/// Get cited entries with rich metadata (low-level API)
///
/// Returns an array of entries, each containing:
/// - `key`: Citation key
/// - `order`: Citation order (for numeric styles)
/// - `year-suffix`: Year disambiguation suffix (e.g., "a", "b")
/// - `lang`: Detected language ("zh" or "en")
/// - `entry-type`: Entry type ("article", "book", etc.)
/// - `fields`: Raw field dictionary (title, author, year, ...)
/// - `parsed-names`: Parsed author/editor names
/// - `rendered`: CSL-rendered content (full, may contain citation number)
/// - `rendered-body`: CSL-rendered content (without citation number, for custom rendering)
/// - `ref-label`: Label object for linking
/// - `labeled-rendered`: Rendered content with label attached
///
/// Usage:
/// ```typst
/// context {
///   let entries = get-cited-entries()
///   for e in entries {
///     // Option 1: Use labeled-rendered directly
///     e.labeled-rendered
///     // Option 2: Custom content + label
///     [Custom: #e.fields.at("title") #e.ref-label]
///   }
/// }
/// ```
#let get-cited-entries() = {
  let bib = _bib-data.get()
  let style = _csl-style.get()

  // Use precomputed data when available
  let precomputed = _get-precomputed()
  let citations = precomputed.citations

  // Process entries through IR pipeline (using cached sort order)
  let abbrevs = _abbreviations.get()
  let rendered-entries = get-rendered-entries(
    bib,
    citations,
    style,
    abbreviations: abbrevs,
    precomputed: precomputed, // Use cached sorted-keys and disambig-states
  )

  // Build rich entry data
  rendered-entries.map(e => (
    key: e.ir.key,
    order: e.ir.order,
    year-suffix: e.ir.disambig.year-suffix,
    lang: detect-language(e.ir.entry.at("fields", default: (:))),
    entry-type: e.ir.entry.at("entry_type", default: "misc"),
    fields: e.ir.entry.at("fields", default: (:)),
    parsed-names: e.ir.entry.at("parsed_names", default: (:)),
    rendered: e.rendered,
    rendered-body: e.rendered-body, // Without citation number (for custom rendering)
    rendered-number: e.rendered-number, // Just the citation number (for alignment)
    ref-label: e.label,
    labeled-rendered: [#e.rendered #e.label],
  ))
}

/// Render the bibliography
///
/// - title: Bibliography title (auto, none, or custom content)
/// - full-control: Optional callback for custom rendering (entries => content)
///   - Signature: `(entries) => content`
///   - entries: Array from `get-cited-entries()`, each with:
///     - key, order, year-suffix, lang, entry-type
///     - fields, parsed-names, rendered, ref-label, labeled-rendered
///
/// Usage:
/// ```typst
/// // Standard usage
/// #csl-bibliography()
///
/// // Custom title
/// #csl-bibliography(title: heading(level: 2)[References])
///
/// // No title
/// #csl-bibliography(title: none)
///
/// // Full custom rendering
/// #csl-bibliography(full-control: entries => {
///   for e in entries [
///     [#e.order] #e.rendered #e.ref-label
///     #parbreak()
///   ]
/// })
/// ```
#let csl-bibliography(title: auto, full-control: none) = {
  // Query pre-rendered bibliography data (computed once in init-csl)
  // This avoids convergence issues by using pre-computed content
  context {
    let bib-data = query(<citeproc-bibliography>)
    if bib-data.len() == 0 {
      text(fill: red, "[Bibliography not initialized]")
    } else {
      let data = bib-data.first().value
      let references-text = data.references-text

      // Title handling
      let actual-title = if title == auto {
        heading(numbering: none, references-text)
      } else {
        title
      }

      if actual-title != none {
        actual-title
      }

      // Use full-control callback or pre-rendered content
      if full-control != none {
        full-control(data.entries)
      } else {
        // Use pre-rendered content
        data.rendered-content
      }
    }
  }
}
