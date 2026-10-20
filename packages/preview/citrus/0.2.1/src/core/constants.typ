// citrus - Constants Module
//
// Defines named constants for magic strings used throughout the codebase.
// Using these constants improves type safety and makes refactoring easier.

// =============================================================================
// Position Types (CSL position condition)
// =============================================================================
// Used in citation rendering to determine first/subsequent/ibid status

#let POSITION = (
  first: "first",
  subsequent: "subsequent",
  ibid: "ibid",
  ibid-with-locator: "ibid-with-locator",
)

// =============================================================================
// Collapse Modes (CSL collapse attribute)
// =============================================================================
// Used in multicite to determine how to collapse citation groups

#let COLLAPSE = (
  year: "year",
  year-suffix: "year-suffix",
  year-suffix-ranged: "year-suffix-ranged",
  citation-number: "citation-number",
)

// =============================================================================
// Render Context Types
// =============================================================================
// Used to distinguish citation vs bibliography rendering

#let RENDER-CONTEXT = (
  citation: "citation",
  bibliography: "bibliography",
)

// =============================================================================
// Citation Forms
// =============================================================================
// Used to specify citation display forms

#let CITE-FORM = (
  prose: "prose",
  author: "author",
  year: "year",
  full: "full",
)

// =============================================================================
// Style Classes
// =============================================================================
// CSL style class types

#let STYLE-CLASS = (
  note: "note",
  in-text: "in-text",
)

// =============================================================================
// Vertical Alignment
// =============================================================================
// Used for superscript/subscript citation styles

#let VERTICAL-ALIGN = (
  sup: "sup",
  sub: "sub",
)
