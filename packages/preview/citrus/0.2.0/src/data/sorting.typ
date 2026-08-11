// citrus - Sorting Module
//
// Extracts sort keys from CSL <sort> element and sorts entries.

#import "variables.typ": NAME-VARS, get-variable
#import "../core/constants.typ": RENDER-CONTEXT
#import "../interpreter/mod.typ": create-context
#import "../interpreter/stack.typ": interpret-children-stack
#import "../output/helpers.typ": content-to-string, find-first-names-node

// Module-level regex patterns (avoid recompilation)
#let _re-whitespace = regex("\\s+")
#let _re-leading-quotes = regex("^['\u{2019}]+")
#let _re-leading-non-digits = regex("^[^0-9]+")
#let _re-trailing-non-digits = regex("[^0-9]+$")
#let _re-date-format = regex("^\\d{4}([-/]\\d{1,2})?([-/]\\d{1,2})?$")
#let _re-non-digits = regex("[^0-9]+")
#let _re-sort-punct = regex("[,.;:!?]")

// Helper: get initials for a given name string
#let _get-initials(given) = {
  if given == none or given == "" { return "" }
  let parts = given.split(_re-whitespace)
  parts
    .filter(p => p.len() > 0)
    .map(p => {
      let clusters = p.clusters()
      if clusters.len() > 0 { clusters.at(0) + "." } else { "" }
    })
    .join(" ")
}

// Normalize name parts for sort comparison (strip bracketed chars, leading quotes)
#let _normalize-name-sort-part(part) = {
  if part == none or type(part) != str { return "" }
  part.replace("[", "").replace("]", "").replace(_re-leading-quotes, "")
}

// Normalize date-like strings for lexicographic sorting
#let _normalize-date-sort-key(text) = {
  if type(text) != str { return text }
  let stripped = text
    .trim()
    .replace(_re-leading-non-digits, "")
    .replace(_re-trailing-non-digits, "")
  if stripped.match(_re-date-format) == none {
    return text
  }
  let parts = stripped.split(_re-non-digits)
  let year = parts.at(0, default: "")
  let month = parts.at(1, default: "0")
  let day = parts.at(2, default: "0")
  if month.len() == 1 { month = "0" + month }
  if day.len() == 1 { day = "0" + day }
  year + "-" + month + "-" + day
}

// Remove quote characters from sort keys
#let _strip-sort-quotes(text) = {
  if type(text) != str { return text }
  text
    .replace("\"", "")
    .replace("\u{201C}", "")
    .replace("\u{201D}", "")
    .replace(_re-sort-punct, "")
}

// =============================================================================
// Sort Key Extraction
// =============================================================================

/// Extract a single sort key value from an entry
///
/// - key-spec: Sort key specification from CSL (variable, macro, sort order)
/// - entry: Entry from citegeist
/// - style: Parsed CSL style
/// Returns: (order, value) tuple
#let extract-sort-key(key-spec, entry, style, citation-context: false) = {
  let ctx = create-context(style, entry)
  let order = key-spec.at("sort", default: "ascending")

  // CSL spec: names-min/use-first/use-last override et-al settings for sort keys
  // Pass these to the context for names rendering within macros
  let names-min = key-spec.at("names-min", default: none)
  let names-use-first = key-spec.at("names-use-first", default: none)
  let names-use-last = key-spec.at("names-use-last", default: none)

  // Add sort key name settings to context (they override et-al settings)
  let ctx = (
    ..ctx,
    sort-names-min: names-min,
    sort-names-use-first: names-use-first,
    sort-names-use-last: names-use-last,
  )

  if citation-context {
    let citation = style.citation
    ctx = (
      ..ctx,
      render-context: RENDER-CONTEXT.citation,
      citation-et-al-min: citation.at("et-al-min", default: none),
      citation-et-al-use-first: citation.at("et-al-use-first", default: none),
      citation-et-al-use-last: citation.at("et-al-use-last", default: none),
      citation-and: citation.at("and", default: none),
      citation-name-delimiter: citation.at("name-delimiter", default: none),
      citation-delimiter-precedes-et-al: citation.at(
        "delimiter-precedes-et-al",
        default: none,
      ),
      citation-delimiter-precedes-last: citation.at(
        "delimiter-precedes-last",
        default: none,
      ),
    )
  } else {
    let bib = style.at("bibliography", default: (:))
    if type(bib) == dictionary {
      ctx = (
        ..ctx,
        citation-et-al-min: bib.at("et-al-min", default: none),
        citation-et-al-use-first: bib.at("et-al-use-first", default: none),
        citation-et-al-use-last: bib.at("et-al-use-last", default: none),
      )
    }
  }

  let name-sort-key = (var-name, initialize-with: none, form: none) => {
    let parsed-names = ctx.at("parsed-names", default: (:))
    let names-list = parsed-names.at(var-name, default: ())
    if names-list.len() > 0 {
      let sort-min = ctx.at("sort-names-min", default: none)
      let sort-use-first = ctx.at("sort-names-use-first", default: none)
      let sort-use-last = ctx.at("sort-names-use-last", default: none)
      let et-al-min = ctx.at("citation-et-al-min", default: none)
      let et-al-use-first = ctx.at("citation-et-al-use-first", default: none)
      let et-al-use-last = ctx.at("citation-et-al-use-last", default: none)
      let min = if sort-min != none { sort-min } else { et-al-min }
      let use-first = if sort-use-first != none {
        sort-use-first
      } else { et-al-use-first }
      let use-last = if sort-use-last != none { sort-use-last } else {
        et-al-use-last
      }

      if (
        min != none
          and use-first != none
          and names-list.len() >= min
          and use-first < names-list.len()
      ) {
        let truncated = names-list.slice(0, use-first)
        if use-last == true and names-list.len() > use-first {
          truncated.push(names-list.last())
        }
        names-list = truncated
      }

      // CSL spec: sort key is constructed from name parts
      // For literal names: use literal value
      // For structured names: "family given" for each name, joined by space
      let use-initials = initialize-with != none
      let demote = ctx.style.demote-non-dropping-particle
      names-list
        .map(name => {
          if name.at("literal", default: "") != "" {
            _normalize-name-sort-part(name.literal)
          } else {
            let family = name.at("family", default: "")
            let given = name.at("given", default: "")
            let prefix = name.at("prefix", default: "") // non-dropping
            let dropping-prefix = name.at(
              "dropping-prefix",
              default: "",
            ) // dropping
            let suffix = name.at("suffix", default: "")
            if form == "short" {
              given = ""
            } else if use-initials {
              given = _get-initials(given)
            }
            family = _normalize-name-sort-part(family)
            given = _normalize-name-sort-part(given)
            prefix = _normalize-name-sort-part(prefix)
            dropping-prefix = _normalize-name-sort-part(dropping-prefix)
            suffix = _normalize-name-sort-part(suffix)

            let demote-prefix = (
              demote in ("display-and-sort", "sort-only")
            )
            let family-part = family
            if prefix != "" and not demote-prefix {
              if prefix.ends-with("'") or prefix.ends-with("-") {
                family-part = prefix + family
              } else {
                family-part = prefix + " " + family
              }
            }

            let parts = ()
            if family-part != "" { parts.push(family-part) }
            if given != "" { parts.push(given) }
            let particles = ()
            if dropping-prefix != "" { particles.push(dropping-prefix) }
            if prefix != "" and demote-prefix { particles.push(prefix) }
            if particles.len() > 0 { parts.push(particles.join(" ")) }
            if suffix != "" { parts.push(suffix) }
            parts.filter(p => p != "").join(" ")
          }
        })
        .join(" ")
    } else { "" }
  }

  let value = if key-spec.at("macro", default: none) != none {
    // Render macro and use result as sort key
    let macro-name = key-spec.macro
    let macro-def = style.macros.at(macro-name, default: none)
    if macro-def != none {
      // CSL spec: for macros, compare output of the first cs:names element
      let names-node = find-first-names-node(macro-def, macros: style.macros)
      if names-node != none {
        let vars = names-node
          .at("attrs", default: (:))
          .at("variable", default: "")
        let var-list = vars.split(" ")
        let name-node = names-node
          .at("children", default: ())
          .find(c => (
            type(c) == dictionary and c.at("tag", default: "") == "name"
          ))
        let init-with = if name-node != none {
          name-node
            .at("attrs", default: (:))
            .at("initialize-with", default: none)
        } else { none }
        let name-form = if name-node != none {
          name-node.at("attrs", default: (:)).at("form", default: none)
        } else {
          names-node.at("attrs", default: (:)).at("form", default: none)
        }
        let macro-name = key-spec.at("macro", default: "")
        if name-form == "count" or macro-name.ends-with("count") {
          let parsed = ctx.at("parsed-names", default: (:))
          let count = 0
          for v in var-list {
            let names-list = parsed.at(v, default: ())
            if names-list.len() > 0 {
              count = names-list.len()
              break
            }
          }
          if count == 0 {
            let substitute = names-node
              .at("children", default: ())
              .find(c => (
                type(c) == dictionary
                  and c.at("tag", default: "") == "substitute"
              ))
            if substitute != none {
              let sub-names = substitute
                .at("children", default: ())
                .find(c => (
                  type(c) == dictionary and c.at("tag", default: "") == "names"
                ))
              if sub-names != none {
                let sub-vars = sub-names
                  .at("attrs", default: (:))
                  .at("variable", default: "")
                  .split(" ")
                for v in sub-vars {
                  let names-list = parsed.at(v, default: ())
                  if names-list.len() > 0 {
                    count = names-list.len()
                    break
                  }
                }
              }
            }
          }
          if count != 0 {
            return (order: order, value: str(count))
          }
        }
        let key = ""
        for v in var-list {
          if key == "" {
            key = name-sort-key(v, initialize-with: init-with, form: name-form)
          }
        }
        if key == "" {
          let substitute = names-node
            .at("children", default: ())
            .find(c => (
              type(c) == dictionary and c.at("tag", default: "") == "substitute"
            ))
          if substitute != none {
            let sub-names = substitute
              .at("children", default: ())
              .find(c => (
                type(c) == dictionary and c.at("tag", default: "") == "names"
              ))
            if sub-names != none {
              let sub-vars = sub-names
                .at("attrs", default: (:))
                .at("variable", default: "")
                .split(" ")
              for v in sub-vars {
                if key == "" {
                  key = name-sort-key(
                    v,
                    initialize-with: init-with,
                    form: name-form,
                  )
                }
              }
            }
          }
        }
        if key != "" {
          key
        } else {
          let rendered = interpret-children-stack((names-node,), ctx)
          let rendered-key = _normalize-date-sort-key(
            content-to-string(rendered),
          )
          if rendered-key != "" {
            rendered-key
          } else {
            let full-rendered = interpret-children-stack(
              macro-def.children,
              ctx,
            )
            _normalize-date-sort-key(content-to-string(full-rendered))
          }
        }
      } else {
        let rendered = interpret-children-stack(macro-def.children, ctx)
        // Convert to string for sorting
        _normalize-date-sort-key(content-to-string(rendered))
      }
    } else { "" }
  } else if key-spec.at("variable", default: "") != "" {
    let var-name = key-spec.variable
    // Special handling for name variables: construct sort key from parsed names
    if var-name in NAME-VARS {
      name-sort-key(var-name)
    } else if (
      var-name in ("issued", "accessed", "original-date", "event-date")
    ) {
      // Date variables need special handling for proper numeric sorting
      // Construct a sortable date string with year offset for proper ordering
      let fields = ctx.fields

      // Helper to build sortable date string
      let build-sortable-date(year-str, month-str, day-str) = {
        if year-str == "" { return "" }
        let month = if month-str == "" { "01" } else { month-str }
        let day = if day-str == "" { "01" } else { day-str }

        // Pad month and day to 2 digits
        let month-padded = if month.len() == 1 { "0" + month } else { month }
        let day-padded = if day.len() == 1 { "0" + day } else { day }

        // Convert year to sortable format (handle negative years)
        // Offset by large number to ensure all values are positive
        // Use 100000000 so that even very old dates (e.g., -5000 BC) are positive
        // Pad to fixed length (9 digits) for proper string comparison
        let year-int = int(year-str)
        let year-offset = 100000000 + year-int
        // Pad to 9 digits: e.g., 99999900 for -100, 100002024 for 2024
        let year-str-padded = str(year-offset)
        // Ensure 9 digit length by padding with leading zeros if needed
        let year-sortable = if year-str-padded.len() < 9 {
          "0" * (9 - year-str-padded.len()) + year-str-padded
        } else {
          year-str-padded
        }

        year-sortable + "-" + month-padded + "-" + day-padded
      }

      // Value for missing dates - use special marker that will be handled
      // by sort-entries to always sort last regardless of direction
      // The "~" prefix ensures it sorts after normal values in ascending order
      // and sort-entries will handle descending by not inverting this marker
      let missing-date-value = "~missing~"

      if var-name == "issued" {
        let year-str = fields.at("year", default: "")
        if year-str != "" {
          // Build start date
          let start-date = build-sortable-date(
            year-str,
            fields.at("month", default: ""),
            fields.at("day", default: ""),
          )
          // Check for date range (end-year)
          let end-year-str = fields.at("end-year", default: "")
          if end-year-str != "" {
            // Combine start and end dates for range sorting
            let end-date = build-sortable-date(
              end-year-str,
              fields.at("end-month", default: ""),
              fields.at("end-day", default: ""),
            )
            start-date + "|" + end-date
          } else {
            start-date
          }
        } else {
          // Try 'date' field as fallback
          let date-str = fields.at("date", default: "")
          if date-str != "" {
            let parts = date-str.split("-")
            let year = if parts.len() >= 1 { parts.at(0) } else { "" }
            let month = if parts.len() >= 2 { parts.at(1) } else { "" }
            let day = if parts.len() >= 3 { parts.at(2) } else { "" }
            build-sortable-date(year, month, day)
          } else {
            // No date - sort at end
            missing-date-value
          }
        }
      } else if var-name == "accessed" {
        let accessed-year = fields.at("accessed-year", default: "")
        if accessed-year != "" {
          build-sortable-date(
            accessed-year,
            fields.at("accessed-month", default: ""),
            fields.at("accessed-day", default: ""),
          )
        } else {
          missing-date-value
        }
      } else if var-name == "original-date" {
        let origdate = fields.at("origdate", default: "")
        if origdate != "" {
          let parts = origdate.split("-")
          let year = if parts.len() >= 1 { parts.at(0) } else { "" }
          let month = if parts.len() >= 2 { parts.at(1) } else { "" }
          let day = if parts.len() >= 3 { parts.at(2) } else { "" }
          build-sortable-date(year, month, day)
        } else {
          missing-date-value
        }
      } else {
        // event-date
        let eventdate = fields.at("eventdate", default: "")
        if eventdate != "" {
          let parts = eventdate.split("-")
          let year = if parts.len() >= 1 { parts.at(0) } else { "" }
          let month = if parts.len() >= 2 { parts.at(1) } else { "" }
          let day = if parts.len() >= 3 { parts.at(2) } else { "" }
          build-sortable-date(year, month, day)
        } else {
          missing-date-value
        }
      }
    } else {
      // Get regular variable value directly
      let raw = get-variable(ctx, var-name)
      if var-name == "status" and type(raw) == str and raw == "" {
        "~missing~"
      } else {
        raw
      }
    }
  } else {
    ""
  }

  // Normalize for case-insensitive sorting
  let normalized = if type(value) == str {
    lower(_strip-sort-quotes(value))
  } else { "" }

  (order: order, value: normalized)
}

/// Extract all sort keys for an entry
///
/// - entry: Entry from citegeist
/// - sort-spec: Array of sort key specifications from CSL
/// - style: Parsed CSL style
/// Returns: Array of (order, value) tuples
#let extract-sort-keys(entry, sort-spec, style, citation-context: false) = {
  if sort-spec == none or sort-spec.len() == 0 {
    return ()
  }

  sort-spec.map(key-spec => extract-sort-key(
    key-spec,
    entry,
    style,
    citation-context: citation-context,
  ))
}

// =============================================================================
// Entry Sorting
// =============================================================================

/// Compare two entries by their sort keys
///
/// - a: First entry IR (with sort-keys)
/// - b: Second entry IR (with sort-keys)
/// Returns: -1, 0, or 1
#let compare-entries(a, b) = {
  let keys-a = a.sort-keys
  let keys-b = b.sort-keys

  let len = calc.min(keys-a.len(), keys-b.len())

  for i in range(len) {
    let ka = keys-a.at(i)
    let kb = keys-b.at(i)

    let va = ka.value
    let vb = kb.value

    if va != vb {
      // Missing values always sort last regardless of direction
      if va.starts-with("~missing") { return 1 }
      if vb.starts-with("~missing") { return -1 }

      let cmp = if va < vb { -1 } else { 1 }
      // Reverse for descending order
      if ka.order == "descending" { return -cmp }
      return cmp
    }
  }

  0
}

/// Invert a string for descending sort (complement each character)
///
/// For proper descending sort with string comparison, we need to invert
/// the string so that "larger" values become "smaller" in the inverted form.
#let invert-for-descending(s) = {
  if s == "" { return "" }
  // For each character, compute its "complement" to reverse sort order
  // We use a simple approach: prefix with "~" and negate digits
  // Map: 0->9, 1->8, 2->7, 3->6, 4->5, 5->4, 6->3, 7->2, 8->1, 9->0
  // For letters: a->z, b->y, etc.
  s
    .codepoints()
    .map(c => {
      let code = c.to-unicode()
      if code >= 0x30 and code <= 0x39 {
        // Digit: 0-9 -> 9-0
        str.from-unicode(0x39 - (code - 0x30))
      } else if code >= 0x61 and code <= 0x7a {
        // Lowercase: a-z -> z-a
        str.from-unicode(0x7a - (code - 0x61))
      } else if code >= 0x41 and code <= 0x5a {
        // Uppercase: A-Z -> Z-A
        str.from-unicode(0x5a - (code - 0x41))
      } else {
        // Keep other characters (like -)
        c
      }
    })
    .join()
}

/// Sort entries by extracted sort keys
///
/// - entries: Array of entry IRs with sort-keys populated
/// Returns: Sorted array of entry IRs
#let _merge-sorted(left, right) = {
  let result = ()
  let i = 0
  let j = 0

  while i < left.len() or j < right.len() {
    if i >= left.len() {
      result.push(right.at(j))
      j += 1
    } else if j >= right.len() {
      result.push(left.at(i))
      i += 1
    } else {
      let cmp = compare-entries(left.at(i), right.at(j))
      if cmp <= 0 {
        result.push(left.at(i))
        i += 1
      } else {
        result.push(right.at(j))
        j += 1
      }
    }
  }

  result
}

#let sort-entries(entries) = {
  if entries.len() <= 1 { return entries }

  let mid = calc.floor(entries.len() / 2)
  let left = sort-entries(entries.slice(0, mid))
  let right = sort-entries(entries.slice(mid))
  _merge-sorted(left, right)
}

/// Sort entries for bibliography output
///
/// For numeric styles: sort by citation order
/// For author-date styles: sort by CSL <sort> element
///
/// - entries: Array of entry IRs
/// - style: Parsed CSL style
/// - by-order: If true, sort by citation order (for numeric styles)
/// Returns: Sorted array of entry IRs
#let sort-bibliography-entries(entries, style, by-order: false) = {
  if by-order {
    // Sort by citation order (numeric styles)
    entries.sorted(key: e => e.order)
  } else {
    // Sort by CSL sort keys (with null-safety for citation-only styles)
    let bib = style.at("bibliography", default: none)
    let sort-spec = if bib != none { bib.at("sort", default: ()) } else { () }

    if sort-spec.len() == 0 {
      // No sort specified, keep original order
      return entries
    }

    // Extract sort keys for each entry
    let with-keys = entries.map(e => {
      let keys = extract-sort-keys(e.entry, sort-spec, style)
      (..e, sort-keys: keys)
    })

    sort-entries(with-keys)
  }
}
