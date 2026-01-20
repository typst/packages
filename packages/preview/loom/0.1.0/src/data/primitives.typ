/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/data/primitives.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Defines the core constructor primitives for creating Loom components.
 * These functions wrap user-defined logic (measure, draw, scope) into the
 * standard metadata structure required by the Engine.
 * ----------------------------------------------------------------------------
 */

#import "../lib/assert.typ": assert-types
#import "../core/context.typ"
#import "frame.typ"
#import "path.typ"

// ----------------------------------------------------------------------------
// INTERNAL HELPERS (Fast checks)
// ----------------------------------------------------------------------------

#let _is-measure(data) = {
  return data == none or (type(data) == array and data.len() == 2)
}

#let _is-draw(body) = {
  return body == none or type(body) == content
}

// ----------------------------------------------------------------------------
// CORE PRIMITIVE (Unsafe / Trusted)
// ----------------------------------------------------------------------------

/// Internal base primitive.
/// Assumes all functions are already validated and conform to the Engine API.
/// Does NOT perform any safety checks for performance reasons.
#let _motif-core(
  key,
  scope,
  measure,
  draw,
  body,
) = {
  // Minimal defaults handling to prevent engine crashes on null-pointers
  let final-scope = if scope == none { c => c } else { scope }
  let final-measure = if measure == none {
    (ctx, children) => (none, none)
  } else { measure }
  let final-draw = if draw == none { (ctx, p, v, body) => body } else { draw }

  [#metadata((
      type: "component",
      scope: final-scope,
      measure: final-measure,
      draw: final-draw,
      body: body,
    ))#key]
}

// ----------------------------------------------------------------------------
// PUBLIC PRIMITIVES
// ----------------------------------------------------------------------------

/// The base primitive for creating a Loom component.
///
/// Wraps the provided functions in a metadata block labeled with `key`.
/// This is the rawest form of a component; it does not automatically handle
/// path management or frame wrapping (see `managed-motif` for that).
///
/// -> content
#let motif(
  /// The namespace key used by the engine to identify this component.
  /// -> label
  key: <motif>,
  /// Function `ctx => ctx`. Modifies the context for children.
  /// -> function
  scope: ctx => ctx,
  /// Function `(ctx, children-data) => (public, view)`.
  /// Calculates data and prepares the view model.
  /// -> function
  measure: none,
  /// Function `(ctx, public, view, body) => content`.
  /// Renders the component.
  /// -> function
  draw: none,
  /// The content body of the component.
  /// -> content
  body,
) = {
  assert(
    type(key) == label,
    message: "motif: `key` must be a label, got " + repr(type(key)),
  )

  // 1. Wrap Measure (Only if user provided one)
  let safe-measure = if measure == none { none } else {
    (ctx, children-data) => {
      let res = measure(ctx, children-data)
      if not _is-measure(res) {
        let loc = path.to-string(ctx)
        panic(
          "motif: function `measure` must return `(any, any)` or `none`, but returned "
            + repr(res)
            + " at "
            + loc,
        )
      }
      res
    }
  }

  // 2. Wrap Draw (Only if user provided one)
  let safe-draw = if draw == none { none } else {
    (ctx, public, view, body) => {
      let res = draw(ctx, public, view, body)
      if not _is-draw(res) {
        let loc = path.to-string(ctx)
        panic(
          "motif: function `draw` must return `content` or `none`, but returned type "
            + repr(type(res))
            + " at "
            + loc,
        )
      }
      res
    }
  }

  // 3. Call Core directly
  _motif-core(key, scope, safe-measure, safe-draw, body)
}

/// A "Managed" motif that automatically handles path tracking.
///
/// Unlike the raw `motif`, this primitive:
/// 1. Pushes its `name` to `sys.path` in the scope.
/// 2. Wraps the result of `measure` in a `frame` object containing the current path and key.
///
/// Use this for components that need to be addressable or have an identity in the tree.
///
/// -> content
#let managed-motif(
  /// The specific name/kind of this component (e.g., "task", "section").
  /// -> str
  name,
  /// The namespace key.
  /// -> label
  key: <motif>,
  /// Function `ctx => ctx`.
  /// -> function
  scope: none,
  /// Function `(ctx, children-data) => (public, view)`.
  /// -> function
  measure: none,
  /// Function `(ctx, public, view, body) => content`.
  /// -> function
  draw: none,
  /// -> content
  body,
) = {
  assert(
    type(name) == str,
    message: "managed-motif: `name` must be a string, got " + repr(type(name)),
  )

  // Logic for Scope
  let managed-scope = ctx => {
    let path-ctx = path.append(ctx, name)
    if scope == none { return path-ctx } // Fast path if no user scope
    scope(path-ctx)
  }

  // Logic for Measure
  let managed-measure = (ctx, children-data) => {
    if measure == none { return (none, none) }

    // Execute user function
    let res = measure(ctx, children-data)

    // SAFETY CHECK HERE: We must validate because we are about to destructure it
    if not _is-measure(res) and res != none {
      let loc = path.to-string(ctx)
      panic(
        "motif `"
          + name
          + "` (managed): function `measure` must return data in format `(any, any)` or `none` but returned "
          + repr(res)
          + " at "
          + loc,
      )
    }

    let (user-public, user-view) = if res == none { (none, none) } else { res }
    let current-path = path.get(ctx)

    // Auto-management: Wrap public data in a standard Frame
    let motif-frame = frame.new(
      kind: name,
      key: current-path.last(default: ("unknown",)),
      path: current-path,
      signal: user-public,
    )

    return (motif-frame, user-view)
  }

  // Call _motif-core DIRECTLY.
  // We do NOT call `motif(...)` here. This saves one layer of wrapper functions
  // and avoids double-checking the result of `managed-measure` (which we know is valid).
  _motif-core(
    key,
    managed-scope,
    managed-measure,
    draw,
    body,
  )
}

/// A helper primitive for components that primarily calculate data.
///
/// It simplifies the `measure` signature to return only the public payload (`public`).
/// The view model is automatically set to `none`.
///
/// -> content
#let compute-motif(
  /// The namespace key.
  /// -> label
  key: <motif>,
  /// If provided, creates a `managed-motif`. If `none`, creates a raw `motif`.
  /// -> str | none
  name: none,
  /// Function `ctx => ctx`.
  /// -> function
  scope: ctx => ctx,
  /// Function `(ctx, children-data) => public`.
  /// Note: Returns only the public payload.
  /// -> function
  measure: none,
  /// -> content
  body,
) = {
  if name != none {
    assert(
      type(name) == str,
      message: "compute-motif: `name` must be a string or none, got "
        + repr(type(name)),
    )
  }

  let args = (
    scope: if scope == none { ctx => ctx } else { scope },
    measure: (ctx, children-data) => {
      if measure == none { return (none, none) }
      // We don't check the return type here strictly because 'public' data can be anything,
      // but we guarantee the tuple structure for the parent motif.
      return (measure(ctx, children-data), none)
    },
  )

  if name == none { motif(key: key, ..args, body) } else {
    managed-motif(key: key, name, ..args, body)
  }
}

/// A specialized primitive for purely data-driven components (Leaves).
///
/// These components do not render anything (`body` is `none`) and are used
/// solely to inject data (signals) into the system.
///
/// -> content
#let data-motif(
  /// The namespace key.
  /// -> label
  key: <component>,
  /// The name/kind of the data node.
  /// -> str
  name,
  /// Function `ctx => ctx`.
  /// -> function
  scope: none,
  /// Function `ctx => public`.
  /// Note: Data motifs typically don't process children.
  /// -> function
  measure: none,
) = {
  assert(
    type(name) == str,
    message: "data-motif: `name` must be a string, got " + repr(type(name)),
  )

  let fallback-scope = if scope == none { ctx => ctx } else { scope }

  compute-motif(
    key: key,
    name: name,
    scope: fallback-scope,
    measure: (ctx, _) => {
      if measure == none { return none }
      measure(ctx)
    },
    none,
  )
}

/// A specialized primitive for purely visual components.
///
/// These components participate in the flow but do not emit signals or manage paths.
/// They transparently propagate their children's signals.
///
/// -> content
#let content-motif(
  /// The namespace key.
  /// -> label
  key: <component>,
  /// Function `ctx => ctx`.
  /// -> function
  scope: ctx => ctx,
  /// Function `(ctx, body) => content`.
  /// -> function
  draw: none,
  /// Optional positional body argument
  /// -> ..content
  ..body,
) = {
  motif(
    key: key,
    scope: scope,
    // Content motifs pass through children data as the public signal
    measure: (_, children-data) => (
      if children-data == () { none } else { children-data },
      none,
    ),
    draw: (ctx, _, _, body) => {
      if draw == none { return none }

      let res = draw(ctx, body)
      if not _is-draw(res) {
        let loc = path.to-string(ctx)
        panic(
          "content-motif: function `draw` must return `content` or `none`, but returned type "
            + repr(type(res))
            + " at "
            + loc,
        )
      }
      res
    },
    body.pos().first(default: none),
  )
}
