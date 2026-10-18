// citrus - Variable Access
//
// Functions for accessing entry variables/fields
// Includes CSL-M legal variable extensions

#import "collapsing.typ": num-to-suffix

// =============================================================================
// Module-level constants (avoid recreating on each call)
// =============================================================================

#let _re-non-alpha = regex("[^A-Za-z]")

// CSL name variables (stored in ctx.names, not ctx.fields)
#let NAME-VARS = (
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

// Direct field mappings (including CSL-M legal variables)
#let _field-map = (
  // Standard CSL variables
  "title": "title",
  "publisher-place": "address",
  "page": "pages",
  "volume": "volume",
  "issue": "number",
  "URL": "url",
  "DOI": "doi",
  "ISBN": "isbn",
  "ISSN": "issn",
  "edition": "edition",
  "note": "note",
  "abstract": "abstract",
  "archive": "archive",
  "archive_location": "archiveprefix",
  "number": "number",
  "genre": "type",
  "event-title": "eventtitle",
  "event": "event",
  "original-title": "original-title",
  "part-title": "part-title",
  "reviewed-title": "reviewed-title",
  "collection-title": "series",
  "number-of-volumes": "volumes",
  // CSL-M legal variables
  "authority": "authority",
  "jurisdiction": "jurisdiction",
  "committee": "committee",
  "document-name": "document-name",
  "hereinafter": "hereinafter",
  "supplement": "supplement",
  "division": "division",
  "gazette-flag": "gazette-flag",
  "volume-title": "volume-title",
  "publication-number": "publication-number",
  "locator-extra": "locator-extra",
  "references": "references",
  "chapter-number": "chapter",
  "section": "section",
  "article": "article",
)

/// Get variable value from context
/// Handles CSL variable names and maps to BibTeX fields
#let get-variable(ctx, name) = {
  let fields = ctx.fields
  let entry-type = ctx.entry-type

  // Handle special variables
  if name == "citation-number" {
    return fields.at("citation-number", default: "")
  }

  if name == "year-suffix" {
    // Year suffix stored as numeric index (0, 1, 2, ...)
    // Convert to letter (a, b, c, ...) for rendering
    let suffix = ctx.at("year-suffix", default: none)
    if suffix == none or suffix == "" { return "" }
    if type(suffix) == int { return num-to-suffix(suffix) }
    return str(suffix) // Fallback for already-converted values
  }

  if name == "issued" {
    let has-issued = (
      fields.at("year", default: "") != ""
        or fields.at("month", default: "") != ""
        or fields.at("day", default: "") != ""
        or fields.at("date", default: "") != ""
        or fields.at("season", default: "") != ""
        or fields.at("literal", default: "") != ""
    )
    if not has-issued {
      return ""
    }
    let flag = fields.at("circa", default: "")
    if flag == "true" {
      return "circa"
    }
  }

  if name == "citation-label" {
    // Prefer explicit citation-label field if provided
    let custom = fields.at("citation-label", default: "")

    let names = ctx.at("parsed-names", default: (:))
    let primary = if names.at("author", default: ()).len() > 0 {
      names.at("author", default: ())
    } else if names.at("editor", default: ()).len() > 0 {
      names.at("editor", default: ())
    } else if names.at("translator", default: ()).len() > 0 {
      names.at("translator", default: ())
    } else {
      ()
    }

    let family-list = primary
      .map(n => {
        let literal = n.at("literal", default: "")
        let raw = if literal != "" { literal } else {
          n.at("family", default: "")
        }
        if raw == "" { return "" }
        // Drop leading lowercase particles (e.g., "von Dipheria" -> "Dipheria")
        let parts = raw.split(" ").filter(p => p != "")
        while parts.len() > 1 and parts.first() == lower(parts.first()) {
          parts = parts.slice(1)
        }
        parts.join(" ")
      })
      .filter(x => x != "")

    let base = if custom != "" {
      custom
    } else if family-list.len() > 0 {
      // Build label from family names
      let cleaned = family-list.map(x => x.replace(_re-non-alpha, ""))
      let label = if cleaned.len() == 1 {
        let s = cleaned.first()
        if s.len() >= 4 { s.slice(0, 4) } else { s }
      } else if cleaned.len() == 2 {
        let a = cleaned.at(0)
        let b = cleaned.at(1)
        let a2 = if a.len() >= 2 { a.slice(0, 2) } else { a }
        let b2 = if b.len() >= 2 { b.slice(0, 2) } else { b }
        a2 + b2
      } else {
        cleaned
          .slice(0, 4)
          .map(s => if s.len() > 0 { s.slice(0, 1) } else { "" })
          .join()
      }

      let year = fields.at("year", default: fields.at("date", default: ""))
      let year-str = str(year)
      let year-suffix = if year-str.len() >= 2 {
        year-str.slice(year-str.len() - 2)
      } else {
        year-str
      }

      label + year-suffix
    } else {
      ""
    }

    if base == "" { return "" }

    let disambig = ctx.at("year-suffix", default: none)
    let suffix = if disambig == none or disambig == "" {
      ""
    } else if type(disambig) == int {
      num-to-suffix(disambig)
    } else {
      str(disambig)
    }

    return base + suffix
  }

  if name == "first-reference-note-number" {
    // The note number where this citation first appeared (for ibid/subsequent)
    return ctx.at("first-reference-note-number", default: "")
  }

  if name == "publisher" {
    // For thesis, use school; otherwise use publisher
    if (
      entry-type == "phdthesis"
        or entry-type == "mastersthesis"
        or entry-type == "thesis"
    ) {
      let school = fields.at("school", default: "")
      if school != "" { return school }
    }
    return fields.at("publisher", default: "")
  }

  if name == "container-title" {
    // Container depends on entry type
    let container = fields.at("container-title", default: "")
    if container != "" { return container }
    let journal = fields.at("journal", default: "")
    if journal != "" { return journal }
    let booktitle = fields.at("booktitle", default: "")
    if booktitle != "" { return booktitle }
    return ""
  }

  if name == "container-title-short" {
    let short = fields.at("container-title-short", default: "")
    if short != "" { return short }
    let journal-abbrev = fields.at("journalAbbreviation", default: "")
    if journal-abbrev != "" { return journal-abbrev }
    let shortjournal = fields.at("shortjournal", default: "")
    if shortjournal != "" { return shortjournal }
    let journal-short = fields.at("journal-short", default: "")
    if journal-short != "" { return journal-short }
    return ""
  }

  if name == "collection-title" {
    let collection = fields.at("collection-title", default: "")
    if collection != "" { return collection }
    return fields.at("series", default: "")
  }

  if name == "collection-title-short" {
    let short = fields.at("collection-title-short", default: "")
    if short != "" { return short }
    let series-short = fields.at("series-short", default: "")
    if series-short != "" { return series-short }
    return ""
  }

  if name == "event-title" {
    return fields.at("eventtitle", default: fields.at("booktitle", default: ""))
  }

  // page-first: derived from page, returns first page of range
  if name == "page-first" {
    let pages = fields.at("pages", default: fields.at("page", default: ""))
    if pages == "" { return "" }
    // Extract first page from range (handles "42-45", "42–45", "42")
    let pages-str = str(pages)
    // Try various delimiters: en-dash, em-dash, hyphen, comma
    for delim in ("–", "—", "-", ",") {
      if pages-str.contains(delim) {
        return pages-str.split(delim).first().trim()
      }
    }
    return pages-str
  }

  // Date variables - check if date exists
  if name == "issued" {
    // Return year as a proxy for "issued has value"
    return fields.at("year", default: fields.at("date", default: ""))
  }

  if name == "accessed" {
    // URL access date - typically urldate in BibTeX
    return fields.at("urldate", default: "")
  }

  if name == "original-date" {
    return fields.at("origdate", default: "")
  }

  // CSL-M original-* variables (for bilingual entries)
  // These map to BibTeX fields with -en suffix
  if name == "original-title" {
    let direct = fields.at("original-title", default: "")
    if direct != "" { return direct }
    return fields.at("title-en", default: "")
  }

  if name == "original-container-title" {
    // For journal articles, use journal-en; for book chapters, use booktitle-en
    let journal-en = fields.at("journal-en", default: "")
    if journal-en != "" { return journal-en }
    return fields.at("booktitle-en", default: "")
  }

  if name == "original-publisher" {
    return fields.at("publisher-en", default: "")
  }

  if name == "original-publisher-place" {
    return fields.at("address-en", default: fields.at(
      "location-en",
      default: "",
    ))
  }

  // CSL-M special variables

  // Country (virtual variable from jurisdiction)
  if name == "country" {
    let jurisdiction = fields.at("jurisdiction", default: "")
    if jurisdiction != "" {
      let parts = jurisdiction.split(":")
      return parts.first()
    }
    return ""
  }

  // Available date (CSL-M: date available for signing, e.g., treaties)
  if name == "available-date" {
    return fields.at("available-date", default: fields.at(
      "availabledate",
      default: "",
    ))
  }

  // Publication date (CSL-M: date published in gazette/reporter)
  if name == "publication-date" {
    return fields.at("publication-date", default: fields.at(
      "pubdate",
      default: "",
    ))
  }

  // Language-name (CSL-M: ISO language code from language field vector)
  if name == "language-name" {
    let lang = fields.at("language", default: "")
    if lang.contains(">") {
      let parts = lang.split(">")
      return parts.at(1, default: "").trim()
    } else if lang.contains("<") {
      let parts = lang.split("<")
      return parts.at(0, default: "").trim()
    }
    return ""
  }

  // Language-name-original (CSL-M: source language from vector)
  if name == "language-name-original" {
    let lang = fields.at("language", default: "")
    if lang.contains(">") {
      let parts = lang.split(">")
      return parts.at(0, default: "").trim()
    } else if lang.contains("<") {
      let parts = lang.split("<")
      return parts.at(1, default: "").trim()
    }
    return ""
  }

  // Standard mapping - try original name first (CSL-JSON), then mapped name (BibTeX)
  let value = fields.at(name, default: "")
  if value == "" {
    let field-name = _field-map.at(name, default: name)
    if field-name != name {
      value = fields.at(field-name, default: "")
    }
  }

  // Apply abbreviations if available
  let abbrevs = ctx.at("abbreviations", default: (:))
  if abbrevs != (:) and value != "" {
    // Try jurisdiction-specific first, then default
    let jurisdiction = fields.at("jurisdiction", default: "default")
    let lookup = abbrevs.at(jurisdiction, default: none)
    if lookup == none {
      lookup = abbrevs.at("default", default: (:))
    }
    // Look up abbreviation for this variable
    let var-abbrevs = lookup.at(name, default: (:))
    if value in var-abbrevs {
      return var-abbrevs.at(value)
    }
  }

  value
}

/// Check if variable exists and has value
/// Handles both regular variables (fields) and name variables (names dict)
#let has-variable(ctx, name) = {
  // Name variables are stored in ctx.parsed-names, not ctx.fields
  if name in NAME-VARS {
    let names = ctx.at("parsed-names", default: (:))
    let name-list = names.at(name, default: ())
    return name-list.len() > 0
  }

  // Regular variables
  let val = get-variable(ctx, name)
  val != none and val != ""
}
