// src/parser.typ
// String → token array conversion

#import "../pipeline/token.typ": token

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
      if tcy-buf != "" {
        tokens.push(token("tcy", fields: (text: tcy-buf)))
        tcy-buf = ""
      }
      tokens.push(token("newline", fields: (text: "\n")))
    } else if is-tcy-char(ch, config) {
      tcy-buf += ch
    } else {
      if tcy-buf != "" {
        tokens.push(token("tcy", fields: (text: tcy-buf)))
        tcy-buf = ""
      }
      tokens.push(token("char", fields: (text: ch)))
    }
  }

  if tcy-buf != "" {
    tokens.push(token("tcy", fields: (text: tcy-buf)))
  }

  tokens
}
