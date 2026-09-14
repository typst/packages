// citrus - Names Rendering Module
//
// Functions for rendering names in different contexts (grouping, display, bibliography).

#import "../core/constants.typ": RENDER-CONTEXT
#import "../interpreter/mod.typ": create-context
#import "../interpreter/stack.typ": interpret-children-stack
#import "../parsing/locales.typ": detect-language
#import "layout.typ": select-layout
#import "helpers.typ": (
  content-to-string, find-first-names-macro, find-first-names-node,
)

// =============================================================================
// Names Rendering for Grouping
// =============================================================================

/// Render the first cs:names element for cite grouping comparison
///
/// CSL spec: "cites with identical rendered names are grouped together...
/// The comparison is limited to the output of the (first) cs:names element,
/// but includes output rendered through cs:substitute."
///
/// - entry: Bibliography entry
/// - style: Parsed CSL style
/// - disambig-state: Disambiguation state (names-expanded, givenname-level)
/// Returns: String representation of rendered names for grouping comparison
#let render-names-for-grouping(
  entry,
  style,
  names-expanded: 0,
  givenname-level: 0,
) = {
  let citation = style.at("citation", default: none)
  if citation == none { return "" }

  // CSL-M: Select layout based on entry language
  let entry-lang = detect-language(entry.at("fields", default: (:)))
  let layouts = citation.at("layouts", default: ())
  let layout = select-layout(layouts, entry-lang)
  if layout == none { return "" }

  // Find first cs:names element in citation layout (follows macro references)
  let macros = style.at("macros", default: (:))
  let names-node = find-first-names-node(layout, macros: macros)
  if names-node == none { return "" }

  // Create context for rendering with citation-level et-al settings
  let ctx = create-context(style, entry)
  let ctx = (
    ..ctx,
    names-expanded: names-expanded,
    givenname-level: givenname-level,
    // Citation-level et-al settings (inheritable name options)
    citation-et-al-min: citation.at("et-al-min", default: none),
    citation-et-al-use-first: citation.at("et-al-use-first", default: none),
  )

  // Render the names node using stack interpreter
  let rendered = interpret-children-stack((names-node,), ctx)

  // Convert content to string for comparison
  content-to-string(rendered)
}

/// Render names for citation display (not just comparison)
///
/// This renders the full macro that calls names, preserving correct formatting.
/// Used by multicite for displaying author names.
///
/// - entry: Bibliography entry
/// - style: Parsed CSL style
/// - names-expanded: Name expansion level for disambiguation
/// - givenname-level: Given name expansion level
/// Returns: Rendered content for display
#let render-names-for-citation-display(
  entry,
  style,
  names-expanded: 0,
  givenname-level: 0,
) = {
  let citation = style.at("citation", default: none)
  if citation == none { return [] }

  // CSL-M: Select layout based on entry language
  let entry-lang = detect-language(entry.at("fields", default: (:)))
  let layouts = citation.at("layouts", default: ())
  let layout = select-layout(layouts, entry-lang)
  if layout == none { return [] }

  // Find first macro that contains names
  let macros = style.at("macros", default: (:))
  let macro-info = find-first-names-macro(layout, macros: macros)

  if macro-info == none {
    // Fall back to direct names node rendering
    let names-node = find-first-names-node(layout, macros: macros)
    if names-node == none { return [] }

    let ctx = create-context(style, entry)
    let ctx = (
      ..ctx,
      names-expanded: names-expanded,
      givenname-level: givenname-level,
      // Citation-level et-al settings (inheritable name options)
      citation-et-al-min: citation.at("et-al-min", default: none),
      citation-et-al-use-first: citation.at("et-al-use-first", default: none),
    )
    return interpret-children-stack((names-node,), ctx)
  }

  // Render the text node that calls the macro (this interprets the macro fully)
  let ctx = create-context(style, entry)
  let ctx = (
    ..ctx,
    names-expanded: names-expanded,
    givenname-level: givenname-level,
    // Citation-level et-al settings (inheritable name options)
    citation-et-al-min: citation.at("et-al-min", default: none),
    citation-et-al-use-first: citation.at("et-al-use-first", default: none),
  )

  interpret-children-stack((macro-info.text-node,), ctx)
}

// =============================================================================
// Names Rendering for Bibliography
// =============================================================================

/// Get the first cs:names node in bibliography layout
///
/// - style: Parsed CSL style
/// Returns: The first cs:names node, or none
#let get-first-bib-names-node(style) = {
  let bib = style.at("bibliography", default: none)
  if bib == none { return none }

  let layouts = bib.at("layouts", default: ())
  if layouts.len() == 0 { return none }

  // Use the first layout (typically the default/fallback layout)
  let layout = layouts.first()
  let macros = style.at("macros", default: (:))
  find-first-names-node(layout, macros: macros)
}

/// Render the first cs:names element in bibliography for author substitution comparison
///
/// CSL spec for subsequent-author-substitute:
/// "Substitution is limited to the names of the first cs:names element rendered."
///
/// - entry: Bibliography entry
/// - style: Parsed CSL style
/// - names-expanded: Name expansion level for disambiguation
/// - givenname-level: Given name expansion level
/// Returns: String representation of rendered names for comparison
#let render-names-for-bibliography(
  entry,
  style,
  names-expanded: 0,
  givenname-level: 0,
) = {
  let names-node = get-first-bib-names-node(style)
  if names-node == none { return "" }

  // Create context for rendering
  let ctx = create-context(style, entry)
  let ctx = (
    ..ctx,
    names-expanded: names-expanded,
    givenname-level: givenname-level,
    render-context: RENDER-CONTEXT.bibliography,
  )

  // Render the names node using stack interpreter
  let rendered = interpret-children-stack((names-node,), ctx)

  // Convert content to string for comparison
  content-to-string(rendered)
}
