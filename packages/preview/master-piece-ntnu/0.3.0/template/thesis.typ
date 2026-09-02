// #import "@preview/master-piece-ntnu:0.3.0": master-piece-ntnu, setup-appendices
#import "/src/lib.typ": master-piece-ntnu, setup-appendices

// The template is extensible and plays well with other dependencies;
// For example, a table of acronyms can be generated using glossarium
#import "@preview/glossarium:0.5.10": make-glossary, print-glossary, register-glossary
#import "./acronyms.typ": acronyms
#show: make-glossary
#register-glossary(acronyms)

// Configure formatting options before invoking the template;
// For example, uncomment below to set another font (except for covers)
// #set text(font: "New Computer Modern")

// --------------------------------------------------------------------- //
// ---------- MAIN THESIS TEMPLATE ENTRYPOINT & CONFIGURATION ---------- //
// --------------------------------------------------------------------- //
#show: master-piece-ntnu.with(
  // Primary document language; either "en" or "no"
  primary-lang: "no",

  // Language-specific title, subtitle, abstract, and keywords.
  // Grouped by language, with only values for "en" and "no" being mandatory.
  // Localized abstract/keywords headings may be omitted only for "en" and "no".
  // Field "alpha-3" is the language's ISO 639-3 code, for non-"en"/"no" langs.
  // If desired, any "subtitle" field may be set to none (to omit it entirely).
  localized-info: (
    en: (
      title: "How to Abandon Dinosaur-Age TypeSetting Software",
      subtitle: "A Modern Approach to Problem-Solving",
      abstract: include "./content/abstract-1-en.typ",
      keywords: ("Overfull \\hbox", "Missing $ inserted", "Compilation timed out"),
    ),
    no: (
      title: "Utfasing av typesettingssystemer fra dinosaurenes tid",
      subtitle: "En moderne tilnærming til problemet",
      abstract: lorem(300),
      keywords: ("Forsvunne figurer", "Bærekraftig formatering"),
    ),
  ),

  // Ordered author information; only first and last names fields are mandatory
  authors: (
    (
      first-name: "John",
      last-names: "Doe",
      email: "john.doe@example.com",
      user-id: "jod",
      faculty: "Faculty of Educated Guesses",
      department: "Department of Applied Guesswork",
    ),
    (
      first-name: "Jane",
      last-names: "Doe",
    ),
  ),

  // Ordered supervisor information; "external-org" replaces userid/faculty/dept
  supervisors: (
    (
      first-name: "Alice",
      last-names: "Smith",
      email: "alice@example.com",
      user-id: "alice",
      faculty: "Faculty of Impossible Expectations",
      department: "Department of Loyal Supervision",
    ),
    (
      first-name: "Bob",
      last-names: "Jones",
      email: "bob@example.com",
      external-org: "Selskap AS",
    ),
  ),

  // Degree as part of which the thesis is conducted; all fields are mandatory.
  // Kind is the degree title conferred as listed in the third dropdown above.
  // Level is either "project", "bachelor", "master" or "phd"
  degree: (
    code: "MTFORMAT",
    name: "Applied Guesswork and Formatting Adjustments",
    kind: "Master of Unapplied Sciences",
    level: "master",
  ),

  // Faculty that the thesis is part of
  faculty: "Faculty of Fast Compilation Times",

  // Department that the thesis is part of
  department: "Department of Typesetting Sanity",

  // Information about the cover page for the thesis
  cover: (
    // Whether to generate a cover page at all. Note that for the official submission,
    // NTNU will automatically generate a cover page, so this should probably be disabled
    // before submitting.
    enable: true,
    // Colour of rectangle to be used on the front cover.
    color: rgb("#8DA7CF"),
  ),

  // Logo
  // logo: image("assets/ntnu-logo.png", width: 45mm),

  // Different margins for alternating pages. Adds extra margins to the inside-side of
  // each page, which helps keep all text legible when binding the thesis like a book,
  // but can look weird when presented as a PDF on a screen.
  alternating-margins: true,

  // Acknowledgements body
  acknowledgements: include "content/acknowledgements.typ",

  // Additional front-matter sections, each with keys "heading" and "body"
  extra-preambles: (
    (heading: "Acronyms and Abbreviations", body: print-glossary(acronyms)),
  ),

  // Document date; hardcode for determinism/reproducibility
  doc-date: datetime.today(),

  // Document city (where it's being signed/authored/submitted)
  doc-city: "Trondheim",

  // Extra keywords, embedded in document metadata but not listed in text
  doc-extra-keywords: ("master thesis",),

  // Miscellaneous settings affecting the document's appearance
  style: (
    // Whether the proprietary Arial font should be used in Sans-Serif contexts.
    // While this is the font prescribed by the official KTH covers, it is often
    // preferable to use an open, metric-compatible alternative. If this is set
    // to `false`, Liberation Sans will be used instead of Arial. Otherwise, if
    // this is set to `true`, Typst will issue a warning if Arial is not found
    // on the system at compile-time.
    // Graceful font fallback is not possible until issue typst#6010 is fixed.
    use-arial: false,

    // Whether front matter, headings, and headings should use a Sans-Serif font
    more-sans-serif: false,

    // Whether to make top-level headings stand out more and look less plain
    fancy-chapters: false,
  ),
)

// Tip: when tagging elements, scope labels like <intro:goals:example>

#include "./content/ch01-introduction.typ"
#include "./content/ch02-background.typ"
#include "./content/ch03-method.typ"
#include "./content/ch04-the-thing.typ"
#include "./content/ch05-results.typ"
#include "./content/ch06-discussion.typ"
#include "./content/ch07-conclusion.typ"

#bibliography("references.yaml", title: "References")

#show: setup-appendices
#include "./content/zz-a-usage.typ"
#include "./content/zz-b-else.typ"
