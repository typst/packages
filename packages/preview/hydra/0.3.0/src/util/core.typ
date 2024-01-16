#import "@preview/oxifmt:0.2.0": strfmt as fmt

/// Substitute `value` for the return value of `default()` if it is a sentinel value.
///
/// - value (any): The value to check.
/// - default (function): The function to produce the default value with.
/// - check (any): The sentinel value to check for.
/// -> any
#let or-default(value, default, check: none) = if value == check { default() } else { value }
