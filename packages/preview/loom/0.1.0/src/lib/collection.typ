/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/collection.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Provides functional utilities for manipulating data collections (dictionaries
 * and arrays). Includes safe navigation (get), deep merging, and filtering.
 * ----------------------------------------------------------------------------
 */

/// Safely retrieves a value from a nested structure of dictionaries and arrays.
///
/// Walks through the `root` using the provided `path`. If any key or index
/// does not exist, or if an intermediate value is `none`, it returns the
/// `default` value instead of panicking.
///
/// - root (dictionary | array):
/// - default (any):
///
/// # Example
/// ```typ
/// let data = (a: (b: (10, 20)))
/// get(data, "a", "b", 1) // -> 20
/// get(data, "a", "x", default: 0) // -> 0
/// ```
///
/// -> any
#let get(
  /// The data structure to traverse.
  /// -> dictionary | array
  root,
  /// A sequence of keys (for dicts) or indices (for arrays).
  /// ..(str | int)
  ..path,
  /// Required type by the final outcome.
  /// -> type
  req-type: none,
  /// The value to return if the path is invalid or the result is `none`.
  /// -> any
  default: none,
) = {
  let current = root
  let path-args = path.pos()

  if current == none { return default }

  for key in path-args {
    if type(current) == dictionary and type(key) == str {
      current = current.at(key, default: none)
    } else if type(current) == array and type(key) == int {
      current = current.at(key, default: none)
    } else {
      return default
    }

    if current == none { return default }
  }

  if req-type != none and type(current) != req-type { return default }

  return current
}

/// Applies a function to a value only if the value is not `none`.
/// This serves as a functional replacement for `.map()`.
///
/// # Example
/// ```typ
/// let val = get(data, "count") // might be none
/// map(val, x => x * 2) // returns none if val was none, else result
/// ```
///
/// -> any
#let map(
  /// The value to transform.
  /// -> any
  value,
  /// The transformation function.
  /// -> function
  fn,
  /// Type expected by the function.
  /// -> type
  req-type: none,
) = {
  if value == none { return none }
  if req-type != none and type(value) != req-type { return none }
  return fn(value)
}

/// Recursively merges two dictionaries.
/// Unlike the standard `+` operator, this preserves nested keys in `base`
/// instead of overwriting the whole inner dictionary.
///
/// # Example
/// ```typ
/// let defaults = (font: (size: 10pt, family: "Arial"))
/// let user = (font: (size: 12pt))
/// merge-deep(defaults, user) // -> (font: (size: 12pt, family: "Arial"))
/// ```
///
/// The merged result.
/// -> dictionary
#let merge-deep(
  /// The original dictionary (e.g., default config).
  /// -> dictionary
  base,
  /// The dictionary with updates (e.g., user config).
  /// -> dictionary
  override,
) = {
  if type(base) != dictionary or type(override) != dictionary {
    return override
  }

  let result = base
  for (k, v) in override {
    if k in base {
      result.insert(k, merge-deep(base.at(k), v))
    } else {
      result.insert(k, v)
    }
  }

  result
}

/// Creates a new dictionary with specific keys removed.
///
/// # Example
/// ```typ
/// let d = (a: 1, b: 2, c: 3)
/// omit(d, "a", "c") // -> (b: 2)
/// ```
///
/// -> dictionary
#let omit(
  /// The source dictionary.
  /// -> dictionary
  dict,
  /// The keys to exclude
  /// -> ..str
  ..keys,
) = {
  let to-remove = keys.pos()
  let result = dict

  for k in to-remove {
    let _ = result.remove(k, default: none)
  }

  result
}

/// Creates a new dictionary with ONLY the specified keys.
/// Keys that do not exist in the source are ignored.
///
/// -> dictionary
#let pick(
  /// The source dictionary
  /// -> dictionary
  dict,
  /// The keys to keep
  /// -> ..str
  ..keys,
) = {
  let to-keep = keys.pos()
  let result = (:)

  for k in to-keep {
    if k in dict {
      result.insert(k, dict.at(k))
    }
  }

  result
}

/// Removes all entries with value `none` from an array or dictionary.
/// Useful for cleaning up lists built with conditionals.
///
/// # Example
/// ```typ
/// compact((1, none, 2)) // -> (1, 2)
/// compact((a: 1, b: none)) // -> (a: 1)
/// ```
///
/// -> array | dictionary
#let compact(
  /// The collection to clean.
  /// -> array | dictionary
  collection,
) = {
  if type(collection) == array {
    collection.filter(it => it != none)
  } else if type(collection) == dictionary {
    let result = (:)
    for (k, v) in collection {
      if v != none { result.insert(k, v) }
    }
    result
  } else {
    collection
  }
}
