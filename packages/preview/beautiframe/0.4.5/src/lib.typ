// ═══════════════════════════════════════════════════════════════════════════
// BEAUTIFRAME - Beautiful Theorem-Like Environments for Typst
// ═══════════════════════════════════════════════════════════════════════════

// Import all styles
#import "styles/classic.typ": classic-style
#import "styles/modern.typ": modern-style
#import "styles/elegant.typ": elegant-style
#import "styles/colorful.typ": colorful-style
#import "styles/boxed.typ": boxed-style
#import "styles/minimal.typ": minimal-style
#import "styles/academic.typ": academic-style
#import "styles/cours.typ": cours-style
#import "styles/bw.typ": bw-style

// ═══════════════════════════════════════════════════════════════════════════
// CONFIGURATION STATE
// ═══════════════════════════════════════════════════════════════════════════

#let beautiframe-default-config = (
  style: "classic",

  // ─────────────────────────────────────────────────────────────────────────
  // VARIANT MAPPING
  // Users can assign any variant to any environment type
  // Available variants depend on the style (see style files for options)
  // ─────────────────────────────────────────────────────────────────────────
  theorem-variant: "prominent",
  definition-variant: "standard",
  lemma-variant: "standard",
  proposition-variant: "standard",
  corollary-variant: "standard",
  remark-variant: "subtle",
  example-variant: "accent",

  // ─────────────────────────────────────────────────────────────────────────
  // COLOR PALETTE
  // ─────────────────────────────────────────────────────────────────────────
  primary-color: rgb("#2c3e50"),     // Main text color
  secondary-color: rgb("#7f8c8d"),   // Muted elements
  accent-color: rgb("#2980b9"),      // Highlights and borders
  background-color: white,           // Background for filled styles

  // Which colour a style's non-"accent" variants paint with:
  //   false — the single accent-color (default, uniform look)
  //   true  — each environment's own colour (theorem-color, example-color, …)
  env-colors: false,
  // Resolved per environment before the style is called; styles read this
  // instead of accent-color so that env-colors is honoured everywhere.
  base-color: rgb("#2980b9"),

  // Background tints of filled boxes.
  //   auto — lighten each colour until it reaches background-lightness, so a
  //          yellow and a green tint read equally strong
  //   a ratio (e.g. 92%) — lighten every colour by that fixed amount
  background-tint: auto,
  background-lightness: 0.93,        // target perceived lightness, 0..1

  // Ink of the environment header text:
  //   auto     — each style's own choice (mostly black or primary-color)
  //   "base"   — follow base-color, i.e. the accent or the environment colour
  //   a colour — that colour, in every style
  label-color: auto,

  // Per-environment colors (can be used by colorful style or any style)
  theorem-color: rgb("#c0392b"),     // Red - strong, important
  definition-color: rgb("#2980b9"),  // Blue - foundational
  lemma-color: rgb("#8e44ad"),       // Purple - supporting
  proposition-color: rgb("#8e44ad"), // Purple - same as lemma
  corollary-color: rgb("#d35400"),   // Orange - follows from theorem
  remark-color: rgb("#7f8c8d"),      // Gray - commentary
  example-color: rgb("#27ae60"),     // Green - practical

  // ─────────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY
  // ─────────────────────────────────────────────────────────────────────────
  label-size: 1em,                   // Size for "Theorem", "Definition", etc. (1em = body font size)
  label-weight: "bold",              // Weight for labels
  name-style: "italic",              // Style for theorem names
  body-size: none,                   // Inherit from document

  // ─────────────────────────────────────────────────────────────────────────
  // SPACING (Vertical)
  // ─────────────────────────────────────────────────────────────────────────
  // Per-environment spacing (before/after the entire block)
  theorem-above: 1em,
  theorem-below: 0.8em,
  definition-above: 1em,
  definition-below: 0.8em,
  lemma-above: 0.8em,
  lemma-below: 0.6em,
  proposition-above: 0.8em,
  proposition-below: 0.6em,
  corollary-above: 0.8em,
  corollary-below: 0.6em,
  remark-above: 0.6em,
  remark-below: 0.6em,
  example-above: 0.8em,
  example-below: 0.8em,
  proof-above: 0.5em,
  proof-below: 0.8em,

  // Internal spacing (within environments)
  header-gap: 0.3em,                 // Gap between header and body

  // ─────────────────────────────────────────────────────────────────────────
  // SPACING (Horizontal) / MARGINS
  // ─────────────────────────────────────────────────────────────────────────
  inset: (x: 0.8em, y: 0.6em),      // Padding inside boxes
  border-width: 1pt,                 // Border/stroke thickness
  border-radius: 0pt,                // Rounded corners (for boxed style)
  line-position: 2cm,                // Position of vertical line from left (classic style)
  label-extra: 1cm,                  // Extra space for labels into left margin (classic style)

  // ─────────────────────────────────────────────────────────────────────────
  // NUMBERING
  // ─────────────────────────────────────────────────────────────────────────
  numbering-format: "1",             // "1" or "1.1" for section.number
  // Prefix env numbers with the heading number, LaTeX \numberwithin style.
  // false = plain "Theorem 3"; true = one heading level ("Theorem 2.3");
  // an integer N = first N heading levels ("Theorem 2.1.3" for N = 2).
  // Applies to built-in AND new-env custom environments.
  link-to-section: false,

  // Counter reset behavior: "manual" (default) keeps counting across the
  // document; "section" restarts each env counter after every heading up to
  // the link-to-section depth (level 1 when link-to-section is off).
  counter-reset: "manual",           // "manual", "section"

  // ─────────────────────────────────────────────────────────────────────────
  // LABELS (English default) - Singular
  // ─────────────────────────────────────────────────────────────────────────
  theorem-label: "Theorem",
  definition-label: "Definition",
  lemma-label: "Lemma",
  proposition-label: "Proposition",
  corollary-label: "Corollary",
  remark-label: "Remark",
  example-label: "Example",
  proof-label: "Proof",

  // ─────────────────────────────────────────────────────────────────────────
  // LABELS - Plural (used when plural: true)
  // ─────────────────────────────────────────────────────────────────────────
  theorem-plural: "Theorems",
  definition-plural: "Definitions",
  lemma-plural: "Lemmas",
  proposition-plural: "Propositions",
  corollary-plural: "Corollaries",
  remark-plural: "Remarks",
  example-plural: "Examples",

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER LAYOUT
  // Which half of "Remark (What is analysis?)" carries the emphasis.
  //   "label-first"  — Remark 2 (What is analysis?)     [default]
  //   "title-first"  — What is analysis? (Remark 2)
  //   "title-abbrev" — What is analysis? (Rem 2)
  //   "title-only"   — What is analysis?
  //   "prefix"       — Rem 2: What is analysis?
  // Only applies when the environment has a name/title; otherwise the label
  // is rendered as usual.
  // ─────────────────────────────────────────────────────────────────────────
  header-layout: "label-first",      // "label-first" | "title-first"
                                     // "title-abbrev" | "title-only" | "prefix"
  label-abbrev: false,               // demote to the short forms below
  prefix-separator: ":",             // separator used by the "prefix" layout

  // ─────────────────────────────────────────────────────────────────────────
  // LABELS - Abbreviated (used when label-abbrev: true)
  // ─────────────────────────────────────────────────────────────────────────
  theorem-abbrev: "Thm",
  definition-abbrev: "Def",
  lemma-abbrev: "Lem",
  proposition-abbrev: "Prop",
  corollary-abbrev: "Cor",
  remark-abbrev: "Rem",
  example-abbrev: "Ex",
  proof-abbrev: "Pf",

  // ─────────────────────────────────────────────────────────────────────────
  // QED / PROOF
  // ─────────────────────────────────────────────────────────────────────────
  qed-symbol: text(size: 1.4em, sym.square.stroked),    // □ or ■ or ∎

  // ─────────────────────────────────────────────────────────────────────────
  // ADVANCED
  // ─────────────────────────────────────────────────────────────────────────
  breakable: true,                   // Allow page breaks within envs

  // ─────────────────────────────────────────────────────────────────────────
  // QR SIDEBAR
  // Optional renderer function: url => content. When set, passing qr: "url"
  // to any environment places rendered content in a right sidebar.
  // ─────────────────────────────────────────────────────────────────────────
  qr-renderer: none,                 // url => content, or none to disable
  qr-width: 1.85cm,                  // Width of the QR sidebar column

  // ─────────────────────────────────────────────────────────────────────────
  // COLOR MODE (Print-friendly options)
  // ─────────────────────────────────────────────────────────────────────────
  color-mode: "color",               // "color", "grayscale", "bw"

  // ─────────────────────────────────────────────────────────────────────────
  // WORKED EXERCISES
  // ─────────────────────────────────────────────────────────────────────────
  instructor-mode: false,             // Show instructor-only correction content
  correction-label: "Correction",     // Default correction title
  correction-renderer: none,          // (title, body) => content, or none

  // ─────────────────────────────────────────────────────────────────────────
  // TROUS (student fill-in blanks)
  // A trou carries the content the class produces live: it prints as reserved
  // space in the student build and as the content itself in the instructor
  // build (instructor-mode: true).
  // ─────────────────────────────────────────────────────────────────────────
  trou-fill: "empty",                 // "empty" | "lines" | "grid"
  trou-scale: 2.0,                    // handwriting factor applied to the
                                      // measured height: a student's hand needs
                                      // about twice the height of typeset text
  trou-line-gap: 8mm,                 // ruling pitch, also the quantum the
                                      // reserved height snaps to for "lines"
  trou-frame: true,                   // frame the reserved space
  trou-color: luma(65%),              // ink of rules and frame (student build)
  trou-padding: 0.6em,                // breathing room over the measured height
  trou-min-height: 1cm,               // never reserve less than this
  trou-max-height: none,              // cap the reserved height (none = uncapped)
  trou-hint-size: 8pt,                // size of the optional hint text
  trou-mark-instructor: true,         // flag filled content in the instructor build
  trou-mark-color: none,              // none = accent-color
)

#let beautiframe-config = state("beautiframe-config", beautiframe-default-config)

// Restores every setting to its default value. Configuration is global and
// cumulative, so this is the way back after a style, a preset or a theme has
// been applied — chapters of a document can then start from a known state.
#let beautiframe-reset-config() = beautiframe-config.update(beautiframe-default-config)

#let beautiframe-ref-state = state("beautiframe-refs", (:))

// Depth of environment nesting, so a trou knows whether it sits inside an
// environment body (where label-column layouts must not be re-applied).
#let _trou-depth = state("beautiframe-trou-depth", 0)
#let beautiframe-page-counter = counter(page)

// ═══════════════════════════════════════════════════════════════════════════
// STYLE REGISTRY
// ═══════════════════════════════════════════════════════════════════════════

#let styles = (
  classic: classic-style,
  modern: modern-style,
  elegant: elegant-style,
  colorful: colorful-style,
  boxed: boxed-style,
  minimal: minimal-style,
  academic: academic-style,
  cours: cours-style,
  bw: bw-style,
)

// ═══════════════════════════════════════════════════════════════════════════
// COUNTERS (Independent for each environment type)
// ═══════════════════════════════════════════════════════════════════════════

#let theorem-counter = counter("beautiframe-theorem")
#let definition-counter = counter("beautiframe-definition")
#let lemma-counter = counter("beautiframe-lemma")
#let proposition-counter = counter("beautiframe-proposition")
#let corollary-counter = counter("beautiframe-corollary")
#let remark-counter = counter("beautiframe-remark")
#let example-counter = counter("beautiframe-example")

// Get counter for a given environment type
#let get-counter(env-type) = {
  if env-type == "theorem" { theorem-counter }
  else if env-type == "definition" { definition-counter }
  else if env-type == "lemma" { lemma-counter }
  else if env-type == "proposition" { proposition-counter }
  else if env-type == "corollary" { corollary-counter }
  else if env-type == "remark" { remark-counter }
  else if env-type == "example" { example-counter }
  else { none }
}

// Manual reset function
#let beautiframe-reset() = {
  theorem-counter.update(0)
  definition-counter.update(0)
  lemma-counter.update(0)
  proposition-counter.update(0)
  corollary-counter.update(0)
  remark-counter.update(0)
  example-counter.update(0)
}

// ═══════════════════════════════════════════════════════════════════════════
// COLOR PROCESSING (for grayscale/bw modes)
// ═══════════════════════════════════════════════════════════════════════════

#let process-color(color, cfg) = {
  if cfg.color-mode == "bw" {
    // Pure black and white
    let comps = color.components()
    let r = if type(comps.at(0)) == ratio { comps.at(0) / 100% } else { comps.at(0) / 255 }
    let g = if type(comps.at(1)) == ratio { comps.at(1) / 100% } else { comps.at(1) / 255 }
    let b = if type(comps.at(2)) == ratio { comps.at(2) / 100% } else { comps.at(2) / 255 }
    let lum = r * 0.299 + g * 0.587 + b * 0.114
    if lum > 0.5 { white } else { black }
  } else if cfg.color-mode == "grayscale" {
    // Convert to grayscale
    let comps = color.components()
    let r = if type(comps.at(0)) == ratio { comps.at(0) / 100% } else { comps.at(0) / 255 }
    let g = if type(comps.at(1)) == ratio { comps.at(1) / 100% } else { comps.at(1) / 255 }
    let b = if type(comps.at(2)) == ratio { comps.at(2) / 100% } else { comps.at(2) / 255 }
    let lum = r * 0.299 + g * 0.587 + b * 0.114
    luma(int(lum * 100) * 1%)
  } else {
    // Full color
    color
  }
}

// Get environment-specific color
#let get-env-color(env-type, cfg) = {
  let color = if env-type == "theorem" { cfg.theorem-color }
  else if env-type == "definition" { cfg.definition-color }
  else if env-type == "lemma" { cfg.lemma-color }
  else if env-type == "proposition" { cfg.proposition-color }
  else if env-type == "corollary" { cfg.corollary-color }
  else if env-type == "remark" { cfg.remark-color }
  else if env-type == "example" { cfg.example-color }
  else { cfg.accent-color }
  process-color(color, cfg)
}

// Relative luminance of a colour, 0 (black) to 1 (white)
#let relative-luminance(color) = {
  let comps = color.components()
  let chan(c) = if type(c) == ratio { c / 100% } else { c / 255 }
  let r = chan(comps.at(0))
  let g = chan(comps.at(1))
  let b = chan(comps.at(2))
  r * 0.299 + g * 0.587 + b * 0.114
}

// Lighten a colour until it reaches the configured target lightness, so that
// tints of a dark green and a bright yellow read with the same strength.
// A dark colour gets lightened a lot, a light one barely at all.
#let perceptual-tint(color, cfg) = {
  if cfg.background-tint != auto {
    color.lighten(cfg.background-tint)
  } else {
    let l = relative-luminance(color)
    let target = cfg.background-lightness
    let t = if l >= target { 0.0 } else { (target - l) / (1.0 - l) }
    color.lighten(calc.min(t, 1.0) * 100%)
  }
}

// Get background color for filled boxes (B&W aware)
#let get-background-color(base-color, cfg) = {
  if cfg.color-mode == "bw" {
    white  // No background in B&W mode
  } else if cfg.color-mode == "grayscale" {
    luma(95%)  // Very light gray
  } else {
    perceptual-tint(base-color, cfg)
  }
}

// Get accent color (B&W aware)
#let get-accent-color(cfg) = {
  process-color(cfg.accent-color, cfg)
}

// Get secondary color (B&W aware)
#let get-secondary-color(cfg) = {
  process-color(cfg.secondary-color, cfg)
}

// Get environment label
#let get-env-label(env-type, cfg) = {
  if env-type == "theorem" { cfg.theorem-label }
  else if env-type == "definition" { cfg.definition-label }
  else if env-type == "lemma" { cfg.lemma-label }
  else if env-type == "proposition" { cfg.proposition-label }
  else if env-type == "corollary" { cfg.corollary-label }
  else if env-type == "remark" { cfg.remark-label }
  else if env-type == "example" { cfg.example-label }
  else if env-type == "proof" { cfg.proof-label }
  else { env-type }
}

// Get the abbreviated environment label (none when the type has no short form)
#let get-env-abbrev(env-type, cfg) = {
  if env-type == "theorem" { cfg.theorem-abbrev }
  else if env-type == "definition" { cfg.definition-abbrev }
  else if env-type == "lemma" { cfg.lemma-abbrev }
  else if env-type == "proposition" { cfg.proposition-abbrev }
  else if env-type == "corollary" { cfg.corollary-abbrev }
  else if env-type == "remark" { cfg.remark-abbrev }
  else if env-type == "example" { cfg.example-abbrev }
  else if env-type == "proof" { cfg.proof-abbrev }
  else { none }
}

// Redistribute (label, name, number) according to header-layout, so that every
// style picks up the swap without knowing about it: styles keep rendering
// "title" prominently and "name" as the secondary, parenthesised half.
#let _apply-header-layout(cfg, env-type, label-text, name, num) = {
  if cfg.header-layout == "label-first" or name == none {
    (label-text, name, num)
  } else {
    // Abbreviate only the standard singular label: plural forms and custom
    // environment labels are left alone.
    let short = get-env-abbrev(env-type, cfg)
    let base = if cfg.label-abbrev and short != none and label-text == get-env-label(env-type, cfg) {
      short
    } else {
      label-text
    }
    let demoted = if num == none { [#base] } else { [#base #num] }

    if cfg.header-layout == "title-first" {
      // What is analysis? (Remark 2)
      (name, demoted, none)
    } else if cfg.header-layout == "title-only" {
      // What is analysis?  — the label and its number are dropped from the
      // header. The counter still advances, so env-ref keeps working.
      (name, none, none)
    } else if cfg.header-layout == "title-abbrev" {
      // What is analysis? (Rem 2)  — like title-first, but the label is always
      // abbreviated, whatever label-abbrev says.
      let short = get-env-abbrev(env-type, cfg)
      let abbrev = if short != none and label-text == get-env-label(env-type, cfg) { short } else { label-text }
      (name, if num == none { [#abbrev] } else { [#abbrev #num] }, none)
    } else {
      // Rem 2: What is analysis?  — the prefix stays light, the title carries
      // the label weight applied by the style
      ([#text(weight: "regular")[#demoted#cfg.prefix-separator]#h(0.35em)#name], none, none)
    }
  }
}

// Get environment variant
#let get-env-variant(env-type, cfg) = {
  if env-type == "theorem" { cfg.theorem-variant }
  else if env-type == "definition" { cfg.definition-variant }
  else if env-type == "lemma" { cfg.lemma-variant }
  else if env-type == "proposition" { cfg.proposition-variant }
  else if env-type == "corollary" { cfg.corollary-variant }
  else if env-type == "remark" { cfg.remark-variant }
  else if env-type == "example" { cfg.example-variant }
  else { "standard" }
}

// Get environment spacing
#let get-env-spacing(env-type, cfg) = {
  if env-type == "theorem" { (above: cfg.theorem-above, below: cfg.theorem-below) }
  else if env-type == "definition" { (above: cfg.definition-above, below: cfg.definition-below) }
  else if env-type == "lemma" { (above: cfg.lemma-above, below: cfg.lemma-below) }
  else if env-type == "proposition" { (above: cfg.proposition-above, below: cfg.proposition-below) }
  else if env-type == "corollary" { (above: cfg.corollary-above, below: cfg.corollary-below) }
  else if env-type == "remark" { (above: cfg.remark-above, below: cfg.remark-below) }
  else if env-type == "example" { (above: cfg.example-above, below: cfg.example-below) }
  else if env-type == "proof" { (above: cfg.proof-above, below: cfg.proof-below) }
  else { (above: 0.8em, below: 0.6em) }
}

// ═══════════════════════════════════════════════════════════════════════════
// SETUP FUNCTION
// ═══════════════════════════════════════════════════════════════════════════

#let beautiframe-setup(
  style: none,
  // Variant mapping
  // default-variant sets all variants at once; individual params override it
  default-variant: none,
  theorem-variant: none,
  definition-variant: none,
  lemma-variant: none,
  proposition-variant: none,
  corollary-variant: none,
  remark-variant: none,
  example-variant: none,
  // Colors
  primary-color: none,
  secondary-color: none,
  accent-color: none,
  background-color: none,
  env-colors: none,
  label-color: none,
  background-tint: none,
  background-lightness: none,
  theorem-color: none,
  definition-color: none,
  lemma-color: none,
  proposition-color: none,
  corollary-color: none,
  remark-color: none,
  example-color: none,
  // Typography
  label-size: none,
  label-weight: none,
  name-style: none,
  body-size: none,
  // Spacing (vertical)
  theorem-above: none,
  theorem-below: none,
  definition-above: none,
  definition-below: none,
  lemma-above: none,
  lemma-below: none,
  proposition-above: none,
  proposition-below: none,
  corollary-above: none,
  corollary-below: none,
  remark-above: none,
  remark-below: none,
  example-above: none,
  example-below: none,
  proof-above: none,
  proof-below: none,
  header-gap: none,
  // Spacing (horizontal)
  inset: none,
  border-width: none,
  border-radius: none,
  line-position: none,
  label-extra: none,
  // Numbering
  numbering-format: none,
  link-to-section: none,
  counter-reset: none,
  // Labels (singular)
  theorem-label: none,
  definition-label: none,
  lemma-label: none,
  proposition-label: none,
  corollary-label: none,
  remark-label: none,
  example-label: none,
  proof-label: none,
  // Labels (plural)
  theorem-plural: none,
  definition-plural: none,
  lemma-plural: none,
  proposition-plural: none,
  corollary-plural: none,
  remark-plural: none,
  example-plural: none,
  // Header layout
  header-layout: none,
  label-abbrev: none,
  prefix-separator: none,
  // Labels (abbreviated)
  theorem-abbrev: none,
  definition-abbrev: none,
  lemma-abbrev: none,
  proposition-abbrev: none,
  corollary-abbrev: none,
  remark-abbrev: none,
  example-abbrev: none,
  proof-abbrev: none,
  // QED
  qed-symbol: none,
  // Advanced
  breakable: none,
  // Color mode
  color-mode: none,
  // Worked exercises
  instructor-mode: none,
  correction-label: none,
  correction-renderer: none,
  // Trous
  trou-fill: none,
  trou-scale: none,
  trou-line-gap: none,
  trou-frame: none,
  trou-color: none,
  trou-padding: none,
  trou-min-height: none,
  trou-max-height: none,
  trou-hint-size: none,
  trou-mark-instructor: none,
  trou-mark-color: none,
  // QR sidebar
  qr-renderer: none,
  qr-width: none,
) = {
  beautiframe-config.update(cfg => {
    let new-cfg = cfg
    if style != none { new-cfg.insert("style", style) }
    // Variant mapping — default-variant first, then individual overrides win
    if default-variant != none {
      new-cfg.insert("theorem-variant",     default-variant)
      new-cfg.insert("definition-variant",  default-variant)
      new-cfg.insert("lemma-variant",       default-variant)
      new-cfg.insert("proposition-variant", default-variant)
      new-cfg.insert("corollary-variant",   default-variant)
      new-cfg.insert("remark-variant",      default-variant)
      new-cfg.insert("example-variant",     default-variant)
    }
    if theorem-variant != none { new-cfg.insert("theorem-variant", theorem-variant) }
    if definition-variant != none { new-cfg.insert("definition-variant", definition-variant) }
    if lemma-variant != none { new-cfg.insert("lemma-variant", lemma-variant) }
    if proposition-variant != none { new-cfg.insert("proposition-variant", proposition-variant) }
    if corollary-variant != none { new-cfg.insert("corollary-variant", corollary-variant) }
    if remark-variant != none { new-cfg.insert("remark-variant", remark-variant) }
    if example-variant != none { new-cfg.insert("example-variant", example-variant) }
    // Colors
    if primary-color != none { new-cfg.insert("primary-color", primary-color) }
    if secondary-color != none { new-cfg.insert("secondary-color", secondary-color) }
    if accent-color != none { new-cfg.insert("accent-color", accent-color) }
    if background-color != none { new-cfg.insert("background-color", background-color) }
    if env-colors != none { new-cfg.insert("env-colors", env-colors) }
    if label-color != none { new-cfg.insert("label-color", label-color) }
    if background-tint != none { new-cfg.insert("background-tint", background-tint) }
    if background-lightness != none { new-cfg.insert("background-lightness", background-lightness) }
    if theorem-color != none { new-cfg.insert("theorem-color", theorem-color) }
    if definition-color != none { new-cfg.insert("definition-color", definition-color) }
    if lemma-color != none { new-cfg.insert("lemma-color", lemma-color) }
    if proposition-color != none { new-cfg.insert("proposition-color", proposition-color) }
    if corollary-color != none { new-cfg.insert("corollary-color", corollary-color) }
    if remark-color != none { new-cfg.insert("remark-color", remark-color) }
    if example-color != none { new-cfg.insert("example-color", example-color) }
    // Typography
    if label-size != none { new-cfg.insert("label-size", label-size) }
    if label-weight != none { new-cfg.insert("label-weight", label-weight) }
    if name-style != none { new-cfg.insert("name-style", name-style) }
    if body-size != none { new-cfg.insert("body-size", body-size) }
    // Spacing (vertical)
    if theorem-above != none { new-cfg.insert("theorem-above", theorem-above) }
    if theorem-below != none { new-cfg.insert("theorem-below", theorem-below) }
    if definition-above != none { new-cfg.insert("definition-above", definition-above) }
    if definition-below != none { new-cfg.insert("definition-below", definition-below) }
    if lemma-above != none { new-cfg.insert("lemma-above", lemma-above) }
    if lemma-below != none { new-cfg.insert("lemma-below", lemma-below) }
    if proposition-above != none { new-cfg.insert("proposition-above", proposition-above) }
    if proposition-below != none { new-cfg.insert("proposition-below", proposition-below) }
    if corollary-above != none { new-cfg.insert("corollary-above", corollary-above) }
    if corollary-below != none { new-cfg.insert("corollary-below", corollary-below) }
    if remark-above != none { new-cfg.insert("remark-above", remark-above) }
    if remark-below != none { new-cfg.insert("remark-below", remark-below) }
    if example-above != none { new-cfg.insert("example-above", example-above) }
    if example-below != none { new-cfg.insert("example-below", example-below) }
    if proof-above != none { new-cfg.insert("proof-above", proof-above) }
    if proof-below != none { new-cfg.insert("proof-below", proof-below) }
    if header-gap != none { new-cfg.insert("header-gap", header-gap) }
    // Spacing (horizontal)
    if inset != none { new-cfg.insert("inset", inset) }
    if border-width != none { new-cfg.insert("border-width", border-width) }
    if border-radius != none { new-cfg.insert("border-radius", border-radius) }
    if line-position != none { new-cfg.insert("line-position", line-position) }
    if label-extra != none { new-cfg.insert("label-extra", label-extra) }
    // Numbering
    if numbering-format != none { new-cfg.insert("numbering-format", numbering-format) }
    if link-to-section != none { new-cfg.insert("link-to-section", link-to-section) }
    if counter-reset != none { new-cfg.insert("counter-reset", counter-reset) }
    // Labels (singular)
    if theorem-label != none { new-cfg.insert("theorem-label", theorem-label) }
    if definition-label != none { new-cfg.insert("definition-label", definition-label) }
    if lemma-label != none { new-cfg.insert("lemma-label", lemma-label) }
    if proposition-label != none { new-cfg.insert("proposition-label", proposition-label) }
    if corollary-label != none { new-cfg.insert("corollary-label", corollary-label) }
    if remark-label != none { new-cfg.insert("remark-label", remark-label) }
    if example-label != none { new-cfg.insert("example-label", example-label) }
    if proof-label != none { new-cfg.insert("proof-label", proof-label) }
    // Labels (plural)
    if theorem-plural != none { new-cfg.insert("theorem-plural", theorem-plural) }
    if definition-plural != none { new-cfg.insert("definition-plural", definition-plural) }
    if lemma-plural != none { new-cfg.insert("lemma-plural", lemma-plural) }
    if proposition-plural != none { new-cfg.insert("proposition-plural", proposition-plural) }
    if corollary-plural != none { new-cfg.insert("corollary-plural", corollary-plural) }
    if remark-plural != none { new-cfg.insert("remark-plural", remark-plural) }
    if example-plural != none { new-cfg.insert("example-plural", example-plural) }
    // Header layout
    if header-layout != none { new-cfg.insert("header-layout", header-layout) }
    if label-abbrev != none { new-cfg.insert("label-abbrev", label-abbrev) }
    if prefix-separator != none { new-cfg.insert("prefix-separator", prefix-separator) }
    // Labels (abbreviated)
    if theorem-abbrev != none { new-cfg.insert("theorem-abbrev", theorem-abbrev) }
    if definition-abbrev != none { new-cfg.insert("definition-abbrev", definition-abbrev) }
    if lemma-abbrev != none { new-cfg.insert("lemma-abbrev", lemma-abbrev) }
    if proposition-abbrev != none { new-cfg.insert("proposition-abbrev", proposition-abbrev) }
    if corollary-abbrev != none { new-cfg.insert("corollary-abbrev", corollary-abbrev) }
    if remark-abbrev != none { new-cfg.insert("remark-abbrev", remark-abbrev) }
    if example-abbrev != none { new-cfg.insert("example-abbrev", example-abbrev) }
    if proof-abbrev != none { new-cfg.insert("proof-abbrev", proof-abbrev) }
    // QED
    if qed-symbol != none { new-cfg.insert("qed-symbol", qed-symbol) }
    // Advanced
    if breakable != none { new-cfg.insert("breakable", breakable) }
    // Color mode
    if color-mode != none { new-cfg.insert("color-mode", color-mode) }
    // Worked exercises
    if instructor-mode != none { new-cfg.insert("instructor-mode", instructor-mode) }
    if correction-label != none { new-cfg.insert("correction-label", correction-label) }
    if correction-renderer != none { new-cfg.insert("correction-renderer", correction-renderer) }
    // Trous
    if trou-fill != none { new-cfg.insert("trou-fill", trou-fill) }
    if trou-scale != none { new-cfg.insert("trou-scale", trou-scale) }
    if trou-line-gap != none { new-cfg.insert("trou-line-gap", trou-line-gap) }
    if trou-frame != none { new-cfg.insert("trou-frame", trou-frame) }
    if trou-color != none { new-cfg.insert("trou-color", trou-color) }
    if trou-padding != none { new-cfg.insert("trou-padding", trou-padding) }
    if trou-min-height != none { new-cfg.insert("trou-min-height", trou-min-height) }
    if trou-max-height != none { new-cfg.insert("trou-max-height", trou-max-height) }
    if trou-hint-size != none { new-cfg.insert("trou-hint-size", trou-hint-size) }
    if trou-mark-instructor != none { new-cfg.insert("trou-mark-instructor", trou-mark-instructor) }
    if trou-mark-color != none { new-cfg.insert("trou-mark-color", trou-mark-color) }
    // QR sidebar
    if qr-renderer != none { new-cfg.insert("qr-renderer", qr-renderer) }
    if qr-width != none { new-cfg.insert("qr-width", qr-width) }
    new-cfg
  })
}

// ═══════════════════════════════════════════════════════════════════════════
// INITIALIZATION (for auto counter reset)
// ═══════════════════════════════════════════════════════════════════════════

#let beautiframe-init(doc) = {
  doc
}

// ═══════════════════════════════════════════════════════════════════════════
// STUDENT FILL SPACE
// ═══════════════════════════════════════════════════════════════════════════

// Generate fill space appended inside an environment.
// space: "empty" | "lines" | "grid"
// height: total height of the fill area
#let _fill-space(space, height) = {
  if space == "empty" {
    block(width: 100%, height: height)[]
  } else if space == "lines" {
    let gap = 8mm
    let n = calc.ceil(height / gap) + 1
    block(width: 100%, height: height, clip: true, breakable: false)[
      #set par(spacing: 0pt, leading: 0pt)
      #set block(spacing: 0pt)
      #for _ in range(n) {
        v(gap - 0.5pt)
        line(length: 100%, stroke: 0.4pt + luma(72%))
      }
    ]
  } else if space == "grid" {
    block(
      width: 100%, height: height, clip: true,
      fill: tiling(size: (5mm, 5mm))[
        #place(dx: 2.5mm, dy: 2.5mm,
          circle(radius: 0.55pt, fill: luma(72%)))
      ],
    )[]
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION-LINKED NUMBERING
// ═══════════════════════════════════════════════════════════════════════════

// Heading-prefix depth: 0 = disabled, true = 1 level, integer = N levels.
#let _section-depth(cfg) = {
  if cfg.link-to-section == true { 1 }
  else if type(cfg.link-to-section) == int { calc.max(0, cfg.link-to-section) }
  else { 0 }
}

// Selector matching every heading that restarts env numbering (level <= depth).
#let _reset-selector(depth) = {
  let sel = heading.where(level: 1)
  for l in range(2, depth + 1) { sel = sel.or(heading.where(level: l)) }
  sel
}

// Counter value consumed before the current section started (0 outside sections).
// Must be called inside a context block.
#let _section-base(ctr, loc, depth) = {
  let hs = query(selector(_reset-selector(depth)).before(loc))
  if hs.len() == 0 { 0 } else { ctr.at(hs.last().location()).first() }
}

// Number shown for the env: the raw count, minus what earlier sections consumed
// when counter-reset is "section". Must be called inside a context block.
#let _env-shown-val(cfg, ctr, val, loc) = {
  if cfg.counter-reset == "section" {
    val - _section-base(ctr, loc, calc.max(_section-depth(cfg), 1))
  } else { val }
}

// Render the shown number with its heading prefix ("2.1.3") as a string.
// Must be called inside a context block.
#let _format-env-number(cfg, shown, loc) = {
  let depth = _section-depth(cfg)
  if depth > 0 {
    let h = counter(heading).at(loc)
    let levels = h.slice(0, calc.min(depth, h.len())).map(str)
    if levels.len() > 0 { levels.join(".") + "." + str(shown) } else { str(shown) }
  } else { str(shown) }
}

// ═══════════════════════════════════════════════════════════════════════════
// CORE ENVIRONMENT FUNCTION
// ═══════════════════════════════════════════════════════════════════════════

#let _env-render(
  type: "theorem",
  name: none,
  number: auto,
  ref-number: auto,
  label: none,
  display-label: none,
  color: none,
  qr: none,
  instructor: false,
  // Counter override (used by new-env custom environments); none = the
  // built-in counter for `type`.
  counter: none,
  // Student fill space appended inside the environment.
  // space: none (default) | "empty" | "lines" | "grid"
  // space-height: height of the fill area
  space: none,
  space-height: 3cm,
  body,
) = context {
  let cfg = beautiframe-config.get()
  if instructor and not cfg.instructor-mode {
    return none
  }
  let style-dict = styles.at(cfg.style)

  // Get label text
  let label-text = if display-label != none { display-label } else { get-env-label(type, cfg) }

  // Get variant for this environment type
  let variant = get-env-variant(type, cfg)

  // Get environment color
  let env-color = if color != none { process-color(color, cfg) } else { get-env-color(type, cfg) }

  // Wrap body with QR sidebar if a renderer is configured
  let body = if qr != none and cfg.qr-renderer != none {
    grid(
      columns: (1fr, cfg.qr-width),
      column-gutter: 0.35cm,
      align: top,
      body,
      (cfg.qr-renderer)(qr),
    )
  } else { body }

  // Append student fill space if requested
  let body = if space != none {
    [#body#_fill-space(space, space-height)]
  } else { body }

  // Mark the body as environment-internal for any trou it contains
  let body = {
    _trou-depth.update(d => d + 1)
    body
    _trou-depth.update(d => d - 1)
  }

  // Handle numbering
  let ref-number-value = none
  let num = if number == none {
    none
  } else if number == auto {
    let ctr = if counter != none { counter } else { get-counter(type) }
    if ctr != none {
      ctr.step()
      let val = ctr.get().first() + 1
      let shown = _env-shown-val(cfg, ctr, val, here())
      ref-number-value = if ref-number == auto { shown } else { ref-number }
      _format-env-number(cfg, shown, here())
    } else {
      none
    }
  } else {
    ref-number-value = if ref-number == auto { number } else { ref-number }
    number
  }

  // Get spacing
  let spacing = get-env-spacing(type, cfg)

  // Resolve the colour a style's non-accent variants should paint with
  let cfg = {
    let c = cfg
    c.insert("base-color", if cfg.env-colors { env-color } else { process-color(cfg.accent-color, cfg) })
    // The QED glyph is set at 1.4em, taller than the text it ends. Left as is,
    // it grows the line box and drops the whole line below the proof label,
    // which sits in its own column. A zero-height box keeps the glyph on the
    // baseline without letting it dictate the height of the line.
    c.insert("qed-symbol", box(height: 0pt, align(bottom, cfg.qed-symbol)))
    c
  }

  // Redistribute label / name / number according to header-layout
  let (label-text, name, num) = _apply-header-layout(cfg, type, label-text, name, num)

  let rendered = if type == "proof" {
    (style-dict.proof)(body, cfg)
  } else if style-dict.keys().contains(variant) {
    (style-dict.at(variant))(label-text, name, num, body, cfg, env-color)
  } else {
    // Fallback to standard variant
    (style-dict.standard)(label-text, name, num, body, cfg, env-color)
  }

  // Wrap in spacing block
  v(spacing.above)

  if label == none {
    rendered
  } else {
    [#rendered #label]
  }

  v(spacing.below)
}

#let env(
  type: "theorem",
  name: none,
  number: auto,
  ref-number: auto,
  label: none,
  display-label: none,
  color: none,
  qr: none,
  instructor: false,
  counter-key: none,
  space: none,
  space-height: 3cm,
  body,
) = {
  let marker = if label == none {
    []
  } else {
    metadata((
      kind: "beautiframe-ref",
      target-key: str(label),
      target: label,
      type: type,
      display-label: display-label,
      number: number,
      ref-number: ref-number,
      counter-key: counter-key,
    ))
  }
  [
    #marker
    #_env-render(
      type: type,
      name: name,
      number: number,
      ref-number: ref-number,
      label: label,
      display-label: display-label,
      color: color,
      qr: qr,
      instructor: instructor,
      counter: if counter-key != none { counter(counter-key) } else { none },
      space: space,
      space-height: space-height,
      body,
    )
  ]
}

#let _env-ref-page-text(
  targets,
  page-style: "comma",
  page-prefix: "p. ",
  pages-prefix: "pp. ",
) = {
  let first-page = beautiframe-page-counter.at(targets.first()).first()
  let last-page = beautiframe-page-counter.at(targets.last()).first()
  let page-ref = if first-page == last-page {
    [#page-prefix#first-page]
  } else {
    [#pages-prefix#first-page#text[-]#last-page]
  }
  if page-style == "comma" {
    [, #page-ref]
  } else if page-style == "bare" {
    [ #page-ref]
  } else {
    [ (#page-ref)]
  }
}

#let _env-ref-label-text(label, lower-label: true) = {
  if lower-label and std.type(label) == str and label.len() > 0 {
    let parts = label.clusters()
    lower(parts.first()) + parts.slice(1).join("")
  } else {
    label
  }
}

#let _env-ref-entry(target) = {
  let key = str(target)
  let hits = query(metadata).filter(item => {
    let value = item.value
    std.type(value) == dictionary and value.at("kind", default: none) == "beautiframe-ref" and value.at("target-key", default: none) == key
  })
  if hits.len() == 0 {
    none
  } else {
    let entry = hits.first().value
    let loc = hits.first().location()
    let cfg = beautiframe-config.get()
    let label-text = if entry.display-label != none { entry.display-label } else { get-env-label(entry.type, cfg) }
    let ctr = if entry.at("counter-key", default: none) != none {
      counter(entry.counter-key)
    } else {
      get-counter(entry.type)
    }
    let actual-number = if entry.number == none {
      none
    } else if entry.number == auto and ctr != none {
      _env-shown-val(cfg, ctr, ctr.at(target).first() + 1, loc)
    } else {
      entry.number
    }
    let num = if actual-number == none {
      none
    } else if entry.number == auto {
      _format-env-number(cfg, actual-number, loc)
    } else {
      str(actual-number)
    }
    let ref-num = if entry.ref-number == auto { actual-number } else { entry.ref-number }
    (
      target: entry.target,
      label: label-text,
      label-key: if std.type(label-text) == str { label-text } else { entry.target-key },
      number: num,
      ref-number: ref-num,
    )
  }
}

/// Reference a labelled Beautiframe environment.
///
/// The target environment must be called with `label: <id>`.
/// By default this prints a linked reference such as "theorem 2, p. 5".
#let env-ref(
  target,
  page: true,
  page-style: "comma",
  page-prefix: "p. ",
  pages-prefix: "pp. ",
  lower-label: true,
  missing: [??],
) = context {
  let entry = _env-ref-entry(target)
  if entry == none {
    missing
  } else {
    let ref-label = _env-ref-label-text(entry.label, lower-label: lower-label)
    let ref-text = if entry.number == none {
      [#ref-label]
    } else {
      [#ref-label #entry.number]
    }
    let page-text = if page {
      _env-ref-page-text((target,), page-style: page-style, page-prefix: page-prefix, pages-prefix: pages-prefix)
    } else {
      [#none]
    }
    link(entry.target)[#ref-text#page-text]
  }
}
#let envref = env-ref

#let _env-ref-range-text(group, lower-label: true) = {
  let first = group.first()
  let last = group.last()
  let first-entry = first.entry
  let last-entry = last.entry
  let ref-label = _env-ref-label-text(first-entry.label, lower-label: lower-label)
  if group.len() == 1 or first-entry.number == none {
    if first-entry.number == none {
      [#ref-label]
    } else {
      [#ref-label #first-entry.number]
    }
  } else {
    [#ref-label #first-entry.number#text[-]#last-entry.number]
  }
}

/// Reference multiple labelled Beautiframe environments.
///
/// Consecutive references with the same display label are compacted into a range.
/// Mixed environment types stay explicit, e.g. "Definition 1 and Proposition 2".
#let env-refs(
  ..targets,
  page: true,
  page-style: "comma",
  page-prefix: "p. ",
  pages-prefix: "pp. ",
  lower-label: true,
  missing: [??],
  separator: [, ],
  last-separator: [ et ],
) = context {
  let items = ()

  let _ = for target in targets.pos() {
    let entry = _env-ref-entry(target)
    if entry != none {
      items.push((target: target, entry: entry))
    } else {
      items.push((target: target, entry: none))
    }
  }

  let groups = ()
  let _ = for item in items {
    if item.entry == none {
      groups.push((item,))
    } else if groups.len() == 0 {
      groups.push((item,))
    } else {
      let prev-group = groups.last()
      let prev = prev-group.last()
      let same-label = prev.entry != none and prev.entry.label-key == item.entry.label-key
      let consecutive = (
        same-label and
        type(prev.entry.ref-number) == int and
        type(item.entry.ref-number) == int and
        item.entry.ref-number == prev.entry.ref-number + 1
      )
      if consecutive {
        groups.remove(groups.len() - 1)
        groups.push(prev-group + (item,))
      } else {
        groups.push((item,))
      }
    }
  }

  let pieces = ()
  let _ = for group in groups {
    let first = group.first()
    if first.entry == none {
      pieces.push([#missing])
    } else {
      let targets = group.map(item => item.target)
      let text = _env-ref-range-text(group, lower-label: lower-label)
      let page-text = if page {
        _env-ref-page-text(targets, page-style: page-style, page-prefix: page-prefix, pages-prefix: pages-prefix)
      } else {
        [#none]
      }
      pieces.push(link(first.entry.target)[#text#page-text])
    }
  }

  if pieces.len() == 0 {
    [#none]
  } else if pieces.len() == 1 {
    pieces.first()
  } else if pieces.len() == 2 {
    pieces.join(last-separator)
  } else {
    pieces.slice(0, pieces.len() - 1).join(separator) + last-separator + pieces.last()
  }
}
#let envrefs = env-refs

// ═══════════════════════════════════════════════════════════════════════════
// CONVENIENCE FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

// Plural label for a single call. Returns none (= keep the configured
// singular label) unless this call asked for the plural.
//
// It has to be a per-call display-label, not a beautiframe-setup call: setup
// updates the global config state from that point on, so one `plural: true`
// used to turn every later environment of the same type plural with no way
// back. This mirrors what new-env already does for custom environments.
//
// Must be called inside a context block.
#let _plural-label(type, plural) = {
  if plural {
    beautiframe-config.get().at(type + "-plural", default: none)
  } else {
    none
  }
}

// title: is accepted as a synonym for name: for backward compatibility
#let theorem(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  env(type: "theorem", display-label: _plural-label("theorem", plural), name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let definition(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  env(type: "definition", display-label: _plural-label("definition", plural), name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let lemma(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  env(type: "lemma", display-label: _plural-label("lemma", plural), name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let proposition(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  env(type: "proposition", display-label: _plural-label("proposition", plural), name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let corollary(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  env(type: "corollary", display-label: _plural-label("corollary", plural), name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let remark(name: none, title: none, number: none, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  env(type: "remark", display-label: _plural-label("remark", plural), name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let example(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  env(type: "example", display-label: _plural-label("example", plural), name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let proof(label: none, instructor: false, body) = env(type: "proof", label: label, instructor: instructor, body)

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM ENVIRONMENT FACTORY
// ═══════════════════════════════════════════════════════════════════════════

/// Create a custom environment with its own counter
/// Returns a function that can be called like the built-in environments
///
/// Example:
/// ```typst
/// #let conjecture = new-env("Conjecture", base: "theorem")
/// #let propriete = new-env("Propriété", plural: "Propriétés", base: "definition", numbered: false)
/// #let formule = new-env("Formule", plural: "Formules", base: "lemma", color: blue)
///
/// #conjecture[This is a conjecture.]
/// #conjecture(name: "Goldbach")[Every even number > 2 is the sum of two primes.]
/// #propriete(plural: true)[Multiple properties here.]
/// ```
///
/// Parameters:
/// - label: The display label (e.g., "Conjecture", "Propriété")
/// - plural: The plural form of the label (default: same as label)
/// - base: Which built-in env to inherit styling from ("theorem", "definition", etc.)
/// - numbered: Whether to auto-number (default: true)
/// - color: Optional custom color for this environment
#let new-env(
  label,
  plural: none,
  base: "theorem",
  numbered: true,
  color: none,
) = {
  // Each custom environment gets its own counter, addressed by key so the
  // central numbering (link-to-section, counter-reset) applies to it too.
  let counter-key = "beautiframe-custom-" + label
  let singular-label = label

  // Default plural to label if not specified
  let plural-label = if plural == none { label } else { plural }

  // Return the environment function
  (name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) => {
    // Choose singular or plural label
    let display-label = if plural { plural-label } else { singular-label }

    // Render using the base environment type while preserving its configured label.
    let actual-name = if name != none { name } else { title }
    env(
      type: base,
      display-label: display-label,
      color: color,
      name: actual-name,
      number: if number == auto and not numbered { none } else { number },
      counter-key: counter-key,
      label: label,
      qr: qr,
      instructor: instructor,
      space: space,
      space-height: space-height,
      body,
    )
  }
}

/// Reset a custom environment counter
/// Example: #reset-env("Conjecture")
#let reset-env(label) = {
  counter("beautiframe-custom-" + label).update(0)
}

// ═══════════════════════════════════════════════════════════════════════════
// QED SYMBOL PRESETS
// ═══════════════════════════════════════════════════════════════════════════

#let qed-square() = beautiframe-setup(qed-symbol: text(size: 1.4em, sym.square.stroked))
#let qed-filled() = beautiframe-setup(qed-symbol: text(size: 1.4em, sym.square.filled))
#let qed-tombstone() = beautiframe-setup(qed-symbol: text(size: 1.4em, sym.qed))
#let qed-cqfd() = beautiframe-setup(qed-symbol: [_CQFD_])
#let qed-slashes() = beautiframe-setup(qed-symbol: "//")
#let qed-text() = beautiframe-setup(qed-symbol: [_Q.E.D._])
#let qed-none() = beautiframe-setup(qed-symbol: [])

// ═══════════════════════════════════════════════════════════════════════════
// LANGUAGE PRESETS
// ═══════════════════════════════════════════════════════════════════════════

// Restores the built-in English labels, plurals and abbreviations, so a
// document can come back from preset-french / preset-german / preset-spanish.
#let preset-english() = beautiframe-setup(
  theorem-label: "Theorem",
  definition-label: "Definition",
  lemma-label: "Lemma",
  proposition-label: "Proposition",
  corollary-label: "Corollary",
  remark-label: "Remark",
  example-label: "Example",
  proof-label: "Proof",
  // Plurals
  theorem-plural: "Theorems",
  definition-plural: "Definitions",
  lemma-plural: "Lemmas",
  proposition-plural: "Propositions",
  corollary-plural: "Corollaries",
  remark-plural: "Remarks",
  example-plural: "Examples",
  // Abbreviations
  theorem-abbrev: "Thm",
  definition-abbrev: "Def",
  lemma-abbrev: "Lem",
  proposition-abbrev: "Prop",
  corollary-abbrev: "Cor",
  remark-abbrev: "Rem",
  example-abbrev: "Ex",
  proof-abbrev: "Pf",
  prefix-separator: ":",
)

#let preset-french() = beautiframe-setup(
  theorem-label: "Théorème",
  definition-label: "Définition",
  lemma-label: "Lemme",
  proposition-label: "Proposition",
  corollary-label: "Corollaire",
  remark-label: "Remarque",
  example-label: "Exemple",
  proof-label: "Preuve",
  // Plurals
  theorem-plural: "Théorèmes",
  definition-plural: "Définitions",
  lemma-plural: "Lemmes",
  proposition-plural: "Propositions",
  corollary-plural: "Corollaires",
  remark-plural: "Remarques",
  example-plural: "Exemples",
  // Abréviations
  theorem-abbrev: "Thm",
  definition-abbrev: "Déf",
  lemma-abbrev: "Lem",
  proposition-abbrev: "Prop",
  corollary-abbrev: "Cor",
  remark-abbrev: "Rem",
  example-abbrev: "Ex",
  proof-abbrev: "Pr",
  // Espace fine insécable avant le deux-points
  prefix-separator: sym.space.nobreak.narrow + ":",
)

#let preset-german() = beautiframe-setup(
  theorem-label: "Satz",
  definition-label: "Definition",
  lemma-label: "Lemma",
  proposition-label: "Proposition",
  corollary-label: "Korollar",
  remark-label: "Bemerkung",
  example-label: "Beispiel",
  proof-label: "Beweis",
  // Plurals
  theorem-plural: "Sätze",
  definition-plural: "Definitionen",
  lemma-plural: "Lemmata",
  proposition-plural: "Propositionen",
  corollary-plural: "Korollare",
  remark-plural: "Bemerkungen",
  example-plural: "Beispiele",
)

#let preset-spanish() = beautiframe-setup(
  theorem-label: "Teorema",
  definition-label: "Definición",
  lemma-label: "Lema",
  proposition-label: "Proposición",
  corollary-label: "Corolario",
  remark-label: "Observación",
  example-label: "Ejemplo",
  proof-label: "Demostración",
  // Plurals
  theorem-plural: "Teoremas",
  definition-plural: "Definiciones",
  lemma-plural: "Lemas",
  proposition-plural: "Proposiciones",
  corollary-plural: "Corolarios",
  remark-plural: "Observaciones",
  example-plural: "Ejemplos",
)

// ═══════════════════════════════════════════════════════════════════════════
// COLOR THEMES
// ═══════════════════════════════════════════════════════════════════════════

#let theme-ocean() = beautiframe-setup(
  primary-color: rgb("#1a5276"),
  accent-color: rgb("#2980b9"),
  theorem-color: rgb("#1a5276"),
  definition-color: rgb("#2874a6"),
  lemma-color: rgb("#3498db"),
  proposition-color: rgb("#3498db"),
  corollary-color: rgb("#5dade2"),
  remark-color: rgb("#85c1e9"),
  example-color: rgb("#21618c"),
)

#let theme-forest() = beautiframe-setup(
  primary-color: rgb("#1e4d2b"),
  accent-color: rgb("#2ecc71"),
  theorem-color: rgb("#1e4d2b"),
  definition-color: rgb("#27ae60"),
  lemma-color: rgb("#2ecc71"),
  proposition-color: rgb("#2ecc71"),
  corollary-color: rgb("#58d68d"),
  remark-color: rgb("#82e0aa"),
  example-color: rgb("#196f3d"),
)

#let theme-sunset() = beautiframe-setup(
  primary-color: rgb("#922b21"),
  accent-color: rgb("#e74c3c"),
  theorem-color: rgb("#922b21"),
  definition-color: rgb("#d35400"),
  lemma-color: rgb("#e67e22"),
  proposition-color: rgb("#e67e22"),
  corollary-color: rgb("#f39c12"),
  remark-color: rgb("#f5b041"),
  example-color: rgb("#c0392b"),
)

#let theme-lavender() = beautiframe-setup(
  primary-color: rgb("#4a235a"),
  accent-color: rgb("#9b59b6"),
  theorem-color: rgb("#4a235a"),
  definition-color: rgb("#7d3c98"),
  lemma-color: rgb("#9b59b6"),
  proposition-color: rgb("#9b59b6"),
  corollary-color: rgb("#af7ac5"),
  remark-color: rgb("#d2b4de"),
  example-color: rgb("#6c3483"),
)

// ═══════════════════════════════════════════════════════════════════════════
// FRENCH MATH COURSE — built-in environments and preset
// ═══════════════════════════════════════════════════════════════════════════

// Extra environments used in French secondary/post-secondary math courses
#let propriete = new-env("Propriété", plural: "Propriétés", base: "corollary", numbered: false)
#let formule   = new-env("Formule",   plural: "Formules",   base: "lemma")
#let methode   = new-env("Méthode",   plural: "Méthodes",   base: "proposition")
#let regles    = new-env("Règle",     plural: "Règles",     base: "proposition", numbered: false)
#let pratique  = new-env("En pratique", plural: "En pratique", base: "example")
#let guided-example = new-env("Exemple guidé", base: "example")
#let objectifs = new-env("Objectifs d'apprentissage", base: "lemma", numbered: false)
#let objectif  = objectifs
#let concepts  = new-env("Concepts clés", base: "lemma", numbered: false)
#let glossaire = new-env("Glossaire", base: "lemma", numbered: false)

#let _default-correction-renderer(title, body) = block(
  width: 100%,
  above: 0.75em,
  below: 0.45em,
  inset: (x: 0.8em, y: 0.75em),
  stroke: 0.5pt + luma(45%),
  radius: 2pt,
  breakable: true,
)[
  // Keep the correction title with the first following body item.
  #block(sticky: true)[
    #text(weight: "bold")[#title]
    #v(0.35em)
  ]
  #body
]

#let worked-exercise(
  title: none,
  label: none,
  qr: none,
  correction: none,
  correction-title: none,
  body,
) = context {
  let cfg = beautiframe-config.get()
  let shown-correction-title = if correction-title == none { cfg.correction-label } else { correction-title }
  pratique(title: title, label: label, qr: qr, [
    #body
    #if correction != none and cfg.instructor-mode [
      #if cfg.correction-renderer != none {
        (cfg.correction-renderer)(shown-correction-title, correction)
      } else {
        _default-correction-renderer(shown-correction-title, correction)
      }
    ]
  ])
}

/// A compact, unnumbered challenge callout following the configured remark style.
/// Examples:
/// #defi[Résoudre $x^2 - 5x + 6 = 0$.]
/// #defi(title: [Y arrivez-vous ?])[Résoudre $x^2 - 5x + 6 = 0$.]
/// #defi(title: [Pourquoi ?], icon: [🌶])[Justifier chaque étape.]
#let defi(
  title: none,
  icon: [🎯],
  label: none,
  qr: none,
  space: none,
  space-height: 3cm,
  body,
) = {
  let base-label = if icon == none {
    [Défi]
  } else {
    [#icon #h(0.3em) Défi]
  }
  let challenge-label = if title == none {
    base-label
  } else {
    [#base-label : #title]
  }
  block(breakable: false)[
    #env(
      type: "remark",
      display-label: challenge-label,
      number: none,
      label: label,
      qr: qr,
      space: space,
      space-height: space-height,
      body,
    )
  ]
}
#let défi = defi

// formules — plural shorthand (same counter as formule)
#let formules(name: none, title: none, label: none, qr: none, space: none, space-height: 3cm, body) = {
  formule(plural: true, name: if name != none { name } else { title }, label: label, qr: qr, space: space, space-height: space-height, body)
}

// Formulas marked for an end-of-chapter recap.
#let formule-recap-state = state("beautiframe-formule-recap", ())

/// Retain a formula for a later recap without displaying anything in place.
#let formule-end(label, formula) = {
  formule-recap-state.update(entries => entries + ((label, formula),))
}
/// Print formulas collected since the previous recap, then start a new collection.
#let formules-recap(title: [Formules à retenir], clear: true) = {
  context {
    let entries = formule-recap-state.get()
    if entries.len() > 0 {
      env(type: "lemma", display-label: title, number: none)[
        #for ((label, formula)) in entries {
          block(width: 100%, breakable: false, above: 0.55em, below: 0.7em)[
            #strong(label) :

            #align(center)[#formula]
          ]
        }
      ]
    }
  }
  if clear {
    formule-recap-state.update(())
  }
}
#let recap-formules = formules-recap

// Notation / Discussion — unnumbered remark-type environments
#let notation(name: none, title: none, label: none, qr: none, space: none, space-height: 3cm, body) = {
  env(type: "remark", display-label: "Notation", name: if name != none { name } else { title }, number: none, label: label, qr: qr, space: space, space-height: space-height, body)
}
#let discussion(
  name: none,
  title: none,
  label: none,
  qr: none,
  instructor: false,
  correction: none,
  correction-title: none,
  space: none,
  space-height: 3cm,
  body,
) = context {
  let cfg = beautiframe-config.get()
  let shown-correction-title = if correction-title == none { cfg.correction-label } else { correction-title }
  env(type: "remark", display-label: "Discussion", name: if name != none { name } else { title }, number: none, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, [
    #body
    #if correction != none and cfg.instructor-mode [
      #if cfg.correction-renderer != none {
        (cfg.correction-renderer)(shown-correction-title, correction)
      } else {
        _default-correction-renderer(shown-correction-title, correction)
      }
    ]
  ])
}

// Convenience aliases matching French terminology
#let theoreme      = theorem
#let definitionfr  = definition
#let propositionfr = proposition
#let exemple       = example
#let exemplefr     = example
#let remarque      = remark
#let corollaire    = corollary
// preuve wraps proof but accepts an ignored title: param for backward compatibility
#let preuve(title: none, label: none, body) = proof(label: label, body)

/// Apply the full French math course configuration in one call.
/// Sets classic style, standard variants, blue accent, French labels, QED square.
#let preset-french-math() = {
  preset-french()
  beautiframe-setup(
    style: "cours",
    theorem-variant:     "standard",
    definition-variant:  "standard",
    lemma-variant:       "standard",
    proposition-variant: "standard",
    corollary-variant:   "standard",
    remark-variant:      "minimal",
    example-variant:     "standard",
    label-weight: "bold",
    name-style:   "italic",
    accent-color: rgb("#2980b9"),
  )
  qed-square()
}

/// Reset all built-in counters plus the french-math custom env counters.
#let beautiframe-reset-french-math() = {
  beautiframe-reset()
  reset-env("Formule")
  reset-env("Méthode")
  reset-env("En pratique")
  reset-env("Exemple guidé")
  reset-env("Objectifs d'apprentissage")
  reset-env("Concepts clés")
  reset-env("Glossaire")
  formule-recap-state.update(())
}

/// Apply the BW French math course configuration (Gymnomath / coursCollège style).
/// Sets bw style with prominent boxes for théorèmes/propositions, standard side-blocks
/// for définitions/exemples/méthodes, minimal for remarques. Black-and-white palette.
#let preset-french-math-bw() = {
  preset-french()
  beautiframe-setup(
    style:               "bw",
    theorem-variant:     "prominent",
    definition-variant:  "standard",
    lemma-variant:       "boxed",
    proposition-variant: "prominent",
    corollary-variant:   "boxed",
    remark-variant:      "minimal",
    example-variant:     "standard",
    label-weight:        "bold",
    label-size:          8.4pt,
    name-style:          "italic",
    primary-color:       luma(10%),
    secondary-color:     luma(45%),
    inset:              (x: 8pt, y: 8pt),
    border-width:        0.55pt,
    proof-label:         "Preuve",
  )
  qed-square()
}

// ═══════════════════════════════════════════════════════════════════════════
// TROUS - reserved fill-in space that carries the instructor content
// ═══════════════════════════════════════════════════════════════════════════
//
// A trou holds the content that is produced live in class (the example, the
// counterexample, the class's answer, the sketch). It renders as reserved,
// correctly sized blank space in the student build, and as the content itself
// in the instructor build (beautiframe-setup(instructor-mode: true)).
//
//   #trou[La suite $1/n$ tend vers $0$ sans jamais l'atteindre.]
//   #trou(hint: [contre-exemple], fill: "lines")[La fonction de Dirichlet.]
//   #trou(height: 4cm)[...]                 // fixed height instead of measured
//   Une fonction #trou-inline[continue] sur $[a; b]$ ...
//
// Styles may provide their own `trou` renderer in their style dict; the
// generic renderer below is used when they do not.

// Ink used for rules and frames in the student build.
#let _trou-color(cfg) = {
  if cfg.color-mode == "bw" { black } else { cfg.trou-color }
}

// Ink used to flag filled content in the instructor build.
#let _trou-mark-color(cfg) = {
  let c = if cfg.trou-mark-color != none { cfg.trou-mark-color } else { cfg.accent-color }
  process-color(c, cfg)
}

// The reserved area itself: a fixed-height block, optionally ruled or dotted.
#let _trou-interior(fill-kind, height, color, gap: 8mm) = {
  if fill-kind == "lines" {
    let n = calc.max(1, calc.floor(height / gap))
    block(width: 100%, height: height, clip: true, breakable: false)[
      // Rules are block-level: kill paragraph and block spacing so the pitch
      // is exactly `gap`
      #set par(spacing: 0pt, leading: 0pt)
      #set block(spacing: 0pt)
      #for _ in range(n) {
        v(gap - 0.5pt)
        line(length: 100%, stroke: 0.4pt + color)
      }
    ]
  } else if fill-kind == "grid" {
    block(
      width: 100%, height: height, clip: true, breakable: false,
      fill: tiling(size: (5mm, 5mm))[
        #place(dx: 2.5mm, dy: 2.5mm, circle(radius: 0.55pt, fill: color))
      ],
    )[]
  } else {
    block(width: 100%, height: height, breakable: false)[]
  }
}

// Generic renderer, used by styles that do not define their own.
#let _default-trou(interior, hint, cfg, color, nested: false) = {
  block(
    width: 100%,
    above: 0.7em,
    below: 0.7em,
    breakable: false,
    stroke: if cfg.trou-frame { 0.5pt + color } else { none },
    radius: cfg.border-radius,
    inset: if cfg.trou-frame { (x: 0.5em, y: 0.45em) } else { (x: 0pt, y: 0pt) },
  )[
    #if hint != none [
      #text(size: cfg.trou-hint-size, style: "italic", fill: color)[#hint]
      #v(0.2em, weak: true)
    ]
    #interior
  ]
}

// Instructor build: the content, flagged so it is easy to spot on the sheet.
#let _trou-instructor(body, hint, cfg) = {
  if not cfg.trou-mark-instructor {
    body
  } else {
    let color = _trou-mark-color(cfg)
    block(
      width: 100%,
      above: 0.7em,
      below: 0.7em,
      breakable: true,
      stroke: (left: 2pt + color),
      inset: (left: 0.7em, y: 0.35em),
    )[
      #if hint != none [
        #text(size: cfg.trou-hint-size, style: "italic", fill: color)[#hint]
        #v(0.2em, weak: true)
      ]
      #body
    ]
  }
}

/// Reserved fill-in space carrying the content produced in class.
/// - height: `auto` measures the body, or give a fixed length
/// - fill: `auto` (config), "empty", "lines" or "grid"
/// - frame: `auto` (config), true or false
/// - hint: short cue printed in the student build ("contre-exemple", "esquisse")
/// - min-height / padding: override the configured minimum and breathing room
#let trou(
  height: auto,
  fill: auto,
  frame: auto,
  hint: none,
  min-height: auto,
  padding: auto,
  scale: auto,
  body,
) = context {
  let cfg = beautiframe-config.get()

  if cfg.instructor-mode {
    _trou-instructor(body, hint, cfg)
  } else {
    let cfg = if frame == auto { cfg } else {
      let c = cfg
      c.insert("trou-frame", frame)
      c
    }
    let fill-kind = if fill == auto { cfg.trou-fill } else { fill }
    let pad = if padding == auto { cfg.trou-padding } else { padding }
    let minh = if min-height == auto { cfg.trou-min-height } else { min-height }
    let sc = if scale == auto { cfg.trou-scale } else { scale }
    let gap = cfg.trou-line-gap
    let color = _trou-color(cfg)
    let style-dict = styles.at(cfg.style)
    let render = style-dict.at("trou", default: _default-trou)
    let nested = _trou-depth.get() > 0

    layout(size => {
      // An explicit height is taken as given; a measured one is scaled up,
      // since handwriting needs far more room than typeset text.
      let h = if height != auto {
        height.to-absolute()
      } else {
        measure(block(width: size.width, body)).height * sc + pad.to-absolute()
      }
      let h = calc.max(h, minh.to-absolute())
      // Ruled space snaps up to a whole number of lines
      let h = if fill-kind == "lines" { calc.ceil(h / gap) * gap } else { h }
      let h = if cfg.trou-max-height != none {
        calc.min(h, cfg.trou-max-height.to-absolute())
      } else { h }

      render(
        _trou-interior(fill-kind, h, color, gap: gap),
        hint, cfg, color, nested: nested,
      )
    })
  }
}

/// Inline blank, for a single word or expression left out of a printed
/// sentence. Sized to the hidden content unless `width` is given.
#let trou-inline(width: auto, body) = context {
  let cfg = beautiframe-config.get()

  if cfg.instructor-mode {
    if cfg.trou-mark-instructor {
      underline(stroke: 0.6pt + _trou-mark-color(cfg), offset: 2.5pt, evade: false, body)
    } else {
      body
    }
  } else {
    let w = if width != auto {
      width
    } else {
      measure(body).width * cfg.trou-scale + 0.6em
    }
    box(
      width: w,
      height: 0.85em,
      stroke: (bottom: 0.5pt + _trou-color(cfg)),
    )[]
  }
}
