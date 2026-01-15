// exercise-bank - Exercise Package for Typst
// Handles exercises with metadata, content, and solutions
// Supports multiple display modes and filtering

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
))

// Registry of all exercises (for filtering)
#let exo-registry = state("exo-registry", ())

// Exercises pending solution display (for end-section/end-chapter modes)
#let exo-pending-solutions = state("exo-pending-solutions", ())

// ID counter for auto-generation
#let exo-id-counter = counter("exo-id-counter")

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
#let calc-badge-width(label, number) = {
  let badge = box(
    stroke: 0.8pt,
    inset: (x: 4pt, y: 3pt),
    text(weight: "bold")[#label #number],
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
) = context {
  let cfg = exo-config.get()

  let badge-stroke = if is-solution { 0.8pt + rgb("#4a7c59") } else { 0.8pt }
  let badge-fill = if is-solution { rgb("#e8f5e9") } else { white }

  let badge = box(
    stroke: badge-stroke,
    fill: badge-fill,
    inset: (x: 4pt, y: 3pt),
    text(weight: "bold")[#label #number],
  )

  // Calculate badge width and add spacing (8pt gap between badge and content)
  let badge-width = measure(badge).width

  // Also measure the alternative label to use max width for consistency
  let alt-label = if is-solution { cfg.exercise-label } else { cfg.solution-label }
  let alt-badge-width = calc-badge-width(alt-label, number)

  // Use the max of both widths plus gap
  let content-indent = calc.max(badge-width, alt-badge-width) + 12pt

  // ID display below badge
  let id-block = if show-id and exercise-id != none {
    v(-2pt)
    text(size: 7pt, fill: rgb("#666666"), style: "italic")[#exercise-id]
  }

  // Competencies display
  let comp-block = if show-competencies and competencies.len() > 0 {
    v(4pt)
    for comp in competencies {
      competency-tag(comp)
      h(4pt)
    }
  }

  block(
    above: 0.8em,
    below: 0.8em,
    width: 100%,
    grid(
      columns: (content-indent, 1fr),
      column-gutter: 0pt,
      align: (left + top, left + top),
      // Badge column
      {
        badge
        if show-id and exercise-id != none { id-block }
      },
      // Content column - add top padding to align with badge text
      {
        v(3pt)  // Match badge inset.y
        set par(first-line-indent: 0cm)
        body
        if show-competencies and competencies.len() > 0 { comp-block }
      },
    ),
  )
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
  content,
  solution: none,
  id: auto,
  // Metadata fields
  topic: none,
  level: none,
  author: none,
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
    author: author,
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
    content: content,
    solution: solution,
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
      content,
      exercise-id: exercise-id,
      show-id: cfg.show-id,
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
  author: none,
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
    if author != none and meta.author != author { matches = false }
    if custom != none and not custom(meta) { matches = false }

    if matches {
      exo-box(
        label: cfg.exercise-label,
        number: exercise.number,
        exercise.content,
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
  content,
  solution: none,
  id: auto,
  competencies: (),  // List of competency tags
  // Metadata fields
  topic: none,
  level: none,
  author: none,
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
      author: author,
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
      content: content,
      solution: solution,
      competencies: competencies,
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

      // Get competencies (with default for backward compatibility)
      let comps = found.at("competencies", default: ())

      // Display exercise
      if cfg.solution-mode != "only" {
        exo-box(
          label: cfg.exercise-label,
          number: num,
          found.content,
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
  author: none,
  competency: none,  // Filter by single competency
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
    if author != none and meta.author != author { matches = false }

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

    if cfg.solution-mode != "only" {
      exo-box(
        label: cfg.exercise-label,
        number: num,
        exercise.content,
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
  author: none,
) = context {
  let registry = exo-registry.get()
  let count = 0

  for exercise in registry {
    let meta = exercise.metadata
    let matches = true

    if topic != none and meta.topic != topic { matches = false }
    if level != none and meta.level != level { matches = false }
    if author != none and meta.author != author { matches = false }

    if matches { count += 1 }
  }

  count
}
