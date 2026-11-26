/*
 * ============================================================
 * PROJECT ADAPTER
 * ============================================================
 *
 * Connects the academic template library to this project.
 *
 * Responsibilities:
 * - Load project-specific configuration
 * - Load project-specific abbreviation definitions
 * - Resolve the bibliography source
 * - Create the document-bound public API
 * - Export functions for document content
 *
 * Template implementation remains in the shared library.
 * ============================================================
 */


// ------------------------------------------------------------
// IMPORTS
// ------------------------------------------------------------

// Shared template library.
#import "@preview/iu-academic-template:1.0.0": make-document

// Project-specific data.
#import "config.typ": config
#import "abbreviations.typ": abbreviations


// ============================================================
// DOCUMENT CONTEXT
// ============================================================

#let _doc = make-document(
  config: config,
  abbreviations: abbreviations,
  bibliography-source: path(config.bibliography.file),
  bibliography-style: config.bibliography.style,
)


// ============================================================
// PUBLIC DOCUMENT API
// ============================================================

// ------------------------------------------------------------
// DOCUMENT STRUCTURE
// ------------------------------------------------------------

#let setup-document = _doc.setup-document
#let render-front-matter = _doc.render-front-matter
#let start-main-matter = _doc.start-main-matter
#let render-bibliography = _doc.render-bibliography
#let render-appendices = _doc.render-appendices


// ------------------------------------------------------------
// FIGURES AND TABLES
// ------------------------------------------------------------

#let insert-figure = _doc.insert-figure
#let insert-table = _doc.insert-table


// ------------------------------------------------------------
// APPENDICES
// ------------------------------------------------------------

#let insert-appendix = _doc.insert-appendix
#let insert-appendix-section = _doc.insert-appendix-section


// ------------------------------------------------------------
// ABBREVIATIONS
// ------------------------------------------------------------

#let abbr = _doc.abbr


// ------------------------------------------------------------
// ADVANCED CITATIONS
// ------------------------------------------------------------

#let narrative-cite = _doc.narrative-cite
#let secondary-cite = _doc.secondary-cite
#let cite-same-author = _doc.cite-same-author
#let block-quote = _doc.block-quote


// ------------------------------------------------------------
// CITRUS UTILITIES
// ------------------------------------------------------------

#let multicite = _doc.multicite
#let nocite = _doc.nocite
#let locator = _doc.locator
