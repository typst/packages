// citeproc-typst - Quote Handling Module
//
// Implements CSL quote flipflopping:
// - Alternates between outer and inner quotes for nested quotations
// - Handles locale-specific quote marks

#import "../parsing/locales.typ": get-quote-chars

// =============================================================================
// Quote Functions
// =============================================================================

/// Apply quotes to text content
///
/// - text: The text to quote
/// - ctx: Context with locale info
/// - level: Nesting level (0 = outer quotes, 1 = inner quotes, etc.)
/// Returns: Quoted text
#let apply-quotes(text, ctx, level: 0) = {
  if text == none or text == "" or text == [] { return text }

  let lang = ctx.style.at("default-locale", default: "en")
  let chars = get-quote-chars(lang)

  // Alternate between outer and inner quotes based on level
  let is-inner = calc.rem(level, 2) == 1

  let open = if is-inner { chars.open-inner-quote } else { chars.open-quote }
  let close = if is-inner { chars.close-inner-quote } else { chars.close-quote }

  [#open#text#close]
}

/// Count quote nesting level in a string
///
/// Counts how many levels deep we are in quotes
///
/// - text: Text to analyze
/// - ctx: Context with locale info
/// Returns: Integer nesting level
#let count-quote-nesting(text, ctx) = {
  if text == none or type(text) != str { return 0 }

  let lang = ctx.style.at("default-locale", default: "en")
  let chars = get-quote-chars(lang)

  let level = 0
  let max-level = 0

  for char in text {
    if (
      char == chars.open-quote.first() or char == chars.open-inner-quote.first()
    ) {
      level += 1
      if level > max-level { max-level = level }
    } else if (
      char == chars.close-quote.first()
        or char == chars.close-inner-quote.first()
    ) {
      level -= 1
    }
  }

  max-level
}

/// Transform nested quotes in text to use proper alternating marks
///
/// This is a simplified flipflop that handles basic quote nesting
///
/// - text: Text with quotes
/// - ctx: Context with locale info
/// Returns: Text with properly alternated quotes
#let flipflop-quotes(text, ctx) = {
  if text == none or type(text) != str { return text }

  let lang = ctx.style.at("default-locale", default: "en")
  let chars = get-quote-chars(lang)

  // Simple state machine for quote level
  let result = ""
  let level = 0

  // Unicode quote characters for detection
  let left-double = "\u{201C}" // "
  let right-double = "\u{201D}" // "
  let straight-double = "\""
  let left-single = "\u{2018}" // '
  let right-single = "\u{2019}" // '
  let straight-single = "'"

  // Track character by character
  for char in text.clusters() {
    if char == straight-double or char == left-double or char == right-double {
      if char == straight-double or char == left-double {
        // Opening quote
        if calc.rem(level, 2) == 0 {
          result += chars.open-quote
        } else {
          result += chars.open-inner-quote
        }
        level += 1
      } else {
        // Closing quote
        level -= 1
        if calc.rem(level, 2) == 0 {
          result += chars.close-quote
        } else {
          result += chars.close-inner-quote
        }
      }
    } else if (
      char == straight-single or char == left-single or char == right-single
    ) {
      // Could be apostrophe or quote - context-dependent
      // For now, pass through
      result += char
    } else {
      result += char
    }
  }

  result
}
