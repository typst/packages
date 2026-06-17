/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/guards.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
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

#import "assert.typ": assert-types
#import "../data/path.typ"
#import "../core/context.typ": get-system-field


#let _fail(ctx, msg) = {
  // In test mode, we return false instead of panicking to verify failure paths.
  if get-system-field(ctx, "test", default: false) {
    return false
  }
  panic(msg)
}

#let _error-msg(ctx, relation, targets) = {
  let current = path.current(ctx)
  let me = if current != none { current.at(0) } else { "Unknown" }
  let target-list = targets.map(t => "`" + t + "`").join(", ", last: " or ")

  "Component `" + me + "` " + relation + " " + target-list + "."
}


// --- PUBLIC API ---

/// Asserts that the component is currently nested within one of the specified ancestors.
///
/// Use this to enforce hierarchy rules, e.g., "A 'task' must be inside a 'project'".
///
/// -> bool
#let assert-inside(
  /// The current context.
  /// -> dictionary
  ctx,
  /// Allowed ancestor kinds.
  /// -> ..str
  ..ancestors,
) = {
  assert-types(ctx, dictionary)
  let kinds = ancestors.pos()
  kinds.map(k => assert-types(k, str))

  // We exclude the current element from the check (I am not inside myself)
  if not path.contains(ctx, ..kinds, include-current: false) {
    return _fail(ctx, _error-msg(ctx, "must be nested within", kinds))
  }
  return true
}

/// Asserts that the component is NOT nested within any of the specified ancestors.
///
/// Use this to prevent invalid recursion or nesting, e.g., "A 'page' cannot be inside a 'footer'".
///
/// -> bool
#let assert-not-inside(
  /// -> dictionary
  ctx,
  /// Forbidden ancestor kinds.
  /// -> ..str
  ..ancestors,
) = {
  assert-types(ctx, dictionary)
  let kinds = ancestors.pos()
  kinds.map(k => assert-types(k, str))

  if path.contains(ctx, ..kinds, include-current: false) {
    return _fail(ctx, _error-msg(ctx, "must NOT be nested within", kinds))
  }
  return true
}

/// Asserts that the immediate parent matches one of the specified kinds.
///
/// This is stricter than `assert-inside`.
///
/// -> bool
#let assert-direct-parent(
  /// -> dictionary
  ctx,
  /// Allowed parent kinds.
  /// -> ..str
  ..parents,
) = {
  assert-types(ctx, dictionary)
  let kinds = parents.pos()
  kinds.map(k => assert-types(k, str))

  let parent = path.parent-kind(ctx)

  if parent not in kinds {
    return _fail(ctx, _error-msg(
      ctx,
      "requires a direct parent of kind",
      kinds,
    ))
  }
  return true
}

/// Asserts that the component is at the root of the Loom tree.
///
/// Useful for top-level managers that should not be nested inside other Loom components.
///
/// -> bool
#let assert-root(
  /// -> dictionary
  ctx,
) = {
  assert-types(ctx, dictionary)
  if path.parent(ctx) != none {
    return _fail(ctx, "Component must be at the root level.")
  }
  return true
}

/// Asserts that the current nesting depth is within a specific limit.
///
/// Useful for preventing stack overflows in recursive structures.
///
/// -> bool
#let assert-max-depth(
  /// -> dictionary
  ctx,
  /// -> int
  max,
) = {
  assert-types(ctx, dictionary)
  assert-types(max, int)

  let depth = path.depth(ctx)
  if depth > max {
    return _fail(
      ctx,
      "Maximum nesting depth of "
        + str(max)
        + " exceeded (Current: "
        + str(depth)
        + ").",
    )
  }
  return true
}

/// Asserts that a specific key exists in the context.
///
/// -> bool
#let assert-has-key(
  /// -> dictionary
  ctx,
  /// The required key.
  /// -> str
  key,
  /// Optional custom error message.
  /// -> str | none
  msg: none,
) = {
  if key not in ctx {
    let m = if msg == none {
      "Missing required context key: `" + key + "`"
    } else { msg }
    return _fail(ctx, m)
  }
  return true
}

/// Asserts that a context key has a specific value (or one of a set of values).
///
/// Useful for enforcing enum-like states (e.g., `assert-value(ctx, "status", "active", "pending")`).
///
/// -> bool
#let assert-value(
  /// -> dictionary
  ctx,
  /// The key to check.
  /// -> str
  key,
  /// The allowed values.
  /// -> ..any
  ..allowed,
) = {
  assert-has-key(ctx, key)
  let val = ctx.at(key)
  let options = allowed.pos()

  if val not in options {
    return _fail(
      ctx,
      "Context key `"
        + key
        + "` has invalid value `"
        + repr(val)
        + "`. Expected one of: "
        + options.map(repr).join(", "),
    )
  }
  return true
}
