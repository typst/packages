// ===================================================================
// BYPST — CONFIGURATION (colors, fonts, sizes, spacing)
// Branding and tuning constants. No dependencies; imported by the
// other theme modules.
// ===================================================================

// ===================================================================
// INSTITUTIONAL SHORTCUTS
// ===================================================================

#let bips-en = [Leibniz Institute for Prevention Research and Epidemiology --- BIPS]
#let bips-de = [Leibniz-Institut für Präventionsforschung und Epidemiologie --- BIPS]

// ===================================================================
// COLOR DEFINITIONS
// ===================================================================

#let bips-blue = rgb(23, 99, 170)
#let bips-logo-blue = rgb(65, 125, 177)
#let bips-text-gray = rgb(66, 66, 66)
#let bips-orange = rgb(250, 133, 55)
#let bips-green = rgb(49, 210, 57)

// ===================================================================
// TYPOGRAPHY CONFIGURATION
// ===================================================================

// Font families (with fallbacks for systems without Fira fonts)
// Fallback chains: preferred → common alternatives → Typst built-in
#let font-family-text = ("Fira Sans", "Noto Sans")
#let font-family-code = ("Fira Mono", "DejaVu Sans Mono")
#let font-family-math = ("New Computer Modern Math",)

// Main content styling
#let font-size-base = 18pt
#let font-color-base = bips-text-gray

#let font-size-small = 14pt

#let font-size-tiny = 12pt
#let font-size-large = 22pt
#let font-size-huge = 26pt

// Em ratios for the size helpers (small/tiny/large/huge), derived from the
// pt sizes above so there is a single source. Used em-relative so the helpers
// scale automatically with base-size and any surrounding text size.
#let font-em-small = font-size-small / font-size-base
#let font-em-tiny = font-size-tiny / font-size-base
#let font-em-large = font-size-large / font-size-base
#let font-em-huge = font-size-huge / font-size-base

// Heading styling (sizes are em-based in show rules, so they scale with base-size)
// h1: 1.11em, h2: 1em, h3: 1em (h3 distinguished by color, not size)
#let heading-color-1 = bips-blue
#let heading-weight-1 = "bold"
#let heading-color-2 = bips-blue
#let heading-weight-2 = "bold"
#let heading-color-3 = bips-text-gray
#let heading-weight-3 = "bold"

// Slide title and subtitle styling
#let font-size-slide-title = 26pt
#let font-size-slide-title-only = 30pt  // Slightly larger when no subtitle
#let font-color-slide-title = bips-blue
#let font-weight-slide-title = 600

// Height of the title area (keeps the divider at a consistent position).
// Tuned with _title-divider-gap so the divider meets the logo's lower edge:
// 1.55cm top margin + 1.6cm + 0.35cm gap = 3.5cm = logo bottom (3cm @ dy 0.5cm).
#let slide-title-area-height = 1.6cm

#let font-size-slide-subtitle = 20pt
#let font-color-slide-subtitle = bips-blue
#let font-weight-slide-subtitle = "regular"

// Title slide styling
#let font-size-title-slide-main = 26pt
#let font-color-title-slide-main = bips-blue
#let font-weight-title-slide-main = 500

#let font-size-title-slide-subtitle = 20pt
#let font-color-title-slide-subtitle = bips-blue
#let font-weight-title-slide-subtitle = 400

#let font-size-title-slide-author = 20pt
#let font-color-title-slide-author = bips-blue
#let font-weight-title-slide-author = 500

#let font-size-title-slide-institute = 18pt
#let font-color-title-slide-institute = bips-text-gray
#let font-weight-title-slide-institute = "regular"

#let font-size-title-slide-date = 16pt
#let font-color-title-slide-date = bips-text-gray
#let font-weight-title-slide-date = "regular"

// Section slide styling
#let font-size-section-slide = 40pt
#let font-color-section-slide = bips-blue
#let font-weight-section-slide = "bold"

// Thanks slide styling
#let font-size-thanks-slide-main = 24pt
#let font-color-thanks-slide-main = bips-blue
#let font-weight-thanks-slide-main = "bold"

#let font-size-thanks-slide-website = 20pt
#let font-color-thanks-slide-website = bips-blue
#let font-weight-thanks-slide-website = "regular"

#let font-size-thanks-slide-contact = 14pt
#let font-color-thanks-slide-contact = bips-text-gray
#let font-weight-thanks-slide-contact = "regular"

// Page number styling
#let font-size-page-number = 18pt
#let font-color-page-number = bips-text-gray
#let font-weight-page-number = "regular"

// Code styling
#let font-scale-code-inline = 1
#let font-scale-code-block = 0.8

// List and enumeration spacing
#let list-spacing = 0.6em
#let enum-spacing = 0.6em

// Emphasis and strong text styling
#let font-color-emphasis = bips-blue
#let font-color-strong = bips-blue
