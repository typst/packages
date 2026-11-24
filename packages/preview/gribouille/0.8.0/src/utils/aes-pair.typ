/// Helpers encoding the "exclusive default" rule for geoms that paint both a stroke `colour` and a body `fill`.
///
/// Rule: if the user has set either aesthetic (via `aes()` mapping or as a fixed layer parameter), the *other* aesthetic must not receive its default value. Defaults apply only when neither has been set. Whether an aesthetic was set to a positive value by the user, either as a pinned parameter or as a column mapping.
///
/// "Set" excludes both the `auto` sentinel (fallback marker) and the `none` sentinel (explicit disable) for pins, plus the absence of a column for mappings. A `none` pin is *not* counted here so the exclusive-default rule does not suppress the opposite aesthetic's default: disabling fill should leave the stroke default intact, not also strip it.
///
/// - layer: The layer dictionary providing `params`.
/// - mapping: The resolved aesthetic mapping handed to a geom's `draw`.
/// - name: Aesthetic name to query (e.g., `"colour"`, `"fill"`).
///
/// Returns: A boolean indicating whether the user supplied this aesthetic.

/// Whether an aesthetic was set to a positive value by the user, either as a pinned parameter or as a column mapping.
///
/// "Set" excludes both the `auto` sentinel (fallback marker) and the `none`
/// sentinel (explicit disable) for pins, plus the absence of a column for
/// mappings. A `none` pin is *not* counted here so the exclusive-default rule
/// does not suppress the opposite aesthetic's default: disabling fill should
/// leave the stroke default intact, not also strip it.
///
/// \@internal
/// \@param layer The layer dictionary providing `params`.
///
/// \@param mapping The resolved aesthetic mapping handed to a geom's `draw`.
///
/// \@param name Aesthetic name to query (e.g., `"colour"`, `"fill"`).
/// \@returns A boolean indicating whether the user supplied this aesthetic.
#let aes-set(layer, mapping, name) = {
  let pin = layer.params.at(name, default: auto)
  let pinned = pin != auto and pin != none
  let mapped = mapping != none and mapping.at(name, default: none) != none
  pinned or mapped
}

/// Compute the pair of defaults to feed into `resolve-stroke-colour` and `resolve-fill-colour` for a dual-aesthetic geom.
///
/// Returns `(colour-default, fill-default)`:
///
/// - both originals when neither or both aesthetics are set, so geoms keep their historical look when the user touches nothing or supplies both;
/// - `(default-colour, none)` when only `colour` is set, suppressing the fill default so the geom does not inject an unwanted body fill;
/// - `(none, default-fill)` when only `fill` is set, suppressing the stroke default so the outline does not appear unsolicited.
///
/// Pass the returned `colour-default` / `fill-default` straight into the existing resolver functions, which already treat a `none` default as "skip the default" (with `apply-alpha` short-circuiting on `none`).
///
/// - layer: The layer dictionary providing `params`.
/// - mapping: The resolved aesthetic mapping handed to a geom's `draw`.
/// - default-colour: The geom's stroke default when no aesthetic is set.
/// - default-fill: The geom's fill default when no aesthetic is set.
///
/// Returns: A `(colour-default, fill-default)` 2-tuple.
#let resolve-pair-defaults(layer, mapping, default-colour, default-fill) = {
  let c-set = aes-set(layer, mapping, "colour")
  let f-set = aes-set(layer, mapping, "fill")
  if c-set and not f-set { return (default-colour, none) }
  if f-set and not c-set { return (none, default-fill) }
  (default-colour, default-fill)
}
