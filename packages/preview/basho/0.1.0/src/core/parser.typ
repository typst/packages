// src/parser.typ
// String → token array conversion
//
// Token schema:
//   (type: "char", text: <single character>)
//   (type: "newline", text: "\n")
//   (type: "tcy", text: <Latin/number run>)

/// Tests whether a character cluster is an ASCII Latin letter, digit, or comma.
///
/// - ch (str): A single character cluster.
/// - config (dictionary): The layout configuration.
/// -> bool
#let is-tcy-char(ch, config) = {
  ch.match(config.tcy.first().pattern) != none
}

/// Splits an input string into an array of tokens.
/// - Newline characters → type "newline"
/// - Consecutive ASCII Latin/digit/comma runs → type "tcy"
/// - Everything else → type "char" (one per cluster)
///
/// - input (str): The string to tokenize.
/// - config (dictionary): The layout configuration.
/// -> array: Array of token dictionaries.
#let tokenize(input, config) = {
  if input == "" {
    return ()
  }

  let tokens = ()
  let tcy-buf = ""

  for ch in input.clusters() {
    if ch == "\n" {
      // Flush any pending TCY buffer
      if tcy-buf != "" {
        tokens.push((type: "tcy", text: tcy-buf))
        tcy-buf = ""
      }
      tokens.push((type: "newline", text: "\n"))
    } else if is-tcy-char(ch, config) {
      // Accumulate Latin/digit run
      tcy-buf += ch
    } else {
      // Flush any pending TCY buffer
      if tcy-buf != "" {
        tokens.push((type: "tcy", text: tcy-buf))
        tcy-buf = ""
      }
      tokens.push((type: "char", text: ch))
    }
  }

  // Flush trailing TCY buffer
  if tcy-buf != "" {
    tokens.push((type: "tcy", text: tcy-buf))
  }

  tokens
}
