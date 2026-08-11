// taskize - Horizontal columned lists for Typst
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
  max-columns: auto,           // auto = up to number of items for auto-fit
  auto-fit-mode: "fill",       // "fill" = spans may use their span; "uniform" = every item must fit one column
  auto-fit-tolerance: 0.5pt,   // measurement tolerance for wrap detection
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
  max-columns: none,
  auto-fit-mode: none,
  auto-fit-tolerance: none,
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
    if max-columns != none { new.max-columns = max-columns }
    if auto-fit-mode != none { new.auto-fit-mode = auto-fit-mode }
    if auto-fit-tolerance != none { new.auto-fit-tolerance = auto-fit-tolerance }
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
  // Try to extract text representation from content
  let text-str = none

  // Handle different content types
  if type(item-content) == str {
    text-str = item-content
  } else if type(item-content) == content {
    // Try to get the text representation
    if item-content.has("text") {
      text-str = item-content.text
    } else if item-content.has("body") and type(item-content.body) == str {
      text-str = item-content.body
    } else if item-content.has("children") {
      // Extract text from first child if it's text
      let children = item-content.children
      if children.len() > 0 {
        let first = children.at(0)
        if type(first) == str {
          text-str = first
        } else if type(first) == content and first.has("text") {
          text-str = first.text
        }
      }
    }
  }

  // If we got text, check for span patterns
  if text-str != none and type(text-str) == str {
    // Remove leading + if present (from +(N) syntax)
    let clean-text = if text-str.starts-with("+") {
      text-str.slice(1)
    } else {
      text-str
    }

    // Check for () pattern - span all columns
    if clean-text.starts-with("()") {
      let remaining = clean-text.slice(2)
      // Remove leading space if present
      if remaining.len() > 0 and remaining.starts-with(" ") {
        remaining = remaining.slice(1)
      }
      return (max-cols, remaining)
    }

    // Check for (N) pattern - span N columns
    if clean-text.starts-with("(") {
      let close-paren = clean-text.position(")")
      if close-paren != none and close-paren > 1 {
        let num-str = clean-text.slice(1, close-paren)
        // Check if num-str contains only digits
        if num-str.len() > 0 and num-str.match(regex("^\d+$")) != none {
          let parsed = int(num-str)
          let remaining = clean-text.slice(close-paren + 1)
          // Remove leading space if present
          if remaining.len() > 0 and remaining.starts-with(" ") {
            remaining = remaining.slice(1)
          }
          return (calc.min(calc.max(parsed, 1), max-cols), remaining)
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
// Adaptive row heights ("auto" row-gutter)
// =============================================================================

// Rows containing tall inline math (display fractions, matrices, ...) report
// a height based on the font's cap-height/baseline edges, not the actual ink,
// so the ink bleeds into the row-gutter. This rule measures each inline
// equation with bounds text edges and switches only the tall ones over, so
// row heights become truthful while ordinary rows keep their exact leading.
// (Same approach as the breather package, inlined to avoid a dependency.)
#let _breathe-rule(body) = {
  show math.equation.where(block: false): it => context {
    let bounded = {
      set text(top-edge: "bounds", bottom-edge: "bounds")
      it
    }
    if measure(bounded).height > 1.1em.to-absolute() { bounded } else { it }
  }
  body
}

#let _is-adaptive-row-gutter(value) = value == "auto" or value == "adaptive"

// =============================================================================
// Content Classification
// =============================================================================

// Returns true if the content can be laid out inline (in a paragraph line).
// Used to decide whether the label can share the first line with the content,
// which gives true baseline alignment (fractions, vectors, etc. no longer
// push the content below the label's baseline).
// Conservative: anything unknown is treated as block-level, which falls back
// to the previous top-aligned rendering.
#let is-inline-content(node) = {
  if type(node) != content {
    return type(node) in (str, int, float, symbol)
  }
  let f = node.func()
  if f == math.equation {
    return not node.block
  }
  let fname = repr(f)
  if fname in (
    "text", "space", "linebreak", "h",
    "strong", "emph", "sub", "super", "underline", "overline", "strike",
    "highlight", "smartquote", "link", "ref",
  ) {
    return true
  }
  if fname == "sequence" {
    return node.children.all(is-inline-content)
  }
  if fname == "styled" {
    return is-inline-content(node.child)
  }
  return false
}

// =============================================================================
// Internal: Render tasks grid
// =============================================================================

#let _is-auto-fit-columns(cols) = {
  cols == "auto-fit" or cols == "fit"
}

#let _resolve-length(value) = {
  if type(value) in (length, relative) {
    measure(box(width: value)).width
  } else {
    value
  }
}

#let _compute-label-width(task-items, fmt, lbl-width, lbl-weight, indent-after, start-num) = {
  if lbl-width == auto {
    let max-width = 0pt
    for i in range(task-items.len()) {
      let label = format-label(start-num + i, fmt)
      let label-size = measure(text(weight: lbl-weight)[#label]).width
      if label-size > max-width { max-width = label-size }
    }
    max-width + indent-after
  } else {
    lbl-width
  }
}

#let _task-content-width(total-width, cols, span, lbl-width, col-gut, indent-after, indent) = {
  let cols = calc.max(1, cols)
  let span = calc.min(calc.max(1, span), cols)
  let label-width = _resolve-length(lbl-width)
  let column-gutter = _resolve-length(col-gut)
  let label-gutter = _resolve-length(indent-after)
  let block-indent = _resolve-length(indent)
  let inner-width = total-width - block-indent
  let fixed-width = cols * label-width + cols * label-gutter + (cols - 1) * column-gutter
  let content-track = (inner-width - fixed-width) / cols
  if content-track < 0pt { content-track = 0pt }
  content-track * span + (span - 1) * (label-width + label-gutter + column-gutter)
}

#let _task-height-at-width(content, width) = {
  measure(block(width: width, content)).height
}

#let _select-auto-fit-columns(
  task-items,
  max-cols,
  fmt,
  col-gut,
  lbl-width,
  lbl-weight,
  indent-after,
  indent,
  start-num,
  mode,
  tolerance,
  available-width,
) = {
  if task-items.len() == 0 { return 1 }

  let max-cols = if max-cols == auto { task-items.len() } else { max-cols }
  max-cols = calc.max(1, calc.min(max-cols, task-items.len()))
  let label-width = _compute-label-width(task-items, fmt, lbl-width, lbl-weight, indent-after, start-num)
  let tol = _resolve-length(tolerance)

  let base-heights = ()
  for item-data in task-items {
    let content = item-data.at(0)
    let width = _task-content-width(available-width, 1, 1, label-width, col-gut, indent-after, indent)
    base-heights.push(_task-height-at-width(content, width))
  }

  let fits-cols(cols) = {
    for (i, item-data) in task-items.enumerate() {
      let content = item-data.at(0)
      let explicit-span = item-data.at(1)
      if mode == "uniform" or explicit-span > 1 {
        // uniform: every item pinned to one column
        // explicit span items: use their declared span, capped at cols
        let span = if mode == "uniform" { 1 } else { calc.min(explicit-span, cols) }
        let width = _task-content-width(available-width, cols, span, label-width, col-gut, indent-after, indent)
        if measure(content).width > width + tol or _task-height-at-width(content, width) > base-heights.at(i) + tol {
          return false
        }
      } else {
        // fill mode, regular item: auto-span until height matches base.
        // Only height is checked — text always reflows to fit any width, so
        // natural-width would reject long sentences even at full-row span.
        let fitted = false
        for s in range(1, cols + 1) {
          let width = _task-content-width(available-width, cols, s, label-width, col-gut, indent-after, indent)
          if _task-height-at-width(content, width) <= base-heights.at(i) + tol {
            fitted = true
            break
          }
        }
        if not fitted { return false }
      }
    }
    true
  }

  let best = 1
  for cols in range(1, max-cols + 1) {
    if fits-cols(cols) {
      best = cols
    } else {
      break
    }
  }
  best
}

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
  adaptive-rows: false,
) = {
  let num-items = task-items.len()
  let wrap-content = if adaptive-rows { _breathe-rule } else { c => c }

  // Calculate label width if auto
  let actual-label-width = _compute-label-width(task-items, fmt, lbl-width, lbl-weight, indent-after, start-num)

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
      #wrap-content(content)
    ]
  }

  // Baseline-aligned rendering: label and content share the same paragraph
  // line, so their baselines match exactly even when the content starts with
  // a tall element (display fraction, vector, ...). Wrapped lines are pushed
  // past the label column with a hanging indent.
  // Only used for inline content with the default label-baseline ("center");
  // block content and explicit baseline offsets keep the grid-cell rendering.
  let use-inline-baseline = lbl-baseline == "center"

  let make-inline-cell(label, content, span) = {
    let lbl = text(weight: lbl-weight)[#label]
    let halign = if type(lbl-align) == alignment and lbl-align.x != none {
      lbl-align.x
    } else {
      right
    }
    let label-box = box(width: actual-label-width, {
      if halign == left { lbl; h(1fr) }
      else if halign == center { h(1fr); lbl; h(1fr) }
      else { h(1fr); lbl }
    })
    // Explicit par(): bare content in a grid cell is not a paragraph element,
    // so a `set par(hanging-indent: ..)` rule would not apply to it.
    grid.cell(colspan: span * 2, align(left + top, par(
      hanging-indent: actual-label-width + indent-after,
      [#label-box#h(indent-after)#wrap-content(content)],
    )))
  }

  // Build the cell(s) for one item: a single baseline-aligned cell when
  // possible, otherwise the classic label cell + top-aligned content cell.
  let make-item-cells(label, content, span) = {
    if use-inline-baseline and is-inline-content(content) {
      (make-inline-cell(label, content, span),)
    } else if span == 1 {
      (make-label-cell(label), make-content-cell(content))
    } else {
      (
        make-label-cell(label),
        grid.cell(colspan: span * 2 - 1, make-content-cell(content)),
      )
    }
  }

  // Build grid content with column spans
  let grid-content = ()

  if flow-dir == "vertical" {
    // VERTICAL FLOW: Fill columns first (like v0.1.0), with column spanning support
    // For vertical flow without column spans, we use the classic formula:
    // For item i: col = i / num_rows, row = i % num_rows
    // With column spans, items are placed sequentially in available positions

    // First pass: check if any items have spans
    let has-spans = false
    for item-data in task-items {
      if calc.min(item-data.at(1), cols) > 1 {
        has-spans = true
        break
      }
    }

    if not has-spans {
      // Simple case: no column spans, use the classic v0.1.0 algorithm
      let num-rows = calc.ceil(num-items / cols)

      for row in range(num-rows) {
        for col in range(cols) {
          // Calculate item index using vertical flow formula
          let item-idx = col * num-rows + row

          if item-idx < num-items {
            let item-data = task-items.at(item-idx)
            let item-content = item-data.at(0)
            let num = start-num + item-idx
            let label = format-label(num, fmt)

            grid-content += make-item-cells(label, item-content, 1)
          } else {
            // No more items, fill with empty cells
            grid-content.push([])
            grid-content.push([])
          }
        }
      }
    } else {
      // Complex case: has column spans
      // Build a 2D grid to track occupied positions
      // Estimate initial number of rows (may grow)
      let num-rows = calc.ceil(num-items / cols)
      let grid-map = ()  // Array of arrays: grid-map.at(row).at(col) = item-idx or none or "occupied"

      // Initialize grid map
      for r in range(num-rows + 10) {  // Add extra rows in case spans push items down
        let row-arr = ()
        for c in range(cols) {
          row-arr.push(none)
        }
        grid-map.push(row-arr)
      }

      // Place items in column-major order, respecting spans
      // Track the current height (row) of each column
      let col-heights = ()
      for _ in range(cols) {
        col-heights.push(0)
      }

      for item-idx in range(num-items) {
        let item-data = task-items.at(item-idx)
        let span = calc.min(item-data.at(1), cols)

        // Find the column with minimum height that can accommodate this span
        let placed = false
        let best-col = 0
        let best-row = 0

        // Try each starting column position
        for start-col in range(cols) {
          if start-col + span > cols {
            // Span doesn't fit starting from this column
            continue
          }

          // Check the maximum height among spanned columns
          let max-height = 0
          for s in range(span) {
            if col-heights.at(start-col + s) > max-height {
              max-height = col-heights.at(start-col + s)
            }
          }

          // This is a valid position
          if not placed or max-height < best-row {
            best-col = start-col
            best-row = max-height
            placed = true
          }
        }

        if placed {
          // Place item at (best-row, best-col)
          grid-map.at(best-row).at(best-col) = item-idx
          // Mark spanned positions as occupied
          for s in range(1, span) {
            grid-map.at(best-row).at(best-col + s) = "occupied"
          }
          // Update column heights for all spanned columns
          for s in range(span) {
            col-heights.at(best-col + s) = best-row + 1
          }
        }
      }

      // Find actual number of rows used
      let actual-rows = 0
      for r in range(grid-map.len()) {
        let row-has-content = false
        for c in range(cols) {
          if grid-map.at(r).at(c) != none {
            row-has-content = true
            break
          }
        }
        if row-has-content {
          actual-rows = r + 1
        }
      }

      // Convert grid-map to grid-content
      for row in range(actual-rows) {
        let col = 0
        while col < cols {
          let cell-value = grid-map.at(row).at(col)
          if cell-value == none {
            // Empty cell
            grid-content.push([])
            grid-content.push([])
            col += 1
          } else if cell-value == "occupied" {
            // Skip - this is part of a span from a previous column
            // Don't add any cells, the colspan handles it
            col += 1
          } else {
            // Item cell
            let item-idx = cell-value
            let item-data = task-items.at(item-idx)
            let item-content = item-data.at(0)
            let span = calc.min(item-data.at(1), cols)
            let num = start-num + item-idx
            let label = format-label(num, fmt)

            grid-content += make-item-cells(label, item-content, span)
            col += span  // Skip the spanned columns
          }
        }
      }
    }
  } else {
    // HORIZONTAL FLOW: Original logic (fill rows first)
    let current-col = 0
    let current-row = 0

    for i in range(num-items) {
      let item-data = task-items.at(i)
      let item-content = item-data.at(0)
      let span = calc.min(item-data.at(1), cols)

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

      grid-content += make-item-cells(label, item-content, span)

      current-col += span
    }

    // Fill remaining cells in last row
    while current-col < cols {
      grid-content.push([])
      grid-content.push([])
      current-col += 1
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
  max-columns: auto,
  auto-fit-mode: auto,
  auto-fit-tolerance: auto,
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
  let requested-cols = if columns == auto { cfg.columns } else { columns }
  let fmt = if label != auto { label } else if label-format != auto { label-format } else { cfg.label-format }
  let col-gut = if column-gutter == auto { cfg.column-gutter } else { column-gutter }
  let row-gut = if row-gutter == auto { cfg.row-gutter } else { row-gutter }
  // "auto"/"adaptive" row-gutter: rows are sized to their true ink (tall
  // inline math no longer bleeds into the gutter) and the numeric gutter
  // falls back to the configured default.
  let adaptive-rows = _is-adaptive-row-gutter(row-gut)
  if adaptive-rows {
    row-gut = if _is-adaptive-row-gutter(cfg.row-gutter) { 0.6em } else { cfg.row-gutter }
  }
  let max-cols = if max-columns == auto { cfg.max-columns } else { max-columns }
  let fit-mode = if auto-fit-mode == auto { cfg.auto-fit-mode } else { auto-fit-mode }
  let fit-tolerance = if auto-fit-tolerance == auto { cfg.auto-fit-tolerance } else { auto-fit-tolerance }
  let lbl-width = if label-width == auto { cfg.label-width } else { label-width }
  let lbl-align = if label-align == auto { cfg.label-align } else { label-align }
  let lbl-baseline = if label-baseline == auto { cfg.label-baseline } else { label-baseline }
  let lbl-weight = if label-weight == auto { cfg.label-weight } else { label-weight }
  let indent-after = if indent-after-label == auto { cfg.indent-after-label } else { indent-after-label }
  let blk-indent = if indent == auto { cfg.indent } else { indent }
  let above-spacing = if above == auto { cfg.above } else { above }
  let below-spacing = if below == auto { cfg.below } else { below }
  let flow-dir = if flow == auto { cfg.flow } else { flow }
  let span-parse-cols = if _is-auto-fit-columns(requested-cols) {
    if max-cols == auto { 512 } else { max-cols }
  } else {
    requested-cols
  }

  // Extract items from the body content - INDENTATION-INDEPENDENT PARSING
  // Strategy: Flatten ALL enum.item nodes at any depth into a single list
  // Nested enums from indentation differences are just more items
  // Each item is stored as (content, span) tuple
  let task-items = ()

  // Merge extra content into the previous item (used for multiline tasks)
  let merge-item-content(base, extra) = {
    if extra == none { return base }
    let base-content = if type(base) == content { base } else { [#base] }
    let extra-content = if type(extra) == content { extra } else { [#extra] }
    base-content + extra-content
  }

  let append-to-last-item(items, extra) = {
    if extra == none or items.len() == 0 { return items }
    let last = items.at(items.len() - 1)
    let merged = merge-item-content(last.at(0), extra)
    let new-items = items.slice(0, items.len() - 1)
    new-items.push((merged, last.at(1)))
    new-items
  }

  // Helper to remove ALL enum and enum.item nodes from content (they'll be extracted separately)
  let strip-enums(node) = {
    if type(node) != content {
      return node
    }

    // If this IS an enum or enum.item, return empty
    if node.func() == enum or node.func() == enum.item {
      return none
    }

    // If no children, return as-is
    if not node.has("children") {
      return node
    }

    // Process children recursively
    let new-children = ()
    for child in node.children {
      if type(child) == content {
        if child.func() == enum or child.func() == enum.item {
          // Skip enum and enum.item children entirely
          continue
        }
        // Recursively clean
        let cleaned = strip-enums(child)
        if cleaned != none {
          new-children.push(cleaned)
        }
      } else {
        // Non-content (text, etc) - keep it
        new-children.push(child)
      }
    }

    // Return result
    if new-children.len() == 0 {
      return none
    } else if new-children.len() == 1 {
      return new-children.at(0)
    } else {
      // Join multiple children
      return new-children.join()
    }
  }

  // Recursively extract ALL enum.item nodes, flattening any nesting
  let flatten-all-enum-items(node) = {
    let items = ()

    if type(node) != content {
      return items
    }

    if node.func() == enum {
      // Enum - extract all items from it
      for child in node.children {
        items = items + flatten-all-enum-items(child)
      }
    } else if node.func() == enum.item {
      // Found an item!
      // First check if body contains nested enums (from inconsistent indentation)
      let nested = flatten-all-enum-items(node.body)

      if nested.len() > 0 {
        // Has nested items from inconsistent indentation
        // Strip enum.item nodes from body before parsing
        let cleaned-body = strip-enums(node.body)

        // Parse span from cleaned body
        let (span, content-parsed) = if cleaned-body != none {
          parse-span(cleaned-body, span-parse-cols)
        } else {
          (1, [])
        }

        // Add parent item if it has content after cleaning
        if content-parsed != [] {
          items.push((content-parsed, span))
        }

        // Add all nested items at same level
        items = items + nested
      } else {
        // No nesting - parse and add as-is
        let (span, content-parsed) = parse-span(node.body, span-parse-cols)
        items.push((content-parsed, span))
      }
    } else if node.func() == text and node.text.starts-with("+") {
      // Handle +(N) and +() syntax which gets parsed as text (not enum.item)
      // This happens when there's no space after +
      let text-content = node.text.slice(1) // Remove the +
      let (span, content) = parse-span(text-content, span-parse-cols)
      items.push((content, span))
    } else if node.has("children") {
      // Other content - check children for enums and text nodes, and
      // treat non-item content between items as continuation lines.
      for child in node.children {
        let child-items = flatten-all-enum-items(child)
        if child-items.len() > 0 {
          items = items + child-items
        } else {
          items = append-to-last-item(items, child)
        }
      }
    }

    items
  }

  // Extract and flatten all items
  task-items = flatten-all-enum-items(body)

  // Determine starting number
  let start-num = if resume {
    tasks-counter.get().first() + 1
  } else {
    start
  }

  if task-items.len() > 0 {
    if _is-auto-fit-columns(requested-cols) {
      assert(fit-mode in ("fill", "uniform"), message: "auto-fit-mode must be \"fill\" or \"uniform\"")
      layout(size => {
        let cols = _select-auto-fit-columns(
          task-items, max-cols, fmt, col-gut, lbl-width, lbl-weight,
          indent-after, blk-indent, start-num, fit-mode, fit-tolerance, size.width,
        )
        // In fill mode, compute the minimum span each regular item needs to fit
        // at the chosen column count, so wide items auto-span rather than forcing
        // a lower column count.
        let render-items = if fit-mode == "fill" {
          let lw = _compute-label-width(task-items, fmt, lbl-width, lbl-weight, indent-after, start-num)
          let tol = _resolve-length(fit-tolerance)
          task-items.map(item-data => {
            let content = item-data.at(0)
            let explicit-span = item-data.at(1)
            if explicit-span > 1 { return item-data }
            let base-h = _task-height-at-width(content,
              _task-content-width(size.width, 1, 1, lw, col-gut, indent-after, blk-indent))
            for s in range(1, cols + 1) {
              let w = _task-content-width(size.width, cols, s, lw, col-gut, indent-after, blk-indent)
              if _task-height-at-width(content, w) <= base-h + tol {
                return (content, s)
              }
            }
            (content, cols)
          })
        } else {
          task-items
        }
        render-tasks-grid(
          render-items, cols, fmt, col-gut, row-gut,
          lbl-width, lbl-align, lbl-baseline, lbl-weight, indent-after,
          blk-indent, above-spacing, below-spacing,
          flow-dir, start-num,
          adaptive-rows: adaptive-rows,
        )
      })
    } else {
      render-tasks-grid(
        task-items, requested-cols, fmt, col-gut, row-gut,
        lbl-width, lbl-align, lbl-baseline, lbl-weight, indent-after,
        blk-indent, above-spacing, below-spacing,
        flow-dir, start-num,
        adaptive-rows: adaptive-rows,
      )
    }
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
