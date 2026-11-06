/// Internal implementation for `custom-enum-numbering`
#let _custom_enum_numbering(patterns, cycle, default, ..nums) = {
  context assert(
    enum.full,
    message: "custom-enum-numbering must be used with enum.full",
  )

  assert(nums.pos().len() > 0)
  let depth = nums.pos().len() - 1
  let value = nums.pos().last()

  // Determine correct pattern for given depth
  let pattern = if cycle {
    patterns.at(calc.rem(depth, patterns.len()))
  } else {
    patterns.at(depth, default: default)
  }

  numbering(pattern, value)
}

/// A helper to set a custom enum numbering based on the list depth
///
/// You must set `enum(full: true)` for it to work.
///
/// *Example*
/// ```typst
/// #set enum(
///   full: true,
///   numbering: custom-enum-numbering("a)", "1.")
/// )
/// ```
///
/// The numbering for depth levels that are not specified is decided as follows:
/// - If `cycle` is true then the given patterns get applied cyclically.
/// - Otherwise, the `default` argument is applied for all unspecified levels.
/// - If `default` is set to #auto, the last specified pattern is chosen.
///
/// -> numbering
#let custom-enum-numbering(
  /// Whether to cycle through the patterns for unspecified depth levels. -> bool
  cycle: false,
  /// The default argument for unspecified depth levels.
  ///
  /// If set to #auto, the last specified pattern is chosen.
  ///
  /// -> auto | str
  default: auto,
  /// The string patterns for the numbering in order of their according depth level. -> arguments
  ..patterns,
) = {
  // Handle arguments
  assert(patterns.named().len() == 0, message: "Invalid named argument")
  let patterns = patterns.pos()
  assert(type(patterns) == array)
  assert(patterns.len() > 0, message: "No patterns provided")
  assert(patterns.all(p => type(p) == str), message: "Pattern must be a string")
  assert(type(cycle) == bool)
  if default == auto { default = patterns.last() }
  assert(type(default) == str)

  _custom_enum_numbering.with(patterns, cycle, default)
}
