/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/mutator.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann.
 * All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Provides a functional, immutable API for modifying Typst dictionaries.
 * Includes operations for batch processing (put, remove, update, nest, merge)
 * to handle state changes cleanly without side effects.
 * ----------------------------------------------------------------------------
 */

#import "collection.typ"

/// Applies a sequence of operations to a target dictionary.
///
/// This function acts as the transaction runner. It takes an initial dictionary
/// (`target`) and applies a list of functional operations (`ops`) to it sequentially.
///
/// # Example
/// ```typ
/// let data = (name: "Typst", version: 1)
/// let result = batch(data, {
///   put("version", 2)
///   put("status", "active")
/// })
/// ```
///
/// The resulting dictionary after all operations have been applied.
/// -> dictionary
#let batch(
  /// The initial dictionary to start with. If `none`, starts with an empty dictionary `(:)`
  /// -> dictionary
  target,
  /// An array of operation functions (e.g., created by `put`, `remove`, `nest`).
  /// -> array<function>
  ops,
) = {
  let state = (base: if target == none { (:) } else { target }, patch: (:))

  if ops == none { return state.base }

  let _read(s, key, default: none) = {
    if key in s.patch { s.patch.at(key) } else {
      s.base.at(key, default: default)
    }
  }

  for op in ops {
    state = op(state, _read.with(state))
  }

  return if state.patch.len() == 0 { state.base } else {
    state.base + state.patch
  }
}

/// Applies a set of operations to a nested dictionary under a specific key.
/// If the key does not exist or is not a dictionary, it initializes an empty dictionary first.
///
/// # Example
/// ```typ
/// nest("metadata", (
///   put("created_at", "2024"),
///   put("author", "Me")
/// ))
/// ```
///
/// -> operation
#let _nest-op(
  /// The key containing the nested dictionary.
  /// -> str
  key,
  /// A list of operations to apply to the nested dictionary.
  /// -> array<function>
  sub-ops,
) = (
  (state, read) => {
    let curr = read(key)
    let sub-target = if type(curr) == dictionary { curr } else { (:) }

    let new-sub-result = batch(sub-target, sub-ops)

    let new-patch = state.patch + ((key): new-sub-result)
    (base: state.base, patch: new-patch)
  }
)

#let _auto-nest(path, leaf-op) = {
  if path.len() == 0 { return leaf-op }

  let head = path.first()
  let tail = path.slice(1)

  (_nest-op(head, _auto-nest(tail, leaf-op)),)
}

#let nest(key, sub-ops) = (_nest-op(key, sub-ops),)

/// Creates an operation to set a value for a specific key.
/// Overwrites the value if the key already exists.
///
/// -> operation
#let put(
  /// Optional path of keys to traverse before setting the value.
  /// -> str
  ..path,
  /// The key to assign.
  /// -> str
  key,
  /// The value to assign to the key.
  /// -> any
  value,
) = _auto-nest(
  path.pos(),
  (
    (state, read) => {
      let new-path = state.patch + ((key): value)
      (base: state.base, patch: new-path)
    },
  ),
)

/// Creates an operation that sets a value only if the key does not currently exist.
/// Useful for setting default values without overwriting existing data.
///
/// -> operation
#let ensure(
  /// Optional path of keys to traverse before checking the key.
  /// -> str
  ..path,
  /// The key to check.
  /// -> str
  key,
  /// The value to set if the key is missing (or `none`).
  /// -> any
  default,
) = _auto-nest(
  path.pos(),
  (
    (state, read) => {
      let curr = read(key)
      if curr == none {
        let new-patch = state.patch + ((key): default)
        (base: state.base, patch: new-patch)
      } else {
        state
      }
    },
  ),
)

/// Creates an operation that sets a value, inheriting the previous one if `auto`.
///
/// - If `value` is `auto`: uses the current state value.
/// - If current state is missing: uses `default`.
/// - If `value` is set: uses that value.
///
/// -> operation
#let derive(
  /// Optional path of keys to traverse before updating.
  /// -> str
  ..path,
  /// The key to update.
  /// -> str
  key,
  /// The new value (or `auto`).
  /// -> any
  value,
  /// Fallback if `value` is `auto` and key is missing in state.
  /// -> any
  default: none,
) = _auto-nest(
  path.pos(),
  (
    (state, read) => {
      if value == auto {
        (ensure(key, default).first())(state, read)
      } else {
        (put(key, value).first())(state, read)
      }
    },
  ),
)

/// Creates an operation to transform an existing value using a callback function.
///
/// # Example
/// ```typ
/// update("count", c => c + 1)
/// // Or with a path:
/// update("stats", "visitors", "count", c => c + 1)
/// ```
///
/// -> operation
#let update(
  /// Optional path of keys to traverse before updating.
  /// -> str
  ..path,
  /// The key to update.
  /// -> str
  key,
  /// A function that takes the current value of `key` and returns the new value.
  /// -> function
  fn,
) = _auto-nest(
  path.pos(),
  (
    (state, read) => {
      if (not key in state.base) and (key in state.patch) { return state }

      let new-patch = state.patch + ((key): fn(read(key)))
      (base: state.base, patch: new-patch)
    },
  ),
)

/// Creates an operation to remove a key from the dictionary.
///
/// -> operation
#let remove(
  /// Optional path of keys to traverse before removing the key.
  /// -> str
  ..path,
  /// The key to remove.
  /// -> str
  key,
) = _auto-nest(
  path.pos(),
  (
    (state, read) => {
      let new-patch = state.patch
      let _ = new-patch.remove(key, default: none)

      let new-base = state.base
      let _ = new-base.remove(key, default: none)

      (base: new-base, patch: new-patch)
    },
  ),
)

/// Merges a dictionary shallowly into the current state.
///
/// If a key in `other` already exists in the target, it is overwritten.
///
/// -> operation
#let merge(
  /// Optional path of keys to traverse before merging.
  /// -> str
  ..path,
  /// The dictionary to merge.
  /// -> dictionary
  other,
) = _auto-nest(
  path.pos(),
  (
    (state, read) => {
      let new-patch = state.patch + other
      (base: state.base, patch: new-patch)
    },
  ),
)

/// Merges a dictionary deeply into the current state.
///
/// Unlike `merge` (which is shallow), this operation recursively merges
/// nested dictionaries.
///
/// -> operation
#let merge-deep(
  /// Optional path of keys to traverse before merging.
  /// -> str
  ..path,
  /// The dictionary to merge.
  /// -> dictionary
  other,
) = _auto-nest(
  path.pos(),
  (
    (state, reader) => {
      let new-patch = state.patch

      // Iterate over the keys we want to merge in
      for (key, val) in other {
        let curr = reader(key)
        let merged = collection.merge-deep(curr, val)
        new-patch.insert(key, merged)
      }

      (base: state.base, patch: new-patch)
    },
  ),
)

/// Ensures that a dictionary structure exists deeply.
///
/// Unlike `merge-deep`, this operation treats the input `defaults` as fallback values.
/// - If a key exists in the current state, the current value is preserved.
/// - If a key is missing, the value from `defaults` is used.
/// - Nested dictionaries are merged recursively to ensure the structure exists.
///
/// # Example
/// ```typ
/// let defaults = (
///   theme: (color: "blue", font: "serif"),
///   meta: (version: 1)
/// )
///
/// // If state was: (theme: (color: "red"))
/// // Result is: (theme: (color: "red", font: "serif"), meta: (version: 1))
/// ensure-deep(defaults)
/// ```
///
/// -> operation
#let ensure-deep(
  /// Optional path of keys to traverse before ensuring the structure.
  /// -> str
  ..path,
  /// The dictionary containing default structure and values.
  /// -> dictionary
  defaults,
) = _auto-nest(
  path.pos(),
  (
    (state, reader) => {
      let new-patch = state.patch

      // Internal helper: recursively merges defaults into a target.
      // We define this locally to ensure "keep-existing" semantics
      // regardless of how collection.merge-deep is implemented.
      let _apply-defaults(target, defs) = {
        // 1. If target is missing, the default wins entirely.
        if target == none { return defs }

        // 2. If mismatch types or not dictionaries, the existing target wins.
        if type(target) != dictionary or type(defs) != dictionary {
          return target
        }

        // 3. Both are dictionaries: recurse into keys.
        let result = target
        for (k, v) in defs {
          let t-val = result.at(k, default: none)
          result.insert(k, _apply-defaults(t-val, v))
        }
        return result
      }

      // Iterate over the keys in the defaults object
      for (key, default-val) in defaults {
        let curr = reader(key)
        let ensured = _apply-defaults(curr, default-val)
        new-patch.insert(key, ensured)
      }

      (base: state.base, patch: new-patch)
    },
  ),
)
