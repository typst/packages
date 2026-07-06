
#let hypraw-state = state("hypraw-style", (:))

/// Override settings for the next code block only. Settings reset after use.
///
/// - line-numbers (auto, bool, int, array, none): Line number configuration:
///   - `none` or `false`: Disable line numbers
///   - `true`: Enable with default start (1)
///   - `int`: Start from this line number
///   - `array`: Custom labels per line (must match line count)
/// - copy-button (auto, bool): Enable/disable copy button for next block
/// - highlight (auto, array, dictionary): Line highlighting configuration:
///   - Array of indices/ranges: e.g., `(0, 2, (4, 6))` applies default "highlight" class
///   - Dictionary mapping classes to indices: e.g., `(ins: (0, 2), del: (3,))` for ins/del/mark effects
#let hypraw-set(line-numbers: auto, copy-button: auto, highlight: auto) = context {
  if line-numbers != auto {
    hypraw-state.update(s => {
      s.line-numbers = line-numbers
      s
    })
  }
  if copy-button != auto {
    hypraw-state.update(s => {
      s.copy-button = copy-button
      s
    })
  }
  if highlight != auto {
    hypraw-state.update(s => {
      s.highlight = highlight
      s
    })
  }
}

#let resolve-line-numbers(line-numbers, line-count) = {
  if line-numbers == false or line-numbers == none {
    // No line number
    none
  } else if line-numbers == true {
    // Use 1 as default start number
    range(1, 1 + line-count)
  } else if type(line-numbers) == int {
    // As start number
    range(line-numbers, line-numbers + line-count)
  } else if type(line-numbers) == array {
    // As specified numbers.
    if line-numbers.len() != line-count {
      panic(
        "Should provide line numbers for each line. Expected "
          + str(line-count)
          + ", received "
          + str(line-numbers.len())
          + ".",
      )
    }
    line-numbers
  } else {
    // Invalid
    panic("Invalid line numbers format: " + repr(line-numbers))
  }
}

#let _expand-indices(items) = {
  let result = ()
  for item in items {
    if type(item) == int {
      // Single line index (1-based)
      result.push(item - 1)
    } else if type(item) == array and item.len() == 2 {
      // Range (start, end) inclusive
      let (start, end) = item
      result += range(start - 1, end)
    } else {
      panic("Invalid highlight item format: " + repr(item))
    }
  }
  result.sorted().dedup()
}

#let resolve-highlights(highlight, line-count) = {
  if highlight == none or highlight == false {
    (:)
  } else if type(highlight) == array {
    // Simple array format - applies "highlight" class to all
    (highlight: _expand-indices(highlight))
  } else if type(highlight) == dictionary {
    // Dictionary format - maps class names to line indices
    let result = (:)
    for (class, items) in highlight {
      if type(items) != array {
        panic("Highlight items must be an array for class: " + class)
      }
      result.insert(class, _expand-indices(items))
    }
    result
  } else {
    panic("highlight must be an array or dictionary")
  }
}
