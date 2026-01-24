// citeproc-typst - Interpretation Context
//
// Creates the context object used during CSL interpretation.
//
// =============================================================================
// Naming Convention: parsed_names vs parsed-names
// =============================================================================
//
// External data (from citegeist) uses Python/underscore convention:
//   - entry.parsed_names  (underscore - as returned by citegeist)
//   - entry.entry_type    (underscore - as returned by citegeist)
//
// Internal context uses Typst/hyphen convention:
//   - ctx.parsed-names    (hyphen - Typst idiomatic)
//   - ctx.entry-type      (hyphen - Typst idiomatic)
//
// This create-context function bridges the two conventions, reading from
// external underscore format and exposing internal hyphen format.

// =============================================================================
// Context Creation
// =============================================================================

/// Create interpretation context
/// - cite-number: Optional citation number to inject
/// - abbreviations: Optional abbreviation lookup table
/// - disambiguate: Optional flag for CSL disambiguate condition (Method 3)
#let create-context(
  style,
  entry,
  cite-number: none,
  abbreviations: (:),
  disambiguate: false,
) = {
  let fields = entry.at("fields", default: (:))
  let is-csl-json = fields.at("_source", default: "") == "csl-json"

  // Inject citation number if provided
  if cite-number != none {
    fields.insert("citation-number", str(cite-number))
  }

  // Map CSL name variables to BibTeX name fields
  let raw-names = entry.at("parsed_names", default: (:))
  let mapped-names = raw-names

  // For CSL-JSON, names are already in CSL format (author, editor, container-author, etc.)
  // For BibTeX, we need to map some fields
  if not is-csl-json {
    // Add CSL variable aliases for BibTeX fields
    // container-author -> bookauthor (for chapters in books)
    if "bookauthor" in raw-names and "container-author" not in raw-names {
      mapped-names.insert("container-author", raw-names.at("bookauthor"))
    }

    // CSL-M original-* name variables (for bilingual entries)
    // Maps to BibTeX -en suffix fields if parsed by citegeist
    if "author-en" in raw-names and "original-author" not in raw-names {
      mapped-names.insert("original-author", raw-names.at("author-en"))
    }
    if "editor-en" in raw-names and "original-editor" not in raw-names {
      mapped-names.insert("original-editor", raw-names.at("editor-en"))
    }
  }

  // Determine entry type
  // For CSL-JSON, use csl-type field directly if available
  let entry-type = if is-csl-json and "csl-type" in fields {
    fields.at("csl-type")
  } else {
    entry.at("entry_type", default: "misc")
  }

  (
    style: style,
    entry: entry,
    macros: style.macros,
    locale: style.locale,
    fields: fields,
    parsed-names: mapped-names,
    entry-type: entry-type,
    is-csl-json: is-csl-json,
    abbreviations: abbreviations,
    disambiguate: disambiguate,
  )
}

// =============================================================================
// Context Update Functions
// =============================================================================
//
// These functions document the optional context fields that can be added
// after initial creation. Using these functions makes the spreading pattern
// explicit and provides a single source of truth for field names.

/// Add year-suffix to context for disambiguation
///
/// - ctx: Base context
/// - suffix: Year suffix string (e.g., "a", "b")
/// Returns: Updated context
#let with-year-suffix(ctx, suffix) = {
  (..ctx, year-suffix: suffix)
}

/// Add position info to context for citation rendering
///
/// - ctx: Base context
/// - position: Position type ("first", "subsequent", "ibid", "ibid-with-locator")
/// Returns: Updated context
#let with-position(ctx, position) = {
  (..ctx, position: position)
}

/// Add disambiguation state to context
///
/// - ctx: Base context
/// - names-expanded: Number of additional names to show
/// - givenname-level: Given name expansion level (0=none, 1=initials, 2=full)
/// Returns: Updated context
#let with-disambiguation(ctx, names-expanded, givenname-level) = {
  (
    ..ctx,
    names-expanded: names-expanded,
    givenname-level: givenname-level,
  )
}

/// Add render context type to context
///
/// - ctx: Base context
/// - render-context: "citation" or "bibliography"
/// Returns: Updated context
#let with-render-context(ctx, render-context) = {
  (..ctx, render-context: render-context)
}

/// Add citation-level et-al settings to context
///
/// - ctx: Base context
/// - et-al-min: Minimum authors before et al
/// - et-al-use-first: Number of authors to show before et al
/// Returns: Updated context
#let with-citation-et-al(ctx, et-al-min, et-al-use-first) = {
  (
    ..ctx,
    citation-et-al-min: et-al-min,
    citation-et-al-use-first: et-al-use-first,
  )
}

/// Add first-reference-note-number for subsequent citations
///
/// - ctx: Base context
/// - note-number: The note number of first occurrence (or none)
/// Returns: Updated context
#let with-first-note-number(ctx, note-number) = {
  (
    ..ctx,
    first-reference-note-number: if note-number != none {
      str(note-number)
    } else { "" },
  )
}

/// Add author substitution info for bibliography grouping
///
/// - ctx: Base context
/// - substitute: Substitute string (e.g., "---")
/// - rule: Substitution rule (e.g., "complete-all")
/// - vars: Variables from first cs:names element
/// Returns: Updated context
#let with-author-substitute(ctx, substitute, rule, vars) = {
  (
    ..ctx,
    author-substitute: substitute,
    author-substitute-rule: rule,
    substitute-vars: vars,
  )
}

/// Add locale override to context
///
/// - ctx: Base context
/// - locale: Locale object to use
/// Returns: Updated context
#let with-locale(ctx, locale) = {
  (..ctx, locale: locale)
}
