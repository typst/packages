/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/matcher.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-07
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Provides validation functions to enforce architectural constraints.
 * Used by components to assert their position in the hierarchy or the
 * presence of specific context data.
 * ----------------------------------------------------------------------------
 */

// Unique signature to identify matcher objects to avoid collisions with user data.
#let _SIG_KEY = "__loom_matcher_sig__"
#let _SIG_VAL = "loom-matcher-v1-7600d448"


// --- 1. DESCRIPTORS (Helpers) ---

/// Matches ANYTHING (Wildcard).
/// Use this instead of `auto` if you want to explicitly allow any value.
///
/// # Example
/// ```typ
/// // Matches both "foo" and `auto`
/// matcher.match(auto, matcher.any())
/// ```
///
/// -> dictionary
#let any() = (
  (_SIG_KEY): _SIG_VAL,
  type: "matcher-any",
)

/// Matches if *any* of the provided options match (Logic OR).
///
/// # Example
/// ```typ
/// // Matches integers OR strings
/// matcher.choice(int, str)
/// ```
///
/// -> dictionary
#let choice(
  /// The list of allowed patterns.
  /// -> ..any
  ..options,
) = (
  (_SIG_KEY): _SIG_VAL,
  type: "matcher-choice",
  options: options.pos(),
)

/// Matches an array of *any length* where every item matches the schema.
/// This is used to describe a list of uniform items.
///
/// # Example
/// ```typ
/// // Matches (1, 2, 3) but not (1, "a")
/// matcher.many(int)
/// ```
///
/// -> dictionary
#let many(
  /// The pattern that every item in the array must match.
  /// -> any
  schema,
) = (
  (_SIG_KEY): _SIG_VAL,
  type: "matcher-many",
  schema: schema,
)

/// Matches a dictionary of *any size* where every value matches the schema.
/// This is used to describe a homogeneous map (e.g., config settings).
///
/// # Example
/// ```typ
/// // Matches (a: 1, b: 2) but not (a: 1, b: "x")
/// matcher.dict(int)
/// ```
///
/// -> dictionary
#let dict(
  /// The pattern that every value in the dictionary must match.
  /// -> any
  schema,
) = (
  (_SIG_KEY): _SIG_VAL,
  type: "matcher-dict",
  schema: schema,
)

/// Matches a value exactly (Strict Equality).
///
/// Use this to match a specific value (like a Type object) without triggering
/// the engine's type-checking logic.
///
/// # Example
/// ```typ
/// // Matches the type `int` itself, not the number 1.
/// matcher.exact(int)
/// ```
///
/// -> dictionary
#let exact(
  /// The value to match exactly.
  /// -> any
  value,
) = (
  (_SIG_KEY): _SIG_VAL,
  type: "matcher-exact",
  value: value,
)

/// Matches if the value is an instance of the given type.
///
/// Use this to explicitly enforce a type check, even when `match_types: true`
/// is active (which would normally switch types to equality checking).
///
/// # Example
/// ```typ
/// matcher.instance(int) // Matches 1, 2, 3...
/// ```
///
/// -> dictionary
#let instance(
  /// The expected type.
  /// -> type
  target,
) = (
  (_SIG_KEY): _SIG_VAL,
  type: "matcher-instance",
  target: target,
)

// --- 2. ENGINE ---

/// Checks if a value matches a schema pattern.
///
/// # Patterns
/// - **Literal:** `1`, `"foo"`, `auto`. Matches exact equality.
/// - **Type:** `int`, `str`. Matches `type(value)`.
/// - **Tuple:** `(int, int)`. Matches array of exact length and sequence.
/// - **Record:** `(name: str)`. Matches dictionary with specific keys.
/// - **Descriptor:** `matcher.many(int)`. Uses helper logic.
///
/// # Example
/// ```typ
/// matcher.match((a: 1), (a: int)) // -> true
/// ```
///
/// -> bool
#let match(
  /// The value to check.
  /// -> any
  value,
  /// The schema or pattern to match against.
  /// -> any
  expected,
  /// If `true`, fails if the value has extra dictionary keys not in the schema.
  /// -> bool
  strict: false,
) = {
  // A. Check Descriptors (By Description)
  // We explicitly check for our unique signature before treating it as logic
  if (
    type(expected) == dictionary
      and expected.at(_SIG_KEY, default: none) == _SIG_VAL
  ) {
    // Wildcard
    if expected.type == "matcher-any" {
      return true
    }

    if expected.type == "matcher-exact" {
      return value == expected.value
    }
    if expected.type == "matcher-instance" {
      return type(value) == expected.target
    }

    if expected.type == "matcher-choice" {
      return expected.options.any(opt => match(value, opt, strict: strict))
    }
    if expected.type == "matcher-many" {
      if type(value) != array { return false }
      return value.all(item => match(item, expected.schema, strict: strict))
    }
    if expected.type == "matcher-dict" {
      if type(value) != dictionary { return false }
      return value
        .values()
        .all(val => match(val, expected.schema, strict: strict))
    }
  }

  // B. Check Syntax (By Example)

  // 1. Type
  if type(expected) == type {
    return (
      type(value) == expected or (type(value) == type and value == expected)
    )
  }

  // 2. Tuple (Array)
  if type(expected) == array {
    if type(value) != array { return false }
    if value.len() != expected.len() { return false }
    for i in range(expected.len()) {
      if not match(value.at(i), expected.at(i), strict: strict) { return false }
    }
    return true
  }

  // 3. Record (Dictionary)
  if type(expected) == dictionary {
    if type(value) != dictionary { return false }
    for (k, v) in expected {
      if not (k in value) { return false }
      if not match(value.at(k), v, strict: strict) { return false }
    }
    if strict {
      for k in value.keys() { if not (k in expected) { return false } }
    }
    return true
  }

  // 4. Literal (Includes `auto`, `none`, strings, numbers)
  return value == expected
}


// --- 3. SWITCH (Classifier) ---

/// Defines a single case within a switch block.
///
/// -> dictionary
#let case(
  /// The pattern to match against.
  /// -> any
  pattern,
  /// The value to return if the pattern matches.
  /// -> any
  output,
  /// Whether to enforce strict matching for this specific case.
  /// -> bool
  strict: false,
) = ((pattern: pattern, output: output, strict: strict),)

/// Evaluates a value against a list of cases and returns the output of the first match.
///
/// # Example
/// ```typ
/// let type = matcher.switch(signal, (
///   case((cost: int), "task"),
///   case((text: str), "note"),
///   case(matcher.any(), "unknown")
/// ))
/// ```
///
/// -> any | none
#let switch(
  /// The value to evaluate.
  /// -> any
  target,
  /// A list of cases created with `matcher.case()`.
  /// -> array
  cases,
) = {
  if type(cases) != array { panic("Switch expects an array of cases.") }
  for c in cases {
    if match(target, c.pattern, strict: c.strict) { return c.output }
  }
  return none
}
