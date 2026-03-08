// citrus - Global state management
//
// Manages bibliography data, CSL style, and citation tracking.
// Uses metadata + query pattern for citation collection.

#import "constants.typ": POSITION

// =============================================================================
// Label Encoding/Decoding
// =============================================================================
// Uses a safe encoding scheme that handles any characters in keys/locators.
// Format: "citeproc:" + base64-like encoding of JSON data
// This avoids issues with separator characters appearing in user data.

/// Encode citation data into a safe label string
///
/// - key: Citation key
/// - locator: Optional locator
/// - form: Optional form
/// Returns: Encoded string safe for use as a label
#let _encode-cite-label(key, locator, form) = {
  // Use repr() for safe serialization, join with newlines (safe in labels)
  // Format: "citeproc\n{key}\n{repr(locator)}\n{repr(form)}"
  "citeproc\n" + key + "\n" + repr(locator) + "\n" + repr(form)
}

/// Decode citation data from a label string
///
/// - label-str: The label string to decode
/// Returns: (key: str, locator: any, form: any) or none if invalid
#let _decode-cite-label(label-str) = {
  if not label-str.starts-with("citeproc\n") { return none }

  let parts = label-str.split("\n")
  if parts.len() < 4 { return none }

  let key = parts.at(1)
  let locator-repr = parts.at(2, default: "none")
  let form-repr = parts.at(3, default: "none")

  // Parse locator back from repr
  let locator = if locator-repr == "none" {
    none
  } else if locator-repr.starts-with("\"") and locator-repr.ends-with("\"") {
    locator-repr.slice(1, -1)
  } else {
    locator-repr
  }

  // Parse form back from repr
  let form = if form-repr == "none" {
    none
  } else if form-repr.starts-with("\"") and form-repr.ends-with("\"") {
    form-repr.slice(1, -1)
  } else {
    form-repr
  }

  (key: key, locator: locator, form: form)
}

// =============================================================================
// Core State Variables
// =============================================================================

/// Bibliography data (key -> entry)
#let _bib-data = state("citeproc-bib-data", (:))

/// Parsed CSL style
#let _csl-style = state("citeproc-csl-style", none)

/// Display configuration
#let _config = state("citeproc-config", (
  show-url: true,
  show-doi: true,
  show-accessed: true,
))

/// Abbreviations data (jurisdiction -> variable -> value -> abbreviated)
/// Structure: { "default": { "title": { "Full Title": "Abbr" }, ... }, ... }
#let _abbreviations = state("citeproc-abbreviations", (:))

/// Global citation counter for O(1) lookup in precomputed array
/// Each cite-marker increments this; show rule uses it to index pre-rendered citations
#let _cite-global-idx = counter("citeproc-cite-global-idx")

// =============================================================================
// Citation Tracking (metadata + query pattern)
// =============================================================================

/// Place a citation marker in the document
///
/// This creates an invisible metadata element that can be queried later
/// to determine citation order and positions. Also steps a global counter
/// for O(1) citation lookup in the pre-rendered array.
///
/// Design:
/// - Global counter (_cite-global-idx) provides O(1) index into pre-rendered citations
/// - Fixed metadata value "citeproc-cite" enables efficient metadata.where() query
/// - Safe label encoding handles any characters in keys/locators
///
/// - key: Citation key
/// - locator: Optional locator (page, chapter, etc.)
/// - form: Optional citation form (prose, author, year, etc.)
/// Returns: Content (invisible metadata)
#let cite-marker(key, locator: none, form: none) = {
  // Step global counter FIRST for consistent indexing
  _cite-global-idx.step()
  // Safe encoding that handles any characters in key/locator/form
  let encoded = _encode-cite-label(key, locator, form)
  let lbl = label(encoded)
  // Fixed value for efficient metadata.where() query
  [#metadata("citeproc-cite")#lbl]
}

/// Collect all citations from the document
///
/// Must be called within a `context` block.
/// Returns a dictionary with:
/// - order: key -> first occurrence order (1-based)
/// - positions: positions-key -> array of position info
/// - by-location: array of (key, occurrence) in document order
/// - count: total unique citations
/// - first-note-numbers: key -> note number of first occurrence (for note styles)
#let collect-citations() = {
  // Efficient query using fixed metadata value
  let cites = query(metadata.where(value: "citeproc-cite"))

  let result = (
    order: (:),
    positions: (:),
    by-location: (),
    count: 0,
    first-note-numbers: (:),
  )

  let n = 0
  let note-number = 0 // Track note numbers (each citation in note style = one footnote)
  let prev-key = none

  for c in cites {
    // Decode label using safe encoding
    let label-str = str(c.label)
    let decoded = _decode-cite-label(label-str)
    if decoded == none { continue }

    let key = decoded.key
    let locator = decoded.locator
    let form = decoded.form

    // Positions key for O(1) lookup (uses repr for consistency)
    let positions-key = key + "\n" + repr(locator)

    note-number += 1

    // Track first occurrence order (by key, not positions-key)
    if key not in result.order {
      n += 1
      result.order.insert(key, n)
      result.first-note-numbers.insert(key, note-number)
    }

    // Initialize positions array if needed
    if positions-key not in result.positions {
      result.positions.insert(positions-key, ())
    }

    // Track each occurrence's position
    let is-first = result.positions.at(positions-key).len() == 0
    let is-first-of-key = result.order.at(key) == n and is-first

    // Determine position type
    let position = if is-first-of-key {
      POSITION.first
    } else if prev-key == key {
      // Same key as previous citation
      if locator != none { POSITION.ibid-with-locator } else { POSITION.ibid }
    } else {
      POSITION.subsequent
    }

    // Use per-positions-key occurrence (1-based)
    let occurrence = result.positions.at(positions-key).len() + 1

    result
      .positions
      .at(positions-key)
      .push((
        occurrence: occurrence,
        position: position,
        key: key,
        locator: locator,
        form: form,
        note-number: note-number,
      ))

    result.by-location.push((
      key: key,
      positions-key: positions-key,
      occurrence: occurrence,
      locator: locator,
      form: form,
    ))
    prev-key = key
  }

  result.count = n
  result
}

// =============================================================================
// Entry IR (Intermediate Representation)
// =============================================================================

/// Create an enriched entry IR with computed fields
///
/// - key: Citation key
/// - entry: Raw entry from citegeist
/// - order: Citation order number (for numeric styles)
/// - style: Parsed CSL style
/// Returns: Enriched entry IR
#let create-entry-ir(key, entry, order, style) = {
  (
    // Original data
    key: key,
    entry: entry,
    order: order,
    // Will be populated by sorting/disambiguation
    sort-keys: (),
    disambig: (
      year-suffix: "",
      names-expanded: 0,
      add-givenname: false,
    ),
    // Fragments for disambiguation comparison (populated lazily)
    fragments: (:),
  )
}

/// Get the first author's family name (for grouping)
///
/// - entry: Entry from citegeist
/// Returns: First author family name or empty string
#let get-first-author-family(entry) = {
  let names = entry.at("parsed_names", default: (:)).at("author", default: ())
  if names.len() == 0 {
    names = entry.at("parsed_names", default: (:)).at("editor", default: ())
  }
  if names.len() > 0 {
    let first = names.first()
    let prefix = first.at("prefix", default: "")
    let family = first.at("family", default: "")
    if prefix != "" { prefix + " " + family } else { family }
  } else {
    ""
  }
}

/// Get the year from an entry
///
/// - entry: Entry from citegeist
/// Returns: Year string or empty string
#let get-entry-year(entry) = {
  let fields = entry.at("fields", default: (:))
  str(fields.at("year", default: fields.at("date", default: "")))
}
