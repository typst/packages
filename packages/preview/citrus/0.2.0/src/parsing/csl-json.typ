// citrus - CSL-JSON Support
//
// Handles direct CSL-JSON input as an alternative to BibTeX.
// CSL-JSON properties map directly to CSL variables, avoiding translation losses.

#import "../data/variables.typ": NAME-VARS

// =============================================================================
// Note Field Parsing (citeproc-js compatibility)
// =============================================================================
//
// citeproc-js parses the "note" field to extract embedded CSL variables.
// This allows Zotero's "Extra" field to contain structured data.
//
// Formats supported:
// 1. Line format: "variable-name: value" on separate lines
// 2. For names: "variable-name: Family || Given" (double pipe separator)
//
// Example note field:
//   reviewed-title: Some Title
//   genre: Peer commentary
//   reviewed-author: Smith || John

/// Regex pattern for note field variable lines
/// Matches: variable-name: value
#let _note-field-pattern = regex("^([a-z][a-z0-9-]*[a-z0-9]):\\s*(.+)$")

/// Parse embedded variables from note field
///
/// Extracts CSL variables embedded in the note field following citeproc-js format.
/// Variables that don't exist in the entry are extracted and added.
///
/// - note: Note field string
/// - existing-fields: Dictionary of existing fields (to avoid overwriting)
/// - existing-names: Dictionary of existing parsed names
/// Returns: (fields: dict, names: dict, cleaned-note: str)
#let parse-note-field-vars(note, existing-fields, existing-names) = {
  if note == none or note == "" {
    return (fields: (:), names: (:), cleaned-note: "")
  }

  let lines = note.split("\n")
  let extracted-fields = (:)
  let extracted-names = (:)
  let remaining-lines = ()
  let found-non-var-line = false

  for (i, line) in lines.enumerate() {
    let trimmed = line.trim()

    // Skip empty lines
    if trimmed == "" {
      if found-non-var-line {
        remaining-lines.push(line)
      }
      continue
    }

    // Try to match variable pattern
    let matches = trimmed.matches(_note-field-pattern)

    if matches.len() > 0 {
      let m = matches.first()
      let var-name = m.captures.at(0)
      let value = m.captures.at(1).trim()

      // Only extract if not already present in entry
      let field-exists = var-name in existing-fields
      let name-exists = var-name in existing-names

      if not field-exists and not name-exists {
        // Check if this is a name variable
        if var-name in NAME-VARS {
          // Parse name: "Family || Given" format
          let parts = value.split("||").map(p => p.trim())
          let name-entry = if parts.len() == 1 {
            // Literal name
            (
              family: "",
              given: "",
              suffix: "",
              prefix: "",
              literal: parts.at(0),
            )
          } else if parts.len() >= 2 {
            // Family || Given format
            (
              family: parts.at(0),
              given: parts.at(1),
              suffix: "",
              prefix: "",
              literal: "",
            )
          } else {
            none
          }

          if name-entry != none {
            if var-name not in extracted-names {
              extracted-names.insert(var-name, ())
            }
            extracted-names.at(var-name).push(name-entry)
          }
        } else {
          // Regular text variable
          extracted-fields.insert(var-name, value)
        }
      }
      // Don't add to remaining lines (consumed)
    } else {
      // Non-variable line - keep in note
      // Once we hit a non-variable line (except at start), stop parsing
      if i > 0 or trimmed != "" {
        found-non-var-line = true
      }
      remaining-lines.push(line)
    }
  }

  let cleaned-note = if remaining-lines.len() > 0 {
    remaining-lines.join("\n").trim()
  } else {
    ""
  }

  (fields: extracted-fields, names: extracted-names, cleaned-note: cleaned-note)
}

// =============================================================================
// CSL-JSON State
// =============================================================================

/// CSL-JSON entries state (key -> entry)
/// Stores converted CSL-JSON entries for lookup
#let _csl-json-data = state("citeproc-csl-json-data", (:))

/// Flag indicating CSL-JSON mode is active
#let _csl-json-mode = state("citeproc-csl-json-mode", false)

// =============================================================================
// CSL-JSON Variable Mappings
// =============================================================================

/// Direct text variables from CSL-JSON
#let TEXT-VARS = (
  "title",
  "container-title",
  "container-title-short",
  "collection-title",
  "collection-title-short",
  "publisher",
  "publisher-place",
  "volume",
  "issue",
  "page",
  "edition",
  "abstract",
  "note",
  "journalAbbreviation",
  "DOI",
  "URL",
  "ISBN",
  "ISSN",
  "citation-label",
  "language",
  "archive",
  "archive_location",
  "call-number",
  "event-title",
  "event",
  "event-place",
  "genre",
  "medium",
  "original-title",
  "part-title",
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

/// Map CSL-JSON variable names to internal field names
/// (matches _field-map in variables.typ for consistency with BibTeX)
#let VAR-TO-FIELD = (
  "URL": "url",
  "DOI": "doi",
  "ISBN": "isbn",
  "ISSN": "issn",
  // CSL variables mapped to BibTeX field names
  "collection-title": "series",
  "event-title": "eventtitle",
  "number-of-volumes": "volumes",
)

/// CSL type to BibTeX entry_type mapping
#let CSL-TYPE-MAP = (
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

/// Number variables (stored as strings for consistency)
#let NUMBER-VARS = (
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

  let result = (:)

  // Handle literal dates first (e.g., "in press", "forthcoming")
  // These take precedence when date-parts is empty
  if "literal" in csl-date {
    result.insert("literal", csl-date.literal)
  }
  if "raw" in csl-date and "literal" not in csl-date {
    let has-date-parts = csl-date.at("date-parts", default: ()).len() > 0
    if not has-date-parts {
      result.insert("literal", csl-date.raw)
    }
  }

  let parts = csl-date.at("date-parts", default: ())
  if parts.len() > 0 {
    // First date-parts array is the start date
    let start = parts.first()

    // Only insert non-empty values (empty strings mean "missing component")
    if start.len() >= 1 {
      let year-val = str(start.at(0))
      if year-val != "" {
        result.insert("year", year-val)
      }
    }
    if start.len() >= 2 {
      let month-val = str(start.at(1))
      if month-val != "" {
        // CSL valid months: 1-12 (regular months), 13-18 (seasons), 21-24 (alternate seasons)
        // Invalid months (e.g., -1, 60) should not be inserted
        let month-int = int(month-val)
        let is-valid-month = (
          month-int != none
            and (
              (month-int >= 1 and month-int <= 12)
                or (month-int >= 13 and month-int <= 18)
                or (month-int >= 21 and month-int <= 24)
            )
        )
        if is-valid-month {
          result.insert("month", month-val)
        }
      }
    }
    if start.len() >= 3 {
      let day-val = str(start.at(2))
      if day-val != "" {
        result.insert("day", day-val)
      }
    }

    // Handle date ranges (second element)
    if parts.len() >= 2 {
      let end = parts.at(1)
      if end.len() >= 1 {
        let end-year-val = str(end.at(0))
        if end-year-val != "" and end-year-val != "0" {
          result.insert("end-year", end-year-val)
        }
        if end-year-val == "0" {
          result.insert("raw-end-year", "0")
        }
      }
      if end.len() >= 2 {
        let end-month-val = str(end.at(1))
        if end-month-val != "" {
          result.insert("end-month", end-month-val)
        }
      }
      if end.len() >= 3 {
        let end-day-val = str(end.at(2))
        if end-day-val != "" {
          result.insert("end-day", end-day-val)
        }
      }
    }
  }

  // Handle season
  if "season" in csl-date {
    result.insert("season", str(csl-date.season))
  }
  // Uncertain date markers (CSL-JSON)
  if "circa" in csl-date and csl-date.circa == 1 {
    result.insert("circa", "true")
  }

  result
}

/// Convert CSL type to BibTeX-like entry_type
///
/// This maps CSL types to approximate BibTeX equivalents for
/// entry_type checks in conditions.typ
#let convert-csl-type(csl-type) = {
  CSL-TYPE-MAP.at(csl-type, default: "misc")
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

  for var in TEXT-VARS {
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
        // Use mapped field name for consistency with BibTeX processing
        let field-name = VAR-TO-FIELD.at(var, default: var)
        fields.insert(field-name, str-val)
      }
    }
  }

  // Number variables (also store as strings for consistency)
  for var in NUMBER-VARS {
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
        // accessed -> urldate and accessed-* fields
        if "year" in date-fields {
          let date-str = date-fields.year
          if "month" in date-fields {
            date-str += "-" + date-fields.month
            if "day" in date-fields {
              date-str += "-" + date-fields.day
            }
          }
          fields.insert("urldate", date-str)
          // Also store individual components for accessed date
          fields.insert("accessed-year", date-fields.year)
          if "month" in date-fields {
            fields.insert("accessed-month", date-fields.month)
          }
          if "day" in date-fields {
            fields.insert("accessed-day", date-fields.day)
          }
        }
      } else if var == "original-date" {
        // original-date -> origdate
        if "year" in date-fields {
          let date-str = date-fields.year
          if "month" in date-fields {
            date-str += "-" + date-fields.month
            if "day" in date-fields {
              date-str += "-" + date-fields.day
            }
          }
          fields.insert("origdate", date-str)
        }
      } else if var == "event-date" {
        if "year" in date-fields {
          let date-str = date-fields.year
          if "month" in date-fields {
            date-str += "-" + date-fields.month
            if "day" in date-fields {
              date-str += "-" + date-fields.day
            }
          }
          fields.insert("eventdate", date-str)
          fields.insert("event-year", date-fields.year)
        }
        if "month" in date-fields {
          fields.insert("event-month", date-fields.month)
        }
        if "day" in date-fields {
          fields.insert("event-day", date-fields.day)
        }
        if "end-year" in date-fields {
          fields.insert("event-end-year", date-fields.at("end-year"))
        }
        if "end-month" in date-fields {
          fields.insert("event-end-month", date-fields.at("end-month"))
        }
        if "end-day" in date-fields {
          fields.insert("event-end-day", date-fields.at("end-day"))
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

  for var in NAME-VARS {
    if var in csl-entry {
      let names = csl-entry.at(var)
      if type(names) == array and names.len() > 0 {
        // Normalize name structure
        // CSL has two types of particles:
        // - non-dropping-particle: always attached to family name (e.g., "la" in "la Martinière")
        // - dropping-particle: can be placed before or after family depending on style (e.g., "de")
        let normalized = names.map(n => {
          if type(n) == dictionary {
            // Handle isInstitution flag - treat as literal/institutional name
            let is-institution = (
              n.at("isInstitution", default: "false") == "true"
            )
            let family = n.at("family", default: "")
            let given = n.at("given", default: "")
            let literal = n.at("literal", default: "")
            let prefix = n.at("non-dropping-particle", default: "")
            let dropping-prefix = n.at("dropping-particle", default: "")

            // Strip quote-protected family names (e.g., "\"van Happel\"")
            let quoted-family = false
            if (
              family.starts-with("\"")
                and family.ends-with("\"")
                and family.len() >= 2
            ) {
              family = family.slice(1, family.len() - 1)
              quoted-family = true
            }

            // Infer non-dropping particle from leading lowercase words
            if (
              not quoted-family
                and prefix == ""
                and dropping-prefix == ""
                and family != ""
            ) {
              let parts = family.split(" ").filter(p => p != "")
              let particle-parts = ()
              while parts.len() > 1 and parts.first() == lower(parts.first()) {
                particle-parts.push(parts.first())
                parts = parts.slice(1)
              }
              if particle-parts.len() > 0 {
                prefix = particle-parts.join(" ")
                family = parts.join(" ")
              }
            }
            // If isInstitution is set, use family as literal
            if is-institution and literal == "" {
              literal = family
            }
            let suffix = n.at("suffix", default: "")
            let comma-suffix = n.at("comma-suffix", default: false)
            if suffix == "" and given.contains(",") {
              let parts = given
                .split(",")
                .map(p => p.trim())
                .filter(p => p != "")
              if parts.len() > 1 {
                given = parts.first()
                suffix = parts.slice(1).join(", ")
                if suffix.starts-with("!") {
                  comma-suffix = true
                  suffix = suffix.slice(1).trim()
                }
              }
            }
            (
              family: family,
              given: given,
              suffix: suffix,
              prefix: prefix,
              dropping-prefix: dropping-prefix,
              comma-suffix: comma-suffix,
              literal: literal,
              is-institution: is-institution,
            )
          } else if type(n) == str {
            // Literal name string
            (
              family: n,
              given: "",
              suffix: "",
              prefix: "",
              dropping-prefix: "",
              comma-suffix: false,
              literal: n,
            )
          } else {
            (
              family: "",
              given: "",
              suffix: "",
              prefix: "",
              dropping-prefix: "",
              comma-suffix: false,
              literal: "",
            )
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

  // Accept CSL-JSON reviewed-author (citeproc-js extension)
  if "reviewed-author" in csl-entry and "reviewed-author" not in parsed-names {
    let names = csl-entry.at("reviewed-author")
    if type(names) == array and names.len() > 0 {
      let normalized = names
        .map(n => {
          if type(n) == dictionary {
            let is-institution = (
              n.at("isInstitution", default: "false") == "true"
            )
            let family = n.at("family", default: "")
            let given = n.at("given", default: "")
            let literal = n.at("literal", default: "")
            if is-institution and literal == "" {
              literal = family
            }
            (
              family: family,
              given: given,
              suffix: n.at("suffix", default: ""),
              prefix: n.at("non-dropping-particle", default: ""),
              dropping-prefix: n.at("dropping-particle", default: ""),
              comma-suffix: n.at("comma-suffix", default: false),
              literal: literal,
              isInstitution: is-institution,
            )
          } else {
            none
          }
        })
        .filter(x => x != none)
      if normalized.len() > 0 {
        parsed-names.insert("reviewed-author", normalized)
      }
    }
  }

  // Parse note field for embedded variables (citeproc-js compatibility)
  // This extracts variables like "reviewed-title: ...", "genre: ...", etc.
  let note-content = fields.at("note", default: "")
  if note-content != "" {
    let note-result = parse-note-field-vars(note-content, fields, parsed-names)

    // Add extracted fields (only if not already present)
    for (k, v) in note-result.fields.pairs() {
      if k not in fields {
        fields.insert(k, v)
      }
    }

    // Add extracted names (only if not already present)
    for (k, v) in note-result.names.pairs() {
      if k not in parsed-names {
        parsed-names.insert(k, v)
      }
    }

    // Update note field to cleaned version (variables removed)
    if note-result.cleaned-note != note-content {
      fields.insert("note", note-result.cleaned-note)
    }
  }

  if "event-date" in fields and "eventdate" not in fields {
    let raw = str(fields.at("event-date", default: "")).trim()
    if raw != "" {
      let parts = raw.split("/")
      let start = parts.first().trim()
      let start-parts = start.split("-")
      if start-parts.len() >= 1 {
        let year = start-parts.at(0)
        let date-str = year
        if start-parts.len() >= 2 {
          let month = start-parts.at(1)
          date-str += "-" + month
          fields.insert("event-month", month)
          if start-parts.len() >= 3 {
            let day = start-parts.at(2)
            date-str += "-" + day
            fields.insert("event-day", day)
          }
        }
        fields.insert("eventdate", date-str)
        fields.insert("event-year", year)
      }
      if parts.len() >= 2 {
        let end = parts.at(1).trim()
        let end-parts = end.split("-")
        if end-parts.len() >= 1 and end-parts.at(0) != "" {
          fields.insert("event-end-year", end-parts.at(0))
        }
        if end-parts.len() >= 2 and end-parts.at(1) != "" {
          fields.insert("event-end-month", end-parts.at(1))
        }
        if end-parts.len() >= 3 and end-parts.at(2) != "" {
          fields.insert("event-end-day", end-parts.at(2))
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
