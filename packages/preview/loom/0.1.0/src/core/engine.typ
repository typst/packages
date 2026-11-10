/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/core/engine.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * The core traversal engine of Loom.
 * Defines the `intertwine` function, which recursively visits the content tree,
 * executes component logic (Scope -> Measure -> Draw), and reconstructs the
 * document structure.
 * ----------------------------------------------------------------------------
 */

#import "../data/frame.typ"
#import "context.typ": get-system-field, set-system-fields


/// Checks if a content node is a registered Loom component.
///
/// A node is considered a component if:
/// 1. It is a `metadata` element.
/// 2. Its label matches the provided namespace `key`.
/// 3. Its value is a dictionary containing `type: "component"`.
///
/// -> dictionary | none
#let get-component(
  /// The content node to inspect.
  /// -> content
  node,
  /// The namespace label to validate against.
  /// -> label
  key,
) = {
  if node == none or node.func() != metadata { return none }

  if node.at("label", default: none) != key { return none }

  let value = node.value
  if type(value) != dictionary { return none }

  // Check for the explicit type marker set by the component constructor
  if value.at("type", default: none) != "component" { return none }

  return value
}

/// The main traversal function (The Heart of Loom).
///
/// It recursively walks through the user's content tree and handles five distinct cases:
/// 1. **Component:** Executes the Loom lifecycle (Scope -> Measure -> Draw).
/// 2. **Container:** (e.g., Stack, Grid) Recursively visits children and aggregates results.
/// 3. **Wrapper:** (e.g., Block, Align) Recursively visits the body and reconstructs the element.
/// 4. **Generic:** Best-effort traversal for elements with a `child` field.
/// 5. **Atomic:** (e.g., Text, Image) Returns as-is.
///
/// Returns a tuple `(content, data)` where:
/// - `content`: The fully rendered content (only populated if `draw: true`).
/// - `data`: An array of `frame` objects containing the signals collected from this branch.
///
/// -> (content, array<frame>)
#let intertwine(
  /// The current context dictionary.
  /// -> dictionary
  ctx,
  /// The content node to process.
  /// -> content
  node,
  /// The namespace label used to identify Loom components.
  /// -> label
  key: <motif>,
  /// If `true`, generates visual output. If `false`, performs a dry-run for data collection.
  /// -> bool
  draw: false,
) = {
  // Base Case: Empty node
  if node == none { return (none, ()) }

  // --- CASE 1: COMPONENT (The core logic) ---
  let component = get-component(node, key)
  if component != none {
    // 1. SCOPE PHASE
    // Allow the component to modify the context for its children.
    // This happens before we visit the children.
    let child-ctx = (component.scope)(ctx)
    child-ctx = set-system-fields(child-ctx, relative-id: 0)

    // 2. AUTO-TRAVERSAL
    // The engine automatically visits the body with the new context.
    let (body-content, children-public) = intertwine(
      child-ctx,
      component.body,
      key: key,
      draw: draw,
    )

    // Prepare input data for the measure function.
    // Ensure we always pass an array of public models, filtering out 'none'.
    let raw-data = if type(children-public) == array { children-public } else {
      (children-public,)
    }
    let clean-data = raw-data.filter(d => d != none)

    // 3. MEASURE PHASE
    // Pure calculation based on the context and the children's public data.
    // Does not have access to content, preventing side effects on the layout.
    let (my-public, my-view) = (component.measure)(child-ctx, clean-data)

    if type(my-public) == dictionary {
      if get-system-field(child-ctx, "debug", default: false) {
        my-public = frame.add-sys(my-public, (children: clean-data))
      }
    }

    // 4. DRAW PHASE
    // Only executed if the draw flag is set.
    // Combines the calculated models with the processed body content.
    let content = if draw {
      (component.draw)(child-ctx, my-public, my-view, body-content)
    } else {
      none
    }

    return (content, frame.normalize(my-public))
  }

  // --- CASE 2: CONTAINER (Grid, Stack, Sequence) ---
  if node.has("children") {
    // Recursively intertwines all children
    let results = node
      .children
      .enumerate()
      .map(((i, child)) => {
        let inner-ctx = set-system-fields(ctx, relative-id: i)
        let result = intertwine(inner-ctx, child, key: key, draw: draw)
        result
      })

    // A. Content Aggregation (for rendering)
    let merged-content = if draw {
      // For sequences, we join the content.
      // For layouts (Grid/Stack), this is handled below.
      results.map(r => r.at(0)).join()
    } else {
      none
    }

    // B. Data Aggregation
    // Preserve the structure (array) of the children's data.
    let collected-public = frame.normalize(results.map(((_, public)) => public))

    if node.func() == [].func() {
      return (merged-content, collected-public)
    } else if draw {
      let new-children = results.map(r => r.at(0)).filter(c => c != none)

      let args = node.fields()
      let _ = args.remove("children")

      return ((node.func())(..args, ..new-children), collected-public)
    } else {
      return (none, collected-public)
    }
  }

  // --- CASE 3: WRAPPER (Block, Align, Styles) ---
  if node.has("body") {
    let (child-content, signals) = intertwine(
      ctx,
      node.body,
      key: key,
      draw: draw,
    )

    let content = if draw {
      let args = node.fields()
      let _ = args.remove("body")

      let pos-args = ()

      // Handle positional arguments that Typst stores as named fields
      if "alignment" in args { pos-args.push(args.remove("alignment")) }
      if "angle" in args { pos-args.push(args.remove("angle")) }
      if "dest" in args { pos-args.push(args.remove("dest")) }
      if "count" in args { pos-args.push(args.remove("count")) }

      // Reconstruct the wrapper with the processed child content
      (node.func())(..pos-args, ..args, child-content)
    } else {
      none
    }
    return (content, signals)
  }

  // --- CASE 4: GENERIC WRAPPER (fallback for elements with 'child') ---
  if node.has("child") {
    let (child-content, signals) = intertwine(
      ctx,
      node.child,
      key: key,
      draw: draw,
    )

    let content = if draw {
      let args = node.fields()
      let _ = args.remove("child")

      let pos-args = ()

      if "styles" in args { pos-args.push(args.remove("styles")) }

      // Best effort reconstruction
      (node.func())(..args, child-content, ..pos-args)
    } else {
      none
    }
    return (content, signals)
  }

  // --- CASE 5: ATOMIC CONTENT (Text, Image, Shapes) ---
  return (if draw { node } else { none }, ())
}
