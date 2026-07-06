/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/query.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Provides traversal and aggregation utilities for the component data tree.
 * Used in `measure` functions to extract, filter, and summarize data from children.
 * ----------------------------------------------------------------------------
 */

#import "assert.typ": assert-types
#import "collection.typ"
#import "../data/frame.typ": is-frame


/// Filters a list of children frames by kind.
///
/// This is a shallow operation; it only checks the immediate list provided.
///
/// -> array<frame>
#let select(
  /// The list of frames to search.
  /// -> array<frame>
  children,
  /// The component kind to match (e.g., "task").
  /// -> str
  kind,
) = {
  if children == none { return () }
  children.filter(c => c != none and c.at("kind", default: none) == kind)
}

/// Shorthand for `select` that returns the signals directly.
///
/// -> array
#let select-signals(
  /// -> array<frame>
  children,
  /// -> str
  kind,
) = {
  select(children, kind)
    .map(c => c.at("signal", default: none))
    .filter(s => s != none)
}

/// Filters children using a custom predicate function.
///
/// # Example
/// ```typ
/// where(children, c => c.signal.cost > 100)
/// ```
///
/// -> array<frame>
#let where(
  /// -> array<frame>
  children,
  /// Function `frame => bool`.
  /// -> function
  predicate,
) = {
  if children == none { return () }
  children.filter(c => c != none and predicate(c))
}

/// Shorthand for `where` that returns the signals directly.
///
/// -> array
#let where-signals(
  /// -> array<frame>
  children,
  /// -> function
  predicate,
) = {
  where(children, predicate)
    .map(c => c.at("signal", default: none))
    .filter(s => s != none)
}

/// Finds the first child of a specific kind.
///
/// -> frame | none
#let find(
  /// -> array<frame>
  children,
  /// -> str
  kind,
  /// Value to return if not found.
  /// -> any
  default: none,
) = {
  select(children, kind).first(default: default)
}

/// Shorthand for `find` that returns the signal directly.
///
/// -> any
#let find-signal(
  /// -> array<frame>
  children,
  /// -> str
  kind,
  /// -> any
  default: none,
) = {
  let frame = find(children, kind)
  if frame == none { return default }
  frame.at("signal", default: default)
}

/// Recursively collects all descendants of a specific kind (or all if kind is none).
///
/// Traverses the tree by inspecting the `signal` of each node to find children.
/// It supports three patterns for children in signals:
/// 1. **Wrapper:** The signal is a single frame.
/// 2. **List:** The signal is an array of frames.
/// 3. **Container:** The signal is a dictionary with a "children" key.
///
/// Note: Non-frame data found in signals (strings, numbers, etc.) is ignored during traversal.
///
/// -> array<frame>
#let collect(
  /// The root list of frames.
  /// -> array<frame>
  children,
  /// The kind to filter by. If `none`, returns all nodes.
  /// -> str | none
  kind: none,
  /// Maximum recursion depth.
  /// -> int
  depth: 10,
) = {
  assert-types(depth, int)
  if depth <= 0 or children == none { return () }

  let result = ()

  for node in children.filter(is-frame) {
    if kind in (none, node.kind) { result.push(node) }

    let signal = node.signal
    let next-nodes = ()

    if is-frame(signal) { next-nodes.push(signal) } else if (
      type(signal) == array
    ) { next-nodes += signal.filter(is-frame) } else if (
      type(signal) == dictionary
    ) {
      if "children" in signal {
        let children = signal.children

        if is-frame(children) { next-nodes.push(children) }
        if type(children) == array { next-nodes += children.filter(is-frame) }
      }
    }

    if next-nodes.len() > 0 {
      result += collect(next-nodes, kind: kind, depth: depth - 1)
    }
  }

  return result
}

/// Shorthand for `collect` that returns the signals directly.
///
/// -> array
#let collect-signals(
  /// -> array<frame>
  children,
  /// -> str | none
  kind: none,
  /// -> int
  depth: 10,
) = {
  collect(children, kind: kind, depth: depth)
    .map(c => c.at("signal", default: none))
    .filter(s => s != none)
}

/// Extracts a specific field from the signals of all children.
///
/// Useful for creating lists of values (e.g., all prices, all names).
///
/// -> array
#let pluck(
  /// -> array<frame>
  children,
  /// The key to look for in `child.signal`.
  /// -> str
  key,
  /// -> any
  default: none,
) = {
  if children == none { return () }
  children
    .filter(c => c != none)
    .map(c => c.at("signal", default: (:)).at(key, default: default))
}

/// Sums up a specific numeric field from the signals of all children.
///
/// A shortcut for `pluck(..).sum()`.
///
/// -> int | float
#let sum-signals(
  /// -> array<frame>
  children,
  /// The key containing the number in `child.signal`.
  /// -> str
  key,
  /// -> int | float
  default: 0,
) = {
  pluck(children, key, default: default).sum(default: default)
}

/// Groups children by a specific value in their signal.
///
/// Returns a dictionary where keys are the values found in the signal field `key`.
///
/// # Example
/// Grouping ingredients by category:
/// `group-by(ingredients, "category")` -> `("fruit": (..), "veg": (..))`
///
/// -> dictionary<str, array<frame>>
#let group-by(
  /// -> array<frame>
  children,
  /// The signal key to group by.
  /// -> str
  key,
) = {
  let groups = (:)
  for child in children {
    if child == none { continue }
    let signal = child.at("signal", default: (:))

    // We convert the grouping key to string to ensure it can be a dict key
    let group-key = str(signal.at(key, default: "other"))

    let current = groups.at(group-key, default: ())
    current.push(child)
    groups.insert(group-key, current)
  }
  groups
}

/// Shorthand for `group-by` that returns arrays of signals instead of frames.
///
/// -> dictionary<str, array>
#let group-signals(
  /// -> array<frame>
  children,
  /// -> str
  key,
) = {
  let groups = group-by(children, key)
  let new-groups = (:)
  for (k, v) in groups {
    new-groups.insert(
      k,
      v.map(c => c.at("signal", default: none)).filter(s => s != none),
    )
  }
  new-groups
}

/// Aggregates data from a list of children using a reducer function.
///
/// Operates directly on the `signal` of the children.
///
/// -> any
#let fold(
  /// The list of frames.
  /// -> array<frame>
  children,
  /// Reducer `(accumulator, signal) => new_accumulator`.
  /// -> function
  fn,
  /// Initial value.
  /// -> any
  base,
) = {
  if children == none { return base }
  children
    .filter(c => c != none)
    .map(c => c.at("signal", default: (:)))
    .fold(base, fn)
}
