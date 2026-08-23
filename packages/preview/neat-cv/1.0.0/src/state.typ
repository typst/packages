// Global state for theme and author information
#let __st-theme = state("theme")
#let __st-author = state("author")
#let __st-side-width = state("side-width", 4cm)
#let __st-profile-picture = state("profile-picture", none)

// ---- Constants ----
/// Scaling factor to apply to the body font size to obtain the side-content font size.
#let SIDE_CONTENT_FONT_SIZE_SCALE = 0.72
/// Scaling factor to apply to the body font size to obtain the item-pills font size.
#let ITEM_PILLS_FONT_SIZE_SCALE = 0.85
/// Scaling factor to apply to the body font size to obtain the footer font size.
#let FOOTER_FONT_SIZE_SCALE = 0.7
/// Gap between the header (colored block at the top) and body
#let HEADER_BODY_GAP = 3mm
/// Horizontal page margin
#let HORIZONTAL_PAGE_MARGIN = 12mm
/// Vertical page margin
#let VERTICAL_PAGE_MARGIN = 15mm
/// All page margins, defined explicitly
#let PAGE_MARGIN = (
  left: HORIZONTAL_PAGE_MARGIN,
  right: HORIZONTAL_PAGE_MARGIN,
  top: VERTICAL_PAGE_MARGIN - HEADER_BODY_GAP,
  bottom: VERTICAL_PAGE_MARGIN,
)
/// Length of the gap between individual sections of the level bar
#let LEVEL_BAR_GAP_SIZE = 2pt
/// Height of the box of each individual section in the level bar
#let LEVEL_BAR_BOX_HEIGHT = 3.5pt
/// Width of the left column in an `entry()` or `publication()`
#let ENTRY_LEFT_COLUMN_WIDTH = 5.7em
/// Scaling factor for the date/year left column in entries and publications
#let ENTRY_DATE_FONT_SIZE_SCALE = 0.8
/// Scaling factor for the main content column in entries and publications
#let ENTRY_CONTENT_FONT_SIZE_SCALE = 0.85
/// Width of the thin sidebar variant
#let THIN_SIDE_WIDTH = 1cm


/// Dot separator used between inline items (footer, position list, etc.)
#let DOT_SEPARATOR = box(inset: (x: 0.5em), sym.dot.c)


// ---- Utilities ----
/// Calculate/scale the length of stroke elements, as strokes are visual
/// elements and should have a constant length.
///
/// -> length
#let __stroke_length(x) = x * 1pt
