// citrus - CSL-JSON Support
//
// Handles direct CSL-JSON input as an alternative to BibTeX.
// CSL-JSON properties map directly to CSL variables, avoiding translation losses.

// =============================================================================
// CSL-JSON State
// =============================================================================

/// CSL-JSON entries state (key -> entry)
/// Stores converted CSL-JSON entries for lookup
#let _csl-json-data = state("citeproc-csl-json-data", (:))

/// Flag indicating CSL-JSON mode is active
#let _csl-json-mode = state("citeproc-csl-json-mode", false)

// =============================================================================
// CSL-JSON Conversion
// =============================================================================

/// Convert CSL-JSON date to BibTeX-style fields
///
/// CSL-JSON: { "date-parts": [[2023, 1, 15]] }
/// BibTeX-style: { year: "2023", month: "1", day: "15" }
#let convert-csl-date(csl-date) = {
  if csl-date == none { return (:) }
  if type(csl-date) != dictionary { return (:) }

  let parts = csl-date.at("date-parts", default: ())
  if parts.len() == 0 { return (:) }

  // First date-parts array is the start date
  let start = parts.first()
  let result = (:)

  if start.len() >= 1 {
    result.insert("year", str(start.at(0)))
  }
  if start.len() >= 2 {
    result.insert("month", str(start.at(1)))
  }
  if start.len() >= 3 {
    result.insert("day", str(start.at(2)))
  }

  // Handle date ranges (second element)
  if parts.len() >= 2 {
    let end = parts.at(1)
    if end.len() >= 1 {
      result.insert("end-year", str(end.at(0)))
    }
  }

  // Handle literal dates
  if "literal" in csl-date {
    result.insert("literal", csl-date.literal)
  }

  // Handle season
  if "season" in csl-date {
    result.insert("season", str(csl-date.season))
  }

  result
}

/// Convert CSL type to BibTeX-like entry_type
///
/// This maps CSL types to approximate BibTeX equivalents for
/// entry_type checks in conditions.typ
#let convert-csl-type(csl-type) = {
  let type-map = (
    "article": "article",
    "article-journal": "article",
    "article-magazine": "article",
    "article-newspaper": "article",
    "bill": "misc",
    "book": "book",
    "broadcast": "misc",
    "chapter": "incollection",
    "classic": "book",
    "collection": "book",
    "dataset": "misc",
    "document": "misc",
    "entry": "misc",
    "entry-dictionary": "misc",
    "entry-encyclopedia": "misc",
    "event": "misc",
    "figure": "misc",
    "graphic": "misc",
    "hearing": "misc",
    "interview": "misc",
    "legal_case": "misc",
    "legislation": "misc",
    "manuscript": "unpublished",
    "map": "misc",
    "motion_picture": "misc",
    "musical_score": "misc",
    "pamphlet": "booklet",
    "paper-conference": "inproceedings",
    "patent": "patent",
    "performance": "misc",
    "periodical": "misc",
    "personal_communication": "misc",
    "post": "misc",
    "post-weblog": "misc",
    "regulation": "misc",
    "report": "techreport",
    "review": "article",
    "review-book": "article",
    "software": "misc",
    "song": "misc",
    "speech": "misc",
    "standard": "misc",
    "thesis": "phdthesis",
    "treaty": "misc",
    "webpage": "misc",
  )
  type-map.at(csl-type, default: "misc")
}

/// Convert CSL-JSON entry to internal format
///
/// Transforms CSL-JSON structure to match what citegeist produces,
/// allowing reuse of existing interpretation logic.
///
/// - csl-entry: CSL-JSON item object
/// Returns: Entry in internal format (entry_type, fields, parsed_names)
#let convert-csl-json-entry(csl-entry) = {
  let id = csl-entry.at("id", default: "")
  let csl-type = csl-entry.at("type", default: "document")

  // Build fields dictionary from CSL-JSON properties
  let fields = (:)

  // Direct text variables
  let text-vars = (
    "title",
    "container-title",
    "collection-title",
    "publisher",
    "publisher-place",
    "volume",
    "issue",
    "page",
    "edition",
    "abstract",
    "note",
    "DOI",
    "URL",
    "ISBN",
    "ISSN",
    "language",
    "archive",
    "archive_location",
    "call-number",
    "event-title",
    "event-place",
    "genre",
    "medium",
    "original-title",
    "original-publisher",
    "original-publisher-place",
    "references",
    "reviewed-title",
    "scale",
    "section",
    "source",
    "status",
    "title-short",
    "version",
    // CSL-M variables
    "authority",
    "jurisdiction",
    "committee",
    "document-name",
    "hereinafter",
    "supplement",
    "division",
    "volume-title",
    "publication-number",
  )

  for var in text-vars {
    if var in csl-entry {
      let val = csl-entry.at(var)
      if val != none {
        // Handle different value types
        let str-val = if type(val) == str {
          val
        } else if type(val) == int or type(val) == float {
          str(val)
        } else if type(val) == array {
          // Join array elements (some fields can have multiple values)
          val.map(v => if type(v) == str { v } else { repr(v) }).join("; ")
        } else {
          repr(val)
        }
        fields.insert(var, str-val)
      }
    }
  }

  // Number variables (also store as strings for consistency)
  let number-vars = (
    "chapter-number",
    "citation-number",
    "collection-number",
    "first-reference-note-number",
    "number",
    "number-of-pages",
    "number-of-volumes",
    "part-number",
    "printing-number",
    "supplement-number",
    "version",
    "volume",
    "issue",
  )

  for var in number-vars {
    if var in csl-entry and var not in fields {
      let val = csl-entry.at(var)
      if val != none {
        // Handle different value types (some fields might have unexpected types)
        let str-val = if type(val) == str {
          val
        } else if type(val) == int or type(val) == float {
          str(val)
        } else if type(val) == array {
          val.map(v => if type(v) == str { v } else { str(v) }).join(", ")
        } else {
          repr(val)
        }
        fields.insert(var, str-val)
      }
    }
  }

  // Map CSL variable names to BibTeX-style field names for compatibility
  // container-title -> journal/booktitle (depending on type)
  if "container-title" in fields {
    if (
      csl-type
        in (
          "article",
          "article-journal",
          "article-magazine",
          "article-newspaper",
        )
    ) {
      fields.insert("journal", fields.at("container-title"))
    } else {
      fields.insert("booktitle", fields.at("container-title"))
    }
  }

  // publisher-place -> address
  if "publisher-place" in fields {
    fields.insert("address", fields.at("publisher-place"))
  }

  // page -> pages
  if "page" in fields {
    fields.insert("pages", fields.at("page"))
  }

  // issue -> number
  if "issue" in fields {
    fields.insert("number", fields.at("issue"))
  }

  // Handle dates
  let date-vars = (
    "issued",
    "accessed",
    "original-date",
    "event-date",
    "submitted",
  )
  for var in date-vars {
    if var in csl-entry {
      let date-fields = convert-csl-date(csl-entry.at(var))
      if var == "issued" {
        // issued -> year, month, day (primary date)
        for (k, v) in date-fields.pairs() {
          fields.insert(k, v)
        }
        // Also store as date string for biblatex compatibility
        if "year" in date-fields {
          let date-str = date-fields.year
          if "month" in date-fields {
            date-str += "-" + date-fields.month
            if "day" in date-fields {
              date-str += "-" + date-fields.day
            }
          }
          fields.insert("date", date-str)
        }
      } else if var == "accessed" {
        // accessed -> urldate
        if "year" in date-fields {
          let date-str = date-fields.year
          if "month" in date-fields {
            date-str += "-" + date-fields.month
            if "day" in date-fields {
              date-str += "-" + date-fields.day
            }
          }
          fields.insert("urldate", date-str)
        }
      } else if var == "original-date" {
        // original-date -> origdate
        if "year" in date-fields {
          let date-str = date-fields.year
          if "month" in date-fields {
            date-str += "-" + date-fields.month
          }
          fields.insert("origdate", date-str)
        }
      }
    }
  }

  // Store CSL type directly (for type matching in conditions)
  fields.insert("csl-type", csl-type)

  // Mark as from CSL-JSON source
  fields.insert("_source", "csl-json")

  // Build parsed_names from CSL-JSON name arrays
  // CSL-JSON names are already structured: [{family, given, suffix, ...}]
  let parsed-names = (:)

  let name-vars = (
    "author",
    "editor",
    "translator",
    "container-author",
    "collection-editor",
    "composer",
    "director",
    "illustrator",
    "interviewer",
    "original-author",
    "original-editor",
    "recipient",
    "reviewed-author",
  )

  for var in name-vars {
    if var in csl-entry {
      let names = csl-entry.at(var)
      if type(names) == array and names.len() > 0 {
        // Normalize name structure
        let normalized = names.map(n => {
          if type(n) == dictionary {
            (
              family: n.at("family", default: ""),
              given: n.at("given", default: ""),
              suffix: n.at("suffix", default: ""),
              prefix: n.at("non-dropping-particle", default: n.at(
                "dropping-particle",
                default: "",
              )),
              literal: n.at("literal", default: ""),
            )
          } else if type(n) == str {
            // Literal name string
            (family: n, given: "", suffix: "", prefix: "", literal: n)
          } else {
            (family: "", given: "", suffix: "", prefix: "", literal: "")
          }
        })
        parsed-names.insert(var, normalized)

        // Map container-author -> bookauthor for compatibility
        if var == "container-author" {
          parsed-names.insert("bookauthor", normalized)
        }
      }
    }
  }

  (
    entry_type: convert-csl-type(csl-type),
    fields: fields,
    parsed_names: parsed-names,
  )
}

/// Parse CSL-JSON content and return entries dictionary
///
/// - json-content: JSON string, bytes, or parsed array
/// Returns: Dictionary of key -> entry
#let parse-csl-json(json-content) = {
  let entries = if type(json-content) == str {
    // Parse JSON string using bytes conversion
    json(bytes(json-content))
  } else if type(json-content) == bytes {
    json(json-content)
  } else if type(json-content) == array {
    json-content
  } else {
    ()
  }

  let result = (:)
  for entry in entries {
    let id = entry.at("id", default: none)
    if id != none {
      result.insert(str(id), convert-csl-json-entry(entry))
    }
  }
  result
}

/// Generate minimal BibTeX stub for hidden bibliography
///
/// Creates minimal @misc entries with just keys and titles
/// to enable Typst's @key citation syntax.
///
/// - entries: Dictionary of key -> entry (after convert-csl-json-entry)
/// Returns: BibTeX string
#let generate-stub-bib(entries) = {
  let lines = ()
  for (key, entry) in entries.pairs() {
    let title = entry
      .at("fields", default: (:))
      .at("title", default: "Untitled")
    // Escape special characters in title
    let safe-title = title.replace("{", "\\{").replace("}", "\\}")
    lines.push("@misc{" + key + ",\n  title = {" + safe-title + "}\n}")
  }
  lines.join("\n\n")
}
