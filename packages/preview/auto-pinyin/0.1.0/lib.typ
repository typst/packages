// Load the WASM plugin for pinyin conversion
#let _plugin = plugin("auto-pinyin.wasm")

// ============================================
// Version Information
// ============================================

/// Get version information about auto-pinyin and its dependencies.
///
/// Returns: string - version information including auto-pinyin version
///   and rust-pinyin commit id.
///
/// Example:
///   #version()  // → "auto-pinyin: 0.1.0\nrust-pinyin commit: abc123..."
#let version() = {
  str(_plugin.version())
}

// ============================================
// Internal Helper Functions
// ============================================

/// Extract text from string or content
/// Returns: string or none if extraction fails
#let _extract-text(input) = {
  if type(input) == str {
    input
  } else if type(input) == content and "text" in input.fields() {
    input.text
  } else {
    none
  }
}

/// Convert a single character to pinyin using WASM plugin
/// Internal function - assumes input is validated
#let _char-to-pinyin(char, style: "tone-num") = {
  if style == "tone-num" {
    str(_plugin.char_to_pinyin(bytes(char)))
  } else if style == "tone-num-end" {
    str(_plugin.char_to_pinyin_tone_num_end(bytes(char)))
  } else if style == "tone" {
    str(_plugin.char_to_pinyin_tone(bytes(char)))
  } else if style == "plain" {
    str(_plugin.char_to_pinyin_plain(bytes(char)))
  } else if style == "first-letter" {
    str(_plugin.char_to_pinyin_first_letter(bytes(char)))
  } else {
    panic(
      "Invalid style: '"
        + style
        + "'. Valid options: tone-num, tone-num-end, tone, plain, first-letter",
    )
  }
}

/// Convert a single character to multiple pinyin readings using WASM plugin
/// Internal function - assumes input is validated
#let _char-to-pinyin-multi(char, style: "tone-num") = {
  let result-str = if style == "tone-num" {
    str(_plugin.char_to_pinyin_multi(bytes(char)))
  } else if style == "tone-num-end" {
    str(_plugin.char_to_pinyin_multi_tone_num_end(bytes(char)))
  } else if style == "tone" {
    str(_plugin.char_to_pinyin_multi_tone(bytes(char)))
  } else if style == "plain" {
    str(_plugin.char_to_pinyin_multi_plain(bytes(char)))
  } else if style == "first-letter" {
    str(_plugin.char_to_pinyin_multi_first_letter(bytes(char)))
  } else {
    panic(
      "Invalid style: '"
        + style
        + "'. Valid options: tone-num, tone-num-end, tone, plain, first-letter",
    )
  }

  result-str.split("|")
}

// ============================================
// Public API Functions
// ============================================

/// Convert Chinese characters to an array of pinyin strings.
///
/// This function converts each Chinese character in the input to its pinyin
/// representation. Non-Chinese characters are preserved as-is in the array.
///
/// Parameters:
/// - chars: string or content - Chinese characters to convert
/// - style: string (default: "tone-num") - pinyin output style
///   - "tone-num": tone number after vowel (e.g., "ha4n")
///   - "tone-num-end": tone number at end (e.g., "han4")
///   - "tone": with tone marks (e.g., "hàn")
///   - "plain": without tone (e.g., "han")
///   - "first-letter": first letter only (e.g., "h")
/// - override: dictionary (default: (:)) - character/phrase to pinyin mapping
///   - Keys can be single characters or multi-character phrases
///   - Values: single-char key can be `str` or `array`, multi-char key must be `array`
///   - Array values: each element corresponds to one character's pinyin
///   - Uses greedy matching: longer phrases are matched first
///   - Useful for polyphonic characters (多音字) or fixed phrases
///
/// Returns: array of strings - one pinyin string per character or phrase
///
/// Examples:
///   #to-pinyin("汉语")                              // → ("ha4n", "yu3")
///   #to-pinyin("汉语", style: "plain")              // → ("han", "yu")
///   #to-pinyin("Hello世界")                         // → ("H", "e", "l", "l", "o", "shi4", "jie4")
///   #to-pinyin("重庆", override: (重: "cho2ng"))    // → ("cho2ng", "qi4ng")
///
///   // User can join the array as needed:
///   #to-pinyin("汉语").join("")                     // → "ha4nyu3"
///   #to-pinyin("汉语").join(" ")                    // → "ha4n yu3"
#let to-pinyin(chars, style: "tone-num", override: (:)) = {
  // Extract text from input
  let s = _extract-text(chars)
  if s == none {
    panic("to-pinyin: input must be a string or content with text field")
  }

  // If no override, convert character by character
  if override == (:) {
    return s.clusters().map(c => _char-to-pinyin(c, style: style))
  }

  // With override: process with greedy matching
  // Sort override keys by length (longest first) for greedy matching
  let override-keys-sorted = override
    .keys()
    .sorted(key: k => k.clusters().len())
    .rev()

  // Helper: Try to match a phrase in override starting at position i
  // Returns (matched-text, pinyin, length) or none
  let try-match-override = (clusters, start-i) => {
    for key in override-keys-sorted {
      let key-clusters = key.clusters()
      let key-len = key-clusters.len()

      // Check if remaining text is long enough
      if start-i + key-len > clusters.len() {
        continue
      }

      // Check if text matches
      let matches = true
      for j in range(key-len) {
        if clusters.at(start-i + j) != key-clusters.at(j) {
          matches = false
          break
        }
      }

      if matches {
        let value = override.at(key)
        // Validate override value: single-char can be str|array, multi-char must be array
        let pinyin-array = if type(value) == str {
          if key-len > 1 {
            panic(
              "Multi-character override key '"
                + key
                + "' must have array value, got string: '"
                + value
                + "'",
            )
          }
          (value,)
        } else if type(value) == array {
          if value.len() != key-len {
            panic(
              "Override value array length ("
                + str(value.len())
                + ") doesn't match key length ("
                + str(key-len)
                + ") for '"
                + key
                + "'",
            )
          }
          value
        } else {
          panic(
            "Override value must be string or array, got " + str(type(value)),
          )
        }
        return (key, pinyin-array, key-len)
      }
    }
    return none
  }

  // Process character by character with override support
  let clusters = s.clusters()
  let result = ()
  let i = 0

  while i < clusters.len() {
    // Try to match a phrase override first (greedy: longest match wins)
    let match-result = try-match-override(clusters, i)

    if match-result != none {
      let (matched-text, pinyin-array, len) = match-result
      // Add each pinyin from the override array
      for pinyin in pinyin-array {
        result.push(pinyin)
      }
      i += len
    } else {
      // No override match, use auto-generated pinyin
      let c = clusters.at(i)
      result.push(_char-to-pinyin(c, style: style))
      i += 1
    }
  }

  result
}

/// Get all possible pinyin readings for a Chinese character (heteronym).
///
/// For heteronyms (多音字), this function returns all possible pinyin
/// readings as an array. For non-Chinese characters, returns a single-element
/// array containing the character itself.
///
/// When given a multi-character string, returns an array of arrays,
/// where each element is the array of readings for that character.
///
/// Parameters:
/// - char: string or content - Chinese character(s) to process
/// - style: string (default: "tone-num") - pinyin output style
///   - "tone-num": tone number after vowel (e.g., "ha2i")
///   - "tone-num-end": tone number at end (e.g., "hai2")
///   - "tone": with tone marks (e.g., "hái")
///   - "plain": without tone (e.g., "hai")
///   - "first-letter": first letter only (e.g., "h")
///
/// Returns:
///   - Single character: array of strings - all possible pinyin readings
///   - Multiple characters: array of arrays - readings per character
///
/// Examples:
///   #to-pinyin-multi("还")                      // → ("ha2i", "hua2n", "fu2")
///   #to-pinyin-multi("还", style: "plain")      // → ("hai", "huan", "fu")
///   #to-pinyin-multi("还", style: "tone")       // → ("hái", "huán", "fú")
///
///   // User can join readings as needed:
///   #to-pinyin-multi("还").join("|")            // → "ha2i|hua2n|fu2"
///   #to-pinyin-multi("还").first()              // → "ha2i" (most common reading)
///
///   // Multiple characters:
///   #to-pinyin-multi("还没")                    // → (("ha2i", "hua2n", "fu2"), ("me2i", "mo4", "me"))
#let to-pinyin-multi(char, style: "tone-num") = {
  // Extract text from input
  let s = _extract-text(char)
  if s == none {
    panic("to-pinyin-multi: input must be a string or content with text field")
  }

  let clusters = s.clusters()

  // Handle single character
  if clusters.len() == 1 {
    return _char-to-pinyin-multi(clusters.at(0), style: style)
  }

  // For multiple characters, return array of arrays
  clusters.map(c => _char-to-pinyin-multi(c, style: style))
}
