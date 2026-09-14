/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/core/runtime.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Orchestrates the Loom execution lifecycle.
 * Manages the multi-pass measure loop (fixed-point iteration) and the final
 * draw pass, handling context injection and convergence checks.
 * ----------------------------------------------------------------------------
 */

#import "engine.typ"
#import "context.typ": empty-context, get-system-field, set-system-fields
#import "../lib/assert.typ": assert-types


/// The main entry point for Loom.
///
/// Initiates the fixed-point engine execution. It repeatedly measures the content
/// until the data converges (stabilizes) or the maximum number of passes is reached.
/// Finally, it performs a draw pass to generate the visual output.
///
/// -> content | (director: content, observer: array<content>)
#let weave(
  /// The namespace key used to identify components.
  /// -> label
  key: <motif>,
  /// Callback `(ctx, payload) => dictionary`.
  /// Used to inject the calculated payload from the previous pass back into the context.
  /// -> function
  injector: (ctx, payload) => (global: payload),
  /// Enables verbose logging and debug visuals.
  /// -> bool
  debug: false,
  /// Initial global variables to inject into the context.
  /// -> dictionary
  inputs: (:),
  /// Callback executed if the engine fails to converge within `max-passes`.
  /// -> function
  handle-nonconvergence: (ctx, iterations, last-payload, current-payload) => {
    none
  },
  /// Maximum total passes (measure + draw). Defaults to 2.
  /// -> int
  max-passes: 2,
  /// Optional content nodes to process alongside the director.
  /// Observers are only calculated once during the draw phase and will be ignored for fix point calculation
  /// -> none | array<content>
  observer: none,
  /// The main content to process.
  /// -> none | content
  director,
) = {
  assert-types(observer, none, array)
  assert-types(director, none, content)

  // Initial Context Setup
  let base-ctx = empty-context + inputs
  base-ctx = set-system-fields(base-ctx, debug: debug, key: key)

  let current-payload = ()
  let fix-point-reached = false

  let measure-limit = if max-passes > 1 { max-passes - 1 } else { 0 }

  // --- 1. Measure Loop ---
  for i in range(measure-limit) {
    let measure-ctx = set-system-fields(base-ctx, pass: "measure")
    let transition-data = injector(measure-ctx, current-payload)
    measure-ctx = measure-ctx + transition-data

    let (_, new-payload) = engine.intertwine(
      measure-ctx,
      director,
      key: key,
      draw: false,
    )

    // check for convergence
    if i > 0 and new-payload == current-payload {
      fix-point-reached = true
      if debug { rect(fill: red)[Converged early at pass #i] }
      current-payload = new-payload
      break
    }

    if i == measure-limit - 1 and measure-limit > 1 {
      [#handle-nonconvergence(measure-ctx, i + 1, current-payload, new-payload)]
    }

    current-payload = new-payload
  }

  // --- 2. Final Draw ---
  let draw-ctx = set-system-fields(base-ctx, pass: "draw")
  let final-transition = injector(draw-ctx, current-payload)
  draw-ctx = draw-ctx + final-transition

  let (final-director, ..) = engine.intertwine(
    draw-ctx,
    director,
    key: key,
    draw: true,
  )

  if observer == none {
    final-director
  } else {
    let final-observer = observer.map(observer_ => {
      engine
        .interwine(
          draw-ctx,
          observer_,
          key: key,
          draw: true,
        )
        .at(0)
    })

    (director: final-director, observer: final-observer)
  }
}
