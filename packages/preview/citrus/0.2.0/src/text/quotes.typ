// citrus - Quote Handling Module
//
// Implements CSL quote flipflopping:
// - Alternates between outer and inner quotes for nested quotations
// - Handles locale-specific quote marks

#import "../parsing/mod.typ": get-quote-chars

// Module-level regex patterns (avoid recompilation in hot loops)
#let _re-letter = regex("[a-zA-Z\u{00C0}-\u{024F}]")
#let _re-quote-opener = regex("[ \t\n(\\[]")
#let _re-digit = regex("[0-9]")
#let _re-single-quote-pair = regex(
  "(^|[\\s\\(\\[])[\u{2018}\u{2019}']([^'\u{2018}\u{2019}]+)[\u{2018}\u{2019}']",
)
#let _re-double-quote-chars = regex("[\"\u{201C}\u{201D}]")

// =============================================================================
// Quote Functions
// =============================================================================

/// Apply quotes to text content
///
/// - text: The text to quote
/// - ctx: Context with locale info
/// - level: Nesting level (0 = outer quotes, 1 = inner quotes, etc.)
/// Returns: Quoted text

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

/// Transform quotes in text to use proper marks for the given nesting level
///
/// CSL spec (following citeproc-js behavior):
/// - Opening quotes are detected by having a preceding space or opening bracket
/// - Single quotes NOT preceded by space/bracket are treated as apostrophes
/// - Apostrophes between letters (don't, l'Égypte) are preserved
///
/// - text: Text with quotes
/// - ctx: Context with locale info
/// - level: Current quote nesting level (0 = outermost, 1 = inside outer quotes, etc.)
/// Returns: Text with quotes transformed for the given level
#let transform-quotes-at-level(text, ctx, level) = {
  if text == none or type(text) != str { return text }

  let lang = ctx.style.at("default-locale", default: "en")
  let chars = get-quote-chars(lang)

  // Unicode quote characters for detection
  let left-double = "\u{201C}" // "
  let right-double = "\u{201D}" // "
  let straight-double = "\""
  let left-single = "\u{2018}" // '
  let right-single = "\u{2019}" // ' (also apostrophe!)
  let straight-single = "'"

  // Determine target quotes based on level mod 2
  // Level 0: outer quotes (double), Level 1: inner quotes (single), etc.
  let use-inner = calc.rem(level, 2) == 1
  let target-open = if use-inner { chars.open-inner-quote } else {
    chars.open-quote
  }
  let target-close = if use-inner { chars.close-inner-quote } else {
    chars.close-quote
  }

  let clusters = text.clusters()
  let result = ""
  let letter-pattern = _re-letter
  // Characters that can precede an opening quote (citeproc-js style)
  let quote-opener-pattern = _re-quote-opener

  for (i, char) in clusters.enumerate() {
    // Check previous and next characters
    let prev = if i > 0 { clusters.at(i - 1) } else { "" }
    let next = if i < clusters.len() - 1 { clusters.at(i + 1) } else { "" }
    let prev-is-letter = prev.match(letter-pattern) != none
    let next-is-letter = next.match(letter-pattern) != none
    // citeproc-js: opening quote must be preceded by space, bracket, or be at start
    let can-be-opening = i == 0 or prev.match(quote-opener-pattern) != none

    if char == left-double or char == straight-double {
      // Double quote: always transform (double quotes are unambiguous)
      if can-be-opening {
        result += target-open
      } else {
        result += target-close
      }
    } else if char == right-double {
      // Closing double quote
      result += target-close
    } else if char == left-single {
      // Unicode left single quote - intended as opening quote
      if can-be-opening {
        if use-inner {
          result += chars.open-inner-quote
        } else {
          result += chars.open-quote
        }
      } else {
        // Not at valid opening position - treat as apostrophe
        result += right-single
      }
    } else if char == straight-single {
      // Straight single quote - most ambiguous case
      // citeproc-js rule: only an opening quote if preceded by space/bracket
      // AND followed by a letter (not a digit - '09 is apostrophe)
      let next-is-digit = next.match(_re-digit) != none
      if prev-is-letter and next-is-letter {
        // Between letters: apostrophe (don't, l'Égypte)
        result += right-single
      } else if can-be-opening and not prev-is-letter and next-is-letter {
        // At valid opening position AND followed by letter: opening quote
        // e.g., 'friend' -> "friend"
        if use-inner {
          result += chars.open-inner-quote
        } else {
          result += chars.open-quote
        }
      } else if prev-is-letter and not next-is-letter {
        // After letter, not before letter: closing quote
        // e.g., friend' -> friend"
        // But treat trailing s' as possessive apostrophe (his', James')
        if prev == "s" {
          result += right-single
        } else if use-inner {
          result += chars.close-inner-quote
        } else {
          result += chars.close-quote
        }
      } else {
        // Other cases:
        // - '09 (space before, digit after) -> apostrophe (year contraction)
        // - 'n' (space before, letter after, but short) -> depends on context
        // Default: keep as apostrophe for safety
        result += right-single
      }
    } else if char == right-single {
      // Unicode right single quote
      if prev-is-letter and next-is-letter {
        // Between letters: apostrophe
        result += right-single
      } else {
        // Closing quote position
        if use-inner {
          result += chars.close-inner-quote
        } else {
          result += chars.close-quote
        }
      }
    } else {
      result += char
    }
  }

  if not use-inner {
    result = result.replace(
      _re-single-quote-pair,
      m => (
        m.captures.at(0) + target-open + m.captures.at(1) + target-close
      ),
    )
  }

  result
}

#let _is-plain-text(content) = {
  if content == none or content == [] { return true }
  if type(content) == str { return true }
  let func = content.func()
  let fields = content.fields()
  if func == text {
    let body = fields.at("body", default: fields.at("text", default: ""))
    return _is-plain-text(body)
  }
  if "children" in fields {
    return fields.children.all(_is-plain-text)
  }
  false
}

#let _content-to-string(content) = {
  if content == none or content == [] { return "" }
  if type(content) == str { return content }
  let func = content.func()
  let fields = content.fields()
  if func == text {
    let body = fields.at("body", default: fields.at("text", default: ""))
    return _content-to-string(body)
  }
  if "children" in fields {
    return fields.children.map(_content-to-string).join("")
  }
  if "body" in fields { return _content-to-string(fields.body) }
  if "text" in fields { return _content-to-string(fields.text) }
  ""
}

/// Apply quotes to text content
///
/// - text: The text to quote
/// - ctx: Context with locale info
/// - level: Nesting level (0 = outer quotes, 1 = inner quotes, etc.)
/// Returns: Quoted text
#let apply-quotes(content, ctx, level: 0) = {
  if content == none or content == "" or content == [] { return content }

  let lang = ctx.style.at("default-locale", default: "en")
  let chars = get-quote-chars(lang)

  // Alternate between outer and inner quotes based on level
  let is-inner = calc.rem(level, 2) == 1
  let has-inner = if type(content) == str {
    content.match(_re-double-quote-chars) != none
  } else {
    _content-to-string(content).match(_re-double-quote-chars) != none
  }
  if is-inner and not has-inner { is-inner = false }

  let open = if is-inner { chars.open-inner-quote } else { chars.open-quote }
  let close = if is-inner { chars.close-inner-quote } else { chars.close-quote }

  if type(content) == str {
    let normalized = transform-quotes-at-level(content, ctx, 1)
    normalized = normalized
      .replace(chars.open-quote, chars.open-inner-quote)
      .replace(chars.close-quote, chars.close-inner-quote)
    open + normalized + close
  } else {
    if content.func() == text {
      let fields = content.fields()
      let body = fields.at("text", default: fields.at("body", default: none))
      if type(body) == str {
        let normalized = transform-quotes-at-level(body, ctx, 1)
        normalized = normalized
          .replace(chars.open-quote, chars.open-inner-quote)
          .replace(chars.close-quote, chars.close-inner-quote)
        return text(open + normalized + close)
      }
    }
    if _is-plain-text(content) {
      let normalized = transform-quotes-at-level(
        _content-to-string(content),
        ctx,
        1,
      )
      normalized = normalized
        .replace(chars.open-quote, chars.open-inner-quote)
        .replace(chars.close-quote, chars.close-inner-quote)
      return text(open + normalized + close)
    }
    [#open#content#close]
  }
}
