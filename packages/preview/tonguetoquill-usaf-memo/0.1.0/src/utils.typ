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
// CONFIGURATION CONSTANTS
// =============================================================================

/// Spacing constants following AFH 33-337 standards.
/// 
/// Defines standard measurements used throughout the memorandum template:
/// - two-spaces: Standard separator between labels and content
/// - line: Line spacing within paragraphs for proper readability
/// - line-height: Base height for line calculations
/// - tab: Tab stop distance for paragraph indentation alignment
/// - margin: Standard page margin (1 inch on all sides)
/// 
/// -> dictionary
#let spacing = (
  two-spaces: 0.5em,      // Standard two-space separator
  line:.5em,            // Line spacing within paragraphs
  line-height:.7em,      //base height for lines
  tab: 0.5in,             // Tab stop for alignment
  margin:1in            // Standard page margin
)

/// Configures document-wide typography and spacing settings.
/// 
/// Applies consistent formatting across the entire memorandum:
/// - Sets paragraph leading and spacing for proper line height
/// - Configures block spacing to eliminate unwanted gaps
/// - Sets font and size to 12pt (AFH 33-337 standard)
/// - Enables text justification for professional appearance
/// 
/// - body-font (str | array): Font(s) to use for body text
/// - ctx (content): Content to apply configuration to
/// -> content
#let configure(body-font,ctx) = {
  context{
    set par(leading: spacing.line, spacing:spacing.line, justify: true)
    set block(above:spacing.line, below:0em,spacing: 0em)
    set text(font: body-font, size: 12pt, fallback: false)
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
  let lead = spacing.line
  let height = spacing.line-height
  v(lead + (height + lead) * count,weak:weak)
}

/// Creates vertical spacing equivalent to one blank line.
/// Convenience function for single line spacing.
/// 
/// - weak (bool): Whether spacing can be compressed at page breaks
/// -> content
#let blank-line(weak:true) = blank-lines(1,weak:weak)

/// Paragraph numbering configuration dictionary.
/// 
/// Defines the hierarchical numbering system for AFH 33-337 compliant paragraphs:
/// - Level 0: 1., 2., 3., etc. (base paragraphs)
/// - Level 1: a., b., c., etc. (subparagraphs)  
/// - Level 2: (1), (2), (3), etc. (sub-subparagraphs)
/// - Level 3: (a), (b), (c), etc. (sub-sub-subparagraphs)
/// - Level 4+: Underlined numbers/letters for deeper nesting
/// 
/// -> dictionary
#let paragraph-config = (
  counter-prefix: "par-counter-",
  numbering-formats: ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n))),
  block-indent-state: state("BLOCK_INDENT", true),
)

/// Global counters for document structure.
/// 
/// Maintains state for document-wide numbering systems:
/// - indorsement: Sequential numbering of indorsements (1st Ind, 2nd Ind, etc.)
/// 
/// -> dictionary
#let counters = (
  indorsement: counter("indorsement"),
)

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

/// Formats a date in standard military format.
/// 
/// Converts a datetime object to the standard format used in military correspondence:
/// "1 January 2024" (day without padding, full month name, four-digit year).
/// 
/// - date (datetime): Date to format for display
/// -> str
#let display-date(date) = {
  date.display("[day padding:none] [month repr:long] [year]")
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

  grid(
    columns: calc.max(1, cols) + 1,
    column-gutter: .1fr,
    row-gutter: spacing.line,
    ..cells
  )
}

// =============================================================================
// BACKMATTER SECTION UTILITIES
// =============================================================================

/// Renders backmatter sections with intelligent page break handling.
/// 
/// Provides smart formatting for memorandum backmatter sections (attachments, cc, distribution)
/// with features to prevent orphaned section headers and provide continuation labeling
/// when content spans multiple pages.
/// 
/// Features:
/// - Automatic page break detection and handling
/// - Continuation labeling for multi-page sections
/// - Flexible numbering styles for different section types
/// - Consistent formatting across all backmatter sections
/// 
/// - content (content | array): Section content to render
/// - section-label (str): Label for the section (e.g., "Attachments:", "cc:")
/// - numbering-style (none | str | function): Optional numbering format for lists
/// - continuation-label (none | str): Custom label when content continues on next page
/// -> content
#let render-backmatter-section(
  content, 
  section-label, 
  numbering-style: none, 
  continuation-label: none
) = {
  let formatted-content = {
    [#section-label]
    parbreak()
    if numbering-style != none { 
      let items = if type(content) == array { content } else { (content,) }
      enum(..items, numbering: numbering-style) 
    } else { 
      if type(content) == array {
        content.join("\n")
      } else {
        content
      }
    }
  }
  
  context {
    let available-space = page.height - here().position().y - 1in
    if measure(formatted-content).height > available-space {
      let continuation-text = if continuation-label != none { 
        continuation-label 
      } else { 
        section-label + " (listed on next page):" 
      }
      continuation-text
      pagebreak()
    }
    formatted-content
  }
}

/// Calculates vertical spacing before backmatter sections.
/// 
/// Provides appropriate vertical spacing between the main memorandum body
/// and backmatter sections, or between multiple backmatter sections.
/// Uses different spacing for the first section vs. subsequent sections.
/// 
/// - is-first-section (bool): Whether this is the first backmatter section
/// -> content
#let calculate-backmatter-spacing(is-first-section) = {
  context {
    let line_count = if is-first-section { 2 } else { 1 }
    blank-lines(line_count)
    
  }
}

// =============================================================================
// PARAGRAPH NUMBERING UTILITIES
// =============================================================================

/// Gets the numbering format for a specific paragraph level.
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
  if level < paragraph-config.numbering-formats.len() {
    paragraph-config.numbering-formats.at(level)
  } else {
    "i."  // Fallback for deep nesting
  }
}

/// Generates paragraph number for a given level with proper formatting.
/// 
/// Creates properly formatted paragraph numbers for the hierarchical numbering
/// system. Can either use the current counter value or accept an explicit value.
/// Supports both automatic counter incrementation and manual counter control.
/// 
/// - level (int): Paragraph nesting level (0-based)
/// - counter-value (none | int): Optional explicit counter value to use
/// - increment (bool): Whether to increment the counter after display
/// -> content
#let generate-paragraph-number(level, counter-value: none, increment: false) = {
  let paragraph-counter = counter(paragraph-config.counter-prefix + str(level))
  
  if counter-value != none {
    assert(counter-value >= 0,message: "Counter value of `" + str(counter-value) + "` cannot be less than 0")
    let temp-counter = counter("temp-counter")
    temp-counter.update(counter-value)
    let numbering-format = get-paragraph-numbering-format(level)
    temp-counter.display(numbering-format)
  } else {
    let numbering-format = get-paragraph-numbering-format(level)
    let result = paragraph-counter.display(numbering-format)
    if increment { 
      paragraph-counter.step() 
    }
    result
  }
}

/// Calculates proper indentation width for a paragraph level.
/// 
/// Computes the exact indentation needed for hierarchical paragraph alignment
/// by measuring the width of parent paragraph numbers and adding appropriate
/// spacing. Ensures consistent alignment with AFH 33-337 tab stop standards.
/// 
/// - level (int): Paragraph nesting level (0-based)
/// -> length
/// -> length
#let calculate-paragraph-indent(level) = {
  assert(level >= 0)
  if level == 0 { 
    return 0pt 
  }
  
  let parent-level = level - 1
  let parent-indent = calculate-paragraph-indent(parent-level)
  let parent-counter = counter(paragraph-config.counter-prefix + str(parent-level)).get().at(0) 
  let parent-counter-value = counter(paragraph-config.counter-prefix + str(parent-level)).get().at(0)
  let parent-number = generate-paragraph-number(parent-level, counter-value: parent-counter-value)

  let indent-buffer = [#h(parent-indent)#parent-number#h(spacing.two-spaces)]
  return measure(indent-buffer).width
}

/// Global state for tracking current paragraph level.
/// Used internally by the paragraph numbering system to maintain proper nesting.
/// -> state
#let PAR_LEVEL_STATE = state("PAR_LEVEL", 0)

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
/// - Proper indentation based on nesting level
/// - Counter management for hierarchical numbering
/// - Widow/orphan prevention settings
/// - Support for both block and hanging indent styles
/// 
/// - content (content): Paragraph content to format
/// -> content
#let memo-par(content) = {
  context {
    let level = PAR_LEVEL_STATE.get()
    let paragraph-number = generate-paragraph-number(level, increment: true)
    counter(paragraph-config.counter-prefix + str(level + 1)).update(1)
    let indent-width = calculate-paragraph-indent(level)
    set text(costs: (widow: 0%)) 

    let output = {
      if paragraph-config.block-indent-state.get() {
        pad(left: indent-width)[#paragraph-number#h(spacing.two-spaces)#content]
      } else {
        pad(left: 0em)[#h(indent-width)#paragraph-number#h(spacing.two-spaces)#content]
      }
    }
    output
  }
}

// =============================================================================
// INDORSEMENT UTILITIES
// =============================================================================

/// Converts number to ordinal suffix for indorsements following AFH 33-337 conventions.
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
/// -> content
#let process-indorsements(indorsements, body-font: none) = {
  if not falsey(indorsements) {
    for indorsement in indorsements {
      (indorsement.render)(body-font: body-font)
    }
  }
}