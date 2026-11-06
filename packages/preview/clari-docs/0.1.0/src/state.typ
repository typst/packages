// ============================================================
// clari-slides — Global State Management
// ============================================================
// All mutable presentation settings are stored as Typst
// `state` objects so that they are accessible from any
// context block anywhere in the document.

/// Active primary color (derived from the chosen theme).
#let cs-primary     = state("cs-primary",     rgb("#1A6DB5"))

/// Active accent color (secondary highlight color).
#let cs-accent      = state("cs-accent",      rgb("#5BC0EB"))

/// Default slide background color.
#let cs-back-color  = state("cs-back-color",  white)

/// Whether to show slide numbers in the footer.
#let cs-show-nums   = state("cs-show-nums",   true)

/// Whether to show a progress bar at the bottom of each slide.
#let cs-show-prog   = state("cs-show-prog",   true)

/// Height of the bottom progress bar.
#let cs-prog-height = state("cs-prog-height", 3pt)

/// Active category ("simple" | "math" | "professional" | "allrounder").
#let cs-category    = state("cs-category",    "simple")

/// Base font family.
#let cs-font        = state("cs-font",        "Fira Sans")

/// Base font size.
#let cs-font-size   = state("cs-font-size",   20pt)

/// Registered sections list for TOC generation.
#let cs-sections    = state("cs-sections",    ())

// ============================================================
// Convenience context helpers
// ============================================================

/// Returns the current primary color.
#let _primary()   = context cs-primary.get()
/// Returns the current accent color.
#let _accent()    = context cs-accent.get()
/// Returns the current back color.
#let _back()      = context cs-back-color.get()
/// Returns the current font.
#let _font()      = context cs-font.get()
/// Returns the current category.
#let _category()  = context cs-category.get()
