// =====================
// CONFIGURATION CORE
// =====================
// The package ships defaults (loaded from its bundled config files);
// user projects override them via the #show: noteworthy.with(...) rule
// in main.typ (see init.typ). The resolved configuration lives in a
// document state, so every accessor below is context-only: call it
// from inside a `context` block.

#import "./scheme.typ": schemes

// Package-bundled defaults
#let default-metadata = json("../config/metadata.json")
#let default-constants = json("../config/constants.json")

#let default-config = (
  meta: (
    title: default-metadata.title,
    subtitle: default-metadata.subtitle,
    authors: default-metadata.authors,
    affiliation: default-metadata.affiliation,
    logo: default-metadata.logo,
  ),
  c: (
    font: default-constants.font,
    title-font: default-constants.title-font,
    chapter-name: default-constants.chapter-name,
    subchap-name: default-constants.subchap-name,
    show-solution: default-constants.show-solution,
    solutions-text: default-constants.solutions-text,
    problems-text: default-constants.problems-text,
    box-margin: eval(default-constants.box-margin),
    box-inset: eval(default-constants.box-inset),
    pad-chapter-id: default-constants.pad-chapter-id,
    pad-page-id: default-constants.pad-page-id,
    heading-numbering: default-constants.heading-numbering,
    block-design: default-constants.at("block-design", default: "simple"),
  ),
  theme-name: lower(default-constants.display-mode),
  theme: schemes.at(lower(default-constants.display-mode), default: schemes.at("noteworthy-dark")),
)

#let nw-state = state("noteworthy-config", default-config)

// Context-only accessors
#let nw-config() = nw-state.get().c
#let nw-meta() = nw-state.get().meta
#let nw-theme() = nw-state.get().theme

// =====================
// HELPER FUNCTIONS
// =====================

// Helper: Convert any ID (int or string) to string
#let to-str(id) = if type(id) == int { str(id) } else { id }

// Helper: Zero-pad a number string to a given width
#let zero-pad(s, width) = {
  let s = to-str(s)
  let padding = width - s.len()
  if padding > 0 { "0" * padding + s } else { s }
}

// Helper: Calculate required width for a count (1-9 -> 2, 10-99 -> 2, 100-999 -> 3)
#let calc-width(count) = {
  if count >= 100 { 3 } else { 2 } // Always at least 2 digits for cleaner look
}

// Helper: Format chapter ID for display with dynamic padding (context-only)
#let format-chapter-id(id, total-chapters) = {
  if not nw-config().pad-chapter-id { return to-str(id) }
  let width = calc-width(total-chapters)
  zero-pad(to-str(id), width)
}

// Helper: Format page ID for display with dynamic padding (context-only)
#let format-page-id(id, total-pages-in-chapter, total-chapters) = {
  let s = to-str(id)
  if not nw-config().pad-page-id { return s }

  let ch-width = calc-width(total-chapters)
  let pg-width = calc-width(total-pages-in-chapter)

  if "." in s {
    let parts = s.split(".")
    zero-pad(parts.at(0), ch-width) + "." + zero-pad(parts.at(1), pg-width)
  } else {
    // Single ID like "1" -> "01.01" (chapter.first-page)
    zero-pad(s, ch-width) + "." + zero-pad("1", pg-width)
  }
}

// Helper: Extract chapter ID from page ID (supports int or string, with or without dot)
#let get-chapter-id(id) = {
  let s = to-str(id)
  if "." in s { s.split(".").at(0) } else { s }
}
