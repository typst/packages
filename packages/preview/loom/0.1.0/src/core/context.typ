/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/core/context.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Defines the Context structure, which holds the state propagated down the
 * component tree. Includes utilities for scoping variables and managing
 * system fields.
 * ----------------------------------------------------------------------------
 */

#import "../lib/assert.typ": assert-types
#import "../lib/collection.typ"


/// The base context used at the root of the Loom execution.
///
/// Contains the necessary `sys` structure to prevent initialization errors.
/// -> dictionary
#let empty-context = (
  sys: (
    path: (),
    debug: false,
    relative-id: 0,
  ),
)

/// Updates the context with new variables, respecting existing values if `auto` is passed.
///
/// This function is the core of Loom's "scope injection" mechanism. It allows
/// components to provide default values that can be overridden by parents.
///
/// Arguments must be passed as named arguments where the value is either:
/// 1. A tuple `(value, default_fallback)`
/// 2. A dictionary `(value: ..., default: ...)`
///
/// Logic:
/// - If `value` is not `auto`, it overwrites the context (Authoritative set).
/// - If `value` IS `auto` and the key exists in context, it keeps the existing value (Inheritance).
/// - If `value` IS `auto` and the key is missing, it uses `fallback` (Defaulting).
///
/// -> dictionary
#let scope(
  /// The current context.
  /// -> dictionary
  ctx,
  /// Named arguments representing the variables to inject.
  /// -> ..(array | dictionary)
  ..args,
) = {
  let updates = (:)

  for (key, value-container) in args.named() {
    assert-types(value-container, array, dictionary)

    let (value, fallback) = if type(value-container) == dictionary {
      (value-container.value, value-container.default)
    } else { value-container }

    if value != auto { updates.insert(key, value) } else if (
      key in ctx and ctx.at(key) != auto
    ) {} else { updates.insert(key, fallback) }
  }

  let updated-keys = updates.keys()

  return ctx + updates
}

/// Retrieves a value from the reserved `sys` namespace in the context.
///
/// -> any
#let get-system-field(
  /// -> dictionary
  ctx,
  /// -> str
  field,
  /// -> any
  default: none,
) = collection.get(ctx, "sys", field, default: default)

/// Updates values in the reserved `sys` namespace.
///
/// Used by the Engine to track state (path, recursion depth, pass) without
/// polluting the user's variable scope.
///
/// -> dictionary
#let set-system-fields(
  /// -> dictionary
  ctx,
  /// -> ..any
  ..args,
) = collection.merge-deep(ctx, (sys: args.named()))
