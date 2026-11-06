// config.typ: Configuration constants and defaults for USAF memorandum template
//
// This module defines core configuration values that implement AFH 33-337 Chapter 14
// formatting requirements for official USAF memorandums.

// =============================================================================
// SPACING CONSTANTS
// =============================================================================
// AFH 33-337 specifies precise spacing requirements throughout Chapter 14

#let spacing = (
  line: .5em,         // Internal line spacing for readability
  line-height: .7em,  // Base line height for spacing calculations
  tab: 0.5in,         // Tab stop for multi-column recipient alignment
  margin: 1in         // AFH 33-337 §4: "Use 1-inch margins on the left, right and bottom"
)

// =============================================================================
// TYPOGRAPHY DEFAULTS
// =============================================================================
// AFH 33-337 §5: "Use 12 point Times New Roman font for text"

#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC",)
#let DEFAULT_BODY_FONTS = ("times new roman", "NimbusRomNo9L")  // AFH 33-337 §5: Times New Roman required
#let LETTERHEAD_COLOR = rgb("#000099")  // Standard USAF blue for letterhead

// =============================================================================
// PARAGRAPH CONFIGURATION
// =============================================================================
// AFH 33-337 "The Text of the Official Memorandum" §2:
// "Number and letter each paragraph and subparagraph"
// Hierarchical numbering: 1., a., (1), (a), etc.

#let paragraph-config = (
  counter-prefix: "par-counter-",
  // AFH 33-337 §2: Hierarchical paragraph numbering format
  // Level 0: 1., 2., 3. | Level 1: a., b., c. | Level 2: (1), (2), (3) | Level 3: (a), (b), (c)
  numbering-formats: ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n))),
  block-indent-state: state("BLOCK_INDENT", true),
)

// =============================================================================
// COUNTERS
// =============================================================================

#let counters = (
  indorsement: counter("indorsement"),
)

// =============================================================================
// CLASSIFICATION COLORS
// =============================================================================
// AFH 33-337 §3: "Follow AFI 31-401, Information Security Program Management,
// applicable executive orders and DoD guidance for the necessary markings on
// classified correspondence."
// Color values follow DoD standard classification marking colors
// Source: https://security.stackexchange.com/questions/161829

#let CLASSIFICATION_COLORS = (
  "UNCLASSIFIED": rgb(0, 122, 51),    // Forest green (#007A33)
  "CONFIDENTIAL": rgb(0, 51, 160),    // Deep blue (#0033A0)
  "SECRET": rgb(200, 16, 46),         // Crimson red (#C8102E)
  "TOP SECRET": rgb(255, 103, 31),    // Burnt orange (#FF671F)
)
