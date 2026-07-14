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

#let beautiframe-config = state("beautiframe-config", (
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
))

#let beautiframe-ref-state = state("beautiframe-refs", (:))
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

// Get background color for filled boxes (B&W aware)
#let get-background-color(base-color, cfg) = {
  if cfg.color-mode == "bw" {
    white  // No background in B&W mode
  } else if cfg.color-mode == "grayscale" {
    luma(95%)  // Very light gray
  } else {
    base-color.lighten(92%)  // Light tint of the color
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

// title: is accepted as a synonym for name: for backward compatibility
#let theorem(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(theorem-label: cfg.theorem-plural)
  }
  env(type: "theorem", name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let definition(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(definition-label: cfg.definition-plural)
  }
  env(type: "definition", name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let lemma(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(lemma-label: cfg.lemma-plural)
  }
  env(type: "lemma", name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let proposition(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(proposition-label: cfg.proposition-plural)
  }
  env(type: "proposition", name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let corollary(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(corollary-label: cfg.corollary-plural)
  }
  env(type: "corollary", name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let remark(name: none, title: none, number: none, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(remark-label: cfg.remark-plural)
  }
  env(type: "remark", name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
}
#let example(name: none, title: none, number: auto, label: none, plural: false, qr: none, instructor: false, space: none, space-height: 3cm, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(example-label: cfg.example-plural)
  }
  env(type: "example", name: if name != none { name } else { title }, number: number, label: label, qr: qr, instructor: instructor, space: space, space-height: space-height, body)
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
