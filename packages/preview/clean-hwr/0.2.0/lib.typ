// TODO: check dep versions
#import "@preview/linguify:0.5.0": set-database, load-ftl-data, linguify
#import "@preview/acrostiche:0.7.0": init-acronyms
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary

#import "pages/confidentiality_notice.typ": _render-confidentiality-notice-if-right-place, render-confidentiality-notice
#import "pages/title_page.typ": _render-title-page
#import "pages/abstract.typ": _render-abstract
#import "pages/note_on_gender_inclusive_language.typ": _render-note-on-gender-inclusive-lang
#import "pages/declaration_of_authorship.typ": _render-declaration-of-authorship
#import "pages/glossary.typ": _render-glossary
#import "pages/acronyms.typ": _render-acronyms
#import "pages/indices_of_everything.typ": _render-indices-of-everything
#import "pages/bibliography.typ": _set-biblography
#import "pages/appendix.typ": _render-appendix

/// Main entry point for rendering an HWR-style academic paper template.
///
/// This function configures document-wide settings (language, fonts,
/// numbering, metadata, glossary, acronyms, bibliography, appendix, etc.)
/// and renders all structural components in the correct order:
///
/// 1. Optional confidentiality notice
/// 2. Title page
/// 3. Abstract
/// 4. Declaration of authorship
/// 5. Table of contents
/// 6. Glossary and acronyms
/// 7. Indices (figures, tables, listings)
/// 8. Main body
/// 9. Bibliography
/// 10. Appendix
///
/// It also initializes localization, glossary handling, and acronym support.
///
/// Parameters
///
/// - language (str, default: `"en"`):
///   Document language (e.g. `"en"` or `"de"`).
///
/// - main-font (str, default: `"TeX Gyre Termes"`):
///   Font family used for the entire document.
///
/// - metadata (dictionary):
///   Main metadata for the title page.
///   Defaults:
///   ```typst
///   (
///     paper-type: [],
///     title: [PTB Template],
///     student-id: "",
///     authors: none,
///     company: "",
///     enrollment-year: "",
///     semester: "",
///     company-supervisor: "",
///     authors-per-line: 2,
///     field-of-study: none,
///     university: none,
///     date-of-publication: none,
///     uni-logo: none,
///     company-logo: none,
///   )
///   ```
///
/// - custom-entries (dictionary, default: `()`):
///   Additional custom metadata entries for the title page.
///
/// - label-signature-left (content, default: []):
///   Label shown below the left signature line.
///
/// - label-signature-right (content, default: []):
///   Label shown below the right signature line.
///
/// - word-count (content or none, default: `none`):
///   Optional word count displayed on the title page.
///
/// - custom-declaration-of-authorship (content, default: []):
///   Overrides the default declaration text.
///
/// - confidentiality-notice (dictionary):
///   ```typst
///   (
///     title: [],
///     content: [],
///     page-idx: none,
///   )
///   ```
///   Defines an optional confidentiality notice and its placement.
///
/// - abstract (content, default: [#lorem(30)]):
///   Abstract text of the document.
///
/// - note-gender-inclusive-language (dictionary):
///   ```typst
///   (
///     enabled: false,
///     title: "",
///   )
///   ```
///   Enables an optional note (typically for German-language papers).
///
/// - glossary (dictionary):
///   ```typst
///   (
///     title: "",
///     entries: (),
///     disable-back-references: none,
///   )
///   ```
///
/// - acronyms (dictionary):
///   ```typst
///   (
///     title: "",
///     entries: (),
///   )
///   ```
///
/// - figure-index (dictionary):
///   ```typst
///   (
///     enabled: false,
///     title: "",
///   )
///   ```
///
/// - table-index (dictionary):
///   ```typst
///   (
///     enabled: false,
///     title: "",
///   )
///   ```
///
/// - listing-index (dictionary):
///   ```typst
///   (
///     enabled: false,
///     title: "",
///   )
///   ```
///
/// - bibliography-object (content or none, default: `none`):
///   Bibliography data source.
///
/// - citation-style (str, default: `"hwr_citation.csl"`):
///   CSL file used for citation formatting.
///
/// - appendix (dictionary):
///   ```typst
///   (
///     enabled: false,
///     title: "",
///     content: [],
///   )
///   ```
///
/// - body (content):
///   Main document content.
///
/// Returns
/// - content:
///   Fully rendered academic document including front matter,
///   main body, bibliography, and optional appendix.
///
/// Example
/// ```typst
/// #hwr(
///   metadata: (
///     title: [My Thesis],
///     authors: [Max Mustermann],
///     student-id: "123456",
///   ),
///   abstract: [This thesis explores ...],
/// )[
///   = Introduction
///   This is the main content.
/// ]
/// ```
#let hwr(
  language: "en",
  main-font: "TeX Gyre Termes",

  // Main Metadata for the title page
  metadata: (
    paper-type: [],
    title: [PTB Template],
    student-id: "",
    authors: none,
    company: "",
    enrollment-year: "",
    semester: "",
    company-supervisor: "",
    // These do not need to be changed by the user
    authors-per-line: 2,
    field-of-study: none,
    university: none,
    date-of-publication: none,
    uni-logo: none,
    company-logo: none,
  ),
  custom-entries: (),
  label-signature-left: [],
  label-signature-right: [],
  word-count: none,

  // Declaration of authorship
  custom-declaration-of-authorship: [],

  // Confidentiality notice
  confidentiality-notice: (
    title: [],
    content: [],
    page-idx: none,
  ),

  // Abstract content
  abstract: [#lorem(30)],

  // A note that is only relevant if you write a german paper
  note-gender-inclusive-language: (
    enabled: false,
    title: ""
  ),

  // All the lists and outlines
  glossary: (
    title: "",
    entries: (),
    disable-back-references: none,
  ),
  acronyms: (
    title: "",
    entries: ()
  ),
  figure-index: (
    enabled: false,
    title: ""
  ),
  table-index: (
    enabled: false,
    title: ""
  ),
  listing-index: (
    enabled: false,
    title: ""
  ),

  // Bibliography settings
  bibliography-object: none,
  citation-style: "hwr_citation.csl",

  // The content of the appendix
  appendix: (
    enabled: false,
    title: "",
    content: []
  ),

  body,
) = {
  set-database(eval(load-ftl-data("./l10n", ("de", "en"))))

  set document(author: metadata.authors, title: metadata.title)
  set page(numbering: none, number-align: center)
  set text(font: main-font, lang: language)
  set heading(numbering: "1.1", supplement: linguify("chapter"))

  // SETUP Acronyms
  if acronyms.entries != () {
    init-acronyms(acronyms.entries)
  }

  show: make-glossary
  register-glossary(glossary.entries)

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  _render-title-page(
    language: language,
    metadata: metadata,
    custom-entries: custom-entries,
    label-signature-left: label-signature-left,
    label-signature-right: label-signature-right,
    word-count: word-count,
  )

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  _render-abstract(abstract: abstract)
  _render-note-on-gender-inclusive-lang(note-gender-inclusive-language: note-gender-inclusive-language)

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  _render-declaration-of-authorship(
    custom-declaration-of-authorship: custom-declaration-of-authorship,
    metadata: metadata
  )

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  // Content outline
  outline(depth: 3, indent: 2%)
  pagebreak()

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  _render-glossary(glossary: glossary)

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  _render-acronyms(acronyms: acronyms)

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  _render-indices-of-everything(
    figure-index: figure-index,
    table-index: table-index,
    listing-index: listing-index,
  )

  set par(justify: true)
  set page(numbering: "1")

  body

  // Settings for pages after main body
  set heading(numbering: none)
  set page(numbering: "I")

  _set-biblography(
    bibliography-object: bibliography-object,
    citation-style: citation-style
  )

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)

  _render-appendix(appendix: appendix)

  _render-confidentiality-notice-if-right-place(confidentiality-notice: confidentiality-notice)
}
