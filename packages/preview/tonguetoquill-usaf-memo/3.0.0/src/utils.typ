// utils.typ: Utility functions and backend code for Typst usaf-memo package.
//
// This module provides core utility functions, configuration constants, and helper
// functions used by the main memorandum template. It handles spacing calculations,
// paragraph numbering, grid layouts, and various formatting utilities required
// for AFH 33-337 compliance.
//
// Key components:
// - Spacing constants and configuration management
// - Paragraph numbering and indentation utilities
// - Grid layout and backmatter formatting functions
// - Date formatting and content scaling utilities
// - Indorsement processing and ordinal number generation

#import "config.typ": CLASSIFICATION_COLORS, counters, paragraph-config, spacing

// Shared measured line-stride cache used by blank-line spacing and body
// line-count heuristics. Value is a `length` set once in `frontmatter`.
#let LINE_STRIDE = state("LINE_STRIDE")
// Shared blank-line step cache used by structural spacing.
#let BLANK_LINE_STEP = state("BLANK_LINE_STEP")

/// Creates vertical spacing equivalent to multiple blank lines.
///
/// Each step matches one row of the body paragraph line grid.
///
/// - count (int): Number of blank lines to create
/// - weak (bool): Whether spacing can be compressed at page breaks
/// -> content
#let blank-lines(count, weak: true) = {
  if count == 0 {
    v(0em, weak: weak)
  } else {
    context {
      let measured-stride = {
        let one-line = measure(par(spacing: 0pt)[x]).height
        measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
      }
      // Scale legacy visual step with current font size:
      // 19.05pt was tuned for 12pt body text.
      let em-size = measure(box(width: 1em)[]).width
      let legacy-scaled = spacing.vertical * (em-size / 12pt)
      let fallback-step = calc.max(measured-stride, legacy-scaled)
      let cached-step = BLANK_LINE_STEP.get()
      let step = if cached-step != none { cached-step } else { fallback-step }
      v(step * count, weak: weak)
    }
  }
}

/// Creates vertical spacing equivalent to one blank line.
/// Convenience function for single line spacing.
///
/// - weak (bool): Whether spacing can be compressed at page breaks
/// -> content
#let blank-line(weak: true) = blank-lines(1, weak: weak)

// =============================================================================
// GENERAL UTILITY FUNCTIONS
// =============================================================================

/// Checks if a value is "falsey" (none, false, empty array, or empty string).
///
/// Provides a consistent way to test for empty or missing values across
/// the template system. Used for conditional rendering of optional sections.
///
/// - value (any): The value to check for "falsey" status
/// -> bool
#let falsey(value) = {
  value == none or value == false or (type(value) == array and value.len() == 0) or (type(value) == str and value == "")
}

/// Scales content to fit within a specified box while maintaining aspect ratio.
///
/// Automatically measures content and calculates uniform scaling to fit within
/// the given dimensions. Commonly used for letterhead seals and other images
/// that need to fit specific size constraints while preserving proportions.
///
/// - width (length): Maximum width for the content (default: 2in)
/// - height (length): Maximum height for the content (default: 1in)
/// - alignment (alignment): Content alignment within the box (default: left+horizon)
/// - body (content): Content to scale and fit
/// -> content
#let fit-box(width: 2in, height: 1in, alignment: left + horizon, body) = context {
  // 1) measure the unscaled content
  let s = measure(body)

  // 2) compute the uniform scale that fits inside the box
  let f = calc.min(width / s.width, height / s.height) * 100% // ratio

  // 3) fixed-size box, center the scaled content, and reflow so layout respects it
  box(width: width, height: height, clip: true)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// Formats a date for the memo heading.
///
/// - String: shown as-is (use for fixed text like placeholders).
/// - datetime: USAF style `DD Month YYYY`; DAF style `Month DD, YYYY`.
///
/// - date (str|datetime): Date to format for display
/// - memo-style (str): `"usaf"` or `"daf"`
/// -> content
#let display-date(date, memo-style: "usaf") = {
  assert(
    memo-style in ("usaf", "daf"),
    message: "memo-style for display-date must be \"usaf\" or \"daf\"",
  )
  if type(date) == str {
    date
  } else {
    let pattern = if memo-style == "daf" {
      "[month repr:long] [day padding:none], [year]"
    } else {
      "[day padding:none] [month repr:long] [year]"
    }
    date.display(pattern)
  }
}

/// Gets the banner color for a classification marking.
///
/// Matches when `level` (trimmed) starts with a known prefix: TOP SECRET, SECRET, or UNCLASSIFIED.
/// Otherwise returns black.
///
/// - level (str): Marking string shown in header/footer
/// -> color
#let get-classification-level-color(level) = {
  if level == none or type(level) != str {
    return rgb(0, 0, 0)
  }
  let s = level.trim()
  // "TOP SECRET" before "SECRET" so the full phrase matches first.
  let level-order = ("TOP SECRET", "SECRET", "UNCLASSIFIED")
  for base-level in level-order {
    if s.starts-with(base-level) {
      return CLASSIFICATION_COLORS.at(base-level)
    }
  }
  rgb(0, 0, 0)
}

// =============================================================================
// GRID LAYOUT UTILITIES
// =============================================================================

/// Creates an automatic grid layout from string or array content.
///
/// Converts 1D content into a multi-column grid layout with proper spacing.
/// Used primarily for formatting recipient lists in the "MEMORANDUM FOR" section
/// where multiple organizations need to be displayed in columns.
///
/// Features:
/// - Automatic column distribution and row filling
/// - Configurable column spacing and count
/// - Handles both single strings and arrays of strings
/// - Adds padding cells to maintain consistent column alignment
///
/// - content (str | array): Content to arrange in grid (strings only)
/// - column-gutter (length): Space between columns (default: 0.5em)
/// - cols (int): Number of columns for the grid (default: 3)
/// -> grid
#let create-auto-grid(content, column-gutter: .5em, cols: 3) = {
  let content_type = type(content)

  assert(content_type == str or content_type == array, message: "Content must be a string or an array of strings.")
  if content_type == array {
    for item in content {
      assert(type(item) == str, message: "All items in content array must be strings.")
    }
  }

  // Normalize to 1d array
  if content_type == str {
    content = (content,)
  }


  // Build cell array in row-major order
  let cells = ()
  let i = 0
  for item in content {
    i += 1
    cells.push(item)
    if calc.rem(i, cols) == 0 {
      // Add empty cell to pad the page
      cells.push([])
    }
  }

  // Add padding cells to complete the last row if needed
  let remainder = calc.rem(cells.len(), cols + 1)
  if remainder != 0 {
    let padding_needed = (cols + 1) - remainder
    for _ in range(padding_needed) {
      cells.push([])
    }
  }

  grid(
    columns: calc.max(1, cols) + 1,
    column-gutter: .1fr,
    row-gutter: spacing.line,
    ..cells
  )
}

// =============================================================================
// TYPE NORMALIZATION UTILITIES
// =============================================================================

/// Ensures the input is an array. If already an array, returns as-is.
/// If not an array, wraps the value in a tuple.
///
/// This utility eliminates repetitive `if type(x) == array` checks throughout
/// the codebase by providing a canonical "normalize to array" function.
///
/// - value: Any value to normalize to array form
/// - Returns: Array containing the value(s)
///
/// Examples:
/// - ensure-array("foo") → ("foo",)
/// - ensure-array(("a", "b")) → ("a", "b")
/// - ensure-array(none) → ()
#let ensure-array(value) = {
  if value == none {
    ()
  } else if type(value) == array {
    value
  } else {
    (value,)
  }
}

/// Ensures the input is a string. If already a string, returns as-is.
/// If an array, joins elements with the specified separator.
///
/// This utility eliminates repetitive `if type(x) == array { x.join(...) }`
/// checks throughout the codebase by providing a canonical "normalize to string"
/// function.
///
/// - value: Any value to normalize to string form
/// - separator: String to use when joining array elements (default: "\n")
/// - Returns: String representation of the value
///
/// Examples:
/// - ensure-string("foo") → "foo"
/// - ensure-string(("a", "b")) → "a\nb"
/// - ensure-string(("a", "b"), ", ") → "a, b"
/// - ensure-string(none) → ""
#let ensure-string(value, separator: "\n") = {
  if value == none {
    ""
  } else if type(value) == array {
    value.join(separator)
  } else {
    str(value)
  }
}

/// Extracts the first element from an array, or returns the value if not an array.
///
/// This utility eliminates repetitive ternary operators like
/// `if type(x) == array { x.at(0) } else { x }` by providing a canonical
/// "first element or self" function.
///
/// - value: Any value to extract from
/// - Returns: First array element if array, otherwise the value itself
///
/// Examples:
/// - first-or-value("foo") → "foo"
/// - first-or-value(("a", "b")) → "a"
/// - first-or-value(()) → none
/// - first-or-value(none) → none
#let first-or-value(value) = {
  if value == none {
    none
  } else if type(value) == array {
    if value.len() > 0 {
      value.at(0)
    } else {
      none
    }
  } else {
    value
  }
}


// =============================================================================
// INDORSEMENT UTILITIES
// =============================================================================

/// Converts number to ordinal suffix for indorsements following AFH 33-337 conventions.
///
/// AFH 33-337 Chapter 14 indorsement examples show "1st Ind", "2d Ind", "3d Ind" format.
/// Note: Military style uses "2d" and "3d" instead of "2nd" and "3rd" per DoD correspondence standards.
///
/// Generates proper ordinal suffixes for indorsement numbering:
/// - 1st, 2d, 3d, 4th, 5th, etc. (note: military uses "2d" and "3d", not "2nd" and "3rd")
/// - Special handling for 11th, 12th, 13th (all use "th")
/// - Follows official military correspondence standards
///
/// - number (int): The indorsement number (1, 2, 3, etc.)
/// -> str
#let get-ordinal-suffix(number) = {
  let last-digit = calc.rem(number, 10)
  let last-two-digits = calc.rem(number, 100)

  if last-two-digits >= 11 and last-two-digits <= 13 {
    "th"
  } else if last-digit == 1 {
    "st"
  } else if last-digit == 2 {
    "d"
  } else if last-digit == 3 {
    "d"
  } else {
    "th"
  }
}

/// Formats indorsement number according to AFH 33-337 standards.
///
/// Creates properly formatted indorsement labels with ordinal suffixes:
/// - "1st Ind", "2d Ind", "3d Ind", "4th Ind", etc.
/// - Uses military-specific ordinal format (2d/3d instead of 2nd/3rd)
/// - Combines with "Ind" suffix for standard indorsement header format
///
/// - number (int): Indorsement sequence number (1, 2, 3, etc.)
/// -> str
#let format-indorsement-number(number) = {
  let suffix = get-ordinal-suffix(number)
  str(number) + suffix + " Ind"
}

/// Processes and renders an array of indorsements.
///
/// Iterates through an array of indorsement objects and renders each one
/// with proper formatting and font settings. Used by the main memorandum
/// template to process the indorsements parameter.
///
/// - indorsements (array): Array of indorsement objects created with indorsement()
/// - body-font (str | array): Font(s) to use for indorsement text
/// - font-size (length): Font size for indorsement text (default: 12pt)
/// -> content
#let process-indorsements(indorsements, body-font: none, font-size: 12pt) = {
  if not falsey(indorsements) {
    for indorsement in indorsements {
      (indorsement.render)(body-font: body-font, font-size: font-size)
    }
  }
}
