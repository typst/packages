// exercise-bank - Exercise Package for Typst
// Handles exercises with metadata, content, and solutions
// Supports multiple display modes and filtering

// =============================================================================
// External Package Imports
// =============================================================================

#import "@preview/tiaoma:0.3.0": qrcode as _tiaoma-qrcode
#import "@preview/wrap-it:0.1.1": wrap-content as _wrap-content

// =============================================================================
// State and Counters
// =============================================================================

#let optional-star-icon(size: 0.62em, fill: black) = box(width: size, height: size, inset: 0pt)[
  #polygon(
    fill: fill,
    (0.50 * size, 0.00 * size),
    (0.62 * size, 0.34 * size),
    (0.98 * size, 0.35 * size),
    (0.69 * size, 0.56 * size),
    (0.79 * size, 0.91 * size),
    (0.50 * size, 0.70 * size),
    (0.21 * size, 0.91 * size),
    (0.31 * size, 0.56 * size),
    (0.02 * size, 0.35 * size),
    (0.38 * size, 0.34 * size),
  )
]

// Diagonal dumbbell (haltère, fitness-icon convention): marks exercises whose
// correction will be handed out — students train on their own with the corrigé.
// Solid silhouette, readable at badge size; students learn the icon, no
// explanatory text needed.
#let corr-given-icon(size: 0.75em) = box(width: size, height: size, inset: 0pt)[
  #place(top + left, rotate(-45deg, origin: center, box(width: size, height: size)[
    #place(top + left, dx: 0.02 * size, dy: 0.28 * size,
      rect(width: 0.17 * size, height: 0.44 * size, fill: black, radius: 0.04 * size))
    #place(top + left, dx: 0.81 * size, dy: 0.28 * size,
      rect(width: 0.17 * size, height: 0.44 * size, fill: black, radius: 0.04 * size))
    #place(top + left, dx: 0.17 * size, dy: 0.425 * size,
      rect(width: 0.66 * size, height: 0.15 * size, fill: black))
  ]))
]

// Difficulty icons, one per level of the default scale (same drawn-icon
// convention as the markers above). The level-to-icon mapping is fully
// configurable via difficulty-scale.

// Level 1 (introductory): seedling
#let difficulty-seedling-icon(size: 0.75em, fill: black) = box(width: size, height: size, inset: 0pt)[
  #place(top + left, dx: 0.46 * size, dy: 0.40 * size,
    rect(width: 0.10 * size, height: 0.55 * size, fill: fill))
  #place(top + left, polygon(fill: fill,
    (0.51 * size, 0.52 * size),
    (0.10 * size, 0.44 * size),
    (0.24 * size, 0.10 * size),
  ))
  #place(top + left, polygon(fill: fill,
    (0.51 * size, 0.52 * size),
    (0.92 * size, 0.44 * size),
    (0.78 * size, 0.10 * size),
  ))
]

// Level 2 (standard): pencil
#let difficulty-pencil-icon(size: 0.75em, fill: black) = box(width: size, height: size, inset: 0pt)[
  #place(top + left, rotate(45deg, origin: center, box(width: size, height: size)[
    #place(top + left, dx: 0.40 * size, dy: 0.02 * size,
      rect(width: 0.20 * size, height: 0.62 * size, fill: fill, radius: (top: 0.05 * size)))
    #place(top + left, polygon(fill: fill,
      (0.40 * size, 0.70 * size),
      (0.60 * size, 0.70 * size),
      (0.50 * size, 0.96 * size),
    ))
  ]))
]

// Level 3 (exam-type): target
#let difficulty-target-icon(size: 0.75em, fill: black) = box(width: size, height: size, inset: 0pt)[
  #place(center + horizon, circle(radius: 0.42 * size, stroke: 0.09 * size + fill))
  #place(center + horizon, circle(radius: 0.14 * size, fill: fill))
]

// Level 4 (advanced): mountain
#let difficulty-mountain-icon(size: 0.75em, fill: black) = box(width: size, height: size, inset: 0pt)[
  #place(top + left, polygon(fill: fill,
    (0.00 * size, 0.90 * size),
    (0.36 * size, 0.16 * size),
    (0.60 * size, 0.62 * size),
    (0.50 * size, 0.90 * size),
  ))
  #place(top + left, polygon(fill: fill,
    (0.34 * size, 0.90 * size),
    (0.66 * size, 0.34 * size),
    (1.00 * size, 0.90 * size),
  ))
]

// Level 5 (expert): star
#let difficulty-star-icon(size: 0.72em, fill: black) = optional-star-icon(size: size, fill: fill)

// Arrow icons for the clickable exercise <-> correction links
#let solution-link-icon(size: 0.7em, fill: black) = box(width: size, height: size, inset: 0pt)[
  #place(top + left, dx: 0pt, dy: 0.40 * size,
    rect(width: 0.55 * size, height: 0.20 * size, fill: fill))
  #place(top + left, polygon(fill: fill,
    (0.50 * size, 0.14 * size),
    (1.00 * size, 0.50 * size),
    (0.50 * size, 0.86 * size),
  ))
]

#let solution-backlink-icon(size: 0.7em, fill: black) = box(width: size, height: size, inset: 0pt)[
  #place(top + left, polygon(fill: fill,
    (0.50 * size, 0.14 * size),
    (0.00 * size, 0.50 * size),
    (0.50 * size, 0.86 * size),
  ))
  #place(top + left, dx: 0.45 * size, dy: 0.40 * size,
    rect(width: 0.55 * size, height: 0.20 * size, fill: fill))
]

// Built-in 5-level difficulty scale: keys are strings ("1".."5"); each entry
// provides the badge color ("color" mode) and a tinted icon ("symbols" mode).
#let default-difficulty-scale = (
  "1": (color: rgb("#2e7d32"), symbol: difficulty-seedling-icon(fill: rgb("#2e7d32"))),
  "2": (color: rgb("#c62828"), symbol: difficulty-pencil-icon(fill: rgb("#c62828"))),
  "3": (color: rgb("#1565c0"), symbol: difficulty-target-icon(fill: rgb("#1565c0"))),
  "4": (color: rgb("#6a1b9a"), symbol: difficulty-mountain-icon(fill: rgb("#6a1b9a"))),
  "5": (color: rgb("#212121"), symbol: difficulty-star-icon(fill: rgb("#212121"))),
)

// Global exercise counter
#let exo-counter = counter("exo-counter")

// Global display counter: never reset, used to build document-unique label
// names for the exercise <-> correction links (exo-counter restarts per
// section, so its values collide across chapters)
#let exo-display-counter = counter("exo-display-counter")

// Configuration state
#let exo-config = state("exo-config", (
  // Display control
  "display": "both",              // "ex" (exercises only), "sol" (solutions/corrections only), "both"
  "corrDisplay": "solution",   // "solution", "correction", "mixed"
  "corrLoc": "after",          // "after", "pagebreak", "end-section", "end-chapter"
  "sol-loc": auto,             // location for solutions only; auto = follow corrLoc
                               // (e.g. sol-loc: "after" + corr-loc: "end-chapter")
  // Labels
  "solution-label": "Solution",
  "correction-label": "Correction",
  "exercise-label": "Exercise",
  // Counter behavior
  "counter-reset": "section",    // "section", "chapter", "global"
  "number-prefix": none,         // none, or "heading" to prefix exercise numbers with the
                                 // current level-1 heading number (e.g. "3.5")
  "number-separator": ".",       // Separator between chapter prefix and exercise number
  // Display options
  "show-metadata": false,
  "show-id": false,              // Show exercise UID below the badge
  "show-competencies": false,    // Show competency tags below exercise
  "display-mode": "exercise",    // "exercise" (default exo-box) or "exam" (g-exam question)
  // Visual styling
  "badge-style": "box",          // "box", "circled", "filled-circle", "pill", "tag", "margin", "border-accent", "underline", "rounded-box", "header-card"
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
  "optional-symbol": optional-star-icon(), // Symbol shown before label for optional exercises (none to disable)
  "corr-given-symbol": corr-given-icon(),  // Symbol shown before label when the correction will be handed out (none to disable)
  // Difficulty encoding
  "difficulty-display": "color",  // How the difficulty: level shows on exercises:
                                  // "color" (badge takes the level color),
                                  // "stars" (N small stars before the label, numeric levels),
                                  // "symbols" (one icon per level), "none"
  "difficulty-scale": auto,       // auto = built-in 5-level scale; or dict key -> (color: .., symbol: ..)
  "difficulty-position": "below", // Where stars/symbols go: "below" the badge (keeps the
                                  // badge compact) or "badge" (inline, before the label)
  // Solution presentation
  "solution-style": auto,         // auto = badge box; "inline" = epigraph-like short rule +
                                  // content right under the statement (only for sol-loc "after")
  "inline-rule-length": 3cm,      // Length of the rule above inline solutions
  "inline-label": auto,           // Small margin label next to inline solutions:
                                  // auto = solution-label, none to hide, or custom content
  // Exercise <-> correction links (for deferred corrections)
  "link-solutions": false,        // Clickable icon on the exercise jumping to its deferred
                                  // solution/correction, and a back-link on the correction
  "link-icon": solution-link-icon(),         // Icon next to the exercise badge (none to hide)
  "backlink-icon": solution-backlink-icon(), // Icon next to the correction badge (none to hide)
  "link-style": "icon",           // "icon" (arrow next to the badge) or "page"
                                  // ("Solution p. 30" textbook-style reference at the
                                  // top right of the statement)
  "page-ref-format": auto,        // auto, or function (label, page) => content
  "page-ref-color": auto,         // Color of the page reference; auto = exercise badge color
  // QR codes
  "show-qr": true,            // Master toggle for per-exercise QR codes
  "qr-size": 1.5cm,           // Target QR code size (shrinks to fit the label margin if needed)
  "qr-min-size": 1cm,         // Never shrink below this (a smaller QR is hard to scan);
                              // if the label margin is narrower, the QR extends into the page margin
  "qr-color": black,          // QR module color
  "qr-caption": none,         // Optional small caption below every QR code (e.g. [Corrigé])
  "qr-position": "auto",      // "auto" (per badge style: label margin or wrapped),
                              // "wrap" (always wrap the exercise content around the QR) or
                              // "tasks" (overlay the QR; a taskize #tasks body flows around it)
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
  sol-loc: none,         // same values as corr-loc, or auto (= follow corr-loc); solutions only
  // Labels
  solution-label: none,
  correction-label: none,
  exercise-label: none,
  // Counter behavior
  counter-reset: none,
  number-prefix: auto,     // auto = keep current; none, or "heading" for chapter-prefixed numbers
  number-separator: none,  // Separator between chapter prefix and number (default ".")
  // Display options
  show-metadata: none,
  show-id: none,
  show-competencies: none,
  display-mode: none,  // "exercise" or "exam"
  // Visual styling
  badge-style: none,   // "box", "circled", "filled-circle", "pill", "tag", "margin", "border-accent", "underline", "rounded-box", "header-card"
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
  optional-symbol: none,  // Symbol for optional exercises (use [★], [⛰], etc.)
  corr-given-symbol: none,  // Symbol for exercises whose correction is handed out
  // Difficulty encoding
  difficulty-display: none,  // "color", "stars", "symbols", "none"
  difficulty-scale: none,    // auto (built-in scale) or dict key -> (color: .., symbol: ..)
  difficulty-position: none, // "below" (under the badge) or "badge" (inline)
  // Solution presentation
  solution-style: none,      // auto (badge box) or "inline" (epigraph-like rule)
  inline-rule-length: none,  // Length of the rule above inline solutions
  inline-label: auto,        // Small margin label for inline solutions (none to hide)
  // Exercise <-> correction links
  link-solutions: none,      // true/false
  link-icon: auto,           // Icon on the exercise (auto = keep current, none to hide)
  backlink-icon: auto,       // Icon on the correction (auto = keep current, none to hide)
  link-style: none,          // "icon" or "page" ("Solution p. 30" reference)
  page-ref-format: none,     // auto or function (label, page) => content
  page-ref-color: none,      // Color of the page reference (auto = badge color)
  // QR codes
  show-qr: none,          // Master toggle for per-exercise QR codes
  qr-size: none,          // Target QR code size
  qr-min-size: none,      // Minimum QR code size (may overflow narrow label margins)
  qr-color: none,         // QR module color
  qr-caption: auto,       // Small caption below every QR code (none to remove)
  qr-position: none,      // "auto" (per badge style), "wrap" (always wrap content)
                          // or "tasks" (overlay; taskize #tasks bodies flow around the QR)
) = {
  exo-config.update(cfg => {
    let new = cfg
    if display != none { new.display = display }
    if corr-display != none { new.corrDisplay = corr-display }
    if corr-loc != none { new.corrLoc = corr-loc }
    if sol-loc != none { new.sol-loc = sol-loc }
    if solution-label != none { new.solution-label = solution-label }
    if correction-label != none { new.correction-label = correction-label }
    if exercise-label != none { new.exercise-label = exercise-label }
    if counter-reset != none { new.counter-reset = counter-reset }
    if number-prefix != auto { new.number-prefix = number-prefix }
    if number-separator != none { new.number-separator = number-separator }
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
    if optional-symbol != none { new.optional-symbol = optional-symbol }
    if corr-given-symbol != none { new.corr-given-symbol = corr-given-symbol }
    if difficulty-display != none { new.difficulty-display = difficulty-display }
    if difficulty-scale != none { new.difficulty-scale = difficulty-scale }
    if difficulty-position != none { new.difficulty-position = difficulty-position }
    if solution-style != none { new.solution-style = solution-style }
    if inline-rule-length != none { new.inline-rule-length = inline-rule-length }
    if inline-label != auto { new.inline-label = inline-label }
    if link-solutions != none { new.link-solutions = link-solutions }
    if link-icon != auto { new.link-icon = link-icon }
    if backlink-icon != auto { new.backlink-icon = backlink-icon }
    if link-style != none { new.link-style = link-style }
    if page-ref-format != none { new.page-ref-format = page-ref-format }
    if page-ref-color != none { new.page-ref-color = page-ref-color }
    if show-qr != none { new.show-qr = show-qr }
    if qr-size != none { new.qr-size = qr-size }
    if qr-min-size != none { new.qr-min-size = qr-min-size }
    if qr-color != none { new.qr-color = qr-color }
    if qr-caption != auto { new.qr-caption = qr-caption }
    if qr-position != none { new.qr-position = qr-position }
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
// Difficulty Helpers
// =============================================================================

// Resolve the difficulty scale entry (color/symbol dict) for an exercise
#let get-difficulty-entry(cfg, metadata) = {
  let diff = metadata.at("difficulty", default: none)
  if diff == none { return none }
  let scale = cfg.at("difficulty-scale", default: auto)
  if scale == auto { scale = default-difficulty-scale }
  scale.at(str(diff), default: none)
}

// Badge color for an exercise: the difficulty color in "color" mode,
// otherwise auto (= use the configured badge-color)
#let get-exercise-badge-color(cfg, metadata) = {
  if cfg.at("difficulty-display", default: "color") == "color" {
    let entry = get-difficulty-entry(cfg, metadata)
    if entry != none and entry.at("color", default: none) != none {
      return entry.color
    }
  }
  auto
}

// Difficulty marker for "stars"/"symbols" display modes (none otherwise)
#let get-difficulty-marker(cfg, metadata) = {
  let mode = cfg.at("difficulty-display", default: "color")
  if mode != "stars" and mode != "symbols" { return none }
  let diff = metadata.at("difficulty", default: none)
  if diff == none { return none }
  let entry = get-difficulty-entry(cfg, metadata)
  let color = if entry != none { entry.at("color", default: black) } else { black }
  if mode == "stars" {
    // One small star per level; requires a numeric difficulty
    if str(diff).match(regex("^[0-9]+$")) == none { return none }
    let n = calc.min(int(str(diff)), 5)
    if n < 1 { return none }
    box(stack(dir: ltr, spacing: 0.06em,
      ..range(n).map(_ => optional-star-icon(size: 0.52em, fill: color))))
  } else if entry != none {
    entry.at("symbol", default: none)
  }
}

// Difficulty marker rendered below the badge (difficulty-position: "below",
// the default: keeps the badge compact instead of widening the label margin)
#let get-difficulty-badge-sub(cfg, metadata) = {
  if cfg.at("difficulty-position", default: "below") == "below" {
    get-difficulty-marker(cfg, metadata)
  }
}

#let get-exercise-marker(cfg, metadata, extra: none) = {
  let markers = ()
  if cfg.at("difficulty-position", default: "below") == "badge" {
    let diff-marker = get-difficulty-marker(cfg, metadata)
    if diff-marker != none {
      markers.push(diff-marker)
    }
  }
  if cfg.optional-symbol != none and metadata.at("optional", default: false) {
    markers.push(cfg.optional-symbol)
  }
  if cfg.at("corr-given-symbol", default: none) != none and metadata.at("corr-given", default: false) {
    markers.push(cfg.at("corr-given-symbol"))
  }
  if extra != none {
    markers.push(extra)
  }
  if markers.len() > 0 { markers.join(h(2.5pt)) }
}

// =============================================================================
// Number Formatting
// =============================================================================

// Displayed exercise number, optionally prefixed by a chapter number.
// number-prefix may be "heading" (current level-1 heading number), a counter
// (e.g. beautitled's chapter-counter, which bypasses counter(heading)), or a
// function () => value evaluated in context. Must be called inside context.
#let format-exo-number(cfg, num) = {
  let prefix = cfg.at("number-prefix", default: none)
  if prefix == none { return [#num] }
  let chap = if prefix == "heading" {
    counter(heading).get().first()
  } else if type(prefix) == function {
    prefix()
  } else {
    // Assume a counter (custom heading packages often keep their own)
    prefix.get().first()
  }
  let show-prefix = if chap == none { false } else if type(chap) == int { chap > 0 } else { true }
  if show-prefix {
    [#chap#cfg.at("number-separator", default: ".")#num]
  } else {
    [#num]
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
// Measures the configured labels so exercise/solution/correction boxes align;
// falls back to the default English/French labels
#let calc-default-margin(font-size: 12pt, style: "box", labels: auto) = {
  let labels = if labels == auto {
    ("Exercise", "Solution", "Correction", "Exercice", "Corrigé")
  } else {
    labels
  }

  if type(style) == function {
    // Custom badge function: measure with the longest label and a 3-digit number
    let max-width = 0pt
    for label in labels {
      let width = measure(style(label, 100, font-size, black, false)).width
      if width > max-width { max-width = width }
    }
    max-width + 16pt
  } else if style == "circled" or style == "filled-circle" {
    // Circle styles only show number, size is font-size * 2
    font-size * 2 + 16pt
  } else if style == "rect" or style == "filled-rect" {
    // Rect styles only show the number
    measure(box(
      inset: (x: 6pt),
      text(weight: "bold", size: font-size)[100],
    )).width + 16pt
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
// QR Codes
// =============================================================================

// Build the QR code shown next to an exercise.
// `qr` is a URL string (rendered with tiaoma) or arbitrary content (used as-is).
// `max-width` caps the width so the QR shrinks to fit narrow label margins
// instead of overflowing them.
#let make-exo-qr(qr, cfg, max-width: none) = {
  if qr == none or not cfg.at("show-qr", default: true) { return none }
  let size = cfg.at("qr-size", default: 1.5cm)
  let min-size = cfg.at("qr-min-size", default: 1cm)
  if max-width != none and size > max-width {
    // Shrink to fit the label margin, but never below min-size: a smaller QR
    // is hard to scan, so past that point it extends into the page margin
    size = calc.max(max-width, calc.min(min-size, size))
  }
  if size <= 0pt { return none }
  let code = if type(qr) == str {
    _tiaoma-qrcode(qr, width: size, options: (fg-color: cfg.at("qr-color", default: black)))
  } else {
    box(width: size, qr)
  }
  let caption = cfg.at("qr-caption", default: none)
  box({
    code
    if caption != none {
      v(2pt, weak: true)
      align(center, box(width: size, text(size: 6.5pt, fill: luma(100), hyphenate: false, caption)))
    }
  })
}

// =============================================================================
// Badge Styles
// =============================================================================

// Style: box (default) - Rectangle with stroke
#let badge-box(label, number, font-size, color, is-solution, label-marker: none) = {
  let fill-color = if is-solution { color.lighten(85%) } else { white }
  let label-text = text(weight: "bold", size: font-size, fill: color)[#label~#number]
  let label-content = if label-marker == none {
    label-text
  } else {
    grid(
      // auto width: the marker cell may hold several icons (e.g. ★ + ⊙)
      columns: (auto, auto),
      column-gutter: 3pt,
      align: (center + horizon, left + horizon),
      box(height: 0.75em, align(center + horizon, label-marker)),
      label-text,
    )
  }
  box(
    height: font-size + 8pt,
    stroke: 0.8pt + color,
    fill: fill-color,
    inset: (x: 4pt, y: 0pt),
  )[
    #align(horizon)[#label-content]
  ]
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

// Style: rect - Number in a compact outlined rectangle (no label)
#let badge-rect(label, number, font-size, color, is-solution) = {
  let fill-color = if is-solution { color.lighten(85%) } else { white }
  box(
    height: font-size + 8pt,
    stroke: 0.8pt + color,
    fill: fill-color,
    inset: (x: 6pt, y: 0pt),
    align(horizon, text(weight: "bold", size: font-size, fill: color)[#number]),
  )
}

// Style: filled-rect - Number in a compact filled rectangle
#let badge-filled-rect(label, number, font-size, color, is-solution) = {
  box(
    height: font-size + 8pt,
    fill: color,
    radius: 2pt,
    inset: (x: 6pt, y: 0pt),
    align(horizon, text(weight: "bold", size: font-size, fill: white)[#number]),
  )
}

// Attach marker icons (optional star, difficulty, link arrow...) to the left
// of any badge shape
#let badge-with-marker(badge, marker) = {
  if marker == none { return badge }
  box(grid(
    columns: (auto, auto),
    column-gutter: 3pt,
    align: (center + horizon, center + horizon),
    box(height: 0.75em, align(center + horizon, marker)),
    badge,
  ))
}

// Get badge based on style name (for badge-based styles only).
// `style` may also be a function (label, number, font-size, color,
// is-solution) => content for fully custom badges.
#let get-badge(style, label, number, font-size, color, is-solution, label-marker: none) = {
  if type(style) == function {
    badge-with-marker(style(label, number, font-size, color, is-solution), label-marker)
  } else if style == "circled" {
    badge-with-marker(badge-circled(label, number, font-size, color, is-solution), label-marker)
  } else if style == "filled-circle" {
    badge-with-marker(badge-filled-circle(label, number, font-size, color, is-solution), label-marker)
  } else if style == "rect" {
    badge-with-marker(badge-rect(label, number, font-size, color, is-solution), label-marker)
  } else if style == "filled-rect" {
    badge-with-marker(badge-filled-rect(label, number, font-size, color, is-solution), label-marker)
  } else if style == "pill" {
    badge-with-marker(badge-pill(label, number, font-size, color, is-solution), label-marker)
  } else if style == "tag" {
    badge-with-marker(badge-tag(label, number, font-size, color, is-solution), label-marker)
  } else {
    // Default: box
    badge-box(label, number, font-size, color, is-solution, label-marker: label-marker)
  }
}

// Check if style is a "full-width" style (wraps content instead of badge+content grid)
#let is-fullwidth-style(style) = {
  type(style) == str and style in ("margin", "border-accent", "underline", "rounded-box", "header-card")
}

// =============================================================================
// Full-Width Styles (wrap entire content)
// =============================================================================

// Style: margin - Side label with rule in the margin.
// For the solution variant the QR (if any) is already wrapped into the body.
#let style-margin(label, number, body, font-size, color, is-solution, qr: none) = {
  if is-solution {
    block(
      width: 100%,
      inset: (x: 8pt, y: 6pt),
      stroke: 0.55pt + color,
      radius: 2pt,
      breakable: true,
    )[
      #text(size: font-size, weight: "bold", fill: color)[#label~#number]
      #v(0.4em)
      #text(size: 9pt)[#body]
    ]
  } else {
    grid(
      columns: (3.35cm, 1fr),
      column-gutter: 0.55cm,
      align: top,
      [
        #line(length: 100%, stroke: 0.45pt + color)
        #v(-0.2em)
        #align(right)[
          #text(size: font-size, weight: "bold", fill: color)[#label~#number:]
        ]
        #if qr != none {
          v(0.45em)
          align(right, qr)
        }
      ],
      [
        #line(length: 0pt, stroke: 0.45pt + white)
        #v(-0.2em)
        #body
      ],
    )
  }
}

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
    inset: 12pt,
  )[
    #text(weight: "bold", size: font-size, fill: border-color)[#label~#number]
    #v(2pt)
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
      inset: (x: 12pt, top: 8pt, bottom: 12pt),
      above: 0pt,
    )[#body]
  ]
}

// Wrap exercise content around a QR code at the top right.
// columns (1fr, auto) keep the QR flush right even when the content is short.
#let qr-wrap-body(qr, body) = _wrap-content(
  box(inset: (left: 10pt, bottom: 6pt), qr),
  body,
  align: top + right,
  column-gutter: 0pt,
  columns: (1fr, auto),
)

// Shared state key read by taskize (>= 0.2.8): a top-right zone that the next
// #tasks call flows around (first rows narrowed, rest full width). This is the
// only coupling between the two packages — the state key, not an import.
#let _taskize-wrap-zone = state("taskize-wrap-zone", none)

// qr-position: "tasks" — overlay the QR at the top right (zero flow height)
// and publish the zone for the body's #tasks block. wrap-it can only flow
// plain text around the QR; a taskize grid is one opaque block to it, so the
// whole grid used to land below a reserved QR-height row. Here taskize itself
// splits its rows around the zone instead. Bodies without a #tasks block do
// not avoid the overlay — "tasks" is opt-in for taskize-based content.
#let qr-overlay-body(qr, body) = context {
  let padded = box(inset: (left: 10pt, bottom: 6pt), qr)
  let size = measure(padded)
  place(top + right, padded)
  _taskize-wrap-zone.update((width: size.width, height: size.height))
  body
  _taskize-wrap-zone.update(none)
}

// Attach a top-right floater (QR code, page reference) to a body, honoring
// qr-position: "tasks" (taskize flows around it) vs the wrap-it default.
#let qr-attach-body(qr, body, cfg) = {
  if qr == none { body } else if cfg.at("qr-position", default: "auto") == "tasks" {
    qr-overlay-body(qr, body)
  } else {
    qr-wrap-body(qr, body)
  }
}

// Get full-width style block
// For the "margin" style the QR code goes below the side label; for the other
// full-width styles the exercise content wraps around the QR at the top right.
#let get-fullwidth-style(style, label, number, body, font-size, color, is-solution, qr: none) = {
  if style == "margin" {
    style-margin(label, number, body, font-size, color, is-solution, qr: qr)
  } else if qr != none {
    get-fullwidth-style(style, label, number, qr-wrap-body(qr, body), font-size, color, is-solution)
  } else if style == "border-accent" {
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

// Resolve the effective margin position from the config (must be called
// inside context: measures the configured labels)
#let calc-margin-pos(cfg) = {
  if cfg.margin-position == auto {
    // Let the widest badge use the label-extra space in the page margin
    // instead of indenting all content by its full width
    let needed = calc-default-margin(
      font-size: cfg.label-font-size,
      style: cfg.badge-style,
      labels: (cfg.exercise-label, cfg.solution-label, cfg.correction-label),
    )
    calc.max(needed - cfg.label-extra, 0pt)
  } else {
    cfg.margin-position
  }
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
  label-marker: none,      // Optional marker displayed before the badge label
  badge-sub: none,         // Optional marker displayed right below the badge (e.g., difficulty)
  margin-content: none,    // Optional content below the badge (e.g., QR code, remarks)
  qr: none,                // QR code: URL string (rendered with tiaoma) or content
  badge-color: auto,       // Override the badge color (e.g., difficulty color); auto = config
) = context {
  let cfg = exo-config.get()

  // Determine the color based on box type
  let actual-color = if box-type == "solution" {
    cfg.solution-color
  } else if box-type == "correction" {
    cfg.correction-color
  } else if badge-color != auto {
    badge-color
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

  let qr-pos = cfg.at("qr-position", default: "auto")

  // Check if this is a full-width style
  if is-fullwidth-style(cfg.badge-style) {
    // Use full-width layout (style wraps the content)
    // Full-width styles have no label column: below-badge markers join the
    // inline ones
    let label-marker = if badge-sub == none { label-marker } else if label-marker == none {
      badge-sub
    } else {
      label-marker + h(2.5pt) + badge-sub
    }
    // Markers (optional star, difficulty icon...) prefix the header label;
    // header-card draws its label on a filled strip, so the marker sits on a
    // small white chip to stay visible
    let label = if label-marker == none { label } else {
      let marker = box(height: 0.75em, align(center + horizon, label-marker))
      if cfg.badge-style == "header-card" {
        marker = box(fill: white, radius: 2pt, inset: (x: 2.5pt, y: 1.5pt),
          box(height: 0.65em, align(center + horizon, label-marker)))
      }
      [#marker~#label]
    }
    // "margin" places the QR in its 3.35cm label column (unless qr-position
    // is "wrap", or for its label-less solution variant); the others get it
    // at full qr-size since the content area is wide
    let qr-block = none
    if cfg.badge-style == "margin" and qr-pos != "wrap" and not is-solution {
      qr-block = make-exo-qr(qr, cfg, max-width: 3.35cm)
    } else {
      full-body = qr-attach-body(make-exo-qr(qr, cfg), full-body, cfg)
    }
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
        qr: qr-block,
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
      label-marker: label-marker,
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

    // Margin position and label space (like environments)
    let margin-pos = calc-margin-pos(cfg)
    let label-extra = cfg.label-extra
    let gap = 6pt

    // QR code below the badge, capped to the label column width so it adapts
    // when the user reduces margin-position; with qr-position: "wrap" it goes
    // into the content column instead, wrapped by the exercise text
    let qr-block = none
    let content-body = body
    if qr-pos == "wrap" or qr-pos == "tasks" {
      content-body = qr-attach-body(make-exo-qr(qr, cfg), body, cfg)
    } else {
      qr-block = make-exo-qr(qr, cfg, max-width: margin-pos + label-extra)
    }

    // Never let the label column content overflow: if the badge (or QR) is
    // wider than the configured margin, widen the column instead
    let label-col-width = calc.max(
      margin-pos + label-extra,
      measure(badge-with-points).width,
      if badge-sub != none { measure(badge-sub).width } else { 0pt },
      if qr-block != none { measure(qr-block).width } else { 0pt },
    )

    // Build the label column content
    let label-column = {
      set text(hyphenate: false)
      align(right)[
        #box[#badge-with-points]
        #if badge-sub != none {
          block(above: 3pt, badge-sub)
        }
        #if show-id and exercise-id != none { id-block }
        #if qr-block != none {
          // Block keeps the QR on its own line, close below the badge
          block(above: 4pt, qr-block)
        }
        #if margin-content != none {
          v(4pt)
          margin-content
        }
      ]
    }

    // Use grid - shifted left so labels can extend into page margin
    block(
      above: space-above,
      below: space-below,
      width: 100% + label-extra,
      breakable: true,
      inset: (left: -label-extra, right: label-extra),  // Add right margin to compensate
    )[
      #grid(
        columns: (label-col-width, 1fr),
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
          #content-body
          #if show-competencies and competencies.len() > 0 { comp-block }
        ],
      )
    ]
  }
}

#let exo-solution-box(number: 1, body, exercise-id: none, show-id: false, qr: none, label-marker: none) = context {
  let cfg = exo-config.get()
  exo-box(
    label: cfg.solution-label,
    number: number,
    body,
    box-type: "solution",
    exercise-id: exercise-id,
    show-id: show-id,
    qr: qr,
    label-marker: label-marker,
  )
}

#let exo-correction-box(number: 1, body, exercise-id: none, show-id: false, qr: none, label-marker: none) = context {
  let cfg = exo-config.get()
  exo-box(
    label: cfg.correction-label,
    number: number,
    body,
    box-type: "correction",
    exercise-id: exercise-id,
    show-id: show-id,
    qr: qr,
    label-marker: label-marker,
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
// Returns: array of (type: "solution" or "correction", content: content, qr: ...)
// - may contain 0, 1, or 2 items
#let determine-content-to-show(solution, correction, cfg, exercise-flags, qr-sol: none, qr-corr: none) = {
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

  // Attach the matching QR code to each item
  items.map(item => {
    item.insert("qr", if item.type == "solution" { qr-sol } else { qr-corr })
    item
  })
}

// Invisible link target (defined at module level: inside exo() the name
// `metadata` is shadowed by the exercise metadata dict)
#let make-link-target(name) = [#metadata(none)#label(name)]

// Epigraph-style inline solution: a short rule + the content, right under
// the statement (no badge box). A small margin label (inline-label, defaults
// to the solution label) makes clear this is the solution. The layout mirrors
// the badge grid so the rule aligns with the exercise content column.
#let inline-solution-block(content, cfg) = context {
  let small-label = {
    let l = cfg.at("inline-label", default: auto)
    if l == auto {
      text(size: 8pt, fill: cfg.solution-color, style: "italic", cfg.solution-label)
    } else {
      l
    }
  }
  let body = {
    set par(first-line-indent: 0cm)
    line(length: cfg.at("inline-rule-length", default: 3cm), stroke: 0.5pt + cfg.solution-color)
    v(0.2em)
    content
  }
  if is-fullwidth-style(cfg.badge-style) {
    block(
      above: cfg.solution-above,
      below: cfg.solution-below,
      width: 100%,
      breakable: true,
    )[
      #if small-label != none [#small-label#v(0.1em)]
      #body
    ]
  } else {
    let label-extra = cfg.label-extra
    block(
      above: cfg.solution-above,
      below: cfg.solution-below,
      width: 100% + label-extra,
      breakable: true,
      inset: (left: -label-extra, right: label-extra),
    )[
      #grid(
        columns: (calc-margin-pos(cfg) + label-extra, 1fr),
        column-gutter: 6pt,
        align: (right + top, left + top),
        align(right, small-label),
        body,
      )
    ]
  }
}

// Render solution/correction items returned by determine-content-to-show.
// - loc: where these items are being placed ("after" enables the inline
//   solution style)
// - link-base: when set (and link-solutions is on), the first item receives
//   the "exb-corr-<base>" link target and every item gets a back-link icon
//   to the exercise
#let show-content-items(items, number, exercise-id, cfg, loc: none, link-base: none) = {
  let first = true
  for item in items {
    let body = item.content
    let marker = none
    if link-base != none and cfg.at("link-solutions", default: false) {
      if first {
        body = [#make-link-target("exb-corr-" + link-base)#body]
      }
      let icon = cfg.at("backlink-icon", default: none)
      if icon != none {
        marker = link(label("exb-ex-" + link-base), icon)
      }
    }
    first = false
    if item.type == "solution" {
      if loc == "after" and cfg.at("solution-style", default: auto) == "inline" {
        inline-solution-block(body, cfg)
      } else {
        exo-solution-box(
          number: number,
          body,
          exercise-id: exercise-id,
          show-id: cfg.show-id,
          qr: item.at("qr", default: none),
          label-marker: marker,
        )
      }
    } else {
      exo-correction-box(
        number: number,
        body,
        exercise-id: exercise-id,
        show-id: cfg.show-id,
        qr: item.at("qr", default: none),
        label-marker: marker,
      )
    }
  }
}

// Where an item type goes: solutions follow sol-loc (auto = corr-loc),
// corrections follow corr-loc
#let resolve-item-loc(cfg, item-type) = {
  if item-type == "solution" {
    let s = cfg.at("sol-loc", default: auto)
    if s == auto { cfg.corrLoc } else { s }
  } else {
    cfg.corrLoc
  }
}

// True if the exercise should carry a clickable link icon to its deferred
// solution/correction
#let has-deferred-items(items, cfg) = {
  items.any(item => resolve-item-loc(cfg, item.type) != "after")
}

// Textbook-style page reference ("Solution p. 30") shown at the top right of
// the statement, linking to the deferred solution/correction (link-style: "page")
#let make-page-ref(cfg, link-base, items, badge-color) = {
  let target = label("exb-corr-" + link-base)
  let deferred = items.filter(item => resolve-item-loc(cfg, item.type) != "after")
  let ref-label = if deferred.len() > 0 and deferred.first().type == "correction" {
    cfg.correction-label
  } else {
    cfg.solution-label
  }
  context {
    let found = query(target)
    if found.len() > 0 {
      let page-num = counter(page).at(found.first().location()).first()
      let fmt = cfg.at("page-ref-format", default: auto)
      let body = if fmt == auto {
        let color = cfg.at("page-ref-color", default: auto)
        if color == auto {
          color = if badge-color != auto { badge-color } else { cfg.badge-color }
        }
        text(fill: color, size: 0.92em)[#ref-label p.~#page-num]
      } else {
        fmt(ref-label, page-num)
      }
      link(target, body)
    }
  }
}

// Place solution/correction items per type: immediately after the exercise,
// after a pagebreak, or deferred to the pending queue (end-section /
// end-chapter, printed by exo-print-solutions)
#let place-content-items(items, number, exercise-id, cfg, link-base: none) = {
  let after-items = ()
  let pagebreak-items = ()
  let deferred = ()
  for item in items {
    let loc = resolve-item-loc(cfg, item.type)
    if loc == "pagebreak" {
      pagebreak-items.push(item)
    } else if loc == "end-section" or loc == "end-chapter" {
      deferred.push((item: item, loc: loc))
    } else {
      after-items.push(item)
    }
  }
  show-content-items(after-items, number, exercise-id, cfg, loc: "after")
  let label-attached = false
  if pagebreak-items.len() > 0 {
    pagebreak(weak: true)
    show-content-items(pagebreak-items, number, exercise-id, cfg, link-base: link-base)
    label-attached = true
  }
  for (i, d) in deferred.enumerate() {
    // The "exb-corr" link target must be unique: attach it to the first
    // deferred item only if the pagebreak group didn't already carry it
    let attach = link-base != none and not label-attached and i == 0
    exo-pending-solutions.update(pending => {
      pending.push((
        number: number,
        content: d.item.content,
        type: d.item.type,
        id: exercise-id,
        qr: d.item.at("qr", default: none),
        loc: d.loc,
        link-base: link-base,
        attach-label: attach,
      ))
      pending
    })
  }
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
  qr: none,              // QR code: URL string or content, placed per badge style
  qr-sol: none,          // QR code shown on the solution box
  qr-corr: none,         // QR code shown on the correction box
  // Exercise-level display flags
  sol-in-corr: false,      // If true, correction already contains solution (use solution in "correction" mode)
  show-corr: false,       // If true, show correction in "mixed" mode
  optional: false,         // If true, show the optional marker before the exercise label
  corr-given: false,       // If true, show the corr-given marker (correction handed out)
  // Metadata fields
  topic: none,
  level: none,
  difficulty: none,  // Difficulty level (key into difficulty-scale, e.g. 1-5)
  authors: (),  // Array of authors, e.g., ("Nathan", "Raph")
  ..extra-metadata
) = {
  // Step counters first (outside context)
  exo-counter.step()
  exo-display-counter.step()

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
    difficulty: difficulty,
    authors: authors,
    optional: optional,
    corr-given: corr-given,
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

  // Displayed number (possibly chapter-prefixed) and difficulty badge color
  let disp-num = format-exo-number(cfg, num)
  let ex-badge-color = get-exercise-badge-color(cfg, metadata)

  // Create exercise record
  let exercise-record = (
    id: exercise-id,
    number: num,
    metadata: metadata,
    exercise: exercise,
    solution: solution,
    correction: correction,
    margin-content: margin-content,
    qr: qr,
    qr-sol: qr-sol,
    qr-corr: qr-corr,
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
    let items-to-show = determine-content-to-show(solution, correction, cfg, exercise-flags, qr-sol: qr-sol, qr-corr: qr-corr)
    show-content-items(items-to-show, disp-num, exercise-id, cfg)
  } else if cfg.display == "ex" {
    // Only show exercise
    exo-box(
      label: get-exercise-label(cfg, metadata),
      number: disp-num,
      exercise,
      exercise-id: exercise-id,
      show-id: cfg.show-id,
      label-marker: get-exercise-marker(cfg, metadata),
      badge-sub: get-difficulty-badge-sub(cfg, metadata),
      margin-content: margin-content,
      qr: qr,
      badge-color: ex-badge-color,
    )
  } else {
    // "both" mode - show exercise and solution/correction
    let items-to-show = determine-content-to-show(solution, correction, cfg, exercise-flags, qr-sol: qr-sol, qr-corr: qr-corr)

    // Exercise <-> correction links: only when something is actually deferred
    let link-base = none
    let link-marker = none
    let exercise-body = exercise
    if cfg.at("link-solutions", default: false) and has-deferred-items(items-to-show, cfg) {
      link-base = str(exo-display-counter.get().first())
      exercise-body = [#make-link-target("exb-ex-" + link-base)#exercise-body]
      if cfg.at("link-style", default: "icon") == "page" {
        exercise-body = qr-attach-body(
          make-page-ref(cfg, link-base, items-to-show, ex-badge-color),
          exercise-body, cfg,
        )
      } else {
        let icon = cfg.at("link-icon", default: none)
        if icon != none {
          link-marker = link(label("exb-corr-" + link-base), icon)
        }
      }
    }

    // Show exercise
    exo-box(
      label: get-exercise-label(cfg, metadata),
      number: disp-num,
      exercise-body,
      exercise-id: exercise-id,
      show-id: cfg.show-id,
      label-marker: get-exercise-marker(cfg, metadata, extra: link-marker),
      badge-sub: get-difficulty-badge-sub(cfg, metadata),
      margin-content: margin-content,
      qr: qr,
      badge-color: ex-badge-color,
    )

    // Handle solution/correction display (per-type location)
    place-content-items(items-to-show, disp-num, exercise-id, cfg, link-base: link-base)
  }
  }  // close context
}  // close function

// =============================================================================
// Solution Display Functions
// =============================================================================

// Print collected solutions/corrections. With loc: "end-section" or
// "end-chapter", only the items deferred to that location are printed
// (the others stay pending); loc: none prints everything.
#let exo-print-solutions(title: auto, loc: none) = context {
  let cfg = exo-config.get()
  let pending = exo-pending-solutions.get()

  let to-print = ()
  let to-keep = ()
  for item in pending {
    if loc == none or item.at("loc", default: none) == loc {
      to-print.push(item)
    } else {
      to-keep.push(item)
    }
  }

  if to-print.len() > 0 {
    let section-title = if title == auto {
      // "Corrections" when only corrections are pending, "Solutions" otherwise
      if to-print.all(item => item.at("type", default: "solution") == "correction") {
        cfg.correction-label + "s"
      } else {
        cfg.solution-label + "s"
      }
    } else {
      title
    }

    v(1em)
    text(weight: "bold", size: 12pt)[#section-title]
    v(0.5em)

    for item in to-print {
      let content = item.at("content", default: none)
      let item-type = item.at("type", default: "solution")
      let item-qr = item.at("qr", default: none)

      // Exercise <-> correction links: link target + back-link icon
      let marker = none
      let link-base = item.at("link-base", default: none)
      if link-base != none and cfg.at("link-solutions", default: false) {
        if item.at("attach-label", default: false) {
          content = [#make-link-target("exb-corr-" + link-base)#content]
        }
        let icon = cfg.at("backlink-icon", default: none)
        if icon != none {
          marker = link(label("exb-ex-" + link-base), icon)
        }
      }

      if item-type == "solution" {
        exo-solution-box(
          number: item.number,
          content,
          exercise-id: item.at("id", default: none),
          show-id: cfg.show-id,
          qr: item-qr,
          label-marker: marker,
        )
      } else {
        exo-correction-box(
          number: item.number,
          content,
          exercise-id: item.at("id", default: none),
          show-id: cfg.show-id,
          qr: item-qr,
          label-marker: marker,
        )
      }
    }
  }

  // Keep only the items deferred to another location
  exo-pending-solutions.update(to-keep)
}

#let exo-section-end() = {
  exo-print-solutions(loc: "end-section")
}

#let exo-chapter-end() = {
  exo-print-solutions(loc: "end-chapter")
}

// Wrap the whole document to automate end-chapter corrections: the pending
// items are printed before each new level-1 heading and at the end of the
// document, and the exercise counter resets at each chapter (per the
// counter-reset setting).
//
//   #show: exo-auto-chapter
#let exo-auto-chapter(body) = context {
  // Corrections printed inside the heading show rule would inherit the
  // heading text style (bold, large); capture the base style here to reset it
  let base-size = text.size
  let base-weight = text.weight
  show heading.where(level: 1): it => {
    // Headings emitted internally by heading-styling packages (e.g.
    // beautitled's hidden outline headings, labelled <_btl-internal>) must
    // not trigger a chapter boundary: they can sit inside place(hide(..)),
    // where the corrections would print invisibly yet be cleared from the
    // pending queue
    if it.at("label", default: none) == label("_btl-internal") {
      it
    } else {
      {
        set text(size: base-size, weight: base-weight)
        exo-chapter-end()
      }
      it
      exo-chapter-start()
    }
  }
  body
  exo-chapter-end()
}

// =============================================================================
// Filtering Function
// =============================================================================

#let exo-filter(
  topic: none,
  level: none,
  difficulty: none,  // Filter: matches the exercise's difficulty level
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
    if difficulty != none {
      let ex-diff = meta.at("difficulty", default: none)
      if ex-diff == none or str(ex-diff) != str(difficulty) { matches = false }
    }
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
          label-marker: get-exercise-marker(cfg, meta),
          badge-sub: get-difficulty-badge-sub(cfg, meta),
          qr: exercise.at("qr", default: none),
          badge-color: get-exercise-badge-color(cfg, meta),
        )
      }

      // Handle solution/correction display
      if show-solutions and cfg.display != "ex" {
        let sol = exercise.at("solution", default: none)
        let corr = exercise.at("correction", default: none)
        let items-to-show = determine-content-to-show(
          sol, corr, cfg, exercise-flags,
          qr-sol: exercise.at("qr-sol", default: none),
          qr-corr: exercise.at("qr-corr", default: none),
        )
        show-content-items(items-to-show, exercise.number, exercise.id, cfg)
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
  qr: none,          // QR code: URL string or content, placed per badge style
  qr-sol: none,      // QR code shown on the solution box
  qr-corr: none,     // QR code shown on the correction box
  // Exercise-level display flags
  sol-in-corr: false,      // If true, correction already contains solution
  show-corr: false,       // If true, show correction in "mixed" mode
  optional: false,         // If true, show the optional marker before the exercise label
  corr-given: false,       // If true, show the corr-given marker (correction handed out)
  // Metadata fields
  topic: none,
  level: none,
  difficulty: none,  // Difficulty level (key into difficulty-scale, e.g. 1-5)
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
      difficulty: difficulty,
      authors: authors,
      optional: optional,
      corr-given: corr-given,
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
      qr: qr,
      qr-sol: qr-sol,
      qr-corr: qr-corr,
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
  optional: auto,        // auto = use bank metadata; bool = override for this display
  optional-symbol: auto, // auto = use current config; content/none = override for this display
  corr-given: auto,        // auto = use bank metadata; bool = override for this display
  corr-given-symbol: auto, // auto = use current config; content/none = override for this display
) = {
  exo-counter.step()
  exo-display-counter.step()

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
      let ex-qr = found.at("qr", default: none)
      let ex-qr-sol = found.at("qr-sol", default: none)
      let ex-qr-corr = found.at("qr-corr", default: none)
      let display-metadata = found.metadata
      if optional != auto {
        display-metadata.insert("optional", optional)
      }
      if corr-given != auto {
        display-metadata.insert("corr-given", corr-given)
      }
      let display-cfg = cfg
      if optional-symbol != auto {
        display-cfg.optional-symbol = optional-symbol
      }
      if corr-given-symbol != auto {
        display-cfg.insert("corr-given-symbol", corr-given-symbol)
      }

      // Get solution and correction
      let sol = found.at("solution", default: none)
      let corr = found.at("correction", default: none)

      // Build exercise flags
      let exercise-flags = (
        solInCorr: found.at("solInCorr", default: false),
        showCorr: found.at("showCorr", default: false),
      )

      // Displayed number (possibly chapter-prefixed) and difficulty badge color
      let disp-num = format-exo-number(cfg, num)
      let ex-badge-color = get-exercise-badge-color(cfg, display-metadata)

      // Check display mode
      if cfg.display-mode == "exam" {
        // EXAM MODE: Use exo-box with points
        let exam-cfg = exam-config.get()

        // Display exercise with points in the badge
        exo-box(
          label: get-exercise-label(display-cfg, display-metadata),
          number: disp-num,
          found.exercise,
          exercise-id: found.id,
          show-id: cfg.show-id,
          competencies: comps,
          show-competencies: cfg.show-competencies,
          points: pts,
          label-marker: get-exercise-marker(display-cfg, display-metadata),
          badge-sub: get-difficulty-badge-sub(display-cfg, display-metadata),
          qr: ex-qr,
          badge-color: ex-badge-color,
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
        // Determine what content to show
        let items-to-show = determine-content-to-show(sol, corr, cfg, exercise-flags, qr-sol: ex-qr-sol, qr-corr: ex-qr-corr)
        let show-items = items-to-show.len() > 0 and (cfg.display == "sol" or (cfg.display == "both" and do-show-solution))

        // Exercise <-> correction links: only when something is actually deferred
        let link-base = none
        let link-marker = none
        let exercise-body = found.exercise
        if (cfg.display != "sol" and show-items and cfg.at("link-solutions", default: false)
            and has-deferred-items(items-to-show, cfg)) {
          link-base = str(exo-display-counter.get().first())
          exercise-body = [#make-link-target("exb-ex-" + link-base)#exercise-body]
          if cfg.at("link-style", default: "icon") == "page" {
            exercise-body = qr-attach-body(
              make-page-ref(cfg, link-base, items-to-show, ex-badge-color),
              exercise-body, cfg,
            )
          } else {
            let icon = cfg.at("link-icon", default: none)
            if icon != none {
              link-marker = link(label("exb-corr-" + link-base), icon)
            }
          }
        }

        // Display exercise based on show mode
        if cfg.display != "sol" {
          exo-box(
            label: get-exercise-label(display-cfg, display-metadata),
            number: disp-num,
            exercise-body,
            exercise-id: found.id,
            show-id: cfg.show-id,
            competencies: comps,
            show-competencies: cfg.show-competencies,
            label-marker: get-exercise-marker(display-cfg, display-metadata, extra: link-marker),
            badge-sub: get-difficulty-badge-sub(display-cfg, display-metadata),
            qr: ex-qr,
            badge-color: ex-badge-color,
          )
        }

        // Handle solution/correction display (per-type location)
        if show-items {
          if cfg.display == "sol" {
            show-content-items(items-to-show, disp-num, found.id, cfg)
          } else {
            place-content-items(items-to-show, disp-num, found.id, cfg, link-base: link-base)
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
  difficulty: none,   // Filter by difficulty level
  author: none,       // Filter: matches if author is in exercise's authors array
  competency: none,   // Filter by single competency
  // List filters (match any in list)
  topics: none,       // e.g., ("algebra", "geometry")
  levels: none,       // e.g., ("1M", "2M")
  difficulties: none, // e.g., (1, 2) - match any
  competencies: none, // e.g., ("C1.1", "C2.3") - match any
  // Custom filter function
  where: none,       // Function (exercise) => bool
  // Display options
  show-solutions: auto,
  renumber: true,    // Renumber exercises sequentially
  max: none,         // Maximum number to show
  shuffle: false,    // Randomize order (needs seed)
) = {
  // Stepped outside context: base for document-unique link label names
  exo-display-counter.step()

  context {
  let cfg = exo-config.get()
  let registry = exo-registry.get()
  let call-base = exo-display-counter.get().first()

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
    if difficulty != none {
      let ex-diff = meta.at("difficulty", default: none)
      if ex-diff == none or str(ex-diff) != str(difficulty) { matches = false }
    }
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
    if difficulties != none {
      let ex-diff = meta.at("difficulty", default: none)
      let found = false
      if ex-diff != none {
        for d in difficulties {
          if str(ex-diff) == str(d) { found = true; break }
        }
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
    let ex-qr = exercise.at("qr", default: none)
    let sol = exercise.at("solution", default: none)
    let corr = exercise.at("correction", default: none)

    // Build exercise flags
    let exercise-flags = (
      solInCorr: exercise.at("solInCorr", default: false),
      showCorr: exercise.at("showCorr", default: false),
    )

    // Displayed number (possibly chapter-prefixed) and difficulty badge color
    let disp-num = format-exo-number(cfg, num)
    let ex-badge-color = get-exercise-badge-color(cfg, exercise.metadata)

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
        number: disp-num,
        exercise.exercise,
        exercise-id: exercise.id,
        show-id: cfg.show-id,
        competencies: ex-comps,
        show-competencies: cfg.show-competencies,
        points: pts,
        label-marker: get-exercise-marker(cfg, exercise.metadata),
        badge-sub: get-difficulty-badge-sub(cfg, exercise.metadata),
        qr: ex-qr,
        badge-color: ex-badge-color,
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
      // Determine what content to show
      let items-to-show = determine-content-to-show(
        sol, corr, cfg, exercise-flags,
        qr-sol: exercise.at("qr-sol", default: none),
        qr-corr: exercise.at("qr-corr", default: none),
      )
      let show-items = items-to-show.len() > 0 and (cfg.display == "sol" or do-show-solutions)

      // Exercise <-> correction links: only when something is actually deferred.
      // Label base combines the call base and the loop index for uniqueness.
      let link-base = none
      let link-marker = none
      let exercise-body = exercise.exercise
      if (cfg.display != "sol" and show-items and cfg.at("link-solutions", default: false)
          and has-deferred-items(items-to-show, cfg)) {
        link-base = str(call-base) + "-" + str(display-num)
        exercise-body = [#make-link-target("exb-ex-" + link-base)#exercise-body]
        if cfg.at("link-style", default: "icon") == "page" {
          exercise-body = qr-attach-body(
            make-page-ref(cfg, link-base, items-to-show, ex-badge-color),
            exercise-body, cfg,
          )
        } else {
          let icon = cfg.at("link-icon", default: none)
          if icon != none {
            link-marker = link(label("exb-corr-" + link-base), icon)
          }
        }
      }

      if cfg.display != "sol" {
        exo-box(
          label: get-exercise-label(cfg, exercise.metadata),
          number: disp-num,
          exercise-body,
          exercise-id: exercise.id,
          show-id: cfg.show-id,
          competencies: ex-comps,
          show-competencies: cfg.show-competencies,
          label-marker: get-exercise-marker(cfg, exercise.metadata, extra: link-marker),
          badge-sub: get-difficulty-badge-sub(cfg, exercise.metadata),
          qr: ex-qr,
          badge-color: ex-badge-color,
        )
      }

      // Handle solution/correction display (per-type location)
      if show-items {
        if cfg.display == "sol" {
          show-content-items(items-to-show, disp-num, exercise.id, cfg)
        } else {
          place-content-items(items-to-show, disp-num, exercise.id, cfg, link-base: link-base)
        }
      }
    }

    // Apply page break after if configured
    if cfg.page-break == "after" or cfg.page-break == "around" {
      pagebreak(weak: true)
    }
  }
  }  // close context
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
  difficulty: none,  // Filter: matches the exercise's difficulty level
  author: none,  // Filter: matches if author is in exercise's authors array
) = context {
  let registry = exo-registry.get()
  let count = 0

  for exercise in registry {
    let meta = exercise.metadata
    let matches = true

    if topic != none and meta.topic != topic { matches = false }
    if level != none and meta.level != level { matches = false }
    if difficulty != none {
      let ex-diff = meta.at("difficulty", default: none)
      if ex-diff == none or str(ex-diff) != str(difficulty) { matches = false }
    }
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
// Exam Integration
// =============================================================================

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
