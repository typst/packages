// citrus - Entry Rendering Module
//
// Functions for rendering bibliography entries.

#import "../core/constants.typ": RENDER-CONTEXT
#import "../interpreter/mod.typ": create-context
#import "../interpreter/stack.typ": interpret-children-stack
#import "../parsing/locales.typ": detect-language
#import "layout.typ": select-layout
#import "punctuation.typ": collapse-punctuation
#import "helpers.typ": node-uses-citation-number

// =============================================================================
// Entry Rendering
// =============================================================================

/// Render only the citation number for an entry
///
/// - entry: Bibliography entry from citegeist
/// - style: Parsed CSL style
/// - cite-number: Citation number for numeric styles
/// Returns: Typst content (just the formatted number, e.g., "〔1〕")
#let render-citation-number(entry, style, cite-number: none) = {
  let ctx = create-context(style, entry, cite-number: cite-number)
  // CSL-M: Set render-context (citation-number is used in bibliography)
  let ctx = (..ctx, render-context: RENDER-CONTEXT.bibliography)
  let entry-lang = detect-language(entry.at("fields", default: (:)))

  let bib = style.at("bibliography", default: none)
  if bib == none { return [] }

  let layout = select-layout(bib.at("layouts", default: ()), entry-lang)
  if layout == none { return [] }

  // Find and render only the citation-number node
  let number-nodes = layout.children.filter(node => node-uses-citation-number(
    node,
  ))
  if number-nodes.len() > 0 {
    interpret-children-stack(number-nodes, ctx)
  } else {
    // Fallback: simple bracketed number
    [[#cite-number]]
  }
}

/// Render a bibliography entry
///
/// - entry: Bibliography entry from citegeist
/// - style: Parsed CSL style
/// - cite-number: Citation number for numeric styles
/// - year-suffix: Year suffix for disambiguation (e.g., "a", "b")
/// - include-number: Whether to include citation number in output
/// - author-substitute: String to replace author names with (for subsequent-author-substitute)
/// - author-substitute-rule: Rule for how to substitute
/// - author-substitute-count: Number of matching names to substitute (for partial-* rules)
/// - substitute-vars: Variable names of the first cs:names to substitute
/// - auto-links: Whether to auto-link DOI/URL/PMID/PMCID (default: true)
/// Returns: Typst content
#let render-entry(
  entry,
  style,
  cite-number: none,
  year-suffix: "",
  include-number: true,
  abbreviations: (:),
  names-expanded: 0,
  givenname-level: 0,
  needs-disambiguate: false,
  author-substitute: none,
  author-substitute-rule: "complete-all",
  author-substitute-count: 0,
  substitute-vars: "author",
  auto-links: true,
) = {
  let ctx = create-context(
    style,
    entry,
    cite-number: cite-number,
    abbreviations: abbreviations,
    disambiguate: needs-disambiguate,
  )

  // Inject year suffix and disambiguation info into context for rendering
  // CSL-M: Set render-context for context condition
  // Also add author-substitute info for bibliography grouping
  let ctx = (
    ..ctx,
    year-suffix: year-suffix,
    names-expanded: names-expanded,
    givenname-level: givenname-level,
    render-context: RENDER-CONTEXT.bibliography,
    author-substitute: author-substitute,
    author-substitute-rule: author-substitute-rule,
    author-substitute-count: author-substitute-count,
    substitute-vars: substitute-vars, // Variables from first cs:names element
    auto-links: auto-links,
  )

  let entry-lang = detect-language(entry.at("fields", default: (:)))

  // Find matching layout (with null-safety for citation-only styles)
  let bib = style.at("bibliography", default: none)
  if bib == none {
    return text(fill: red, "[No bibliography element in CSL]")
  }

  let layout = select-layout(bib.at("layouts", default: ()), entry-lang)

  if layout == none {
    return text(fill: red, "[No bibliography layout defined]")
  }

  // CSL-M: Switch locale if layout has explicit locale attribute
  let layout-locale = layout.at("locale", default: none)
  if layout-locale != none {
    let locales = style.at("locales", default: (:))
    let locale-code = layout-locale.split(" ").first()
    // Try exact match, then prefix match
    let target-locale = locales.at(locale-code, default: none)
    if target-locale == none {
      let prefix = if locale-code.len() >= 2 { locale-code.slice(0, 2) } else {
        locale-code
      }
      target-locale = locales.at(prefix, default: none)
    }
    if target-locale != none {
      ctx = (..ctx, locale: target-locale)
    }
  }
  // Fallback layout (no locale attr) uses style's default-locale (ctx.locale unchanged)

  // Filter out citation-number nodes if requested
  let children = if include-number {
    layout.children
  } else {
    layout.children.filter(node => not node-uses-citation-number(node))
  }

  // Use stack-based interpreter with built-in memoization
  // This reduces O(calls * depth) to O(unique macros) for macro expansion
  let result = interpret-children-stack(children, ctx)

  // Apply layout suffix (usually ".")
  let layout-suffix = layout.at("suffix", default: ".")

  // Apply punctuation collapsing to CSL output only
  collapse-punctuation([#result#layout-suffix])
}

/// Render a bibliography entry from an entry IR
///
/// - entry-ir: Entry IR with disambig info
/// - style: Parsed CSL style
/// - include-number: Whether to include citation number in output
/// - abbreviations: Optional abbreviation lookup table
/// - author-substitute: String to replace author names with (for subsequent-author-substitute)
/// - author-substitute-rule: Rule for how to substitute
/// - author-substitute-count: Number of matching names to substitute (for partial-* rules)
/// - substitute-vars: Variable names of the first cs:names to substitute
/// - auto-links: Whether to auto-link DOI/URL/PMID/PMCID (default: true)
/// Returns: Typst content
#let render-entry-ir(
  entry-ir,
  style,
  include-number: true,
  abbreviations: (:),
  author-substitute: none,
  author-substitute-rule: "complete-all",
  author-substitute-count: 0,
  substitute-vars: "author",
  auto-links: true,
) = {
  let disambig = entry-ir.disambig
  render-entry(
    entry-ir.entry,
    style,
    cite-number: entry-ir.order,
    year-suffix: disambig.at("year-suffix", default: ""),
    include-number: include-number,
    abbreviations: abbreviations,
    names-expanded: disambig.at("names-expanded", default: 0),
    givenname-level: disambig.at("givenname-level", default: 0),
    needs-disambiguate: disambig.at("needs-disambiguate", default: false),
    author-substitute: author-substitute,
    author-substitute-rule: author-substitute-rule,
    author-substitute-count: author-substitute-count,
    substitute-vars: substitute-vars,
    auto-links: auto-links,
  )
}
