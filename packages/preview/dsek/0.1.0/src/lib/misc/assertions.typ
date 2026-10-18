/// Shared helpers for consistent, informative validation panics.

#let origin(fn) = if fn != none { fn + ": " } else { "" }
#let make-hint(hint) = if hint != none { "\n  hint: " + hint } else { "" }

/// Panic if `value` is `none` or the empty array `()`.
///
/// - value (any): The value to check.
/// - key (str): The parameter name, shown in backticks in the message.
/// - fn (str, none): The calling function's name, prepended as context.
/// - hint (str, none): Optional example or explanation appended after a newline.
#let required(value, key, fn: none, hint: none) = {
  let message = origin(fn) + "missing required argument `" + key + "`" + make-hint(hint)
  assert(value != none and value != (), message: message)
}

/// Panic if `dict` is missing any of the given `keys`.
///
/// - dict (dictionary): The dictionary to check.
/// - keys (array): The key names (strings) that must be present.
/// - fn (str): The calling function's name, prepended as context.
/// - hint (str): Optional example or explanation appended after a newline.
/// - allowed (array): Array of allowed keys. If set to `auto`, all no check is performed.
#let required-keys(dict, keys, fn: none, hint: none, allowed: auto) = {
  let missing = keys.filter(k => not dict.keys().contains(k))

  let label = if missing.len() == 1 { "key" } else { "keys" }
  let listed = missing.map(k => "`" + k + "`").join(", ")

  let message = origin(fn) + "missing required " + label + " " + listed + make-hint(hint)

  assert(missing == (), message: message)

  let incorrect = if allowed == auto { () } else {
    dict.keys().filter(k => k not in allowed)
  }

  let label = if incorrect.len() == 1 { "key" } else { "keys" }
  let listed = incorrect.map(k => "`" + k + "`").join(", ")

  let message = origin(fn) + "incorrect " + label + " " + listed + make-hint(hint)
  assert(incorrect == (), message: message)
}
