// tasks - Horizontal columned lists for Typst
// Similar to LaTeX's tasks package
// Items flow horizontally (left-to-right) across columns

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
  label-weight: "regular",      // "regular" or "bold"
  indent-after-label: 0.4em,
  indent: 0pt,                  // left indentation of entire block
  above: 0.5em,                 // space before block
  below: 0.5em,                 // space after block
  flow: "horizontal",           // "horizontal" (a b | c d) or "vertical" (a c | b d)
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
  label-weight: none,
  indent-after-label: none,
  indent: none,
  above: none,
  below: none,
  flow: none,
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
    if label-weight != none { new.label-weight = label-weight }
    if indent-after-label != none { new.indent-after-label = indent-after-label }
    if indent != none { new.indent = indent }
    if above != none { new.above = above }
    if below != none { new.below = below }
    if flow != none { new.flow = flow }
    new
  })
}

// =============================================================================
// Column Span Parsing
// =============================================================================

// Parse column span syntax from item content
// Returns (span, content) tuple
// Syntax: () for all columns, (N) for N columns, otherwise 1 column
#let parse-span(item-content, max-cols) = {
  // Try to extract text representation
  let text-str = none

  if type(item-content) == str {
    text-str = item-content
  } else if type(item-content) == content and item-content.has("text") {
    text-str = item-content.text
  }

  // If we got text, check for span patterns
  if text-str != none and type(text-str) == str {
    // Check for () pattern - span all columns
    if text-str.starts-with("()") {
      let remaining = text-str.slice(2)
      // Remove leading space if present
      if remaining.len() > 0 and remaining.starts-with(" ") {
        remaining = remaining.slice(1)
      }
      return (max-cols, [#remaining])
    }

    // Check for (N) pattern - span N columns
    if text-str.starts-with("(") {
      let close-paren = text-str.position(")")
      if close-paren != none and close-paren > 1 {
        let num-str = text-str.slice(1, close-paren)
        // Check if num-str contains only digits
        if num-str.len() > 0 and num-str.match(regex("^\d+$")) != none {
          let parsed = int(num-str)
          let remaining = text-str.slice(close-paren + 1)
          // Remove leading space if present
          if remaining.len() > 0 and remaining.starts-with(" ") {
            remaining = remaining.slice(1)
          }
          return (calc.min(calc.max(parsed, 1), max-cols), [#remaining])
        }
      }
    }
  }

  // Default: no span specified
  return (1, item-content)
}

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
  lbl-weight,
  indent-after,
  indent,
  above-spacing,
  below-spacing,
  flow-dir,
  start-num,
) = {
  let num-items = task-items.len()

  // Calculate label width if auto
  let actual-label-width = if lbl-width == auto {
    let max-width = 0pt
    for i in range(num-items) {
      let label = format-label(start-num + i, fmt)
      let label-size = measure(text(weight: lbl-weight)[#label]).width
      if label-size > max-width { max-width = label-size }
    }
    max-width + indent-after
  } else {
    lbl-width
  }

  // Build grid columns (label + content pairs)
  let grid-columns = ()
  for _ in range(cols) {
    grid-columns.push(actual-label-width)
    grid-columns.push(1fr)
  }

  // Helper to create label cell
  let make-label-cell(label) = {
    let label-height = measure(text(weight: lbl-weight)[#label]).height
    let text-height = measure[A].height
    let baseline-offset = if lbl-baseline == "center" {
      (label-height - text-height) * 0.5
    } else if lbl-baseline == "top" {
      0pt
    } else if lbl-baseline == "bottom" {
      label-height - text-height
    } else if type(lbl-baseline) in (length, relative) {
      lbl-baseline
    } else {
      0pt
    }
    align(lbl-align + top)[#v(baseline-offset)#text(weight: lbl-weight)[#label]]
  }

  // Helper to create content cell
  let make-content-cell(content) = {
    align(left + top)[
      #show math.vec: it => box(baseline: 30%, it)
      #content
    ]
  }

  // Build grid content with column spans
  let grid-content = ()
  let current-col = 0
  let current-row = 0

  for i in range(num-items) {
    let item-data = task-items.at(i)
    let item-content = item-data.at(0)
    let span = item-data.at(1)

    // If current position would exceed columns, move to next row
    if current-col + span > cols {
      // Fill remaining columns in current row with empty cells
      while current-col < cols {
        grid-content.push([])
        grid-content.push([])
        current-col += 1
      }
      current-col = 0
      current-row += 1
    }

    let num = start-num + i
    let label = format-label(num, fmt)

    // Add label cell
    if span == 1 {
      // Single column: normal label + content
      grid-content.push(make-label-cell(label))
      grid-content.push(make-content-cell(item-content))
    } else {
      // Multi-column span: label + content spanning multiple columns
      // Calculate colspan: each column is 2 grid cells (label + content)
      let total-colspan = span * 2
      grid-content.push(make-label-cell(label))
      grid-content.push(grid.cell(colspan: total-colspan - 1, make-content-cell(item-content)))
    }

    current-col += span
  }

  // Fill remaining cells in last row
  while current-col < cols {
    grid-content.push([])
    grid-content.push([])
    current-col += 1
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
  label-weight: auto,
  indent-after-label: auto,
  indent: auto,
  above: auto,
  below: auto,
  flow: auto,
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
  let lbl-weight = if label-weight == auto { cfg.label-weight } else { label-weight }
  let indent-after = if indent-after-label == auto { cfg.indent-after-label } else { indent-after-label }
  let blk-indent = if indent == auto { cfg.indent } else { indent }
  let above-spacing = if above == auto { cfg.above } else { above }
  let below-spacing = if below == auto { cfg.below } else { below }
  let flow-dir = if flow == auto { cfg.flow } else { flow }

  // Extract items from the body content
  // Each item is stored as (content, span) tuple
  let task-items = ()

  // Parse the body - look for enum items
  let body-children = if type(body) == content {
    body.fields().at("children", default: (body,))
  } else {
    (body,)
  }

  // Find enum in children
  let i = 0
  while i < body-children.len() {
    let child = body-children.at(i)

    if child.func() == enum.item {
      let (span, content) = parse-span(child.body, cols)
      task-items.push((content, span))
      i += 1
    } else if child.func() == text and child.text.starts-with("+") {
      // Handle +() and +(N) syntax which gets parsed as text
      // Collect this text node and all following non-item children
      let collected = ()
      let text-start = child.text.slice(1) // Remove the +
      collected.push(text-start)

      // Collect subsequent children until we hit another item or text starting with +
      i += 1
      while i < body-children.len() {
        let next = body-children.at(i)
        if next.func() == enum.item {
          break
        } else if next.func() == text and next.text.starts-with("+") {
          break
        } else {
          collected.push(next)
          i += 1
        }
      }

      // Parse span from the first text element (which has the () marker)
      let (span, _) = parse-span(text-start, cols)
      // Reconstruct content without the span marker
      let remaining-content = ()
      if span == cols {
        // Remove "() " or "()" from text-start
        let cleaned = if text-start.starts-with("() ") {
          text-start.slice(3)
        } else if text-start.starts-with("()") {
          text-start.slice(2)
        } else {
          text-start
        }
        if cleaned.len() > 0 {
          remaining-content.push(cleaned)
        }
      } else if span > 1 {
        // Remove "(N) " or "(N)" pattern
        let close-pos = text-start.position(")")
        if close-pos != none {
          let after = text-start.slice(close-pos + 1)
          if after.starts-with(" ") {
            after = after.slice(1)
          }
          if after.len() > 0 {
            remaining-content.push(after)
          }
        }
      } else {
        remaining-content.push(text-start)
      }

      // Add the rest of the collected children
      for j in range(1, collected.len()) {
        remaining-content.push(collected.at(j))
      }

      task-items.push((remaining-content.join(), span))
    } else if child.has("children") {
      for subchild in child.children {
        if type(subchild) == content and subchild.func() == enum.item {
          let (span, content) = parse-span(subchild.body, cols)
          task-items.push((content, span))
        }
      }
      i += 1
    } else {
      i += 1
    }
  }

  // Fallback: if no enum found, try to find enum directly
  if task-items.len() == 0 and type(body) == content {
    if body.func() == enum {
      for item in body.children {
        if item.func() == enum.item {
          let (span, content) = parse-span(item.body, cols)
          task-items.push((content, span))
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
      lbl-width, lbl-align, lbl-baseline, lbl-weight, indent-after,
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
