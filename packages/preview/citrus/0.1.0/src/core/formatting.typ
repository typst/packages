// citrus - CSL Formatting Functions
//
// Apply CSL formatting attributes to content.

#import "utils.typ": capitalize-first-char, is-empty, strip-periods-from-str

// Minor words for title case (defined once, not per call)
#let _minor-words = (
  "a",
  "an",
  "the",
  "and",
  "but",
  "or",
  "for",
  "nor",
  "on",
  "at",
  "to",
  "from",
  "by",
  "of",
  "in",
)

/// Apply CSL formatting attributes to content
/// Optimized: extract all attrs at once, avoid repeated dictionary lookups
#let apply-formatting(content, attrs) = {
  if content == [] or content == "" { return content }
  if attrs.len() == 0 { return content }

  let result = content

  // Extract all formatting attrs at once (single dict traversal)
  let font-style = attrs.at("font-style", default: none)
  let font-weight = attrs.at("font-weight", default: none)
  let text-decoration = attrs.at("text-decoration", default: none)
  let font-variant = attrs.at("font-variant", default: none)
  let vertical-align = attrs.at("vertical-align", default: none)
  let text-case = attrs.at("text-case", default: none)
  let strip-periods = attrs.at("strip-periods", default: "false") == "true"

  // Strip periods if requested (CSL strip-periods="true")
  if strip-periods {
    result = strip-periods-from-str(result)
  }

  // Apply formatting in order
  if font-style == "italic" or font-style == "oblique" {
    result = emph(result)
  }

  if font-weight == "bold" {
    result = strong(result)
  } else if font-weight == "light" {
    result = text(weight: "light", result)
  }

  if text-decoration == "underline" {
    result = underline(result)
  }

  if font-variant == "small-caps" {
    result = smallcaps(result)
  }

  if vertical-align == "sup" {
    result = super(result)
  } else if vertical-align == "sub" {
    result = sub(result)
  }

  // text-case only works on strings
  if text-case != none and type(result) == str {
    if text-case == "lowercase" {
      result = lower(result)
    } else if text-case == "uppercase" {
      result = upper(result)
    } else if text-case == "capitalize-first" and result.len() > 0 {
      result = capitalize-first-char(result)
    } else if text-case == "capitalize-all" {
      result = result
        .split(" ")
        .map(w => if w.len() > 0 { capitalize-first-char(w) } else { w })
        .join(" ")
    } else if text-case == "title" {
      result = result
        .split(" ")
        .enumerate()
        .map(((i, w)) => {
          let lower-w = lower(w)
          if i == 0 or lower-w not in _minor-words {
            if w.len() > 0 { capitalize-first-char(w) } else { w }
          } else { lower-w }
        })
        .join(" ")
    }
  }

  // CSL-M display attribute: "block" creates a new line
  let display = attrs.at("display", default: none)
  if display == "block" {
    result = [#linebreak()#result]
  } else if display == "indent" {
    result = [#h(2em)#result]
  } else if display == "left-margin" {
    // Left margin display (used in some bibliography layouts)
    result = [#result]
  } else if display == "right-inline" {
    // Right inline (continuation after left-margin)
    result = [#result]
  }

  result
}

/// Wrap content with prefix/suffix and apply formatting
#let finalize(content, attrs) = {
  if is-empty(content) { return [] }

  // Strip periods before wrapping (CSL strip-periods="true")
  let processed = if attrs.at("strip-periods", default: "false") == "true" {
    strip-periods-from-str(content)
  } else {
    content
  }

  let prefix = attrs.at("prefix", default: "")
  let suffix = attrs.at("suffix", default: "")

  // Combine prefix + content + suffix without extra spacing
  // If content is a string, concatenate directly to avoid Typst inserting spaces
  let result = if type(processed) == str {
    prefix + processed + suffix
  } else {
    [#prefix#processed#suffix]
  }
  apply-formatting(result, attrs)
}
