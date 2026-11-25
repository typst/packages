/*
 * ============================================================
 * DOCUMENT CONTROLLER
 * ============================================================
 *
 * Controls document initialization and structure.
 *
 * Responsibilities:
 * - Apply global document formatting
 * - Initialize citation processing
 * - Set PDF metadata
 * - Render title page and preliminary lists
 * - Manage front-matter and main-matter page numbering
 * - Render the appendix directory and appendix content
 *
 * All project-specific data is provided by the caller.
 * This module does not import project files.
 * ============================================================
 */


// ------------------------------------------------------------
// IMPORTS
// ------------------------------------------------------------

#import "base.typ": base-style

#import "../components/title-page.typ": render-title-page
#import "../components/table-of-contents.typ": render-table-of-contents
#import "../components/figures.typ": render-list-of-figures
#import "../components/tables.typ": render-list-of-tables
#import "../components/abbreviations-manager.typ": render-list-of-abbreviations
#import "../components/appendix.typ": render-list-of-appendices


// ============================================================
// DOCUMENT INITIALIZATION
// ============================================================

#let setup-document(
  config,
  citation-initializer,
  body,
) = {
  let numbering = config.formatting.page-numbering

  [
    // --------------------------------------------------------
    // PDF METADATA
    // --------------------------------------------------------

    #set document(
      title: config.title-page.title,
      author: config.title-page.author,
    )


    // --------------------------------------------------------
    // PAGE NUMBERING
    // --------------------------------------------------------

    // Main-matter numbering is the document default.
    // Front matter temporarily overrides this setting.

    #set page(
      numbering: numbering.main-matter,
      number-align: numbering.position,
    )


    // --------------------------------------------------------
    // GLOBAL FORMATTING AND CITATIONS
    // --------------------------------------------------------

    // Citation initialization is bound to project resources
    // by the public template API.

    #base-style(
      citation-initializer(body),
      config.formatting,
      config.language,
    )
  ]
}


// ============================================================
// FRONT MATTER
// ============================================================

#let render-front-matter(config, abbreviations) = [

  // ----------------------------------------------------------
  // ROMAN PAGE NUMBERING
  // ----------------------------------------------------------

  #set page(
    numbering: config.formatting.page-numbering.front-matter,
    number-align: config.formatting.page-numbering.position,
  )


  // ----------------------------------------------------------
  // TITLE PAGE
  // ----------------------------------------------------------

  // The title page handles its own page break and
  // suppresses the visible page number.

  #render-title-page(
    config.title-page,
    language: config.language,
  )


  // ----------------------------------------------------------
  // TABLE OF CONTENTS
  // ----------------------------------------------------------

  #render-table-of-contents(
    config.table-of-contents,
    language: config.language,
  )

  #pagebreak(weak: true)


  // ----------------------------------------------------------
  // LIST OF FIGURES
  // ----------------------------------------------------------

  #render-list-of-figures(
    config.list-of-figures,
    language: config.language,
  )

  #pagebreak(weak: true)


  // ----------------------------------------------------------
  // LIST OF TABLES
  // ----------------------------------------------------------

  #render-list-of-tables(
    config.list-of-tables,
    language: config.language,
  )

  #pagebreak(weak: true)


  // ----------------------------------------------------------
  // LIST OF ABBREVIATIONS
  // ----------------------------------------------------------

  // Uses the same definitions as the document-bound abbr()
  // function provided by the public template API.

  #render-list-of-abbreviations(
    abbreviations,
    config.abbreviation-list,
    language: config.language,
  )

  #pagebreak(weak: true)
]


// ============================================================
// MAIN MATTER
// ============================================================

#let start-main-matter(config) = [

  // Begin the main text on a new page.
  #pagebreak(weak: true)

  // Reset the logical page counter.
  // Arabic numbering is configured by setup-document.
  #counter(page).update(
    config.formatting.page-numbering.main-start,
  )
]


// ============================================================
// APPENDICES
// ============================================================

#let render-appendices(config, body) = [

  // ----------------------------------------------------------
  // APPENDIX DIRECTORY
  // ----------------------------------------------------------

  // Render the directory immediately before the appendices.
  // Its visibility is controlled by the project settings.

  #render-list-of-appendices(
    enabled: config.list-of-appendices.enabled,
    language: config.language,
  )


  // ----------------------------------------------------------
  // APPENDIX CONTENT
  // ----------------------------------------------------------

  // Appendix page breaks and numbering are managed by
  // the appendix component.

  #body
]
