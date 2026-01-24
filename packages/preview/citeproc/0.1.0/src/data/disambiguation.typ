// citeproc-typst - Disambiguation Module
//
// Implements CSL disambiguation according to the specification.
// Disambiguation is applied in order:
// 1. disambiguate-add-givenname: Expand initials to full given names
// 2. disambiguate-add-names: Add more author names
// 3. disambiguate condition: Render with disambiguate="true"
// 4. disambiguate-add-year-suffix: Add a, b, c to years
//
// Key insight: Disambiguation is based on RENDERED citation form, not raw data.
// Two citations are ambiguous if they render identically.

#import "../core/state.typ": get-entry-year, get-first-author-family

// Module-level regex pattern
#let _whitespace-pattern = regex("\\s+")

// =============================================================================
// Year Suffix Computation
// =============================================================================

/// Compute year suffixes for entries that need disambiguation
///
/// Groups entries by (first-author, year) and assigns a, b, c, ... suffixes
/// to entries within the same group.
///
/// - entries: Array of entry IRs
/// - style: Parsed CSL style
/// Returns: Dictionary of key -> suffix (e.g., "smith2020" -> "a")
#let compute-year-suffixes(entries, style) = {
  // Check if style uses year-suffix disambiguation
  let citation = style.at("citation", default: none)
  if citation == none { return (:) }

  let use-year-suffix = citation.at(
    "disambiguate-add-year-suffix",
    default: false,
  )
  if not use-year-suffix { return (:) }

  // Group entries by (first-author-family, year)
  // Record original index to preserve bibliography order per CSL spec:
  // "The assignment of year-suffixes follows the order of the bibliographies entries"
  let groups = (:)
  for (idx, e) in entries.enumerate() {
    let entry = e.entry
    let author = get-first-author-family(entry)
    let year = get-entry-year(entry)
    let group-key = lower(author) + "|" + str(year)

    if group-key not in groups {
      groups.insert(group-key, ())
    }
    groups
      .at(group-key)
      .push((
        key: e.key,
        index: idx, // Position in bibliography (already sorted)
      ))
  }

  // Assign suffixes to groups with multiple entries
  let suffixes = (:)
  let suffix-chars = "abcdefghijklmnopqrstuvwxyz"

  for (group-key, items) in groups.pairs() {
    if items.len() > 1 {
      // Sort by bibliography order (index), not by title
      let sorted-items = items.sorted(key: it => it.index)

      for (i, item) in sorted-items.enumerate() {
        if i < suffix-chars.len() {
          suffixes.insert(item.key, suffix-chars.at(i))
        }
      }
    }
  }

  suffixes
}

// =============================================================================
// Name Disambiguation
// =============================================================================

/// Get all authors from an entry as a list of parsed names
///
/// - entry: Entry from citegeist
/// Returns: Array of name dicts with (family, given, literal)
#let get-all-authors(entry) = {
  let fields = entry.at("fields", default: (:))
  let author-field = fields.at("author", default: none)
  if author-field == none { return () }

  // Note: field name is parsed_names (underscore) from citegeist
  let parsed = entry.at("parsed_names", default: (:))
  parsed.at("author", default: ())
}

/// Get initials from a given name
///
/// - given: Full given name string (e.g., "John Michael")
/// Returns: Initials string (e.g., "J. M.")
#let get-initials(given) = {
  if given == none or given == "" { return "" }
  let parts = given.split(_whitespace-pattern)
  parts
    .filter(p => p.len() > 0)
    .map(p => {
      // Handle Unicode - use clusters for first character
      let clusters = p.clusters()
      if clusters.len() > 0 { clusters.at(0) + "." } else { "" }
    })
    .join(" ")
}

/// Build author short representation with given disambiguation level
///
/// - names: Array of parsed name dicts
/// - et-al-use-first: Number of names before et al.
/// - expand-names: Number of additional names to show beyond et-al-use-first
/// - givenname-level: 0 = none, 1 = initials, 2 = full given
/// Returns: String representation for comparison
#let build-author-key(
  names,
  et-al-use-first,
  expand-names: 0,
  givenname-level: 0,
) = {
  if names.len() == 0 { return "" }

  let show-count = calc.min(names.len(), et-al-use-first + expand-names)
  let parts = ()

  for i in range(show-count) {
    let name = names.at(i)
    let family = name.at("family", default: name.at("literal", default: ""))

    let given-part = if givenname-level == 0 {
      ""
    } else if givenname-level == 1 {
      get-initials(name.at("given", default: ""))
    } else {
      name.at("given", default: "")
    }

    if given-part != "" {
      parts.push(family + ", " + given-part)
    } else {
      parts.push(family)
    }
  }

  lower(parts.join("; "))
}

/// Compute name disambiguation levels for entries
///
/// Implements CSL givenname-disambiguation-rule:
/// - "all-names": Expand all ambiguous names in all cites
/// - "all-names-with-initials": Same but limit to initials (level 1)
/// - "primary-name": Only expand first name of each cite
/// - "primary-name-with-initials": Only first name, only initials
/// - "by-cite" (default): Only expand in ambiguous cites, stop when resolved
///
/// - entries: Array of entry IRs
/// - style: Parsed CSL style
/// Returns: Dictionary of key -> (names-expanded: int, givenname-level: int, needs-disambiguate: bool)
#let compute-name-disambiguation(entries, style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return (:) }

  let add-names = citation.at("disambiguate-add-names", default: false)
  let add-givenname = citation.at("disambiguate-add-givenname", default: false)
  let givenname-rule = citation.at(
    "givenname-disambiguation-rule",
    default: "by-cite",
  )

  if not add-names and not add-givenname { return (:) }

  let et-al-min = citation.at("et-al-min", default: none)
  let et-al-use-first = citation.at("et-al-use-first", default: none)
  // Handle none values (when not specified in citation element)
  if et-al-min == none { et-al-min = 4 }
  if et-al-use-first == none { et-al-use-first = 1 }

  // Convert to integers if needed
  if type(et-al-min) == str { et-al-min = int(et-al-min) }
  if type(et-al-use-first) == str { et-al-use-first = int(et-al-use-first) }

  // Determine max givenname level based on rule
  // Level 0 = none, 1 = initials, 2 = full given name
  let max-givenname-level = if givenname-rule.ends-with("-with-initials") {
    1
  } else { 2 }

  // Determine if we only target primary (first) name
  let primary-only = givenname-rule.starts-with("primary-name")

  // Build initial representations for all entries
  let disambig-state = (:)
  for e in entries {
    let authors = get-all-authors(e.entry)
    disambig-state.insert(e.key, (
      authors: authors,
      names-expanded: 0,
      givenname-level: 0,
      year: get-entry-year(e.entry),
      needs-disambiguate: false, // Method 3 flag
    ))
  }

  // Iteratively disambiguate
  // Strategy: Start with minimal representation, expand as needed
  let max-iterations = 10
  let iteration = 0

  while iteration < max-iterations {
    iteration += 1
    let made-change = false

    // Build current keys
    let keys = (:)
    for (entry-key, state) in disambig-state.pairs() {
      let author-key = build-author-key(
        state.authors,
        et-al-use-first,
        expand-names: state.names-expanded,
        givenname-level: state.givenname-level,
      )
      let full-key = author-key + "|" + str(state.year)

      if full-key not in keys {
        keys.insert(full-key, ())
      }
      keys.at(full-key).push(entry-key)
    }

    // Find collisions and try to resolve
    for (full-key, colliding-keys) in keys.pairs() {
      if colliding-keys.len() > 1 {
        // Try disambiguation strategies in order:
        // 1. Add givenname (initials first, then full - respecting rule limits)
        // 2. Add more names

        for entry-key in colliding-keys {
          let state = disambig-state.at(entry-key)
          let resolved = false

          // Try expanding givenname first (respecting max level from rule)
          if add-givenname and state.givenname-level < max-givenname-level {
            let new-level = state.givenname-level + 1
            let new-key = build-author-key(
              state.authors,
              et-al-use-first,
              expand-names: state.names-expanded,
              givenname-level: new-level,
            )

            // Check if this would resolve collision
            let would-resolve = true
            for other-key in colliding-keys {
              if other-key != entry-key {
                let other = disambig-state.at(other-key)
                let other-new-key = build-author-key(
                  other.authors,
                  et-al-use-first,
                  expand-names: other.names-expanded,
                  givenname-level: other.givenname-level,
                )
                if new-key == other-new-key {
                  would-resolve = false
                }
              }
            }

            // Only expand givenname if it would actually resolve the collision
            if would-resolve {
              disambig-state.insert(entry-key, (
                ..state,
                givenname-level: new-level,
              ))
              made-change = true
              resolved = true
            }
          }

          // Try adding more names (skip if primary-only rule)
          if not resolved and add-names and not primary-only {
            let max-names = state.authors.len()
            if state.names-expanded + et-al-use-first < max-names {
              disambig-state.insert(entry-key, (
                ..state,
                names-expanded: state.names-expanded + 1,
              ))
              made-change = true
            }
          }
        }
      }
    }

    if not made-change { break }
  }

  // Final pass: check for remaining collisions and mark for Method 3
  let final-keys = (:)
  for (entry-key, state) in disambig-state.pairs() {
    let author-key = build-author-key(
      state.authors,
      et-al-use-first,
      expand-names: state.names-expanded,
      givenname-level: state.givenname-level,
    )
    let full-key = author-key + "|" + str(state.year)

    if full-key not in final-keys {
      final-keys.insert(full-key, ())
    }
    final-keys.at(full-key).push(entry-key)
  }

  // Mark entries that still have collisions as needing Method 3
  for (full-key, colliding-keys) in final-keys.pairs() {
    if colliding-keys.len() > 1 {
      for entry-key in colliding-keys {
        let state = disambig-state.at(entry-key)
        disambig-state.insert(entry-key, (
          ..state,
          needs-disambiguate: true,
        ))
      }
    }
  }

  // Convert to result format
  let result = (:)
  for (entry-key, state) in disambig-state.pairs() {
    result.insert(entry-key, (
      names-expanded: state.names-expanded,
      givenname-level: state.givenname-level,
      needs-disambiguate: state.needs-disambiguate,
    ))
  }

  result
}

// =============================================================================
// Citation Key for Comparison
// =============================================================================

/// Build a citation key string for disambiguation comparison
///
/// This represents what the citation would render as (minus year-suffix).
/// Two entries with the same citation key are ambiguous.
///
/// - entry: Entry from citegeist
/// - state: Current disambiguation state for this entry
/// - style: Parsed CSL style
/// Returns: String key for comparison
#let build-citation-key(entry, state, style) = {
  let citation = style.at("citation", default: none)
  if citation == none { return "" }

  let et-al-min = citation.at("et-al-min", default: none)
  let et-al-use-first = citation.at("et-al-use-first", default: none)
  // Handle none values (when not specified in citation element)
  if et-al-min == none { et-al-min = 4 }
  if et-al-use-first == none { et-al-use-first = 1 }
  if type(et-al-min) == str { et-al-min = int(et-al-min) }
  if type(et-al-use-first) == str { et-al-use-first = int(et-al-use-first) }

  // Get authors
  let authors = get-all-authors(entry)
  if authors.len() == 0 { return "?" }

  // Apply names-expanded to et-al-use-first
  let effective-use-first = et-al-use-first + state.names-expanded

  // Build author key with current disambiguation state
  let author-key = build-author-key(
    authors,
    effective-use-first,
    expand-names: 0, // Already included in effective-use-first
    givenname-level: state.givenname-level,
  )

  // Add year
  let year = get-entry-year(entry)

  author-key + "|" + str(year)
}

/// Group entries by citation key
///
/// - entries: Array of entry IRs
/// - states: Dictionary of key -> disambiguation state
/// - style: Parsed CSL style
/// Returns: Dictionary of citation_key -> [entry_key, ...]
#let group-by-citation-key(entries, states, style) = {
  let groups = (:)

  for e in entries {
    let state = states.at(e.key)
    let citation-key = build-citation-key(e.entry, state, style)

    if citation-key not in groups {
      groups.insert(citation-key, ())
    }
    groups.at(citation-key).push(e.key)
  }

  groups
}

/// Get ambiguous groups (groups with more than one entry)
///
/// - groups: Dictionary of citation_key -> [entry_key, ...]
/// Returns: Array of (citation_key, [entry_key, ...]) where len > 1
#let get-ambiguous-groups(groups) = {
  groups.pairs().filter(((k, v)) => v.len() > 1)
}

// =============================================================================
// Disambiguation Helpers
// =============================================================================

/// Check if expanding givenname would help disambiguate an entry
///
/// Compares the entry's first author given name against other entries
/// in the same ambiguous group.
///
/// - key: The entry key to check
/// - entries: All entries
/// - ambiguous: Current ambiguous groups
/// Returns: true if expansion would help
#let _givenname-expansion-would-help(key, entries, ambiguous) = {
  let entry = entries.find(e => e.key == key)
  if entry == none { return false }

  let authors = entry
    .entry
    .at("parsed_names", default: (:))
    .at("author", default: ())

  if authors.len() == 0 { return false }

  // Find other entries in same ambiguous group
  for (group-key, group-keys) in ambiguous {
    if key in group-keys {
      for other-key in group-keys {
        if other-key != key {
          let other-entry = entries.find(e => e.key == other-key)
          if other-entry != none {
            let other-authors = other-entry
              .entry
              .at("parsed_names", default: (:))
              .at("author", default: ())
            // Check if first given name differs
            if other-authors.len() > 0 {
              let first-given = authors.first().at("given", default: "")
              let other-first-given = other-authors
                .first()
                .at("given", default: "")
              if first-given != other-first-given {
                return true
              }
            }
          }
        }
      }
    }
  }
  false
}

/// Try to expand names for an entry if possible
///
/// - key: The entry key
/// - state: Current disambiguation state
/// - entry-map: Map of key -> entry
/// - et-al-use-first: Number of names shown before et al
/// Returns: (can-expand, new-state)
#let _try-expand-names(key, state, entry-map, et-al-use-first) = {
  let e = entry-map.at(key)
  let authors = get-all-authors(e.entry)

  if state.names-expanded + et-al-use-first < authors.len() {
    (
      can-expand: true,
      new-state: (..state, names-expanded: state.names-expanded + 1),
    )
  } else {
    (can-expand: false, new-state: state)
  }
}

/// Assign year suffixes to ambiguous groups
///
/// - ambiguous: Array of (citation-key, entry-keys) for ambiguous groups
/// - entries: All entries (for ordering)
/// - states: Current states dict (will be mutated)
/// Returns: Updated states dict
#let _assign-year-suffixes(ambiguous, entries, states) = {
  let suffix-chars = "abcdefghijklmnopqrstuvwxyz"
  let new-states = states

  for (citation-key, entry-keys) in ambiguous {
    // Sort by bibliography order (entry position in entries array)
    let key-order = (:)
    for (i, e) in entries.enumerate() {
      if e.key in entry-keys {
        key-order.insert(e.key, i)
      }
    }

    let sorted-keys = entry-keys.sorted(key: k => key-order.at(k, default: 999))

    for (i, key) in sorted-keys.enumerate() {
      if i < suffix-chars.len() {
        let state = new-states.at(key)
        new-states.insert(key, (..state, year-suffix: suffix-chars.at(i)))
      }
    }
  }

  new-states
}

// =============================================================================
// Main Disambiguation Algorithm
// =============================================================================

/// Apply disambiguation to entry IRs
///
/// Implements CSL disambiguation in order:
/// 1. disambiguate-add-givenname: Expand given names (initials → full)
/// 2. disambiguate-add-names: Add more authors from et-al list
/// 3. disambiguate condition: Set disambiguate=true in context
/// 4. disambiguate-add-year-suffix: Add a, b, c to years
///
/// Key: Each method only applies to entries still ambiguous after previous methods.
///
/// - entries: Array of entry IRs (already sorted by bibliography order)
/// - style: Parsed CSL style
/// Returns: Array of entry IRs with disambig field populated
#let apply-disambiguation(entries, style) = {
  let citation = style.at("citation", default: none)
  if citation == none {
    // No citation element, return entries unchanged
    return entries.map(e => (
      ..e,
      disambig: (
        year-suffix: "",
        names-expanded: 0,
        givenname-level: 0,
        needs-disambiguate: false,
      ),
    ))
  }

  // Get disambiguation options
  let add-givenname = citation.at("disambiguate-add-givenname", default: false)
  let add-names = citation.at("disambiguate-add-names", default: false)
  let add-year-suffix = citation.at(
    "disambiguate-add-year-suffix",
    default: false,
  )
  let givenname-rule = citation.at(
    "givenname-disambiguation-rule",
    default: "by-cite",
  )

  // Determine max givenname level based on rule
  let max-givenname-level = if givenname-rule.ends-with("-with-initials") {
    1
  } else { 2 }
  let primary-only = givenname-rule.starts-with("primary-name")

  // Get et-al settings for names expansion limit
  let et-al-min = citation.at("et-al-min", default: none)
  if et-al-min == none { et-al-min = 4 }
  if type(et-al-min) == str { et-al-min = int(et-al-min) }

  // Initialize disambiguation state for each entry
  let states = (:)
  let entry-map = (:) // key -> entry for quick lookup

  for e in entries {
    states.insert(e.key, (
      givenname-level: 0,
      names-expanded: 0,
      needs-disambiguate: false,
      year-suffix: "",
    ))
    entry-map.insert(e.key, e)
  }

  // Initial grouping
  let groups = group-by-citation-key(entries, states, style)
  let ambiguous = get-ambiguous-groups(groups)

  // ==========================================================================
  // Method 1: disambiguate-add-givenname
  // ==========================================================================
  if add-givenname and ambiguous.len() > 0 {
    // Try expanding givenname for ambiguous entries
    for level in range(1, max-givenname-level + 1) {
      let ambiguous-keys = ambiguous.map(((k, v)) => v).flatten()

      // Check each ambiguous entry for potential givenname expansion
      for key in ambiguous-keys {
        let state = states.at(key)
        if state.givenname-level < level {
          // Only expand if it would actually help disambiguate
          if _givenname-expansion-would-help(key, entries, ambiguous) {
            states.insert(key, (..state, givenname-level: level))
          }
        }
      }

      // Re-group and check
      let new-groups = group-by-citation-key(entries, states, style)
      ambiguous = get-ambiguous-groups(new-groups)

      if ambiguous.len() == 0 { break }
    }
  }

  // ==========================================================================
  // Method 2: disambiguate-add-names
  // ==========================================================================
  if add-names and not primary-only and ambiguous.len() > 0 {
    // Get et-al-use-first setting
    let et-al-use-first = citation.at("et-al-use-first", default: none)
    if et-al-use-first == none { et-al-use-first = 1 }
    if type(et-al-use-first) == str { et-al-use-first = int(et-al-use-first) }

    // Try adding more names for still-ambiguous entries
    let max-iterations = 10
    let iteration = 0

    while ambiguous.len() > 0 and iteration < max-iterations {
      iteration += 1
      let ambiguous-keys = ambiguous.map(((k, v)) => v).flatten()

      // Try to expand names for each ambiguous entry
      let any-expanded = false
      for key in ambiguous-keys {
        let state = states.at(key)
        let result = _try-expand-names(key, state, entry-map, et-al-use-first)
        if result.can-expand {
          any-expanded = true
          states.insert(key, result.new-state)
        }
      }

      if not any-expanded { break }

      // Re-group and check
      let new-groups = group-by-citation-key(entries, states, style)
      ambiguous = get-ambiguous-groups(new-groups)
    }
  }

  // ==========================================================================
  // Method 3: disambiguate condition
  // ==========================================================================
  // Mark remaining ambiguous entries for the disambiguate condition
  if ambiguous.len() > 0 {
    let ambiguous-keys = ambiguous.map(((k, v)) => v).flatten()
    for key in ambiguous-keys {
      let state = states.at(key)
      states.insert(key, (
        ..state,
        needs-disambiguate: true,
      ))
    }
    // Note: We don't re-group here because we can't easily simulate
    // what the disambiguate condition would render. This is left to
    // the style author's judgment.
  }

  // ==========================================================================
  // Method 4: disambiguate-add-year-suffix
  // ==========================================================================
  if add-year-suffix and ambiguous.len() > 0 {
    states = _assign-year-suffixes(ambiguous, entries, states)
  }

  // ==========================================================================
  // Apply states to entries
  // ==========================================================================
  entries.map(e => (
    ..e,
    disambig: states.at(e.key),
  ))
}

/// Check if two entries have the same short author representation
///
/// - entry-a: First entry
/// - entry-b: Second entry
/// Returns: bool
#let same-author-short(entry-a, entry-b) = {
  let author-a = get-first-author-family(entry-a)
  let author-b = get-first-author-family(entry-b)
  lower(author-a) == lower(author-b)
}

/// Check if two entries have the same year
///
/// - entry-a: First entry
/// - entry-b: Second entry
/// Returns: bool
#let same-year(entry-a, entry-b) = {
  let year-a = get-entry-year(entry-a)
  let year-b = get-entry-year(entry-b)
  year-a == year-b
}
