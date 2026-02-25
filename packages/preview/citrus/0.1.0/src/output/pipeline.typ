// citrus - IR Pipeline Module
//
// Functions for processing entries through the full IR (Intermediate Representation) pipeline.

#import "../core/state.typ": create-entry-ir
#import "../data/sorting.typ": sort-bibliography-entries
#import "../data/disambiguation.typ": apply-disambiguation
#import "helpers.typ": style-uses-citation-number
#import "names-render.typ": (
  get-first-bib-names-node, render-names-for-bibliography,
)
#import "entry.typ": render-citation-number, render-entry-ir

// =============================================================================
// Name Comparison Helpers for Subsequent Author Substitute
// =============================================================================

/// Check if two name dicts are equal
/// Compares family, given, and literal fields
#let _names-equal(name1, name2) = {
  if name1 == none or name2 == none { return false }
  let family1 = name1.at("family", default: "")
  let family2 = name2.at("family", default: "")
  let given1 = name1.at("given", default: "")
  let given2 = name2.at("given", default: "")
  let literal1 = name1.at("literal", default: "")
  let literal2 = name2.at("literal", default: "")

  if literal1 != "" or literal2 != "" {
    literal1 == literal2
  } else {
    family1 == family2 and given1 == given2
  }
}

/// Count how many names match from the start of two name lists
#let _count-matching-names(names1, names2) = {
  let count = 0
  let min-len = calc.min(names1.len(), names2.len())
  for i in range(min-len) {
    if _names-equal(names1.at(i), names2.at(i)) {
      count += 1
    } else {
      break
    }
  }
  count
}

// =============================================================================
// IR Pipeline
// =============================================================================

/// Process entries through the full IR pipeline
///
/// Phase 1: Create IRs with order info
/// Phase 2: Sort entries
/// Phase 3: Apply disambiguation
///
/// - bib-data: Dictionary of key -> entry
/// - citations: Citation info from collect-citations()
/// - style: Parsed CSL style
/// Returns: Array of processed entry IRs, sorted and disambiguated
#let process-entries(bib-data, citations, style) = {
  // Phase 1: Create entry IRs
  let entries = citations
    .order
    .pairs()
    .map(((key, order)) => {
      let entry = bib-data.at(key, default: none)
      if entry == none { return none }
      create-entry-ir(key, entry, order, style)
    })
    .filter(x => x != none)

  // Determine if bibliography should be sorted by citation order
  // Check if style uses citation-number variable
  let uses-citation-number = style-uses-citation-number(style)

  // Phase 2: Sort entries
  // - If bibliography uses citation-number: sort by citation order
  // - Otherwise: use CSL <sort> if present
  let sorted-entries = sort-bibliography-entries(
    entries,
    style,
    by-order: uses-citation-number,
  )

  // Phase 3: Apply disambiguation
  let disambig-entries = apply-disambiguation(sorted-entries, style)

  disambig-entries
}

/// Get rendered bibliography entries
///
/// - bib-data: Dictionary of key -> entry
/// - citations: Citation info from collect-citations()
/// - style: Parsed CSL style
/// - abbreviations: Optional abbreviation lookup table
/// - precomputed: Optional precomputed data with sorted-keys and disambig-states
/// Returns: Array of (entry-ir, rendered, rendered-body, rendered-number, label) tuples
#let get-rendered-entries(
  bib-data,
  citations,
  style,
  abbreviations: (:),
  precomputed: none,
) = {
  // Use precomputed sorted order and disambig states if available
  let entries = if (
    precomputed != none
      and precomputed.at(
        "sorted-keys",
        default: none,
      )
        != none
  ) {
    let sorted-keys = precomputed.sorted-keys
    let disambig-states = precomputed.at("disambig-states", default: (:))

    // Reconstruct entries in cached sorted order with cached disambig
    sorted-keys
      .enumerate()
      .map(((idx, key)) => {
        let entry = bib-data.at(key, default: none)
        if entry == none { return none }
        let order = citations.order.at(key, default: idx)
        let ir = create-entry-ir(key, entry, order, style)
        // Apply cached disambiguation state
        let disambig = disambig-states.at(key, default: ir.disambig)
        (..ir, disambig: disambig)
      })
      .filter(x => x != none)
  } else {
    // Fall back to full processing
    process-entries(bib-data, citations, style)
  }

  // Get subsequent-author-substitute settings
  let bib-settings = style.at("bibliography", default: (:))
  let substitute = bib-settings.at(
    "subsequent-author-substitute",
    default: none,
  )
  let substitute-rule = bib-settings.at(
    "subsequent-author-substitute-rule",
    default: "complete-all",
  )

  // Get the first cs:names node in bibliography to identify which variables to substitute
  let first-names-node = get-first-bib-names-node(style)
  let substitute-vars = if first-names-node != none {
    first-names-node.at("attrs", default: (:)).at("variable", default: "author")
  } else { "author" }

  // Track previous entry's names for substitution
  // prev-names: rendered string for comparison
  // prev-names-list: parsed names list for per-name comparison (partial-* rules)
  let prev-names = none
  let prev-names-list = none
  let result = ()

  for e in entries {
    // Get current entry's names string for comparison
    // Use bibliography layout, not citation layout
    let current-names = render-names-for-bibliography(
      e.entry,
      style,
      names-expanded: e.disambig.at("names-expanded", default: 0),
      givenname-level: e.disambig.at("givenname-level", default: 0),
    )

    // Get the parsed names list for the substitute variable (for per-name comparison)
    let substitute-var = substitute-vars.split(" ").first()
    let current-names-list = e
      .entry
      .at("parsed_names", default: (:))
      .at(
        substitute-var,
        default: (),
      )

    // Determine if we should substitute and how
    let should-substitute = false
    let matching-count = 0 // Number of matching names from the start

    if substitute != none and prev-names != none and current-names != "" {
      // CSL spec: comparison is limited to output of first cs:names element
      if substitute-rule == "complete-all" {
        // Only substitute if all names match exactly
        should-substitute = current-names == prev-names
      } else if substitute-rule == "complete-each" {
        // Substitute each name if ALL match
        should-substitute = current-names == prev-names
        if should-substitute {
          matching-count = current-names-list.len()
        }
      } else if substitute-rule == "partial-each" {
        // Substitute matching names from start until first mismatch
        if prev-names-list != none {
          matching-count = _count-matching-names(
            current-names-list,
            prev-names-list,
          )
          should-substitute = matching-count > 0
        }
      } else if substitute-rule == "partial-first" {
        // Substitute only first name if it matches
        if prev-names-list != none and prev-names-list.len() > 0 {
          if (
            current-names-list.len() > 0
              and _names-equal(
                current-names-list.first(),
                prev-names-list.first(),
              )
          ) {
            should-substitute = true
            matching-count = 1
          }
        }
      }
    }

    result.push((
      ir: e,
      rendered: render-entry-ir(
        e,
        style,
        include-number: true,
        abbreviations: abbreviations,
        author-substitute: if should-substitute { substitute } else { none },
        author-substitute-rule: substitute-rule,
        author-substitute-count: matching-count,
        substitute-vars: substitute-vars,
      ),
      rendered-body: render-entry-ir(
        e,
        style,
        include-number: false,
        abbreviations: abbreviations,
        author-substitute: if should-substitute { substitute } else { none },
        author-substitute-rule: substitute-rule,
        author-substitute-count: matching-count,
        substitute-vars: substitute-vars,
      ),
      rendered-number: render-citation-number(
        e.entry,
        style,
        cite-number: e.order,
      ),
      label: label("citeproc-ref-" + e.key),
    ))

    // Update previous names for next iteration
    prev-names = current-names
    prev-names-list = current-names-list
  }

  result
}
