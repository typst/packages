/// Create a token dictionary with the given type and optional fields.
///
/// - type (str): The token type (e.g. "char", "tcy", "newline").
/// - fields (dictionary): Optional key-value pairs to merge into the token.
/// -> dictionary: A token dictionary with at least a `type` field.
#let token(type, fields: (:)) = {
  let result = (type: type)
  for (k, v) in fields {
    result.insert(k, v)
  }
  result
}

/// Merge additional fields into a token, returning a new token (non-mutating).
/// Works as a safe wrapper around dictionary merge.
///
/// - t (dictionary): The base token.
/// - fields (dictionary): Fields to merge in.
/// -> dictionary: A new token with all fields from t plus fields.
#let merge-token(t, fields) = {
  t + fields
}

/// Check whether a token has a given type.
///
/// - t (dictionary): The token to check.
/// - expected (str): The expected type string.
/// -> bool
#let is-token-type(t, expected) = {
  t.type == expected
}
