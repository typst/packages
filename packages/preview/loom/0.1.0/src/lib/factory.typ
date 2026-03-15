/*
 * ----------------------------------------------------------------------------
 * Project: Loom
 * File:    src/lib/factory.typ
 * Author:  Leonie Juna Ziechmann
 * Created: 2026-01-04
 * License: MIT
 * ----------------------------------------------------------------------------
 * Copyright (c) 2026 Leonie Juna Ziechmann. All rights reserved.
 * ----------------------------------------------------------------------------
 * Description:
 * Factory module for constructing Loom instances.
 * Maps the internal core and primitive functions to a user-friendly public API,
 * binding them to a specific label key (namespace) for safety.
 * ----------------------------------------------------------------------------
 */

#import "../core/runtime.typ"
#import "../data/primitives.typ"
#import "motifs.typ"

/// Constructs a new Loom instance bound to a specific namespace key.
///
/// This function acts as the bridge between the user's project and the Loom engine.
/// It returns a dictionary of tools (weave, motifs, utilities) that are all
/// pre-configured to use the provided `key` for identification.
///
/// # Example
/// ```typ
/// #let loom = construct(<my-project>)
/// #loom.weave(...)
/// ```
///
/// -> dictionary
#let construct(
  /// A unique label to identify components belonging to this Loom instance.
  /// -> label
  key,
) = (
  // Engine Entrypoint
  weave: runtime.weave.with(key: key),
  // Component Constructors
  motif: (
    plain: primitives.motif.with(key: key),
    managed: primitives.managed-motif.with(key: key),
    compute: primitives.compute-motif.with(key: key),
    data: primitives.data-motif.with(key: key),
    content: primitives.content-motif.with(key: key),
  ),
  // Pre-built Utility Components
  prebuild-motif: (
    debug: motifs.debug-motif.with(key: key),
    apply: motifs.apply-motif.with(key: key),
  ),
)
