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
  label-size: 11pt,                  // Size for "Theorem", "Definition", etc.
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
  link-to-section: false,            // Include section number in env number

  // Counter reset behavior
  counter-reset: "manual",           // "manual", "section", "chapter"

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
  // COLOR MODE (Print-friendly options)
  // ─────────────────────────────────────────────────────────────────────────
  color-mode: "color",               // "color", "grayscale", "bw"
))

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
) = {
  beautiframe-config.update(cfg => {
    let new-cfg = cfg
    if style != none { new-cfg.insert("style", style) }
    // Variant mapping
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
// CORE ENVIRONMENT FUNCTION
// ═══════════════════════════════════════════════════════════════════════════

#let env(
  type: "theorem",
  name: none,
  number: auto,
  body,
) = context {
  let cfg = beautiframe-config.get()
  let style-dict = styles.at(cfg.style)

  // Get label text
  let label-text = get-env-label(type, cfg)

  // Get variant for this environment type
  let variant = get-env-variant(type, cfg)

  // Get environment color
  let env-color = get-env-color(type, cfg)

  // Handle numbering
  let num = if number == none {
    none
  } else if number == auto {
    let ctr = get-counter(type)
    if ctr != none {
      ctr.step()
      context {
        let val = ctr.get().first()
        if cfg.link-to-section {
          let h = counter(heading).get()
          if h.len() > 0 {
            str(h.first()) + "." + str(val)
          } else {
            str(val)
          }
        } else {
          str(val)
        }
      }
    } else {
      none
    }
  } else {
    number
  }

  // Get spacing
  let spacing = get-env-spacing(type, cfg)

  // Wrap in spacing block
  v(spacing.above)

  // Call appropriate style renderer
  if type == "proof" {
    (style-dict.proof)(body, cfg)
  } else if style-dict.keys().contains(variant) {
    (style-dict.at(variant))(label-text, name, num, body, cfg, env-color)
  } else {
    // Fallback to standard variant
    (style-dict.standard)(label-text, name, num, body, cfg, env-color)
  }

  v(spacing.below)
}

// ═══════════════════════════════════════════════════════════════════════════
// CONVENIENCE FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

#let theorem(name: none, number: auto, plural: false, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(theorem-label: cfg.theorem-plural)
  }
  env(type: "theorem", name: name, number: number, body)
}
#let definition(name: none, number: auto, plural: false, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(definition-label: cfg.definition-plural)
  }
  env(type: "definition", name: name, number: number, body)
}
#let lemma(name: none, number: auto, plural: false, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(lemma-label: cfg.lemma-plural)
  }
  env(type: "lemma", name: name, number: number, body)
}
#let proposition(name: none, number: auto, plural: false, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(proposition-label: cfg.proposition-plural)
  }
  env(type: "proposition", name: name, number: number, body)
}
#let corollary(name: none, number: auto, plural: false, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(corollary-label: cfg.corollary-plural)
  }
  env(type: "corollary", name: name, number: number, body)
}
#let remark(name: none, number: none, plural: false, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(remark-label: cfg.remark-plural)
  }
  env(type: "remark", name: name, number: number, body)
}
#let example(name: none, number: auto, plural: false, body) = context {
  if plural {
    let cfg = beautiframe-config.get()
    beautiframe-setup(example-label: cfg.example-plural)
  }
  env(type: "example", name: name, number: number, body)
}
#let proof(body) = env(type: "proof", body)

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
  // Create a unique counter for this environment
  let env-counter = counter("beautiframe-custom-" + label)

  // Default plural to label if not specified
  let plural-label = if plural == none { label } else { plural }

  // Return the environment function
  (name: none, number: auto, plural: false, body) => {
    // Handle numbering
    let actual-number = number
    if number == auto {
      if numbered {
        env-counter.step()
        actual-number = context env-counter.get().first()
      } else {
        actual-number = none
      }
    }

    // Choose singular or plural label
    let display-label = if plural { plural-label } else { label }

    // Temporarily set the label for the base type
    let label-key = base + "-label"

    // Apply color if specified
    if color != none {
      let color-key = base + "-color"
      beautiframe-setup(..((label-key): display-label, (color-key): color))
    } else {
      beautiframe-setup(..((label-key): display-label))
    }

    // Render using the base environment type
    env(type: base, name: name, number: actual-number, body)
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
