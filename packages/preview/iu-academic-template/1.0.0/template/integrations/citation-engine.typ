/*
 * ============================================================
 * CITATION ENGINE MANAGER
 * ============================================================
 *
 * Initializes citation processing for a document.
 *
 * Supported combinations:
 * - Citrus + CSL-JSON (.json)
 * - Citrus + BibTeX/BibLaTeX (.bib)
 * - Native Typst + Hayagriva (.yaml, .yml)
 * - Native Typst + BibTeX/BibLaTeX (.bib)
 *
 * Responsibilities:
 * - Resolve bundled and custom citation styles
 * - Apply the document language to Citrus CSL styles
 * - Initialize Citrus with project-bound resources
 * - Preserve native Typst citation processing
 *
 * Project configuration and resource paths are supplied
 * by the caller. No project files are imported directly.
 *
 * Configuration validation is handled by the public
 * template API.
 * ============================================================
 */


// ------------------------------------------------------------
// IMPORTS
// ------------------------------------------------------------

#import "citrus.typ" as citrus


// ============================================================
// CITATION STYLE RESOLUTION
// ============================================================

// Resolve bundled styles relative to the template package.
//
// Custom CSL files must be passed as project-bound paths.
// Native Typst also supports built-in style names.

#let resolve-bibliography-style(style, engine) = {

  // ----------------------------------------------------------
  // CUSTOM STYLE
  // ----------------------------------------------------------

  if type(style) == path {
    return style
  }


  // ----------------------------------------------------------
  // BUNDLED IU STYLE
  // ----------------------------------------------------------

  if style == "iu" {

    if engine == "citrus" {
      return path("../styles/iu-citrus.csl")
    }

    // Use the bundled IU CSL style for both citation engines.
    // Native Typst supports custom CSL files directly.
    return path("../styles/iu-citrus.csl")
  }


  // ----------------------------------------------------------
  // APA STYLE
  // ----------------------------------------------------------

  if style == "apa" {

    if engine == "citrus" {
      return path("../styles/apa.csl")
    }

    return "apa"
  }


  // ----------------------------------------------------------
  // TRANSITIONAL STYLE NAMES
  // ----------------------------------------------------------

  // Support the current project configuration while
  // migrating to symbolic style identifiers.

  if style == "template/styles/iu-citrus.csl" {

    assert(
      engine == "citrus",
      message: "The Citrus IU style requires the Citrus engine.",
    )

    return path("../styles/iu-citrus.csl")
  }

  if style == "template/styles/iu.csl" {

    assert(
      engine == "native",
      message: "The native IU style requires the native engine.",
    )

    // Preserve the legacy native style identifier while
    // resolving it to the existing bundled IU CSL file.
    return path("../styles/iu-citrus.csl")
  }

  if style == "template/styles/apa.csl" {
    return path("../styles/apa.csl")
  }


  // ----------------------------------------------------------
  // UNSUPPORTED STYLE
  // ----------------------------------------------------------

  panic(
    "Unknown bibliography style. Use 'iu', 'apa', or a project-bound CSL path.",
  )
}


// ============================================================
// CSL LANGUAGE
// ============================================================

// Convert the validated document language to a CSL locale.

#let _csl-locale(language) = {
  if language == "de" {
    "de-DE"
  } else {
    "en-US"
  }
}


// ------------------------------------------------------------
// APPLY CSL LOCALE
// ------------------------------------------------------------

// Update only the root <style> element.
//
// An existing default-locale attribute is replaced.
// If the attribute is missing, it is inserted.
//
// The original CSL file is never modified.

#let _apply-csl-locale(style-content, language) = {

  let locale = _csl-locale(language)

  let locale-attribute = (
    "default-locale=\"" + locale + "\""
  )


  // ----------------------------------------------------------
  // FIND ROOT ELEMENT
  // ----------------------------------------------------------

  let root-pattern = regex("<style\\b[^>]*>")
  let root-match = style-content.match(root-pattern)

  assert(
    root-match != none,
    message: "Invalid CSL style: Missing root <style> element.",
  )

  let root = root-match.text


  // ----------------------------------------------------------
  // FIND EXISTING LOCALE ATTRIBUTE
  // ----------------------------------------------------------

  let locale-pattern = regex(
    "default-locale\\s*=\\s*[\"'][^\"']*[\"']",
  )

  let existing-locale = root.match(locale-pattern)


  // ----------------------------------------------------------
  // UPDATE ROOT ELEMENT
  // ----------------------------------------------------------

  let updated-root = if existing-locale != none {

    root.replace(
      existing-locale.text,
      locale-attribute,
      count: 1,
    )

  } else {

    root.replace(
      "<style",
      "<style " + locale-attribute,
      count: 1,
    )

  }


  // ----------------------------------------------------------
  // RETURN LOCALIZED STYLE
  // ----------------------------------------------------------

  style-content.replace(
    root,
    updated-root,
    count: 1,
  )
}

// ============================================================
// CSL-JSON DATA NORMALIZATION
// ============================================================

// Avoid repeating the same institution as both author
// and publisher for datasets.
//
// Only institutional authors represented by a single
// CSL-JSON literal name are normalized.
//
// Different publishers remain unchanged.

#let _normalize-csl-json-entries(database) = {
  let entries = json(bytes(database))

  let normalized-entries = entries.map(entry => {
    let authors = entry.at("author", default: ())
    let publisher = entry.at("publisher", default: none)

    let same-institution = (
      entry.at("type", default: "") in ("dataset", "standard", "report")
      and publisher != none
      and type(authors) == array
      and authors.len() == 1
      and authors.first().at("literal", default: none) == publisher
    )

    if same-institution {
      let normalized-entry = entry
      let _ = normalized-entry.remove("publisher")
      normalized-entry
    } else if (
      entry.at("type", default: "") == "post"
      and publisher == none
      and entry.at("container-title", default: none) != none
    ) {
      // Use the social media platform as publisher.
      let normalized-entry = entry
      let platform = normalized-entry.at("container-title")

      let _ = normalized-entry.remove("container-title")
      let _ = normalized-entry.insert("publisher", platform)

      normalized-entry
    } else {
      entry
    }
  })

  json.encode(normalized-entries, pretty: false)
}

// ============================================================
// CITATION ENGINE INITIALIZATION
// ============================================================

#let initialize-citations(
  body,
  settings: none,
  bibliography-source: none,
  bibliography-style: none,
  language: none,
) = {

  let engine = settings.engine
  let file = settings.file


  // ----------------------------------------------------------
  // NATIVE TYPST
  // ----------------------------------------------------------

  // Native Typst handles citation processing through
  // its bibliography element. No initializer is needed.

  if engine == "native" {
    return body
  }


  // ----------------------------------------------------------
  // CITRUS RESOURCES
  // ----------------------------------------------------------

  // Load the project-bound bibliography source.

  let database = read(bibliography-source)


  // Resolve the selected CSL style.
  // Bundled styles remain inside the template package.

  let style-resource = resolve-bibliography-style(
    bibliography-style,
    engine,
  )

  let style-content = read(style-resource)


  // ----------------------------------------------------------
  // CSL LOCALIZATION
  // ----------------------------------------------------------

  // Apply the document language before initializing Citrus.

  let localized-style = _apply-csl-locale(
    style-content,
    language,
  )


  // ----------------------------------------------------------
  // CITRUS + CSL-JSON
  // ----------------------------------------------------------

  if file.ends-with(".json") {

    let normalized-database = _normalize-csl-json-entries(
      database,
    )

    citrus.init-csl-json(
      normalized-database,
      localized-style,
      body,
    )

  }

  // ----------------------------------------------------------
  // CITRUS + BIBTEX/BIBLATEX
  // ----------------------------------------------------------

  else if file.ends-with(".bib") {

    citrus.init-csl(
      database,
      localized-style,
      body,
    )

  }


  // ----------------------------------------------------------
  // UNSUPPORTED SOURCE
  // ----------------------------------------------------------

  else {

    panic(
      "Citrus requires a CSL-JSON or BibTeX bibliography.",
    )

  }
}