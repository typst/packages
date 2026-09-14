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

// =============================================================================
// CONFIGURATION IMPORTS
// =============================================================================
// Import configuration constants from single source of truth

#import "config.typ": spacing, paragraph-config, counters, CLASSIFICATION_COLORS

// =============================================================================
// UTILITY FUNCTIONS - CONFIGURATION
// =============================================================================

/// Configures document-wide typography and spacing settings.
///
/// Applies consistent formatting across the entire memorandum:
/// - Sets paragraph leading and spacing for proper line height
/// - Configures block spacing to eliminate unwanted gaps
/// - Sets font and configurable size (AFH 33-337 standard is 12pt)
/// - Enables text justification for professional appearance
///
/// - body-font (str | array): Font(s) to use for body text
/// - font-size (length): Font size for body text (default: 12pt)
/// - ctx (content): Content to apply configuration to
/// -> content
#let configure(body-font, font-size: 12pt, ctx) = {
  context{
    set par(leading: spacing.line, spacing:spacing.line, justify: false)
    set block(above:spacing.line, below:0em,spacing: 0em)
    set text(font: body-font, size: font-size, fallback: true)
    ctx
  }
}

/// Creates vertical spacing equivalent to multiple blank lines.
/// 
/// Calculates proper vertical space based on line height and leading
/// to maintain consistent spacing throughout the document.
/// 
/// - count (int): Number of blank lines to create
/// - weak (bool): Whether spacing can be compressed at page breaks
/// -> content
#let blank-lines(count,weak:true) = {
  if count == 0 {
    v(0em, weak:weak)
  } else {
    let lead = spacing.line
    let height = spacing.line-height
    v(lead + (height + lead) * count,weak:weak)
  }
}

/// Creates vertical spacing equivalent to one blank line.
/// Convenience function for single line spacing.
///
/// - weak (bool): Whether spacing can be compressed at page breaks
/// -> content
#let blank-line(weak:true) = blank-lines(1,weak:weak)

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
#let fit-box(width: 2in, height: 1in, alignment:left+horizon, body) = context {
  // 1) measure the unscaled content
  let s = measure(body)

  // 2) compute the uniform scale that fits inside the box
  let f = calc.min(width / s.width, height / s.height) * 100%  // ratio

  // 3) fixed-size box, center the scaled content, and reflow so layout respects it
  box(width: width, height: height, clip: true)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// Checks if a string is in ISO date format (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS).
///
/// Performs a simple pattern check for ISO 8601 date strings by verifying:
/// - String is at least 10 characters long
/// - Characters at positions 4 and 7 are dashes
///
/// - date-str (str): String to check for ISO date pattern
/// -> bool
#let is-iso-date-string(date-str) = {
  if date-str.len() >= 10 {
    let char4 = date-str.at(4)
    let char7 = date-str.at(7)
    return char4 == "-" and char7 == "-"
  }
  return false
}

/// Extracts the date portion (YYYY-MM-DD) from an ISO date string.
///
/// Returns the first 10 characters which contain the date portion of an
/// ISO 8601 date string, removing any time component if present.
///
/// - date-str (str): ISO date string to extract from
/// -> str
#let extract-iso-date(date-str) = {
  date-str.slice(0, 10)
}

/// Formats a date in standard military format or ISO format depending on input type.
///
/// AFH 33-337 "Date": "Use the 'Day Month Year' or 'DD Mmm YY' format for documents
/// addressed to a military organization. For civilian addressees, use the 'Month Day, Year' format."
/// Examples: "15 October 2014" or "15 Oct 14" for military, "October 15, 2014" for civilian
///
/// Intelligently handles different date input formats:
/// - ISO string (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS): Parsed via TOML and displayed in military format
/// - Non-ISO string: Displayed as-is
/// - datetime object: Displayed in military format ("1 January 2024")
///
/// - date (str|datetime): Date to format for display
/// -> str
// NOTE: Consider simplification if Typst adds native ISO date parsing (see CASCADES.md §A)
#let display-date(date) = {
  if type(date) == str {
    if is-iso-date-string(date) {
      // Parse ISO date string using TOML to get datetime object
      let iso-date = extract-iso-date(date)
      let toml-str = "date = " + iso-date
      let parsed = toml(bytes(toml-str))
      parsed.date.display("[day padding:none] [month repr:long] [year]")
    } else {
      date
    }
  }
  else {
    date.display("[day padding:none] [month repr:long] [year]")
  }
}

/// Gets the color associated with a classification level.
/// 
/// - level (str): Classification level string
/// -> color
#let get-classification-level-color(level) = {
  if level == none {
    return rgb(0, 0, 0) // Default to black if no classification
  }
  // Order matters - check most specific first
  let level-order = ("TOP SECRET", "SECRET", "CONFIDENTIAL", "UNCLASSIFIED")
  
  for base-level in level-order {
    if base-level in level {
      return CLASSIFICATION_COLORS.at(base-level)
    }
  }
  
  rgb(0, 0, 0) // Default
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
// PARAGRAPH NUMBERING UTILITIES
// =============================================================================

/// Gets the numbering format for a specific paragraph level.
///
/// AFH 33-337 "The Text of the Official Memorandum" §2: "Number and letter each
/// paragraph and subparagraph" with hierarchical numbering implied by examples.
/// Standard military format follows the pattern: 1., a., (1), (a), etc.
///
/// Returns the appropriate numbering format for AFH 33-337 compliant
/// hierarchical paragraph numbering:
/// - Level 0: "1." (1., 2., 3., etc.)
/// - Level 1: "a." (a., b., c., etc.)
/// - Level 2: "(1)" ((1), (2), (3), etc.)
/// - Level 3: "(a)" ((a), (b), (c), etc.)
/// - Level 4+: Underlined format for deeper nesting
///
/// - level (int): Paragraph nesting level (0-based)
/// -> str | function
#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

/// Generates paragraph number for a given level with proper formatting.
///
/// Creates properly formatted paragraph numbers for the hierarchical numbering
/// system using Typst's native counter display capabilities.
///
/// - level (int): Paragraph nesting level (0-based)
/// - counter-value (none | int): Optional explicit counter value to use (for measuring widths)
/// - increment (bool): Whether to increment the counter after display
/// -> content
#let generate-paragraph-number(level, counter-value: none, increment: false) = {
  let paragraph-counter = counter(paragraph-config.counter-prefix + str(level))
  let numbering-format = get-paragraph-numbering-format(level)

  if counter-value != none {
    // For measuring widths: create temporary counter at specific value
    assert(counter-value >= 0, message: "Counter value of `" + str(counter-value) + "` cannot be less than 0")
    let temp-counter = counter("temp-counter")
    temp-counter.update(counter-value)
    temp-counter.display(numbering-format)
  } else {
    // Standard case: display and optionally increment
    let result = paragraph-counter.display(numbering-format)
    if increment {
      paragraph-counter.step()
    }
    result
  }
}

/// Calculates proper indentation width for a paragraph level.
///
/// AFH 33-337 "The Text of the Official Memorandum" §4-5:
/// - "The first paragraph is never indented; it is numbered and flush left"
/// - "Indent the first line of sub-paragraphs to align the number or letter with
///    the first character of its parent level paragraph"
///
/// Computes the exact indentation needed for hierarchical paragraph alignment
/// by measuring the cumulative width of all ancestor paragraph numbers and their
/// spacing. Uses direct iteration instead of recursion for better performance.
///
/// Per AFH 33-337: Sub-paragraph text aligns with first character of parent text,
/// which means indentation = sum of all ancestor number widths + spacing.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> length
#let calculate-paragraph-indent(level) = {
  assert(level >= 0)
  if level == 0 {
    return 0pt
  }

  // Accumulate widths of all ancestor numbers iteratively
  let total-indent = 0pt
  for ancestor-level in range(level) {
    let ancestor-counter-value = counter(paragraph-config.counter-prefix + str(ancestor-level)).get().at(0)
    let ancestor-number = generate-paragraph-number(ancestor-level, counter-value: ancestor-counter-value)
    // Measure number + spacing buffer
    let width = measure([#ancestor-number#"  "]).width
    total-indent += width
  }

  total-indent
}

/// Global state for tracking current paragraph level.
/// Used internally by the paragraph numbering system to maintain proper nesting.
/// -> state
#let PAR_LEVEL_STATE = state("PAR_LEVEL", 0)

/// Global state for tracking whether we're in backmatter.
/// Used to disable paragraph numbering in backmatter sections.
/// -> state
#let IN_BACKMATTER_STATE = state("IN_BACKMATTER", false)

/// Sets the current paragraph level state.
/// 
/// Internal function used by the paragraph numbering system to track
/// the current nesting level for proper indentation and numbering.
/// 
/// - level (int): Paragraph nesting level to set
/// -> content
#let SET_LEVEL(level) = {
  context {
    PAR_LEVEL_STATE.update(level)
  }
}

/// Creates a formatted paragraph with automatic numbering and indentation.
///
/// Generates a properly formatted paragraph with AFH 33-337 compliant numbering,
/// indentation, and spacing. Automatically manages counter incrementation and
/// nested paragraph state. Used internally by the body rendering system.
///
/// Features:
/// - Automatic paragraph number generation and formatting
/// - Proper indentation based on nesting level via direct width measurement
/// - Counter management for hierarchical numbering
/// - Widow/orphan prevention settings
///
/// - content (content): Paragraph content to format
/// -> content
#let memo-par(content) = context {
  let level = PAR_LEVEL_STATE.get()
  let paragraph-number = generate-paragraph-number(level, increment: true)
  // Reset child level counter
  counter(paragraph-config.counter-prefix + str(level + 1)).update(1)
  let indent-width = calculate-paragraph-indent(level)

  set text(costs: (widow: 0%))

  // Number + two spaces + content, with left padding for nesting
  pad(left: indent-width, paragraph-number + "  " + content)
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
// NOTE: Could be table-driven vs algorithmic (see CASCADES.md §B) — current approach is correct
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