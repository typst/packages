// citrus - CSL Formatting Functions
//
// Apply CSL formatting attributes to content.

#import "utils.typ": capitalize-first-char, is-empty, strip-periods-from-str

// Superscript folding map (from CSL test suite SuperscriptFolding list)
// Converts Unicode superscripts to base glyphs for <sup> rendering.
#let _superscript-folding = (
  "ª": "a",
  "²": "2",
  "³": "3",
  "¹": "1",
  "º": "o",
  "ʰ": "h",
  "ʱ": "ɦ",
  "ʲ": "j",
  "ʳ": "r",
  "ʴ": "ɹ",
  "ʵ": "ɻ",
  "ʶ": "ʁ",
  "ʷ": "w",
  "ʸ": "y",
  "ˠ": "ɣ",
  "ˡ": "l",
  "ˢ": "s",
  "ˣ": "x",
  "ˤ": "ʕ",
  "ᴬ": "A",
  "ᴭ": "Æ",
  "ᴮ": "B",
  "ᴰ": "D",
  "ᴱ": "E",
  "ᴲ": "Ǝ",
  "ᴳ": "G",
  "ᴴ": "H",
  "ᴵ": "I",
  "ᴶ": "J",
  "ᴷ": "K",
  "ᴸ": "L",
  "ᴹ": "M",
  "ᴺ": "N",
  "ᴼ": "O",
  "ᴽ": "Ȣ",
  "ᴾ": "P",
  "ᴿ": "R",
  "ᵀ": "T",
  "ᵁ": "U",
  "ᵂ": "W",
  "ᵃ": "a",
  "ᵄ": "ɐ",
  "ᵅ": "ɑ",
  "ᵆ": "ᴂ",
  "ᵇ": "b",
  "ᵈ": "d",
  "ᵉ": "e",
  "ᵊ": "ə",
  "ᵋ": "ɛ",
  "ᵌ": "ɜ",
  "ᵍ": "g",
  "ᵏ": "k",
  "ᵐ": "m",
  "ᵑ": "ŋ",
  "ᵒ": "o",
  "ᵓ": "ɔ",
  "ᵔ": "ᴖ",
  "ᵕ": "ᴗ",
  "ᵖ": "p",
  "ᵗ": "t",
  "ᵘ": "u",
  "ᵙ": "ᴝ",
  "ᵚ": "ɯ",
  "ᵛ": "v",
  "ᵜ": "ᴥ",
  "ᵝ": "β",
  "ᵞ": "γ",
  "ᵟ": "δ",
  "ᵠ": "φ",
  "ᵡ": "χ",
  "⁰": "0",
  "ⁱ": "i",
  "⁴": "4",
  "⁵": "5",
  "⁶": "6",
  "⁷": "7",
  "⁸": "8",
  "⁹": "9",
  "⁺": "+",
  "⁻": "−",
  "⁼": "=",
  "⁽": "(",
  "⁾": ")",
  "ⁿ": "n",
  "℠": "SM",
  "™": "TM",
  "㆒": "一",
  "㆓": "二",
  "㆔": "三",
  "㆕": "四",
  "㆖": "上",
  "㆗": "中",
  "㆘": "下",
  "㆙": "甲",
  "㆚": "乙",
  "㆛": "丙",
  "㆜": "丁",
  "㆝": "天",
  "㆞": "地",
  "㆟": "人",
  "ˀ": "ʔ",
  "ˁ": "ʕ",
  "ۥ": "و",
  "ۦ": "ي",
)

#let fold-superscripts(text) = {
  if type(text) != str { return text }
  let parts = ()
  let changed = false
  for ch in text.clusters() {
    let mapped = _superscript-folding.at(ch, default: none)
    if mapped != none {
      parts.push(super(mapped))
      changed = true
    } else {
      parts.push(ch)
    }
  }
  if changed { parts.join() } else { text }
}

// Minor words for title case (defined once, not per call)
// These are lowercased unless at start of title or after major punctuation
// Based on common title case style guides (Chicago, APA, etc.)
#let _minor-words = (
  // Articles
  "a",
  "an",
  "the",
  // Coordinating conjunctions
  "and",
  "but",
  "or",
  "for",
  "nor",
  "yet",
  "so",
  // Short prepositions (typically 4-5 letters or fewer in title case rules)
  "about",
  "as",
  "at",
  "by",
  "down",
  "for",
  "from",
  "in",
  "into",
  "of",
  "off",
  "on",
  "onto",
  "out",
  "over",
  "per",
  "till",
  "to",
  "under",
  "up",
  "via",
  "with",
  // Name particles (should stay lowercase)
  "von",
  "van",
  "de",
  "la",
  "le",
  "der",
  "den",
  "und", // German "and"
  // Common foreign minor words
  "y", // Spanish "and"
  "e", // Italian/Portuguese "and"
  "et", // Latin/French "and"
)

// Characters that start a new "sentence" in title case
// Word after these should be capitalized even if it's a minor word
#let _major-punctuation = (":", ";", "—", "–", "?", "!", ".")

// Module-level regex patterns (avoid recompilation)
#let _re-letter = regex("[a-zA-Z\u{00C0}-\u{024F}]")
#let _re-lower-letter = regex("[a-z\u{00E0}-\u{00FF}]")
#let _re-upper-letter = regex("[A-Z\u{00C0}-\u{00DF}]")
#let _re-greek-letter = regex("[A-Za-z\u{0370}-\u{03FF}]")

/// Check if a word is all uppercase (likely an acronym)
#let _is-all-uppercase(word) = {
  if word == "" { return false }
  // Filter out non-letter characters for the check
  let letters = word.clusters().filter(c => c.match(_re-letter) != none)
  if letters.len() == 0 { return false }
  letters.all(c => c == upper(c))
}

/// Check if a word starts with a lowercase letter (intentional, like "iPad")
#let _starts-with-lowercase(word) = {
  if word == "" { return false }
  let first = word.clusters().first()
  // Check if it's a letter and lowercase
  if first.match(_re-lower-letter) != none {
    return true
  }
  false
}

/// Capitalize a word for title case
/// - If word is all uppercase (acronym), preserve it
/// - If word starts with lowercase intentionally (iPad), preserve it
/// - Otherwise, capitalize first letter, preserve rest
/// - Skip leading non-letter characters (quotes, punctuation)
#let _capitalize-word(word) = {
  if word == "" { return "" }

  // Preserve all-uppercase words (acronyms like UK, A.N.)
  if _is-all-uppercase(word) {
    return word
  }

  // Preserve words that intentionally start with lowercase (like iPad)
  // But only if they have uppercase later (indicating intentional casing)
  if _starts-with-lowercase(word) {
    let clusters = word.clusters()
    let has-later-upper = clusters
      .slice(1)
      .any(c => c.match(_re-upper-letter) != none)
    if has-later-upper {
      return word
    }
  }

  let clusters = word.clusters()
  if clusters.len() == 0 { return word }

  // Find the first letter to capitalize (skip leading non-letters like quotes)
  let letter-pattern = _re-letter
  let prefix = ""
  let rest = clusters

  for (i, c) in clusters.enumerate() {
    if c.match(letter-pattern) != none {
      // Found first letter - capitalize it and return
      prefix = clusters.slice(0, i).join()
      let letter = clusters.at(i)
      let suffix = clusters.slice(i + 1).join()
      return prefix + upper(letter) + suffix
    }
  }

  // No letters found, return as-is
  word
}

/// Process a hyphenated compound word for title case
/// - parts: array of word parts split by hyphen
/// - capitalize-first: whether the first part should be capitalized
/// Returns: processed string joined by hyphens
#let _process-hyphenated(parts, capitalize-first) = {
  let processed = ()
  let first = true

  if (
    parts.len() > 0 and parts.first().match(_re-greek-letter) == none
  ) {
    return parts.join("-")
  }

  for part in parts {
    if part == "" {
      processed.push("")
      continue
    }

    let lower-part = lower(part)

    if first {
      // First part follows the capitalize-first rule
      if capitalize-first or lower-part not in _minor-words {
        processed.push(_capitalize-word(part))
      } else {
        // Minor word at non-capitalizing position: preserve original
        processed.push(part)
      }
      first = false
    } else {
      // Non-first parts: capitalize unless minor word
      if lower-part not in _minor-words {
        processed.push(_capitalize-word(part))
      } else {
        // Minor word: preserve original (don't force lowercase)
        processed.push(part)
      }
    }
  }

  processed.join("-")
}

/// Apply title case to a string
/// Rules:
/// 1. First word is always capitalized
/// 2. Last word is always capitalized (even if minor word)
/// 3. Words after major punctuation (: ; — – ? ! .) are capitalized
/// 4. Minor words (a, an, the, and, etc.) are lowercased unless rule 1, 2, or 3 applies
/// 5. Hyphenated compounds: capitalize each part unless it's a minor word
///    (e.g., "Self-Esteem" but "Out-of-Fashion")
/// 6. Em-dash and en-dash act as word separators - word after them is capitalized
#let _apply-title-case(s) = {
  if s == "" { return s }

  // First, split by em-dash and en-dash (these create new "sentences")
  // We need to process each segment separately
  let segments = ()
  let current = ""
  let chars = s.clusters()

  for c in chars {
    if c == "—" or c == "–" {
      if current != "" {
        segments.push(("text", current))
        current = ""
      }
      segments.push(("dash", c))
    } else {
      current += c
    }
  }
  if current != "" {
    segments.push(("text", current))
  }

  // First pass: collect all words to identify the last word
  let all-words = ()
  for (seg-type, seg-content) in segments {
    if seg-type == "text" {
      let normalized = seg-content.replace("\u{00A0}", " ")
      let words = normalized.split(" ").filter(w => w != "")
      all-words += words
    }
  }
  let last-word-lower = if all-words.len() > 0 {
    lower(all-words.last())
  } else { "" }

  // Process each text segment
  let result = ()
  let is-first-word-of-string = true // Only true for the very first word
  let words-processed = 0
  let total-words = all-words.len()

  for (seg-type, seg-content) in segments {
    if seg-type == "dash" {
      result.push(seg-content)
      continue
    }

    // This is a text segment - apply title case
    // Split by regular space and non-breaking space (U+00A0)
    // First replace non-breaking spaces with regular spaces for splitting
    let normalized = seg-content.replace("\u{00A0}", " ")
    let words = normalized.split(" ")
    let processed-words = ()
    // capitalize-next is true only for the very first word of the entire string
    let capitalize-next = is-first-word-of-string

    for word in words {
      if word == "" {
        processed-words.push("")
        continue
      }

      // Track word position
      words-processed += 1
      let is-last-word = words-processed == total-words

      // Check if this word contains hyphens or slashes (compound word)
      if "-" in word {
        let parts = word.split("-")
        // Last word of title should be capitalized even if minor
        let should-cap = (
          capitalize-next
            or is-last-word
            or lower(parts.first()) not in _minor-words
        )
        processed-words.push(_process-hyphenated(parts, should-cap))
      } else if "/" in word {
        // Slash-separated words: capitalize each part
        let parts = word.split("/")
        let processed-parts = parts
          .enumerate()
          .map(((i, part)) => {
            if part == "" { return "" }
            let lower-part = lower(part)
            // First part follows normal rules, others always capitalize (slash acts as separator)
            if i == 0 {
              if (
                capitalize-next
                  or is-last-word
                  or lower-part not in _minor-words
              ) {
                _capitalize-word(part)
              } else {
                part
              }
            } else {
              // After slash: always capitalize (like after colon)
              _capitalize-word(part)
            }
          })
        processed-words.push(processed-parts.join("/"))
      } else {
        // Regular word
        let lower-word = lower(word)

        // Capitalize if: first word, last word, after punctuation, or not a minor word
        if capitalize-next or is-last-word or lower-word not in _minor-words {
          processed-words.push(_capitalize-word(word))
        } else {
          // Minor word: preserve original (don't force lowercase)
          processed-words.push(word)
        }
      }

      // After processing first real word, no longer at start of string
      is-first-word-of-string = false

      // Check if this word ends with major punctuation (excluding dashes, handled above)
      capitalize-next = false
      let last-char = word.clusters().last()
      if last-char in (":", ";", "?", "!", ".") {
        capitalize-next = true
      }
    }

    result.push(processed-words.join(" "))
  }

  result.join("")
}

/// Apply text-case transformation only (for use before quotes are added)
/// This is separate from apply-formatting because text-case only works on strings,
/// and quotes convert strings to content.
///
/// CSL spec: text-case="title" only applies to English content.
/// For non-English entries, title case should preserve original casing.
///
/// - content: String content to transform
/// - attrs: CSL attributes including text-case
/// - ctx: Context (optional) - used to check entry language for title case
#let apply-text-case(content, attrs, ctx: none) = {
  if content == [] or content == "" { return content }
  if type(content) != str { return content }

  let text-case = attrs.at("text-case", default: none)
  if text-case == none { return content }

  let locale = ""
  if ctx != none {
    let fields = ctx.at("fields", default: (:))
    let entry-lang = fields.at("language", default: "")
    if entry-lang != "" {
      locale = entry-lang
    } else {
      locale = ctx.style.at("default-locale", default: "")
    }
  }
  let is-turkish = locale.starts-with("tr")

  let upper-locale = s => if not is-turkish {
    upper(s)
  } else {
    s
      .clusters()
      .map(c => (
        if c == "i" { "İ" } else if c == "ı" { "I" } else { upper(c) }
      ))
      .join()
  }
  let lower-locale = s => if not is-turkish {
    lower(s)
  } else {
    s
      .clusters()
      .map(c => (
        if c == "I" { "ı" } else if c == "İ" { "i" } else { lower(c) }
      ))
      .join()
  }

  // CSL spec: title case only applies to English
  // Check entry language if ctx is provided
  if text-case == "title" and ctx != none {
    let fields = ctx.at("fields", default: (:))
    let entry-lang = fields.at("language", default: "")
    // Title case only for English or when no language specified
    // CSL spec: if language starts with "en" it's English
    if entry-lang != "" and not entry-lang.starts-with("en") {
      // Non-English: don't apply title case
      return content
    }
    if entry-lang == "" {
      let style-locale = ctx.style.at("default-locale", default: "en-US")
      if not style-locale.starts-with("en") {
        // Non-English default locale: don't apply title case
        return content
      }
    }
  }

  let result = content
  if text-case == "lowercase" {
    result = lower-locale(result)
  } else if text-case == "uppercase" {
    result = upper-locale(result)
  } else if text-case == "capitalize-first" and result.len() > 0 {
    result = capitalize-first-char(result)
  } else if text-case == "capitalize-all" {
    result = result
      .split(" ")
      .map(w => if w.len() > 0 { capitalize-first-char(w) } else { w })
      .join(" ")
  } else if text-case == "title" {
    result = _apply-title-case(result)
  } else if text-case == "sentence" {
    let lowered = lower(result)
    if lowered.len() > 0 {
      let clusters = lowered.clusters()
      result = upper(clusters.first()) + clusters.slice(1).join()
    }
  }
  result
}

/// Apply CSL formatting attributes to content
/// Optimized: extract all attrs at once, avoid repeated dictionary lookups
#let apply-formatting(content, attrs) = {
  if content == [] or content == "" { return content }
  if attrs.len() == 0 { return content }

  let result = content

  // Extract all formatting attrs at once (single dict traversal)
  // NOTE: text-case is handled separately by apply-text-case() which has
  // access to ctx for language-specific behavior. Do NOT apply it here.
  let font-style = attrs.at("font-style", default: none)
  let font-weight = attrs.at("font-weight", default: none)
  let text-decoration = attrs.at("text-decoration", default: none)
  let font-variant = attrs.at("font-variant", default: none)
  let vertical-align = attrs.at("vertical-align", default: none)

  // Note: strip-periods is handled in finalize() BEFORE adding prefix/suffix
  // Do NOT strip periods here as it would remove periods from suffix like ". "

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

  // text-case: handle simple transformations here, but NOT title case
  // Title case requires ctx for language-aware behavior and is handled
  // separately by apply-text-case() where ctx is available.
  let text-case = attrs.at("text-case", default: none)
  if text-case != none and text-case != "title" and type(result) == str {
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
    } else if text-case == "sentence" {
      // Sentence case: lowercase everything, then capitalize first letter
      let lowered = lower(result)
      if lowered.len() > 0 {
        let clusters = lowered.clusters()
        result = upper(clusters.first()) + clusters.slice(1).join()
      }
    }
  }

  // CSL-M display attribute: "block" creates a new line
  let display = attrs.at("display", default: none)
  if display == "block" {
    result = [#linebreak()#result#linebreak()]
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
/// CSL spec: Affixes are OUTSIDE formatting (e.g., prefix+<i>content</i>+suffix)
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

  // CSL spec: collapse double punctuation at content/suffix boundary
  // If content ends with a period and suffix starts with a period, remove one
  // Use stripped content when strip-periods is enabled
  let content-ends-with-period = if type(processed) == str {
    processed.ends-with(".")
  } else if attrs.at("strip-periods", default: "false") == "true" {
    false
  } else {
    attrs.at("_ends-with-period", default: false)
  }

  let adjusted-suffix = if (
    suffix.len() > 0 and suffix.first() == "." and content-ends-with-period
  ) {
    suffix.slice(1) // Remove leading period from suffix
  } else {
    suffix
  }

  // Apply formatting to content FIRST (CSL spec: affixes are outside formatting)
  let formatted = apply-formatting(processed, attrs)

  // Combine prefix + formatted content + suffix
  if prefix == "" and adjusted-suffix == "" {
    formatted
  } else if type(formatted) == str {
    prefix + formatted + adjusted-suffix
  } else {
    [#prefix#formatted#adjusted-suffix]
  }
}
