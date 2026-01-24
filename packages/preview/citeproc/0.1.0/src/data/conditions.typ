// citeproc-typst - CSL Condition Evaluator
//
// Evaluates CSL conditional expressions (if/else-if)
// Includes CSL-M extension conditions

#import "variables.typ": get-variable, has-variable  // Same directory
#import "../core/constants.typ": POSITION, RENDER-CONTEXT

// =============================================================================
// Module-level constants (avoid recreating on each call)
// =============================================================================

// Regex patterns for condition evaluation
#let _starts-with-digit-pattern = regex("\\d")
#let _iso-date-with-day-pattern = regex("^\\d{4}[-/]\\d{1,2}[-/]\\d{1,2}")
#let _text-date-with-day-pattern = regex("[A-Za-z]+\\s+\\d{1,2},?\\s+\\d{4}")

// Map BibTeX types to CSL types (including CSL-M legal types)
#let _type-map = (
  // Standard CSL types
  "article": "article-journal",
  "book": "book",
  "inbook": "chapter",
  "incollection": "chapter",
  "inproceedings": "paper-conference",
  "conference": "paper-conference",
  "phdthesis": "thesis",
  "mastersthesis": "thesis",
  "thesis": "thesis",
  "techreport": "report",
  "report": "report",
  "misc": "document",
  "online": "webpage",
  "webpage": "webpage",
  "patent": "patent",
  "standard": "standard",
  "dataset": "dataset",
  "software": "software",
  "periodical": "periodical",
  "collection": "book",
  // CSL-M legal types
  "legal_case": "legal_case",
  "case": "legal_case",
  "legislation": "legislation",
  "statute": "legislation",
  "bill": "bill",
  "hearing": "hearing",
  "regulation": "regulation",
  "treaty": "treaty",
  "classic": "classic",
  "video": "video",
  "legal_commentary": "legal_commentary",
  "gazette": "gazette",
)

// Map user-specified `mark` field to CSL types
// Users can set mark = {S} in bib file to override type detection
//
// GB/T 7714 document type codes:
//   M - book, C - conference, N - newspaper, J - journal,
//   D - thesis, R - report, S - standard, P - patent,
//   G - collection, EB - online, DB - database, etc.
//
// CSL-M legal types can also be specified directly.
#let _mark-map = (
  // GB/T 7714 codes
  "M": "book",
  "C": "paper-conference",
  "N": "article-newspaper",
  "J": "article-journal",
  "D": "thesis",
  "R": "report",
  "S": "standard",
  "P": "patent",
  "G": "book", // collection -> book
  "EB": "webpage",
  "DB": "dataset",
  "CP": "software",
  "A": "chapter", // analytic (chapter in book)
  "Z": "document", // other/miscellaneous
  // CSL-M legal types (use type name directly)
  "LEGISLATION": "legislation",
  "LEGAL_CASE": "legal_case",
  "REGULATION": "regulation",
  "BILL": "bill",
  "HEARING": "hearing",
  "TREATY": "treaty",
)

/// Check if entry type matches
/// Priority: CSL-JSON type > mark field > BibTeX type mapping > raw type
#let check-type(ctx, type-list) = {
  let fields = ctx.fields
  let is-csl-json = ctx.at("is-csl-json", default: false)

  let csl-type = none

  // 0. For CSL-JSON, use the csl-type field directly (already in CSL format)
  if is-csl-json and "csl-type" in fields {
    csl-type = fields.at("csl-type")
  }

  // 1. Check for user-specified mark field (highest priority for BibTeX)
  if csl-type == none {
    let mark = fields.at("mark", default: none)
    if mark != none {
      csl-type = _mark-map.at(upper(str(mark)), default: none)
    }
  }

  // 2. Fall back to BibTeX type mapping
  if csl-type == none {
    let entry-type = ctx.entry-type
    csl-type = _type-map.at(entry-type, default: entry-type)
  }

  // Split type list and check
  let types = type-list.split(" ")
  types.any(t => t == csl-type)
}

/// Check if variable exists
#let check-variable(ctx, var-list) = {
  let vars = var-list.split(" ")
  vars.any(v => has-variable(ctx, v))
}

/// Check if value is numeric
/// CSL spec: numeric if it starts with a digit
#let check-is-numeric(ctx, var-name) = {
  let val = get-variable(ctx, var-name)
  if val == "" { return false }
  val.starts-with(_starts-with-digit-pattern)
}

/// Evaluate a CSL condition
///
/// - attrs: Condition attributes (type, variable, match, etc.)
/// - ctx: Interpretation context
/// Returns: bool
#let eval-condition(attrs, ctx) = {
  let match-mode = attrs.at("match", default: "all")

  // For "all" mode, use early return optimization
  // This avoids evaluating remaining conditions once we know the result
  let is-all-mode = match-mode == "all"
  let conditions = ()

  // Helper to add condition result with early return for "all" mode
  let add-condition(result) = {
    if is-all-mode and not result {
      return false // Early return - no need to check more
    }
    conditions.push(result)
    true
  }

  // Type condition
  if "type" in attrs {
    let result = check-type(ctx, attrs.type)
    if is-all-mode and not result { return false }
    conditions.push(result)
  }

  // Variable condition
  if "variable" in attrs {
    let result = check-variable(ctx, attrs.variable)
    if is-all-mode and not result { return false }
    conditions.push(result)
  }

  // Is-numeric condition
  if "is-numeric" in attrs {
    conditions.push(check-is-numeric(ctx, attrs.at("is-numeric")))
  }

  // Is-uncertain-date condition
  // CSL spec: true if date has uncertainty markers (circa, ~, ?)
  if "is-uncertain-date" in attrs {
    let date-var = attrs.at("is-uncertain-date")
    let date-val = get-variable(ctx, date-var)
    let is-uncertain = if date-val != "" {
      // Check for uncertainty markers
      let s = lower(str(date-val))
      (
        s.contains("circa")
          or s.contains("c.")
          or s.contains("~")
          or s.contains("?")
          or s.contains("ca.")
          or s.contains("approximately")
      )
    } else { false }
    conditions.push(is-uncertain)
  }

  // Has-day condition (for dates) - standard CSL, not CSL-M
  // Note: CSL-M has its own has-day handled below
  if (
    "has-day" in attrs
      and "has-day" not in ("has-to-month-or-season", "has-year-only")
  ) {
    let date-var = attrs.at("has-day")
    let date-val = get-variable(ctx, date-var)
    let has-day-result = if date-val != "" {
      // Check for day component in various formats
      let s = str(date-val)
      // YYYY-MM-DD format
      let iso-match = s.match(_iso-date-with-day-pattern)
      if iso-match != none {
        true
      } else {
        // "Month Day, Year" format
        let text-match = s.match(_text-date-with-day-pattern)
        text-match != none
      }
    } else { false }
    conditions.push(has-day-result)
  }

  // Position condition (first, subsequent, ibid, ibid-with-locator, near-note)
  if "position" in attrs {
    let pos-value = attrs.at("position")
    let current-pos = ctx.at("position", default: POSITION.first)
    let positions = pos-value.split(" ")

    // Pre-compute note distance if needed (avoid repeated lookups)
    let note-distance = if (
      positions.any(p => p == "near-note" or p == "far-note")
    ) {
      let last-note = ctx.at("last-note-number", default: none)
      let current-note = ctx.at("note-number", default: none)
      if last-note != none and current-note != none {
        current-note - last-note
      } else { none }
    } else { none }
    let near-note-threshold = ctx.style.at("near-note-distance", default: 5)

    let matches = positions.any(p => {
      if p == current-pos {
        true
      } else if p == POSITION.subsequent {
        (
          current-pos
            in (POSITION.subsequent, POSITION.ibid, POSITION.ibid-with-locator)
        )
      } else if p == "near-note" {
        note-distance != none and note-distance <= near-note-threshold
      } else if p == "far-note" {
        note-distance == none or note-distance > near-note-threshold
      } else {
        false
      }
    })
    conditions.push(matches)
  }

  // Locator condition (check if locator/supplement is present)
  if "locator" in attrs {
    let has-locator = ctx.at("locator", default: none) != none
    conditions.push(has-locator)
  }

  // Disambiguate condition (CSL Method 3)
  // CSL spec: "A disambiguation attempt can also be made by rendering
  // ambiguous cites with the disambiguate condition testing 'true'."
  // The context should have a 'disambiguate' flag set when the cite
  // needs additional disambiguation beyond methods 1, 2, and 4.
  if "disambiguate" in attrs {
    let disambiguate-value = attrs.at("disambiguate")
    let needs-disambig = ctx.at("disambiguate", default: false)
    conditions.push(disambiguate-value == "true" and needs-disambig)
  }

  // =========================================================================
  // CSL-M Extension Conditions
  // =========================================================================

  // Context condition (CSL-M): check if rendering in citation or bibliography
  if "context" in attrs {
    let context-value = attrs.at("context")
    let current-context = ctx.at(
      "render-context",
      default: RENDER-CONTEXT.bibliography,
    )
    conditions.push(context-value == current-context)
  }

  // Genre condition (CSL-M): check genre field for specific values
  if "genre" in attrs {
    let genre-list = attrs.at("genre").split(" ")
    let entry-genre = get-variable(ctx, "genre")
    conditions.push(genre-list.any(g => g == entry-genre))
  }

  // Has-day condition (CSL-M): check if date has day component
  if "has-day" in attrs {
    let date-var = attrs.at("has-day")
    let date-val = get-variable(ctx, date-var)
    // Check if the date string contains day component (YYYY-MM-DD format)
    let has-day = if date-val != "" {
      let parts = date-val.split("-")
      parts.len() >= 3 and parts.at(2, default: "") != ""
    } else { false }
    conditions.push(has-day)
  }

  // Has-year-only condition (CSL-M): check if date has only year
  if "has-year-only" in attrs {
    let date-var = attrs.at("has-year-only")
    let date-val = get-variable(ctx, date-var)
    let has-year-only = if date-val != "" {
      let parts = date-val.split("-")
      parts.len() == 1 or (parts.len() >= 2 and parts.at(1, default: "") == "")
    } else { false }
    conditions.push(has-year-only)
  }

  // Has-to-month-or-season condition (CSL-M): date has month/season but no day
  if "has-to-month-or-season" in attrs {
    let date-var = attrs.at("has-to-month-or-season")
    let date-val = get-variable(ctx, date-var)
    let has-month-only = if date-val != "" {
      let parts = date-val.split("-")
      (
        parts.len() >= 2
          and parts.at(1, default: "") != ""
          and (parts.len() < 3 or parts.at(2, default: "") == "")
      )
    } else { false }
    conditions.push(has-month-only)
  }

  // Is-multiple condition (CSL-M): check if variable contains multiple values (has space)
  if "is-multiple" in attrs {
    let var-name = attrs.at("is-multiple")
    let val = get-variable(ctx, var-name)
    conditions.push(val != "" and val.contains(" "))
  }

  // No conditions means true (for <else>)
  if conditions.len() == 0 {
    return true
  }

  // Apply match mode (including CSL-M "nand")
  if match-mode == "any" {
    conditions.any(c => c)
  } else if match-mode == "none" {
    not conditions.any(c => c)
  } else if match-mode == "nand" {
    // CSL-M extension: true if at least one condition is false
    not conditions.all(c => c)
  } else {
    // "all" is default
    conditions.all(c => c)
  }
}

// =============================================================================
// CSL-M Nested Conditions (cs:conditions element)
// =============================================================================

/// Evaluate nested conditions (CSL-M extension)
///
/// The cs:conditions element allows grouping multiple cs:condition children
/// with a match attribute applied to the group.
///
/// - conditions-node: The cs:conditions element
/// - ctx: Interpretation context
/// Returns: bool
#let eval-nested-conditions(conditions-node, ctx) = {
  let attrs = conditions-node.at("attrs", default: (:))
  let children = conditions-node.at("children", default: ())
  let match-mode = attrs.at("match", default: "all")

  // Evaluate each child condition
  let results = ()
  for child in children {
    if type(child) != dictionary { continue }
    if child.at("tag", default: "") != "condition" { continue }

    let child-attrs = child.at("attrs", default: (:))
    results.push(eval-condition(child-attrs, ctx))
  }

  // Apply match mode to results
  if match-mode == "any" {
    results.any(r => r)
  } else if match-mode == "none" {
    not results.any(r => r)
  } else if match-mode == "nand" {
    not results.all(r => r)
  } else {
    results.all(r => r)
  }
}
