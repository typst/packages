// citrus - Entry Rendering Module
//
// Functions for rendering bibliography entries.

#import "../core/constants.typ": RENDER-CONTEXT
#import "../core/mod.typ": is-empty
#import "../interpreter/mod.typ": create-context
#import "../interpreter/stack.typ": interpret-children-stack
#import "../parsing/mod.typ": detect-language
#import "layout.typ": select-layout
#import "punctuation.typ": collapse-punctuation, get-punctuation-in-quote
#import "helpers.typ": (
  _children-use-citation-label, content-to-string, node-uses-citation-label,
  node-uses-citation-number, style-uses-citation-number,
)

// =============================================================================
// Entry Rendering
// =============================================================================

/// Render only the citation number for an entry
///
/// - entry: Bibliography entry from citegeist
/// - style: Parsed CSL style
/// - cite-number: Citation number for numeric styles
/// - year-suffix: Year suffix for disambiguation
/// Returns: Typst content (just the formatted number, e.g., "〔1〕")
#let render-citation-number(
  entry,
  style,
  cite-number: none,
  year-suffix: none,
) = {
  let ctx = create-context(style, entry, cite-number: cite-number)
  // CSL-M: Set render-context (citation-number is used in bibliography)
  let ctx = (
    ..ctx,
    render-context: RENDER-CONTEXT.bibliography,
    year-suffix: year-suffix,
  )
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
    let rendered = interpret-children-stack(number-nodes, ctx)
    if is-empty(rendered) {
      [[#cite-number]]
    } else {
      rendered
    }
  } else {
    // Fallback: try citation-label, otherwise simple bracketed number
    let label-nodes = layout.children.filter(node => node-uses-citation-label(
      node,
    ))
    if label-nodes.len() > 0 {
      interpret-children-stack(label-nodes, ctx)
    } else {
      [[#cite-number]]
    }
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
  year-suffix: none,
  include-number: true,
  abbreviations: (:),
  names-expanded: 0,
  givenname-level: 0,
  givenname-levels: (),
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
  // CSL spec: has-explicit-year-suffix determines if year-suffix is auto-appended to dates
  let bib-settings = style.at("bibliography", default: (:))
  // Handle case where bibliography key exists but value is none
  if bib-settings == none { bib-settings = (:) }
  let ctx = (
    ..ctx,
    year-suffix: year-suffix,
    names-expanded: names-expanded,
    givenname-level: givenname-level,
    givenname-levels: givenname-levels,
    render-context: RENDER-CONTEXT.bibliography,
    author-substitute: author-substitute,
    author-substitute-rule: author-substitute-rule,
    author-substitute-count: author-substitute-count,
    substitute-vars: substitute-vars, // Variables from first cs:names element
    auto-links: auto-links,
    has-explicit-year-suffix: bib-settings.at(
      "has-explicit-year-suffix",
      default: false,
    ),
    // Name formatting options (inheritable from bibliography level)
    // Use same keys as citation for unified lookup in names.typ
    citation-and: bib-settings.at("and", default: none),
    citation-name-delimiter: bib-settings.at("name-delimiter", default: none),
    citation-delimiter-precedes-et-al: bib-settings.at(
      "delimiter-precedes-et-al",
      default: none,
    ),
    citation-delimiter-precedes-last: bib-settings.at(
      "delimiter-precedes-last",
      default: none,
    ),
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

  let uses-label = _children-use-citation-label(
    layout.at("children", default: ()),
  )
  if uses-label and ctx.at("year-suffix", default: none) != none {
    ctx = (..ctx, has-explicit-year-suffix: true)
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

  // Filter out citation-number/label nodes if requested
  let children = if include-number {
    layout.children
  } else {
    layout.children.filter(node => (
      not node-uses-citation-number(node) and not node-uses-citation-label(node)
    ))
  }

  // Render bibliography layout
  // Use compiled function if available and not filtering, otherwise fall back to interpreter
  let result = {
    let compiled = style.at("compiled", default: none)
    let use-compiler = sys.inputs.at("compiler", default: "false") == "true"
    // Only use compiled version when include-number=true (no filtering needed)
    if compiled != none and include-number and use-compiler {
      // Get the compiled layout for this locale
      let bib-layouts = compiled.at("bibliography-layouts", default: (:))
      let layout-key = if layout-locale != none { layout-locale } else {
        "_default"
      }
      let compiled-layout = bib-layouts.at(layout-key, default: none)

      // Fallback to default if locale-specific not found
      if compiled-layout == none {
        compiled-layout = bib-layouts.at("_default", default: none)
      }

      if compiled-layout != none {
        // Add compiled macros to context for macro calls
        let ctx = (..ctx, compiled-macros: compiled.macros, done-vars: ())
        let (content, _state, _done, _ends) = (compiled-layout)(ctx)
        content
      } else {
        // Fall back to interpreter if no compiled layout found
        interpret-children-stack(children, ctx)
      }
    } else {
      // Fall back to stack-based interpreter (handles filtering case)
      interpret-children-stack(children, ctx)
    }
  }

  if is-empty(result) {
    if ctx.render-context == RENDER-CONTEXT.bibliography {
      if not style-uses-citation-number(style) {
        return []
      }
    }
    let error = "[CSL STYLE ERROR: reference with no printed form.]"
    if include-number and style-uses-citation-number(style) {
      let number-content = if cite-number != none { str(cite-number) } else {
        ""
      }
      if number-content != "" {
        return [#number-content#". "#error]
      }
    }
    return error
  }

  // Apply layout suffix (usually ".")
  let layout-suffix = layout.at("suffix", default: ".")

  // Apply punctuation collapsing to CSL output only
  collapse-punctuation(
    [#result#layout-suffix],
    punctuation-in-quote: get-punctuation-in-quote(style),
  )
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
    year-suffix: disambig.at("year-suffix", default: none),
    include-number: include-number,
    abbreviations: abbreviations,
    names-expanded: disambig.at("names-expanded", default: 0),
    // CSL spec: givenname disambiguation only applies to citations, not bibliography.
    // Bibliography names always render per their <name> format (with initialize-with, etc.).
    givenname-level: 0,
    givenname-levels: (),
    needs-disambiguate: disambig.at("needs-disambiguate", default: false),
    author-substitute: author-substitute,
    author-substitute-rule: author-substitute-rule,
    author-substitute-count: author-substitute-count,
    substitute-vars: substitute-vars,
    auto-links: auto-links,
  )
}
