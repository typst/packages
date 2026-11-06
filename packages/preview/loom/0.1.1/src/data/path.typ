/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/data/path.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Manages the component hierarchy path stored in the system context.
 * The path is a stack of `(kind, relative-id)` tuples that uniquely identifies
 * the current location in the component tree.
 * ----------------------------------------------------------------------------
 */

#import "../core/context.typ": get-system-field, set-system-fields
#import "../lib/assert.typ": assert-types


/// Retrieves the current path array from the context.
///
/// -> array<(str, int)>
#let get(
  /// -> dictionary
  ctx,
) = get-system-field(ctx, "path", default: ())

/// Pushes a new segment onto the path.
///
/// This creates a new context for a child component. It uses the `relative-id`
/// currently stored in the system context (which is set by the Engine loop)
/// to ensure sibling uniqueness.
///
/// -> dictionary
#let append(
  /// -> dictionary
  ctx,
  /// The kind of the new path segment (e.g., "row").
  /// -> str
  kind,
) = {
  let sys = ctx.at("sys", default: (:))
  let current-path = sys.at("path", default: ())
  let current-id = sys.at("relative-id", default: 0)

  // Append the new tuple (kind, unique-index)
  sys.path = current-path + ((kind, current-id),)

  return ctx + (sys: sys)
}

/// Serializes the path into a unique string identifier.
///
/// Useful for generating HTML IDs, database keys, or debug logs.
///
/// # Example
/// `root(0)>section(0)>div(1)`
///
/// -> str
#let to-string(
  /// -> dictionary
  ctx,
  /// Separator between segments.
  /// -> str
  separator: ">",
) = {
  get(ctx).map(((k, i)) => k + "(" + str(i) + ")").join(separator)
}

/// Checks if the current path contains a specific component kind.
///
/// Useful for validation guards (e.g., "This component must be inside a 'row'").
///
/// -> bool
#let contains(
  /// -> dictionary
  ctx,
  /// One or more kinds to check for.
  /// -> ..str
  ..kind,
  /// If true, checks the entire path including the current tip.
  /// If false, checks only the ancestors (parents).
  /// -> bool
  include-current: true,
) = {
  let path = get(ctx)

  // If we only care about ancestors, temporarily remove the last element
  if not include-current { let _ = path.pop() }

  // Extract just the "kind" strings from the tuples
  path = path.map(((kind, _)) => kind)

  // Check intersection
  kind.pos().any(k => k in path)
}

/// Retrieves the full tuple `(kind, id)` of the immediate parent.
///
/// -> (str, int) | none
#let parent(
  /// -> dictionary
  ctx,
) = {
  let path = get(ctx)
  // We need at least 2 elements: [grandparent, parent, current] -> parent is -2
  path.at(-2, default: (none, none))
}

/// Retrieves just the "kind" string of the immediate parent.
///
/// -> str | none
#let parent-kind(
  /// -> dictionary
  ctx,
) = parent(ctx).at(0)

/// Checks if the immediate parent matches one of the provided kinds.
///
/// -> bool
#let parent-is(
  /// -> dictionary
  ctx,
  /// -> ..str
  ..kinds,
) = {
  let p-kind = parent-kind(ctx)
  p-kind in kinds.pos()
}

/// Returns the nesting depth (length of the path).
///
/// -> int
#let depth(
  /// -> dictionary
  ctx,
) = get(ctx).len()

/// Retrieves the full tuple `(kind, id)` of the current component (the tip of the path).
///
/// -> (str, int) | none
#let current(
  /// -> dictionary
  ctx,
) = get(ctx).last(default: none)

/// Retrieves just the "kind" string of the current component.
///
/// -> str | none
#let current-kind(
  /// -> dictionary
  ctx,
) = {
  let current = current(ctx)
  if current != none { current.at(0) } else { none }
}
