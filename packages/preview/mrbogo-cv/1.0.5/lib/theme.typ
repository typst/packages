// Theme configuration - colors, fonts, and constants
// Internalized from neat-cv with custom color palette

#import "@preview/fontawesome:0.6.0": fa-icon

// === Global State ===
// Theme and author state for cross-component access
#let __st-theme = state("theme")
#let __st-author = state("author")

// === Color Palette ===
#let color-dark = rgb("#1e3d58")      // Header background
#let color-primary = rgb("#057dcd")   // Titles, subtitles, graphic elements
#let color-secondary = rgb("#43b0f1") // Dates, periods, locations
#let color-light = rgb("#e8eef1")     // Light accents

// === Constants ===
#let SIDE_CONTENT_FONT_SIZE_SCALE = 0.72
#let FOOTER_FONT_SIZE_SCALE = 0.7
#let HEADER_BODY_GAP = 2mm
#let HORIZONTAL_PAGE_MARGIN = 12mm
#let PAGE_MARGIN = (
  left: HORIZONTAL_PAGE_MARGIN,
  right: HORIZONTAL_PAGE_MARGIN,
  top: HORIZONTAL_PAGE_MARGIN - HEADER_BODY_GAP,
  bottom: HORIZONTAL_PAGE_MARGIN,
)
#let LEVEL_BAR_GAP_SIZE = 2pt
#let LEVEL_BAR_BOX_HEIGHT = 3.5pt
#let ENTRY_LEFT_COLUMN_WIDTH = 5.7em

// === Utility ===
#let __stroke_length(x) = x * 1pt

// === Section Heading Style ===
// Reduces vertical space before level-1 headings
#let heading-style(doc) = {
  show heading.where(level: 1): set block(above: 0.6em, below: 0.5em)
  doc
}

// === Introduction Section Style ===
#let introduction(content) = {
  block(above: 1em)[
    #set par(first-line-indent: 1em)
    #set text(size: 0.8em)
    #content
  ]
}

// === Side Block Style ===
// Styled block for sidebar skill sections
#let side-block(title, first: false, content) = {
  block(breakable: false, above: if first { 0em } else { 0.8em })[
    #text(fill: color-primary, weight: "semibold")[#title]
    #content
  ]
}
