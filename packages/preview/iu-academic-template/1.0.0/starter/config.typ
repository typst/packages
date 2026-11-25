/*
 * ============================================================
 * DOCUMENT CONFIGURATION
 * ============================================================
 *
 * Project-specific settings for a new academic paper.
 * Edit this file for each assignment.
 *
 * Required title page fields: university, document-type,
 * title, and author. Optional fields can be set to none.
 * ============================================================
 */

#let config = (

  // ==========================================================
  // FORMATTING
  // ==========================================================

  // Document language: "de" or "en".
  language: "de",

  formatting: (

    // Page
    paper: "a4",
    margin: 2cm,


    // Body text font
    // The first font is preferred; the second is used if unavailable
    // (e.g. in the web editor). You can also specify just one font.
    font: ("Arial", "Liberation Sans"),
    font-size: 11pt,
    line-spacing: 1.5,
    paragraph-spacing: 6pt,
    justify: true,
    hyphenate: true,

    // Headings (levels 1–3)
    heading-sizes: (
      16pt,
      14pt,
      11pt,
    ),
    heading-numbering: "1.1",

    // Footnotes
    footnote-size: 10pt,

    // Page numbering
    page-numbering: (
      front-matter: "I",
      main-matter: "1",
      main-start: 1,
      position: center + bottom,
      show-on-title-page: false,
    ),

    // Appendix numbering
    // Figure/table modes: "none", "per-appendix", "continuous".
    appendices-numbering: (
      numbering: "A1",
      figures: "per-appendix",
      tables: "per-appendix",
    ),

  ),

  // ==========================================================
  // TITLE PAGE
  // ==========================================================

  title-page: (

    // University
    university: "IU Internationale Hochschule",
    faculty: none,
    degree-program: none,

    // Assignment
    document-type: "Hausarbeit",
    course: none,
    course-number: none,
    semester: none,

    // Title
    title: "Titel der wissenschaftlichen Arbeit",
    subtitle: none,

    // Author
    author: "Vorname Nachname",
    student-id: none,

    // Supervisor
    supervisor: none,

    // Submission
    location: none,
    submission-date: datetime.today(),

    // Set to image("assets/logo.svg", width: 6cm) once added.
    logo: none,

  ),

  // ==========================================================
  // DIRECTORIES
  // ==========================================================

  table-of-contents: (
    enabled: true,
    depth: 3,
  ),

  list-of-figures: (
    enabled: "auto",
  ),

  list-of-tables: (
    enabled: "auto",
  ),

  abbreviation-list: (
    enabled: true,
  ),

  list-of-appendices: (
    enabled: "auto",
  ),


  // ==========================================================
  // SOURCE NOTES
  // ==========================================================

  // Explicit source notes are always displayed.
  source-notes: (
    show-own-work: true,
  ),


  // ==========================================================
  // BIBLIOGRAPHY
  // ==========================================================

  // Supported file/engine combinations:
  // - "citrus" + .json or .bib
  // - "native" + .yaml, .yml, or .bib
  // Advanced citation helpers require Citrus + CSL-JSON.
  bibliography: (
    enabled: true,
    engine: "citrus",
    file: "references.json",
    style: "iu",
  ),

)
