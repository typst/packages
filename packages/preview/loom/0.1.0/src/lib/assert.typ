/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/assert.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Provides utility functions for strict type checking and runtime assertions.
 * Used primarily to validate arguments in Loom's internal API.
 * ----------------------------------------------------------------------------
 */

/// Asserts that a value matches one of the provided types or specific values.
///
/// If the assertion fails, it constructs a detailed error message listing the
/// expected types/values and the actual type/value received.
///
/// # Example
/// ```typ
/// assert-types(10, int, float) // Passes
/// assert-types("hello", int)   // Fails: Expected `int`, got `string` ("hello")
/// assert-types(none, int, none) // Passes (checks for value `none`)
/// ```
///
/// -> none
#let assert-types(
  /// The value to check
  /// -> any
  value,
  /// A variable list of allowed types (e.g., `int`, `str`) or specific allowed values (e.g., `none`, `auto`).
  /// -> ..type | any
  ..types,
) = assert(
  type(value) in types.pos() or value in types.pos(),
  message: (
    "Expected value of type ",
    types
      .pos()
      .filter(typ => type(typ) in (int, float, str, bool, type))
      .map(typ => {
        if type(typ) in (int, float, str, type) { "`" + str(typ) + "`" }
        if type(typ) == bool { if typ { "`true`" } else { "`false`" } }
      })
      .join(", ", last: " or "),
    " but got `",
    str(type(value)),
    "`",
    // Append the actual value for primitive types to aid debugging
    if (type(value) in (int, float, str)) { ("(" + str(value) + ")") },
    if (type(value) == bool) { if value { "(true)" } else { "(false)" } },
  ).join(),
)
