// exercise-bank - Exercise Package for Typst
// Handles exercises with metadata, content, and solutions
// Supports multiple display modes and filtering

// =============================================================================
// External Package Imports
// =============================================================================

// Import g-exam for exam mode display
#import "@preview/g-exam:0.4.4": exam as g-exam-template, question as g-exam-question, subquestion as g-exam-subquestion

// =============================================================================
// State and Counters
// =============================================================================

// Global exercise counter
#let exo-counter = counter("exo-counter")

// Configuration state
#let exo-config = state("exo-config", (
  // Display control
  "display": "both",              // "ex" (exercises only), "sol" (solutions/corrections only), "both"
  "corrDisplay": "solution",   // "solution", "correction", "mixed"
  "corrLoc": "after",          // "after", "pagebreak", "end-section", "end-chapter"
  // Labels
  "solution-label": "Solution",
  "correction-label": "Correction",
  "exercise-label": "Exercise",
  // Counter behavior
  "counter-reset": "section",    // "section", "chapter", "global"
  // Display options
  "show-metadata": false,
  "show-id": false,              // Show exercise UID below the badge
  "show-competencies": false,    // Show competency tags below exercise
  "display-mode": "exercise",    // "exercise" (default exo-box) or "exam" (g-exam question)
  // Visual styling
  "badge-style": "box",          // "box", "circled", "filled-circle", "pill", "tag", "border-accent", "underline", "rounded-box", "header-card"
  "badge-color": black,          // Color for exercise badges
  "solution-color": rgb("#4a7c59"),    // Color for solution badges (green)
  "correction-color": rgb("#4a7c59"),  // Color for correction badges (green)
  "label-font-size": 12pt,       // Font size for badge label text
  "margin-position": auto,       // Position of content margin from left (auto = computed from label size)
  "label-extra": 1cm,            // Extra space for labels to extend into left margin
  "page-break": "none",          // "none", "before", "after", "around" - page break behavior for exercises
  // Draft mode
  "draft-mode": false,                            // Show placeholders for empty corrections/solutions
  "correction-placeholder": [_To be completed_],  // Placeholder when correction is empty (draft mode)
  "solution-placeholder": [_To be completed_],    // Placeholder when solution is empty (draft mode)
  // Spacing parameters
  "exercise-above": 0.8em,    // Space above exercise boxes
  "exercise-below": 0.8em,    // Space below exercise boxes
  "solution-above": 0.8em,    // Space above solution boxes
  "solution-below": 0.8em,    // Space below solution boxes
  "correction-above": 0.8em,  // Space above correction boxes
  "correction-below": 0.8em,  // Space below correction boxes
  "advanced-symbol": "*",     // Symbol shown before label for advanced exercises (none to disable)
))

// Registry of all exercises (for filtering)
#let exo-registry = state("exo-registry", ())

// Exercises pending solution display (for end-section/end-chapter modes)
#let exo-pending-solutions = state("exo-pending-solutions", ())

// ID counter for auto-generation
#let exo-id-counter = counter("exo-id-counter")

// Exam configuration state (for exam display mode)
#let exam-config = state("exam-config", (
  "show-solutions": false,  // Whether to show solutions in exam
  "solution-label": "Solution",
  // Solution box styling
  "solution-fill": rgb("#e8f5e9"),
  "solution-stroke": 0.8pt + rgb("#4a7c59"),
  "solution-radius": 3pt,
  "solution-inset": 8pt,
  "solution-label-color": rgb("#2e5a3a"),
  // Question styling (for custom question wrappers)
  "question-spacing": 1em,
))

// Custom solution box for exams (fully customizable)
// Defined early so it's available in exo-show/exo-select when in exam mode
#let exam-solution-box(body) = context {
  let exam-cfg = exam-config.get()
  if exam-cfg.show-solutions {
    block(
      width: 100%,
      inset: exam-cfg.solution-inset,
      fill: exam-cfg.solution-fill,
      stroke: exam-cfg.solution-stroke,
      radius: exam-cfg.solution-radius,
      [
        #text(weight: "bold", fill: exam-cfg.solution-label-color)[#exam-cfg.solution-label:]
        #v(4pt)
        #body
      ]
    )
  }
}

// =============================================================================
// Configuration Function
// =============================================================================

#let exo-setup(
  // Display control
  display: none,           // "ex", "sol", "both"
  corr-display: none,    // "solution", "correction", "mixed"
  corr-loc: none,        // "after", "pagebreak", "end-section", "end-chapter"
  // Labels
  solution-label: none,
  correction-label: none,
  exercise-label: none,
  // Counter behavior
  counter-reset: none,
  // Display options
  show-metadata: none,
  show-id: none,
  show-competencies: none,
  display-mode: none,  // "exercise" or "exam"
  // Visual styling
  badge-style: none,   // "box", "circled", "filled-circle", "pill", "tag"
  badge-color: none,   // Color for exercise badges
  solution-color: none,   // Color for solution badges
  correction-color: none, // Color for correction badges
  label-font-size: none,
  margin-position: none,
  label-extra: none,
  page-break: none,    // "none", "before", "after", "around"
  // Draft mode
  draft-mode: none,
  correction-placeholder: none,
  solution-placeholder: none,
  // Spacing parameters
  exercise-above: none,
  exercise-below: none,
  solution-above: none,
  solution-below: none,
  correction-above: none,
  correction-below: none,
  advanced-symbol: none,  // Symbol for advanced exercises (use "*", "†", emoji, etc.)
) = {
  exo-config.update(cfg => {
    let new = cfg
    if display != none { new.display = display }
    if corr-display != none { new.corrDisplay = corr-display }
    if corr-loc != none { new.corrLoc = corr-loc }
    if solution-label != none { new.solution-label = solution-label }
    if correction-label != none { new.correction-label = correction-label }
    if exercise-label != none { new.exercise-label = exercise-label }
    if counter-reset != none { new.counter-reset = counter-reset }
    if show-metadata != none { new.show-metadata = show-metadata }
    if show-id != none { new.show-id = show-id }
    if show-competencies != none { new.show-competencies = show-competencies }
    if display-mode != none { new.display-mode = display-mode }
    if badge-style != none { new.badge-style = badge-style }
    if badge-color != none { new.badge-color = badge-color }
    if solution-color != none { new.solution-color = solution-color }
    if correction-color != none { new.correction-color = correction-color }
    if label-font-size != none { new.label-font-size = label-font-size }
    if margin-position != none { new.margin-position = margin-position }
    if label-extra != none { new.label-extra = label-extra }
    if page-break != none { new.page-break = page-break }
    if draft-mode != none { new.draft-mode = draft-mode }
    if correction-placeholder != none { new.correction-placeholder = correction-placeholder }
    if solution-placeholder != none { new.solution-placeholder = solution-placeholder }
    // Spacing parameters
    if exercise-above != none { new.exercise-above = exercise-above }
    if exercise-below != none { new.exercise-below = exercise-below }
    if solution-above != none { new.solution-above = solution-above }
    if solution-below != none { new.solution-below = solution-below }
    if correction-above != none { new.correction-above = correction-above }
    if correction-below != none { new.correction-below = correction-below }
    if advanced-symbol != none { new.advanced-symbol = advanced-symbol }
    new
  })
}

// =============================================================================
// Counter Reset Hooks
// =============================================================================

#let exo-reset-counter() = {
  exo-counter.update(0)
}

#let exo-section-start() = {
  context {
    let cfg = exo-config.get()
    if cfg.counter-reset == "section" {
      exo-counter.update(0)
    }
  }
}

#let exo-chapter-start() = {
  context {
    let cfg = exo-config.get()
    if cfg.counter-reset == "chapter" or cfg.counter-reset == "section" {
      exo-counter.update(0)
    }
  }
  exo-pending-solutions.update(())
}

// =============================================================================
// Advanced Exercise Label Helper
// =============================================================================

// Build exercise label with optional advanced symbol prefix
#let get-exercise-label(cfg, metadata) = {
  let label = cfg.exercise-label
  if cfg.advanced-symbol != none {
    let is-advanced = metadata.at("advanced", default: false)
    if is-advanced {
      [#cfg.advanced-symbol~#label]
    } else {
      label
    }
  } else {
    label
  }
}

// =============================================================================
// Visual Styling
// =============================================================================

// Calculate the maximum badge width for consistent margins
#let calc-badge-width(label, number, font-size) = {
  let badge = box(
    stroke: 0.8pt,
    inset: (x: 4pt, y: 3pt),
    text(weight: "bold", size: font-size)[#label #number],
  )
  measure(badge).width
}

// Compute default margin based on badge style and longest label with 3-digit number
// "Correction" is the longest among Exercise/Solution/Correction
#let calc-default-margin(font-size: 12pt, style: "box") = {
  let labels = ("Exercise", "Solution", "Correction", "Exercice", "Corrigé")

  if style == "circled" or style == "filled-circle" {
    // Circle styles only show number, size is font-size * 2
    font-size * 2 + 16pt
  } else if style == "tag" {
    // Tag has arrow, measure with longest label
    let max-width = 0pt
    for label in labels {
      let content = box(
        inset: (x: 8pt, y: 3pt),
        text(weight: "bold", size: font-size)[#label 100],
      )
      let width = measure(content).width
      if width > max-width { max-width = width }
    }
    max-width + 8pt + 16pt  // arrow width + padding
  } else if style == "pill" {
    // Pill has more padding
    let max-width = 0pt
    for label in labels {
      let content = box(
        inset: (x: 10pt, y: 4pt),
        text(weight: "medium", size: font-size)[#label 100],
      )
      let width = measure(content).width
      if width > max-width { max-width = width }
    }
    max-width + 16pt
  } else {
    // Default box style
    let max-width = 0pt
    for label in labels {
      let width = calc-badge-width(label, 100, font-size)
      if width > max-width { max-width = width }
    }
    max-width + 16pt
  }
}

// =============================================================================
// Badge Styles
// =============================================================================

// Style: box (default) - Rectangle with stroke
#let badge-box(label, number, font-size, color, is-solution) = {
  let fill-color = if is-solution { color.lighten(85%) } else { white }
  box(
    stroke: 0.8pt + color,
    fill: fill-color,
    inset: (x: 4pt, y: 3pt),
  )[#text(weight: "bold", size: font-size, fill: color)[#label~#number]]
}

// Style: circled - Number in a circle (no label)
#let badge-circled(label, number, font-size, color, is-solution) = {
  let size = font-size * 2
  box(
    width: size,
    height: size,
    stroke: 1.2pt + color,
    radius: 50%,
    align(center + horizon)[
      #text(weight: "bold", size: font-size, fill: color)[#number]
    ]
  )
}

// Style: filled-circle - Number in a filled circle
#let badge-filled-circle(label, number, font-size, color, is-solution) = {
  let size = font-size * 2
  box(
    width: size,
    height: size,
    fill: color,
    radius: 50%,
    align(center + horizon)[
      #text(weight: "bold", size: font-size, fill: white)[#number]
    ]
  )
}

// Style: pill - Rounded pill shape
#let badge-pill(label, number, font-size, color, is-solution) = {
  let stroke-color = 0.8pt + color
  let fill-color = if is-solution { color.lighten(85%) } else { rgb("#f3f4f6") }
  box(
    stroke: stroke-color,
    fill: fill-color,
    radius: 12pt,
    inset: (x: 10pt, y: 4pt),
  )[#text(weight: "medium", size: font-size, fill: color)[#label~#number]]
}

// Style: tag - Arrow-shaped tag
#let badge-tag(label, number, font-size, color, is-solution) = {
  let arrow-width = 8pt
  let tag-height = font-size + 10pt
  let fill-color = color
  stack(dir: ltr, spacing: 0pt,
    box(
      height: tag-height,
      fill: fill-color,
      radius: (left: 3pt, right: 0pt),
      inset: (x: 8pt, y: 3pt),
    )[
      #align(horizon)[
        #text(weight: "bold", size: font-size, fill: white)[#label~#number]
      ]
    ],
    box(
      width: arrow-width,
      height: tag-height,
    )[
      #polygon(
        fill: fill-color,
        (0pt, 0pt),
        (arrow-width, tag-height / 2),
        (0pt, tag-height),
      )
    ]
  )
}

// Get badge based on style name (for badge-based styles only)
#let get-badge(style, label, number, font-size, color, is-solution) = {
  if style == "circled" {
    badge-circled(label, number, font-size, color, is-solution)
  } else if style == "filled-circle" {
    badge-filled-circle(label, number, font-size, color, is-solution)
  } else if style == "pill" {
    badge-pill(label, number, font-size, color, is-solution)
  } else if style == "tag" {
    badge-tag(label, number, font-size, color, is-solution)
  } else {
    // Default: box
    badge-box(label, number, font-size, color, is-solution)
  }
}

// Check if style is a "full-width" style (wraps content instead of badge+content grid)
#let is-fullwidth-style(style) = {
  style in ("border-accent", "underline", "rounded-box", "header-card")
}

// =============================================================================
// Full-Width Styles (wrap entire content)
// =============================================================================

// Style: border-accent - Left vertical bar with inline header
#let style-border-accent(label, number, body, font-size, color, is-solution) = {
  let bar-color = color
  block(
    stroke: (left: 3pt + bar-color),
    inset: (left: 12pt, y: 8pt),
    width: 100%,
  )[
    #text(weight: "bold", size: font-size, fill: bar-color)[#label~#number]
    #v(0.3em)
    #body
  ]
}

// Style: underline - Bold header with underline
#let style-underline(label, number, body, font-size, color, is-solution) = {
  let line-color = color
  block(width: 100%)[
    #text(weight: "bold", size: font-size + 1pt, fill: line-color)[#label~#number]
    #v(-0.3em)
    #line(length: 100%, stroke: 0.8pt + line-color)
    #v(0.5em)
    #body
  ]
}

// Style: rounded-box - Clean rounded border around entire exercise
#let style-rounded-box(label, number, body, font-size, color, is-solution) = {
  let border-color = color
  block(
    width: 100%,
    stroke: 1.2pt + border-color,
    radius: 10pt,
    inset: 14pt,
  )[
    #text(weight: "bold", size: font-size, fill: border-color)[#label~#number]
    #v(8pt)
    #body
  ]
}

// Style: header-card - Rounded box with colored header strip
#let style-header-card(label, number, body, font-size, color, is-solution) = {
  let header-color = color
  block(
    width: 100%,
    stroke: 1pt + header-color,
    radius: 8pt,
    clip: true,
  )[
    #block(
      width: 100%,
      fill: header-color,
      inset: (x: 12pt, y: 6pt),
    )[
      #text(weight: "bold", size: font-size, fill: white)[#label~#number]
    ]
    #block(
      width: 100%,
      inset: 12pt,
    )[#body]
  ]
}

// Get full-width style block
#let get-fullwidth-style(style, label, number, body, font-size, color, is-solution) = {
  if style == "border-accent" {
    style-border-accent(label, number, body, font-size, color, is-solution)
  } else if style == "underline" {
    style-underline(label, number, body, font-size, color, is-solution)
  } else if style == "rounded-box" {
    style-rounded-box(label, number, body, font-size, color, is-solution)
  } else if style == "header-card" {
    style-header-card(label, number, body, font-size, color, is-solution)
  } else {
    // Fallback - should not happen
    body
  }
}

// Compute margin for badge layout (fits "Correction 100")
#let compute-margin(font-size: 11pt) = {
  let test-badge = box(
    stroke: 0.8pt,
    inset: (x: 4pt, y: 3pt),
    text(weight: "bold", size: font-size)[Correction 100],
  )
  measure(test-badge).width + 12pt
}

// Layout function for custom badge styles
#let exo-layout(badge, body, margin: auto) = context {
  let m = if margin == auto { compute-margin() } else { margin }
  grid(
    columns: (m, 1fr),
    column-gutter: 8pt,
    align(right + top)[#badge],
    body,
  )
}

// Competency tag styling
#let competency-tag(comp) = {
  box(
    fill: rgb("#e3f2fd"),
    stroke: 0.5pt + rgb("#1976d2"),
    radius: 3pt,
    inset: (x: 4pt, y: 2pt),
    text(size: 8pt, fill: rgb("#1565c0"))[#comp]
  )
}

#let exo-box(
  label: "Exercice",
  number: 1,
  body,
  box-type: "exercise",    // "exercise", "solution", or "correction"
  exercise-id: none,       // For UID display
  show-id: false,          // Whether to show the UID
  competencies: (),        // List of competencies
  show-competencies: false, // Whether to show competencies
  points: none,            // Points for exam mode
  points-label: "pts",     // Label for points (e.g., "pts", "points")
  margin-content: none,    // Optional content below the badge (e.g., QR code, remarks)
) = context {
  let cfg = exo-config.get()

  // Determine the color based on box type
  let actual-color = if box-type == "solution" {
    cfg.solution-color
  } else if box-type == "correction" {
    cfg.correction-color
  } else {
    cfg.badge-color
  }

  // Is this a solution or correction (for styling purposes)?
  let is-solution = box-type == "solution" or box-type == "correction"

  // Determine spacing based on box type
  let (space-above, space-below) = if box-type == "solution" {
    (cfg.solution-above, cfg.solution-below)
  } else if box-type == "correction" {
    (cfg.correction-above, cfg.correction-below)
  } else {
    (cfg.exercise-above, cfg.exercise-below)
  }

  // Competencies display
  let comp-block = if show-competencies and competencies.len() > 0 {
    v(4pt)
    for comp in competencies {
      competency-tag(comp)
      h(4pt)
    }
  }

  // ID display
  let id-display = if show-id and exercise-id != none {
    text(size: 7pt, fill: rgb("#666666"), style: "italic")[#exercise-id]
  }

  // Full body with competencies
  let full-body = {
    set par(first-line-indent: 0cm)
    body
    if show-competencies and competencies.len() > 0 { comp-block }
    if show-id and exercise-id != none {
      v(4pt)
      id-display
    }
  }

  // Check if this is a full-width style
  if is-fullwidth-style(cfg.badge-style) {
    // Use full-width layout (style wraps the content)
    block(
      above: space-above,
      below: space-below,
      width: 100%,
      breakable: true,
    )[
      #get-fullwidth-style(
        cfg.badge-style,
        label,
        number,
        full-body,
        cfg.label-font-size,
        actual-color,
        is-solution,
      )
    ]
  } else {
    // Use badge + grid layout
    let badge = get-badge(
      cfg.badge-style,
      label,
      number,
      cfg.label-font-size,
      actual-color,
      is-solution,
    )

    // Badge with optional points displayed inline after the box
    let badge-with-points = if points != none {
      box[#badge#h(6pt)#text(size: 9pt, fill: rgb("#555"), style: "italic")[(#points #points-label)]]
    } else {
      badge
    }

    // ID display below badge (for badge styles)
    let id-block = if show-id and exercise-id != none {
      linebreak()
      text(size: 7pt, fill: rgb("#666666"), style: "italic")[#exercise-id]
    }

    // Build the label column content
    let label-column = {
      set text(hyphenate: false)
      align(right)[
        #box[#badge-with-points]
        #if show-id and exercise-id != none { id-block }
        #if margin-content != none {
          v(4pt)
          margin-content
        }
      ]
    }

    // Margin position and label space (like environments)
    // If margin-position is auto, compute based on badge style and label size
    let margin-pos = if cfg.margin-position == auto {
      calc-default-margin(font-size: cfg.label-font-size, style: cfg.badge-style)
    } else {
      cfg.margin-position
    }
    let label-extra = cfg.label-extra
    let gap = 6pt

    // Use grid - shifted left so labels can extend into page margin
    block(
      above: space-above,
      below: space-below,
      width: 100% + label-extra,
      breakable: true,
      inset: (left: -label-extra, right: label-extra),  // Add right margin to compensate
    )[
      #grid(
        columns: (margin-pos + label-extra, 1fr),
        column-gutter: gap,
        align: (right + top, left + top),
        // Label column - has space for label, right-aligned
        label-column,
        // Content column
        block(
          width: 100%,
          inset: (left: 0pt, y: 0pt),
          breakable: true,
        )[
          #set par(first-line-indent: 0cm)
          #v(3pt)  // Align with badge text
          #body
          #if show-competencies and competencies.len() > 0 { comp-block }
        ],
      )
    ]
  }
}

#let exo-solution-box(number: 1, body, exercise-id: none, show-id: false) = context {
  let cfg = exo-config.get()
  exo-box(
    label: cfg.solution-label,
    number: number,
    body,
    box-type: "solution",
    exercise-id: exercise-id,
    show-id: show-id,
  )
}

#let exo-correction-box(number: 1, body, exercise-id: none, show-id: false) = context {
  let cfg = exo-config.get()
  exo-box(
    label: cfg.correction-label,
    number: number,
    body,
    box-type: "correction",
    exercise-id: exercise-id,
    show-id: show-id,
  )
}

// =============================================================================
// Helper Functions for Content Display
// =============================================================================

// Check if content is empty (none or empty content block)
#let is-empty-content(content) = {
  content == none or repr(content) == "[]"
}

// Apply placeholder if content is empty (only in draft mode)
#let apply-placeholder(content, placeholder, draft-mode) = {
  if is-empty-content(content) {
    if draft-mode {
      placeholder
    } else {
      [ ]  // Empty space to maintain box/counter
    }
  } else {
    content
  }
}

// Determine what content to show based on corrDisplay mode and exercise flags
// Returns: array of (type: "solution" or "correction", content: content) - may contain 0, 1, or 2 items
#let determine-content-to-show(solution, correction, cfg, exercise-flags) = {
  let solInCorr = exercise-flags.at("solInCorr", default: false)
  let showCorr = exercise-flags.at("showCorr", default: false)
  let items = ()

  if cfg.corrDisplay == "solution" {
    // Only show solution
    if solution != none {
      let sol-content = apply-placeholder(solution, cfg.solution-placeholder, cfg.draft-mode)
      items.push((type: "solution", content: sol-content))
    }
  } else if cfg.corrDisplay == "correction" {
    // Show correction, and also solution if solInCorr is false
    if correction != none {
      let corr-content = apply-placeholder(correction, cfg.correction-placeholder, cfg.draft-mode)
      items.push((type: "correction", content: corr-content))
    }
    // If solution is NOT already in correction, also show solution
    if not solInCorr and solution != none {
      let sol-content = apply-placeholder(solution, cfg.solution-placeholder, cfg.draft-mode)
      items.push((type: "solution", content: sol-content))
    }
  } else {
    // "mixed" mode: default to solution, but use correction for exercises with showCorr: true
    if showCorr and correction != none {
      let corr-content = apply-placeholder(correction, cfg.correction-placeholder, cfg.draft-mode)
      items.push((type: "correction", content: corr-content))
      // Also show solution if not already in correction
      if not solInCorr and solution != none {
        let sol-content = apply-placeholder(solution, cfg.solution-placeholder, cfg.draft-mode)
        items.push((type: "solution", content: sol-content))
      }
    } else if solution != none {
      let sol-content = apply-placeholder(solution, cfg.solution-placeholder, cfg.draft-mode)
      items.push((type: "solution", content: sol-content))
    } else if correction != none {
      // Fallback to correction if no solution
      let corr-content = apply-placeholder(correction, cfg.correction-placeholder, cfg.draft-mode)
      items.push((type: "correction", content: corr-content))
    }
  }

  items
}

// =============================================================================
// Main Exercise Function
// =============================================================================

#let exo(
  exercise: none,
  solution: none,
  correction: none,
  id: auto,
  margin-content: none,  // Optional content below the badge (e.g., QR code, remarks)
  // Exercise-level display flags
  sol-in-corr: false,      // If true, correction already contains solution (use solution in "correction" mode)
  show-corr: false,       // If true, show correction in "mixed" mode
  // Metadata fields
  topic: none,
  level: none,
  authors: (),  // Array of authors, e.g., ("Nathan", "Raph")
  ..extra-metadata
) = {
  // Step counter first (outside context)
  exo-counter.step()

  context {
    let cfg = exo-config.get()

    // Get number after stepping
    let num = exo-counter.get().first()

  // Generate or use provided ID
  let exercise-id = if id == auto {
    "exo-" + str(num)
  } else {
    id
  }

  // Build metadata dictionary
  let metadata = (
    topic: topic,
    level: level,
    authors: authors,
  )
  // Add extra metadata
  for (key, value) in extra-metadata.named() {
    metadata.insert(key, value)
  }

  // Build exercise flags
  let exercise-flags = (
    solInCorr: sol-in-corr,
    showCorr: show-corr,
  )

  // Create exercise record
  let exercise-record = (
    id: exercise-id,
    number: num,
    metadata: metadata,
    exercise: exercise,
    solution: solution,
    correction: correction,
    margin-content: margin-content,
    solInCorr: sol-in-corr,
    showCorr: show-corr,
  )

  // Register exercise
  exo-registry.update(reg => {
    reg.push(exercise-record)
    reg
  })

  // Display based on show mode
  if cfg.display == "sol" {
    // Only show solution/correction
    let items-to-show = determine-content-to-show(solution, correction, cfg, exercise-flags)
    for item in items-to-show {
      if item.type == "solution" {
        exo-solution-box(number: num, item.content, exercise-id: exercise-id, show-id: cfg.show-id)
      } else {
        exo-correction-box(number: num, item.content, exercise-id: exercise-id, show-id: cfg.show-id)
      }
    }
  } else if cfg.display == "ex" {
    // Only show exercise
    exo-box(
      label: get-exercise-label(cfg, metadata),
      number: num,
      exercise,
      exercise-id: exercise-id,
      show-id: cfg.show-id,
      margin-content: margin-content,
    )
  } else {
    // "both" mode - show exercise and solution/correction

    // Show exercise
    exo-box(
      label: get-exercise-label(cfg, metadata),
      number: num,
      exercise,
      exercise-id: exercise-id,
      show-id: cfg.show-id,
      margin-content: margin-content,
    )

    // Handle solution/correction display
    let items-to-show = determine-content-to-show(solution, correction, cfg, exercise-flags)

    if items-to-show.len() > 0 {
      if cfg.corrLoc == "after" {
        for item in items-to-show {
          if item.type == "solution" {
            exo-solution-box(number: num, item.content, exercise-id: exercise-id, show-id: cfg.show-id)
          } else {
            exo-correction-box(number: num, item.content, exercise-id: exercise-id, show-id: cfg.show-id)
          }
        }
      } else if cfg.corrLoc == "pagebreak" {
        pagebreak(weak: true)
        for item in items-to-show {
          if item.type == "solution" {
            exo-solution-box(number: num, item.content, exercise-id: exercise-id, show-id: cfg.show-id)
          } else {
            exo-correction-box(number: num, item.content, exercise-id: exercise-id, show-id: cfg.show-id)
          }
        }
      } else if cfg.corrLoc == "end-section" or cfg.corrLoc == "end-chapter" {
        // Store for later display
        for item in items-to-show {
          exo-pending-solutions.update(pending => {
            pending.push((number: num, content: item.content, type: item.type, id: exercise-id))
            pending
          })
        }
      }
    }
  }
  }  // close context
}  // close function

// =============================================================================
// Solution Display Functions
// =============================================================================

#let exo-print-solutions(title: auto) = context {
  let cfg = exo-config.get()
  let pending = exo-pending-solutions.get()

  if pending.len() > 0 {
    let section-title = if title == auto {
      cfg.solution-label + "s"
    } else {
      title
    }

    v(1em)
    text(weight: "bold", size: 12pt)[#section-title]
    v(0.5em)

    for item in pending {
      let content = item.at("content", default: none)
      let item-type = item.at("type", default: "solution")

      if item-type == "solution" {
        exo-solution-box(
          number: item.number,
          content,
          exercise-id: item.at("id", default: none),
          show-id: cfg.show-id,
        )
      } else {
        exo-correction-box(
          number: item.number,
          content,
          exercise-id: item.at("id", default: none),
          show-id: cfg.show-id,
        )
      }
    }
  }

  // Clear pending solutions
  exo-pending-solutions.update(())
}

#let exo-section-end() = context {
  let cfg = exo-config.get()
  if cfg.corrLoc == "end-section" {
    exo-print-solutions()
  }
}

#let exo-chapter-end() = context {
  let cfg = exo-config.get()
  if cfg.corrLoc == "end-chapter" {
    exo-print-solutions()
  }
}

// =============================================================================
// Filtering Function
// =============================================================================

#let exo-filter(
  topic: none,
  level: none,
  author: none,  // Filter: matches if author is in exercise's authors array
  custom: none,  // Function (metadata) => bool
  show-solutions: true,
) = context {
  let cfg = exo-config.get()
  let registry = exo-registry.get()

  for exercise in registry {
    let meta = exercise.metadata
    let matches = true

    // Check filters
    if topic != none and meta.topic != topic { matches = false }
    if level != none and meta.level != level { matches = false }
    // Author filter: check if author is in the authors array
    if author != none {
      let ex-authors = meta.at("authors", default: ())
      if author not in ex-authors { matches = false }
    }
    if custom != none and not custom(meta) { matches = false }

    if matches {
      // Build exercise flags from stored data
      let exercise-flags = (
        solInCorr: exercise.at("solInCorr", default: false),
        showCorr: exercise.at("showCorr", default: false),
      )

      if cfg.display != "sol" {
        exo-box(
          label: get-exercise-label(cfg, meta),
          number: exercise.number,
          exercise.exercise,
          exercise-id: exercise.id,
          show-id: cfg.show-id,
        )
      }

      // Handle solution/correction display
      if show-solutions and cfg.display != "ex" {
        let sol = exercise.at("solution", default: none)
        let corr = exercise.at("correction", default: none)
        let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags)

        for item in items-to-show {
          if item.type == "solution" {
            exo-solution-box(
              number: exercise.number,
              item.content,
              exercise-id: exercise.id,
              show-id: cfg.show-id,
            )
          } else {
            exo-correction-box(
              number: exercise.number,
              item.content,
              exercise-id: exercise.id,
              show-id: cfg.show-id,
            )
          }
        }
      }
    }
  }
}

// =============================================================================
// Exercise Bank Functions (define without display)
// =============================================================================

// Define an exercise without displaying it (for exercise banks)
#let exo-define(
  exercise: none,
  solution: none,
  correction: none,
  id: auto,
  competencies: (),  // List of competency tags
  points: none,      // Points for exam mode
  // Exercise-level display flags
  sol-in-corr: false,      // If true, correction already contains solution
  show-corr: false,       // If true, show correction in "mixed" mode
  // Metadata fields
  topic: none,
  level: none,
  authors: (),  // Array of authors, e.g., ("Nathan", "Raph")
  ..extra-metadata
) = {
  // Generate unique ID using counter
  exo-id-counter.step()

  context {
    let id-num = exo-id-counter.get().first()

    // Generate or use provided ID
    let exercise-id = if id == auto {
      "bank-" + str(id-num)
    } else {
      id
    }

    // Build metadata dictionary
    let metadata = (
      topic: topic,
      level: level,
      authors: authors,
    )
    // Add extra metadata
    for (key, value) in extra-metadata.named() {
      metadata.insert(key, value)
    }

    // Create exercise record (number will be assigned when displayed)
    let exercise-record = (
      id: exercise-id,
      number: none,  // Not yet assigned
      metadata: metadata,
      exercise: exercise,
      solution: solution,
      correction: correction,
      competencies: competencies,
      points: points,
      solInCorr: sol-in-corr,
      showCorr: show-corr,
    )

    // Register exercise without displaying
    exo-registry.update(reg => {
      reg.push(exercise-record)
      reg
    })
  }
}

// Show a specific exercise by ID
#let exo-show(
  id,
  show-solution: auto,  // auto = use current config
) = {
  exo-counter.step()

  context {
    let cfg = exo-config.get()
    let registry = exo-registry.get()
    let num = exo-counter.get().first()

    // Apply page break before if configured
    if cfg.page-break == "before" or cfg.page-break == "around" {
      pagebreak(weak: true)
    }

    // Find exercise by ID
    let found = none
    for exercise in registry {
      if exercise.id == id {
        found = exercise
        break
      }
    }

    if found != none {
      // Determine if we should show solution
      let do-show-solution = if show-solution == auto {
        cfg.display != "ex"
      } else {
        show-solution
      }

      // Get competencies and points (with defaults for backward compatibility)
      let comps = found.at("competencies", default: ())
      let pts = found.at("points", default: none)

      // Get solution and correction
      let sol = found.at("solution", default: none)
      let corr = found.at("correction", default: none)

      // Build exercise flags
      let exercise-flags = (
        solInCorr: found.at("solInCorr", default: false),
        showCorr: found.at("showCorr", default: false),
      )

      // Check display mode
      if cfg.display-mode == "exam" {
        // EXAM MODE: Use exo-box with points
        let exam-cfg = exam-config.get()

        // Display exercise with points in the badge
        exo-box(
          label: get-exercise-label(cfg, found.metadata),
          number: num,
          found.exercise,
          exercise-id: found.id,
          show-id: cfg.show-id,
          competencies: comps,
          show-competencies: cfg.show-competencies,
          points: pts,
        )

        // Show solution if configured
        if exam-cfg.show-solutions {
          let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags)
          for item in items-to-show {
            exam-solution-box(item.content)
          }
        }
      } else {
        // EXERCISE MODE: Use default exo-box format (no points)
        // Display exercise based on show mode
        if cfg.display != "sol" {
          exo-box(
            label: get-exercise-label(cfg, found.metadata),
            number: num,
            found.exercise,
            exercise-id: found.id,
            show-id: cfg.show-id,
            competencies: comps,
            show-competencies: cfg.show-competencies,
          )
        }

        // Determine what content to show
        let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags)

        // Handle solution/correction display
        if items-to-show.len() > 0 and (cfg.display == "sol" or (cfg.display == "both" and do-show-solution)) {
          if cfg.corrLoc == "after" or cfg.display == "sol" {
            for item in items-to-show {
              if item.type == "solution" {
                exo-solution-box(number: num, item.content, exercise-id: found.id, show-id: cfg.show-id)
              } else {
                exo-correction-box(number: num, item.content, exercise-id: found.id, show-id: cfg.show-id)
              }
            }
          } else if cfg.corrLoc == "pagebreak" {
            pagebreak(weak: true)
            for item in items-to-show {
              if item.type == "solution" {
                exo-solution-box(number: num, item.content, exercise-id: found.id, show-id: cfg.show-id)
              } else {
                exo-correction-box(number: num, item.content, exercise-id: found.id, show-id: cfg.show-id)
              }
            }
          } else if cfg.corrLoc == "end-section" or cfg.corrLoc == "end-chapter" {
            for item in items-to-show {
              exo-pending-solutions.update(pending => {
                pending.push((number: num, content: item.content, type: item.type, id: found.id))
                pending
              })
            }
          }
        }
      }

      // Apply page break after if configured
      if cfg.page-break == "after" or cfg.page-break == "around" {
        pagebreak(weak: true)
      }
    } else {
      text(fill: red)[*Error: Exercise "#id" not found*]
    }
  }
}

// Show multiple exercises by IDs
#let exo-show-many(..ids, show-solution: auto) = {
  for id in ids.pos() {
    exo-show(id, show-solution: show-solution)
  }
}

// =============================================================================
// Advanced Filtering
// =============================================================================

// Filter and display exercises with flexible criteria
#let exo-select(
  // Simple filters (match exact value)
  topic: none,
  level: none,
  author: none,       // Filter: matches if author is in exercise's authors array
  competency: none,   // Filter by single competency
  // List filters (match any in list)
  topics: none,       // e.g., ("algebra", "geometry")
  levels: none,       // e.g., ("1M", "2M")
  competencies: none, // e.g., ("C1.1", "C2.3") - match any
  // Custom filter function
  where: none,       // Function (exercise) => bool
  // Display options
  show-solutions: auto,
  renumber: true,    // Renumber exercises sequentially
  max: none,         // Maximum number to show
  shuffle: false,    // Randomize order (needs seed)
) = context {
  let cfg = exo-config.get()
  let registry = exo-registry.get()

  // Determine solution display
  let do-show-solutions = if show-solutions == auto {
    cfg.display != "ex"
  } else {
    show-solutions
  }

  // Filter exercises
  let filtered = ()
  for exercise in registry {
    let meta = exercise.metadata
    let matches = true

    // Simple exact filters
    if topic != none and meta.topic != topic { matches = false }
    if level != none and meta.level != level { matches = false }
    // Author filter: check if author is in the authors array
    if author != none {
      let ex-authors = meta.at("authors", default: ())
      if author not in ex-authors { matches = false }
    }

    // List filters (match any)
    if topics != none {
      let found = false
      for t in topics {
        if meta.topic == t { found = true; break }
      }
      if not found { matches = false }
    }
    if levels != none {
      let found = false
      for l in levels {
        if meta.level == l { found = true; break }
      }
      if not found { matches = false }
    }

    // Competency filters
    let ex-comps = exercise.at("competencies", default: ())
    if competency != none {
      if competency not in ex-comps { matches = false }
    }
    if competencies != none {
      let found = false
      for c in competencies {
        if c in ex-comps { found = true; break }
      }
      if not found { matches = false }
    }

    // Custom filter
    if where != none and not where(exercise) { matches = false }

    if matches {
      filtered.push(exercise)
    }
  }

  // Apply max limit
  if max != none and filtered.len() > max {
    filtered = filtered.slice(0, max)
  }

  // Display filtered exercises
  let display-num = 0
  for exercise in filtered {
    display-num += 1
    let num = if renumber { display-num } else { exercise.number }
    let ex-comps = exercise.at("competencies", default: ())
    let pts = exercise.at("points", default: none)
    let sol = exercise.at("solution", default: none)
    let corr = exercise.at("correction", default: none)

    // Build exercise flags
    let exercise-flags = (
      solInCorr: exercise.at("solInCorr", default: false),
      showCorr: exercise.at("showCorr", default: false),
    )

    // Apply page break before if configured
    if cfg.page-break == "before" or cfg.page-break == "around" {
      pagebreak(weak: true)
    }

    // Check display mode
    if cfg.display-mode == "exam" {
      // EXAM MODE: Use exo-box with points
      let exam-cfg = exam-config.get()

      // Display exercise with points in the badge
      exo-box(
        label: get-exercise-label(cfg, exercise.metadata),
        number: num,
        exercise.exercise,
        exercise-id: exercise.id,
        show-id: cfg.show-id,
        competencies: ex-comps,
        show-competencies: cfg.show-competencies,
        points: pts,
      )

      // Show solution if configured
      if exam-cfg.show-solutions {
        let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags)
        for item in items-to-show {
          exam-solution-box(item.content)
        }
      }
    } else {
      // EXERCISE MODE: Use default exo-box format (no points)
      if cfg.display != "sol" {
        exo-box(
          label: get-exercise-label(cfg, exercise.metadata),
          number: num,
          exercise.exercise,
          exercise-id: exercise.id,
          show-id: cfg.show-id,
          competencies: ex-comps,
          show-competencies: cfg.show-competencies,
        )
      }

      // Determine what content to show
      let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags)

      if items-to-show.len() > 0 and (cfg.display == "sol" or do-show-solutions) {
        if cfg.corrLoc == "after" or cfg.display == "sol" {
          for item in items-to-show {
            if item.type == "solution" {
              exo-solution-box(
                number: num,
                item.content,
                exercise-id: exercise.id,
                show-id: cfg.show-id,
              )
            } else {
              exo-correction-box(
                number: num,
                item.content,
                exercise-id: exercise.id,
                show-id: cfg.show-id,
              )
            }
          }
        } else if cfg.corrLoc == "pagebreak" {
          pagebreak(weak: true)
          for item in items-to-show {
            if item.type == "solution" {
              exo-solution-box(number: num, item.content, exercise-id: exercise.id, show-id: cfg.show-id)
            } else {
              exo-correction-box(number: num, item.content, exercise-id: exercise.id, show-id: cfg.show-id)
            }
          }
        } else if cfg.corrLoc == "end-section" or cfg.corrLoc == "end-chapter" {
          for item in items-to-show {
            exo-pending-solutions.update(pending => {
              pending.push((number: num, content: item.content, type: item.type, id: exercise.id))
              pending
            })
          }
        }
      }
    }

    // Apply page break after if configured
    if cfg.page-break == "after" or cfg.page-break == "around" {
      pagebreak(weak: true)
    }
  }
}

// =============================================================================
// Utility Functions
// =============================================================================

#let exo-get-registry() = context {
  exo-registry.get()
}

#let exo-clear-registry() = {
  exo-registry.update(())
}

// Count exercises matching criteria
#let exo-count(
  topic: none,
  level: none,
  author: none,  // Filter: matches if author is in exercise's authors array
) = context {
  let registry = exo-registry.get()
  let count = 0

  for exercise in registry {
    let meta = exercise.metadata
    let matches = true

    if topic != none and meta.topic != topic { matches = false }
    if level != none and meta.level != level { matches = false }
    // Author filter: check if author is in the authors array
    if author != none {
      let ex-authors = meta.at("authors", default: ())
      if author not in ex-authors { matches = false }
    }

    if matches { count += 1 }
  }

  count
}

// =============================================================================
// Exam Integration (g-exam wrapper)
// =============================================================================

// Re-export g-exam functions for direct use
#let exam-template = g-exam-template
#let exam-question-raw = g-exam-question
#let exam-subquestion = g-exam-subquestion

// Custom score table that works with exo-box questions
#let exam-score-table(
  ..exercise-ids,
  question-label: "Question",
  points-label: "Points",
  grade-label: "Note",
  total-label: "Total",
) = context {
  let registry = exo-registry.get()
  let ids = exercise-ids.pos()

  // Collect points for each exercise
  let points-list = ()
  let total = 0

  for (idx, id) in ids.enumerate() {
    for exercise in registry {
      if exercise.id == id {
        let pts = exercise.at("points", default: 0)
        points-list.push((num: idx + 1, points: pts))
        total += pts
        break
      }
    }
  }

  // Build table
  let cols = points-list.len() + 1

  table(
    columns: (auto,) * (cols + 1),
    align: center,
    stroke: 0.5pt,
    // Header row
    [*#question-label*], ..points-list.map(p => str(p.num)), [*#total-label*],
    // Points row
    [*#points-label*], ..points-list.map(p => str(p.points)), [*#total*],
    // Grade row (empty for filling in)
    [*#grade-label*], ..points-list.map(p => []), [],
  )
}

// Setup exam configuration (exam-config state is defined at top of file)
#let exam-setup(
  show-solutions: none,
  solution-label: none,
  solution-fill: none,
  solution-stroke: none,
  solution-radius: none,
  solution-inset: none,
  solution-label-color: none,
  question-spacing: none,
) = {
  exam-config.update(cfg => {
    let new = cfg
    if show-solutions != none { new.show-solutions = show-solutions }
    if solution-label != none { new.solution-label = solution-label }
    if solution-fill != none { new.solution-fill = solution-fill }
    if solution-stroke != none { new.solution-stroke = solution-stroke }
    if solution-radius != none { new.solution-radius = solution-radius }
    if solution-inset != none { new.solution-inset = solution-inset }
    if solution-label-color != none { new.solution-label-color = solution-label-color }
    if question-spacing != none { new.question-spacing = question-spacing }
    new
  })
}

// exam-solution-box is defined at top of file

// Display an exercise from the bank as a g-exam question
#let exam-question(
  id,
  points: auto,  // auto = use points from exercise, or specify manually
  supplement: none,  // Additional content after the question
) = context {
  let registry = exo-registry.get()
  let exam-cfg = exam-config.get()
  let cfg = exo-config.get()

  // Find exercise by ID
  let found = none
  for exercise in registry {
    if exercise.id == id {
      found = exercise
      break
    }
  }

  if found != none {
    // Determine points
    let pts = if points == auto {
      found.at("points", default: none)
    } else {
      points
    }

    // Build exercise flags
    let exercise-flags = (
      solInCorr: found.at("solInCorr", default: false),
      showCorr: found.at("showCorr", default: false),
    )

    // Build question content
    let q-content = {
      found.exercise
      if supplement != none {
        supplement
      }
      // Show solution if configured
      if exam-cfg.show-solutions {
        let sol = found.at("solution", default: none)
        let corr = found.at("correction", default: none)
        let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags)
        for item in items-to-show {
          v(8pt)
          exam-solution-box(item.content)
        }
      }
    }

    // Display as g-exam question
    if pts != none {
      g-exam-question(points: pts, q-content)
    } else {
      g-exam-question(q-content)
    }
  } else {
    text(fill: red)[*Error: Exercise "#id" not found*]
  }
}

// Display multiple exercises from the bank as g-exam questions
#let exam-question-many(..ids, points: auto) = {
  for id in ids.pos() {
    exam-question(id, points: points)
  }
}

// Select and display exercises as g-exam questions with filtering
#let exam-select(
  // Simple filters (match exact value)
  topic: none,
  level: none,
  author: none,  // Filter: matches if author is in exercise's authors array
  competency: none,
  // List filters (match any in list)
  topics: none,
  levels: none,
  competencies: none,
  // Custom filter function
  where: none,
  // Display options
  max: none,
  points: auto,  // auto = use from exercise, or override all
) = context {
  let exam-cfg = exam-config.get()
  let cfg = exo-config.get()
  let registry = exo-registry.get()

  // Filter exercises
  let filtered = ()
  for exercise in registry {
    let meta = exercise.metadata
    let matches = true

    // Simple exact filters
    if topic != none and meta.topic != topic { matches = false }
    if level != none and meta.level != level { matches = false }
    // Author filter: check if author is in the authors array
    if author != none {
      let ex-authors = meta.at("authors", default: ())
      if author not in ex-authors { matches = false }
    }

    // List filters (match any)
    if topics != none {
      let found = false
      for t in topics {
        if meta.topic == t { found = true; break }
      }
      if not found { matches = false }
    }
    if levels != none {
      let found = false
      for l in levels {
        if meta.level == l { found = true; break }
      }
      if not found { matches = false }
    }

    // Competency filters
    let ex-comps = exercise.at("competencies", default: ())
    if competency != none {
      if competency not in ex-comps { matches = false }
    }
    if competencies != none {
      let found = false
      for c in competencies {
        if c in ex-comps { found = true; break }
      }
      if not found { matches = false }
    }

    // Custom filter
    if where != none and not where(exercise) { matches = false }

    if matches {
      filtered.push(exercise)
    }
  }

  // Apply max limit
  if max != none and filtered.len() > max {
    filtered = filtered.slice(0, max)
  }

  // Display as g-exam questions
  for exercise in filtered {
    // Determine points
    let pts = if points == auto {
      exercise.at("points", default: none)
    } else {
      points
    }

    // Build exercise flags
    let exercise-flags = (
      solInCorr: exercise.at("solInCorr", default: false),
      showCorr: exercise.at("showCorr", default: false),
    )

    // Build question content
    let q-content = {
      exercise.exercise
      // Show solution if configured
      if exam-cfg.show-solutions {
        let sol = exercise.at("solution", default: none)
        let corr = exercise.at("correction", default: none)
        let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags)
        for item in items-to-show {
          v(8pt)
          exam-solution-box(item.content)
        }
      }
    }

    // Display as g-exam question
    if pts != none {
      g-exam-question(points: pts, q-content)
    } else {
      g-exam-question(q-content)
    }
  }
}
