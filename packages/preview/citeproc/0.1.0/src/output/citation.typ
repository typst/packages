// citeproc-typst - Citation Rendering Module
//
// Functions for rendering in-text citations.

#import "../core/constants.typ": POSITION, RENDER-CONTEXT
#import "../interpreter/mod.typ": create-context
#import "../interpreter/stack.typ": interpret-children-stack
#import "../parsing/locales.typ": detect-language
#import "../text/names.typ": format-names
#import "layout.typ": select-layout

// =============================================================================
// Citation Rendering
// =============================================================================

/// Render an in-text citation
///
/// - entry: Bibliography entry
/// - style: Parsed CSL style
/// - form: Citation form (none, "normal", "prose", "author", "year")
/// - supplement: Page number or other supplement
/// - cite-number: Citation number (for numeric styles)
/// - year-suffix: Year suffix for disambiguation
/// - position: Citation position ("first", "subsequent", "ibid", "ibid-with-locator")
/// - suppress-affixes: If true, don't apply prefix/suffix (for multi-cite contexts)
/// - first-note-number: Note number where this citation first appeared (for ibid/subsequent)
/// Returns: Typst content
#let render-citation(
  entry,
  style,
  form: none,
  supplement: none,
  cite-number: none,
  year-suffix: "",
  position: POSITION.first,
  suppress-affixes: false,
  first-note-number: none,
  abbreviations: (:),
  names-expanded: 0,
  givenname-level: 0,
) = {
  let ctx = create-context(
    style,
    entry,
    cite-number: cite-number,
    abbreviations: abbreviations,
  )

  let citation = style.citation
  if citation == none or citation.at("layouts", default: ()).len() == 0 {
    return text(fill: red, "[No citation layout]")
  }

  // CSL-M: Set render-context for context condition
  // Also pass et-al-subsequent settings for subsequent cites
  let ctx = (
    ..ctx,
    year-suffix: year-suffix,
    position: position,
    first-reference-note-number: if first-note-number != none {
      str(first-note-number)
    } else { "" },
    // Disambiguation state for name rendering
    names-expanded: names-expanded,
    givenname-level: givenname-level,
    render-context: RENDER-CONTEXT.citation,
    // Et-al settings for subsequent cites (CSL spec: inheritable name options)
    et-al-subsequent-min: citation.at("et-al-subsequent-min", default: none),
    et-al-subsequent-use-first: citation.at(
      "et-al-subsequent-use-first",
      default: none,
    ),
    citation-et-al-min: citation.at("et-al-min", default: none),
    citation-et-al-use-first: citation.at("et-al-use-first", default: none),
  )

  // CSL-M: Select layout based on entry language
  let entry-lang = detect-language(entry.at("fields", default: (:)))
  let layout = select-layout(citation.layouts, entry-lang)

  // CSL-M: Switch locale if layout has explicit locale attribute
  let layout-locale = layout.at("locale", default: none)
  if layout-locale != none {
    let locales = style.at("locales", default: (:))
    let locale-code = layout-locale.split(" ").first()
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

  // Interpret citation layout using stack-based interpreter with memoization
  let result = interpret-children-stack(
    layout.children,
    ctx,
    delimiter: layout.delimiter,
  )

  // Handle form variations
  if form == "author" {
    // Extract author only - use standard name formatter
    let names = ctx.parsed-names.at("author", default: ())
    if names.len() > 0 {
      // Use default name formatting attributes
      let name-attrs = (
        form: "long",
        name-as-sort-order: none,
        sort-separator: ", ",
        delimiter: ", ",
        "and": "text",
      )
      format-names(names, name-attrs, ctx)
    } else {
      "?"
    }
  } else if form == "year" {
    let year = ctx.fields.at("year", default: "n.d.")
    str(year) + year-suffix
  } else if form == "prose" {
    // Prose form: inline text without superscript/subscript
    let full-result = if supplement != none {
      [#result, #supplement]
    } else {
      result
    }

    // Apply prefix/suffix but NOT vertical-align (unless suppressed for multi-cite)
    if suppress-affixes {
      full-result
    } else {
      let prefix = layout.prefix
      let suffix = layout.suffix
      [#prefix#full-result#suffix]
    }
  } else {
    // Default form: apply all formatting
    let full-result = if supplement != none {
      [#result, #supplement]
    } else {
      result
    }

    // Apply prefix/suffix (unless suppressed for multi-cite)
    let prefix = if suppress-affixes { "" } else { layout.prefix }
    let suffix = if suppress-affixes { "" } else { layout.suffix }
    let formatted = [#prefix#full-result#suffix]

    // Apply vertical-align (superscript/subscript)
    let valign = layout.at("vertical-align", default: none)
    if valign == "sup" {
      super(formatted)
    } else if valign == "sub" {
      sub(formatted)
    } else {
      formatted
    }
  }
}
