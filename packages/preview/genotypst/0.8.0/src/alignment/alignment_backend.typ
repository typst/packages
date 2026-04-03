#let _alignment-backend = plugin("alignment.wasm")

// Cache available matrices at module load time (loaded once)
#let _available-matrices = json(_alignment-backend.list_matrices()).matrices

/// Resolves a scoring matrix name to its canonical form.
///
/// Performs case-insensitive lookup against available matrices from the WASM plugin.
/// Returns the canonical matrix name (e.g., "BLOSUM62") if found, or none if not found.
///
/// - name (str): Matrix name to look up (case-insensitive).
/// -> str, none
#let resolve-matrix-name(name) = {
  let upper-name = upper(name)
  if upper-name in _available-matrices {
    upper-name
  } else {
    none
  }
}

/// Private: Converts WASM i32 infinity representations to Typst floats.
///
/// The WASM plugin uses i32::MIN (-2147483648) for negative infinity
/// and i32::MAX (2147483647) for positive infinity. This function
/// converts these sentinel values to Typst's float.inf representation.
///
/// - value (int): The value to convert.
/// -> int, float
#let _convert-infinity(value) = {
  if value == -2147483648 { -float.inf } else if value == 2147483647 {
    float.inf
  } else { value }
}

/// Private: Executes pairwise alignment through the WASM backend.
///
/// - seq-1 (str): First cleaned sequence.
/// - seq-2 (str): Second cleaned sequence.
/// - config (dictionary): Backend request payload.
/// -> dictionary
#let _alignment-align(seq-1, seq-2, config) = {
  let config-json = json.encode(config)
  let result = _alignment-backend.align(
    bytes(seq-1),
    bytes(seq-2),
    bytes(config-json),
  )
  json(result)
}

/// Private: Retrieves scoring matrix information through the WASM backend.
///
/// Converts backend infinity sentinels before returning the parsed payload.
///
/// - name (str): Canonical matrix name.
/// -> dictionary
#let _alignment-matrix-info(name) = {
  let result = json(_alignment-backend.matrix_info(bytes(name)))
  result.insert("scores", result.scores.map(_convert-infinity))
  result
}
