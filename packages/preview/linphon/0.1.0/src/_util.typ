#let _delim-matches = (
  "[": "]",
  "]": "[",
  "{": "}",
  "}": "{",
  "<": ">",
  ">": "<",
  "(": ")",
  ")": "(",
  "|": "|",
  "/": "/",
)

#let _delim-replacements = (
  "<": "\u{27e8}",
  ">": "\u{27e9}",
)

/// Parse a `delim`-argument into a uniform form
/// 
/// Takes a delim argument as either a string or an array and returns it as a
/// uniform dictionary with a `left` and `right` field.
/// 
/// Examples:
///   ```typc parse-delim("[")``` -> ```typc (left: "[", right: "]")```
///   ```typc parse-delim("]")``` -> ```typc (left: "]", right: "[")```
///   ```typc parse-delim("{|")``` -> ```typc (left: "{", right: "|")```
///   ```typc parse-delim(("{", "|"))``` -> ```typc (left: "{", right: "|")```
///   ```typc parse-delim(none)``` -> ```typc (left: none, right: none)```
///   ```typc parse-delim((none, ">"))``` -> ```typc (left: none, right: ">")```
/// 
/// -> dict
#let parse-delim(delim) = {
  let parsed = (left: none, right: none)
  if type(delim) == str and delim.len() == 1 {
    // single character delim spec
    parsed.left = delim
    if delim in _delim-matches {
      parsed.right = _delim-matches.at(delim)
    } else {
      parsed.right = delim
    }
  } else if type(delim) == str {
    // two character delim spec (chr 2+ is ignored)
    (parsed.left, parsed.righ) = (delim.at(0), delim.at(1))
  } else if type(delim) == array and delim.len() > 1 {
    // 2-array delim spec (indices 2+ are ignored)
    (parsed.left, parsed.right) = (delim.at(0), delim.at(1))
  } else {
    panic("Invalid delim spec `" + repr(delim) + "` - incorrect form or type.")
  }
  // ensure specified delims exist
  assert(
    parsed.left == none or parsed.left in _delim-matches,
    message: "Unknown left delim `" + repr(parsed.left) + "`."
  )
  assert(
    parsed.right == none or parsed.right in _delim-matches,
    message: "Unknown right delim `" + repr(parsed.right) + "`."
  )
  if parsed.left != none and parsed.left in _delim-replacements {
    parsed.left = _delim-replacements.at(parsed.left)
  }
  if parsed.right != none and parsed.right in _delim-replacements {
    parsed.right = _delim-replacements.at(parsed.right)
  }
  parsed
}
