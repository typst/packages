/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/data/frame.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Defines the `frame` data structure, which is the fundamental unit of data
 * exchange in Loom. A frame wraps user signals with system metadata (path, kind).
 * ----------------------------------------------------------------------------
 */

#import "../lib/assert.typ": assert-types

/// Creates a new frame instance.
///
/// Frames are the standardized envelopes for passing data between motifs.
/// They carry both the user's data (`signal`) and the engine's routing information
/// (`path`, `kind`, `key`).
///
/// -> frame
#let new(
  /// The category of the component (e.g., "task", "ingredient")
  /// -> str
  kind: "node",
  /// The specific identifier (e.g., "backend-task").
  /// -> str | none
  key: none,
  /// The absolute path to the component in the hierarchy.
  /// -> path
  path: (),
  /// The user-defined data.
  /// -> any
  signal: none,
) = {
  assert-types(kind, str)
  assert-types(key, array, none)
  assert-types(path, array)

  (
    type: "frame",
    kind: kind,
    key: key,
    path: path,
    signal: signal,
    sys: (:),
  )
}

/// Checks if a dictionary is a valid Loom frame.
///
/// Verifies the presence of the `type: "frame"` marker and all required fields.
///
/// -> bool
#let is-frame(
  /// The value to check.
  /// -> any
  data,
) = {
  if not type(data) == dictionary { return false }
  if not data.at("type", default: none) == "frame" { return false }

  ("type", "kind", "key", "path", "signal", "sys")
    .map(f => f in data)
    .fold(true, (acc, x) => acc and x)
}

/// Merges additional system fields into an existing frame.
///
/// Used by the engine to attach debug info or children data to a frame
/// after it has been created by the user.
///
/// -> frame
#let add-sys(
  /// The target frame.
  /// -> frame
  frame,
  /// The system fields to merge.
  /// -> dictionary
  sys-ctx,
) = {
  assert-types(frame, dictionary)
  assert-types(sys-ctx, dictionary)
  let current-sys = frame.at("sys", default: (:))
  frame.sys = current-sys + sys-ctx
  return frame
}

/// Overwrites the system fields of a frame.
///
/// -> frame
#let set-sys(
  /// The target frame.
  /// -> frame
  frame,
  /// The new system dictionary.
  /// -> dictionary
  sys-ctx,
) = {
  assert-types(frame, dictionary)
  assert-types(sys-ctx, dictionary)
  frame.sys = sys-ctx
  return frame
}

/// Normalizes any input into a flat array of frames.
///
/// This ensures that the engine always works with a consistent list structure,
/// regardless of what the user's measure function returned.
///
/// **Rules:**
/// 1. `none` becomes `()`.
/// 2. Single values (dict, string, etc.) become `(value,)`.
/// 3. Arrays are flattened recursively and `none` entries are removed.
///
/// -> array<frame>
#let normalize(
  /// The raw data returned by a measure function or child.
  /// -> any
  data,
) = {
  if data == none { return () }

  if type(data) == array {
    data.map(item => normalize(item)).flatten()
  } else if is-frame(data) {
    (data,)
  } else {
    panic(
      "Loom Data Contract Violation."
        + "Expected a `frame` or `array of frames`, but got: `"
        + str(type(data))
        + "` "
        + "Value: "
        + repr(data)
        + " "
        + "Did you forget to wrap your data in a frame or use a primitive that does it for you?",
    )
  }
}
