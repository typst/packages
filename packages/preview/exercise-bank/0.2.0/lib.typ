// exercise-bank - Exercise Package for Typst
// Handles exercises with metadata, content, and solutions
// Supports multiple display modes and filtering

// =============================================================================
// External Package Imports
// =============================================================================

// Import g-exam for exam mode display
#import "@preview/g-exam:0.4.3": exam as g-exam-template, question as g-exam-question, subquestion as g-exam-subquestion

// =============================================================================
// State and Counters
// =============================================================================

// Global exercise counter
#let exo-counter = counter("exo-counter")

// Configuration state
#let exo-config = state("exo-config", (
  solution-mode: "inline",     // "inline", "end-section", "end-chapter", "none", "only"
  solution-label: "Solution",
  exercise-label: "Exercise",
  counter-reset: "section",    // "section", "chapter", "global"
  show-metadata: false,
  show-id: false,              // Show exercise UID below the badge
  show-competencies: false,    // Show competency tags below exercise
  display-mode: "exercise",    // "exercise" (default exo-box) or "exam" (g-exam question)
  label-font-size: 12pt,       // Font size for badge label text
  margin-position: 2cm,        // Fixed position of content margin from left (like env line-position)
  label-extra: 1cm,            // Extra space for labels to extend into left margin
  page-break: "none",          // "none", "before", "after", "around" - page break behavior
))

// Registry of all exercises (for filtering)
#let exo-registry = state("exo-registry", ())

// Exercises pending solution display (for end-section/end-chapter modes)
#let exo-pending-solutions = state("exo-pending-solutions", ())

// ID counter for auto-generation
#let exo-id-counter = counter("exo-id-counter")

// Exam configuration state (for exam display mode)
#let exam-config = state("exam-config", (
  show-solutions: false,  // Whether to show solutions in exam
  solution-label: "Solution",
  // Solution box styling
  solution-fill: rgb("#e8f5e9"),
  solution-stroke: 0.8pt + rgb("#4a7c59"),
  solution-radius: 3pt,
  solution-inset: 8pt,
  solution-label-color: rgb("#2e5a3a"),
  // Question styling (for custom question wrappers)
  question-spacing: 1em,
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
  solution-mode: none,
  solution-label: none,
  exercise-label: none,
  counter-reset: none,
  show-metadata: none,
  show-id: none,
  show-competencies: none,
  display-mode: none,  // "exercise" or "exam"
  label-font-size: none,
  margin-position: none,
  label-extra: none,
  page-break: none,    // "none", "before", "after", "around"
) = {
  exo-config.update(cfg => {
    let new = cfg
    if solution-mode != none { new.solution-mode = solution-mode }
    if solution-label != none { new.solution-label = solution-label }
    if exercise-label != none { new.exercise-label = exercise-label }
    if counter-reset != none { new.counter-reset = counter-reset }
    if show-metadata != none { new.show-metadata = show-metadata }
    if show-id != none { new.show-id = show-id }
    if show-competencies != none { new.show-competencies = show-competencies }
    if display-mode != none { new.display-mode = display-mode }
    if label-font-size != none { new.label-font-size = label-font-size }
    if margin-position != none { new.margin-position = margin-position }
    if label-extra != none { new.label-extra = label-extra }
    if page-break != none { new.page-break = page-break }
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
  is-solution: false,
  exercise-id: none,       // For UID display
  show-id: false,          // Whether to show the UID
  competencies: (),        // List of competencies
  show-competencies: false, // Whether to show competencies
  points: none,            // Points for exam mode
  points-label: "pts",     // Label for points (e.g., "pts", "points")
  margin-content: none,    // Optional content below the badge (e.g., QR code, remarks)
) = context {
  let cfg = exo-config.get()

  let badge-stroke = if is-solution { 0.8pt + rgb("#4a7c59") } else { 0.8pt }
  let badge-fill = if is-solution { rgb("#e8f5e9") } else { white }

  // Badge box
  let badge = box(
    stroke: badge-stroke,
    fill: badge-fill,
    inset: (x: 4pt, y: 3pt),
    text(weight: "bold", size: cfg.label-font-size)[#label #number],
  )

  // Badge with optional points displayed inline after the box
  let badge-with-points = if points != none {
    box[#badge#h(6pt)#text(size: 9pt, fill: rgb("#555"), style: "italic")[(#points #points-label)]]
  } else {
    badge
  }

  // ID display below badge
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

  // Competencies display
  let comp-block = if show-competencies and competencies.len() > 0 {
    v(4pt)
    for comp in competencies {
      competency-tag(comp)
      h(4pt)
    }
  }

  // Margin position and label space (like environments)
  let margin-pos = cfg.margin-position
  let label-extra = cfg.label-extra
  let gap = 6pt

  // Use grid - shifted left so labels can extend into page margin
  block(
    above: 0.8em,
    below: 0.8em,
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

#let exo-solution-box(number: 1, body, exercise-id: none, show-id: false) = context {
  let cfg = exo-config.get()
  exo-box(
    label: cfg.solution-label,
    number: number,
    body,
    is-solution: true,
    exercise-id: exercise-id,
    show-id: show-id,
  )
}

// =============================================================================
// Main Exercise Function
// =============================================================================

#let exo(
  exercise: none,
  solution: none,
  id: auto,
  margin-content: none,  // Optional content below the badge (e.g., QR code, remarks)
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

  // Create exercise record
  let exercise-record = (
    id: exercise-id,
    number: num,
    metadata: metadata,
    exercise: exercise,
    solution: solution,
    margin-content: margin-content,
  )

  // Register exercise
  exo-registry.update(reg => {
    reg.push(exercise-record)
    reg
  })

  // Display based on mode
  if cfg.solution-mode == "only" {
    // Only show solution
    if solution != none {
      exo-solution-box(number: num, solution, exercise-id: exercise-id, show-id: cfg.show-id)
    }
  } else {
    // Show exercise
    exo-box(
      label: cfg.exercise-label,
      number: num,
      exercise,
      exercise-id: exercise-id,
      show-id: cfg.show-id,
      margin-content: margin-content,
    )

    // Handle solution display
    if solution != none {
      if cfg.solution-mode == "inline" {
        exo-solution-box(number: num, solution, exercise-id: exercise-id, show-id: cfg.show-id)
      } else if cfg.solution-mode == "end-section" or cfg.solution-mode == "end-chapter" {
        // Store for later (include ID for later display)
        exo-pending-solutions.update(pending => {
          pending.push((number: num, solution: solution, id: exercise-id))
          pending
        })
      }
      // "none" mode: don't display solution
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
      exo-solution-box(
        number: item.number,
        item.solution,
        exercise-id: item.at("id", default: none),
        show-id: cfg.show-id,
      )
    }
  }

  // Clear pending solutions
  exo-pending-solutions.update(())
}

#let exo-section-end() = context {
  let cfg = exo-config.get()
  if cfg.solution-mode == "end-section" {
    exo-print-solutions()
  }
}

#let exo-chapter-end() = context {
  let cfg = exo-config.get()
  if cfg.solution-mode == "end-chapter" {
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
      exo-box(
        label: cfg.exercise-label,
        number: exercise.number,
        exercise.exercise,
        exercise-id: exercise.id,
        show-id: cfg.show-id,
      )

      if show-solutions and exercise.solution != none {
        exo-solution-box(
          number: exercise.number,
          exercise.solution,
          exercise-id: exercise.id,
          show-id: cfg.show-id,
        )
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
  id: auto,
  competencies: (),  // List of competency tags
  points: none,      // Points for exam mode
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
      competencies: competencies,
      points: points,
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
        cfg.solution-mode == "inline"
      } else {
        show-solution
      }

      // Get competencies and points (with defaults for backward compatibility)
      let comps = found.at("competencies", default: ())
      let pts = found.at("points", default: none)

      // Check display mode
      if cfg.display-mode == "exam" {
        // EXAM MODE: Use exo-box with points
        let exam-cfg = exam-config.get()

        // Display exercise with points in the badge
        exo-box(
          label: cfg.exercise-label,
          number: num,
          found.exercise,
          exercise-id: found.id,
          show-id: cfg.show-id,
          competencies: comps,
          show-competencies: cfg.show-competencies,
          points: pts,
        )

        // Show solution if configured
        if exam-cfg.show-solutions and found.solution != none {
          exam-solution-box(found.solution)
        }
      } else {
        // EXERCISE MODE: Use default exo-box format (no points)
        // Display exercise
        if cfg.solution-mode != "only" {
          exo-box(
            label: cfg.exercise-label,
            number: num,
            found.exercise,
            exercise-id: found.id,
            show-id: cfg.show-id,
            competencies: comps,
            show-competencies: cfg.show-competencies,
          )
        }

        // Handle solution
        if found.solution != none {
          if cfg.solution-mode == "only" {
            exo-solution-box(number: num, found.solution, exercise-id: found.id, show-id: cfg.show-id)
          } else if cfg.solution-mode == "inline" or do-show-solution {
            exo-solution-box(number: num, found.solution, exercise-id: found.id, show-id: cfg.show-id)
          } else if cfg.solution-mode == "end-section" or cfg.solution-mode == "end-chapter" {
            exo-pending-solutions.update(pending => {
              pending.push((number: num, solution: found.solution, id: found.id))
              pending
            })
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
    cfg.solution-mode == "inline"
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
        label: cfg.exercise-label,
        number: num,
        exercise.exercise,
        exercise-id: exercise.id,
        show-id: cfg.show-id,
        competencies: ex-comps,
        show-competencies: cfg.show-competencies,
        points: pts,
      )

      // Show solution if configured
      if exam-cfg.show-solutions and exercise.solution != none {
        exam-solution-box(exercise.solution)
      }
    } else {
      // EXERCISE MODE: Use default exo-box format (no points)
      if cfg.solution-mode != "only" {
        exo-box(
          label: cfg.exercise-label,
          number: num,
          exercise.exercise,
          exercise-id: exercise.id,
          show-id: cfg.show-id,
          competencies: ex-comps,
          show-competencies: cfg.show-competencies,
        )
      }

      if exercise.solution != none {
        if cfg.solution-mode == "only" or do-show-solutions {
          exo-solution-box(
            number: num,
            exercise.solution,
            exercise-id: exercise.id,
            show-id: cfg.show-id,
          )
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

    // Build question content
    let q-content = {
      found.exercise
      if supplement != none {
        supplement
      }
      // Show solution if configured
      if exam-cfg.show-solutions and found.solution != none {
        v(8pt)
        exam-solution-box(found.solution)
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

// Helper to filter exercises and return them (for use in exam-select)
#let _filter-exercises(
  topic: none,
  level: none,
  author: none,  // Filter: matches if author is in exercise's authors array
  competency: none,
  topics: none,
  levels: none,
  competencies: none,
  where: none,
  max: none,
) = context {
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

  filtered
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

    // Build question content
    let q-content = {
      exercise.exercise
      // Show solution if configured
      if exam-cfg.show-solutions and exercise.solution != none {
        v(8pt)
        exam-solution-box(exercise.solution)
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
