// tasks - Horizontal columned lists for Typst
// Similar to LaTeX's tasks package
// Items flow horizontally (left-to-right) across columns

// Import itemize package for enhanced enum/list features
#import "@preview/itemize:0.2.0" as el

// =============================================================================
// Configuration State
// =============================================================================

#let tasks-config = state("tasks-config", (
  columns: 2,
  label-format: "a)",           // "a)", "1)", "i)", "(a)", "(1)", custom function
  column-gutter: 1em,
  row-gutter: 0.6em,
  label-width: auto,            // auto or fixed width
  label-align: right,
  label-baseline: "center",     // "center", "top", "bottom", or length/auto
  indent-after-label: 0.4em,
  indent: 0pt,                  // left indentation of entire block
  above: 0.5em,                 // space before block
  below: 0.5em,                 // space after block
  flow: "horizontal",           // "horizontal" (a b | c d) or "vertical" (a c | b d)
  // Itemize integration options
  use-itemize-styling: false,   // Enable itemize styling features
  itemize-config: none,         // Pass-through config for itemize
))

// Global counter for resuming
#let tasks-counter = counter("tasks-counter")

// =============================================================================
// Configuration Function
// =============================================================================

#let tasks-setup(
  columns: none,
  label-format: none,
  column-gutter: none,
  row-gutter: none,
  label-width: none,
  label-align: none,
  label-baseline: none,
  indent-after-label: none,
  indent: none,
  above: none,
  below: none,
  flow: none,
  use-itemize-styling: none,
  itemize-config: none,
) = {
  tasks-config.update(cfg => {
    let new = cfg
    if columns != none { new.columns = columns }
    if label-format != none { new.label-format = label-format }
    if column-gutter != none { new.column-gutter = column-gutter }
    if row-gutter != none { new.row-gutter = row-gutter }
    if label-width != none { new.label-width = label-width }
    if label-align != none { new.label-align = label-align }
    if label-baseline != none { new.label-baseline = label-baseline }
    if indent-after-label != none { new.indent-after-label = indent-after-label }
    if indent != none { new.indent = indent }
    if above != none { new.above = above }
    if below != none { new.below = below }
    if flow != none { new.flow = flow }
    if use-itemize-styling != none { new.use-itemize-styling = use-itemize-styling }
    if itemize-config != none { new.itemize-config = itemize-config }
    new
  })
}

// =============================================================================
// Itemize Integration
// =============================================================================

// Re-export itemize module for direct access to itemize features
#let itemize = el

// =============================================================================
// Label Formatting
// =============================================================================

// Convert number to label based on format
#let format-label(n, format) = {
  if type(format) == function {
    format(n)
  } else if format == "a)" {
    numbering("a)", n)
  } else if format == "a." {
    numbering("a.", n)
  } else if format == "(a)" {
    numbering("(a)", n)
  } else if format == "1)" {
    numbering("1)", n)
  } else if format == "1." {
    numbering("1.", n)
  } else if format == "(1)" {
    numbering("(1)", n)
  } else if format == "i)" {
    numbering("i)", n)
  } else if format == "i." {
    numbering("i.", n)
  } else if format == "(i)" {
    numbering("(i)", n)
  } else if format == "I)" {
    numbering("I)", n)
  } else if format == "A)" {
    numbering("A)", n)
  } else if format == "A." {
    numbering("A.", n)
  } else if format == "*" {
    // Bullet points
    sym.bullet
  } else if format == "-" {
    // Dash
    "–"
  } else if format == "none" or format == none {
    // No label
    ""
  } else {
    // Try as numbering pattern
    numbering(format, n)
  }
}

// =============================================================================
// Internal: Render tasks grid
// =============================================================================

#let render-tasks-grid(
  task-items,
  cols,
  fmt,
  col-gut,
  row-gut,
  lbl-width,
  lbl-align,
  lbl-baseline,
  indent-after,
  indent,
  above-spacing,
  below-spacing,
  flow-dir,
  start-num,
) = {
  let num-items = task-items.len()
  let num-rows = calc.ceil(num-items / cols)

  // Calculate label width if auto
  let actual-label-width = if lbl-width == auto {
    let max-width = 0pt
    for i in range(num-items) {
      let label = format-label(start-num + i, fmt)
      let label-size = measure(text(weight: "regular")[#label]).width
      if label-size > max-width { max-width = label-size }
    }
    max-width + indent-after
  } else {
    lbl-width
  }

  // Build grid columns
  let grid-columns = ()
  for _ in range(cols) {
    grid-columns.push(actual-label-width)
    grid-columns.push(1fr)
  }

  // Build grid content
  let grid-content = ()

  for row in range(num-rows) {
    for col in range(cols) {
      // Calculate item index based on flow direction
      let item-idx = if flow-dir == "vertical" {
        // Vertical: fill columns first (a c e | b d f)
        col * num-rows + row
      } else {
        // Horizontal: fill rows first (a b | c d | e f)
        row * cols + col
      }

      if item-idx < num-items {
        let num = start-num + item-idx
        let label = format-label(num, fmt)
        let item-content = task-items.at(item-idx)

        // Calculate baseline offset like itemize does
        // Measure label height and sample text height
        let label-height = measure(text(weight: "regular")[#label]).height
        let text-height = measure[A].height  // Sample character for first line height

        let baseline-offset = if lbl-baseline == "center" {
          // Center label relative to first line of text
          (label-height - text-height) * 0.5
        } else if lbl-baseline == "top" {
          // Align to top
          0pt
        } else if lbl-baseline == "bottom" {
          // Align label bottom with text baseline
          label-height - text-height
        } else if type(lbl-baseline) in (length, relative) {
          // Custom offset
          lbl-baseline
        } else {
          // Default: no offset
          0pt
        }

        // Apply baseline adjustment with top alignment (works for multiline)
        let label-cell = align(lbl-align + top)[#v(baseline-offset)#text(weight: "regular")[#label]]

        // Apply vector baseline adjustment to content
        let content-cell = align(left + top)[
          #show math.vec: it => box(baseline: 30%, it)
          #item-content
        ]

        grid-content.push(label-cell)
        grid-content.push(content-cell)
      } else {
        grid-content.push([])
        grid-content.push([])
      }
    }
  }

  // Update counter
  tasks-counter.update(start-num + num-items - 1)

  // Render
  block(
    width: 100%,
    above: above-spacing,
    below: below-spacing,
    inset: (left: indent),
    grid(
      columns: grid-columns,
      column-gutter: (indent-after, col-gut) * cols,
      row-gutter: row-gut,
      ..grid-content
    )
  )
}

// =============================================================================
// Main Tasks Function - Clean syntax with enum
// =============================================================================

// Usage:
//   #tasks[
//     + $2 + 3$
//     + $5 - 2$
//     + $4 times 3$
//   ]
//
// Or with options:
//   #tasks(columns: 3, label: "1)")[
//     + First item
//     + Second item
//   ]
//
// Flow options:
//   flow: "horizontal" -> a b | c d | e f (default)
//   flow: "vertical"   -> a c e | b d f

#let tasks(
  columns: auto,
  label: auto,              // Shorthand for label-format
  label-format: auto,
  start: 1,
  resume: false,
  column-gutter: auto,
  row-gutter: auto,
  label-width: auto,
  label-align: auto,
  label-baseline: auto,
  indent-after-label: auto,
  indent: auto,
  above: auto,
  below: auto,
  flow: auto,
  // Itemize integration parameters
  use-itemize-styling: auto,
  itemize-config: auto,
  body,
) = context {
  let cfg = tasks-config.get()

  // Apply parameters (use provided value or fall back to config)
  let cols = if columns == auto { cfg.columns } else { columns }
  let fmt = if label != auto { label } else if label-format != auto { label-format } else { cfg.label-format }
  let col-gut = if column-gutter == auto { cfg.column-gutter } else { column-gutter }
  let row-gut = if row-gutter == auto { cfg.row-gutter } else { row-gutter }
  let lbl-width = if label-width == auto { cfg.label-width } else { label-width }
  let lbl-align = if label-align == auto { cfg.label-align } else { label-align }
  let lbl-baseline = if label-baseline == auto { cfg.label-baseline } else { label-baseline }
  let indent-after = if indent-after-label == auto { cfg.indent-after-label } else { indent-after-label }
  let blk-indent = if indent == auto { cfg.indent } else { indent }
  let above-spacing = if above == auto { cfg.above } else { above }
  let below-spacing = if below == auto { cfg.below } else { below }
  let flow-dir = if flow == auto { cfg.flow } else { flow }
  let use-itemize = if use-itemize-styling == auto { cfg.use-itemize-styling } else { use-itemize-styling }
  let itemize-cfg = if itemize-config == auto { cfg.itemize-config } else { itemize-config }

  // Extract items from the body content
  let task-items = ()

  // Parse the body - look for enum items
  let body-children = if type(body) == content {
    body.fields().at("children", default: (body,))
  } else {
    (body,)
  }

  // Find enum in children
  for child in body-children {
    if child.func() == enum.item {
      task-items.push(child.body)
    } else if child.has("children") {
      for subchild in child.children {
        if type(subchild) == content and subchild.func() == enum.item {
          task-items.push(subchild.body)
        }
      }
    }
  }

  // Fallback: if no enum found, try to find enum directly
  if task-items.len() == 0 and type(body) == content {
    if body.func() == enum {
      for item in body.children {
        if item.func() == enum.item {
          task-items.push(item.body)
        }
      }
    }
  }

  // Determine starting number
  let start-num = if resume {
    tasks-counter.get().first() + 1
  } else {
    start
  }

  if task-items.len() > 0 {
    render-tasks-grid(
      task-items, cols, fmt, col-gut, row-gut,
      lbl-width, lbl-align, lbl-baseline, indent-after,
      blk-indent, above-spacing, below-spacing,
      flow-dir, start-num,
    )
  }
}

// =============================================================================
// Convenience Functions
// =============================================================================

// Reset the tasks counter
#let tasks-reset() = {
  tasks-counter.update(0)
}

// Shorthand for specific column counts
#let tasks2(body, label: auto, start: 1, resume: false) = {
  tasks(columns: 2, label: label, start: start, resume: resume, body)
}

#let tasks3(body, label: auto, start: 1, resume: false) = {
  tasks(columns: 3, label: label, start: start, resume: resume, body)
}

#let tasks4(body, label: auto, start: 1, resume: false) = {
  tasks(columns: 4, label: label, start: start, resume: resume, body)
}
