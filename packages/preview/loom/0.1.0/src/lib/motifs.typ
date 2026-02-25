/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/motifs.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Collection of utility motifs (components) provided by the standard library.
 * Includes tools for debugging and context manipulation.
 * ----------------------------------------------------------------------------
 */

#import "../core/context.typ": get-system-field, scope
#import "../data/primitives.typ": motif
#import "assert.typ": assert-types

/// A utility motif that visualizes the data flow for debugging purposes.
///
/// If enabled, it prints the internal `children-data` structure directly into the document
/// before rendering the body. This is useful for inspecting signals and calculated views.
///
/// # Example
/// ```typ
/// #debug(display: true)[
///   #my-component(...)
/// ]
/// ```
///
/// -> content
#let debug-motif(
  /// The namespace key.
  /// -> label
  key: <motif>,
  /// If `true`, forces the debug output. If `false`, hides it.
  /// If `auto`, it inherits the global debug state from the context.
  /// -> bool | auto
  display: auto,
  /// -> ..any
  ..args,
  /// The content to wrap.
  /// -> content
  body,
) = {
  assert-types(display, auto, bool)

  motif(
    key: key,
    measure: (ctx, children-data) => {
      let show-children = if display == auto {
        get-system-field(ctx, "debug", default: false)
      } else { display }

      // Return the children-data as the view so it can be printed in the draw phase
      return (children-data, if show-children { children-data } else { none })
    },
    draw: (ctx, _, private, body) => {
      if private != none [#private]
      body
    },
    body,
  )
}


/// A utility motif that injects variables into the context scope for its children.
///
/// This serves as a wrapper to set context variables without creating a custom component.
/// It effectively acts like a `let` binding that propagates down the tree.
///
/// # Example
/// ```typ
/// #apply(theme: "dark", level: 1)[
///   #child-component(...) // child sees theme="dark"
/// ]
/// ```
///
/// -> content
#let apply-motif(
  /// The namespace key.
  /// -> label
  key: <motif>,
  /// Named arguments are injected into the scope.
  /// -> ..any
  ..args,
  /// The content to wrap.
  /// -> content
  body,
) = {
  motif(
    key: key,
    scope: ctx => scope(
      ctx,
      ..(
        args
          .named()
          .pairs()
          .filter(((_, value)) => value != auto)
          .map(((key, value)) => (key, (value, value)))
          .to-dict()
      ),
    ),
    body,
  )
}
