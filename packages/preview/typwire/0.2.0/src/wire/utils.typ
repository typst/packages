/// Convert a ratio (0% - 100%) to an integer (0 - 255).
///
/// -> int
#let ratio-to-int(
  /// A ratio value between 0% and 100%.
  ///
  /// -> ratio
  ratio,
) = {
  int(255 * calc.clamp(ratio / 100%, 0, 1))
}

/// Convert a ratio to a float.
///
/// -> float
#let ratio-to-float(
  /// A ratio of any value.
  ///
  /// -> ratio
  ratio,
) = {
  ratio / 100%
}

/// Convert a float to a ratio.
///
/// -> ratio
#let float-to-ratio(
  /// A float value.
  ///
  /// -> float
  float,
) = {
  float * 100%
}

/// Convert a float to a length.
///
/// -> length
#let float-to-length(
  /// A float value.
  ///
  /// -> float
  float,
) = {
  float * 1pt
}

/// Whether every type in `types` is one of `allowed`. Meant for a small,
/// already-deduplicated list (`values.map(std.type).dedup()`) -- see
/// `encode.typ::encode` for why this is checked natively per container
/// rather than with a closure per element.
///
/// -> bool
#let all-in(
  /// The types to check.
  ///
  /// -> array
  types,
  /// The types allowed.
  ///
  /// -> array
  allowed,
) = {
  for t in types {
    if t not in allowed {
      return false
    }
  }
  true
}

/// Whether debug assertions are enabled.
///
/// -> bool
#let is-debug-assert = sys.inputs.at("debug-assert", default: false) == "true"

// Matches one escape sequence: a backslash followed by either `u{HEX}`
// (captured) or any single character (the dedicated escapes `n`/`t`/`r`/
// `"`/`\`, dispatched on in `unescape-repr-content` below).
//
// This has to be *one* pattern applied in a *single* `.replace()` pass, not
// several independent `.replace()` calls one after another: with several
// passes, an escaped backslash immediately followed by a literal `n`/`t`/
// `r`/`"` (e.g. the string `\d\n`, four characters -- backslash, d,
// backslash, n -- repr'd as `\\d\\n`) gets corrupted, because the second
// pass's `\n` search matches across the boundary the first pass already
// consumed (turning the trailing literal `n` into an actual newline
// instead of leaving it alone). A single combined pattern can't do that,
// since each match consumes the characters it covers and matching resumes
// only after it -- confirmed by reproducing the corruption with the naive
// multi-pass version and then verifying this one against it, empirically,
// since path text can never contain a backslash but regex patterns are
// full of them.
#let escape-pattern = regex("\\\\(?:u\\{([0-9a-fA-F]+)\\}|.)")

/// Reverse `repr`'s escaping for the inner content of a quoted string
/// literal (the text between the quotes, not including them).
///
/// Handles every escape `repr` actually emits for a string (confirmed
/// empirically, since it isn't fully spelled out in the docs): `\"`, `\\`,
/// `\n`, `\t`, `\r`, and `\u{...}` (arbitrary codepoint, variable-width hex,
/// used for any other non-printable character). Pure string manipulation --
/// deliberately not `eval`, which would execute the content as Typst code.
///
/// -> str
#let unescape-repr-content(
  /// The text between a pair of `repr`-produced quotes.
  ///
  /// -> str
  content,
) = {
  content.replace(escape-pattern, m => {
    let hex = m.captures.at(0)
    if hex != none {
      str.from-unicode(int(hex, base: 16))
    } else if m.text == "\\n" {
      "\n"
    } else if m.text == "\\t" {
      "\t"
    } else if m.text == "\\r" {
      "\r"
    } else if m.text == "\\\"" {
      "\""
    } else if m.text == "\\\\" {
      "\\"
    } else {
      // Not one of `repr`'s own escapes -- leave it untouched rather than
      // guess.
      m.text
    }
  })
}

/// Reverse `repr`'s escaping for a full quoted string literal, e.g.
/// `repr("a\"b")`, quotes included.
///
/// -> str
#let unescape-repr-string(
  /// A `repr`-produced quoted string literal.
  ///
  /// -> str
  quoted,
) = unescape-repr-content(quoted.slice(1, -1))
