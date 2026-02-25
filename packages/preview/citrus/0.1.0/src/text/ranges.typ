// citrus - Range Formatting Module
//
// Handles page and year range formatting according to CSL options:
// - page-range-format: expanded, minimal, minimal-two, chicago, chicago-15, chicago-16
// - year-range-format: same options

// =============================================================================
// Module-level regex patterns (avoid recompilation)
// =============================================================================

// Pattern for splitting ranges on dash or en-dash
#let _range-split-pattern = regex("[\\-–\\u2013]")

// Pattern for detecting digits
#let _digit-pattern = regex("[0-9]")

// =============================================================================
// Range Delimiter
// =============================================================================

/// Get the range delimiter from locale or default to en-dash
///
/// - ctx: Context with locale
/// - range-type: "page" or "year"
/// Returns: Delimiter string
#let get-range-delimiter(ctx, range-type: "page") = {
  // Try to get from locale terms
  let term-name = range-type + "-range-delimiter"
  // Default to en-dash
  "–"
}

// =============================================================================
// Range Parsing
// =============================================================================

/// Parse a range string into start and end parts
///
/// - range-str: String like "123-456" or "123–456"
/// Returns: (start, end) tuple or none if not a range
#let parse-range(range-str) = {
  if range-str == none or range-str == "" { return none }

  let str = str(range-str)

  // Match patterns like "123-456", "123–456", "A123-A456", "123a-123b"
  let parts = str.split(_range-split-pattern)

  if parts.len() == 2 {
    let start = parts.at(0).trim()
    let end = parts.at(1).trim()
    if start != "" and end != "" {
      return (start: start, end: end)
    }
  }

  none
}

/// Extract numeric part and prefix/suffix from a page number
///
/// - page-str: String like "123", "A123", "123a"
/// Returns: (prefix, number, suffix) tuple
#let parse-page-parts(page-str) = {
  if page-str == "" { return ("", "", "") }

  let str = page-str.trim()

  // Match prefix (letters before digits), number, suffix (letters after digits)
  let prefix = ""
  let number = ""
  let suffix = ""

  let in-number = false
  let after-number = false

  for char in str.clusters() {
    let is-digit = char.match(_digit-pattern) != none

    if is-digit {
      if after-number {
        // This shouldn't happen in valid page numbers
        suffix += char
      } else {
        number += char
        in-number = true
      }
    } else {
      if in-number {
        after-number = true
        suffix += char
      } else {
        prefix += char
      }
    }
  }

  (prefix, number, suffix)
}

// =============================================================================
// Range Formatting
// =============================================================================

/// Format a range with expanded format (full numbers on both sides)
///
/// - start: Start of range
/// - end: End of range
/// - delimiter: Range delimiter
/// Returns: Formatted string
#let format-range-expanded(start, end, delimiter) = {
  start + delimiter + end
}

/// Format a range with minimal format (remove common leading digits)
///
/// - start: Start of range
/// - end: End of range
/// - delimiter: Range delimiter
/// - min-chars: Minimum characters to keep in end (default 1)
/// Returns: Formatted string
#let format-range-minimal(start, end, delimiter, min-chars: 1) = {
  let (s-prefix, s-num, s-suffix) = parse-page-parts(start)
  let (e-prefix, e-num, e-suffix) = parse-page-parts(end)

  // If prefixes differ, use expanded format
  if s-prefix != e-prefix {
    return format-range-expanded(start, end, delimiter)
  }

  // If numbers are same length, try to minimize
  if s-num.len() == e-num.len() and s-num.len() > 0 {
    let s-chars = s-num.clusters()
    let e-chars = e-num.clusters()

    // Find how many leading digits match
    let matching = 0
    for i in range(s-chars.len()) {
      if s-chars.at(i) == e-chars.at(i) {
        matching += 1
      } else {
        break
      }
    }

    // Keep at least min-chars in the end
    let keep = calc.max(e-chars.len() - matching, min-chars)
    let minimized-end = e-chars.slice(e-chars.len() - keep).join("")

    return (
      s-prefix
        + s-num
        + s-suffix
        + delimiter
        + e-prefix
        + minimized-end
        + e-suffix
    )
  }

  format-range-expanded(start, end, delimiter)
}

/// Format a range with Chicago 15th edition style
///
/// Chicago 15th:
/// - 1-99: use all digits
/// - 100+: use changed digits only, except:
///   - if second is in 1-9, use two digits (e.g., 107-8 -> 107-8, 1007-8 -> 1007-8)
///   - if second is in 10-99, use two digits (e.g., 1496-504 -> 1496-504)
///
/// - start: Start of range
/// - end: End of range
/// - delimiter: Range delimiter
/// Returns: Formatted string
#let format-range-chicago15(start, end, delimiter) = {
  let (s-prefix, s-num, s-suffix) = parse-page-parts(start)
  let (e-prefix, e-num, e-suffix) = parse-page-parts(end)

  if s-prefix != e-prefix or s-num == "" or e-num == "" {
    return format-range-expanded(start, end, delimiter)
  }

  let s-int = int(s-num)
  let e-int = int(e-num)

  // Calculate minimized end
  let minimized-end = if s-int > 100 and calc.rem(s-int, 100) != 0 {
    // Check if they share the same hundreds
    let s-hundreds = calc.floor(s-int / 100)
    let e-hundreds = calc.floor(e-int / 100)

    if s-hundreds == e-hundreds {
      str(calc.rem(e-int, 100))
    } else if s-int >= 10000 {
      str(calc.rem(e-int, 1000))
    } else {
      e-num
    }
  } else {
    e-num
  }

  s-prefix + s-num + s-suffix + delimiter + e-prefix + minimized-end + e-suffix
}

/// Format a range with Chicago 16th edition style
///
/// Chicago 16th: Similar to 15th but slightly different rules
/// Uses changed part only, with minimum of 2 digits for numbers > 100
///
/// - start: Start of range
/// - end: End of range
/// - delimiter: Range delimiter
/// Returns: Formatted string
#let format-range-chicago16(start, end, delimiter) = {
  let (s-prefix, s-num, s-suffix) = parse-page-parts(start)
  let (e-prefix, e-num, e-suffix) = parse-page-parts(end)

  if s-prefix != e-prefix or s-num == "" or e-num == "" {
    return format-range-expanded(start, end, delimiter)
  }

  let s-int = int(s-num)
  let e-int = int(e-num)

  let minimized-end = if s-int > 100 and calc.rem(s-int, 100) != 0 {
    // Find the divisor where they differ
    let result = e-num
    for i in range(2, e-num.len()) {
      let divisor = calc.pow(10, i)
      if calc.floor(s-int / divisor) == calc.floor(e-int / divisor) {
        result = str(calc.rem(e-int, divisor))
        break
      }
    }
    result
  } else {
    e-num
  }

  s-prefix + s-num + s-suffix + delimiter + e-prefix + minimized-end + e-suffix
}

// =============================================================================
// Main API
// =============================================================================

/// Format a page range according to CSL page-range-format
///
/// - page-str: Page string (may be a range like "123-456")
/// - format: "expanded", "minimal", "minimal-two", "chicago", "chicago-15", "chicago-16"
/// - ctx: Context for locale lookup
/// Returns: Formatted string
#let format-page-range(page-str, format: "expanded", ctx: none) = {
  if page-str == none or page-str == "" { return page-str }

  let delimiter = get-range-delimiter(ctx, range-type: "page")
  let range = parse-range(page-str)

  if range == none {
    // Not a range, return as-is (but replace hyphens with proper delimiter)
    return str(page-str).replace("-", delimiter)
  }

  let start = range.start
  let end = range.end

  if format == "expanded" or format == none {
    format-range-expanded(start, end, delimiter)
  } else if format == "minimal" {
    format-range-minimal(start, end, delimiter, min-chars: 1)
  } else if format == "minimal-two" {
    format-range-minimal(start, end, delimiter, min-chars: 2)
  } else if format == "chicago" or format == "chicago-15" {
    format-range-chicago15(start, end, delimiter)
  } else if format == "chicago-16" {
    format-range-chicago16(start, end, delimiter)
  } else {
    // Unknown format, use expanded
    format-range-expanded(start, end, delimiter)
  }
}

/// Format a year range according to CSL year-range-format
///
/// - year-str: Year string (may be a range like "2020-2021")
/// - format: Same options as page-range-format
/// - ctx: Context for locale lookup
/// Returns: Formatted string
#let format-year-range(year-str, format: "expanded", ctx: none) = {
  if year-str == none or year-str == "" { return year-str }

  let delimiter = get-range-delimiter(ctx, range-type: "year")
  let range = parse-range(year-str)

  if range == none {
    return str(year-str).replace("-", delimiter)
  }

  let start = range.start
  let end = range.end

  // Year ranges typically use minimal-two for academic styles
  if format == "expanded" or format == none {
    format-range-expanded(start, end, delimiter)
  } else if format == "minimal" {
    format-range-minimal(start, end, delimiter, min-chars: 1)
  } else if format == "minimal-two" {
    format-range-minimal(start, end, delimiter, min-chars: 2)
  } else if (
    format == "chicago" or format == "chicago-15" or format == "chicago-16"
  ) {
    // Chicago style for years typically keeps last two digits
    format-range-minimal(start, end, delimiter, min-chars: 2)
  } else {
    format-range-expanded(start, end, delimiter)
  }
}
